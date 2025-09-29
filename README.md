# Individual Assignment I : PL/SQL Window Functions Mastery Project

**Name** : Firmin Iradukunda 
**ID** : 27316 
**Course** : Database Development with PL/SQL (INSY 8311) 
**Instructor** : Mr Eric Maniraguha

### Assignment Objective : 
Demonstrate mastery of PL/SQL window functions by solving a realistic business problem, implementing analytical queries, and documenting results in a professional GitHub repository.

## 1. Problem definition
**Business context**:  A small hospitality business in Rwanda’s touristic areas operating within the **tourism and service industry**, offering lodging, dining, and cultural experiences to travelers. It is privately owned, community-oriented, and focused on delivering personalized guest services at affordable prices.

**Data Challenge**: Small hospitality businesses in Rwanda face data challenges due to **seasonal fluctuations in tourism**, making it difficult to forecast demand. **Tracking guests** is often hindered by inconsistent records or limited digital systems, affecting personalized service. Additionally, **optimizing occupancy** requires accurate data to balance pricing, availability, and guest preferences across seasons.


**Expected Outcome** :

 1. ***Improved forecasting*** of peak and low seasons to adjust staffing and pricing .
 2. ***Identification of guests tendencies*** to enhance retention.
   
 3. ***Optimized room allocation and pricing*** to maximize occupancy and revenue across varying demand periods.
## 2. Success Criteria

1. **Rank rooms by occupancy rate per quarter** → `RANK() OVER()`.
    
2.  **Cumulative revenue per month** → `SUM () OVER () `.
    
3.  **Identify repeat guests and time between stays** → `LAG() OVER()`.
    
4. **Average stay length per guest** → `AVG() OVER ()`.

5. **Divide guests into spending quartiles** → `NTILE()`

## 3. Database Schema

|Tables|Purpose  |Key Columns| Example Row 
|-------|------------|---------------|-----
|  Guests |Stores guest personal information |guest_id| 1, 'Jean', 'Niyonzima', 'jean.niyonzima@example.com', '+250788111111', 'Rwanda', DATE '2025-01-10'|
|Rooms|Stores hotel rooms and categories|room_id|1, '101', 'Single', 20000, 'Available'|
|Bookings| Stores bookings information|booking_id, guest_id, room_id|1, 1, 1, DATE '2025-01-12', DATE '2025-01-14', DATE '2025-01-10', 'Checked-out'|
|Payments|Tracks payments of bookings|payment_id, booking_id|1, 1, 40000, DATE '2025-01-12', 'Cash'|
### ER Diagram
img
### Tables creation and data insertions
*** 
1. **Guests** 
*Creation* 
img
*Insertion*
img
2. **Rooms** 
*Creation* 
img
*Insertion*
img
3. **Bookings** 
*Creation* 
img
*Insertion*
img
4. **Payments**
*Creation* 
img
*Insertion*
img

## 4. Windows Functions Implementation

1. **Ranking** : Find the Top Guests by Total Spending  
*Query:*  
```sql
SELECT g.guest_id, -- selects guests by id
       g.first_name || ' ' || g.last_name AS guest_name, -- retrieval of guest names
       SUM(p.amount_paid) AS total_spent, -- sum of amounts paid
       RANK() OVER (ORDER BY SUM(p.amount_paid) DESC) AS spending_rank -- ranking from most to least
FROM Guests g
JOIN Bookings b ON g.guest_id = b.guest_id
JOIN Payments p ON b.booking_id = p.booking_id
GROUP BY g.guest_id, g.first_name, g.last_name; -- joining and grouping
```
* Results
img

2. **Aggregate** : Compare performance of room categories
* Query :
```sql
SELECT r.room_type, --selction of room by type
       COUNT(b.booking_id) AS total_bookings, --counting bookings
       ROUND(AVG(COUNT(b.booking_id)) OVER (PARTITION BY r.room_type), 2) AS avg_bookings_per_type --averaging the counted bookings per room type
FROM Rooms r
LEFT JOIN Bookings b ON r.room_id = b.room_id
GROUP BY r.room_type, b.room_id; --Joining and grouping
```
* Results
img

3. **Aggregate** : Track how revenue grows day by day
* Query :
```sql
    SELECT p.payment_date, --selection of payments date 
           SUM(p.amount_paid) AS daily_revenue, -- sum per day
           SUM(SUM(p.amount_paid)) OVER (ORDER BY p.payment_date) AS cumulative_revenue -- cumulative payments ordered by date
    FROM Payments p
    GROUP BY p.payment_date
    ORDER BY p.payment_date; -- grouping and order
```
* Results
img

