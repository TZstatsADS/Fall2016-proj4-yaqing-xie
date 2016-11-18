library(rhdf5)
library("flexclust")
# define working path
train_data_path <- "/Users/YaqingXie/Desktop/3-Applied Data Science/Fall2016-proj4-yaqing-xie/data/Project4_data/data/"
test_data_path <- "/Users/YaqingXie/Desktop/3-Applied Data Science/Fall2016-proj4-yaqing-xie/data/test"
data_output_path <- "/Users/YaqingXie/Desktop/3-Applied Data Science/Fall2016-proj4-yaqing-xie/data/methodology_2"
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



### convert training data ###
train_data_id <- data.frame(matrix(ncol = 1, nrow = 0))
train_data_dura <- data.frame(matrix(ncol = 1, nrow = 0))
train_data_pace <- data.frame(matrix(ncol = 4, nrow = 0))
train_data_sect <- data.frame(matrix(ncol = 5, nrow = 0))
train_data_loud <- data.frame(matrix(ncol = 4, nrow = 0))
train_data_pitches <- data.frame(matrix(ncol = 48, nrow = 0))
train_data_timbre <- data.frame(matrix(ncol = 48, nrow = 0))
n <- 1
for(i in 1:file_num){
  if(! i %in% ab_songs){
    data <- h5read(file_names[i], "analysis")
    H5close()
    song_id <- substring(file_names[i], nchar(file_names[i])-20, nchar(file_names[i])-3)
    duration <- max(data$segments_start)
    bars_int <- mean(diff(data$bars_start))
    beats_int <- mean(diff(data$beats_start))
    sections_num <- length(data$sections_start)
    sections_avg_prop <- mean(diff(data$sections_start)/duration)
    sections_max_prop <- max(diff(data$sections_start)/duration)
    sections_min_prop <- min(diff(data$sections_start)/duration)
    sections_var_prop <- var(diff(data$sections_start)/duration)
    segments_int <- mean(diff(data$segments_start))
    max_loudness_avg <- mean(data$segments_loudness_max)
    max_loudness_max <- max(data$segments_loudness_max)
    max_loudness_min <- min(data$segments_loudness_max)
    max_loudness_var <- var(data$segments_loudness_max)
    pitches <- matrix(nrow = 12, ncol = 4)
    for(j in 1:12){
      pitches[j,1] <- mean(data$segments_pitches[j,])
      pitches[j,2] <- max(data$segments_pitches[j,])
      pitches[j,3] <- min(data$segments_pitches[j,])
      pitches[j,4] <- var(data$segments_pitches[j,])
    }
    pitches <- as.vector(t(pitches))
    timbre <- matrix(nrow = 12, ncol = 4)
    for(j in 1:12){
      timbre[j,1] <- mean(data$segments_timbre[j,])
      timbre[j,2] <- max(data$segments_timbre[j,])
      timbre[j,3] <- min(data$segments_timbre[j,])
      timbre[j,4] <- var(data$segments_timbre[j,])
    }
    timbre <- as.vector(t(timbre))
    tatums_int <- mean(diff(data$tatums_start))
    # create subset of features
    train_data_id[n,] <- song_id
    train_data_dura[n,] <- duration
    train_data_pace[n,] <- tnt,  tatums_int)
    train_data_sect[n,] <- c(sections_num, sections_avg_prop,
                             sections_max_prop, sections_min_prop, sections_var_prop)
    train_data_loud[n,] <- c(max_loudness_avg, max_loudness_max, max_loudness_min,
                             max_loudness_var)
    train_data_pitches[n,] <- pitches
    train_data_timbre[n,] <- timbre
    n <- n+1
  }
}

### save raw training data
train_data_raw <- cbind(train_data_id, train_data_dura, train_data_pace, train_data_sect,
                        train_data_loud,train_data_pitches, train_data_timbre)
train_data_raw[is.na(train_data_raw)] <- 0
write.csv(train_data_raw, file = paste(data_output_path, "/train_raw.csv", sep=""), row.names = FALSE)



### Kmeans clustering on subsets of features
train_data_dura[is.na(train_data_dura)] <- 0
train_data_pace[is.na(train_data_pace)] <- 0
train_data_sect[is.na(train_data_sect)] <- 0
train_data_loud[is.na(train_data_loud)] <- 0
train_data_pitches[is.na(train_data_pitches)] <- 0
train_data_timbre[is.na(train_data_timbre)] <- 0

