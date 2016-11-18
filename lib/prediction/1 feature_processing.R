library(rhdf5)
# define working path
train_data_path <- "/Users/YaqingXie/Desktop/3-Applied Data Science/Fall2016-proj4-yaqing-xie/data/Project4_data/data/"
test_data_path <- "/Users/YaqingXie/Desktop/3-Applied Data Science/Fall2016-proj4-yaqing-xie/data/TestSongFile100"
pca_matrix_path <- "/Users/YaqingXie/Desktop/3-Applied Data Science/Fall2016-proj4-yaqing-xie/lib/prediction"
data_output_path <- "/Users/YaqingXie/Desktop/3-Applied Data Science/Fall2016-proj4-yaqing-xie/data/prediction"
setwd(train_data_path)
file_names <- list.files(recursive = T)
file_num <- length(file_names)



### check whether songs in training set have 0 dim features ###
for(i in 1:file_num){
  data <- h5read(file_names[i], "analysis")
  H5close()
  if(length(data$bars_confidence) == 0){
    print(i)
    print("bars")
  }
  if(length(data$beats_confidence) == 0){
    print(i)
    print("beats")
  }
  if(length(data$sections_confidence) == 0){
    print(i)
    print("sections")
  }
  if(length(data$segments_confidence) == 0){
    print(i)
    print("segments")
  }
  if(length(data$tatums_confidence) == 0){
    print(i)
    print("tatums")
  }
}
# output
ab_songs <- c(715, 950, 991, 1112, 1325, 1375, 1658, 1705, 2284)



### find out median dimension of different features using training data###
data.bars = vector()
data.beats = vector()
data.sec = vector()
data.seg = vector()
data.tat = vector()
n = 1
for(i in 1:file_num){
  if(! i %in% ab_songs){
    data <- h5read(file_names[i], "analysis")
    H5close()
    data.bars[n] <- length(data$bars_confidence)
    data.beats[n] <- length(data$beats_confidence)
    data.sec[n] <- length(data$sections_confidence)
    data.seg[n] <- length(data$segments_confidence)
    data.tat[n] <- length(data$tatums_confidence)
    n = n+1
  }
}
# output
bars_dim <- floor(median(data.bars)) #120
beats_dim <- floor(median(data.beats)) #446
sec_dim <- floor(median(data.sec)) #9
seg_dim <- floor(median(data.seg)) #744
tat_dim <- floor(median(data.tat)) #983



### define feature processing functions ###
feature_truncate_1d <- function(ls, len){
  if(length(ls) >= len){
    ls <- ls[1:len]
  }
  else{
    if(length(ls) == 0){
      ls <- rep(0, len)
    }
    else{
      t <- ceiling(len/length(ls))
      ls <- rep(ls, t)
      ls <- ls[1:len]
    }
  }
  return(ls)
}

feature_truncate_2d <- function(df, ncols){
  if(dim(df)[2] >= ncols){
    df <- df[,1:ncols]
  }
  else{
    if(dim(df)[2] == 0){
      df <- matrix(rep(0, 12*ncols), 12, ncols)
    }
    else{
      t <- ceiling(ncols/dim(df)[2])
      df <- do.call("cbind", replicate(t, df, simplify = FALSE))
      df <- df[,1:ncols]
    }
  }
  ls <- as.vector(t(df))
  return(ls)
}



