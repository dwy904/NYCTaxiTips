## Procedure VI - Conclusion & Testing

# Finalized the random forest model with num.trees equals to 50.
Random_Forest_Final = Train_Data %>%
  ml_random_forest(response = "Tip_Group", 
                   features = colnames(Train_Data)[-29], type = 'classification',
                   max.bins = 6, num.trees = 50)

Test_Output = data.frame(Prediction = predict(Random_Forest_Final, newdata = Test_Data),
                         select(Test_Data, Tip_Group))

# Final test accuracy
mean(as.numeric(confusionMatrix(Test_Output$Prediction, Test_Output$Tip_Group)$byClass[,11]))

# Visualize the confusion matrix
Confusion = data.frame(confusionMatrix(Test_Output$Prediction, Test_Output$Tip_Group)$table)

ggplot(data =  Confusion, aes(x = Reference, y = Prediction, fill = Freq)) +
  geom_tile(aes(fill = Freq), colour = "white") +
  geom_text(aes(label = sprintf("%1.0f", Freq)), vjust = 1) +
  scale_fill_gradient(low = "lightblue", high = "deepskyblue4") +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank()) +
  ggtitle('Final Confusion Matrix')