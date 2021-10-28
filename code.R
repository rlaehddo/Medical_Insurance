
data <- read.csv("~/Desktop/school/stat151A/midterm/MedicalInsurance.csv")
age <- data$age
sex <- data$sex
bmi <- data$bmi
children <- data$children
smoker <- data$smoker
region <- data$region
charges <- data$charges

#EDA Plots
library(ggplot2)
library(reshape2)
library(ggpubr)
library(dplyr)
library(gridExtra)

figure1 <- ggplot(data=data, aes(x=charges)) +
  geom_histogram(bins=20, color = "black") + 
  labs(title = "Distribution of Charges", caption = "Figure 1a: Distribution of Charges", x = "charges (in dollars)")

logcharges <- log(charges)
sum(is.na(logcharges)) #2 NAN values
which(is.na(logcharges)) #80 and 730 
c(charges[80], charges[730]) #-999 and -999; negative values

figure2 <- ggplot(data=data, aes(x= logcharges)) +
  geom_histogram(bins=20, color = "black") + 
  labs(title = "Log Transformation of Distribution of Charges", caption = "Figure 1b: Log Transformation of Distribution of Charges", x = "log(charges)")

grid.arrange(figure1, figure2, ncol=2)

age.box <- ggplot(data=data,aes(x=age)) + 
  geom_boxplot() +
  labs(title="Distribution of Age")

sex.box <- ggplot(data=data, aes(x=sex)) +
  geom_boxplot() +
  labs(title="Distribution of Sexes")

maxbmi_df <- data %>%
  filter(bmi >140)

bmi.box <- ggplot(data=data, aes(x=bmi)) +
  geom_boxplot() +  
  geom_point(data=maxbmi_df, aes(y = 0), color = 'red') + 
  labs(title="Distribution of BMIs")
  

child.box <- ggplot(data=data,aes(x=children)) +
  geom_boxplot() +
  labs(title="Distribution of Children")

region.box <- ggplot(data=data, aes(x=region)) +
  geom_boxplot() +
  labs(title="Distribution of Regions")

smoker.box <- ggplot(data=data, aes(x=smoker)) +
  geom_boxplot() +
  labs(title="Distribution of Smokers")

grid.arrange(age.box, child.box, bmi.box, sex.box, region.box, smoker.box, ncol = 3,
             bottom = text_grob("Figure 2: Univariate Distribution of Explanatory Variables"))

