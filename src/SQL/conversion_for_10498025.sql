select
  sum(Sign) as visits,
  sum(Sign*arrayExists(x -> x in _goals,Goals.ID)) as goal_visits
from visits_all
where
  CounterID in _counters and
  StartDate BETWEEN '2016-11-01' AND '2016-11-10' and
  ClickMarketCategoryID = 10498025 and -- Умные часы и браслеты
  IsRobot = 0