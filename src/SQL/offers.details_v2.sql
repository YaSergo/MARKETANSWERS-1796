SELECT
  hyper_id,
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
    hyper_id,
    name,
    fee_threshold,
    model_id,
    SUM(IF(is_cpa, 1, 0)) AS num_cpa_offers,  -- количество CPA предложений
    -- количество CPA предложений, которые превышают порог по fee
    -- fee в 2% offers записывается как 200, поэтому для сравнения использую деление на 10000
    SUM(IF(is_cpa AND fee/10000 >= fee_threshold, 1, 0)) AS num_cpa_offers_gtt 
  FROM
  (
    SELECT -- список категорий с названиями и порогами по fee
      hyper_id,
      name,
      fee_threshold
    FROM
    (
      SELECT -- получаем названия категорий
        hyper_id, name
      FROM dictionaries.categories
      WHERE
        cpa_type = 'cpa_with_cpc_pessimization' AND
        hyper_id <> 411499 -- исключаем яйцеварки, подробнее: https://st.yandex-team.ru/MBI-19040
    ) cpa_categories LEFT JOIN medintsev.ma1796_fee_thresholds fee_thresholds
    ON cpa_categories.hyper_id = fee_thresholds.hid
  ) categories_details LEFT JOIN
  (
    SELECT *
    FROM dictionaries.offers
    WHERE
      priority_regions = 213 AND -- смотрим только по Москве
      binary_price_price IS NOT NULL AND -- убираем предложения, где цена не указана
      day = '2016-11-11' AND -- в дальнейшем можно взять больше дней и сгладить статистику
      model_id > 0 -- 20161111 Илья: смотрим на предложения, только привязанные к КМ
  ) offers_details
  ON categories_details.hyper_id = offers_details.category_id
  GROUP BY
    hyper_id,
    name,
    fee_threshold,
    model_id
) a
GROUP BY
  hyper_id,
  name,
  fee_threshold