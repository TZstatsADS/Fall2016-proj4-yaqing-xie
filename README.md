# Project: Words 4 Music

### [Project Description](doc/project4_desc.md)

![image](http://cdn.newsapi.com.au/image/v1/f7131c018870330120dbe4b73bb7695c?width=650)

Term: Fall 2016

+ [Data link](https://courseworks2.columbia.edu/courses/11849/files/folder/Project_Files?preview=763391)-(**coursework login required**)
+ [Data description](doc/readme.html)
+ Contributor's name: Yaqing Xie
+ Collaboration and discussion: Yueqi Zhang, Tian Sheng, Qing Yin, Sen Zhuang
+ Projec title: Words 4 Music
+ Project summary: The objective of this project is to recommend candidate lyrics to songs given their music features. Two different methodologies are applied in this project.
+ Methodology 1:
	* Extract all raw features of training songs from h5 files. 
	* Considering different songs have different dimensions of features, calculate each feature's median dimension first, and then either truncate of append the feature so the dimension can be consistent between different songs.
	* Use topic modeling to assign training songs to different topics.
	* Use KNN or RF to predict a new test song's topic based on its features.
	* After a test song is given a topic, recommend the lyrics that are the most common among training songs under this specific topic.
+ Methodology 2:
	* For each training song, calculate music features such as beat interval, bar interval, mean max loudness, number of sections etc.
	* Transfer the obtained features into factor data type.
	* Use topic modeling to assign training songs to different topics.
	* Use association rule to understand how features associate with topics.
	* When given a new test song, apply association rule to predict its topic.
	* Recommend the lyrics that are the most common among training songs under this specific topic.
	
	
Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── lib/
├── data/
├── doc/
├── figs/
└── output/
```

Please see each subfolder for a README file.
