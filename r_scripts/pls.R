require(networkD3)
library(RMySQL)
library(RColorBrewer)
library(htmlwidgets)
library(pls)
library(psy)
library(sem)
library(dplyr)
library(lavaan)
con<-dbConnect(MySQL(),dbname='StackOverflowDump',host='localhost',port = 3306, password='******',user='root')

class(HolzingerSwineford1939)


crave <- function(model, digits=2) {
  # ig111207
  # computes composite reliability and average variance extracted
  # usage: crave(model)
  # where model is a sem fitted model
  # such as sem.wh.1
  require(sem)
  x <- stdCoef(model, twoheaded=F)
  coeff <- x[,2]
  paths <- as.character(x[,3])
  newl <- strsplit(paths, " <--- ")
  newl <- as.data.frame(newl)
  newl <- t(newl)
  item <- newl[,1]
  LV <- newl[,2]
  
  coeff2 <- coeff^2
  e2 <- 1-coeff2
  
  y <- data.frame(LV, item, coeff, coeff2, e2)
  rownames(y) <- item
  
  cr <- by(y, LV, function(x) sum(x$coeff)^2 / (sum(x$coeff)^2+sum(x$e2)) )
  ave <- by(y, LV, function(x) sum(x$coeff2) / (sum(x$coeff2)+sum(x$e2)) )
  
  z <- data.frame(
    cr=round(as.numeric(cr), digits),
    s1=ifelse(cr<.7,"","*"),
    ave=round(as.numeric(ave), digits),
    s2=ifelse(ave<.5,"","*")
  )  
  
  #print(y,digits)
  #print(z)
  answer <- list(items=y,latent=z)
  answer
}
intrinsic <- dbGetQuery(con,"select f.Learning as x1, f.HelpOthers as x2, f.Enjoyment as x3, f.IntrinsicMotivation as y1 from FormalSurveyResults f, RespondentMeasures r where f.Email = r.Email")
intrinsic <- matrix(intrinsic)
cor_num <- cor(intrinsic)
intText = 'y1 -> x2, y1_x2, NA
           y1 -> x3, y1_x3, NA'
model.kerch <- specifyModel(file = "",text = intText)

int_sem <- sem(model.kerch,cor_num,nrow(intrinsic))

# f.ExternalMotivation as y1, f.IntrojectedMotivation as y2, f.IdentifiedMotivation as y3, f.IntrinsicMotivation as y4, IntegratedMotivation as y5

AllVariables <- dbGetQuery(con,"select f.Learning as x1, f.HelpOthers as x2, f.Enjoyment as x3, f.IdentityConstruction as x4, f.WorkSupport as x5, f.GainReputation as x6, f.GainRecognition as x7, f.Reciprocity as x8, f.VirtualRewards as x9, f.SignalCapability as x10, f.JobProspects as x11, f.PersonalObligation as x12, f.ExternalMotivation as y1, f.IntrojectedMotivation as y2, f.IdentifiedMotivation as y3, f.IntrinsicMotivation as y4, IntegratedMotivation as y5 from FormalSurveyResults f, RespondentMeasures r where f.Email = r.Email")
MotModel <- ' y5 =~ x8 + x12
              y4 =~ x2 + x3 + x1
              y3 =~ x5 + x4
              y2 =~ x7 + x6
              y1 =~ x11 + x10 + x9 '
MotFit <- cfa(MotModel, data=AllVariables, std.lv = TRUE)
sd(AllVariables$x1)
summary(MotFit,fit.measures = TRUE)

# TaskPersistence as y1, CompetenceConstruct as y2, Autonomy as y3, Relatedness as y4
AllVariables <- dbGetQuery(con,"select EnthusiasmForDifficulty as x1, PersitenceForProblems as x2, Competence as x3, ShowCapability as x4, BeMyself as x5, InputsToCommunity as x6, CommunityFriendness as x7, LikeCommunity as x8, TaskPersistence as y1, CompetenceConstruct as y2, Autonomy as y3, Relatedness as y4 from FormalSurveyResults")
MotModel <- ' y1 =~ x1 + x2
y2 =~ x3 + x4
y3 =~ x5 + x6
y4 =~ x7 + x8 '
sd(AllVariables$x8)
MotFit <- cfa(MotModel, data=AllVariables, std.lv = TRUE)
summary(MotFit,fit.measures = TRUE)

