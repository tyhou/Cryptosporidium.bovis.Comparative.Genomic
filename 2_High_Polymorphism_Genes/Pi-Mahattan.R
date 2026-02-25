library(dplyr)
library(ggplot2)
library(patchwork)
setwd("D:/Genome-seq/Cbovis-25-04-11/0_Github_upload/2_HighPolymorphismGenes/")
data <- read.csv("MF_DnaSPResults_check_gp60.csv",header = T,sep = ",",check.names = F)

filtered_data <- data[data$Pi != 0 & !is.na(data$Pi), ]
gene <- filtered_data$Datafile
chr <- filtered_data$chr
gene_position <- filtered_data$No
Pi <- filtered_data$Pi

cutoff_Pi <- mean(Pi) + 1*sd(Pi)

df <- data.frame(gene,chr,gene_position,Pi)
cutoff_df <- subset(df,Pi > cutoff_Pi)
write.csv(cutoff_df,file = "cutoff_genes.csv")
write.table(cutoff_df$gene,quote = F,row.names = F,col.names = F,file = "cutoff_genes.txt")

df$color[df$chr %in% c("Chr1","Chr3","Chr5","Chr7")] <- "gray"
df$color[df$chr %in% c("Chr2","Chr4","Chr6","Chr8")] <- "gray40"

X_axis <-  df %>% group_by(chr) %>% summarize(center=( max(gene_position) + min(gene_position) ) / 2 )

p1 <- ggplot(df,aes(x=gene_position,y=Pi,color=color))+
  theme_bw() +
  theme(plot.title = element_text(size = 20, face = "bold",hjust = 0.5))+
  theme(
    legend.position="none",
    panel.border = element_blank(),
    axis.line.y = element_line(),
    axis.line.x = element_blank(),
    axis.text.y = element_text(size = 14,color = "black"),
    axis.text.x = element_blank(),
    axis.ticks.x= element_blank(),
    axis.title.x = element_text(size = 14),
    axis.title.y = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
  )+
  geom_point(alpha=0.8, size=2) +
  scale_color_manual(values = c("grey70", "grey40","red")) +
  scale_x_continuous(expand = c(0.01,0.01), label = X_axis$chr, breaks= X_axis$center ) +
  scale_y_continuous(limits = c(0.24,0.26),breaks = seq(0.24,0.26, by = 0.01))+
  labs(x="",y="Nucleotide diversity (Pi)")+
  geom_hline(yintercept = cutoff_Pi,colour = "red", size= 1,lty="dashed")

p1

p2 <- ggplot(df,aes(x=gene_position,y=Pi,color=color))+
  theme_bw() +
  theme(plot.title = element_text(size = 20, face = "bold",hjust = 0.5))+
  theme(
    legend.position="none",
    panel.border = element_blank(),
    axis.line.y = element_line(),
    axis.line.x = element_line(),
    axis.text = element_text(size = 14,color = "black"),
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
  )+
  geom_point(alpha=0.8, size=2) +
  scale_color_manual(values = c("grey70", "grey40","red")) +
  scale_x_continuous(expand = c(0.01,0.01), label = X_axis$chr, breaks= X_axis$center ) +
  scale_y_continuous(limits = c(0,0.04),breaks = seq(0, 0.04, by = 0.01))+
  labs(x="",y="Nucleotide diversity (Pi)")+
  geom_hline(yintercept = cutoff_Pi,colour = "red", size= 1,lty="dashed")

p2

library(patchwork)

p_combine <- p1/p2 + plot_layout(guides = "collect",heights = c(1, 2))
p_combine
ggsave("Pi.pdf",p_combine,device = "pdf",width = 7,height = 4,dpi = 300 )
ggsave("Pi.png",p_combine,device = "png",width = 7,height = 4,dpi = 300 )
