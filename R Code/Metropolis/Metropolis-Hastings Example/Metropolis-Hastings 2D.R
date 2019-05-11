#rm(list=ls())  # clear all variables
dev.off() # clear all plots
cat("\014") # clear console
Data = read.csv(file="F:/Documents/University/Math Project/Project Year 4/Ben Lambert Data/RWM_mosquito.csv", header=TRUE, sep=",")
fMean = function(mu,psi,t){ # 13.3.1
  return(1000*exp(-mu*t)*psi)
}
fLikelihood = function(mu,psi,Data){
  t = Data$time
  X = Data$recaptured
  Mean = sapply(t, function(x) fMean(mu,psi,x))
  # sapply works with a list of numbers or a vector. Takes each value and applys the specified function to it
  # seq_along() returns number of elements a vector has. See seq(10) vs seq_along(10)
  # dpois is the Poisson Dist. The "d" pois gives the (log) density
  Likelihood = sapply(t, function(i) dpois(X[i], Mean[i]))
  return(prod(Likelihood)) # prod() returns the product of all the values
}
f1 = function(x, y){
  fLikelihood(x, y, Data) * rgamma(1, shape = 2, rate = 20)
}
f2 = function(x, y){
  fLikelihood(x, y, Data) * rbeta(1, shape1 = 2, shape2 = 40, ncp = 0)
}
x0 = numeric(10000)
y0 = x0
x0[1] = runif(1) # Randomly pick an initial position x_0
y0[1] = runif(1)
print(x0[1]) # View initial position
pring(y0[1])
sigma = 1
J1 = function(x,y){ #Jumping (proposal) distribution from y to x. This is Gaussian on a confined domain. Should integrate (dx) to 1. On a finite domain this factor is important.
  ff = function(x){
    dlnorm(x, meanlog = 0.5*(-sigma^2 + 2*log10(x)), sdlog = sigma)
  }
  Anorm = integrate(ff, 0, 1)
  result = ff(x)/Anorm$value  # If symmetric, this will cancel out, possibly leaving the normalisation factor
  return(result)
}
J2 = function(x,y){ #Jumping (proposal) distribution from y to x. This is Gaussian on a confined domain. Should integrate (dx) to 1. On a finite domain this factor is important.
  ff = function(x){
    dbeta(x, shape1 = 2 + x, shape2 = 40 - x)
  }
  Anorm = integrate(ff, 0, 1)
  result = ff(x)/Anorm$value  # If symmetric, this will cancel out, possibly leaving the normalisation factor
  return(result)
}
for(i in 1:length(x0)){
  x1 = rlnorm(1, meanlog = 0.5*(-sigma^2 + 2*log10(x0[i])), sdlog = sigma) # Generate random normally distributed sample from initial position: x'
  y1 = rbeta(1, shape1 = 2 + y0[i], shape2 = 40 - y0[i])
  #print(x1) # View accepted sample
  A = min(1, ((f2(x1,y1)/f2(x0[i],y0[i])) * (f1(x1,y1)/f1(x0[i],y0[i])) * (J2(y0[i],y1)/J2(y1,y0[i])) * (J1(x0[i],x1)/J1(x1,x0[i])))) # Acceptence Ratio
  u = runif(1, min = 0, max = 1)
  if((u>A)|(x1<0)|(x1>1)){
    x0[i+1] = x0[i] # Make the next value to be used equal to the last: x_{t+1} = x_t
  } else{
    x0[i+1] = x1 # Accept candidate x'
  }
  if((u>A)|(y1<0)|(y1>1)){
    y0[i+1] = y0[i]
  } else{
    y0[i+1] = y1
  }
}
x0 = c(x0[51:length(x0)]) # A way of chopping off the first 50 valuesmean
y0 = c(y0[51:length(y0)])
df1 = data.frame(x = Data$time, y = Data$recaptured)
df2 = data.frame(x = seq(0,15,length=100), y = fMean(0.1, 0.05, seq(0,18,length=100)))
df3 = data.frame(x = x0, y = y0)
df4 = data.frame(x = seq(1,15,length=46), y = fMean(unique(x0), unique(y0), seq(1,15,length=46)))
df5 = data.frame(x = unique(x0), y = unique(y0))
ggplot(df1, aes(x, y)) +
  geom_line(aes(color = "Recapture"), lwd = 1) +
  geom_point(data = df1, color = "black", size = 2) +
  geom_line(data = df2, aes(color = "Model"), lwd = 1) +
  labs(x = "Time in Days", y = "Recapture") +
  theme(axis.text.x = element_text(size = 18),
        axis.title.x = element_text(size = 20),
        axis.text.y = element_text(size = 18),
        axis.title.y = element_text(size = 20),
        plot.title = element_text(size = 20, face = "bold", hjust = 0.5),
        legend.position = c(0.8, 0.84),
        legend.background = element_rect(fill = "grey96", size = 1, linetype = "solid"),
        legend.text = element_text(size = 18),
        legend.title = element_text(size = 18, face = "bold")) +
  guides(fill = guide_legend(reverse = TRUE), color=guide_legend(override.aes=list(fill=NA))) +
  scale_x_continuous(breaks = seq(1, 15, 2),
                     limits = c(1, 15)) +
  scale_y_continuous(breaks = seq(5, 45, 5),
                     limits = c(5, 45)) +
  ggtitle("Number of Recaptures Each Day") +
  scale_color_manual("Results", values = c("deepskyblue2", "red1"), breaks = c("Recapture", "Model"))
