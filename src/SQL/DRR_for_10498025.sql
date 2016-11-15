-- без этого не выполняются запросы к analyst.orders_dict
-- подробности у Захара
set hive.ppd.remove.duplicatefilters = false;
set start_date='2016-10-10';
set end_date=  '2016-11-10';

SELECT
  'CPA' AS type,
  ${hiveconf:start_date} AS start_date,
  ${hiveconf:end_date} AS end_date,
  sum(item_revenue)*30 AS total_price, -- в рублях
  sum(item_price) AS total_offer_price -- в рублях
FROM analyst.orders_dict
WHERE
  model_hid = 10498025 AND -- Умные часы и браслеты
  creation_day BETWEEN ${hiveconf:start_date} AND ${hiveconf:end_date} AND
  order_is_billed = True AND
  offer_currency = 'RUR' -- на всякий случай, чтобы не суммировать в другой валюте
  AND NOT order_is_fake AND NOT buyer_is_fake AND NOT shop_is_fake -- устраняем фейки из данных

UNION ALL

SELECT
  'CPC' AS type,
  ${hiveconf:start_date} AS start_date,
  ${hiveconf:end_date} AS end_date,
  SUM(price)*30/100 AS total_price, -- в рублях
  -- коэффициент конверии был получен за период 10.10.16-10.11.16
  -- с помощью запроса src/SQL/conversion_for_10498025.sql
  SUM(offer_price)*0.0117 AS total_offer_price -- в рублях
FROM robot_market_logs.clicks
WHERE
  hyper_cat_id = 10498025 AND -- Умные часы и браслеты
  day BETWEEN ${hiveconf:start_date} AND ${hiveconf:end_date} AND
  filter = 0 AND -- убираем накрутку
  state = 1 AND -- убираем яндекс пользователей
  hyper_id > 0 -- ПОЧЕМУ есть неприматченные клики???