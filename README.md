# 🎮 Steam Games Data Analysis

> A data analysis capstone project covering the full analytics pipeline — from raw data collection to an interactive Power BI dashboard — based on the Steam gaming platform.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Tools and Technologies](#tools-and-technologies)
- [Project Structure](#project-structure)
- [Dataset](#dataset)
- [Data Collection](#data-collection)
- [Data Cleaning](#data-cleaning)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [SQL Analysis](#sql-analysis)
- [Power BI Dashboard](#power-bi-dashboard)
- [DAX Measures](#dax-measures)
- [Key Insights](#key-insights)
- [How to Run](#how-to-run)
- [Author](#author)

---

## Project Overview

This project demonstrates a complete data analytics workflow applied to Steam's game catalog. The goal is to extract meaningful insights about game pricing, popularity, genres, and publisher activity using a combination of Python, SQL, and Power BI.

**What this project covers:**

- Automated data collection via the Steam API using Python
- Data cleaning, transformation, and feature engineering in Jupyter Notebook
- Structured SQL analysis with PostgreSQL (aggregations, CTEs, window functions)
- Interactive multi-page dashboard built in Power BI with a custom Steam-inspired dark theme

---

## Tools and Technologies

| Category | Tools |
|---|---|
| **Language** | Python 3 |
| **Data Processing** | Pandas, NumPy |
| **Visualization (Python)** | Matplotlib, Seaborn, Plotly |
| **Database** | PostgreSQL |
| **BI & Dashboarding** | Power BI, DAX |
| **Environment** | Jupyter Notebook |

---

## Project Structure

```text
steam_capstone/
│
├── data/
│   ├── raw/
│   │   └── steam_games_raw.csv          # Original collected data
│   ├── processed/
│   │   └── steam_games_cleaned.csv      # Cleaned & enriched dataset
│   └── sql_outputs/                     # Query result exports
│
├── notebooks/
│   └── steam_data_analysis.ipynb        # EDA and analysis notebook
│
├── scripts/
│   └── collect_steam_data.py            # Steam API data collection script
│
├── sql/
│   └── steam_analysis_queries.sql       # All PostgreSQL queries
│
├── dashboard/
│   ├── steam_dashboard.pbix             # Power BI dashboard file
│   ├── steam_neon_powerbi_theme.json    # Custom dark theme
│   ├── steam_background.png             # Dashboard background image
│   └── screenshots/                     # Dashboard preview images
│
├── requirements.txt                     # Python dependencies
├── README.md
└── .gitignore
```

---

## Dataset

The dataset was collected from the Steam platform and contains the following fields:

| Field | Description |
|---|---|
| `name` | Game title |
| `developers` | Development studio(s) |
| `publishers` | Publishing company/companies |
| `release_year` | Year the game was released |
| `final_price` | Current price (USD) |
| `initial_price` | Original price before discounts |
| `discount_pct` | Applied discount percentage |
| `recommendations` | Number of user recommendations |
| `metacritic_score` | Metacritic critic score (0–100) |
| `platforms` | Supported platforms (Windows, Mac, Linux) |
| `genres` | Game genres (may be multiple) |
| `price_category` | Binned price group (Free / Low / Mid / High) |

---

## Data Collection

Data was collected using a custom Python script (`collect_steam_data.py`) that queries the Steam Store API.

The script:
- Fetches game metadata for a list of Steam App IDs
- Handles rate limiting and missing values
- Saves the raw output to `data/raw/steam_games_raw.csv`

> **Note:** Steam API access is free and does not require authentication for public endpoints.

---

## Data Cleaning

Cleaning was performed in Jupyter Notebook. Key steps included:

- **Missing values** — dropped or imputed depending on the column and its importance
- **Data type fixes** — prices converted to float, dates parsed to datetime
- **Outlier handling** — extreme price and recommendation values flagged and reviewed
- **Feature engineering** — new columns created for richer analysis:

| New Column | Description |
|---|---|
| `release_year` | Extracted from release date |
| `game_age` | Years since release (as of current year) |
| `price_category` | Categorical price tier (Free / Low / Mid / High) |
| `genre_count` | Number of genres assigned to a game |
| `is_free` | Boolean flag for free-to-play games |

The cleaned dataset is saved to:

```
data/processed/steam_games_cleaned.csv
```

---

## Exploratory Data Analysis

EDA was conducted in `notebooks/steam_data_analysis.ipynb` using Pandas, Matplotlib, Seaborn, and Plotly.

**Analysis areas covered:**

- **Release trends** — number of games released per year; growth acceleration in recent years
- **Pricing analysis** — distribution of prices; free vs. paid ratio; price categories
- **Recommendations** — distribution and outliers; most-recommended titles
- **Metacritic scores** — score distribution; correlation with recommendations and price
- **Genre analysis** — most common genres; genre combinations; avg price and popularity by genre
- **Platform support** — Windows vs. Mac vs. Linux game availability

---

## SQL Analysis

All SQL queries are in `sql/steam_analysis_queries.sql` and were run using **PostgreSQL**.

**Techniques used:**

| Technique | Purpose |
|---|---|
| Basic aggregations | Total games, avg price, avg score |
| `GROUP BY` + `HAVING` | Genre and publisher summaries |
| `WHERE` filters | Free games, high-rated titles, recent releases |
| `CTE` (Common Table Expressions) | Multi-step calculations |
| `JOIN` | Connecting genre/platform data |
| Window functions (`RANK`, `ROW_NUMBER`) | Ranking games within categories |
| `unnest()` | Splitting multi-value genre arrays into rows |

---

## Power BI Dashboard

The dashboard (`dashboard/steam_dashboard.pbix`) consists of **4 pages** with a custom dark Steam-inspired neon theme.

### Page 1 — Overview

High-level summary of the dataset.

- Total number of games
- Free vs. paid game split
- Average game price
- Total user recommendations
- Games released per year (line/bar chart)
- Games by price category (donut chart)

### Page 2 — Genres Analysis

Deep dive into game genres.

- Top genres by game count
- Average recommendations by genre
- Average price by genre
- Genre summary table (sortable)

### Page 3 — Publishers and Developers

Focus on the companies behind the games.

- Top developers by number of published games
- Top publishers by number of published games
- Top publishers by total user recommendations
- Publisher summary detail table

### Page 4 — Popularity and Games

Individual game performance analysis.

- Top games by total recommendations
- Average recommendations by release year
- Top games by Metacritic score
- Full searchable and sortable games table

---

## DAX Measures

Custom DAX measures used across the dashboard:

```DAX
Total Games = COUNTROWS(steam_games_cleaned)
```

```DAX
Free Games = 
CALCULATE(
    COUNTROWS(steam_games_cleaned),
    steam_games_cleaned[is_free] = TRUE()
)
```

```DAX
Paid Games = 
CALCULATE(
    COUNTROWS(steam_games_cleaned),
    steam_games_cleaned[is_free] = FALSE()
)
```

```DAX
Average Price = AVERAGE(steam_games_cleaned[final_price])
```

```DAX
Total Recommendations = SUM(steam_games_cleaned[recommendations])
```

```DAX
Average Recommendations = AVERAGE(steam_games_cleaned[recommendations])
```

```DAX
% Free Games = 
DIVIDE(
    [Free Games],
    [Total Games],
    0
)
```

```DAX
High Rated Games = 
CALCULATE(
    COUNTROWS(steam_games_cleaned),
    steam_games_cleaned[metacritic_score] >= 80
)
```

---

## Key Insights

1. **Paid games dominate** — the majority of games on Steam have a price, though free-to-play titles receive disproportionately high recommendation counts due to lower access barriers.
2. **Explosive growth in recent years** — the number of new Steam releases has grown significantly year-over-year, reflecting lower barriers to indie publishing.
3. **Recommendation distribution is heavily skewed** — a small number of blockbuster titles account for a large share of total recommendations.
4. **Free games outperform paid in popularity** — without a purchase barrier, free games accumulate recommendations faster and from a wider audience.
5. **Genre concentration** — a handful of genres (Action, Indie, Adventure) account for the majority of titles, while niche genres often carry higher average prices.
6. **Publisher and developer concentration** — a relatively small number of studios are responsible for a large portion of total games and recommendations on the platform.
7. **Price and quality weakly correlated** — higher-priced games do not consistently achieve better Metacritic scores or more recommendations.

---

## How to Run

### 1. Clone the repository

```bash
git clone <your-repository-link>
cd steam_capstone
```

### 2. Install Python dependencies

```bash
pip install -r requirements.txt
```

### 3. Collect the data

```bash
python scripts/collect_steam_data.py
```

> This will generate `data/raw/steam_games_raw.csv`.

### 4. Run the analysis notebook

Open in Jupyter:

```bash
jupyter notebook notebooks/steam_data_analysis.ipynb
```

Run all cells to reproduce the cleaning steps and EDA visualizations.

### 5. Run SQL queries

Connect to your PostgreSQL instance and execute:

```
sql/steam_analysis_queries.sql
```

> Import the cleaned CSV into a table named `steam_games_cleaned` before running queries.

### 6. Open the Power BI dashboard

Open the file in Power BI Desktop:

```
dashboard/steam_dashboard.pbix
```

Make sure to refresh the data source path if needed.

---

## Author

**Arman Zhetessov**  
Data Analysis Capstone Project

---

*Built with Python · PostgreSQL · Power BI*
