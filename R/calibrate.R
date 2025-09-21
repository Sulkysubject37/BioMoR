#' Calibrate model probabilities
#' @param model caret or xgboost model
#' @param test_data test dataframe
#' @param method "platt" or "isotonic"
#' @return calibrated probs
calibrate_model <- function(model, test_data, method = "platt") {
  probs <- predict(model, newdata = test_data, type = "prob")[, "Active"]
  if (method == "platt") {
    platt_model <- glm(test_data$Label ~ probs, family = binomial)
    return(predict(platt_model, type = "response"))
  } else if (method == "isotonic") {
    iso_model <- isoreg(probs, as.numeric(test_data$Label == "Active"))
    return(pmin(pmax(iso_model$yf, 0), 1))  # clamp to [0,1]
  } else stop("Unknown method")
}