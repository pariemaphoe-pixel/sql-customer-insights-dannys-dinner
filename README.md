<div align="center">

<!-- HEADER BANNER -->
<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,11,20&height=200&section=header&text=Danny's%20Diner&fontSize=60&fontColor=fff&animation=twinkling&fontAlignY=35&desc=SQL%20%7C%20Customer%20Analytics%20%7C%20Business%20Intelligence&descAlignY=58&descSize=18" width="100%"/>

<!-- BADGES -->
[![SQL](https://img.shields.io/badge/SQL-PostgreSQL-336791?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Status](https://img.shields.io/badge/Status-Complete-brightgreen?style=for-the-badge&logo=checkmarx&logoColor=white)]()
[![Case Study](https://img.shields.io/badge/8_Week_SQL_Challenge-Case_Study_%231-orange?style=for-the-badge&logo=databricks&logoColor=white)](https://8weeksqlchallenge.com/)
[![Portfolio](https://img.shields.io/badge/Portfolio-Project-blueviolet?style=for-the-badge&logo=github&logoColor=white)]()

<br/>

> *"Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry, and ramen."*

<br/>

</div>

---

## 📖 Table of Contents

| # | Section |
|---|---------|
| 1 | [🎯 Project Overview](#-project-overview) |
| 2 | [📊 Key Results at a Glance](#-key-results-at-a-glance) |
| 3 | [🗃️ Database Schema](#️-database-schema) |
| 4 | [❓ Business Questions & SQL Solutions](#-business-questions--sql-solutions) |
| 5 | [📈 Data Visualizations](#-data-visualizations) |
| 6 | [💡 Key Insights](#-key-insights) |
| 7 | [🎯 Strategic Recommendations](#-strategic-recommendations) |
| 8 | [🧰 Tools & Skills Demonstrated](#-tools--skills-demonstrated) |

---

## 🎯 Project Overview

Danny's Diner is **Case Study #1** from [Danny Ma's 8-Week SQL Challenge](https://8weeksqlchallenge.com/case-study-1/) — one of the most recognized data analytics challenges in the community. Danny needs help understanding his customers to keep the restaurant thriving.

### The Mission
Analyze customer visit patterns, total spending, and favourite menu items to help Danny deliver **personalized experiences** and make an informed decision about expanding the loyalty program.

### Dataset Snapshot

```
📅 Analysis Period: January 1 – February 1, 2021
👥 Customers: 3 (A, B, C)
🍜 Menu Items: Sushi ($10) | Curry ($15) | Ramen ($12)
📋 Total Transactions: 15 orders
```

---

## 📊 Key Results at a Glance

<div align="center">

| Metric | Value |
|--------|-------|
| 💰 **Total Revenue** | $186 |
| 🛒 **Total Orders** | 15 |
| 👥 **Unique Customers** | 3 |
| 💳 **Average Order Value** | $12.40 |
| 📆 **Active Business Days** | 8 |
| 🏆 **Top Product** | Ramen (51.6% of revenue) |
| ⭐ **Highest Spender** | Customer A ($76) |

</div>

---

## 🗃️ Database Schema

Danny provided three tables. Understanding how they connect is the foundation of every query.

```
┌──────────────────────┐       ┌──────────────────────┐
│       SALES          │       │        MENU           │
├──────────────────────┤       ├──────────────────────┤
│ customer_id  STRING  │       │ product_id   INT  🔑  │
│ order_date   DATE    │       │ product_name STRING   │
│ product_id   INT  ───┼──────▶│ price        INT      │
└──────────────────────┘       └──────────────────────┘
         │
         │
         ▼
┌──────────────────────┐
│      MEMBERS         │
├──────────────────────┤
│ customer_id  STRING  │
│ join_date    DATE    │
└──────────────────────┘
```

### Join Logic

```sql
-- Primary Join: Enrich sales with product details
INNER JOIN menu ON sales.product_id = menu.product_id

-- Secondary Join: Identify loyalty members
LEFT JOIN members ON sales.customer_id = members.customer_id
-- LEFT JOIN used because not all customers are members (Customer C)
```

> **Why LEFT JOIN for members?** Customer C has no membership record. A LEFT JOIN preserves all sales rows while returning `NULL` for non-members — critical for accurate revenue calculations.

---

## ❓ Business Questions & SQL Solutions

### 1. What is the total amount each customer spent?

```sql
SELECT
    s.customer_id,
    SUM(m.price) AS total_spent
FROM sales s
INNER JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY total_spent DESC;
```

**Result:**

| Customer | Total Spent |
|----------|------------|
| A | $76 |
| B | $74 |
| C | $36 |

---

### 2. How many days has each customer visited?

```sql
SELECT
    customer_id,
    COUNT(DISTINCT order_date) AS visit_days
FROM sales
GROUP BY customer_id;
```

**Result:**

| Customer | Visit Days |
|----------|-----------|
| A | 4 |
| B | 6 |
| C | 2 |

---

### 3. What was the first item from the menu purchased by each customer?

```sql
WITH ranked_orders AS (
    SELECT
        s.customer_id,
        m.product_name,
        s.order_date,
        DENSE_RANK() OVER (
            PARTITION BY s.customer_id
            ORDER BY s.order_date
        ) AS purchase_rank
    FROM sales s
    INNER JOIN menu m ON s.product_id = m.product_id
)
SELECT customer_id, product_name AS first_purchase
FROM ranked_orders
WHERE purchase_rank = 1;
```

**Result:**

| Customer | First Purchase |
|----------|---------------|
| A | curry, sushi |
| B | curry |
| C | ramen |

---

### 4. What is the most purchased item on the menu and how many times was it purchased?

```sql
SELECT
    m.product_name,
    COUNT(s.product_id) AS total_orders
FROM sales s
INNER JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY total_orders DESC
LIMIT 1;
```

**Result:** 🍜 **Ramen** — ordered **8 times** (53.3% of all orders)

---

### 5. Which item was the most popular for each customer?

```sql
WITH purchase_counts AS (
    SELECT
        s.customer_id,
        m.product_name,
        COUNT(*) AS order_count,
        DENSE_RANK() OVER (
            PARTITION BY s.customer_id
            ORDER BY COUNT(*) DESC
        ) AS rank
    FROM sales s
    INNER JOIN menu m ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, product_name, order_count
FROM purchase_counts
WHERE rank = 1;
```

**Result:**

| Customer | Favourite Item | Times Ordered |
|----------|---------------|---------------|
| A | Ramen | 3 |
| B | Curry, Ramen, Sushi *(tied)* | 2 each |
| C | Ramen | 3 |

---

### 6. Which item was purchased first by the customer after they became a member?

```sql
WITH post_member_orders AS (
    SELECT
        s.customer_id,
        m.product_name,
        s.order_date,
        DENSE_RANK() OVER (
            PARTITION BY s.customer_id
            ORDER BY s.order_date
        ) AS rank
    FROM sales s
    INNER JOIN menu m ON s.product_id = m.product_id
    INNER JOIN members mb ON s.customer_id = mb.customer_id
    WHERE s.order_date >= mb.join_date
)
SELECT customer_id, product_name AS first_member_purchase
FROM post_member_orders
WHERE rank = 1;
```

**Result:**

| Customer | First Post-Membership Order |
|----------|-----------------------------|
| A | Ramen |
| B | Sushi |

---

### 7. What item was purchased just before the customer became a member?

```sql
WITH pre_member_orders AS (
    SELECT
        s.customer_id,
        m.product_name,
        s.order_date,
        DENSE_RANK() OVER (
            PARTITION BY s.customer_id
            ORDER BY s.order_date DESC
        ) AS rank
    FROM sales s
    INNER JOIN menu m ON s.product_id = m.product_id
    INNER JOIN members mb ON s.customer_id = mb.customer_id
    WHERE s.order_date < mb.join_date
)
SELECT customer_id, product_name AS last_pre_member_purchase
FROM pre_member_orders
WHERE rank = 1;
```

**Result:**

| Customer | Last Pre-Membership Order |
|----------|--------------------------|
| A | Sushi, Curry |
| B | Sushi |

---

### 8. What is the total items and amount spent for each member before they became a member?

```sql
SELECT
    s.customer_id,
    COUNT(s.product_id)  AS items_ordered,
    SUM(m.price)         AS total_spent
FROM sales s
INNER JOIN menu m    ON s.product_id    = m.product_id
INNER JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;
```

**Result:**

| Customer | Items Before Membership | Spent Before Membership |
|----------|------------------------|------------------------|
| A | 2 | $25 |
| B | 3 | $40 |

---

### 9. If each $1 spent equates to 10 points, and sushi has a 2x points multiplier — how many points would each customer have?

```sql
SELECT
    s.customer_id,
    SUM(
        CASE
            WHEN m.product_name = 'sushi' THEN m.price * 20
            ELSE m.price * 10
        END
    ) AS total_points
FROM sales s
INNER JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY total_points DESC;
```

**Result:**

| Customer | Total Points |
|----------|-------------|
| A | 860 |
| B | 940 |
| C | 360 |

> 💡 **Insight:** Customer B leads in loyalty points despite spending $2 less than A — driven by more balanced ordering including sushi (2x multiplier).

---

### 10. Bonus — Full Customer Dashboard with Membership Status

```sql
SELECT
    s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
    CASE
        WHEN mb.join_date IS NULL          THEN 'N'
        WHEN s.order_date >= mb.join_date  THEN 'Y'
        ELSE 'N'
    END AS member
FROM sales s
INNER JOIN menu    m  ON s.product_id    = m.product_id
LEFT  JOIN members mb ON s.customer_id  = mb.customer_id
ORDER BY s.customer_id, s.order_date;
```

**Result (sample):**

| Customer | Order Date | Product | Price | Member? |
|----------|-----------|---------|-------|---------|
| A | 2021-01-01 | curry | $15 | N |
| A | 2021-01-01 | sushi | $10 | N |
| A | 2021-01-07 | curry | $15 | Y |
| A | 2021-01-10 | ramen | $12 | Y |
| A | 2021-01-11 | ramen | $12 | Y |
| B | 2021-01-01 | curry | $15 | N |
| B | 2021-01-09 | sushi | $10 | Y |
| C | 2021-01-01 | ramen | $12 | N |

---

## 📈 Data Visualizations

### 🍜 Product Performance

```
Revenue by Product ($186 Total)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Ramen  ████████████████████████████████████████████ $96  (51.6%)
Curry  ██████████████████████████████               $60  (32.3%)
Sushi  ████████████████                             $30  (16.1%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
         $0         $25        $50        $75       $100
```

```
Order Volume (15 Total Orders)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Ramen  ████████████████████████████████████████████  8 orders (53.3%)
Curry  ████████████████████████                      4 orders (26.7%)
Sushi  ████████████████                              3 orders (20.0%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### 👥 Customer Order Preferences Heatmap

```
         Customer A    Customer B    Customer C
        ┌─────────────┬─────────────┬─────────────┐
 Ramen  │  🔥🔥🔥  3  │  🔥🔥    2  │  🔥🔥🔥  3  │
        ├─────────────┼─────────────┼─────────────┤
 Curry  │  🔥🔥    2  │  🔥🔥    2  │     —     0  │
        ├─────────────┼─────────────┼─────────────┤
 Sushi  │  🔥      1  │  🔥🔥    2  │     —     0  │
        └─────────────┴─────────────┴─────────────┘
         (Member ⭐)    (Member ⭐)   (Non-Member)
```

---

### 📅 Daily Revenue Pattern

```
Revenue ($)
$70 ┤
    │ ●  Jan 1: $64 ← PEAK DAY (34% of total revenue)
$60 ┤ │
    │ │
$50 ┤ │
    │ │
$40 ┤ │                          ● Jan 11: $34
    │ │                          │
$30 ┤ │     ● Jan 7: $27         │
    │ │     │                    │
$20 ┤ │     │   ● Jan 10: $12    │
    │ │  ● Jan 4: $10            │     ● Jan 16: $12
$10 ┤ │  ●───┘                   └──────┘            ● Feb 1: $12
    │ │  Jan 2: $15
 $0 ┘─────────────────────────────────────────────────────────
      Jan 1  Jan 4  Jan 7  Jan 10  Jan 13  Jan 16  Jan 19  Feb 1
```

---

### 💳 Membership Impact Analysis

```
                   BEFORE MEMBERSHIP    →    AFTER MEMBERSHIP
                   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Customer A     │  2 orders  │  $25  │  →  │  4 orders  │  $51  │  📈 +100% orders / +104% spend
(Joined Jan 7) │            │       │     │            │       │

Customer B     │  3 orders  │  $40  │  →  │  3 orders  │  $34  │  📊 Stable orders / -15% spend
(Joined Jan 9) │            │       │     │            │       │

Customer C     │     Not yet a member — conversion opportunity 🎯         │
               ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 💡 Key Insights

<details>
<summary><b>🍜 Insight 1: Ramen is the undisputed star</b></summary>

Ramen accounts for **53.3% of all orders** and **51.6% of total revenue** — despite being mid-priced at $12. Its dominance is volume-driven. Every single customer has ordered it, and two of the three exclusively favour it.

**Implication:** Ramen is Danny's anchor product. Any menu changes should protect this item's positioning.

</details>

<details>
<summary><b>💰 Insight 2: Membership dramatically boosts Customer A's spending</b></summary>

After joining, Customer A's order frequency doubled (+100%) and spending increased by 104% — from $25 to $51. This is a strong signal that the loyalty program can be a genuine revenue driver when customers are properly engaged with it.

**Implication:** The membership program has proven ROI. The priority should be converting Customer C.

</details>

<details>
<summary><b>📦 Insight 3: Customer C is a high-risk, high-opportunity account</b></summary>

Customer C has only ever ordered ramen and has never joined the loyalty program. With just $36 in total spend vs. the $74–76 average of members, there is significant untapped value. Members spend **2× more** on average.

**Implication:** A targeted ramen-first promotion with a membership incentive could unlock $30–40 in incremental revenue from Customer C alone.

</details>

<details>
<summary><b>📅 Insight 4: January 1st generated 34% of all revenue in a single day</b></summary>

With 5 orders and $64 in revenue on opening day, the business had a strong launch but struggled to maintain momentum. Activity dropped significantly after January 11th, with only sporadic visits through February.

**Implication:** Danny needs a re-engagement strategy — loyalty rewards, weekly specials, or SMS/email nudges for customers inactive for 3+ days.

</details>

<details>
<summary><b>🎯 Insight 5: Curry is the margin hero hiding in plain sight</b></summary>

Curry is priced at $15 — the highest on the menu — yet only accounts for 26.7% of orders. If its order frequency matched ramen's, it would generate ~$120 in revenue vs. the current $60. Curry has the highest revenue-per-order efficiency on the menu.

**Implication:** Marketing curry more prominently (combos, specials, chef's recommendation) could meaningfully increase revenue without adding menu complexity.

</details>

---

## 🎯 Strategic Recommendations

| Priority | Action | Expected Impact |
|----------|--------|----------------|
| 🔴 **High** | Convert Customer C to membership | +$30–40 estimated incremental spend |
| 🔴 **High** | Re-engagement campaign after 3-day inactivity | Reduce gaps between orders |
| 🟡 **Medium** | Cross-sell curry to Customer C via ramen combo deals | Increase AOV from $12 to $13.50+ |
| 🟡 **Medium** | Analyse what drove Jan 1 peak — replicate tactics | Potential for $30–40 days consistently |
| 🟢 **Low** | Premium ramen variants at $14–15 | Improve ramen revenue per order by ~20% |
| 🟢 **Low** | Sushi 2× loyalty points promotion | Drive sushi trial among ramen-only customers |

---

## 🧰 Tools & Skills Demonstrated

<div align="center">

| Category | Skills Applied |
|----------|---------------|
| **SQL Techniques** | `INNER JOIN`, `LEFT JOIN`, `GROUP BY`, `ORDER BY`, `CASE WHEN`, `CTEs`, `Window Functions` (`DENSE_RANK`, `PARTITION BY`) |
| **Analytics** | Customer segmentation, cohort analysis, pre/post analysis, product performance benchmarking |
| **Business Thinking** | Revenue attribution, loyalty program ROI, churn risk identification, pricing strategy |
| **Communication** | Executive summary, insight narrative, actionable recommendations tied to data |

</div>

---

<div align="center">

### 📁 Repository Structure

```
📦 dannys-diner-sql-analysis
 ┣ 📄 README.md                              ← You are here
 ┣ 📂 sql/
 ┃ ┣ 📄 schema_setup.sql                    ← Table creation & seed data
 ┃ ┣ 📄 case_study_solutions.sql            ← All 10 business questions
 ┃ ┗ 📄 bonus_queries.sql                   ← Dashboard & ranking tables
 ┣ 📂 data/
 ┃ ┣ 📄 product_performance_analysis.csv    ← Revenue & order data
 ┃ ┣ 📄 daily_sales_trends.csv             ← Day-by-day activity
 ┃ ┗ 📄 customer_product_preferences.csv   ← Heatmap source data
 ┗ 📂 reports/
   ┗ 📄 comprehensive_analysis.pdf          ← Full findings report
```

</div>

---

<div align="center">

**Made with 🍜 and SQL**

*Part of the [8 Week SQL Challenge](https://8weeksqlchallenge.com/) by Danny Ma*

<br/>

*If this project was helpful, consider leaving a ⭐ — it helps others discover it!*

<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,11,20&height=100&section=footer" width="100%"/>

</div>