max.bmi <- max(bmi) #143.02
which(bmi > 143) #974
data$logcharges <- logcharges
data <- na.omit(data)
data <- data[data$bmi !=max.bmi, ]
```

#correlation
continuous <- c("age", "bmi")

correlation_matrix <- round(cor(data[c(continuous, 'logcharges')]), 2)
melt_correlation_matrix <- melt(correlation_matrix)
ggplot(data = melt_correlation_matrix, aes(x = Var1, y = Var2, fill = value)) + 
  geom_tile() + geom_text(aes(label = value), color = "white", size = 4) + 
  labs (title = "Correlation Plot of Numerical Variables", caption = "Figure 3: Correlation Plot of Numerical Explanatory Variables")

par(mfrow = c(1,4))
#sex
sex.box <- boxplot(log(charges) ~ sex, data = data, main = "Charges by Sex")
#children
children.box <- boxplot(log(charges) ~ children, data = data, main = "Charges by Children")
#smoker
smoker.box <- boxplot(log(charges) ~ smoker, data = data, main = "Charges by Smoker")
#region
region.box <- boxplot(log(charges) ~ region, data = data, main = "Charges by Region")

mtext("Figure 4: Bivariate Relationship for Categorical Variable", side= 3, line = -22.5, outer = TRUE, cex = 0.6)


#sex interaction with age and bmi
sex.age <- ggplot(data[data$sex == "male" |
                         data$sex == "female", ], 
                  aes(x = cut_interval(x = age, length = 10), 
                      y = logcharges, color = sex)) + 
  geom_boxplot() + 
  xlab("Age") + 
  ylab("logcharges") + 
  labs(title = "logcharges vs. Age Categorized by Sex", color = 'Sex') +
  theme(plot.title = element_text(size = 10))

sex.bmi <- ggplot(data, aes(x = bmi, y = logcharges, color = sex)) + 
  geom_point(shape = 8) + 
  xlab("BMI") + 
  ylab("logcharges") + 
  xlim(c(0,60)) + 
  labs(title = "logcharges vs. BMI Categorized by Sex", color = 'Sex') +
  theme(plot.title = element_text(size = 10))

sex.interaction <- annotate_figure(ggarrange(sex.age, sex.bmi, ncol = 2, nrow = 1), top = text_grob("Interaction of logcharges by Age and BMI Categorized by Sex"))



#smoker interaction with age and bmi 
smoker.age <- ggplot(data[data$smoker == "yes" |
                            data$smoker == "no", ], 
                     aes(x = cut_interval(x = age, length = 10), 
                         y = logcharges, color = smoker)) + 
  geom_boxplot() + 
  xlab("Age") + 
  ylab("logcharges") + 
  labs(title = "logcharges vs. Age Categorized by Smoker", color = 'Smoker') +
  theme(plot.title = element_text(size = 10))

smoker.bmi <- ggplot(data, aes(x = bmi, y = logcharges, color = smoker)) + 
  geom_point(shape = 8) + 
  xlab("BMI") + 
  ylab("logcharges") + 
  xlim(c(0,60)) + 
  labs(title = "logcharges vs. BMI Categorized by Smoker", color = 'Smoker') +
  theme(plot.title = element_text(size = 10))

smoker.interaction <- annotate_figure(ggarrange(smoker.age, smoker.bmi, ncol = 2, nrow = 1),
                                      top = text_grob("Interaction of logcharges by Age and BMI Categorized by Smoker"))


#region interaction with age and bmi 
region.age <- ggplot(data[data$region == "northwest" |
                            data$region == "northeast" |
                            data$region == "southwest" |
                            data$region == "southeast", ],
                     aes(x = cut_interval(x=age, length =10),
                         y = logcharges, color = region)) + 
  geom_boxplot() + 
  xlab("Age") + 
  ylab("logcharges") + 
  labs(title = "logcharges vs. Age Categorized by Region", color = 'Region') +
  theme(plot.title = element_text(size = 10))


region.bmi <- ggplot(data, aes(x = bmi, y = logcharges, color = region)) + 
  geom_point(shape = 8) + 
  xlab("BMI") + 
  ylab("logcharges") + 
  labs(title = "logcharges vs. BMI Categorized by Region", color = 'Region') + 
  theme(plot.title = element_text(size = 10))

region.interaction <- annotate_figure(ggarrange(region.age, region.bmi, ncol = 2, nrow = 1),
                                      top = text_grob("Interaction of logcharges by Age and BMI Categorized by Region"))


#children interaction with age and bmi 
data["children"] <- as.factor(data$children)

children.age <- ggplot(data[data$children == "0" |
                              data$children == "1" |
                              data$children == "2" |
                              data$children == "3" |
                              data$children == "4" |
                              data$children == "5", ],
                       aes(x = cut_interval(x=age, length =10),
                           y = logcharges, color = children)) + 
  geom_boxplot() + 
  xlab("Age") + 
  ylab("logcharges") + 
  labs(title = "logcharges vs. Age Categorized by Children", color = 'Children') +
  theme(plot.title = element_text(size = 10))


children.bmi <- ggplot(data, aes(x = bmi, y = logcharges, color = children)) + 
  geom_point(shape = 8) + 
  xlab("BMI") + 
  ylab("logcharges") + 
  labs(title = "logcharges vs. BMI Categorized by Children", color = 'Children') + 
  theme(plot.title = element_text(size = 10))

children.interaction <- annotate_figure(ggarrange(children.age, children.bmi, ncol = 2, nrow = 1),
                                        top = text_grob("Interaction of logcharges by Age and BMI Categorized by Children"))


annotate_figure(ggarrange(sex.interaction, smoker.interaction, region.interaction, children.interaction, ncol = 2, nrow = 2),
                bottom = "Figure 5: Interaction of logcharges by Age and Bmi with Categorical Variables")

set.seed(2020)
trainindex <- sample(c(rep(0, 0.8 * nrow(data)),
                       rep(1, 0.2* nrow(data))))

train <- data[trainindex == 1, ]
test <- data[trainindex == 0, ]

init.model <- lm(formula = logcharges ~ age + bmi + children + sex + smoker + region,  data = train)

summary(init.model)

model.1 <- lm(logcharges ~ age + bmi + smoker + region, data = train) 
model.2 <- lm(logcharges ~ age + bmi + smoker + region + children, data = train) 
model.3 <- lm(logcharges ~ age + bmi + smoker + region + children + sex, data = train) 

anova(model.1, model.2, model.3)

model.1 <- lm(logcharges ~ age + bmi + smoker + region + children, data = train) 
model.2 <- lm(logcharges ~ age + bmi + smoker + region + children + age:smoker, data = train) 
model.3 <- lm(logcharges ~ age + bmi + smoker + region + children + age:smoker + bmi:smoker, data = train) 

anova(model.1, model.2, model.3)

model <- model.3

summary(model)

residual <- data.frame(model$fitted.values, model$residuals)

residual.plot <- ggplot(data=residual, aes(x=model$fitted.values, y = model$residuals)) +
  geom_point(shape = 1) + 
  labs(x= "Fitted Values", y = "Residuals",
       title = "Residuals vs. Fitted Values",
       caption = "Figure 6a: Residual Plot vs. Fitted Values for Final Model") 

model.fittedvalues <- model$fitted.values
model.residuals <- model$residuals
mean.residual <- mean(residual$model.residuals)
sd.residual <- sd(residual$model.residuals)

residual$standardized.residuals <- ((residual$model.residuals - mean.residual) / sd.residual)

normal.qqplot <- ggplot(data = residual, aes(sample = standardized.residuals)) +
  stat_qq(shape = 1, fill = "black") + stat_qq_line(color = "blue") + 
  labs(x="Theoretical Quantiles", y="Standardized Residuals", 
       title="Normal Q-Q Plot", 
       caption="Figure 6b: Normal Q-Q Plot for Final Model")

grid.arrange(residual.plot, normal.qqplot, ncol = 2)

test.prediction <- predict(model, newdata=test, interval="prediction", level=0.95) # test set predictions
train.prediction <- predict(model, newdata=train) # train set predictions
test.logcharges <- test$logcharges

fit.plot <- ggplot(data.frame(test.prediction), aes(x=test.logcharges, y=fit)) +
  geom_point() +
  geom_smooth(aes(color="model"), stat="smooth", method="gam", formula=y~s(x, bs="cs")) +
  geom_line(aes(x=seq(min(test.logcharges), max(test.logcharges), length.out=length(test.logcharges)),
                y=seq(min(test.logcharges), max(test.logcharges), length.out=length(test.logcharges)),
                color="ideal")) + labs(x="Actual", y="Predicted",
       caption="Figure 7: Linear Model Fit of Predicting Log Charges for Potential Beneficiaries") +
  scale_color_manual("linear relation", values=c("red", "blue")) +
  theme(plot.title = element_text(hjust = 0.5), legend.position = c(0.25, 0.8)) + 
  ggtitle("Predicting Log Charges for Potential Beneficiaries") +
  annotate(geom="text", x=10, y=7.5, label=paste("Train RMSE =", 
                                                 round(sqrt(mean((train.prediction - train$logcharges)^2)), 2)), color="red") + 
  annotate(geom="text", x=10, y=7, label=paste("Test RMSE =",
                                               round(sqrt(mean((test.prediction - test$logcharges)^2)), 2)), color="red")

fit.plot


