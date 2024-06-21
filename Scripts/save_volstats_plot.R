# Calculate heart volumes from ANTs labelStats function
# Author: Rachel A. Roston, Ph.D.
# Date: 2024-03-15

remove(list = ls())
gc()

library(ANTsR)
library(ANTsRCore)
library(viridis)
library(stringr)
library(ggplot2)

experiments = c("Heart173",
                "Heart133",
                "Heart116",
                "Heart51",
                "Heart73",
                "Heart85",
                "Rostrum120")

addvols = c(19,20,50,51) # labels to combine into new column (e.g., TotalHeart is c(19,20,50,51))
addvols.name = "TotalHeart" # name of new column (e.g. "TotalHeart")
dir.vol.results = "/SimMorph/Results/OrganVolumes/"

wd = "/SimMorph/Results/OrganVolumes/labelStats/"
setwd(wd)

for(j in 1:length(experiments)){
  files = dir(paste0(wd, experiments[j]), full.names = TRUE)
  seg.stats.exp = list()
  for(i in 1:length(files)) {seg.stats.exp[[i]] = read.csv(files[i])}
  subjects = lapply(str_split(files, "/"), "[", 12)
  subjects = gsub("_labelStats.csv", "", subjects)
  names(seg.stats.exp) <- subjects

  exp.vol.data = matrix(nrow = length(seg.stats.exp), ncol = length(seg.stats.exp[[1]]$Volume))

  for(i in 1:length(seg.stats.exp)){
    exp.vol.data[i,] = seg.stats.exp[[i]]$Volume
  }
  exp.vol.data = as.data.frame(exp.vol.data, row.names = names(seg.stats.exp))
  colnames(exp.vol.data) <- paste0("Label_", seg.stats.exp[[1]]$LabelValue)
  
  exp.vol.data[,addvols.name] <- exp.vol.data[addvols[1]]
  for(i in 2:length(addvols)){
    exp.vol.data[,addvols.name] = exp.vol.data[, addvols.name] + exp.vol.data[addvols[i]]
  }
  
  write.csv(exp.vol.data, paste0(dir.vol.results, "/", experiments[j], "_labelVols.csv"))
  
}


# Make plots
experiments = c("Heart51",
                "Heart73",
                "Heart85",
                "baseline",
                "Heart116",
                "Heart133",
                "Heart173")
labelNames = read.csv("/SimMorph/ProjectDesign/komp_label_conversion.csv")



vols = list()
for(i in 1:length(experiments)){
  vols[[i]] = read.csv(paste0(dir.vol.results, experiments[i], "_labelVols.csv"))
}
names(vols) <- experiments


# Heart volume violin plot
heartvols = data.frame()
for(i in 1:length(vols)){
  TotalHeart = vols[[i]]$TotalHeart
  exp = rep(names(vols[i]), times = length(TotalHeart))
  individual = vols[[i]][,1]
  tmp = data.frame(exp, TotalHeart, individual)
  heartvols = rbind(heartvols, tmp)
}

scalefactors = data.frame(experiments, ScaleFactor = c("~51%", "~73%", "~85%", "100%", "~116%", "~133%",  "~173%"))
ScaleFactor = vector()
for(i in 1:length(heartvols$exp)){
  ScaleFactor[i] = scalefactors$ScaleFactor[which(heartvols$exp[i] == scalefactors$experiments)]
}
ScaleFactor = ordered(as.factor(ScaleFactor), levels = c("~51%", "~73%", "~85%", "100%", "~116%", "~133%", "~173%"))
heartvols$ScaleFactor = ScaleFactor

for(i in 1:nrow(heartvols)){
  tmp = gsub(paste0("_", heartvols$exp[i]), "", heartvols$individual[i])
  heartvols$ID[i] = tmp
}

meanheartvols = as.data.frame(tapply(heartvols$TotalHeart, heartvols$ScaleFactor, mean))
colnames(meanheartvols) <- "mean"
actualvols = paste0(round(meanheartvols[,1]/meanheartvols[4,1] * 100, 0), "%")
logmean = log(meanheartvols$mean)
meanheartvols = data.frame(meanheartvols, logmean, actualvols, scalefactors)


# Option1
p <- ggplot(heartvols, aes(x=ScaleFactor, y=log(TotalHeart))) + 
  geom_violin()
p + geom_jitter(aes(colour = as.factor(ID)), show.legend = F, shape=16, position=position_jitter(0.2)) + 
  theme_bw() + 
  xlab("Expected % of Original Heart Volume") +
  ylab("log(Heart Volume (voxels))") + 
  theme(text = element_text(size=16)) +
  scale_color_viridis(discrete = T) + 
  geom_text(data = meanheartvols, 
            aes(x=ScaleFactor, 
                y=logmean - 0.3, 
                label = actualvols))


#Option2
p <- ggplot(heartvols, aes(x=ScaleFactor, y=log(TotalHeart))) + 
  geom_violin()
p + geom_jitter(aes(colour = as.factor(ID)), show.legend = F, shape=16, position=position_jitter(0.2)) + 
  theme_bw() + 
  xlab("Expected % of Original Heart Volume") +
  ylab("log(Heart Volume (voxels))") + 
  theme(text = element_text(size=18)) +
  scale_color_viridis(discrete = T) + 
  geom_label(data = meanheartvols, 
             aes(x=ScaleFactor, 
                 y=logmean-0.3, 
                 label = actualvols))
