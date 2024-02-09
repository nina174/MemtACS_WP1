library(ggplot2)
library(tidyr)

setwd("...")

mi_OG = read.delim("sig_mi_YG.csv", sep = ",")
mi_OG$id = as.factor(1:nrow(mi_OG))


#pivot the data frame into a long format
mi_OG_long <- mi_OG %>% pivot_longer(cols=c('mi_pic_1', 'mi_pic_2', 'mi_pic_4', 'mi_pic_5'),
                               names_to='picture_position',
                               values_to='mi')

ggplot(data = mi_OG_long, aes(x = picture_position, y = mi, group = id, color = id)) +
  geom_point(alpha=0.3) + #individual data points
  geom_line(alpha = 0.3) + #connect individual data points with a line
  stat_summary(aes(group = 1), geom = "point", fun.y = mean,
                 shape = 17, size = 3) + # add symbol for mean at each picture position
  stat_smooth(aes(group = 1), method = "lm", se = TRUE) +
  #scale_y_continuous(limits = c(0.0196, 0.0208), breaks = seq(0.0196, 0.0208, by = 0.0002)) +
  theme_classic() +
  theme(legend.position = "none")


mi_OG = read.delim("sig_mi_OG.csv", sep = ",")
mi_OG$id = as.factor(1:nrow(mi_OG))

#pivot the data frame into a long format
mi_OG_long <- mi_OG %>% pivot_longer(cols=c('mi_pic_1', 'mi_pic_2', 'mi_pic_4', 'mi_pic_5'),
                                     names_to='picture_position',
                                     values_to='mi')

ggplot(data = mi_OG_long, aes(x = picture_position, y = mi, group = id, color = id)) +
  geom_point(alpha=0.3) + #individual data points
  geom_line(alpha = 0.3) + #connect individual data points with a line
  stat_summary(aes(group = 1), geom = "point", fun.y = mean,
               shape = 17, size = 3) + # add symbol for mean at each picture position
  stat_smooth(aes(group = 1), method = "loess", se = TRUE) +
  #scale_y_continuous(limits = c(0.0196, 0.0208), breaks = seq(0.0196, 0.0208, by = 0.0002)) +
  theme_classic() +
  theme(legend.position = "none")

