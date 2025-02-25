# SQL Baseball Analysis Project

## Project Overview
This project involves analyzing baseball pitching data using SQL Server. The dataset consists of game statistics for the Tampa Bay Rays, focusing on pitching performance, at-bat outcomes, and pitch types.

The datasets were cleaned in Excel by:
- Dropping unnecessary columns
- Sorting and filtering records
- Standardizing data formats

The cleaned datasets were then imported into SQL Server for further analysis.

## Datasets Used
- `LastPitchRays.csv` – Contains information on each pitch thrown in an at-bat, including pitch number, batter stance, game location, and pitch outcome.
- `RaysPitchingStats.csv` – Stores detailed pitching statistics, such as pitch type, speed, inning breakdowns, and performance metrics per pitcher.

## SQL Analysis Overview
The SQL queries in this project aim to extract key insights about pitching performance. Below are the main areas of analysis:

### 1. General Data Exploration
- Queries that retrieve and preview the full datasets.
- Basic statistics and summary aggregations.

### 2. At-Bat and Pitch Count Analysis
- Average number of pitches per at-bat for all games.
- Comparison of home vs. away game pitch counts.
- Analysis of left-handed vs. right-handed batters.

### 3. Pitching Performance Metrics
- Calculation of strike percentage per pitcher.
- Most frequently used pitch types in different game situations.
- Pitching trends across innings (e.g., does pitch velocity drop in later innings?).

### 4. Game-Specific Insights
- Breakdown of pitcher effectiveness based on innings.
- Use of window functions to track performance trends per game.
- Aggregated statistics for different matchups.

## Key Insights
- Home games show slightly different pitching trends compared to away games.
- Right-handed batters tend to face more pitches on average than left-handed batters.
- Some pitchers have a higher strike percentage, indicating efficiency.
- Pitch type distribution reveals strategic preferences in different game scenarios.

## How to Use the SQL Queries
1. Import the datasets into Microsoft SQL Server.
2. Run the SQL queries using SSMS (SQL Server Management Studio).
3. Modify and expand the queries to explore further insights.

## Future Enhancements
- Deeper analysis by joining both datasets for more detailed trends.
- Data visualization using Power BI, Tableau, or Python.
- Predictive analytics to forecast pitching effectiveness.

## Contributors
- Abhinav Sharma
- Suggestions & contributions are welcome!
