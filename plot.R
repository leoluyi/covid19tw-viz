library(magrittr)
library(readr)
library(tidyverse)
library(RColorBrewer)
library(ggthemes)

# Data manipulation -------------------------------------------------------

data <- read_csv(
  "dataset/covid19_modified_twdata_20210528.csv",
  col_types = cols(
    date = col_date(format = "%Y-%m-%d"),
    released_date = col_date(format = "%Y-%m-%d")
  )) %>%
  rename("confirmed_date" = "date")


data <- data %>%
  mutate(
    days_diff = as.integer(confirmed_date - released_date),
    days_delay = as.integer(released_date - confirmed_date),
  ) %>% 
  mutate(
    days_diff_d = fct_rev(factor(days_diff, ordered = TRUE)),
    days_delay_d = factor(days_delay, ordered = TRUE)
  )


# Plots -------------------------------------------------------------------

my_theme <-
  theme_wsj(base_family = NULL, title_family = NULL, base_size = 12) +
  theme(
    text = element_text(family = "Noto Sans CJK TC"),  # MacOS only
    plot.title = element_text(size = 18, face = "bold"),
    plot.subtitle = element_text(size = 14, face = "bold"),
    legend.title = element_text(size = 12),
    legend.position = "top",
    legend.justification = "left",
    axis.text = element_text(size = 10, face = "plain"),
    plot.caption = element_text(size = 8, face = "plain")
  )

old_theme <- theme_set(my_theme)

p1 <- data %>%
  ggplot(mapping = aes(x=confirmed_date, y=diff_n, fill=days_delay)) +
  geom_bar(
    stat = "identity",
    colour="white",
    position = position_stack(reverse = TRUE),
    alpha = 0.95
  ) +
  scale_fill_gradientn(
    name = "公布日\n為確診後(n)天",
    colors = c(
      "gray30",
      rev(colorRampPalette(brewer.pal(n = 9, name = "RdYlBu"))(length(unique(data$days_delay)-1)))
    )
  ) +
  scale_x_date(
    expand            = c(0,0),     # remove excess x-axis space before and after case bars
    date_breaks       = "day",      # date labels and major vertical grid-lines appear
    date_minor_breaks = "day",      # minor vertical lines appear
    date_labels       = "%d\n%b"    # date labels format
  ) +
  scale_y_continuous(
    breaks = scales::breaks_width(100),
    minor_breaks = scales::breaks_width(50)
  ) +
  ggtitle("COVID-19 本土確診病例校正回歸情形 (2021)",
          subtitle = "確診人數 (依確診日)") +
  xlab("確診日") + ylab(NULL) +
  labs(caption=str_c("Dataset credit: Jeremy Liu", "Plot by: leoluyi", sep = "\n"))
p1

p2 <- data %>%
  ggplot(mapping = aes(x=confirmed_date, y=diff_n, fill=days_delay_d)) +
  geom_bar(
    stat = "identity",
    colour="white",
    position = position_stack(reverse = TRUE),
    alpha = 0.95
  ) +
  scale_fill_manual(
    name = "公布日\n為確診後(n)天",
    values = c(
      "gray30",
      rev(colorRampPalette(brewer.pal(n = 9, name = "RdYlBu"))(nlevels(data$days_delay_d)-1))
    )
  ) +
  scale_x_date(
    expand            = c(0,0),     # remove excess x-axis space before and after case bars
    date_breaks       = "day",      # date labels and major vertical grid-lines appear
    date_minor_breaks = "day",      # minor vertical lines appear
    date_labels       = "%d\n%b"    # date labels format
  ) +
  scale_y_continuous(
    breaks = scales::breaks_width(100),
    minor_breaks = scales::breaks_width(50)
  ) +
  ggtitle("COVID-19 本土確診病例校正回歸情形 (2021)",
          subtitle = "確診人數 (依確診日)") +
  xlab("確診日") + ylab(NULL) +
  labs(caption=str_c("Dataset credit: Jeremy Liu", "Plot by: leoluyi", sep = "\n")) +
  guides(fill = guide_legend(ncol = 7, byrow=TRUE))
p2

p3 <- data %>%
  ggplot(mapping = aes(x=released_date, y=diff_n, fill=days_diff_d)) +
  geom_bar(
    stat = "identity",
    colour = "white",
    position = position_stack(reverse = TRUE),
    alpha = 0.95
  ) +
  scale_fill_manual(
    name = "確診日\n為公布日(n)天前",
    # values = c("gray26", viridis(nlevels(data$days_diff_d)-1))
    values = c(
      "gray30",
      rev(colorRampPalette(brewer.pal(n = 9, name = "RdYlBu"))(nlevels(data$days_diff_d)-1))
    )
  ) +
  scale_x_date(
    expand            = c(0,0),
    date_breaks       = "day",
    date_minor_breaks = "day",
    date_labels       = "%d\n%b") +
  scale_y_continuous(
    breaks = scales::breaks_width(100),
    minor_breaks = scales::breaks_width(50)
  ) +
  ggtitle("COVID-19 本土確診病例校正回歸情形 (2021)",
          subtitle = "確診人數 (依公布日)") +
  xlab("公布日") + ylab(NULL) +
  labs(caption=str_c("Dataset credit: Jeremy Liu", "Plot by: leoluyi", sep = "\n")) +
  guides(fill = guide_legend(ncol = 7, byrow=TRUE))
p3

ggsave("img/p1.png", p1, width = 8, height = 6)
ggsave("img/p2.png", p2, width = 8, height = 6)
ggsave("img/p3.png", p3, width = 8, height = 6)

## References
# https://epirhandbook.com/epidemic-curves.html
# https://www.datanovia.com/en/blog/top-r-color-palettes-to-know-for-great-data-visualization

