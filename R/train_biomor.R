#' Train BioMoR Autoencoder
#' @param data Dataframe with numeric features + Label
#' @param feature_cols Character vector of feature columns
#' @param epochs Number of training epochs
#' @param batch_size Batch size
#' @param lr Learning rate
#' @return list(model, dataset, embeddings)
train_biomor <- function(data, feature_cols, epochs = 100, batch_size = 50, lr = 1e-3) {
  ae_obj <- train_autoencoder(data, feature_cols, epochs, batch_size, lr)
  emb <- get_embeddings(ae_obj, data, feature_cols)
  list(model = ae_obj$model, dataset = ae_obj$dataset, embeddings = emb)
}