4. **Navigation** : Spot peak seasons & low seasons
* Query :
```sql
SELECT TO_CHAR(p.payment_date, 'YYYY-MM') AS month, -- Selection of payments by month
       SUM(p.amount_paid) AS monthly_revenue,
       LAG(SUM(p.amount_paid)) OVER (ORDER BY TO_CHAR(p.payment_date, 'YYYY-MM')) AS prev_month_revenue, -- Calculations over time
       SUM(p.amount_paid) 
       LAG(SUM(p.amount_paid)) OVER (ORDER BY TO_CHAR(p.payment_date, 'YYYY-MM')) AS revenue_change --ordering total per month 
FROM Payments p
GROUP BY TO_CHAR(p.payment_date, 'YYYY-MM')
ORDER BY month;
```
*Result 
img
5. **Distribution** : Divide guests into spending quartiles
* Query :
```sql
SELECT g.guest_id, --Selection by guest id
       g.first_name || ' ' || g.last_name AS guest_name,
       SUM(p.amount_paid) AS total_spent, --calculation of spending
       NTILE(4) OVER (ORDER BY SUM(p.amount_paid) DESC) AS spending_quartile --Quarter calcutions 
FROM Guests g
JOIN Bookings b ON g.guest_id = b.guest_id
JOIN Payments p ON b.booking_id = p.booking_id
GROUP BY g.guest_id, g.first_name, g.last_name
ORDER BY spending_quartile, total_spent DESC; --ordering and grouping
```
 * Result 
 img
## 5. Result Analysis 
**1. Descriptive** 

-   A few **top guests** account for the majority of spending (high concentration of revenue).
    
-   Revenue shows **steady cumulative growth** with seasonal peaks in February and March.
    
-   **Single and Double rooms** have higher occupancy than suites.
    
-   Some **guests book repeatedly**, showing loyalty.

**2. Diagnostic** 

-   **High-spending guests** likely book longer stays or premium rooms.
    
-   Seasonal peaks align with **local holidays or tourism waves**.
    
-   Suites may have **low demand due to higher prices** compared to smaller rooms

**3. Prescriptive** 

-   Develop a **loyalty programs** for top spenders to retain them.
    
-   Create **seasonal pricing packages** to maximize peak demand periods.
    
-   Promote **suite discounts or bundled offers** to improve utilization.
    
-   Target **low-spending segments** with promotions to increase average spend.

## 6. References

*[1] “Ireme Technologies,”  Iremetech.com_, 2025. https://iremetech.com/our-blogs/the-rise-of-hospitality-businesses-in-rwanda .*

*“Catalysts for Growth: Supporting Entrepreneurs in Rwanda’s Tourism Industry,”  _Mastercardfdn.org_, Nov. 15, 2018. https://mastercardfdn.org/en/articles/catalysts-for-growth-supporting-entrepreneurs-in-rwandas-tourism-industry/*

*“BEYOND RECOVERY, TOWARDS SUSTAINABLE ECONOMIC GROWTH 2022 Annual Report 2 2022 Annual Report 3.” Available: https://rdb.rw/reports/RDB-Annual-Report-2022.pdf*

*“Business of hospitality in Rwanda - CNBC Africa,” _CNBC Africa_, Jul. 25, 2025. https://www.cnbcafrica.com/media/7753454737854/business-of-hospitality-in-rwanda*

*“COLLEGE OF BUSINESS AND ECONOMICS SMALL AND MEDIUM ENTERPRISES AND JOB CREATION IN RWANDA,” 2016. Accessed: Sep. 29, 2025. [Online]. Available: https://dr.ur.ac.rw/bitstream/handle/123456789/84/UWITONZE%20Marc.pdf?sequence=1*
 
 *“RWANDA SKILLS SURVEY 2012.” Accessed: Sep. 29, 2025. [Online]. Available: https://lmis.rw/media/resources/Tourism.pdf*

*Winifride Umumararungu and G. Njenga, “Sustainable Business Practices for Competitive Advantage in Hospitality Industry in Rwanda, a case of Radisson Blu Hotel, Kigali,” _International Journal of Advanced Business Studies_, vol. 4, no. 1, Mar. 2025, doi: https://doi.org/10.59857/dtyv6913.*

Additional Sources : ChatGPT.com, youtube.com

> “All sources were properly cited. Implementations and analysis represent original work. No AI generated content was copied without attribution or adaptation.”
