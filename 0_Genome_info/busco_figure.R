######################################
# BUSCO summary figure
# @version 4.0.0
# @since BUSCO 2.0.0
######################################

library(ggplot2)

# ==================== CONFIGURE ====================
output_dir <- "./"
output_file <- file.path(output_dir, "busco_figure.png")
my_width <- 20; my_height <- 25; my_unit <- "cm"
my_colors <- c("#F04442", "#F0E442", "#3492C7", "#56B4E9")
my_bar_height <- 0.75
my_title <- "BUSCO Assessment Results"
my_family <- "sans"; my_size_ratio <- 1

# ==================== DATA ====================
my_species <- c(
  '23_42482-SH-XXVIa', '23_42482-SH-XXVIa', '23_42482-SH-XXVIa', '23_42482-SH-XXVIa',
  '02_34453-CH-GD-XXVIb', '02_34453-CH-GD-XXVIb', '02_34453-CH-GD-XXVIb', '02_34453-CH-GD-XXVIb',
  '03_34576-CH-GD-XXVIa', '03_34576-CH-GD-XXVIa', '03_34576-CH-GD-XXVIa', '03_34576-CH-GD-XXVIa',
  '04_35488-CH-GD-XXVIa', '04_35488-CH-GD-XXVIa', '04_35488-CH-GD-XXVIa', '04_35488-CH-GD-XXVIa',
  '05_38369-CH-GD-Mixed', '05_38369-CH-GD-Mixed', '05_38369-CH-GD-Mixed', '05_38369-CH-GD-Mixed',
  '07_40829-CH-GD-XXVIe', '07_40829-CH-GD-XXVIe', '07_40829-CH-GD-XXVIe', '07_40829-CH-GD-XXVIe',
  '08_41351-CH-GD-XXVIe', '08_41351-CH-GD-XXVIe', '08_41351-CH-GD-XXVIe', '08_41351-CH-GD-XXVIe',
  '09_39634-ZC-GD-XXVIc', '09_39634-ZC-GD-XXVIc', '09_39634-ZC-GD-XXVIc', '09_39634-ZC-GD-XXVIc',
  '11_42927-ZC-GD-Mixed', '11_42927-ZC-GD-Mixed', '11_42927-ZC-GD-Mixed', '11_42927-ZC-GD-Mixed',
  '13_24174-ZQ-GD-XXVIa', '13_24174-ZQ-GD-XXVIa', '13_24174-ZQ-GD-XXVIa', '13_24174-ZQ-GD-XXVIa',
  '15_24463-ZQ-GD-XXVIb', '15_24463-ZQ-GD-XXVIb', '15_24463-ZQ-GD-XXVIb', '15_24463-ZQ-GD-XXVIb',
  '20_48455-NX-XXVIb', '20_48455-NX-XXVIb', '20_48455-NX-XXVIb', '20_48455-NX-XXVIb',
  '22_42441-SH-XXVIc', '22_42441-SH-XXVIc', '22_42441-SH-XXVIc', '22_42441-SH-XXVIc',
  '14_24365-ZQ-GD-XXVIa', '14_24365-ZQ-GD-XXVIa', '14_24365-ZQ-GD-XXVIa', '14_24365-ZQ-GD-XXVIa',
  '21_48472-NX-XXVIb', '21_48472-NX-XXVIb', '21_48472-NX-XXVIb', '21_48472-NX-XXVIb',
  '01_33642-CH-GD-XXVIe', '01_33642-CH-GD-XXVIe', '01_33642-CH-GD-XXVIe', '01_33642-CH-GD-XXVIe',
  '06_38389-CH-GD-XXVId', '06_38389-CH-GD-XXVId', '06_38389-CH-GD-XXVId', '06_38389-CH-GD-XXVId',
  '10_39638-ZC-GD-XXVIb', '10_39638-ZC-GD-XXVIb', '10_39638-ZC-GD-XXVIb', '10_39638-ZC-GD-XXVIb',
  '12_53870-ZC-GD-XXVIa', '12_53870-ZC-GD-XXVIa', '12_53870-ZC-GD-XXVIa', '12_53870-ZC-GD-XXVIa',
  '16_42270-ZQ-GD-XXVIc', '16_42270-ZQ-GD-XXVIc', '16_42270-ZQ-GD-XXVIc', '16_42270-ZQ-GD-XXVIc',
  '17_42290-ZQ-GD-XXVIc', '17_42290-ZQ-GD-XXVIc', '17_42290-ZQ-GD-XXVIc', '17_42290-ZQ-GD-XXVIc',
  '18_45015-ZQ-GD-XXVIb', '18_45015-ZQ-GD-XXVIb', '18_45015-ZQ-GD-XXVIb', '18_45015-ZQ-GD-XXVIb',
  '19_24691-HB-XXVId', '19_24691-HB-XXVId', '19_24691-HB-XXVId', '19_24691-HB-XXVId'
)

