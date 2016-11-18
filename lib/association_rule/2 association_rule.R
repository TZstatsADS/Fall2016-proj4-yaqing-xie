library(arules)

setwd("/Users/YaqingXie/Desktop/3-Applied Data Science/Fall2016-proj4-yaqing-xie/data/association_rule/")
topic_20<-read.csv("train_topic_k20.csv")

# songs that have at least one empty feature
ab_songs<-c(714,949,990,1111,1324,1374,1657,1704,2283)
topic_20<-topic_20[-ab_songs,]

features<-read.csv("train.csv")
features<-features[-237,]

# convert data type to factor
data_conb<-cbind(features[,2:7],topic_20[,2])
colnames(data_conb)[7]<-"Topic"
data_conb[,1]<-as.factor(data_conb[,1])
data_conb[,2]<-as.factor(data_conb[,2])
data_conb[,3]<-as.factor(data_conb[,3])
data_conb[,4]<-as.factor(data_conb[,4])
data_conb[,5]<-as.factor(data_conb[,5])
data_conb[,6]<-as.factor(data_conb[,6])
data_conb[,7]<-as.factor(data_conb[,7])
data<-as(data_conb,"transactions")

# get rules
rules<-apriori(data,parameter = list(support=0.01,confidence=0.1))
rules_topic1<-subset(rules,subset=rhs %in% "Topic=1")
rules_topic2<-subset(rules,subset=rhs %in% "Topic=2")
rules_topic3<-subset(rules,subset=rhs %in% "Topic=3")
rules_topic4<-subset(rules,subset=rhs %in% "Topic=4")
rules_topic5<-subset(rules,subset=rhs %in% "Topic=5")

inspect(head(rules_topic1,n=3,by="confidence"))
inspect(head(rules_topic2,n=3,by="confidence"))