IntMotvations <- dbGetQuery(con,"select f.WorkSupport, f.IdentityConstruction from FormalSurveyResults f, RespondentMeasures r where f.Email = r.Email and abs(f.WorkSupport-f.IdentityConstruction) < 3")
box_data = melt(IntMotvations,variable.name = "tag", value.name = "value")
ggplot(box_data,aes(x=box_data$tag,y=value))+geom_boxplot()
cronbach(IntMotvations)

ExtMotvations <- dbGetQuery(con,"select JobProspects, SignalCapability, VirtualRewards from FormalSurveyResults")
cronbach(ExtMotvations)

IntgreMotivations <- dbGetQuery(con,"select f.PersonalObligation, f.Reciprocity from FormalSurveyResults f, RespondentMeasures r ")
cronbach(IntgreMotivations)

IntrMotvations <- dbGetQuery(con,"select GainRecognition, GainReputation from FormalSurveyResults")
cronbach(IntrMotvations)


IdenMotvations <- dbGetQuery(con,"select f.HelpOthers, f.Learning, f.Enjoyment from FormalSurveyResults f, RespondentMeasures r where f.Email = r.Email and abs(f.HelpOthers-f.Enjoyment) < 2 ")
box_data = melt(IdenMotvations,variable.name = "tag", value.name = "value")
ggplot(box_data,aes(x=box_data$tag,y=value))+geom_boxplot()
cronbach(IdenMotvations)

IntrMotvations <- dbGetQuery(con,"select Competence, ShowCapability from FormalSurveyResults")
cronbach(IntrMotvations)

IntrMotvations <- dbGetQuery(con,"select BeMyself, InputsToCommunity from FormalSurveyResults")
cronbach(IntrMotvations)

IntrMotvations <- dbGetQuery(con,"select CommunityFriendness, LikeCommunity from FormalSurveyResults")
cronbach(IntrMotvations)

IdenMotvations <- dbGetQuery(con,"select f.CommunityFriendness, f.LikeCommunity from FormalSurveyResults f, RespondentMeasures r where f.Email = r.Email and r.nAnswers > 0 ")
IntrMotvations <- dbGetQuery(con,"select EnthusiasmForDifficulty, PersitenceForProblems from FormalSurveyResults")
cronbach(IntrMotvations)

con<-dbConnect(MySQL(),dbname='StackOverflowDump',host='localhost',port = 3306, password='891028',user='root')
Y = dbGetQuery(con,"select r.NormalisedActivityEntropy, r.PostRate, r.nAnswers, r.nQuestions, r.nComments from RespondentMeasures r, FormalSurveyResults f where r.AnswerRatio is not NULL and f.Email = r.Email")
YY <- scale(Y)
X = dbGetQuery(con,"select r.Membership, f.EducationMetric, f.AgeMetric, f.ExpMetric, f.Learning, f.HelpOthers, f.Enjoyment, f.PersonalObligation, f.IdentityConstruction, f.WorkSupport, f.GainReputation, f.GainRecognition, f.Reciprocity, f.VirtualRewards, f.SignalCapability, f.JobProspects, f.Competence, f.ShowCapability, f.BeMyself, f.InputsToCommunity, f.CommunityFriendness, f.LikeCommunity, f.EnthusiasmForDifficulty, f.PersitenceForProblems from RespondentMeasures r, FormalSurveyResults f where r.AnswerRatio is not NULL and f.Email = r.Email")
XX <- scale(X)
pls1 <- plsr(YY~XX, validation = "LOO", jackknife = TRUE) # LOO or CV
pls1 <- plsr(YY~XX, ncomp = 3, validation = "LOO", jackknife = TRUE) # LOO or CV
summary(pls1,what = "all")
validationplot(pls1, val.type = "RMSEP")
jack.test(pls1)
predplot(pls1)
coef(pls1)

