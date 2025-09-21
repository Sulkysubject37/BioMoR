#' Run full BioMoR pipeline
#' @param data dataframe with Label + descriptors
#' @param feature_cols optional feature set
#' @param epochs autoencoder epochs
#' @return list of trained models + benchmark reports
biomor_run_pipeline <- function(data, feature_cols = NULL, epochs = 50) {
  if (is.null(feature_cols)) {
    feature_cols <- setdiff(names(data), c("Label", "SMILES"))
  }
  
  # Pretrain AE
  biomor <- train_biomor(data, feature_cols, epochs = epochs)
  emb <- biomor$embeddings
  df_emb <- data.frame(Label = data$Label, emb)
  
  # RF raw
  rec_raw <- recipe(Label ~ ., data = data) %>% step_smote(Label)
  rf_raw <- train(rec_raw, data = data, method = "rf",
                  metric = "ROC", trControl = trainControl(
                    method = "cv", number = 5, classProbs = TRUE,
                    summaryFunction = twoClassSummary, savePredictions = "final"
                  ))
  
  # RF embeddings
  rec_emb <- recipe(Label ~ ., data = df_emb) %>% step_smote(Label)
  rf_emb <- train(rec_emb, data = df_emb, method = "rf",
                  metric = "ROC", trControl = trainControl(
                    method = "cv", number = 5, classProbs = TRUE,
                    summaryFunction = twoClassSummary, savePredictions = "final"
                  ))
  
  # Stacked XGB
  stack_data <- data.frame(Label = rf_raw$pred$obs,
                           RF_raw = rf_raw$pred$Active,
                           RF_emb = rf_emb$pred$Active)
  stack_data$Label <- ifelse(stack_data$Label == "Active", 1, 0)
  dtrain <- xgb.DMatrix(as.matrix(stack_data[, c("RF_raw", "RF_emb")]), label = stack_data$Label)
  xgb_meta <- xgb.train(params = list(objective = "binary:logistic", eval_metric = "auc"),
                        data = dtrain, nrounds = 200, verbose = 0)
  
  # Benchmarks
  bench_raw <- biomor_benchmark(rf_raw, data)
  bench_emb <- biomor_benchmark(rf_emb, df_emb)
  bench_meta <- list(model = xgb_meta) # direct ROC eval can be added
  
  return(list(rf_raw = rf_raw, rf_emb = rf_emb, xgb_meta = xgb_meta,
              benchmarks = list(raw = bench_raw, emb = bench_emb, meta = bench_meta)))
}