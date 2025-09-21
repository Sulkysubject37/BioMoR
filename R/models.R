# ============================
# Models for BioMoR
# ============================

# --- Random Forest ---
#' Train a Random Forest model with caret
#'
#' @param df A data.frame containing predictors and outcome
#' @param outcome_col Name of the outcome column (binary factor)
#' @param ctrl A caret::trainControl object
#'
#' @return A caret train object
#' @export
train_rf <- function(df, outcome_col = "Label", ctrl) {
  # Ensure binary factor outcome
  df[[outcome_col]] <- factor(df[[outcome_col]])
  if (length(levels(df[[outcome_col]])) != 2) {
    stop("Outcome must be binary for ROC-based evaluation.")
  }
  
  # Recipe: handle characters/factors and normalize numeric predictors
  recipe_spec <- recipes::recipe(as.formula(paste(outcome_col, "~ .")), data = df) %>%
    recipes::step_string2factor(all_nominal_predictors()) %>%
    recipes::step_dummy(all_nominal_predictors()) %>%
    recipes::step_zv(all_predictors()) %>%
    recipes::step_normalize(all_numeric_predictors())
  
  caret::train(
    recipe_spec,
    data = df,
    method = "rf",
    trControl = ctrl,
    metric = "ROC",
    tuneLength = 5
  )
}

# --- XGBoost ---
#' Train an XGBoost model with caret
#'
#' @param df A data.frame containing predictors and outcome
#' @param outcome_col Name of the outcome column (binary factor)
#' @param ctrl A caret::trainControl object
#'
#' @return A caret train object
#' @export
train_xgb_caret <- function(df, outcome_col = "Label", ctrl) {
  # Ensure binary factor outcome
  df[[outcome_col]] <- factor(df[[outcome_col]])
  if (length(levels(df[[outcome_col]])) != 2) {
    stop("Outcome must be binary for ROC-based evaluation.")
  }
  
  # Recipe: convert characters to factors, dummy encode, remove zero-variance, normalize
  recipe_spec <- recipes::recipe(as.formula(paste(outcome_col, "~ .")), data = df) %>%
    recipes::step_string2factor(all_nominal_predictors()) %>%
    recipes::step_dummy(all_nominal_predictors()) %>%
    recipes::step_zv(all_predictors()) %>%
    recipes::step_normalize(all_numeric_predictors())
  
  caret::train(
    recipe_spec,
    data = df,
    method = "xgbTree",
    trControl = ctrl,
    metric = "ROC",
    tuneLength = 5
  )
}

# --- Data prep helper ---
#' Prepare dataset for modeling
#'
#' @param df A data.frame
#' @param outcome_col Name of the outcome column
#'
#' @return A processed data.frame with factor outcome
#' @export
prepare_model_data <- function(df, outcome_col = "Label") {
  df[[outcome_col]] <- factor(df[[outcome_col]])
  df
}