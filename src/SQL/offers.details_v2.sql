SELECT *
FROM
(
  SELECT hyper_id, name
  FROM dictionaries.categories
  WHERE
    cpa_type = 'cpa_with_cpc_pessimization' AND
    hyper_id <> 411499 -- исключаем яйцеварки, подробнее: https://st.yandex-team.ru/MBI-19040
) cpa_categories LEFT JOIN medintsev.ma1796_fee_thresholds fee_thresholds
ON cpa_categories.hyper_id = fee_thresholds.hid
