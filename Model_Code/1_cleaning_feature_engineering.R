# Disable scientific notation
options(scipen=9999)

# Set current directory 
setwd('Input the Path to Folder, Data_File') 

# Load data from current directory (you do not have to run this line if you have the data already)
Green_Taxi = read_csv("green_tripdata_201x-09.csv")


## Create a derived variable 'Tip_Pct'

# Select the tip amout larger than or equal to 0
Green_Taxi = Green_Taxi[Green_Taxi$Tip_amount >=0,]
Green_Taxi$Tip_Pct = Green_Taxi$Tip_amount / (Green_Taxi$Total_amount - Green_Taxi$Tip_amount)
Green_Taxi$Tip_Pct[Green_Taxi$Total_amount == 0 & Green_Taxi$Tip_amount == 0] = 0
Green_Taxi = Green_Taxi[Green_Taxi$Tip_Pct != Inf,]
Green_Taxi = Green_Taxi[Green_Taxi$Tip_Pct <= 1,]
summary(Green_Taxi$Tip_Pct) 


## Procedure I -  Data Cleaning

Green_Taxi_Model = Green_Taxi

# Summary statistics of each variable within the dataset
summary(Green_Taxi_Model)
# Remove variable 'Ehail_fee' (All NAs)
Green_Taxi_Model = Green_Taxi_Model[,-17]
# Remove total amount less than 0
Green_Taxi_Model = subset(Green_Taxi_Model, Total_amount >=0)
# Only select credit card transactions (becaues cash transaction tip can not be captured)
Green_Taxi_Model = subset(Green_Taxi_Model, Payment_type == 1)
# Remove observations that are negative in variable, 'Extra'
Green_Taxi_Model = subset(Green_Taxi_Model, Extra >=0)
# Remove observations that have 0 passenger counts
Green_Taxi_Model = subset(Green_Taxi_Model, Passenger_count > 0)
# Remove observations that have 0 trip distance
Green_Taxi_Model = subset(Green_Taxi_Model, Trip_distance > 0)
# Remove the observations that have no 'Trip_type' recorded
Green_Taxi_Model = Green_Taxi_Model[is.na(Green_Taxi_Model$Trip_type) == F,]
# Check the location data that are within the resonable ranges
Longitude_Range = c(-74.326853, -73.693488, -73.655488, -74.309009)
Latitude_Range = c(40.484764, 40.455305,40.955095, 40.922536)
Green_Taxi_Model = 
  subset(Green_Taxi_Model, 
         Pickup_latitude < max(Latitude_Range) & Pickup_latitude > min(Latitude_Range) &
         Dropoff_longitude < max(Longitude_Range) & Dropoff_longitude > min(Longitude_Range))

# Converting data format
Green_Taxi_Model$RateCodeID = as.factor(Green_Taxi_Model$RateCodeID)
Green_Taxi_Model$Trip_type = as.factor(Green_Taxi_Model$Trip_type)
Green_Taxi_Model$Store_and_fwd_flag = as.factor(Green_Taxi_Model$Store_and_fwd_flag)
Green_Taxi_Model$Payment_type = as.factor(Green_Taxi_Model$Payment_type)
Green_Taxi_Model$VendorID = as.factor(Green_Taxi_Model$VendorID)


## Procedure II - Exploratory Data Analysis and Feature Engineering

# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
# Code Website: http://www.cookbook-r.com/Graphs/Multiple_graphs_on_one_page_(ggplot2)/
multiplot <- function(..., plotlist = NULL, file, cols = 1, layout = NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

# District Identification (Pickup and Dropoff location)
# Load required package for geo-data processing
Map_NYC <- readOGR("ZillowNeighborhoods-NY.shp", layer="ZillowNeighborhoods-NY")
Map_Filter = Map_NYC[Map_NYC$City == 'New York', ]
Location_Data_Pickup <- data.frame(Longitude = Green_Taxi_Model$Pickup_longitude, 
                                   Latitude = Green_Taxi_Model$Pickup_latitude)
Location_Data_Dropoff <- data.frame(Longitude = Green_Taxi_Model$Dropoff_longitude, 
                                   Latitude = Green_Taxi_Model$Dropoff_latitude)
# Identify the pickup borough
coordinates(Location_Data_Pickup) <- ~ Longitude + Latitude
proj4string(Location_Data_Pickup) <- proj4string(Map_Filter)
County_Pickup = as.character(over(Location_Data_Pickup, Map_Filter)$County)
# Identify the dropoff borough
coordinates(Location_Data_Dropoff) <- ~ Longitude + Latitude
proj4string(Location_Data_Dropoff) <- proj4string(Map_Filter)
County_Dropoff = as.character(over(Location_Data_Dropoff, Map_Filter)$County)

Green_Taxi_Model$County_Pickup = County_Pickup
Green_Taxi_Model$County_Dropoff = County_Dropoff

# Replace missing values with 'Undefined
Green_Taxi_Model$County_Pickup[is.na(Green_Taxi_Model$County_Pickup)] = 'Undefined'
Green_Taxi_Model$County_Dropoff[is.na(Green_Taxi_Model$County_Dropoff)] = 'Undefined'
# Convert the variable to a categorical format
Green_Taxi_Model$County_Pickup = as.factor(Green_Taxi_Model$County_Pickup)
Green_Taxi_Model$County_Dropoff = as.factor(Green_Taxi_Model$County_Dropoff)

# Visualize the output
p1 = ggplot(aes(x = County_Pickup, fill = County_Pickup), data = Green_Taxi_Model) + geom_bar() +
  xlab('') + ylab('Frequency') + geom_text(stat='count',aes(label=..count..),vjust=-1, size = 3) +
  ylim(0, 350000) + ggtitle("Pickup District")

p2 = ggplot(aes(x = County_Dropoff, fill = County_Dropoff), data = Green_Taxi_Model) + geom_bar() +
  xlab('') + ylab('Frequency') + geom_text(stat='count',aes(label=..count..),vjust=-1, size = 3) +
  ylim(0, 350000) + ggtitle("Dropoff District")

multiplot(p1, p2, cols = 2)


# Create a factor variable for pickup and drop off hour (00:00 - 23:00)
Green_Taxi_Model$Pickup_hour = hour(Green_Taxi_Model$lpep_pickup_datetime)
Green_Taxi_Model$Dropoff_hour = hour(Green_Taxi_Model$Lpep_dropoff_datetime)

Green_Taxi_Model$Dropoff_hour_factor = as.factor(Green_Taxi_Model$Dropoff_hour)
Green_Taxi_Model$Pickup_hour_factor = as.factor(Green_Taxi_Model$Dropoff_hour)

# Create a categorical variable for passenger count
Green_Taxi_Model$Passenger_count_bin = '1'
Green_Taxi_Model$Passenger_count_bin[Green_Taxi_Model$Passenger_count > 1 & 
                                       Green_Taxi_Model$Passenger_count <= 4] = '2 To 4'
Green_Taxi_Model$Passenger_count_bin[Green_Taxi_Model$Passenger_count > 4] = '5 More'
Green_Taxi_Model$Passenger_count_bin = as.factor(Green_Taxi_Model$Passenger_count_bin)

p3 = ggplot(aes(x = Passenger_count_bin, fill = Passenger_count_bin), data = Green_Taxi_Model) + 
  geom_bar() +xlab('Passenger Count') + ylab('Frequency') + ggtitle("Passenger Count Bin") +
  geom_text(stat='count',aes(label=..count..),vjust=-1, size = 3) + ylim(0, 650000)


# Create a categorical variable for trip distance
Green_Taxi_Model$Trip_distance_bin = '0 - 5'
Green_Taxi_Model$Trip_distance_bin[Green_Taxi_Model$Trip_distance > 5 &
                                     Green_Taxi_Model$Trip_distance <= 10] = '5 - 10'
Green_Taxi_Model$Trip_distance_bin[Green_Taxi_Model$Trip_distance >10] = '10 More'
Green_Taxi_Model$Trip_distance_bin = as.factor(Green_Taxi_Model$Trip_distance_bin)

p4 = ggplot(aes(x = Trip_distance_bin, fill = Trip_distance_bin), data = Green_Taxi_Model) + 
  geom_bar() +xlab('Miles') + ylab('Frequency') + ggtitle("Trip Distance Bin") +
  geom_text(stat='count',aes(label=..count..),vjust=-1, size = 3) + ylim(0, 600000)

multiplot(p3, p4, cols = 2)

# Create a variable to identify weekday (Sunday - Saturday)
Green_Taxi_Model$Pickup_Weekday = 
  as.factor(weekdays(as.Date(Green_Taxi_Model$lpep_pickup_datetime)))

# Create a variable to identify weekends
Green_Taxi_Model$Weekend = 'No'
Green_Taxi_Model$Weekend[Green_Taxi_Model$Pickup_Weekday == 'Saturday' | 
                           Green_Taxi_Model$Pickup_Weekday == 'Sunday'] = 'Yes'
Green_Taxi_Model$Weekend = as.factor(Green_Taxi_Model$Weekend)

p5 = ggplot(aes(x = Weekend, fill = Weekend), data = Green_Taxi_Model) + 
  geom_bar() +xlab('Weekend') + ylab('Frequency') + ggtitle("Weekend") +
  geom_text(stat='count',aes(label=..count..),vjust=-1, size = 3) + ylim(0, 600000)

# Create a trip duration variable (unit in seconds)
Green_Taxi_Model$Trip_duration = 
  as.numeric(Green_Taxi_Model$Lpep_dropoff_datetime - Green_Taxi_Model$lpep_pickup_datetime)

p6 = ggplot(aes(x = Trip_duration), data = Green_Taxi_Model) + 
  geom_histogram(fill = 'pink', color = 'white', binwidth = 100) +xlab('Trip duration (Seconds)') +
  ylab('Frequency') + ggtitle("Trip duration") + xlim(0,5000)

multiplot(p5, p6, cols = 2)

# Removing missing values
Green_Taxi_Model = na.omit(Green_Taxi_Model)
# Remove variales 'total amount', 'tip amount' and 'payment type'
Green_Taxi_Model = Green_Taxi_Model[,-c(15,18:19)]
