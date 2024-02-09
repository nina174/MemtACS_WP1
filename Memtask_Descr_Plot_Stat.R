################################################################################
########################### Memtacs WP1 ########################################
################## behavioral analyses EEG Paper################################
################################################################################

library(tidyverse)
library(ggplot2)
library(ggdist)
library(psych)
library(tidyr)
library(lsr)

setwd("...")

memtask = read.delim("TomOut_WP1_OGYG_EEGincl.dat", sep = ";", skip = 1)

memtask$grp = factor(ifelse(grepl("OG", memtask$ID), "OA", "YA"))

memtask = memtask[,c(1,ncol(memtask),3:ncol(memtask)-1)] # rearrange columns

colour_list <- c("#005191", "#E59200") #UMG colours in HEX

########################## Descriptives ########################################

mt = memtask[,c(1:8, 10:13, 15:18, 21:24, 33:36, 39:42, 51:54)]
mt$hit_all_n = mt$retr14rOrd_1.96_hit_N + mt$retr25rOrd_1.96_hit_N
mt$hitrate_all = mt$hit_all_n/48
mt$fa_all_n = mt$retr14wOrd_1.96_falarm_N + mt$retr25wOrd_1.96_falarm_N
mt$fa_rate_all = mt$fa_all_n/48
HR_adj = (mt$hit_all_n + 0.5)/49 #loglinear approach (Hautus, 1995; aus Stanislaw & Todorov (1999)) 
FA_adj = (mt$fa_all_n + 0.5)/49  # add 0.5 to both the number of hits and the number of false alarms, and add 1 to both the number of signal trials and the number of noise trials 
mt$dprime = qnorm(HR_adj) - qnorm(FA_adj)
mt$resp_bias = (mt$hit_all_n+mt$fa_all_n)/96 

describeBy(mt, mt$grp)

#memtask %>%
#  group_by(grp) %>%
#  summarise_at(vars(CorrAll_1.96_proz, CorrAll_1.96_mean), list(name = mean, sd))



############################# Plots ############################################

ggplot(mt, aes(x = grp, y = CorrAll_1.96_proz, fill = grp)) + 
  ## add half-violin from {ggdist} package
  ggdist::stat_halfeye(
    ## custom bandwidth
    adjust = 0.9,
    ## adjust height
    width = .6,
    ## move geom to the right
    justification = -.2,
    ## remove slab interval
    .width = 0, 
    point_colour = NA
  ) + 
  geom_boxplot(
    width = 0.12,
    position = position_dodge(0),
    ## remove outliers
    outlier.color = NA ## `outlier.shape = NA` works as well
  ) +
  ## add dot plots from {ggdist} package
  ggdist::stat_dots(
    side = "left",
    ## move geom to the left
    justification = 1.1,
    binwidth = 0.9,
    color = NA # no coloured line around dots
  ) +
  ## remove white space on the left
  coord_cartesian(xlim = c(1.2, NA)) +
  ## rename legend title and axes
  labs(x = "Group", y = "Memory performance (% correct)") +
  # change order of ROIs
  scale_x_discrete(limits = c("YA", "OA")) +
  theme_classic() +
  scale_fill_manual(values = colour_list) +
  theme(legend.position = "none")

ggplot(mt, aes(x = grp, y = dprime, fill = grp)) + 
  ## add half-violin from {ggdist} package
  ggdist::stat_halfeye(
    ## custom bandwidth
    adjust = .5,
    ## adjust height
    width = .6,
    ## move geom to the right
    justification = -.2,
    ## remove slab interval
    .width = 0, 
    point_colour = NA
  ) + 
  geom_boxplot(
    width = 0.12,
    position = position_dodge(0),
    ## remove outliers
    outlier.color = NA ## `outlier.shape = NA` works as well
  ) +
  ## add dot plots from {ggdist} package
  ggdist::stat_dots(
    side = "left",
    ## move geom to the left
    justification = 1.1,
    binwidth = 0.05,
    color = NA # no coloured line around dots
  ) +
  ## remove white space on the left
  coord_cartesian(xlim = c(1.2, NA)) +
  ## rename legend title and axes
  labs(x = "Group", y = "Memory performance (dprime)") +
  # change order of groups
  scale_x_discrete(limits = c("YA", "OA")) +
  theme_classic() +
  scale_fill_manual(values = colour_list) +
  theme(legend.position = "none")

# plot by picture position
vars <- c("ID", "grp", "Corr14_1.96_proz", "Corr25_1.96_proz")
mt_by_pos <- mt[vars]

mt_by_pos_long <- mt_by_pos %>%
  pivot_longer(
  cols = `Corr14_1.96_proz`:`Corr25_1.96_proz`, 
  names_to = "position",
  values_to = "perc_correct"
  )

ggplot(mt_by_pos_long, aes(x = grp, y = perc_correct, fill = position)) + 
  ## add half-violin from {ggdist} package
  ggdist::stat_halfeye(
    ## custom bandwidth
    adjust = 0.9,
    ## adjust height
    width = .6,
    ## move geom to the right
    justification = -.2,
    ## remove slab interval
    .width = 0,
    point_colour = NA, 
    position = position_dodge(1)
  ) +
  geom_boxplot(
    width = 0.12,
    position = position_dodge(1),
    ## remove outliers
    outlier.color = NA, ## `outlier.shape = NA` works as well
    show.legend = FALSE
  ) +
  ## add dot plots from {ggdist} package
  ggdist::stat_dots(
    side = "left",
    position = "dodge",
    ## move geom to the left
    justification = 1.1,
    binwidth = 0.9,
    color = NA # no coloured line around dots
  ) +
  ## remove white space on the left
  coord_cartesian(xlim = c(1.2, NA)) +
  ## rename legend title and axes
  labs(x = "Group", y = "Memory performance (% correct)") +
  # change order of ROIs
  scale_x_discrete(limits = c("YA", "OA")) +
  theme_classic() +
  scale_fill_manual(values = colour_list) 
  


########################### Statistics #########################################

t.test(CorrAll_1.96_mean ~ grp, data = mt, var.equal = TRUE)
t.test(CorrAll_1.96_proz ~ grp, data = mt, var.equal = TRUE)
cohensD(CorrAll_1.96_mean ~ grp, data = mt)
t.test(Corr14_1.96_proz ~ grp, data = mt, var.equal = TRUE)
t.test(Corr25_1.96_proz ~ grp, data = mt, var.equal = TRUE)
t.test(hitrate_all ~ grp, data = mt, var.equal = TRUE)
t.test(fa_rate_all ~ grp, data = mt, var.equal = TRUE)
t.test(dprime ~ grp, data = mt, var.equal = TRUE)
t.test(resp_bias ~ grp, data = mt, var.equal = TRUE)

mt_by_pos_long2 <- mt_by_pos_long[-c(1,2,3,4),]

t.test(perc_correct ~ position, data = mt_by_pos_long[mt_by_pos_long$grp=="OA",], var.equal = TRUE, paired = TRUE)
t.test(perc_correct ~ position, data = mt_by_pos_long[mt_by_pos_long$grp=="YA",], var.equal = TRUE, paired = TRUE)

mt_by_pos_long %>%
  group_by(grp, position) %>%
  summarise_at(vars(perc_correct), list(name = mean, sd))