# motivation and characteristics
X = dbGetQuery(con,"select f.OSSParticipationMetric, log(r.Membership), f.EducationMetric, f.AgeMetric, f.ExpMetric, from RespondentMeasures r, FormalSurveyResults f where r.avgQuestionQuality is not NULL and f.Email = r.Email")
category_metrics = dbGetQuery(con,"select f.Gender as Gender, f.Occupation as Occupation from FormalSurveyResults f, RespondentMeasures r where  r.avgAnswerQuality is not NULL and r.avgQuestionQuality is not NULL and f.Email = r.Email")
X <- data.frame(X,class.ind(category_metrics$Gender),class.ind(category_metrics$Occupation))


# motivation and quality
con<-dbConnect(MySQL(),dbname='StackOverflowDump',host='localhost',port = 3306, password='891028',user='root')
# Y = dbGetQuery(con,"select log(r.avgAnswerQuality+0.5), log(r.avgQuestionQuality+0.5), log(r.percAcceptedAnswer+0.5) from RespondentMeasures r, FormalSurveyResults f where r.AnswerRatio is not NULL and r.avgAnswerQuality is not NULL and r.avgQuestionQuality is not NULL and f.Email = r.Email")
Y = dbGetQuery(con,"select r.avgAnswerQuality, r.avgQuestionQuality, r.percAcceptedAnswer from RespondentMeasures r, FormalSurveyResults f where r.avgAnswerQuality is not NULL and r.avgQuestionQuality is not NULL and f.Email = r.Email")
X = dbGetQuery(con,"select f.OSSParticipationMetric, log(r.Membership), f.EducationMetric, f.AgeMetric, f.ExpMetric, f.Learning, f.HelpOthers, f.Enjoyment, f.PersonalObligation, f.IdentityConstruction, f.WorkSupport, f.GainReputation, f.GainRecognition, f.Reciprocity, f.VirtualRewards, f.SignalCapability, f.JobProspects, f.Competence, f.ShowCapability, f.BeMyself, f.InputsToCommunity, f.CommunityFriendness, f.LikeCommunity from RespondentMeasures r, FormalSurveyResults f where  r.avgAnswerQuality is not NULL and r.avgQuestionQuality is not NULL and f.Email = r.Email")
# X = dbGetQuery(con,"select f.OSSParticipationMetric, log(r.Membership), f.EducationMetric, f.AgeMetric, f.ExpMetric, f.Learning, f.HelpOthers, f.Enjoyment, f.PersonalObligation, f.IdentityConstruction, f.WorkSupport, f.GainReputation, f.GainRecognition, f.Reciprocity, f.VirtualRewards, f.SignalCapability, f.JobProspects, (f.Competence + f.ShowCapability)/2 as Competence, (f.BeMyself + f.InputsToCommunity)/2 as Autonomy, (f.CommunityFriendness + f.LikeCommunity)/2 as Relatedness from RespondentMeasures r, FormalSurveyResults f where r.AnswerRatio is not NULL and r.avgAnswerQuality is not NULL and r.avgQuestionQuality is not NULL and f.Email = r.Email")
category_metrics = dbGetQuery(con,"select f.Gender as Gender, f.Occupation as Occupation from FormalSurveyResults f, RespondentMeasures r where  r.avgAnswerQuality is not NULL and r.avgQuestionQuality is not NULL and f.Email = r.Email")
X <- data.frame(X,class.ind(category_metrics$Gender),class.ind(category_metrics$Occupation))
hist(Y$percAcceptedAnswer)
hist(X$AgeMetric)
XXX <- scale(X)
YYY <- scale(Y)
pls2 <- plsr(YYY~XXX, validation = "LOO", ncomp = 24, jackknife = TRUE)
summary(pls2,what = "all")
validationplot(pls2, val.type = "RMSEP")
jack.test(pls2)

