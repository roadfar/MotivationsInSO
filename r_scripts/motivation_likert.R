require(likert)
library(reshape2)
library(ggplot2)
library(legend)
library(RMySQL)
library(riverplot)
library(reshape2)
# num_core_learners
a <- c(1,2,3,4,5,6)
a[1:3]
motivations = read.csv("******",sep = ",",header = T)
# motivations = melt(motivations,id.var = "group",variable.name = "tag", value.name = "value")
motivation_processed = data.frame(lapply(motivations[3:14],factor,ordered = TRUE,levels=c("Strongly disagree","Disagree","Neither agree nor disagree","Agree","Strongly agree")))
motivation_processed
names(motivation_processed) = c(
  "To learn and improve programming skills",
  "To help others",
  "For enjoyment",
  "Feeling personal obligation to contribute to the community",
  "To construct identity in the community",
  "To provide support for work",
  "To enhance reputation in the community",
  "To gain recognition from peers",
  "To return the favor to the community",
  "To earn virtual rewards",
  "To signal capability to potential employers",
  "To improve future job prospects"
)
plot(likert(motivation_processed),grouping = motivations$group)+ theme(legend.text = element_text(size = 13), legend.title = element_text(size = 14))+theme(strip.text = element_text(size = 12), axis.text = element_text(size = 13), axis.title = element_text(size = 14))