### convert training data ###
train_data1 <- data.frame(matrix(ncol = 1, nrow = 0))
train_data2 <- data.frame(matrix(ncol = 22151, nrow = 0))
n <- 1
for(i in 1:file_num){
  if(! i %in% ab_songs){
    data <- h5read(file_names[i], "analysis")
    H5close()
    song_id <- substring(file_names[i], nchar(file_names[i])-20, nchar(file_names[i])-3)
    bars_s <- feature_truncate_1d(data$bars_start, 120)
    beats_s <- feature_truncate_1d(data$beats_start, 446)
    sections_s <- feature_truncate_1d(data$sections_start, 9)
    segments_s <- feature_truncate_1d(data$segments_start, 744)
    segments_l_m <- feature_truncate_1d(data$segments_loudness_max, 744)
    segments_l_m_t <- feature_truncate_1d(data$segments_loudness_max_time, 744)
    segments_l_s <- feature_truncate_1d(data$segments_loudness_start, 744)
    segments_p <- feature_truncate_2d(data$segments_pitches, 744)
    segments_t <- feature_truncate_2d(data$segments_timbre, 744)
    tatums_s <- feature_truncate_1d(data$tatums_start, 744)
    new_data_row <- c(bars_s, beats_s, sections_s, segments_s, segments_l_m, segments_l_m_t,
                      segments_l_s, segments_p, segments_t, tatums_s)
    train_data1[n,] <- song_id
    train_data2[n,] <- new_data_row
    n <- n+1
  }
} 



### find columns in training data that have constant values (otherwise PCA won't work)
for(i in 1:22151){
  if(sum(train_data2[,i]==train_data2[1,i])==2341){
    print(i)
  }
}
ab_columns <- c(567, 576)
train_data2 <- cbind(train_data2[,1:566], train_data2[,568:575], train_data2[,577:22151])
train_data <- cbind(train_data1, train_data2)
write.csv(train_data, file = paste(data_output_path, "/train_raw.csv", sep=""))



### train PCA model using training data ###
pca <- prcomp(train_data2, center=TRUE, scale=TRUE)
cumdev <- cumsum(pca$sdev) / sum(pca$sdev)
cumdev_0.9 <- cumdev <= 0.9
n <- sum(cumdev_0.9) + 1
pca_matrix <- pca$rotation[,1:n]
save(pca_matrix, file = paste(pca_matrix_path, "/pca_loading.rda", sep=""))
train_data_pca <- as.matrix(train_data2) %*% pca_matrix
train_data_pca <- cbind(train_data1, train_data_pca)
write.csv(train_data_pca, file = paste(data_output_path, "/train.csv", sep=""))



### convert test data ###
setwd(test_data_path)
file_names <- list.files(recursive = T)
file_num <- length(file_names)
test_data1 <- data.frame(matrix(ncol = 1, nrow = 0))
test_data2 <- data.frame(matrix(ncol = 22151, nrow = 0))
n <- 1
for(i in 1:file_num){
  data <- h5read(file_names[i], "analysis")
  H5close()
  song_id <- substring(file_names[i], nchar(file_names[i])-20, nchar(file_names[i])-3)
  bars_s <- feature_truncate_1d(data$bars_start, 120)
  beats_s <- feature_truncate_1d(data$beats_start, 446)
  sections_s <- feature_truncate_1d(data$sections_start, 9)
  segments_s <- feature_truncate_1d(data$segments_start, 744)
  segments_l_m <- feature_truncate_1d(data$segments_loudness_max, 744)
  segments_l_m_t <- feature_truncate_1d(data$segments_loudness_max_time, 744)
  segments_l_s <- feature_truncate_1d(data$segments_loudness_start, 744)
  segments_p <- feature_truncate_2d(data$segments_pitches, 744)
  segments_t <- feature_truncate_2d(data$segments_timbre, 744)
  tatums_s <- feature_truncate_1d(data$tatums_start, 744)
  new_data_row <- c(bars_s, beats_s, sections_s, segments_s, segments_l_m, segments_l_m_t,
                    segments_l_s, segments_p, segments_t, tatums_s)
  test_data1[n,] <- song_id
  test_data2[n,] <- new_data_row
  n <- n+1
} 
test_data2 <- cbind(test_data2[,1:566], test_data2[,568:575], test_data2[,577:22151])
test_data <- cbind(test_data1, test_data2)
#write.csv(test_data, file = paste(data_output_path, "/test_raw.csv", sep=""))



### apply PCA model on test data ###
load(paste(pca_matrix_path, "/pca_loading.rda", sep=""))
test_data_pca <- as.matrix(test_data2) %*% pca_matrix
test_data_pca <- cbind(test_data1, test_data_pca)
write.csv(test_data_pca, file = paste(data_output_path, "/test.csv", sep=""))