qplot(c(1:length(x0)), x0, geom = "line", ylab = expression(mu), xlab = "Step Count") +
  theme(axis.text.x = element_text(size = 26),
        axis.title.x = element_text(size = 30),
        axis.text.y = element_text(size = 28),
        axis.title.y = element_text(size = 32, angle = 0, vjust = 0.5))
qplot(c(1:length(y0)), y0, geom = "line", ylab = expression(psi), xlab = "Step Count") +
  theme(axis.text.x = element_text(size = 26),
        axis.title.x = element_text(size = 30),
        axis.text.y = element_text(size = 28),
        axis.title.y = element_text(size = 32, angle = 0, vjust = 0.53, hjust = 1))
mean(x0) # 0.09695635
sd(x0)
mean(unique(x0)) + 2*sd(unique(x0))
#summary(x0)
mean(y0) # 0.04105427
sd(y0)
ggplot(df3, aes(x)) +
  geom_histogram(aes(y = ..density..), binwidth = 0.005, color = "black", fill = "grey85") +
  stat_function(fun = dnorm, args = list(mean = mean(df3$x), sd = sd(df3$x)), lwd = 1, color = "deepskyblue2") +
  geom_vline(aes(xintercept = mean(df3$x)),
             color = "blue", linetype="dashed", size=1) +
  labs(x = expression(paste("Parameter ", mu)), y = "Density") +
  theme(axis.text.x = element_text(size = 24),
        axis.title.x = element_text(size = 26),
        axis.text.y = element_text(size = 24),
        axis.title.y = element_text(size = 26)) +
  scale_y_continuous(breaks = seq(0, 60, 10),
                     limits = c(0, 60))
ggplot(df3, aes(y)) +
  geom_histogram(aes(y = ..density..), binwidth = 0.001, color = "black", fill = "grey85") +
  stat_function(fun = dnorm, args = list(mean = mean(df3$y), sd = sd(df3$y)), lwd = 1, color = "coral2") +
  geom_vline(aes(xintercept = mean(df3$y)),
             color = "red", linetype="dashed", size=1) +
  labs(x = expression(paste("Parameter ", psi)), y = "Density") +
  theme(axis.text.x = element_text(size = 24),
        axis.title.x = element_text(size = 26),
        axis.text.y = element_text(size = 24),
        axis.title.y = element_text(size = 26)) +
  scale_y_continuous(breaks = seq(0, 200, 50),
                     limits = c(0, 200)) +
  scale_x_continuous(breaks = seq(0.035, 0.055, 0.005))
ggplot(df3, aes(x, y)) +
  geom_point(data = df3, aes(color = "Accepted Values"), size = 2) +
  stat_ellipse(type = "norm", level = 0.958, size = 1, aes(color = "95.8% Confidence")) +
  stat_ellipse(type = "norm", level = 0.682, size = 1, aes(color = "68.2% Confidence")) +
  labs(x = expression(mu), y = expression(psi)) +
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
  scale_x_continuous(breaks = seq(0.065, 0.135, 0.01),
                     limits = c(0.065, 0.135)) +
  scale_y_continuous(breaks = seq(0.03, 0.06, 0.005),
                     limits = c(0.03, 0.06)) +
  ggtitle("Confidence Ellipse") +
  scale_color_manual("Results", values = c("deepskyblue2", "red1", "black"), breaks = c("Accepted Values", "68.2% Confidence", "95.8% Confidence"))
ggplot(df4, aes(x, y)) +
  geom_smooth(method = "auto", aes(color = "Predicted Model"), lwd = 1, level = 0.682) +
  geom_smooth(method = "auto", aes(color = "Predicted Model"), lwd = 1, level = 0.958) +
  geom_point(data = df1, color = "black", size = 2) +
  geom_line(data = df1, aes(color = "Recapture"), lwd = 1) +
  labs(x = "Time in Days", y = "Recapture") +
  theme(axis.text.x = element_text(size = 18),
        axis.title.x = element_text(size = 20),
        axis.text.y = element_text(size = 18),
        axis.title.y = element_text(size = 20),
        plot.title = element_text(size = 20, face = "bold", hjust = 0.5),
        legend.position = c(0.8, 0.84),
        legend.background = element_rect(fill = "grey96", size = 1, linetype = "solid"),
        legend.text = element_text(size = 18),
        legend.title = element_text(size = 18, face = "bold")) +
  guides(fill = guide_legend(reverse = TRUE), color=guide_legend(override.aes=list(fill=NA))) +
  scale_x_continuous(breaks = seq(1, 15, 2),
                     limits = c(1, 15)) +
  scale_y_continuous(breaks = seq(5, 45, 5),
                     limits = c(5, 45)) +
  ggtitle("Number of Recaptures Each Day") +
  scale_color_manual("Results", values = c("deepskyblue2", "red1"), breaks = c("Recapture", "Predicted Model"))
ggplot(df5, aes(x, y)) +
  geom_density_2d(size = 1, aes(color = "Contours")) +
  geom_path(data = df5, aes(color = "Parameter Path"), lwd = 1) +
  geom_point(data = df5, aes(color = "Accepted Values"), size = 2) +
  labs(x = expression(mu), y = expression(psi)) +
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
  scale_x_continuous(breaks = seq(0.055, 0.145, 0.01),
                     limits = c(0.055, 0.145)) +
  scale_y_continuous(breaks = seq(0.025, 0.06, 0.005),
                     limits = c(0.025, 0.06)) +
  ggtitle("Metropolis") +
  scale_color_manual("Results", values = c("red1", "deepskyblue2", "black"), breaks = c("Accepted Values", "Parameter Path", "Contours"))

