# 📊 SaaS IT Product & Subscription Analytics Suite

An end-to-end product analytics pipeline evaluating user lifecycle patterns, subscription tier economics, revenue run-rate (MRR/ARR), marketing unit economics (CAC/ROAS), and customer support SLA impact on churn across an 8-table relational ecosystem.

---

## 🛠️ Architecture & Tech Stack

| Layer | Tools & Technologies | Key Deliverables |
|---|---|---|
| **Data Processing & ETL** | Python (`pandas`, `numpy`) | Schema standardization, null handling, type casting, and bot event filtering. |
| **Exploratory Analytics** | Python (`matplotlib`, `seaborn`) | User cohort retention matrix and lifecycle decay analysis. |
| **Relational Modeling** | MySQL Workbench | Star/Snowflake schema design, foreign keys, window functions, and SLA churn queries. |
| **Business Intelligence** | Microsoft Power BI | DAX modeling, bidirectional cross-filtering, 3-page interactive executive suite. |

---

## 🗄️ Relational Schema Design (`saas` Database)

The relational architecture models customer interactions across 8 primary entities:
- `users_clean`: Demographic attributes, signup timestamps, initial acquired plan tier, and device metadata.
- `subscriptions_clean`: Plan tiers (`Starter`, `Professional`, `Enterprise`, `Free_Tier`), billing cycles, start/end dates, and monthly recurring revenue.
- `payment_clean`: Transaction histories, gateway status flags (`Success`, `Failed`, `Refunded`), and payment amounts.
- `session_clean`: User sessions, duration, bounce markers, and campaign attribution.
- `event_clean`: Granular product interactions (`Login`, `Dashboard_Render`, `Query_Executed`, `Filter_Applied`, `Report_Exported`, etc.).
- `campaigns_clean`: Acquisition channels, marketing ad spend budgets, and target conversions.
- `support_clean`: SLA ticket tracking, priority tiers, and resolution turnaround times.
- `features_clean`: Platform modules and gated tier permission mappings.

---

## 📈 Power BI Executive Dashboard Suite

### Page 1: Executive & Financial Overview
*Focus: Top-line recurring revenue, run-rate projections, and paid tier distributions.*
- **Current MRR ($22.52M)** and **Projected ARR ($270.27M)** establishing baseline financial run-rate.
- **ARPU ($289.93)** benchmarked across **78K Active Paying Subscribers**.
- Comparative trajectory of **Monthly Gross vs. Net Revenue** isolating refund and failed charge deductions.
- Billing transaction volume breakdown across `Success`, `Refunded`, and `Failed` statuses.

![Executive Overview](Screenshot/page1_financial_overview.png)

---

### Page 2: Product Engagement & Feature Adoption
*Focus: Core product stickiness, feature usage, and daily activity cycles.*
- **Daily Active Users (DAU)** trajectory tracking launch scale, sustained peak activity, and lifecycle plateau.
- **Stickiness (DAU/MAU Ratio)** normalized dynamically across active calendar cohorts (~5.7% across the full multi-year span, peaking at 15–20% during peak operations).
- Cross-tier matrix auditing feature interaction distribution across `Starter`, `Professional`, and `Enterprise` accounts.

![Product Adoption](Screenshot/page2_product_adoption.png)

---

### Page 3: Marketing Attribution & Support SLA Impact
*Focus: Channel return on ad spend (ROAS) and support operational efficiency on customer churn.*
- Channel-level acquisition efficiency benchmarking organic vs. paid ad spend multiples.
- Dynamic cross-filtered SLA resolution buckets (`Fast <= 24h`, `Standard 1-3d`, `Delayed > 3d`) evaluated against subscription churn rates.

![Marketing & Support SLA](Screenshot/page3_marketing_sla.png)

---

### Python User Cohort Retention Heatmap
*Visualizing month-over-month lifecycle retention decay and churn drop-offs.*

![Cohort Retention](Screenshot/retention_cohort_heatmap.png)

---

## 🔍 Key Business Findings & Strategic Insights

1. **Subscription Revenue Distribution:**
   - Paid customer volume is dominated by the **Starter tier (56.19%)**, while **Professional (29.79%)** and **Enterprise (14.02%)** drive high-margin MRR leverage.
2. **Feature Adoption as Retention Predictors:**
   - Heavy engagement with analytics features (`Dashboard_Render` and `Query_Executed`) exhibits the strongest correlation with user lifetime value.
3. **Support SLA Impact on Churn:**
   - Ticket resolutions delayed beyond 3 days demonstrate an observable increase in customer churn rate, confirming the retention impact of strict SLA thresholds.

---

## 🚀 Setup & Replication Guide

### 1. Database Setup (MySQL)
```sql
CREATE DATABASE IF NOT EXISTS saas;
USE saas;

-- Execute schema DDL, data loading, and analytical queries
SOURCE SQL Work/Complete SQL Work.sql;
```
### 2. Python Environment & Retention Script
```Bash
cd "python work"
pip install pandas numpy matplotlib seaborn
python event.py
```
### 3. Power BI Configuration
```Open power bi/Saas IT.pbix in Power BI Desktop.

Navigate to Transform Data > Data source settings.

Set your MySQL server connection to your local instance (127.0.0.1:3306, database: saas).

Click Apply changes.
```
