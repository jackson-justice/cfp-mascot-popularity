# CFP Mascot Popularity (Wikipedia Pageviews API)
# Author: Jackson Justice
# Description: Pulls daily Wikipedia pageview data for CFP mascots and compares
#              online popularity during the 2025 season (Aug 1–Dec 8, 2025).

library(httr)
library(jsonlite)
library(tidyverse)

# -----------------------------
# Settings
# -----------------------------
START_DATE <- "20250801"
END_DATE   <- "20251208"

BASE_URL <- paste0(
  "https://wikimedia.org/api/rest_v1/metrics/pageviews/per-article/",
  "en.wikipedia/all-access/all-agents"
)

# -----------------------------
# Mascots and article titles
# -----------------------------
mascots <- tibble(
  mascot = c(
    "Hoosier",
    "Brutus Buckeye",
    "Uga",
    "The Masked Rider",
    "The Oregon Duck",
    "Tony the Landshark",
    "Reveille",
    "Sooner Schooner",
    "Big Al",
    "Sebastian the Ibis",
    "Leprechaun",
    "Cosmo the Cougar"
  ),
  article = c(
    "Indiana_Hoosiers",
    "Brutus_Buckeye",
    "Uga_(mascot)",
    "The_Masked_Rider",
    "The_Oregon_Duck",
    "Tony_the_Landshark",
    "Reveille_(dog)",
    "Sooner_Schooner",
    "Big_Al_(mascot)",
    "Sebastian_the_Ibis",
    "Notre_Dame_Leprechaun",
    "Cosmo_the_Cougar"
  ),
  seed = 1:12
)

# -----------------------------
# Helper: pull pageviews for one article
# -----------------------------
get_pageviews <- function(mascot_name, article_title,
                          start_date = START_DATE, end_date = END_DATE,
                          base_url = BASE_URL) {
  url <- paste0(base_url, "/", article_title, "/daily/", start_date, "/", end_date)
  resp <- GET(url)
  
  if (status_code(resp) != 200) {
    warning(sprintf("API request failed (%s) for: %s", status_code(resp), mascot_name))
    return(tibble())
  }
  
  json_txt <- content(resp, "text", encoding = "UTF-8")
  json_obj <- fromJSON(json_txt, flatten = TRUE)
  
  if (is.null(json_obj$items)) return(tibble())
  
  as_tibble(json_obj$items) |>
    transmute(
      mascot = mascot_name,
      article = article_title,
      date = as.Date(substr(timestamp, 1, 8), format = "%Y%m%d"),
      views = views
    )
}

# -----------------------------
# Pull data for all mascots
# -----------------------------
pageviews <- mascots |>
  mutate(data = map2(mascot, article, get_pageviews)) |>
  select(-article) |>
  unnest(data, names_sep = "_")

# Save raw daily data
write_csv(pageviews, "2all_mascots_pageviews_2025.csv")

# -----------------------------
# Summarize popularity
# -----------------------------
summary_tbl <- pageviews |>
  group_by(mascot) |>
  summarize(
    total_views = sum(data_views, na.rm = TRUE),
    avg_daily_views = mean(data_views, na.rm = TRUE),
    .groups = "drop"
  ) |>
  left_join(select(mascots, mascot, seed), by = "mascot") |>
  arrange(seed)

write_csv(summary_tbl, "mascot_popularity_summary_2025.csv")

# -----------------------------
# Plot: total views by mascot (colored by seed)
# -----------------------------
summary_tbl |>
  ggplot(aes(x = reorder(mascot, -total_views), y = total_views, fill = factor(seed))) +
  geom_col() +
  labs(
    title = "Popularity of 2025 CFP Mascots (Wikipedia Pageviews)",
    x = NULL,
    y = "Total pageviews (Aug 1–Dec 8, 2025)",
    fill = "CFP Seed"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("cfp_mascot_popularity_2025.png", width = 10, height = 6, dpi = 300)
