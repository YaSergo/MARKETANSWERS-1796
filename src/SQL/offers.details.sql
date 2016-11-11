SELECT
  category_id,
  name,
  fee_threshold,
  COUNT(*) AS num_models,

  -- до ввода порога
  SUM(IF(num_cpa_offers >= 6, 1, 0)) AS before_6,
  SUM(IF(num_cpa_offers  = 5, 1, 0)) AS before_5,
  SUM(IF(num_cpa_offers  = 4, 1, 0)) AS before_4,
  SUM(IF(num_cpa_offers  = 3, 1, 0)) AS before_3,
  SUM(IF(num_cpa_offers  = 2, 1, 0)) AS before_2,
  SUM(IF(num_cpa_offers  = 1, 1, 0)) AS before_1,

  -- после ввода порога
  SUM(IF(num_cpa_offers_gtt >= 6, 1, 0)) AS after_6,
  SUM(IF(num_cpa_offers_gtt  = 5, 1, 0)) AS after_5,
  SUM(IF(num_cpa_offers_gtt  = 4, 1, 0)) AS after_4,
  SUM(IF(num_cpa_offers_gtt  = 3, 1, 0)) AS after_3,
  SUM(IF(num_cpa_offers_gtt  = 2, 1, 0)) AS after_2,
  SUM(IF(num_cpa_offers_gtt  = 1, 1, 0)) AS after_1,

  -- после ввода порога с учётом "правила трёх"
  SUM(IF(num_cpa_offers_gtt >= 6, 1, 0)) AS after3_6,
  SUM(IF(num_cpa_offers_gtt  = 5, 1, 0)) AS after3_5,
  SUM(IF(num_cpa_offers_gtt  = 4, 1, 0)) AS after3_4,
  SUM(IF(num_cpa_offers_gtt  = 3, 1, 0)) + SUM(IF(num_cpa_offers_gtt = 0 AND num_cpa_offers >= 3, 1, 0)) AS after3_3,
  SUM(IF(num_cpa_offers_gtt  = 2, 1, 0)) + SUM(IF(num_cpa_offers_gtt = 0 AND num_cpa_offers  = 2, 1, 0)) AS after3_2,
  SUM(IF(num_cpa_offers_gtt  = 1, 1, 0)) + SUM(IF(num_cpa_offers_gtt = 0 AND num_cpa_offers  = 1, 1, 0)) AS after3_1
FROM
  (
  SELECT
    category_id,
    model_id,
    priority_regions,
    fee_threshold,
    -- SUM(IF(is_cpa, 0, 1)) AS num_cpc_offers,  -- количество CPC предложений
    SUM(IF(is_cpa, 1, 0)) AS num_cpa_offers,  -- количество CPA предложений
    -- количество CPA предложений, которые превышают порог по fee
    -- fee в 2% offers записывается как 200, поэтому для сравнения использую деление на 10000
    SUM(IF(is_cpa AND fee/10000 >= fee_threshold, 1, 0)) AS num_cpa_offers_gtt 
  FROM
  (
    SELECT *
    FROM dictionaries.offers
    WHERE
      priority_regions = 213 AND -- смотрим только по Москве
      binary_price_price IS NOT NULL AND -- убираем предложения, где цена не указана
      day = '2016-11-11' AND -- в дальнейшем можно взять больше дней и сгладить статистику
      model_id > 0 -- 20161111 Илья: смотрим на предложения, только привязанные к КМ
  -- пороги fee взяты от сюда: https://marmot.hdp.yandex.net/beeswax/execute/query/121825#query/logs
  ) offers RIGHT JOIN medintsev.ma1796_fee_thresholds fee_thresholds
  ON offers.category_id = fee_thresholds.hid
  GROUP BY
    category_id,
    model_id,
    priority_regions,
    fee_threshold
  ) a LEFT JOIN dictionaries.categories AS categories -- подтягиваем названия категорий
  ON a.category_id = categories.hyper_id
GROUP BY
  category_id,
  name,
  fee_threshold