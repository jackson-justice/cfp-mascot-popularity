# CFP Mascot Popularity Analysis

This project analyzes the online popularity of College Football Playoff (CFP) mascots during the 2025 season using daily Wikipedia pageview data.

## Research Question
Which CFP mascots generated the most online interest during the 2025 college football season?

## Data Source
- Wikimedia Pageviews API
- Daily pageviews for each mascot’s Wikipedia article
- Date range: August 1 – December 8, 2025

## Methodology
- Requested daily pageview data via the Wikipedia Pageviews REST API
- Parsed JSON responses into tidy R data frames
- Aggregated total and average pageviews by mascot
- Visualized popularity rankings using `ggplot2`

## Key Results
- Mascot popularity did not strictly align with CFP seeding
- Several lower-seeded teams had higher online interest than higher-seeded teams
- The analysis provides a cultural perspective on fan engagement beyond on-field performance

## Tools Used
- R
- httr
- jsonlite
- tidyverse
- ggplot2

## Files
- `cfp_mascots_pageviews.R`: Data collection, processing, and visualization
- `all_mascots_pageviews_2025.csv`: Aggregated pageview data
- `CFP_Mascot_Popularity_Report.pdf`: Summary report and figures