XM = dbGetQuery(con,"select f.OSSParticipationMetric, log(r.Membership), f.EducationMetric, f.AgeMetric, f.ExpMetric, f.ExternalMotivation, f.IntrojectedMotivation, f.IdentifiedMotivation, f.IntegratedMotivation, f.IntrinsicMotivation, (f.Competence + f.ShowCapability)/2 as Competence, (f.BeMyself + f.InputsToCommunity)/2 as Autonomy, (f.CommunityFriendness + f.LikeCommunity)/2 as Relatedness from RespondentMeasures r, FormalSurveyResults f where r.avgAnswerQuality is not NULL and r.avgQuestionQuality is not NULL and f.Email = r.Email")
Y = dbGetQuery(con,"select r.avgAnswerQuality, r.avgQuestionQuality, r.percAcceptedAnswer from RespondentMeasures r, FormalSurveyResults f where r.avgAnswerQuality is not NULL and r.avgQuestionQuality is not NULL and f.Email = r.Email")
category_metrics = dbGetQuery(con,"select f.Gender as Gender, f.Occupation as Occupation from FormalSurveyResults f, RespondentMeasures r where  r.avgAnswerQuality is not NULL and r.avgQuestionQuality is not NULL and f.Email = r.Email")
XM <- data.frame(XM,class.ind(category_metrics$Gender),class.ind(category_metrics$Occupation))
XXM <- scale(XM)
YYM <- scale(Y)
pls2 <- plsr(YYM~XXM, validation = "LOO", jackknife = TRUE)
summary(pls2,what = "all")
jack.test(pls2)

# motivation and efforts
# 如果吧satisfaction 按整体算？
# Y = dbGetQuery(con,"select r.NormalisedActivityEntropy, r.PostRate, log(r.nAnswers+0.5), log(r.nQuestions+0.5), log(r.nComments+0.5), log(r.avgAnswerResponseTime+0.5) from RespondentMeasures r, FormalSurveyResults f where r.AnswerRatio is not NULL and r.avgAnswerResponseTime is not NULL and f.Email = r.Email")
Y = dbGetQuery(con,"select r.NormalisedActivityEntropy, r.PostRate, r.nAnswers, r.nQuestions, r.nComments, log(r.avgAnswerResponseTime) from RespondentMeasures r, FormalSurveyResults f where r.AnswerRatio is not NULL and r.avgAnswerResponseTime is not NULL and f.Email = r.Email")
# X = dbGetQuery(con,"select f.OSSParticipationMetric, log(r.Membership), f.EducationMetric, f.AgeMetric, f.ExpMetric, f.Learning, f.HelpOthers, f.Enjoyment, f.PersonalObligation, f.IdentityConstruction, f.WorkSupport, f.GainReputation, f.GainRecognition, f.Reciprocity, f.VirtualRewards, f.SignalCapability, f.JobProspects, f.Competence, f.ShowCapability, f.BeMyself, f.InputsToCommunity, f.CommunityFriendness, f.LikeCommunity from RespondentMeasures r, FormalSurveyResults f where r.AnswerRatio is not NULL and r.avgAnswerResponseTime is not NULL and f.Email = r.Email")
X = dbGetQuery(con,"select f.OSSParticipationMetric, log(r.Membership), f.EducationMetric, f.AgeMetric, f.ExpMetric, f.ExternalMotivation, f.IntrojectedMotivation, f.IdentifiedMotivation, f.IntegratedMotivation, f.IntrinsicMotivation, (f.Competence + f.ShowCapability)/2 as Competence, (f.BeMyself + f.InputsToCommunity)/2 as Autonomy, (f.CommunityFriendness + f.LikeCommunity)/2 as Relatedness from RespondentMeasures r, FormalSurveyResults f where r.AnswerRatio is not NULL and r.avgAnswerResponseTime is not NULL and f.Email = r.Email")
X = dbGetQuery(con,"select f.OSSParticipationMetric, log(r.Membership), f.EducationMetric, f.AgeMetric, f.ExpMetric, f.Learning, f.HelpOthers, f.Enjoyment, f.PersonalObligation, f.IdentityConstruction, f.WorkSupport, f.GainReputation, f.GainRecognition, f.Reciprocity, f.VirtualRewards, f.SignalCapability, f.JobProspects, (f.Competence + f.ShowCapability)/2 as Competence, (f.BeMyself + f.InputsToCommunity)/2 as Autonomy, (f.CommunityFriendness + f.LikeCommunity)/2 as Relatedness from RespondentMeasures r, FormalSurveyResults f where r.AnswerRatio is not NULL and r.avgAnswerResponseTime is not NULL and f.Email = r.Email")
category_metrics = dbGetQuery(con,"select f.Gender as Gender, f.Occupation as Occupation, (f.EnthusiasmForDifficulty+f.PersitenceForProblems)/2 as EnthusiasmForDifficulty from FormalSurveyResults f, RespondentMeasures r where r.AnswerRatio is not NULL and r.avgAnswerResponseTime is not NULL and f.Email = r.Email")
X <- data.frame(X,class.ind(category_metrics$Gender),class.ind(category_metrics$Occupation))
Y <- data.frame(Y,category_metrics$EnthusiasmForDifficulty)
XX <- scale(X)
YY <- scale(Y)

