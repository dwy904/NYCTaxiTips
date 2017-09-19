# NYC Taxi Tips Prediction
> by Weiye Deng

## Introduction

This report aims to build a quantitative model to predict the percentage of tip to be paid by each customer after a taxi trip. The dataset, Sep 2015 NYC Green Taxi, is publicly available on NYC Taxi & Limousine Commission’s official website. Data cleaning, feature engineering and data partitioning procedures were performed before the model is constructed. The least absolute shrinkage and selection operator (LASSO) and linear regression were applied during the modeling process. A random forest classification model is introduced to turn the prediction problem into a classification problem due to the poor fitness on the linear regression model. The original data need to be re-partitioned. Cross validation and accuracy testing processes on the random forest classification model are demonstrated.  Finally, further consideration and enhancement possibilities are proposed at the end of this report.

