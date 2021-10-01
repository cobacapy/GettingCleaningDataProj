###Download the file from provided URL, unzip

Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists("./data")){dir.create("./data")}
download.file(Url,destfile="./data/Dataset.zip",method="curl")
unzip(zipfile="./data/Dataset.zip",exdir="./data")

###establish file path for easy access

path <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path, recursive=TRUE)

##load dplyr
library(dplyr)

##for final dataset, we need feature, activity, and subject data.

FeaturesTest  <- read.table(file.path(path, "test" , "X_test.txt" ),header = FALSE)
FeaturesTrain <- read.table(file.path(path, "train", "X_train.txt"),header = FALSE)
ActivityTest  <- read.table(file.path(path, "test" , "Y_test.txt" ),header = FALSE)
ActivityTrain <- read.table(file.path(path, "train", "Y_train.txt"),header = FALSE)
SubjectTrain <- read.table(file.path(path, "train", "subject_train.txt"),header = FALSE)
SubjectTest  <- read.table(file.path(path, "test" , "subject_test.txt"),header = FALSE)

###observe data using str([dataname])
### i.e. str(FeaturesTest), str(ActivityTest)

###compile data by Features, Activity, and Subject
Features <- rbind(FeaturesTrain, FeaturesTest)
Activity <- rbind(ActivityTrain, ActivityTest)
Subject <- rbind(SubjectTrain, SubjectTest)

### add names to the variables
names(Subject) <- c("Subject")
names(Activity) <- c("Activity")
FeaturesNames <- read.table(file.path(path, "features.txt"), head = FALSE)
names(Features) <- FeaturesNames$V2
ActivityNames <- read.table(file.path(path, "activity_labels.txt"), col.names = c("Code", "Activity"))

###combine data to get one dataset
Combine <- cbind(Subject, Activity)
Data <- cbind(Features, Combine)

##Subset "Data" with only units that have "mean" and "std" in the name
DataSub <- Data %>% select(Subject, Activity, contains("mean"), contains("std"))

##view DataSub using str(DataSub), if needed

##name the datasets
names(DataSub)[2] = "Activity"
names(DataSub)<-gsub("Acc", "Accelerometer", names(DataSub))
names(DataSub)<-gsub("Gyro", "Gyroscope", names(DataSub))
names(DataSub)<-gsub("BodyBody", "Body", names(DataSub))
names(DataSub)<-gsub("Mag", "Magnitude", names(DataSub))
names(DataSub)<-gsub("^t", "Time", names(DataSub))
names(DataSub)<-gsub("^f", "Frequency", names(DataSub))
names(DataSub)<-gsub("tBody", "TimeBody", names(DataSub))
names(DataSub)<-gsub("-mean()", "Mean", names(DataSub), ignore.case = TRUE)
names(DataSub)<-gsub("-std()", "STD", names(DataSub), ignore.case = TRUE)
names(DataSub)<-gsub("-freq()", "Frequency", names(DataSub), ignore.case = TRUE)
names(DataSub)<-gsub("angle", "Angle", names(DataSub))
names(DataSub)<-gsub("gravity", "Gravity", names(DataSub))


##create final dataset with the means for each variable and subject
FinalData <- DataSub %>%
        group_by(Subject, Activity) %>%
        summarize_all(list(mean = mean))
##add names to final dataset activities
FinalData$Activity <- ActivityNames[FinalData$Activity, 2]
##write table
write.table(FinalData, "FinalData.txt", row.name = FALSE)
