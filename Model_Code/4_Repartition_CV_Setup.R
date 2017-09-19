## Data Re-Partition

# Generate a balanced dataset (the portion among different classes are equal) function
# to subset data for classificaton and
createSets <- function(x, y, p){
  nr <- NROW(x)
  size <- (nr * p) %/% length(unique(y))
  idx <- lapply(split(seq_len(nr), y), function(.x) sample(.x, size))
  unlist(idx)}

# Create the Balanced Index for different binning options
# (please run the binning option code before creating the index).

#Index_Class_Option_1 = createSets(x = Green_Taxi_Model[,-c(18,30)], 
#                         p = 0.25, y = Green_Taxi_Model$Tip_Group)

Index_Class_Option_2 = createSets(x = Green_Taxi_Model[,-c(18,30)], 
                         p = 0.25, y = Green_Taxi_Model$Tip_Group)

#Index_Class_Option_3 = createSets(x = Green_Taxi_Model[,-c(18,30)], 
#                         p = 0.25, y = Green_Taxi_Model$Tip_Group)

# Create balanced classification dataset and remove variable, 'tip amount'
Green_Taxi_Class = Green_Taxi_Model[Index_Class_Option_2, -18]


# Create a training dataset (80% of the balanced dataset) and a test dataset (20% remaining)
Index_Train_Class = createDataPartition(y = Green_Taxi_Class$Tip_Group, p = 0.8, list = F)

Train_Green_Taxi_Class = Green_Taxi_Class[Index_Train_Class,]
Test_Green_Taxi_Class = Green_Taxi_Class[-Index_Train_Class,]

#Test_Green_Taxi_Class = Green_Taxi_Class[-Index_Class_Option_2,]

# Cross Validation Partitioning (Create 5 folds and 5 validation datasets)
Fold = createFolds(y = Train_Green_Taxi_Class$Tip_Group, k = 5, 
                   list = TRUE, returnTrain = FALSE)

Fold_1 = Train_Green_Taxi_Class[-Fold[[1]],]; Fold_2 = Train_Green_Taxi_Class[-Fold[[2]],]
Fold_3 = Train_Green_Taxi_Class[-Fold[[3]],]; Fold_4 = Train_Green_Taxi_Class[-Fold[[4]],]
Fold_5 = Train_Green_Taxi_Class[-Fold[[5]],]; Vali_1 = Train_Green_Taxi_Class[Fold[[1]],] 
Vali_2 = Train_Green_Taxi_Class[Fold[[2]],]; Vali_3 = Train_Green_Taxi_Class[Fold[[3]],]
Vali_4 = Train_Green_Taxi_Class[Fold[[4]],]; Vali_5 = Train_Green_Taxi_Class[Fold[[5]],]

