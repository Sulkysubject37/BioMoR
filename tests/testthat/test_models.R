# ============================
# test_models.R
# ============================

test_that("RF model trains and predicts", {
  # Simulated binary dataset
  set.seed(123)
  df <- data.frame(
    X1 = rnorm(100),
    X2 = runif(100),
    Label = factor(sample(c("Active", "Inactive"), 100, replace = TRUE))
  )
  
  ctrl <- BioMoR::get_cv_control(cv = 3)
  
  fit <- BioMoR::train_rf(df, "Label", ctrl)
  preds <- predict(fit, df)
  
  expect_s3_class(fit, "train")
  expect_true(all(levels(preds) == c("Active", "Inactive")))
  expect_length(preds, nrow(df))
})

test_that("XGB model trains and predicts", {
  # Simulated binary dataset
  set.seed(456)
  df <- data.frame(
    X1 = rnorm(120),
    X2 = runif(120),
    Label = factor(sample(c("Active", "Inactive"), 120, replace = TRUE))
  )
  
  ctrl <- BioMoR::get_cv_control(cv = 3)
  
  fit <- BioMoR::train_xgb_caret(df, "Label", ctrl)
  preds <- predict(fit, df)
  
  expect_s3_class(fit, "train")
  expect_true(all(levels(preds) == c("Active", "Inactive")))
  expect_length(preds, nrow(df))
})