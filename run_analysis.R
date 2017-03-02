##Step 1
#set working directory
setwd("C:/Users/Philippine/Desktop/coursera/Clean_Data")
if(!file.exists("data")) {dir.create ("data")}
## From Readme file
##train/X_train.txt': Training set.
##- 'train/y_train.txt': Training labels.
##- 'test/X_test.txt': Test set.
##- 'test/y_test.txt': Test labels.
Training_set <- read.table("./data/X_train.txt")
Training_labels <- read.table("./data/Y_train.txt")
Test_set <- read.table("./data/X_test.txt")
Test_labels <- read.table("./data/Y_test.txt")
Subject_train <- read.table("./data/subject_train.txt")
Subject_test <- read.table("./data/subject_test.txt")
Activity_labels <- read.table("./data/activity_labels.txt")
Features <- read.table("./data/features.txt")


###ATTACH SUBJECT ID
## Change the column name of Subject_test Column1(V1) to ID,
colnames(Subject_test)[1] <- "ID"
## Change the column name of Subject_train Column1(V1) to ID
## train/subject_train.txt': ##
##Each row identifies the subject who performed the activity
##for each window sample. Its range is from 1 to 30.
colnames(Subject_train) [1] <- "ID"
## Column bind the Subject_test dataset to the Test_set
Test_set <- cbind(Subject_test, Test_set)
## Column bind the Subject_train dataset to the Training_set
Training_set <- cbind(Subject_train, Training_set)


###ATTACH ACTIVITY LABELS
## Change the column name of Training_labels Column1(V1) to Activity
colnames(Training_labels) [1] <- "Activity"
## Change the column name of Test_labels Column1(V1) to Activity
colnames(Test_labels) [1] <- "Activity"
## Column bind the Test_labels dataset to the Test_set
Test_set <- cbind(Test_labels, Test_set)
## Column bind the Training_labels dataset to the Training_set
Training_set <- cbind(Training_labels, Training_set)

### create new variable to identify whether the observation belongs to the test
### or the training group
Test_set$Group <- "test"
Training_set$Group <-"training"
library(dplyr)
### move the new variable "Group" to the front of the dataset
Test_set<-select(Test_set, Group, everything())
Training_set<-select(Training_set, Group, everything())

### merge training and test sets to create one data set
merged_set<- rbind(Test_set, Training_set)

###DESCRIPTIVE ACTIVITY NAMES
merged_set$Activity<-as.character(merged_set$Activity)
merged_set$Activity[merged_set$Activity=="1"] <-"WALKING"
merged_set$Activity[merged_set$Activity=="2"] <-"WALKING_UPSTAIRS"
merged_set$Activity[merged_set$Activity=="3"] <-"WALKING_DOWNSTAIRS"
merged_set$Activity[merged_set$Activity=="4"] <-"SITTING"
merged_set$Activity[merged_set$Activity=="5"] <-"STANDING"
merged_set$Activity[merged_set$Activity=="6"] <-"LAYING"



###Features <- read.table("./data/features.txt")
library(dplyr)
library(tidyr)
Features <- spread(Features, V1, V2)
## rename the colnames of the spread Features dataset to include the "V" prefix
colnames(Features) <- paste0("V",1:561)
###create columns titles Group, Activity and ID and position them in columns 1:3
Features$Group <- "Group"
Features$Activity <- "Activity"
Features$ID <- "ID"
Features<-select(Features, ID, everything())
Features<-select(Features, Activity, everything())
Features<-select(Features, Group, everything())

### bind the Features data to the merged_set
DF1<- rbind(merged_set, Features)
## assign the names of the last row as columnnames
colnames(DF1) = DF1[10300,]
DF1 <- DF1[-10300,]

###remove duplicates
DF1 <- unique(DF1[,1:564])
###Subset DF1 to keep only measures of mean and std as well as the identifier columns
DF1 <- select(DF1, contains("mean"), contains("std"), contains("Group"), contains("Activity"), contains("ID"))
DF1 <- select(DF1, ID, everything())
DF1 <- select(DF1, Activity, everything())
DF1 <- select(DF1, Group, everything())


#### Descriptive variable names
##By examining DF1, we can say that the following acronyms can be replaced:
##Acc can be replaced with Accelerometer
##Gyro can be replaced with Gyroscope
##BodyBody can be replaced with Body
##Mag can be replaced with Magnitude
##Character f can be replaced with Frequency
##Character t can be replaced with Time


names(DF1)<-gsub("Acc", "Accelerometer", names(DF1))
names(DF1)<-gsub("Gyro", "Gyroscope", names(DF1))
names(DF1)<-gsub("BodyBody", "Body", names(DF1))
names(DF1)<-gsub("Mag", "Magnitude", names(DF1))
names(DF1)<-gsub("^t", "Time", names(DF1))
names(DF1)<-gsub("^f", "Frequency", names(DF1))
names(DF1)<-gsub("tBody", "TimeBody", names(DF1))
names(DF1)<-gsub("-mean()", "Mean", names(DF1), ignore.case = TRUE)
names(DF1)<-gsub("-std()", "STD", names(DF1), ignore.case = TRUE)
names(DF1)<-gsub("-freq()", "Frequency", names(DF1), ignore.case = TRUE)
names(DF1)<-gsub("angle", "Angle", names(DF1))
names(DF1)<-gsub("gravity", "Gravity", names(DF1))


###Create a second, independent tidy data set with the average of each
###variable for each activity and each subject
#### change variables in columns 3:89 to numeric
DF1[,c(3:89)]<- sapply(DF1[,c(3:89)], as.numeric)
tidy.data <- aggregate(DF1[,4:ncol(DF1)], by=list(ID=DF1$ID, label=DF1$Activity), mean)
