rm(list=ls())  # clear all variables
dev.off() # clear all plots
cat("\014") # clear console
t = seq(0, 1, length = 200)
f = function(u){
  (exp(-(u-0.2)^2/0.002)/sqrt(2*pi*0.6)) + (exp(-(u-0.45)^2/0.02)/sqrt(2*pi*0.2)) + (exp(-(u-0.7)^2/0.002)/sqrt(2*pi*0.4))
}
y = f(t)
u0 = sample(t, 1) # Randomly pick an initial position
print(u0) # View initial position
i = 1
repeat{                               # /(sqrt(2*pi)*f(u0[i]))
  u1_dist = rnorm(1, mean = u0[i], sd = 1/(sqrt(2*pi)*f(u0[i]))) # Generate random normally distributed sample from initial position
  if(u1_dist >= 0 & u1_dist <= 1){
    u1 = u1_dist
    message(u1, ".  u0 index = ", length(u0)) # View accepted sample
    if(u1 <= u0[i]){
      r = f(u1)/f(u0[i])
    } else{
      r = 1
    }
    p = runif(1, min = 0, max = 1)
    if(r == 1){
      u0[i+1] = u1
      i = i + 1
    } else if(p < r){
      u0[i+1] = u1
      i = i + 1
    } else if(p >= r){
      u0[i+1] = u0[i]
      #if(i <= 20){            # This code is for capturing the movement
      #  plot(u0, f(u0), ylim = c(0,1), xlim = c(0,1), col="red", type="p")
      #  lines(c(u0[i], u0[i+1]), c(f(u0[i]), f(u0[i+1])), ylim = c(0,1), xlim = c(0,1), col="blue", type="l")
      #  if(i > 1){
      #    lines(u0[1:i], f(u0[1:i]), ylim = c(0,1), xlim = c(0,1), type="l")
      #  }
      #}
      i = i + 1
    }
  }
  if(i == 200){
    break
  }
}
qplot(t, y, geom = "line", ylab = "Posterior Density", xlab = "x", col="red", show.legend = FALSE, xlim = c(0,1), ylim = c(0,1)) +
  theme(axis.text.x = element_text(size = 14),
        axis.title.x = element_text(size = 16),
        axis.text.y = element_text(size = 14),
        axis.title.y = element_text(size = 16),
        plot.title = element_text(size = 16, face = "bold", hjust = 0.5))
qplot(c(1:i), u0, geom = "line", ylab = "x", xlab = "Step Count") +
  theme(axis.text.x = element_text(size = 14),
        axis.title.x = element_text(size = 16),
        axis.text.y = element_text(size = 14),
        axis.title.y = element_text(size = 16)) # NOTE: If these two plots give errors then just highlight
                                                # and re-run them again.
qplot(u0, f(u0), geom = c("point", "path"), ylab = "Posterior Density", xlab = "x", ylim = c(0,1), xlim = c(0,1)) +
  geom_point(color = "red", size = 2) +
  geom_path(color = "black") +
  theme(axis.text.x = element_text(size = 14),
        axis.title.x = element_text(size = 16),
        axis.text.y = element_text(size = 14),
        axis.title.y = element_text(size = 16),
        plot.title = element_text(size = 16, face = "bold", hjust = 0.5)) +
  ggtitle("Estimate with Step Connections")
qplot(u0, f(u0), geom = c("point", "line"), ylab = "Posterior Density", xlab = "x", ylim = c(0,1), xlim = c(0,1)) +
  geom_point(color = "black", size = 2) +
  geom_line(color = "red") +
  theme(axis.text.x = element_text(size = 14),
        axis.title.x = element_text(size = 16),
        axis.text.y = element_text(size = 14),
        axis.title.y = element_text(size = 16),
        plot.title = element_text(size = 16, face = "bold", hjust = 0.5)) +
  ggtitle("Posterior Estimate")
##########################################
# Graph of lost values from asymmetries
funcShaded <- function(x) {
  y = dnorm(x, mean = 0.04, sd = 0.1)
  y[x > 0 | x < (0 - 2)] = NA
  return(y)
}
ggplot(data.frame(x = c(-0.2,0.4)), aes(x = x)) +
  stat_function(fun = dnorm, args = list(0.04, 0.1), lwd = 1, color = "red1") +
  geom_vline(xintercept = 0.04, color = "deepskyblue2", linetype = "dashed", size = 1) +
  stat_function(fun = funcShaded, geom = "area", fill= "red", alpha = 0.3) +
  scale_x_continuous(breaks = seq(-0.2, 0.4, 0.1),
                     limits=c(-0.2, 0.4)) +
  labs(x = "Parameter value", y = "Probability Density") +
  theme(axis.text.x = element_text(size = 20),
        axis.title.x = element_text(size = 20),
        axis.text.y = element_text(size = 20),
        axis.title.y = element_text(size = 20),
        plot.title = element_text(size = 22, face = "bold", hjust = 0.5),
        legend.title = element_blank()) +
  ggtitle("Loss of Samples")





#print(options(mc.cores = parallel::detectCores()))
#rstan_options(auto_write = TRUE)