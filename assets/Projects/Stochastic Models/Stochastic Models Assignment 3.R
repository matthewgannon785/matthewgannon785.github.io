library(emplik)
library(survival)
library(dplyr)
data(myeloma)
colnames(myeloma) <- c("time","vstatus","logBUN","HGB","platelet","age",
                       "logWBC","FRAC","logPBM","protein","SCALC")
myeloma <- as.data.frame(myeloma)
?myeloma


# Question 1. 
survdat <- Surv(time= myeloma$time,event= myeloma$vstatus)
fit <- survfit(survdat~myeloma$platelet, data=myeloma,se=TRUE)

plot(fit,conf.int=FALSE,col=1:2, lwd = 3)

# Question 2. 

summary(fit)

diff<- survdiff(survdat~myeloma$platelet, data=myeloma)
diff



# Question 3.

#Fit the Cox PH model to the data
fit_cox <- coxph(survdat~logBUN + HGB + platelet + age + logWBC + 
FRAC + logPBM + protein + SCALC, data=myeloma)
summary(fit_cox)

# Perform stepwise variable selection using AIC
final_model <- step(fit_cox, direction = "both", 
                    scope = formula(fit_cox), 
                    k = 2, trace = FALSE)

summary(final_model)
