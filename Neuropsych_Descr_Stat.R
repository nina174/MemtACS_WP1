###############################################################################
########################Baseline Descriptives #################################
#############################Memtacs WP1#######################################
###############################################################################

setwd('...')
library(psych)
library(ggplot2)

######Identical Pictures#####
load('IQ/IP/20220714_idp.Rdata')

describe(idp, na.rm = TRUE) 

ggplot(idp, aes(x = "", y = idp_RESP_CORR)) +
  stat_boxplot(geom = "errorbar") + 
  geom_boxplot(outlier.alpha = 0) +
  geom_jitter() +
  theme_classic() +
  theme(panel.grid.minor = element_blank()) 

#####Spot a word#####

load('IQ/SaW/20220714_saw.Rdata')

describe(saw, na.rm = TRUE) 

ggplot(saw, aes(x = "", y = saw_RESP_CORR)) +
  stat_boxplot(geom = "errorbar") + 
  geom_boxplot(outlier.alpha = 0) +
  geom_jitter() +
  theme_classic() +
  theme(panel.grid.minor = element_blank()) 

#####CERAD#####

setwd('Y:/01_Studien/03_MEMTACS/Daten/01_WP1')

library(openxlsx)

cerad <- read.xlsx("CERAD.xlsx")
ids = read.table('subjects_EEGincl.txt', header = TRUE)

nid = nrow(ids)
sub=array(NA, nid)

for (f in 1:(nrow(ids))){ 
  ID = ids[f,] 
  sub[f] = which(cerad[,1]==ID)
}

cerad = cerad[sub, ]

describe(cerad)

#####Others#####

demographics <- read.xlsx("MEMTACS_Data_overview.xlsx", sheet = 2, cols = c(3:5, 12))
demographics = demographics[-1,]
demographics$Geschlecht <- factor(demographics$Geschlecht, label = c("male", "female"))

ids = read.table('subjects_EEGincl.txt', header = TRUE)

nid = nrow(ids)
sub=array(NA, nid)

for (f in 1:(nrow(ids))){ 
  ID = ids[f,] 
  sub[f] = which(demographics[,1]==ID)
}

demographics = demographics[sub, ]
demographics$group = factor(replicate(21,"OG"))

gds <- read.xlsx("MEMTACS_Data_overview.xlsx", sheet = 3, cols = c(3,6))
gds = gds[-1,]

nid = nrow(ids)
sub=array(NA, nid)

for (f in 1:(nrow(ids))){ 
  ID = ids[f,] 
  sub[f] = which(gds[,1]==ID)
}
gds = gds[sub,]
gds$Geriatrische.Depressionsskala = as.numeric(gds$Geriatrische.Depressionsskala)

ds <- read.xlsx("MEMTACS_Data_overview.xlsx", sheet = 4, cols = c(3,6:7))
ds=ds[-1,]
nid = nrow(ids)
sub=array(NA, nid)

for (f in 1:(nrow(ids))){ 
  ID = ids[f,] 
  sub[f] = which(gds[,1]==ID)
}
ds=ds[sub,]
ds$Digigitspan.vorwärts = as.numeric(ds$Digigitspan.vorwärts)
ds$Digitspan.Rückwärts = as.numeric(ds$Digitspan.Rückwärts)

ehi <- read.xlsx("MEMTACS_Data_overview.xlsx", sheet = 3, cols = c(3,7))
ehi=ehi[-1,]
ehi=ehi[sub,]
ehi$Lateralitätsquotient.nach.Oldfield=as.numeric(ehi$Lateralitätsquotient.nach.Oldfield)

demographics$laterality = ehi$Lateralitätsquotient.nach.Oldfield

yg <- read.xlsx("MEMTACS_Data_overview_YG.xlsx", sheet = 2, cols = c(3:5,12))  
yg=yg[-1,]
yg$Geschlecht <- factor(yg$Geschlecht, label = c("male", "female"))

ids = read.table('Subjects_YG_Memtask_EEGincl.txt', header = TRUE) 
nid = nrow(ids)
sub=array(NA, nid)

for (f in 1:(nrow(ids))){ 
  ID = ids[f,] 
  sub[f] = which(yg[,1]==ID)
}
yg=yg[sub,]
yg$group=factor(replicate(26,"YG"))

ehi = read.xlsx("MEMTACS_Data_overview_YG.xlsx", sheet = 3, cols = c(1:2)) 
ehi=ehi[-1,]
ehi=ehi[sub,]
ehi$Lateralitätsquotient.nach.Oldfield=as.numeric(ehi$Lateralitätsquotient.nach.Oldfield)

yg$laterality=ehi$Lateralitätsquotient.nach.Oldfield

demographics=rbind(demographics,yg)
describeBy(demographics, group = "group")

#statistical comparison of groups

t.test(Alter ~ group, data = demographics, paired = FALSE, var.equal = TRUE) 
t.test(`Ausbildungsdauer.(Jahre)` ~ group, data = demographics, paired = FALSE, var.equal = TRUE)
t.test(laterality ~ group, data = demographics, paired = FALSE, var.equal = TRUE) 
t.test(Geschlecht ~ group, data = demographics, paired = FALSE, var.equal = TRUE) 
chisq.test(demographics$Geschlecht, demographics$group)
