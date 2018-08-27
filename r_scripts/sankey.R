require(networkD3)
library(RMySQL)
library(RColorBrewer)
library(htmlwidgets)

con<-dbConnect(MySQL(),dbname='******',host='localhost',port = 3306, password='******',user='root')
line_num = dbGetQuery(con,"SELECT author_email, SUM(line_num) as sum from commits where line_num < 1000 group by author_email")
summary(line_num$`SUM(line_num)`)

con<-dbConnect(MySQL(),dbname='StackOverflowDump',host='localhost',port = 3306, password='******',user='root')
sankeydata = dbGetQuery(con,"select id, source, target, value from SankeyData where value <> 0 order by source ASC")
sankeydata$id = as.character(c(0,0,0,0,1,1,1,1,1,1,1,2,2,3,3,3,3,4,4,4,5,5,6,6,6,7,7,7,8,8,8,9,9,10,10,10,11,11,11,11,11,12,12,12,12,12))
sankeydata
mode(sankeydata$id)
# Female:1, Male:2, Full-time open source developer: 3, Company employee: 4, Self-employed: 5, Researcher: 6,
# Student: 7, Unemployed: 8, Other (please specify): 9, <1 year: 10, 1~5 years: 11, 6~10 years: 12, >10 years: 13, Never:14, Rarely: 15, Sometimes: 16, Usually: 17, Always: 18

id <- c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17)
names <- c("Female", "Male", "Full-time open source developer", "Company employee", "Self-employed", "Researcher", "Student", "Unemployed", "Other", "<1 year", "1~5 years", "6~10 years", ">10 years", "Never", "Rarely", "Sometimes", "Usually", "Always")
group <- c("a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a","a")
sankeyNodes <- data.frame(id,names,group)
sankeyNodes
sankeyNetwork(Links = sankeydata, Nodes = sankeyNodes, Source = "source", colourScale = JS(
  'd3.scaleOrdinal()  
  .domain(["a","Female", "Male", "Full-time open source developer", "Company employee", "Self-employed", "Researcher", "Student", "Unemployed", "Other", "<1 year", "1~5 years", "6~10 years", ">10 years", "Never", "Rarely", "Sometimes", "Usually", "Always"])
  .range(["#000000","#E5B3E2CD","#E5FDCDAC","#E5CBD5E8","#F4CAE4","#E6F5C9","#FFF2AE","#F1E2CC","#CBD5E8","#F4CAE4","#E6F5C9","#B3E2CD","#FDCDAC","#CBD5E8","#F4CAE4","#E6F5C9","#B3E2CD","#FDCDAC","#CBD5E8"])'), 
  Target = "target", Value = "value", NodeID = "names", LinkGroup = "id", units = "Quads",
  NodeGroup = "group", fontSize = 14, nodeWidth = 20,fontFamily = "Arial")


brewer.pal(6,"Pastel2")
display.brewer.all()

source <- c(0,1,3,4,4)
target <- c(2,2,1,1,0)
value <- c(33,44,66,77,88)
link_group <- as.character(c('a', 'b', 'c', 'd', 'e'))

sankeydata <- data.frame(source,target, value, link_group)
sankeydata
names <- c('a', 'b', 'c', 'd', 'e')
id <- c(0,1,2,3,4)
group <- as.character(c(1,1,2,1,1))

sankeyNodes <- data.frame(names,id,group)
sankeyNodes
sankeyNetwork(Links = sankeydata, Nodes = sankeyNodes, Source = "source", colourScale = JS(
  'd3.scaleOrdinal()  
  .domain(["1","2","a","b","c","d","e"])
  .range(["#aa031a","#333333","#B3E2CD","#FDCDAC","#CBD5E8","#F4CAE4","#E6F5C9"])'), 
  Target = "target", Value = "value", NodeID = "names", LinkGroup = "link_group", units = "Quads",
  NodeGroup = "group", fontSize = 15, nodeWidth = 20,fontFamily = "Arial")

d3Sankey(Links = sankeydata,Nodes = sankeyNodes, Source = "source", Target = "target", Value = "value", NodeID = "names",
         fontsize = 12, nodeWidth = 15,file = "~/Desktop/TestSankey.png")


# CL challenges
con<-dbConnect(MySQL(),dbname='******',host='localhost',port = 3306, password='******',user='root')
sankeydata = dbGetQuery(con,"select source,target,value,linkGroup from SankeyData where value <> 0")
sankeyNodes = dbGetQuery(con, "select id, NodeName, NodeGroup from nodes_map")
sankeydata
sankeyNodes
sn <- sankeyNetwork(Links = sankeydata, Nodes = sankeyNodes, Source = "source", colourScale = JS(
  'd3.scaleOrdinal()  
  .domain(["40","External learner","Core learner","Quality assurance","Popularizing and finding","Platform support","Continuous unsupervised learning","Content quality","Contribution quality","Overwhelming information","Response time","Search","Popularizing learning projects","Contribution attraction","project connections","Offline learning","Repository restriction","Learning feature","Learning curve of git","Informal communication support","Difficult to start","Continuous learning","Continuous maintaining"])
  .range(["#63030e","#e5c3c4","#c6e4c4","#F4CAE4","#b8c5de","#B3E2CD","#f6eec3","#FDCDAC","#CBD5E8","#F4CAE4","#E6F5C9","#FFF2AE","#B3E2CD","#FDCDAC","#CBD5E8","#F4CAE4","#E6F5C9","#FFF2AE","#B3E2CD","#FDCDAC","#CBD5E8","#F4CAE4"])'), 
  Target = "target", Value = "value", NodeID = "NodeName", LinkGroup = "linkGroup", units = "Quads",
  NodeGroup = "NodeGroup", fontSize = 18, nodeWidth = 20,fontFamily = "Arial",iterations = 0,margin = list("right"=100))
sn

onRender(
  sn,
  '
  function(el,x){
  // select all our node text
  var node_text = d3.select(el)
  .selectAll(".node text")
  //and make them match
  //https://github.com/christophergandrud/networkD3/blob/master/inst/htmlwidgets/sankeyNetwork.js#L180-L181
  .attr("x", 6 + x.options.nodeWidth)
  .attr("text-anchor", "start");
  }
 '
)