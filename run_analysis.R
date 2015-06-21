# The following script is an answer on the Course Project for Getting and Cleaning data  course
# This script is not intenteded to run "as-is". In order to run it, "data" folder should be created 
# OR paths to data files below should be modified to local ones.

# Step 0. Do some preparations.
library(dplyr)
# set working directory
setwd("C:/Users/Vadzim_Dabravolski/Documents/cd_course_project")

########################
# Step 1. Merges the training and the test sets to create one data set.
########################
#read train and test data
train_d <- read.table("./data/UCI HAR Dataset/train/X_train.txt", header=FALSE)
test_d <- read.table("./data/UCI HAR Dataset/test/X_test.txt", header=FALSE)

#read test and train subjects
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt", header=FALSE)
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt", header=FALSE)

#read train and test activities 
act_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt", header=FALSE)
act_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt", header=FALSE)

#merge train and test data sets
data <- rbind(train_d, test_d)
#create the columns with the descriptive names.
columns_raw <- read.table("./data/UCI HAR Dataset/features.txt",header=FALSE)
# cast to character and extract only column names
columns <- as.character(columns_raw$V2)
#apply column names to merged data set
colnames(data) <- columns

# fix issues with incorrect character int the data set. see http://stackoverflow.com/questions/28549045/dplyr-select-error-found-duplicated-column-name
col_fixed <- make.names(names=names(data), unique=TRUE, allow_ = TRUE)
names(data) <- col_fixed

# merge subject and activity data
subject <- rbind(subject_train,subject_test)
colnames(subject) <- "subject"
activity <- rbind(act_train,act_test)
colnames(activity) <- "activity"

# adding new columns with activity and subject to data set
data_exp <- cbind(data, activity, subject)

########################
# Step 2. Extracts only the measurements on the mean and standard deviation for each measurement.
########################
# extract columns with activity, subject, mean and std measurements
data_cl <- select(data_exp, activity, subject, contains("mean"), contains("std"))

########################
# Step 3. Uses descriptive activity names to name the activities in the data set.
########################
# replace activity code with activity name
data_cl$activity <- as.character(data_cl$activity)
data_cl$activity[data_cl$activity == "1"] <- "WALKING"
data_cl$activity[data_cl$activity == "2"] <- "WALKING_UPSTAIRS"
data_cl$activity[data_cl$activity == "3"] <- "WALKING_DOWNSTAIRS"
data_cl$activity[data_cl$activity == "4"] <- "SITTING"
data_cl$activity[data_cl$activity == "5"] <- "STANDING"
data_cl$activity[data_cl$activity == "6"] <- "LAYING"

########################
#Step 4. Appropriately labels the data set with descriptive variable names. 
########################
# Nothing to do here. All columns have descriptive and unique names -  see data_dictionary.txt for details.


########################
#Step 5. creates a second, independent tidy data set with the average of each variable for each activity and each subject
########################
# first grouping by two columns
grouped <- group_by(data_cl,activity,subject)
# gettign the average for each columns with measurements. grouped by activity and subject
data_avrg <- summarise_each(grouped,funs(mean))

# EXTRA. test that everything works OK
# let's pick all average values for LAYING activity for 30th subject suing DPLYR filter():
# filter(data_avrg,activity=="LAYING" & subject=="30")
# Code above returns  a local data frame [1 x 88]. Values are the same as if we calculate it manually.


