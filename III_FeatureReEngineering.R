# Tip Percentage Binning

# Option 1
Green_Taxi_Model$Tip_Group = '0'
Green_Taxi_Model$Tip_Group[Green_Taxi_Model$Tip_Pct > 0 & 
                             Green_Taxi_Model$Tip_Pct <= 0.19] = '0-19'
Green_Taxi_Model$Tip_Group[Green_Taxi_Model$Tip_Pct > 0.19 & 
                             Green_Taxi_Model$Tip_Pct <= 0.24] = '19-24'
Green_Taxi_Model$Tip_Group[Green_Taxi_Model$Tip_Pct > 0.24 & 
                             Green_Taxi_Model$Tip_Pct <= 0.26] = '24 - 26'
Green_Taxi_Model$Tip_Group[Green_Taxi_Model$Tip_Pct > 0.26] = '26 More'

p7 = ggplot(aes(x = Tip_Group, fill = Tip_Group), data = Green_Taxi_Model) + geom_bar() +
  xlab('Tip Group (%)')  + ylab('Frequency') + ggtitle('Option 1')


# Option 2
Green_Taxi_Model$Tip_Group = '0'
Green_Taxi_Model$Tip_Group[Green_Taxi_Model$Tip_Pct > 0 & 
                             Green_Taxi_Model$Tip_Pct <= 0.19] = '0-19'
Green_Taxi_Model$Tip_Group[Green_Taxi_Model$Tip_Pct > 0.19] = '19 More'

p8 = ggplot(aes(x = Tip_Group, fill = Tip_Group), data = Green_Taxi_Model) + geom_bar() +
  xlab('Tip Group (%)') + ylab('Frequency') + ggtitle('Option 2')


# Option 3
Green_Taxi_Model$Tip_Group = '0'
Green_Taxi_Model$Tip_Group[Green_Taxi_Model$Tip_Pct > 0] = 'Has Tip'

p9 = ggplot(aes(x = Tip_Group, fill = Tip_Group), data = Green_Taxi_Model) + geom_bar() +
 xlab('Tip Group (%)') + ylab('Frequency') + ggtitle('Option 3')


# Plot the original distribution
p10 = ggplot(aes(x = Tip_Pct), data = Green_Taxi_Model) + xlim(-0.01, 0.5) +
  geom_histogram(fill = 'lightblue', color = 'white', binwidth = 0.01) + ylab('Frequency') +
  ggtitle('Original Distribution') + xlab('') 


# Visualize the distribution
layout <- matrix(c(1, 1, 1, 2, 3, 4), nrow = 2, byrow = TRUE)
multiplot(p10, p7, p8, p9, layout = layout)