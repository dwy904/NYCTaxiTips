## Procedure III - Data Partitioning (Training and Test Dataset)

# Create a training index
Index_Train = createDataPartition(y = Green_Taxi_Model$Tip_Pct, p = 0.8, list = F)
# Create a training set
Train_Green_Taxi = Green_Taxi_Model[Index_Train,]
# Create a testset
Test_Green_Taxi = Green_Taxi_Model[-Index_Train,]


## Procedure IV - Feature Selection

# Using LASSO, a variable selection method
# Set tuning pararmeters value 
Grid=10^seq(10,-2,length=100)
# Create a model matrix
Model_Matrix = model.matrix(Tip_Pct ~ ., data = Train_Green_Taxi[,-30])[,-1]
# Create a LASSO linear model for feature selection
CV = cv.glmnet(Model_Matrix, Train_Green_Taxi$Tip_Pct, alpha = 1)
# Ouput the feature that selected by the LASSO model
Out_Result = glmnet(Model_Matrix, Train_Green_Taxi$Tip_Pct, alpha = 1, lambda = Grid)
Model_Estimate = predict(Out_Result, type="coefficients", s = CV$lambda.min)
Model_Estimate = as.data.frame(as.matrix(Model_Estimate))
colnames(Model_Estimate)[1] = 'Coefficient'
Model_Estimate = subset(Model_Estimate, Coefficient != 0)
print(Model_Estimate)
# only one variable was selected by the LASSO model. (Pickup_latitude)

# Create a linear model to explore fitness of the dataset
Linear_Model = lm( data = Train_Green_Taxi[,-30], Tip_Pct ~.)
summary(Linear_Model)$r.squared

# The R-Square is only about 4.7% which means the model does not fit the data well.
# Other modeling procedure should be considered such as classification.
# It's possible that the linear model is not an appropriate method in this case.
# The next step is to use random forest model to classify the tip amount group.