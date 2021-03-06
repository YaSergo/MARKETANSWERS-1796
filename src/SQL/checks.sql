-- в отчёте получилось 683 650 моделей на 2016-11-11
-- проверяем простым запросом:
SELECT COUNT(DISTINCT model_id)
FROM
medintsev.ma1796_fee_thresholds LEFT JOIN (
  SELECT category_id, model_id
  FROM dictionaries.offers 
  WHERE
    priority_regions = 213 AND -- смотрим только по Москве
    binary_price_price IS NOT NULL AND -- убираем предложения, где цена не указана
    day = '2016-11-11'
) a
ON ma1796_fee_thresholds.hid = a.category_id

-- 11.11.16 18:18
683650
-- сходится


-- проверка, что яйцеварки (411499) больше не гуру категория
SELECT model_id, COUNT(*) as num_offers
FROM dictionaries.offers
WHERE
  category_id = 411499 AND
  day = '2016-11-11'
GROUP BY
  model_id
-- результат:
-- только model_id == 0 в количестве 7601
-- то есть в данной категории нет ни одного предложения, которое привязано к КМ. Что является косвенным фактором, что это не гуру категория.
-- Каким образом, явно выяснить тип категории?

-- пытаюсь разобраться с binary_price_price IS NULL
SELECT
  SUM(IF(binary_price_price IS NULL,1,0)) as num_NULL_price,
  COUNT(*) as total_num_offers,
  SUM(IF(binary_price_price IS NULL,1,0))/COUNT(*) as rate
FROM
  medintsev.ma1796_fee_thresholds LEFT JOIN
  (
    SELECT *
    FROM dictionaries.offers 
    WHERE
      priority_regions = 213 AND -- смотрим только по Москве
      day = '2016-11-11'
  ) a
  ON ma1796_fee_thresholds.hid = a.category_id