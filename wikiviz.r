library(ggplot2)
library(zoo)
library(xts)
d = read.csv("input.csv")
#summary(d)

# Truncate url
d$url_trunc <- c(gsub("^.*/", "", d$url)) # Keeps text after last "/" of url
d$url_trunc <- c(gsub("\\+", " ", d$url_trunc)) # Removes "+" for readability


# Formate time
dates <- strptime(as.character(d$dtg), "%Y-%m-%d %H:%M:%S") # Convert date into POSIX
d = data.frame(date=dates, d) # Add useful date column
d = d[,-2] # Remove original date column that isn't in proper format
daterange=c(as.POSIXlt(min(d$date)), as.POSIXlt(max(d$date))) # Calculate first and last date/time

# Unique user and url rows -- count used to calculate height
unique <- d[,c('user','url_trunc')]
unique <- unique[!duplicated(unique[,c('user','url_trunc')]),]

# Unique set of users, loops on a user once in for loop
users <- unique(d$user)

# Modifies font sizes for title, labels, and axes
modifiedtheme <- theme_grey(base_size=12) + theme(title = element_text(face="bold", size=rel(0.5)), axis.text = element_text(size=rel(0.4)))
  #+ theme(axis.text.x = element_text(angle=45, face="bold", hjust=1)) # Rotate x axis

for (i in users){  # Group data by user variable
  #if (i == "ewyatt") {
  try({ # Ignores users with one data point in time frame
    p <- plot.new()
    p <- ggplot(data=d[d$user==i,], aes(x=date, y=url_trunc, group=user)) + geom_point(size=1.25) + geom_line(size=0.5)

    p <- p + labs(list(title=i, x="Date and Time", y = "Page Title")) +   # Plot labels
      axis.POSIXct(1, at=seq(daterange[1], daterange[2], by="hour"), format="I %p") + # Set x axis range to first and last date-time in data
      modifiedtheme

    ggsave(plot = p, filename = paste(i,".png",sep=""), height=(0.1*nrow(unique[unique$user==i,])+1),width=(0.5+as.double(daterange[2]-daterange[1])*0.25))
      # Height depends on # of url the user visited
      # Width depends on range of data collection
  })
  #}
}