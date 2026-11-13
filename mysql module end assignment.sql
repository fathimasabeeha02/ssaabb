USE ecomm;
SET @wh   = (SELECT ROUND(AVG(WarehouseToHome)) FROM customer_churn);
SET @hrs  = (SELECT ROUND(AVG(HourSpendOnApp)) FROM customer_churn);
SET @hike = (SELECT ROUND(AVG(OrderAmountHikeFromlastYear)) FROM customer_churn);
SET @day  = (SELECT ROUND(AVG(DaySinceLastOrder)) FROM customer_churn);

UPDATE customer_churn SET WarehouseToHome = @wh WHERE WarehouseToHome IS NULL;
UPDATE customer_churn SET HourSpendOnApp = @hrs WHERE HourSpendOnApp IS NULL;
UPDATE customer_churn SET OrderAmountHikeFromlastYear = @hike WHERE OrderAmountHikeFromlastYear IS NULL;
UPDATE customer_churn SET DaySinceLastOrder = @day WHERE DaySinceLastOrder IS NULL;
SELECT
  SUM(WarehouseToHome IS NULL)             AS null_WarehouseToHome,
  SUM(HourSpendOnApp IS NULL)              AS null_HourSpendOnApp,
  SUM(OrderAmountHikeFromlastYear IS NULL) AS null_OrderAmountHike,
  SUM(DaySinceLastOrder IS NULL)           AS null_DaySinceLastOrder
FROM customer_churn;
SET @mode_tenure = (SELECT Tenure FROM customer_churn
                    WHERE Tenure IS NOT NULL
                    GROUP BY Tenure ORDER BY COUNT(*) DESC LIMIT 1);
UPDATE customer_churn SET Tenure = @mode_tenure WHERE Tenure IS NULL;

SET @mode_coupon = (SELECT CouponUsed FROM customer_churn
                    WHERE CouponUsed IS NOT NULL
                    GROUP BY CouponUsed ORDER BY COUNT(*) DESC LIMIT 1);
UPDATE customer_churn SET CouponUsed = @mode_coupon WHERE CouponUsed IS NULL;

SET @mode_order = (SELECT OrderCount FROM customer_churn
                   WHERE OrderCount IS NOT NULL
                   GROUP BY OrderCount ORDER BY COUNT(*) DESC LIMIT 1);
UPDATE customer_churn SET OrderCount = @mode_order WHERE OrderCount IS NULL;
SELECT
  SUM(Tenure IS NULL)      AS null_Tenure,
  SUM(CouponUsed IS NULL)  AS null_CouponUsed,
  SUM(OrderCount IS NULL)  AS null_OrderCount
FROM customer_churn;
DELETE FROM customer_churn WHERE WarehouseToHome > 100;
UPDATE customer_churn SET PreferredLoginDevice = 'Mobile Phone' WHERE PreferredLoginDevice = 'Phone';
UPDATE customer_churn SET PreferedOrderCat = 'Mobile Phone' WHERE PreferedOrderCat = 'Mobile';
UPDATE customer_churn SET PreferredPaymentMode = 'Cash on Delivery' WHERE PreferredPaymentMode = 'COD';
UPDATE customer_churn SET PreferredPaymentMode = 'Credit Card' WHERE PreferredPaymentMode = 'CC';

ALTER TABLE customer_churn RENAME COLUMN PreferedOrderCat TO PreferredOrderCat;
ALTER TABLE customer_churn RENAME COLUMN HourSpendOnApp TO HoursSpentOnApp;


ALTER TABLE customer_churn ADD COLUMN ComplaintReceived VARCHAR(3);
UPDATE customer_churn SET ComplaintReceived = IF(Complain = 1, 'Yes', 'No');

ALTER TABLE customer_churn ADD COLUMN ChurnStatus VARCHAR(10);
UPDATE customer_churn SET ChurnStatus = IF(Churn = 1, 'Churned', 'Active');
ALTER TABLE customer_churn DROP COLUMN Churn, DROP COLUMN Complain;



SELECT COUNT(*) FROM customer_churn;
DESCRIBE customer_churn;
SET SQL_SAFE_UPDATES = 0;
SET @wh   = (SELECT ROUND(AVG(WarehouseToHome)) FROM customer_churn);
SELECT ChurnStatus, COUNT(*) AS customers FROM customer_churn GROUP BY ChurnStatus;
SELECT AVG(Tenure) AS avg_tenure, SUM(CashbackAmount) AS total_cashback
FROM customer_churn WHERE ChurnStatus = 'Churned';
SELECT ROUND(100 * SUM(ComplaintReceived = 'Yes') / COUNT(*), 2) AS pct_complained
FROM customer_churn WHERE ChurnStatus = 'Churned';
SELECT CityTier, COUNT(*) AS churned
FROM customer_churn
WHERE ChurnStatus = 'Churned' AND PreferredOrderCat = 'Laptop & Accessory'
GROUP BY CityTier ORDER BY churned DESC LIMIT 1;
SELECT PreferredPaymentMode, COUNT(*) AS cnt
FROM customer_churn WHERE ChurnStatus = 'Active'
GROUP BY PreferredPaymentMode ORDER BY cnt DESC LIMIT 1;
SELECT SUM(OrderAmountHikeFromlastYear) AS total_hike
FROM customer_churn
WHERE MaritalStatus = 'Single' AND PreferredOrderCat = 'Mobile Phone';
SELECT AVG(NumberOfDeviceRegistered) FROM customer_churn WHERE PreferredPaymentMode = 'UPI';
SELECT CityTier, COUNT(*) AS cnt FROM customer_churn GROUP BY CityTier ORDER BY cnt DESC LIMIT 1;
SELECT Gender, SUM(CouponUsed) AS coupons FROM customer_churn
GROUP BY Gender ORDER BY coupons DESC LIMIT 1;
SELECT PreferredOrderCat, COUNT(*) AS customers, MAX(HoursSpentOnApp) AS max_hours
FROM customer_churn GROUP BY PreferredOrderCat;
SELECT SUM(OrderCount) AS total_orders
FROM customer_churn
WHERE PreferredPaymentMode = 'Credit Card'
  AND SatisfactionScore = (SELECT MAX(SatisfactionScore) FROM customer_churn);
  SELECT AVG(SatisfactionScore) FROM customer_churn WHERE ComplaintReceived = 'Yes';
  SELECT PreferredOrderCat, COUNT(*) AS cnt
FROM customer_churn WHERE CouponUsed > 5
GROUP BY PreferredOrderCat ORDER BY cnt DESC;
SELECT PreferredOrderCat, AVG(CashbackAmount) AS avg_cashback
FROM customer_churn GROUP BY PreferredOrderCat
ORDER BY avg_cashback DESC LIMIT 3;
SELECT PreferredPaymentMode
FROM customer_churn
GROUP BY PreferredPaymentMode
HAVING AVG(Tenure) = 10 AND SUM(OrderCount) > 500;