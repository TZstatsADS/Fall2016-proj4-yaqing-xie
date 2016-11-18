############################################################
############################################################
######                 classification                 ######
############################################################
# suppose we have our "feature matrix" with dimension 2350 * features
# and we have our "clusters", which is obtained based on topic clustering
# then we have a label (cluster) for each data point (music)
# random forest
# now we will use random forest to do multiple classification
# final: RF
setwd("/Users/YaqingXie/Desktop/3-Applied Data Science/Fall2016-proj4-yaqing-xie/data/prediction")

music_feature_train<-read.csv("train.csv")
music_label_train<-read.csv("train_topic_k20.csv")

music_feature_test <- read.csv("test.csv")

music_feature_train<-music_feature_train[-237,]
music_feature_train<-music_feature_train[,-c(1,2)]
music_label_train<-music_label_train[-c(714,949,990,1111,1324,1374,1657,1704,2283),]
music_label_train<-factor(music_label_train[,2])

# Classification - RF
library(randomForest)
music_rf<-randomForest(music_feature_train,music_label_train,importance=T,proximity=T)
music_rf_pre<-predict(music_rf,music_feature_test,type="vote",norm.votes=T)
write.csv(music_rf_pre, "test_topic_pred_RF.csv")

# Classificaiton - KNN
library(caret)
music_knn<-knn3(music_feature_train,music_label_train,k=30)
# music_knn<-knn3(music_feature_train,music_label_train,k=20)
# music_knn<-knn3(music_feature_train,music_label_train,k=10)
music_knn_pre<-predict(music_knn,music_feature_test)
write.csv(music_knn_pre, "test_topic_pred_KNN.csv")