# read the label and test features
setwd("/Users/YaqingXie/Desktop/3-Applied Data Science/Fall2016-proj4-yaqing-xie/data/prediction")
topic_word_prob<-read.csv("topic_word_prob_20.csv")
test_topic<-read.csv("test_topic_pred_RF.csv")

topic_word_prob <- topic_word_prob[,-1]
topic_word_prob <- topic_word_prob[,-1]

topic_word_prob <- t(matrix(as.numeric(unlist(topic_word_prob)), 
                        nrow=nrow(topic_word_prob[,-1])))
test_topic <- as.matrix(test_topic[,1:20])

result<- test_topic %*% topic_word_prob

# give rank
for (i in 1:nrow(result)){
  result[i,]=rank(-result[i,], ties.method = 'first')
}
result[,c(2,3,6:30)] <- rep(4987, nrow(result))

# output
setwd("/Users/YaqingXie/Desktop/3-Applied Data Science/Fall2016-proj4-yaqing-xie/output")
write.table(result, "final_vocabulary.csv", col.names = FALSE, sep=",")
