rm(list=ls())  # clear all variables
dev.off() # clear all plots
cat("\014") # clear console
a = 0
b = 0
rho = 0.2
ProbCalc = function(c_or_u, c, u){
    if(c_or_u){ 
        Prob = rnorm(1, b + rho*(u - a), sqrt(1 - rho^2))
    }else{            
        Prob = rnorm(1, a + rho*(c - b), sqrt(1 - rho^2))
    }
    return(Prob)
}
GibbsStep = function(c_or_u, c, u){
    Prob = ProbCalc(c_or_u, c, u)
    if(c_or_u){
        c = Prob
    }else{
        u = Prob
    }
    return(list(c=c, u=u))
}
GibbsSelect = function(c, u){
    c_or_u = ifelse(rbinom(1, 1, 0.5), TRUE, FALSE)
    return(GibbsStep(c_or_u, c, u)) # Takes all three values and passes them onto fprobCalc
}
Gibbs = function(numIterations, c, u){
    lc = vector(length = numIterations) # Creates two vectors with all elements equal to FALSE
    lu = vector(length = numIterations)
    lc[1] = c # Sets the first element to be the boolean chosen in fGibbsComplete()
    lu[1] = u
    for(i in 2:numIterations){
        lState = GibbsSelect(lc[i-1], lu[i-1]) # Takes the two first element values and generates a boolean for cloud_or_rain
        lc[i] = lState$c
        lu[i] = lState$u
    }
    return(list(u = lu, c = lc))
}
Test = Gibbs(500, runif(1, -4, 4), runif(1, -4, 4)) # This is what runs the Gibbs Sampler
df3 = data.frame(x = Test$c, y = Test$u)
ggplot(df3, aes(x, y)) +
    geom_density_2d(size = 1, aes(color = "Contours")) +
    geom_path(aes(color = "Parameter Path"), lwd = 1) +
    geom_point(aes(color = "Parameter Values"), size = 2) +
    labs(x = "Crime", y = "Unemployment") +
    theme(axis.text.x = element_text(size = 18),
          axis.title.x = element_text(size = 20),
          axis.text.y = element_text(size = 18),
          axis.title.y = element_text(size = 20, vjust = 0.5),
          plot.title = element_text(size = 20, face = "bold", hjust = 0.5),
          legend.position = c(0.14, 0.84),
          legend.background = element_rect(fill = "grey96", size = 1, linetype = "solid"),
          legend.text = element_text(size = 16),
          legend.title = element_text(size = 18, face = "bold")) +
    guides(fill = guide_legend(reverse = TRUE), color=guide_legend(override.aes=list(fill=NA))) +
    scale_x_continuous(breaks = seq(-4, 4, 1),
                       limits = c(-4, 4)) +
    scale_y_continuous(breaks = seq(-4, 4, 1),
                       limits = c(-4, 4)) +
    ggtitle("Gibbs") +
    scale_color_manual("Results", values = c("deepskyblue2", "black", "red1"), breaks = c("Parameter Values", "Parameter Path", "Contours"))
