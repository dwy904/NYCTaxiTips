# NYC Taxi Tips Prediction
> <img src="http://www.nyc.gov/html/tlc/images/features/fi_about_photo_trip_records.png" width=550 height=250 align="right"/> <br />
> 
> **Weiye Deng** <br />
> Business Intelligence Engineer <br />
> <br />
> MS. Analytics - Data Science <br />
> Georgetown University <br />
> dwy904@gmail.com <br />
> <br />

## Introduction

This report aims to build a quantitative model to predict the percentage of tip to be paid by each customer after a taxi trip. The dataset, Sep 201x NYC Green Taxi, is publicly available on NYC Taxi & Limousine Commission’s official website. Data cleaning, feature engineering and data partitioning procedures were performed before the model is constructed. The least absolute shrinkage and selection operator (LASSO) and linear regression were applied during the modeling process. A random forest classification model is introduced to turn the prediction problem into a classification problem due to the poor fitness on the linear regression model. The original data need to be re-partitioned. Cross validation and accuracy testing processes on the random forest classification model are demonstrated.  Finally, further consideration and enhancement possibilities are proposed at the end of this report.

## Environment Setup

**1. Install R and RStudio:** <br />
If R and Rstudio are not installed, please install them before the code is run. Please refer to this [setup instruction]( 
	https://courses.edx.org/courses/UTAustinX/UT.7.01x/3T2014/56c5437b88fa43cf828bff5371c6a924/) or type the below command to terminal:
```
sudo apt-get install r-base
```

**2. Install Spark:** <br />
Open RStudio, type in the following code in the RStudio Console:
```r
install.packages("sparklyr")
library(sparklyr)
spark_install(version = "1.6.2")
```

**3. Install the required packages:** <br />
```r
install.packages('ggplot2')
install.packages('readr')
install.packages('rgeos')
install.packages('sp')
install.packages('rgdal')
install.packages('lubridate')
install.packages('utils')
install.packages('googleVis')
install.packages('chron')
install.packages('glmnet')
install.packages('sparklyr')
install.packages('dplyr')
install.packages('ggmap')
install.packages('reshape2')
install.packages('caret')
```

**4. Set the working directory to folder, Data_File, using command:** 
```r 
setwd()
```

## Data Cleaning

1. Remove all values which are less than 0 in variable, Fare Amount; <br />
2. Only select credit card transactions because only credit card tips can be captured in the system; <br />
3. Remove variable, Payment Type, because there are only credit card payments in the remaining data; <br />
4. Remove the negative observations that are in variable, Extra (rush hour and overnight charge); <br />
5. Remove the observations that are less than or equal to 0 in variable, Passenger Count; <br />
6. Remove the negative or 0 value observations in variable, Trip Distance; <br />
7. Check the longitude and latitude data and ensure the location are within NYC area; <br />
8. Convert variables into proper (categorical / factor format / date time) formats. <br />


## Feature Engineering
1. The administrative districts where the pick-up and drop-off activities (longitude and latitude) took place are identified by utilizing the NYC area shapefiles provided by Zillow. Replace the missing values as ‘Undefined’ area. <br />
2. Identify the pick-up and drop-off hours (0:00 - 23:00) from ‘Date Time’, and create both categorical and continuous variables to store these values; <br />
3. Create a categorical variable to bin ‘Passenger Count’ into 3 groups (1, 2-4, and >=5 passengers); <br />
4. Create a categorical variable to bin ‘Trip Distance’ into 3 groups (0-5, 5-10, and >= 10 miles); <br />
5. Create a categorical variable to identify the days of a week (Sunday - Saturday);
6. Create a categorical variable to identify weekends; <br />
7. Create a continuous variable to store the duration of a trip. This variable can be derived from variable, pick-up and drop-off Date Time; <br />
8. Remove variables, ‘Tip Amount’ and ‘Total Amount’, because these variables have already been used to derive the response variable, Tip Percentage.


## Feature Selection

There are 30 in total attributes within the dataset after the data are processed. Surprisingly, only one variable, Pickup Latitude, is selected by the LASSO method, which indicates that most of the variables are not significantly correlated with the response variable, Tip Percentage. In order to reexamine the goodness of fit of these model features, an ordinary least squares multiple linear regression model is built after the LASSO method. The r-square statistic from the linear regression model is 4.7%, which means this model does not fit the data well enough to make predictions. It also indicates that the features are not significant enough to fit the data. It is possible that there is a weak linear relationship between the response variable and the predictive variables. <br />

One other alternative is to turn the prediction problem into a classification problem. The goodness of features from this dataset is determined by investigating accuracy of the training and test dataset from the classification model. 

## Feature Re-Engineering 
In order to build a classification model, the original response variable, Tip Percentage, needs to be grouped into different bins as a categorical response variable. Several binning options are generated to train the classification model. The binning option that is associated with the reasonable accuracy rate is selected for further investigations (parameter tuning and cross validation). Choosing options one and two as shown above turns the model into a multiclass classification problem. More information is reserved by choosing either of the two options. Option three turns the model into a binary classification problem which only describes whether a customer pays tip or not after a taxi trip.
<br />
<br />
![](https://github.com/dwy904/TipsPrediction_NYCGreenTaxi/blob/master/FeatureReEngineering.png)

When the dataset for classification model training is partitioned, the portion of each tip group within the training dataset should be balanced because keeping each class in an equal portion during the model training procedure prevents overfitting toward one class. Only about 20% of the data can be used in the training dataset due to the equal portion requirement for the training dataset. In this situation, balanced accuracy from the training dataset is used to evaluate the classification performance of different binning options. 


## Model Initialization 

Random forest algorithm is selected in these classification problems. The binning option that provides the most information and yields the highest accuracy rate is selected to perform in-depth analysis (parameter tuning and cross validation). The classification training accuracies are shown below for different tip binning option groups. As the number of classes increases, the classification accuracies tend to decreased. Meanwhile, less information is explored when there are fewer classes in the classification model.
<br />

|Option|1|2|3|
|    :---:    |     :---:  |   :---:  |   :---:  | 
|Accuracy|56%|60%|63%|


## Cross Validation and Parameter Tuning

The random forest model associated with option 2 is chosen for cross validation and parameter tuning procedures due to its reasonable classification accuracy and the number of classes. These two procedures are performed because it is likely that the model classification accuracy can be boosted by utilizing hyper-parameter tuning. At the same time, cross validation analysis prevents classification models from overfitting. <br />

Parameter tuning is first performed in search of the optimal parameter within the random forest model. The tree number is the targeted parameter to be tuned in the random forest model. The balanced training accuracy reaches its maximum at the tree number 50.  <br />

|Tree Number|10|50|100|200|
|    :---:    |     :---:  |   :---:  |   :---:  |  :---:  | 
|**Balanced Accuracy**| 59%|60%|60%|60%|

A random forest classification with 50 trees is the finalized model for this classification situation. In order to examine whether overfitting issue occurs, cross validation is performed following parameter tuning. <br />

|Cross Validation|Fold 1|Fold 2|Fold 3|Fold 4|Fold 5|Test Accuracy|
| :---: | :---:  |   :---:  |   :---:  |  :---:  |   :---:  |   :---:  | 
|**Balanced Accuracy**| 60%|60%|60%|60%|60%|60%|

There are 5 separate folds during the cross validation process. The constant balanced validation accuracy indicates that the random forest classification is stable while 60% accuracy in the test dataset confirms all the analyses performed above are appropriate. The confusion matrix in Figure 6 below shows the classification accuracy by each class. The model is able to most accurately classify the tip group paying 0% tip according to the diagonal matrix. <br />

<br />

![](https://github.com/dwy904/TipsPrediction_NYCGreenTaxi/blob/master/ConfusionMatrix_Test.png)



## Conclusion
In this report, data cleaning and feature engineering procedures are carefully performed in a reasonable and appropriate approach. The data cleaning process successfully removes the unreasonable, unrelated and unnecessary observations. The feature engineering procedure diversifies the formats of the data. Both linear regression and classification models are built during model training process. The linear regression model is not an appropriate modeling method in this situation due to a weak linear correlation between the response and predictive variables. Although the multiclass classification model provides a better performance in comparison with the linear model, it is still not intelligent enough to make precise classifications. 


<br />

> Note: Code will be uploaded shortly