pls1 <- plsr(YY~XX, validation = "LOO", jackknife = TRUE) # LOO or CV
pls1 <- plsr(YY~XX, ncomp = 22, validation = "LOO", jackknife = TRUE) # LOO or CV
summary(pls1,what = "all")
validationplot(pls1, val.type = "RMSEP")
jack.test(pls1)
predplot(pls1)
coef(pls1)


library(sem)
library(dplyr)

dat <- matrix(rnorm(100), 25, 4) # 25*4 矩阵
dat
colnames(dat) <- c('a', 'b', 'c', 'd') # 分配列名
cor_num <- cor(dat) # 计算相关性矩阵
cor_num
model.kerch <- specifyModel(

  text = '
  a -> b, a_b, NA
  a -> c, a_c, NA
  a -> d, a_d, NA
  b -> d, b_d, NA
  b -> c, b_c, NA
  c -> d, c_d, NA
  a <-> a, a_a, NA
  b <-> b, b_b, NA
  c <-> c, c_c, NA
  d <-> d, d_d, NA
  ')
out_sem <- sem(model.kerch, cor_num, nrow(dat))
coef <- out_sem$coeff
coeff_name <- out_sem$semmod[,1]
summary(out_sem)
pathDiagram(out_sem, edge.labels="values")

oss = dbGetQuery(con,"SELECT WorkSupport from FormalSurveyResults where Occupation = 'Full-time open source developer'")
comp = dbGetQuery(con,"SELECT WorkSupport from FormalSurveyResults where Occupation = 'Company employee'")
self = dbGetQuery(con,"SELECT WorkSupport from FormalSurveyResults where Occupation = 'Self-employed'")
Stud = dbGetQuery(con,"SELECT WorkSupport from FormalSurveyResults where Occupation = 'Student'")
Res = dbGetQuery(con,"SELECT WorkSupport from FormalSurveyResults where Occupation = 'Researcher'")
Unem = dbGetQuery(con,"SELECT WorkSupport from FormalSurveyResults where Occupation = 'Unemployed'")
other = dbGetQuery(con,"SELECT WorkSupport from FormalSurveyResults where Occupation = 'Other (please specify)'")
wilcox.test(oss$WorkSupport, comp$WorkSupport) #***
wilcox.test(oss$WorkSupport, self$WorkSupport) #***
wilcox.test(oss$WorkSupport, Stud$WorkSupport) #***
