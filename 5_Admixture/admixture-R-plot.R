
infile <- "K4"  # prefix for output files (change per K)

# Read Q matrix
tbl <- read.table("admixture_output.4.Q")
colnames(tbl) <- c("strain", paste0("Population", 1:(ncol(tbl)-1)))

library(ggplot2)
library(reshape2)
library(ggsci)

# Read population and label info
pop <- read.table("pop.txt", header=F, stringsAsFactors=F)
label <- read.table("label.txt", header=F, stringsAsFactors=F)

colnames(pop) <- c("strain", "pop")
colnames(label) <- c("strain", "label")

# Merge data
tem <- merge(tbl, pop, by="strain", all.x=TRUE)
tbl <- merge(label, tem, by="strain", all.x=TRUE)

# Order samples as in pop.txt (reverse for plot)
tbl <- tbl[order(factor(tbl$strain, levels=pop$strain)), ]
tbl$strain <- factor(tbl$strain, levels=rev(pop$strain))

# Reshape to long format
tbl_no_id <- tbl[, -1]  # remove strain
data_long <- melt(tbl_no_id, id.vars=c("label","pop"), 
                  variable.name="Population", value.name="Ancestry")

# Generate random colors from ggsci palettes
palettes <- unique(c(
  pal_npg("nrc")(10), pal_aaas("default")(10), pal_nejm("default")(8),
  pal_lancet("lanonc")(9), pal_jama("default")(7), pal_jco("default")(10),
  pal_ucscgb("default")(26), pal_d3("category10")(10), pal_locuszoom("default")(7),
  pal_igv("default")(51), pal_uchicago("default")(9), pal_startrek("uniform")(7),
  pal_tron("legacy")(7), pal_futurama("planetexpress")(12), 
  pal_rickandmorty("schwifty")(12), pal_simpsons("springfield")(16),
  pal_gsea("default")(12)
))
set.seed(1234567)
col_list <- sample(palettes, ncol(tbl_no_id)-2, replace=FALSE)

# Set label factor order for plotting
data_long$label <- factor(data_long$label, levels=rev(unique(data_long$label)))

# Plot
p <- ggplot(data_long, aes(x=Ancestry, y=label, fill=Population)) +
  geom_bar(stat='identity', position='fill', width=1) +
  scale_fill_manual(values=col_list) +
  scale_x_continuous(expand=c(0,0)) +
  theme(axis.text.y=element_text(size=10, vjust=0.5, hjust=1))

# Save output
pdf(paste0(infile, ".pdf"), width=0.2*nrow(tbl), height=8.27)
print(p)
dev.off()

ggsave(paste0(infile, ".png"), p, width=0.2*nrow(tbl), height=8.27, dpi=300)