require(likert)
library(reshape2)
library(ggplot2)
library(legend)
library(RMySQL)
library(riverplot)
library(RColorBrewer)
library(nnet)
library(pls)


con<-dbConnect(MySQL(),dbname='StackOverflowDump',host='localhost',port = 3306, password='******',user='root')

# custom colors
display.brewer.all()
display.brewer.all(type = "div")
brewer.pal(6,"GnBu")
mColors = c("#f8766d","#00bfc4","#FEE08B","#00c0f3","#ff6699","#cc99cc")
gradualColors = c("#03549e","#2e75b6","#99bee2","#bdd7ee","#deebf7")
oneColors = c("#00c0f3","#00c0f3","#00c0f3","#00c0f3","#00c0f3")

#mColors = c("#f3d6dc","#fff2cc","#e2f0d9","#deebf7","#d9f0f0","#fbe5d6")


motivations <- read.csv("******",sep = ",", header = T)
motivations <- melt(motivations,variable.name = "Motivation",value.name = "Value")
ggplot(motivations,aes(x=Motivation,y=Value)) + geom_violin(aes(fill=factor(Motivation)))+
  geom_boxplot(aes(fill=factor(Motivation)),varwidth = TRUE,width = 0.07)+
  theme(axis.text = element_text(size = 12))+
  scale_fill_manual(name = "This is my title", values = mColors[1:5]
                    , labels = c("0" = "Foo", "1" = "Bar"))+
  theme(axis.text.x=element_text(angle=50,hjust=0.5,vjust=0.5), axis.title = element_text(size = 12)) +
  theme(legend.position="none")

# MWM test
motivationTypes <- dbGetQuery(con,"select ExternalMotivation, IntrojectedMotivation, IdentifiedMotivation, IntegratedMotivation, IntrinsicMotivation from FormalSurveyResults")
wilcox.test(motivationTypes$ExternalMotivation, motivationTypes$IntrojectedMotivation) #***
wilcox.test(motivationTypes$ExternalMotivation, motivationTypes$IdentifiedMotivation)
wilcox.test(motivationTypes$ExternalMotivation, motivationTypes$IntegratedMotivation) #***
wilcox.test(motivationTypes$ExternalMotivation, motivationTypes$IntrinsicMotivation) #***
wilcox.test(motivationTypes$IntrojectedMotivation, motivationTypes$IdentifiedMotivation) #*
wilcox.test(motivationTypes$IntrojectedMotivation, motivationTypes$IntegratedMotivation) #***
wilcox.test(motivationTypes$IntrojectedMotivation, motivationTypes$IntrinsicMotivation) #***
wilcox.test(motivationTypes$IdentifiedMotivation, motivationTypes$IntegratedMotivation) #***
wilcox.test(motivationTypes$IdentifiedMotivation, motivationTypes$IntrinsicMotivation) #***
wilcox.test(motivationTypes$IntegratedMotivation, motivationTypes$IntrinsicMotivation) #***






motivationTypes$IdentifiedMotivation

mColors = brewer.pal(6,"Pastel2")
con<-dbConnect(MySQL(),dbname='StackOverflowDump',host='localhost',port = 3306, password='******',user='root')
age_data = dbGetQuery(con,"select Age, ExternalMotivation, IntrojectedMotivation, IdentifiedMotivation, IntegratedMotivation, IntrinsicMotivation from FormalSurveyResults")
names(age_data) = c("Age","External motivation","Introjected motivation","Identified motivation","Integrated motivation","Intrinsic motivation")
ages <- melt(age_data,id.vars = c("Age"),variable.name = "Motivation",value.name = "Value")
ages
# ages and motivations
age_data = dbGetQuery(con,"select Age, ExternalMotivation, IntrojectedMotivation, IdentifiedMotivation, IntegratedMotivation, IntrinsicMotivation from FormalSurveyResults")
ggplot(data=ages,aes(x=Motivation,y=Value))+geom_boxplot(aes(fill=Age),outlier.size = 0.5)+scale_color_manual(values = mColors,labels = factor(ages$Age),name = "Age")+scale_fill_manual(values = mColors)+
  stat_summary(fun.y=mean, geom="line", color = "red",linetype="dashed", aes(x=Motivation,group=1))+
  stat_summary(fun.y=mean, geom="point",color = "red") +
  

# dev experiences and motivations
exp_data = dbGetQuery(con,"select DevelopmentExp, ExternalMotivation, IntrojectedMotivation, IdentifiedMotivation, IntegratedMotivation, IntrinsicMotivation from FormalSurveyResults")
names(exp_data) = c("DevelopmentExp","External motivation","Introjected motivation","Identified motivation","Integrated motivation","Intrinsic motivation")
exp <- melt(exp_data,id.vars = c("DevelopmentExp"),variable.name = "Motivation",value.name = "Value")
ggplot(data=exp,aes(x=Motivation,y=Value))+geom_boxplot(aes(fill=DevelopmentExp),outlier.size = 0.5)+scale_color_manual(values = mColors,labels = factor(exp$DevelopmentExp),name = "Development experiences")+scale_fill_manual(values = mColors)+
  stat_summary(fun.y=mean, geom="line", color = "red",linetype="dashed", aes(x=Motivation,group=1))+
  stat_summary(fun.y=mean, geom="point",color = "red")

