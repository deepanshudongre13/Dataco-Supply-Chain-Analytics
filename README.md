# DataCo Smart Supply Chain Analytics

## Business Problem
Delayed deliveries were impacting customer satisfaction and overall operational efficiency.
The objective of this project was to analyze supply chain data to identify where delivery delays occur,
why they occur, and how they affect business performance and revenue.

---

## Tools & Technologies
- **Python**: Data cleaning, preprocessing, and feature engineering  
- **SQL (MySQL)**: Business logic, analysis, and categorical bucketing using Views  
- **Power BI**: Interactive dashboards and data storytelling  

---

## Project Workflow
1. Cleaned and standardized 180,000+ supply chain records using Python  
2. Removed irrelevant and sensitive columns to improve data quality  
3. Converted date fields into proper DateTime format for delay analysis  
4. Engineered business features such as:
   - Discount Flag  
   - High Quantity Flag  
   - Revenue per Item  
5. Loaded the cleaned data into MySQL  
6. Created SQL Views using CASE statements to bucket:
   - Delivery delays  
   - Discount levels  
   - Order quantities  
7. Built a two-page Power BI dashboard separating business performance and operational issues  

---

## Dashboard Preview

### Page 1: Business Strength & Revenue Performance
![Business Strength](./supply%20chain%20powerbi%20ss%20page1.png)

### Page 2: Operational Bottlenecks & Delivery Delays
![Operational Issues](./supply%20chain%20powerbi%20ss%20page%202.png)

---

## Key Insights
- Certain regions consistently experience higher delivery delays  
- Premium shipping modes do not always guarantee faster delivery  
- High-quantity and high-discount orders show a higher risk of late delivery  
- Sales growth does not always align with delivery performance  

---

## Business Impact
- Identified logistics bottlenecks across regions and shipping modes  
- Helped prioritize severe delivery delays over minor issues  
- Enabled management to balance revenue growth with operational efficiency  

---

## Dataset Note
The cleaned dataset exceeds GitHub’s file size limits and has not been uploaded.
All data preparation steps, SQL logic, and insights are fully reproducible using
the provided Python, SQL, and Power BI files.

---

## One-Line Project Summary
An end-to-end supply chain analytics project using Python, SQL, and Power BI to analyze
delivery delays, operational bottlenecks, and their impact on business performance.
