# Violin plot of heart volumes
# Author: Rachel A. Roston, Ph.D.


#Setup
library(viridis)
library(stringr)
library(ggplot2)

source("./Scripts/SimMorph_setup_variables.R")
dir.vol.results = "./Results/OrganVolumes"
factorlevels = order(heart.sims[,2])

# Read heart volume results
vols = list()
for(i in 1:length(heart.sims[,1])){
  vols[[i]] = read.csv(paste0(dir.vol.results, "/", heart.sims[i,1], "_labelVols.csv"))
}
names(vols) <- heart.sims[,1]

# Organize data
heartvols = data.frame()
for(i in 1:length(vols)){
  TotalHeart = vols[[i]]$TotalHeart
  simulation = rep(names(vols[i]), times = length(TotalHeart))
  image = vols[[i]][,1]
  tmp = data.frame(simulation, TotalHeart, image)
  heartvols = rbind(heartvols, tmp)
}
heartvols = merge(heartvols, heart.sims)
heartvols$est_heartscale = factor(heartvols$est_heartscale, 
                                  levels = heart.sims[factorlevels, 3])

for(i in 1:nrow(heartvols)){
  tmp = gsub(paste0("_", heartvols$simulation[i]), "", heartvols$image[i])
  heartvols$ID[i] = tmp
}

meanheartvols = as.data.frame(tapply(heartvols$TotalHeart, heartvols$est_heartscale, mean))
colnames(meanheartvols) <- "mean"
actualvols = paste0(round(meanheartvols[,1]/meanheartvols[4,1] * 100, 0), "%")
logmean = log(meanheartvols$mean)
meanheartvols = data.frame(meanheartvols, logmean, actualvols, ScaleFactor = heart.sims[factorlevels,3])

#Plot
p <- ggplot(heartvols, aes(x=est_heartscale, y=log(TotalHeart))) + 
  geom_violin()
p + geom_jitter(aes(colour = as.factor(ID)), show.legend = F, shape=16, position=position_jitter(0.2)) + 
  theme_bw() + 
  xlab("Expected % of Original Heart Volume") +
  ylab("log(Heart Volume (voxels))") + 
  theme(text = element_text(size=16)) +
  scale_color_viridis(discrete = T) +
  geom_label(data = meanheartvols, 
            aes(x=ScaleFactor, 
                y=logmean - 0.3, 
                label = actualvols))