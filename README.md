# London Bus Safety Dashboard

A Power BI dashboard about bus safety incidents in London (2015–2018), built from raw data using SQL and DAX.

![Dashboard Overview](screenshots/overview.png)

## About this project

I used real data from TfL (Transport for London) about incidents on London buses. My goal was to answer simple business questions, like:

- How many incidents happen each year?
- Which boroughs have the most incidents?
- What type of incident is most common?
- Which bus routes have the most incidents?
- How do incidents change month by month?

## Tech stack

- **PostgreSQL** — data cleaning, data modeling, and business-question SQL queries
- **Power BI** — data model, DAX measures, and the final dashboard
- **DAX**: `CALCULATE`, `DIVIDE`, `AVERAGEX`, `RANKX`, `DATEADD`, `FILTER`, time intelligence

## Key insights

- **Slip Trip Fall** is the most common incident type overall (30% of all incidents), but **Onboard Injuries** is actually the top incident type in most individual boroughs — showing that the citywide pattern and the local pattern are not always the same.
- **Westminster** has the most reported incidents of any borough, which fits with it being a high-traffic central area.
- Incident numbers show a small increase year over year from 2015 to 2017, with 2018 showing a lower total only because the data stops in September 2018 (a partial year).

## Data model

A simple star schema:
- `fact_incidents` (fact table)
- `dim_borough`, `dim_route`, `dim_date` (dimension tables)

## Repository contents

| File | Description |
|---|---|
| `TFL_Bus_Safety_Dashboard.pbix` | The full Power BI file |
| `sql/business_questions.sql` | 11 SQL queries answering key business questions |
| `screenshots/` | Dashboard page screenshots |

## Dashboard pages

**1. Overview**
Total incidents, top borough, top incident type, incidents by year, incidents by type, and a monthly trend line. Filter by year or borough.

**2. Borough**
Top 10 boroughs by incidents, top 2 incident types per borough, and a map of London.

**3. Route Analysis**
Top 3 routes by incidents in each borough, average incidents per route, and the single busiest route.

**4. Trends**
Month-over-month and year-over-year change over time, and how the mix of incident types changed year by year.

## Problems I found and how I fixed them

Building this dashboard was not always easy. Here are two real problems I found and solved:

**Problem 1: KPI cards showing the same number**

I built KPI cards to show month-over-month and year-over-year change. When I added a Year slicer, both cards started to show the same number, or even a blank number.

I found the reason: my DAX measures used `DATEADD` on the date column, but the slicer filtered a different column (Year). This created a conflict, and the measures could not calculate correctly.

I tried `REMOVEFILTERS` to fix it, but the result was still not reliable. So I made a decision: instead of a "dynamic but sometimes wrong" KPI, I turned off the slicer's effect on those two cards, so they always show a correct, fixed comparison. Later, I replaced them with three simpler, always-correct KPIs (Total Incidents, Top Borough, Top Incident Type) that don't depend on time comparisons at all.

**Problem 2: Empty KPI values**

My KPI cards sometimes still showed "blank." I checked my calendar table and found the problem: I had built it with a hardcoded end date (31 December 2018), but my real incident data stopped in September 2018. Power BI was trying to calculate incidents for months that did not exist in the data.

I fixed this by deleting the extra rows from the calendar table, so it matches the real date range of the data.

## What I would do differently next time

- Build the calendar table using `MIN(date)` and `MAX(date)` from the fact table, instead of a hardcoded date.
- Add slicers to every page, not just the Overview page.
- Save a custom Power BI theme file early, so colors stay consistent as I add new visuals.

## Next steps

The dataset also includes `Operator` and `Garage` tables, which I did not use in this version. I kept the project focused on borough, route, and incident-type analysis. A natural next step would be an **Operator Performance** page, comparing incident rates across different bus operators and garages.

## Dataset source

TfL Bus Safety data, published by Transport for London.

## Contact

[Add your LinkedIn / email here]
