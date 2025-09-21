test_that("biomor_benchmark returns metrics", {
  df <- iris
  # Balanced binary target
  df$Label <- ifelse(df$Species %in% c("setosa", "versicolor"), "Active", "Inactive")
  df$Label <- factor(df$Label, levels = c("Inactive", "Active"))
  
  ctrl <- BioMoR::get_cv_control(cv = 3)
  fit <- BioMoR::train_rf(df, "Label", ctrl)
  
  metrics <- BioMoR::biomor_benchmark(fit, df, outcome_col = "Label")
  
  expect_true(is.list(metrics))
  expect_true(all(c("Accuracy", "F1", "ROC_AUC") %in% names(metrics)))
})