set.seed(0)
k_num <- 10
dura_clus <- kcca(train_data_dura, k=k_num, kccaFamily("kmeans"))
pace_clus <- kcca(train_data_pace, k=k_num, kccaFamily("kmeans"))
sect_clus <- kcca(train_data_sect, k=k_num, kccaFamily("kmeans"))
loud_clus <- kcca(train_data_loud, k=k_num, kccaFamily("kmeans"))
pitches_clus <- kcca(train_data_pitches, k=k_num, kccaFamily("kmeans"))
timbre_clus <- kcca(train_data_timbre, k=k_num, kccaFamily("kmeans"))

train_data_clus <- cbind(train_data_id, predict(dura_clus), predict(pace_clus),
                         predict(sect_clus),
                         predict(loud_clus), predict(pitches_clus), predict(timbre_clus))
write.csv(train_data_clus, file = paste(data_output_path, "/train.csv", sep=""), row.names = FALSE)



### convert test data ###
setwd(test_data_path)
file_names <- list.files(recursive = T)
file_num <- length(file_names)
test_data_id <- data.frame(matrix(ncol = 1, nrow = 0))
test_data_clus <- data.frame(matrix(ncol = 6, nrow = 0))
n <- 1
for(i in 1:file_num){
  data <- h5read(file_names[i], "analysis")
  H5close()
  song_id <- substring(file_names[i], nchar(file_names[i])-20, nchar(file_names[i])-3)
  duration <- max(data$segments_start)
  bars_int <- mean(diff(data$bars_start))
  beats_int <- mean(diff(data$beats_start))
  sections_num <- length(data$sections_start)
  sections_avg_prop <- mean(diff(data$sections_start)/duration)
  sections_max_prop <- max(diff(data$sections_start)/duration)
  sections_min_prop <- min(diff(data$sections_start)/duration)
  sections_var_prop <- var(diff(data$sections_start)/duration)
  segments_int <- mean(diff(data$segments_start))
  max_loudness_avg <- mean(data$segments_loudness_max)
  max_loudness_max <- max(data$segments_loudness_max)
  max_loudness_min <- min(data$segments_loudness_max)
  max_loudness_var <- var(data$segments_loudness_max)
  pitches <- matrix(nrow = 12, ncol = 4)
  for(j in 1:12){
    pitches[j,1] <- mean(data$segments_pitches[j,])
    pitches[j,2] <- max(data$segments_pitches[j,])
    pitches[j,3] <- min(data$segments_pitches[j,])
    pitches[j,4] <- var(data$segments_pitches[j,])
  }
  pitches <- as.vector(t(pitches))
  timbre <- matrix(nrow = 12, ncol = 4)
  for(j in 1:12){
    timbre[j,1] <- mean(data$segments_timbre[j,])
    timbre[j,2] <- max(data$segments_timbre[j,])
    timbre[j,3] <- min(data$segments_timbre[j,])
    timbre[j,4] <- var(data$segments_timbre[j,])
  }
  timbre <- as.vector(t(timbre))
  tatums_int <- mean(diff(data$tatums_start))
  
  test_data_id[n,] <- song_id
  test_data_dura <- duration
  test_data_pace <- c(bars_int, beats_int, segments_int,  tatums_int)
  test_data_sect <- c(sections_num, sections_avg_prop,
                           sections_max_prop, sections_min_prop, sections_var_prop)
  test_data_loud <- c(max_loudness_avg, max_loudness_max, max_loudness_min,
                           max_loudness_var)
  test_data_pitches <- pitches
  test_data_timbre <- timbre
  test_data_clus[n,] <- c(predict(dura_clus, matrix(test_data_dura, 1, 1)),
                          predict(pace_clus, matrix(test_data_pace, 1, 4)), 
                          predict(sect_clus, matrix(test_data_sect, 1, 5)), 
                          predict(loud_clus, matrix(test_data_loud, 1, 4)), 
                          predict(pitches_clus, matrix(test_data_pace, 1, 48)), 
                          predict(timbre_clus, matrix(test_data_timbre, 1, 48)))
  n <- n+1
} 

test_data <- cbind(test_data_id, test_data_clus)
colnames(test_data) <- colnames(train_data_clus)
write.csv(test_data, file = paste(data_output_path, "/test.csv", sep=""), row.names = FALSE)
