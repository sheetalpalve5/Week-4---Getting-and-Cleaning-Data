# Getting and Cleaning Data - Week 4

# Downloading and Unzipping the data files
packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")

activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt") , col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt"), col.names = c("index", "featureNames"))
featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresWanted, featureNames]
measurements <- gsub('[()]', '', measurements)

# Creating training datasets
training_dataset <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(training_dataset, colnames(training_dataset), measurements)
trainActivities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt"), col.names = c("Activity"))
trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt"), col.names = c("SubjectNum"))
training_dataset <- cbind(trainSubjects, trainActivities, training_dataset)

# Creating test datasets
test_dataset <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(test_dataset, colnames(test_dataset), measurements)
testActivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt"), col.names = c("Activity"))
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt"), col.names = c("SubjectNum"))
test_dataset <- cbind(testSubjects, testActivities, test_dataset)

# Merges the training and the test sets to create one data set
combined <- rbind(training_dataset, test_dataset)
combined[["Activity"]] <- factor(combined[, Activity], levels = activityLabels[["classLabels"]], labels = activityLabels[["activityName"]])

combined[["SubjectNum"]] <- as.factor(combined[, SubjectNum])
combined <- reshape2::melt(data = combined, id = c("SubjectNum", "Activity"))
combined <- reshape2::dcast(data = combined, SubjectNum + Activity ~ variable, fun.aggregate = mean)

# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject
data.table::fwrite(x = combined, file = "tidyData.txt", quote = FALSE)