#' BioMoR: Bioinformatics Modeling with Recursion, Autoencoders, and Stacked Models
#'
#' The BioMoR package provides a modeling framework for bioinformatics tasks,
#' combining recursive deep learning architectures (transformer-inspired),
#' autoencoders for feature compression, and stacked models (RF, XGBoost, meta-learners).
#'
#' Main features:
#' - Data preparation utilities with recipe-based preprocessing and SMOTE-ready CV.
#' - Base learners: Random Forest and XGBoost (caret interface).
#' - Meta-models: stacked learners with recursive refinements.
#' - Evaluation: ROC, PR, F1 tuning, balanced accuracy, Brier score, calibration.
#'
#' @section Authors:
#' Maintainer: MD. Arshad <arshad10867c@gmail.com>
#'
#' @docType package
#' @name BioMoR
#'
#' @importFrom stats as.formula binomial glm isoreg predict
#' @importFrom magrittr %>%
#' @importFrom caret train trainControl twoClassSummary
#' @importFrom recipes recipe step_smote step_zv all_predictors
#' @importFrom xgboost xgb.DMatrix xgb.train
#'
#' @keywords internal
"_PACKAGE"