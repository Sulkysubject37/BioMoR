#' Benchmark a trained model
#'
#' Evaluates a trained caret model on test data, returning
#' Accuracy, F1 score, and ROC-AUC. If only one class is present
#' in the test set, ROC-AUC is returned as NA.
#'
#' @param model A trained caret model
#' @param test_data Dataframe containing predictors and outcome
#' @param outcome_col Name of outcome column
#' @return A named list of metrics
#' @export
#' @importFrom caret confusionMatrix
#' @importFrom stats predict
#' @importFrom pROC roc
biomor_benchmark <- function(model, test_data, outcome_col) {
  y_true <- factor(test_data[[outcome_col]], levels = c("Inactive", "Active"))
  
  # Predicted probabilities and labels
  y_prob <- predict(model, test_data, type = "prob")[, "Active"]
  y_pred <- predict(model, test_data)
  
  # Confusion matrix for Accuracy/F1
  cm <- caret::confusionMatrix(y_pred, y_true)
  
  # ROC guarded against single-class issue
  if (length(levels(droplevels(y_true))) < 2) {
    auc <- NA
  } else {
    auc <- pROC::roc(y_true, y_prob, levels = rev(levels(y_true)))$auc
  }
  
  list(
    Accuracy = unname(cm$overall["Accuracy"]),
    F1 = unname(cm$byClass["F1"]),
    ROC_AUC = auc
  )
}