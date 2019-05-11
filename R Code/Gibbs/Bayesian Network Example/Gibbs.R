rm(list=ls())  # clear all variables
dev.off() # clear all plots
cat("\014") # clear console
fTransition = function(aProb){
  indicator = rbinom(1, 1, aProb) # No. of observations, No. of trials. rbinom gives random deviates.
  return(indicator)               # Returns either a 1 or 0
}
fProbCalc = function(cloud_or_rain, cloud, rain){
  if(cloud_or_rain){ # Updating cloud if "cloud_or_rain" = TRUE i.e. it was cloudy conditional to
    if(rain){
      aProb = 0.444  # rain
    } else{
      aProb = 0.048  # not rain
    }
  }else{             # Updating rain if "cloud_or_rain" = FALSE i.e. it rained conditional to
    if(cloud){
      aProb = 0.815  # cloudy
    } else{
      aProb = 0.216  # not cloudy
    }
  }
  return(aProb)
}
fGibbsStep = function(cloud_or_rain, cloud, rain){
  aProb = fProbCalc(cloud_or_rain, cloud, rain)
  aNewState = ifelse(fTransition(aProb) == 1, TRUE, FALSE) # Sets aNewState to be TRUE or FALSE depsnding on the probability aProb
  if(cloud_or_rain){
    cloud = aNewState
  }else{
    rain = aNewState
  }
  return(list(cloud=cloud, rain=rain))
}
fGibbsSelect = function(cloud, rain){
  cloud_or_rain = ifelse(rbinom(1, 1, 0.5), TRUE, FALSE)
  return(fGibbsStep(cloud_or_rain, cloud, rain)) # Takes all three values and passes them onto fprobCalc
}
fGibbsComplete = function(numIterations, cloud, rain){
  lCloud = vector(length = numIterations) # Creates two vectors with all elements equal to FALSE
  lRain = vector(length = numIterations)
  lCloud[1] = cloud # Sets the first element to be the boolean chosen in fGibbsComplete()
  lRain[1] = rain
  for(i in 2:numIterations){
    lState = fGibbsSelect(lCloud[i-1], lRain[i-1]) # Takes the two first element values and generates a boolean for cloud_or_rain
    lCloud[i] = lState$cloud
    lRain[i] = lState$rain
  }
  return(list(cloud = lCloud, rain = lRain))
}
lTest = fGibbsComplete(10000, TRUE, TRUE) # This is what runs the Gibbs Sampler
df1 = data.frame(x = ifelse(lTest$cloud, 1, 0), y = ifelse(lTest$rain, 1, 0)) # Converts true and false vectors to 1 and zero vectors
df2 = data.frame(x = df1$x[1:15], y = df1$y[1:15])
ggplot(df1, aes(x)) +
  geom_histogram(aes(y = ..density..), binwidth = 0.5, color = "black", fill = "grey85") +
  stat_function(fun = dnorm, args = list(mean = mean(df1$x), sd = sd(df1$x)), lwd = 1, color = "deepskyblue2") +
  geom_vline(aes(xintercept = mean(df1$x)),
             color = "blue", linetype="dashed", size=1) +
  labs(x = "C", y = "Density") +
  theme(axis.text.x = element_text(size = 24),
        axis.title.x = element_text(size = 26),
        axis.text.y = element_text(size = 24),
        axis.title.y = element_text(size = 26)) +
  scale_y_continuous(breaks = seq(0, 2, 0.5),
                     limits = c(0, 2))
ggplot(df1, aes(y)) +
  geom_histogram(aes(y = ..density..), binwidth = 0.5, color = "black", fill = "grey85") +
  stat_function(fun = dnorm, args = list(mean = mean(df1$y), sd = sd(df1$y)), lwd = 1, color = "coral2") +
  geom_vline(aes(xintercept = mean(df1$y)),
             color = "red", linetype="dashed", size=1) +
  labs(x = "R", y = "Density") +
  theme(axis.text.x = element_text(size = 24),
        axis.title.x = element_text(size = 26),
        axis.text.y = element_text(size = 24),
        axis.title.y = element_text(size = 26)) +
  scale_y_continuous(breaks = seq(0, 1.5, 0.5),
                     limits = c(0, 1.5))
Cm = mean(ifelse(lTest$cloud, 1, 0)) # approx. 0.17
Cs = sd(ifelse(lTest$cloud, 1, 0))
Cm + 2*Cs
Cm - 2*Cs
Rm = mean(ifelse(lTest$rain, 1, 0)) # approx. 0.32
Rs = sd(ifelse(lTest$rain, 1, 0))
Rm + 2*Rs
Rm - 2*Rs
mean(ifelse(lTest$cloud, 1, 0) == 1 & ifelse(lTest$rain, 1, 0) == 1) # approx. 0.14
ggplot(df1, aes(x, y)) +
  geom_path(data = df2, aes(color = "Parameter Path"), lwd = 1) +
  geom_point(data = df2, aes(color = "Accepted Values"), size = 2) +
  labs(x = "P(C)", y = "P(R)") +
  theme(axis.text.x = element_text(size = 18),
        axis.title.x = element_text(size = 20),
        axis.text.y = element_text(size = 18),
        axis.title.y = element_text(size = 20, angle = 0, vjust = 0.5),
        plot.title = element_text(size = 20, face = "bold", hjust = 0.5),
        legend.position = c(0.14, 0.84),
        legend.background = element_rect(fill = "grey96", size = 1, linetype = "solid"),
        legend.text = element_text(size = 16),
        legend.title = element_text(size = 18, face = "bold")) +
  guides(fill = guide_legend(reverse = TRUE), color=guide_legend(override.aes=list(fill=NA))) +
  scale_x_continuous(breaks = seq(-1, 2, 0.5),
                     limits = c(-1, 2)) +
  scale_y_continuous(breaks = seq(-1, 2, 0.5),
                     limits = c(-1, 2)) +
  ggtitle("Gibbs") +
  scale_color_manual("Results", values = c("red1", "black"), breaks = c("Accepted Values", "Parameter Path"))