my_percentage <- c(
  93.5, 0.0, 1.3, 5.2, 95.1, 0.0, 0.4, 4.5, 94.2, 0.0, 0.9, 4.9, 94.8, 0.0, 0.7, 4.5,
  95.1, 0.0, 0.4, 4.5, 90.1, 0.0, 2.7, 7.2, 70.4, 11.4, 7.0, 11.2, 95.1, 0.0, 0.4, 4.5,
  94.8, 0.0, 0.7, 4.5, 87.7, 0.0, 5.2, 7.1, 95.1, 0.0, 0.4, 4.5, 91.7, 0.0, 2.9, 5.4,
  88.8, 0.0, 4.7, 6.5, 92.6, 0.0, 2.0, 5.4, 94.8, 0.0, 0.7, 4.5, 94.4, 0.0, 0.7, 4.9,
  95.1, 0.0, 0.4, 4.5, 95.1, 0.0, 0.4, 4.5, 94.6, 0.0, 0.4, 5.0, 93.5, 1.3, 0.7, 4.5,
  93.5, 1.1, 0.7, 4.7, 95.1, 0.0, 0.4, 4.5, 94.6, 0.0, 0.9, 4.5
)

my_values <- c(
  417, 0, 6, 23, 424, 0, 2, 20, 420, 0, 4, 22, 423, 0, 3, 20, 424, 0, 2, 20,
  402, 0, 12, 32, 314, 51, 31, 50, 424, 0, 2, 20, 423, 0, 3, 20, 391, 0, 23, 32,
  424, 0, 2, 20, 409, 0, 13, 24, 396, 0, 21, 29, 413, 0, 9, 24, 423, 0, 3, 20,
  421, 0, 3, 22, 424, 0, 2, 20, 424, 0, 2, 20, 422, 0, 2, 22, 417, 6, 3, 20,
  417, 5, 3, 21, 424, 0, 2, 20, 422, 0, 4, 20
)

# ==================== PREPARE DATA ====================
# Sort samples by numeric prefix (01,02,...23)
sample_names_unique <- unique(my_species)
sample_num <- as.numeric(gsub("_.*", "", sample_names_unique))
sorted_samples <- sample_names_unique[order(sample_num)]  # ascending
my_species <- factor(my_species, levels = rev(sorted_samples))  # descending for top-to-bottom

# Category order: S (light blue), D (dark blue), F (yellow), M (red)
category <- rep(c("S", "D", "F", "M"), length.out = length(my_species))
category <- factor(category, levels = c("M", "F",  "D", "S" ))
str(category)
df <- data.frame(species = my_species, percentage = my_percentage,
                 values = my_values, category = category)

# ==================== PLOT ====================
labsize <- if (nlevels(my_species) > 10) 0.66 else 1

p <- ggplot(df, aes(x = species, y = percentage, fill = category)) +
  geom_col(position = position_stack(reverse = FALSE), width = my_bar_height) +
  coord_flip() +
  scale_y_continuous(breaks = seq(0, 100, 20), labels = c("0","20","40","60","80","100"),
                     expand = c(0, 0)) +
  scale_fill_manual(values = my_colors,
                    labels = c("Missing (M)",
                               "Fragmented (F)",
                               "Complete (C) and duplicated (D)",
                               "Complete (C) and single-copy (S)")) +
  labs(title = my_title, x = "", y = "\n%BUSCOs") +
  theme_gray(base_size = 8) +
  theme(
    plot.title = element_text(family = my_family, hjust = 0.5, colour = "black",
                              size = rel(2.2) * my_size_ratio, face = "bold"),
    legend.position = "top", legend.title = element_blank(),
    legend.text = element_text(family = my_family, size = rel(1.2) * my_size_ratio),
    panel.background = element_rect(fill = "white", colour = "#FFFFFF"),
    panel.grid = element_blank(),
    axis.text.y = element_text(family = my_family, colour = "black",
                               size = rel(1.66) * my_size_ratio),
    axis.text.x = element_text(family = my_family, colour = "black",
                               size = rel(1.66) * my_size_ratio),
    axis.line = element_line(size = 1 * my_size_ratio, colour = "black"),
    axis.ticks.length = unit(0.4, "cm"),
    axis.ticks.y = element_blank(),
    axis.ticks.x = element_line(colour = "#222222"),
    axis.title.x = element_text(family = my_family, size = rel(1.2) * my_size_ratio)
  ) +
  guides(fill = guide_legend(nrow = 2, byrow = TRUE))

# Add text annotations
for (i in seq_along(levels(my_species))) {
  sp <- levels(my_species)[i]
  vals <- df$values[df$species == sp]
  if (length(vals) == 4) {
    total <- sum(vals)
    label_text <- sprintf("C: %d [S: %d, D: %d], F: %d, M: %d, n: %d",
                          vals[1] + vals[2], vals[1], vals[2], vals[3], vals[4], total)
    p <- p + annotate("text", x = i, y = 3, label = label_text,
                      size = labsize * 4 * my_size_ratio,
                      colour = "black", hjust = 0, family = my_family)
  }
}

# ==================== SAVE ====================
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
ggsave(filename = output_file, plot = p, width = my_width, height = my_height,
       unit = my_unit, dpi = 300)
ggsave(filename = file.path(output_dir, "busco_figure.pdf"), plot = p,
       width = my_width, height = my_height, unit = my_unit, device = cairo_pdf)

message("Done. Figure saved to ", output_file)