# edu and motivations
edu_data = dbGetQuery(con,"select Education, ExternalMotivation, IntrojectedMotivation, IdentifiedMotivation, IntegratedMotivation, IntrinsicMotivation from FormalSurveyResults")
names(edu_data) = c("Education","External motivation","Introjected motivation","Identified motivation","Integrated motivation","Intrinsic motivation")
edu <- melt(edu_data,id.vars = c("Education"),variable.name = "Motivation",value.name = "Value")
ggplot(data=edu,aes(x=Motivation,y=Value))+geom_boxplot(aes(fill=Education),outlier.size = 0.5)+scale_color_manual(values = mColors,labels = factor(edu$Education),name = "Education")+scale_fill_manual(values = mColors)+
  stat_summary(fun.y=mean, geom="line", color = "red",linetype="dashed", aes(x=Motivation,group=1))+
  stat_summary(fun.y=mean, geom="point",color = "red")

# use time and motivations

# oss participation and motivations
oss_data = dbGetQuery(con,"select OSSParticipation, ExternalMotivation, IntrojectedMotivation, IdentifiedMotivation, IntegratedMotivation, IntrinsicMotivation from FormalSurveyResults")
names(oss_data) = c("OSSParticipation","External motivation","Introjected motivation","Identified motivation","Integrated motivation","Intrinsic motivation")
oss <- melt(oss_data,id.vars = c("OSSParticipation"),variable.name = "Motivation",value.name = "Value")
oss
ggplot(data=oss,aes(x=Motivation,y=Value))+geom_boxplot(aes(fill=oss$`OSSParticipation`),outlier.size = 0.5)+scale_color_manual(values = mColors,labels = factor(oss$`OSSParticipation`),name = "OSS participation")+scale_fill_manual(values = mColors)+
  stat_summary(fun.y=mean, geom="line", color = "red",linetype="dashed", aes(x=Motivation,group=1))+
  stat_summary(fun.y=mean, geom="point",color = "red")+
  guides(fill=guide_legend(title="OSS participation"))

# reputation and characteristics
rep_data = dbGetQuery(con,"select GainReputation, Age, Education, DevelopmentExp, OSSParticipation from FormalSurveyResults")
rep = melt(rep_data,id.vars = c("GainReputation"),variable.name = "Characteristic",value.name = "Value")
ggplot(rep,aes(x=Value,y=GainReputation,fill=Characteristic))+geom_boxplot()+facet_grid(.~Characteristic,scales="free")

# virtual rewards and characteristics
rep_data = dbGetQuery(con,"select VirtualRewards, Age, Education, DevelopmentExp, OSSParticipation from FormalSurveyResults")
rep = melt(rep_data,id.vars = c("VirtualRewards"),variable.name = "Characteristic",value.name = "Value")
ggplot(rep,aes(x=Value,y=VirtualRewards,fill=Characteristic))+geom_boxplot()+facet_grid(.~Characteristic,scales="free")

# identity and characteristics
rep_data = dbGetQuery(con,"select IdentityConstruction, Age, Education, DevelopmentExp, OSSParticipation from FormalSurveyResults")
rep = melt(rep_data,id.vars = c("IdentityConstruction"),variable.name = "Characteristic",value.name = "Value")
ggplot(rep,aes(x=Value,y=IdentityConstruction,fill=Characteristic))+geom_boxplot()+facet_grid(.~Characteristic,scales="free")


motivations = dbGetQuery(con,"select Learning, HelpOthers, Enjoyment, PersonalObligation, IdentityConstruction, WorkSupport, GainReputation, GainRecognition, Reciprocity, VirtualRewards, SignalCapability, JobProspects from FormalSurveyResults")  
all_motivations = dbGetQuery(con,"select ExternalMotivation, IntrojectedMotivation, IdentifiedMotivation, IntegratedMotivation, IntrinsicMotivation from FormalSurveyResults")
characteristics = dbGetQuery(con,"select EducationMetric, AgeMetric, ExpMetric, OSSParticipationMetric, Membership from FormalSurveyResults")
category_metrics = dbGetQuery(con,"select Gender, Occupation from FormalSurveyResults")
characteristics <- data.frame(characteristics,class.ind(category_metrics$Gender),class.ind(category_metrics$Occupation))
motivations <- scale(motivations)
characteristics <- scale(characteristics)
all_motivations <- scale(all_motivations)
pls2 <- plsr(motivations~characteristics, validation = "LOO", ncomp = 11, jackknife = TRUE)
coef(pls2)
summary(pls2,what = "all")
validationplot(pls2, val.type = "RMSEP")
plot(pls2)
jack.test(pls2) 
predplot(pls2)

pls3 <- plsr(all_motivations~characteristics, validation = "LOO", ncomp = 11, jackknife = TRUE)
summary(pls3,what = "all")
jack.test(pls3)
