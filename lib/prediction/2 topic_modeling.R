library(rhdf5)
library(topicmodels)
library(NLP)
library(tm)
load("/Users/YaqingXie/Desktop/3-Applied Data Science/Fall2016-proj4-yaqing-xie/data/Project4_data/lyr.RData")
del<-c(2,3,6:30)
lyr_n<-lyr[,-del]
setwd("/Users/YaqingXie/Desktop/3-Applied Data Science/Fall2016-proj4-yaqing-xie/data/Project4_data/data")

# Manually adjusted probabilities for all terms
word_prob <- function(lyr, label) {
  new_lyr <- lyr[-237,]
  df <- cbind(label, new_lyr)
  result <- data.frame(matrix(seq(20), nrow = max(as.numeric(label)), ncol = 5000))
  for (lb in 1:max(as.numeric(label))) {
    holder <- subset(df, df[,1] == lb)
    holder <- colSums(holder[,3:5002])
    tot <- sum(holder)
    prop <- holder / tot
    result[lb,] <- prop
  }
  result <- t(result)
  result <- cbind(colnames(new_lyr)[2:5001], result)
  result[c(2,3,6:30),2:21] <- rep(0,20)
  
  return(result)
}

# Convert tokenized terms to single string
string_convert <- function(lyr) {
  result <- data.frame()
  for (row in 1:(nrow(lyr))) {
    words <- NULL
    for (col in 2:(ncol(lyr)-1)) {
      if (lyr[row,col] != 0) {
        kw <- rep(colnames(lyr)[col],lyr[row,col])
        kw <- paste(kw, collapse=' ')
        words <- paste(words, kw)
      }
    }
    result[row,1] <- words
  }
  return(result)
}

lyrics<-string_convert(lyr_n)
Vlyrics<-c()
for (i in 1:2350){
  Vlyrics<-c(Vlyrics,lyrics[[1]][i])
}
Vlyrics<-Vlyrics[-237]
Vlyrics<-VCorpus(VectorSource(Vlyrics))
Vlyrics<-tm_map(Vlyrics,stripWhitespace)
Vlyrics<-tm_map(Vlyrics,removeWords,stopwords("english"))
#Vlyrics<-tm_map(Vlyrics,stemDocument)
dtm<-DocumentTermMatrix(Vlyrics)

#topic modeling, get 10 topics
k1<-10
control_LDA_VEM<-list(estimate.alpha=TRUE, alpha=50/k,estimate.beta=TRUE,verbose=0,prefix=tempfile(),save=0,keep=0,seed=as.integer(Sys.time()),nstart=1,best=TRUE,var=list(iter.max=500,tol=10^-6),em=list(iter.max=1000,tol=10^-4),initialize="random")
result_k10<-LDA(dtm,k=k1,method="VEM",control=list(seed=2010))
label_k10<-topics(result,1)
write.csv(label_k10,file = "train_topic_k10.csv")
# calculate proportion of words
topic_word_prob_10<-word_prob(lyr,label_k10,num_words = 5000)
write.csv(topic_word_prob_10, file = "topic_word_prob_10.csv")



# topic modeling, get 5 topics
k2<-5
control_LDA_VEM<-list(estimate.alpha=TRUE, alpha=50/k,estimate.beta=TRUE,verbose=0,prefix=tempfile(),save=0,keep=0,seed=as.integer(Sys.time()),nstart=1,best=TRUE,var=list(iter.max=500,tol=10^-6),em=list(iter.max=1000,tol=10^-4),initialize="random")
result<-LDA(dtm,k=k2,method="VEM",control=list(seed=2010))
label_k5<-topics(result,1)
write.csv(label_k5,file = "train_topic_k5.csv")
# calculate proportion of words
topic_word_prob_5<-word_prob(lyr,label_k5,num_words = 5000)
write.csv(topic_word_prob_5, file = "topic_word_prob_5.csv")



# topic modeling, get 20 topics
k3<-20
control_LDA_VEM<-list(estimate.alpha=TRUE, alpha=50/k,estimate.beta=TRUE,verbose=0,prefix=tempfile(),save=0,keep=0,seed=as.integer(Sys.time()),nstart=1,best=TRUE,var=list(iter.max=500,tol=10^-6),em=list(iter.max=1000,tol=10^-4),initialize="random")
result<-LDA(dtm,k=k3,method="VEM",control=list(seed=2010))
label_k20<-topics(result,1)
write.csv(label_k20,file = "train_topic_k20.csv")
# calculate proportion of words
topic_word_prob_20<-word_prob(lyr,label_k20,num_words = 5000)
write.csv(topic_word_prob_20, file = "topic_word_prob_20.csv")