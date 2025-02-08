WITH WarehouseSales AS (
    SELECT products.warehouseCode, 
           SUM(orderdetails.quantityOrdered * orderdetails.priceEach) AS totalSales
    FROM orderdetails
    JOIN products ON orderdetails.productCode = products.productCode
    GROUP BY products.warehouseCode
), 

InventoryTurnover AS (
    SELECT products.warehouseCode, 
           SUM(orderdetails.quantityOrdered) / NULLIF(SUM(products.quantityInStock), 0) AS turnoverRate
    FROM orderdetails
    JOIN products ON orderdetails.productCode = products.productCode
    GROUP BY products.warehouseCode
),

ShippingEfficiency AS (
    SELECT products.warehouseCode, 
           AVG(DATEDIFF(orders.shippedDate, orders.orderDate)) AS avgShippingDelay
    FROM orders
    JOIN orderdetails ON orders.orderNumber = orderdetails.orderNumber
    JOIN products ON orderdetails.productCode = products.productCode
    WHERE orders.status = 'Shipped'
    GROUP BY products.warehouseCode
),

TotalInStock AS(
	select w.warehouseCode, sum(p.quantityInStock) as QuantInStock
	from products p 
	join orderdetails od on od.productCode = p.productCode 
	join warehouses w on p.warehouseCode = w.warehouseCode
	group by w.warehouseCode),

Profits as (
	SELECT warehouses.warehouseCode, 
       SUM((orderdetails.priceEach - products.buyPrice) * orderdetails.quantityOrdered) AS totalProfit
	FROM orderdetails
	JOIN products on orderdetails.productCode = products.productCode
	JOIN warehouses ON products.warehouseCode = warehouses.warehouseCode
	GROUP BY products.warehouseCode
	ORDER BY totalProfit desc),
    
FinalScoring AS (
    SELECT warehouses.warehouseCode, warehouses.warehouseName,
           COALESCE(warehouseSales.totalSales, 0) AS totalSales,
		   COALESCE(Profits.totalProfit, 0) AS totalProfit,
           COALESCE(TotalInStock.QuantInStock, 0) AS QuantInStock,
           COALESCE(InventoryTurnover.turnoverRate, 0) AS turnoverRate,
           COALESCE(ShippingEfficiency.avgShippingDelay, 999) AS avgShippingDelay,
           warehouses.warehousePctCap,
           -- Weighted Score Calculation
           (COALESCE(warehouseSales.totalSales, 0) * 0.05 +  -- 5% weight on sales
            COALESCE(Profits.totalProfit, 0) *0.15 + -- 15% weight on profits
            COALESCE(TotalInStock.QuantInStock, 0) *0.15 + -- 15% weight on quantity in stock
            COALESCE(InventoryTurnover.turnoverRate, 0) * 0.10 -  -- 10% weight on inventory turnover
            COALESCE(ShippingEfficiency.avgShippingDelay, 999) * 0.35 +  -- 35% penalty for delays
            warehouses.warehousePctCap * 0.2) AS performanceScore  -- 20% weight on capacity
    FROM warehouses
    LEFT JOIN WarehouseSales ON warehouses.warehouseCode = warehouseSales.warehouseCode
    LEFT JOIN InventoryTurnover ON warehouses.warehouseCode = InventoryTurnover.warehouseCode
    LEFT JOIN ShippingEfficiency ON warehouses.warehouseCode = ShippingEfficiency.warehouseCode
    LEFT JOIN Profits ON warehouses.warehouseCode = Profits.warehouseCode
    LEFT JOIN TotalInStock ON warehouses.warehouseCode = TotalInStock.warehouseCode
)

SELECT warehouseCode, warehouseName, performanceScore
FROM FinalScoring
ORDER BY performanceScore DESC