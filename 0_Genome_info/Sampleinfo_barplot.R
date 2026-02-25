

library(tidyverse)
library(patchwork) 
library(scales)     

data <- read.csv("Sampleinfo.csv", header = TRUE)

data_processed <- data %>%
  mutate(
    across(c(Coverage, Depth, Length, Count, N50, GC), as.numeric)
  ) %>%
  rename(
    Coverage_Percent = Coverage,
    Average_depth = Depth,
    Total_length_Mb = Length,
    GC_Percent = GC
  )

metric_info <- data.frame(
  Metric = c("Coverage_Percent", "Average_depth", "Total_length_Mb", 
             "Count", "N50", "GC_Percent"),
  DisplayName = c("Coverage (%)", "Average Depth (×)", "Total Length (Mb)", 
                  "Contig Count", "N50 (kb)", "GC%"),  # 修改N50单位从bp到kb
  Color = c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "#8c564b")
)

data_long <- data_processed %>%
  pivot_longer(
    cols = c(Coverage_Percent, Average_depth, Total_length_Mb, Count, N50, GC_Percent),
    names_to = "Metric",
    values_to = "Value"
  ) %>%
  left_join(metric_info, by = "Metric") %>%
  mutate(
    PlotValue = ifelse(Metric == "N50", Value / 1000, Value)
  )

data_long$DisplayName <- factor(data_long$DisplayName, 
                                levels = metric_info$DisplayName)

data_long$ID <- factor(data_long$ID, levels = rev(unique(data_processed$ID)))

theme_no_yaxis <- theme(
  axis.text.y = element_blank(),
  axis.ticks.y = element_blank(),
  axis.title.y = element_blank()
)

plot_list <- list()

for (i in 1:6) {
  metric_name <- metric_info$DisplayName[i]
  metric_type <- metric_info$Metric[i]
  
  plot_data <- data_long %>% 
    filter(DisplayName == metric_name)
  
  p <- ggplot(plot_data, aes(x = PlotValue, y = ID)) +
    geom_bar(stat = "identity", fill = metric_info$Color[i], width = 0.7) +
    labs(
      title = metric_name,
      x = metric_name
    ) +
    theme_minimal(base_size = 10) +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 10),
      axis.title.x = element_text(size = 9),
      axis.text.x = element_text(size = 8),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.x = element_blank()
    )
  
  if (metric_type == "N50") {
    max_n50_kb <- max(plot_data$PlotValue, na.rm = TRUE)
    if (max_n50_kb > 500) {
      break_interval <- 100
    } else if (max_n50_kb > 200) {
      break_interval <- 50
    } else if (max_n50_kb > 100) {
      break_interval <- 20
    } else {
      break_interval <- 10
    }
    
    p <- p + 
      scale_x_continuous(
        breaks = seq(0, ceiling(max_n50_kb/break_interval)*break_interval, break_interval),
        labels = function(x) paste0(x, "k"),  
        expand = expansion(mult = c(0, 0.05))  
      )
  } else {
    p <- p + 
      scale_x_continuous(labels = label_number(accuracy = 0.1))
  }
  
  if (i > 1) {
    p <- p + theme_no_yaxis
  } else {
    p <- p + theme(
      axis.text.y = element_text(size = 7),
      axis.title.y = element_blank()
    )
  }
  
  plot_list[[i]] <- p
}

combined_plot <- plot_list[[1]] | plot_list[[2]] | plot_list[[3]] | 
  plot_list[[4]] | plot_list[[5]] | plot_list[[6]]

combined_plot <- combined_plot + 
  plot_annotation(
    title = "Genome Assembly Quality Metrics by Sample",
    subtitle = "Note: N50 values are displayed in kilobases (kb)",
    theme = theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
      plot.subtitle = element_text(hjust = 0.5, size = 10)
    )
  )

print(combined_plot)

final_plot <- combined_plot + 
  plot_layout(widths = c(1.2, 1, 1, 1, 1, 1))  # 第一个图形稍微宽一点，以容纳y轴标签

print(final_plot)

ggsave("Genome_Quality_Metrics_Horizontal_Compact.pdf", final_plot, 
       width = 10, height = 6, device = "pdf")

n50_comparison <- data_long %>%
  filter(Metric == "N50") %>%
  select(ID, Original_N50_bp = Value, N50_kb = PlotValue) %>%
  arrange(desc(N50_kb))

print("N50值转换对比（前10个样本）：")
print(head(n50_comparison, 10))