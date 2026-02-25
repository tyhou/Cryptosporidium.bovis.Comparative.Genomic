# ==================== Load required packages ====================
library(ggplot2)
library(ggrepel)
library(scatterplot3d)
# If not installed, run: install.packages(c("ggplot2","ggrepel","scatterplot3d"))

# ==================== Read data ====================
# Ensure files exist in working directory or use full path
eigvec <- read.table("23_sample_snp_filter.eigenvec",
                     header = F, stringsAsFactors = F)
eigval <- read.table("23_sample_snp_filter.eigenval",
                     header = F)

# Write formatted eigenvector file (optional)
write.table(eigvec[2:ncol(eigvec)], file = "plink.eigenvector.xls",
            sep = "\t", row.names = F, col.names = T, quote = F)

# ==================== Calculate eigenvalue percentages ====================
pcs <- paste0("PC", 1:nrow(eigval))
percentage <- eigval$V1 / sum(eigval$V1) * 100
eigval_df <- data.frame(PCs = pcs,
                        variance = eigval$V1,
                        proportion = percentage,
                        stringsAsFactors = F)
write.table(eigval_df, file = "plink.eigenvalue.xls",
            sep = "\t", quote = F, row.names = F, col.names = T)

# ==================== Read population info ====================
# File "pca.pop.txt" should contain columns: vcf_id, Source, Subtype
poptable <- read.table("pca.pop.txt", header = T, comment.char = "")

# ==================== Prepare PCA data for plotting ====================
# Take first 4 PCs, second column is sample ID
pca.data <- eigvec[, c(2:6)]
colnames(pca.data) <- c("vcf_id", "PC1", "PC2", "PC3", "PC4")
pca.data <- merge(pca.data, poptable, by = "vcf_id")

# Define colors by Source
cols <- c("ZQ-GD" = "#d53f4d", "HB" = "#524398", "CH-GD" = "#319ad0",
          "ZC-GD" = "#40af35", "SH" = "#c1b120", "NX" = "#525658")

# Assign colors to each row based on Source
pca.data$color <- ifelse(pca.data$Source == "ZQ-GD", "#d53f4d",
                         ifelse(pca.data$Source == "CH-GD", "#319ad0",
                                ifelse(pca.data$Source == "ZC-GD", "#40af35",
                                       ifelse(pca.data$Source == "HB", "#524398",
                                              ifelse(pca.data$Source == "SH", "#c1b120",
                                                     ifelse(pca.data$Source == "NX", "#525658", ""))))))

# Assign pch symbols based on Subtype
pca.data$pch <- ifelse(pca.data$Subtype == "XXVIa", "0",
                       ifelse(pca.data$Subtype == "XXVIb", "1",
                              ifelse(pca.data$Subtype == "XXVIc", "2",
                                     ifelse(pca.data$Subtype == "XXVId", "3",
                                            ifelse(pca.data$Subtype == "XXVIe", "4",
                                                   ifelse(pca.data$Subtype == "Mixed", "5", ""))))))

# ==================== 3D PCA plot ====================
library(scatterplot3d)
# Set viewing angle and save to PDF
pdf(file = "23_sample_3d_pca.pdf", width = 5, height = 5)
scatterplot3d(pca.data$PC1, pca.data$PC2, pca.data$PC3,
              color = pca.data$color,
              angle = 10,
              cex.symbols = 1.5,
              cex.axis = 0.5,
              lwd = 2,
              pch = as.numeric(pca.data$pch),
              xlab = "PC1 (16.4%)",
              ylab = "PC2 (12.5%)",
              zlab = "PC3 (10.7%)")
dev.off()