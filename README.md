# Marketing A/B Test Analysis — SQL Portfolio Project

## 📝Overview

This project analyses a marketing A/B test dataset containing approximately 259110 users, split between two groups: one exposed to real product advertisements and one shown a neutral public service announcement (PSA) used as a control. The dataset captures whether each user converted, the total number of ads they were shown, and the day and hour when they saw the most ads. 
The central business question is straightforward: **did showing ads actually drive more conversions than the control group, and if so, by how much?** Understanding this helps a marketing team decide whether paid ad spend is generating a measurable return and where to concentrate future campaigns.

## 🗒️Approach

The analysis was carried out entirely in SQL (MySQL), working through the problem in four stages.

**Group validation** came first. Before drawing any conclusions, I checked how users were distributed across the two test groups. This revealed a significant imbalance — roughly 96% of users were in the ad group and only 4% in the PSA group. This is worth flagging early because it means direct count comparisons are meaningless; only rates and proportions are valid for comparison.

**Conversion rates** were calculated next using conditional aggregation (`SUM(CASE WHEN converted = 'True' THEN 1 ELSE 0 END)`), giving a clean conversion percentage per group. A chi-square test was then run to confirm that the observed difference was statistically significant and not a result of random chance — given the large sample sizes involved, even a small lift can be reliably detected.

**Ad frequency segmentation** broke the ad group into four exposure buckets (1–10, 11–50, 51–100, and 100+ ads) to test whether users who saw more ads were more likely to convert. This required a `CASE` expression inside a `GROUP BY`, with results ordered by exposure level to make any trend immediately visible.

**Time pattern analysis** used the `most_ads_day` and `most_ads_hour` columns to identify when conversions were strongest. Both were run as separate queries filtered to the ad group only, ordered by conversion rate descending to surface the top-performing windows quickly.

---

## 🔍 Findings

The ad group converted at **4.37%** compared to **2.74%** for the PSA group — a **59.48% relative lift** in conversions. This difference was confirmed as statistically significant via a chi-square test, meaning it is very unlikely to be due to chance.

Conversion rate increases consistently with ad exposure and shows no drop-off at high volumes:
| Ads Seen | Conversion Rate |
|----------|----------------|
| 1–10     | ~0.84%         |
| 11–50    | moderate lift  |
| 51–100   | strong lift    |
| 100+     | ~17%           |

Users who saw 100 or more ads converted at roughly **20× the rate** of those who saw fewer than 10 — a striking pattern that suggests heavier exposure is associated with substantially higher intent to purchase.

On timing, **Monday** produced the highest conversion rate among weekdays at **5.40%**, while Saturday was the weakest at **3.83%**. Across hours of the day, the top windows were **16:00 (5.44%)** and **19:00 (4.88%)**, with 14:00 and 20:00 also performing well. Mid-to-late afternoon and early evening consistently outperform other time windows, pointing to a clear targeting opportunity.

---
## 🛑Limitations

**Group imbalance.** The 96/4 split between the ad and PSA groups is far from a balanced experiment. While the chi-square test accounts for this mathematically by working with rates rather than counts, the imbalance raises questions about how the experiment was designed. A more balanced split would give greater confidence in the results.

**Unknown assignment mechanism.** There is no information in the dataset about how users were assigned to each group. If the assignment was not truly random — for example, if users already showing high purchase intent were systematically shown more ads — the frequency-to-conversion correlation may not be causal. It is possible that motivated buyers sought out or were targeted with more ads, rather than the ads themselves creating that motivation.

**No demographic data.** The dataset contains no information about user age, location, device type, or prior purchase history. This makes it impossible to assess whether the ad effect is uniform across user segments or concentrated in a specific sub-group, and it limits how actionable the timing findings are without knowing who is online at those hours.

---

## 🗄️ Files

| File | Description |
|------|-------------|
| `marketing_ab_analysis.sql` | All SQL queries used in the analysis |
| `README.md` | This file |

---

## 🛠️ Tools
**MySQL** — all analysis

