# ============================
# Utils for BioMoR
# ============================

# --- Cross-validation control (SMOTE ready) ---
#' Get caret cross-validation control
#'
#' Creates a [caret::trainControl] object for cross-validation,
#' configured for two-class problems, ROC-based performance, and optional
#' sampling strategies such as SMOTE or ROSE.
#'
#' @param cv Number of folds (default 5).
#' @param sampling Sampling method (e.g., "smote", "rose", or NULL).
#'
#' @return A [caret::trainControl] object.
#' @export
#' @importFrom caret trainControl twoClassSummary
get_cv_control <- function(cv = 5, sampling = NULL) {
  caret::trainControl(
    method = "cv",
    number = cv,
    classProbs = TRUE,
    summaryFunction = caret::twoClassSummary,
    savePredictions = "final",
    sampling = sampling
  )
}

# --- Brier score ---
#' Compute Brier Score
#'
#' The Brier score is the mean squared error between predicted probabilities
#' and the true binary outcome (0/1). Lower is better.
#'
#' @param y_true True factor labels.
#' @param y_prob Predicted probabilities for the positive class.
#' @param positive Name of the positive class (default `"Active"`).
#'
#' @return Numeric Brier score.
#' @export
brier_score <- function(y_true, y_prob, positive = "Active") {
  y_bin <- ifelse(y_true == positive, 1, 0)
  mean((y_bin - y_prob)^2)
}

# --- Threshold tuning for F1 ---
#' Compute optimal threshold for maximum F1 score
#'
#' Sweeps thresholds between 0 and 1 to find the one that maximizes F1.
#'
#' @param y_true True factor labels.
#' @param y_prob Predicted probabilities for the positive class.
#' @param positive Name of the positive class (default `"Active"`).
#'
#' @return A list with elements:
#' \describe{
#'   \item{threshold}{Best probability cutoff.}
#'   \item{best_f1}{Maximum F1 score achieved.}
#' }
#' @export
#' @importFrom stats factor
compute_f1_threshold <- function(y_true, y_prob, positive = "Active") {
  thresholds <- seq(0, 1, by = 0.01)
  f1_scores <- sapply(thresholds, function(th) {
    preds <- ifelse(y_prob >= th, positive, setdiff(levels(y_true), positive))
    cm <- table(factor(preds, levels = levels(y_true)), y_true)
    
    TP <- cm[positive, positive]
    FP <- cm[positive, setdiff(levels(y_true), positive)]
    FN <- cm[setdiff(levels(y_true), positive), positive]
    
    precision <- ifelse(TP + FP == 0, 0, TP / (TP + FP))
    recall    <- ifelse(TP + FN == 0, 0, TP / (TP + FN))
    
    if (precision + recall == 0) return(0)
    (2 * precision * recall) / (precision + recall)
  })
  
  best_idx <- which.max(f1_scores)
  list(threshold = thresholds[best_idx], best_f1 = f1_scores[best_idx])
}

# --- Global variable declarations ---
#' Declare global variables to silence R CMD check NOTES
#'
#' Declares symbols used internally to avoid NOTE messages from R CMD check.
#'
#' @importFrom utils globalVariables
#' @importFrom stats predict glm isoreg as.formula binomial
#' @importFrom dplyr %>%
#' @importFrom recipes all_nominal_predictors all_predictors all_numeric_predictors
#' @importFrom themis step_smote
utils::globalVariables(c("Label", "Precision", "threshold", "f1", "bal_acc"))