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


## Procedure V - Random Forest Classification & Parameter Tuning

# Setup spark environment
config <- spark_config()
config$spark.executor.cores <- 3
config$spark.executor.memory <- "8G"
sc <- spark_connect(master = "local", config = config)

# Transfer data to Spark cluster in order to improve the machine leanring efficiency
# Transfer Training & Test Set
# (run this code again every time the bining option is changed)
Train_Data =  copy_to(sc, Train_Green_Taxi_Class)
Test_Data = copy_to(sc, Test_Green_Taxi_Class) 

# Initialize the model (finding the best bining opiton for classificaton)
# Build the random forest classification model
# (run this code again every time the bining option is changed)
Random_Forest = Train_Data %>%
  ml_random_forest(response = "Tip_Group", 
                   features = colnames(Train_Data)[-29], type = 'classification',
                   max.bins = 6)

Validate = data.frame(Prediction = predict(Random_Forest, newdata = Test_Data),
                      select(Test_Data, Tip_Group))
Con_Matrix = confusionMatrix(Validate$Prediction, Validate$Tip_Group)

# Output the accuracy rate to the output table
mean(as.numeric(Con_Matrix$byClass[,11]))

# After runing the model separately with 3 bining options, the bining option 2 is 
# selected for in depth investigation (cross validation and parameter tuning)


# Cross Validation on Randomforest classification model

# Transfer folds and validation datasets into Spark
Fold1 = copy_to(sc, Fold_1); Fold2 = copy_to(sc, Fold_2)
Fold3 = copy_to(sc, Fold_3); Fold4 = copy_to(sc, Fold_4)
Fold5 = copy_to(sc, Fold_5); Vali1 = copy_to(sc, Vali_1)
Vali2 = copy_to(sc, Vali_2); Vali3 = copy_to(sc, Vali_3)
Vali4 = copy_to(sc, Vali_4); Vali5 = copy_to(sc, Vali_5)

# Create a dataframe to store the cross validation accuracy value.
Cross_Validation = data.frame(CV = c('CV1', 'CV2', 'CV3', 'CV4', 'CV5'), Balanced_Accuracy = 0)

# Round 1
Random_Forest_1 = Fold1 %>%
  ml_random_forest(response = "Tip_Group", features = colnames(Train_Data)[-29], 
                   type = 'classification', max.bins = 6)
Validate_1 = data.frame(Prediction = predict(Random_Forest_1, newdata = Vali1),
                        select(Vali1, Tip_Group))
Cross_Validation[1,2] = 
  mean(as.numeric(confusionMatrix(Validate_1$Prediction, Validate_1$Tip_Group)$byClass[,11]))

# Round 2
Random_Forest_2 = Fold2 %>%
  ml_random_forest(response = "Tip_Group", features = colnames(Train_Data)[-29], 
                   type = 'classification', max.bins = 6)
Validate_2 = data.frame(Prediction = predict(Random_Forest_2, newdata = Vali2),
                        select(Vali2, Tip_Group))
Cross_Validation[2,2] = 
  mean(as.numeric(confusionMatrix(Validate_2$Prediction, Validate_2$Tip_Group)$byClass[,11]))

# Round 3
Random_Forest_3 = Fold3 %>%
  ml_random_forest(response = "Tip_Group", features = colnames(Train_Data)[-29], 
                   type = 'classification', max.bins = 6)
Validate_3 = data.frame(Prediction = predict(Random_Forest_3, newdata = Vali3),
                        select(Vali3, Tip_Group))
Cross_Validation[3,2] = 
  mean(as.numeric(confusionMatrix(Validate_3$Prediction, Validate_3$Tip_Group)$byClass[,11]))

# Round 4
Random_Forest_4 = Fold4 %>%
  ml_random_forest(response = "Tip_Group", features = colnames(Train_Data)[-29], 
                   type = 'classification', max.bins = 6)
Validate_4 = data.frame(Prediction = predict(Random_Forest_4, newdata = Vali4),
                        select(Vali4, Tip_Group))
Cross_Validation[4,2] = 
  mean(as.numeric(confusionMatrix(Validate_4$Prediction, Validate_4$Tip_Group)$byClass[,11]))

# Round 5
Random_Forest_5 = Fold5 %>%
  ml_random_forest(response = "Tip_Group", features = colnames(Train_Data)[-29], 
                   type = 'classification', max.bins = 6)
Validate_5 = data.frame(Prediction = predict(Random_Forest_5, newdata = Vali5),
                        select(Vali5, Tip_Group))
Cross_Validation[5,2] = 
  mean(as.numeric(confusionMatrix(Validate_5$Prediction, Validate_5$Tip_Group)$byClass[,11]))

# Output cross validaton result
Cross_Validation


# Tuning parameter
# Setup parameter vector for tuning process

Tree_Number = c(10, 50, 100, 200, 400, 800)
Tuning_Output = data.frame(Tree_Number = Tree_Number, Balanced_Accuracy = 0)

Total  <- length(Tree_Number)
Progress_Bar <- txtProgressBar(min = 0, max = Total, style = 3)

for(i in 1:length(Tree_Number)){
  # Build the random forest classification model
  Random_Forest = Train_Data %>%
    ml_random_forest(response = "Tip_Group", 
                     features = colnames(Train_Data)[-29], type = 'classification',
                     max.bins = 6, num.trees = Tree_Number[i])
  
  # Contruct a confusion matrix and calculate balanced accuracy rate 
  # Use development dataset to validate the model performance
  Validate = data.frame(Prediction = predict(Random_Forest, newdata = Test_Data),
                        select(Test_Data, Tip_Group))
  Con_Matrix = confusionMatrix(Validate$Prediction, Validate$Tip_Group)
  # Store the accuracy to the output table
  Tuning_Output[i,2] = mean(as.numeric(Con_Matrix$byClass[,11]))
  
  setTxtProgressBar(Progress_Bar, i)
}

# Output the tuning result
Tuning_Output




