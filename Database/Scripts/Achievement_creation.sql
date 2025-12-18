BEGIN;
-- =========================================================
-- Achievement-Set 1: Fine Dust Sentinel
-- =========================================================
WITH
c_ins AS (
  INSERT INTO Condition(type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold)
  VALUES
    (4,1,NULL,NULL,NULL,NULL,'>=',40),
    (4,1,NULL,NULL,NULL,NULL,'>=',60),
    (4,1,NULL,NULL,NULL,NULL,'>=',80)
  RETURNING id, threshold
),
c AS (
  SELECT id, row_number() OVER (ORDER BY threshold) rn
  FROM c_ins
),
t_ins AS (
  INSERT INTO Trigger(description, cron, time_once, active, last_triggered_at)
  VALUES
    ('Fine Dust Sentinel I',NULL,NULL,TRUE,NULL),
    ('Fine Dust Sentinel II',NULL,NULL,TRUE,NULL),
    ('Fine Dust Sentinel III',NULL,NULL,TRUE,NULL)
  RETURNING id, description
),
t AS (
  SELECT id, row_number() OVER (ORDER BY description) rn
  FROM t_ins
),
tc AS (
  INSERT INTO Trigger_Condition(trigger_id, condition_id)
  SELECT t.id, c.id
  FROM t JOIN c USING (rn)
),
tier_ins AS (
  INSERT INTO Achievement_Tier(reward_xp, image_url, trigger_id)
  SELECT v.reward_xp, v.image_url, t.id
  FROM (VALUES
    (1,10,'/WebPush-PWA/files/icons/achievements/FDS_1.png'),
    (2,20,'/WebPush-PWA/files/icons/achievements/FDS_2.png'),
    (3,40,'/WebPush-PWA/files/icons/achievements/FDS_3.png')
  ) v(rn, reward_xp, image_url)
  JOIN t USING (rn)
  RETURNING id, reward_xp
),
tier AS (
  SELECT id, row_number() OVER (ORDER BY reward_xp) rn
  FROM tier_ins
)
INSERT INTO Achievement_Set(title, description, body, tier1_id, tier2_id, tier3_id)
SELECT
  'Fine Dust Sentinel',
  'Capture extremely high PM2.5 values.',
  'Next tier achieved for Fine Dust Sentinel! Another extreme PM2.5 reading logged.',
  max(id) FILTER (WHERE rn=1),
  max(id) FILTER (WHERE rn=2),
  max(id) FILTER (WHERE rn=3)
FROM tier;

-- =========================================================
-- Achievement-Set 2: Pure Air Guardian
-- =========================================================
WITH
c_ins AS (
  INSERT INTO Condition(type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold)
  VALUES
    (3,1,NULL,NULL,NULL,NULL,'<=',15),
    (3,1,NULL,NULL,NULL,NULL,'<=',10),
    (3,1,NULL,NULL,NULL,NULL,'<=',5)
  RETURNING id, threshold
),
c AS (
  SELECT id, row_number() OVER (ORDER BY threshold DESC) rn
  FROM c_ins
),
t_ins AS (
  INSERT INTO Trigger(description, cron, time_once, active, last_triggered_at)
  VALUES
    ('Pure Air Guardian I',NULL,NULL,TRUE,NULL),
    ('Pure Air Guardian II',NULL,NULL,TRUE,NULL),
    ('Pure Air Guardian III',NULL,NULL,TRUE,NULL)
  RETURNING id, description
),
t AS (
  SELECT id, row_number() OVER (ORDER BY description) rn
  FROM t_ins
),
tc AS (
  INSERT INTO Trigger_Condition(trigger_id, condition_id)
  SELECT t.id, c.id
  FROM t JOIN c USING (rn)
),
tier_ins AS (
  INSERT INTO Achievement_Tier(reward_xp, image_url, trigger_id)
  SELECT v.reward_xp, v.image_url, t.id
  FROM (VALUES
    (1,10,'/WebPush-PWA/files/icons/achievements/PAG_1.png'),
    (2,20,'/WebPush-PWA/files/icons/achievements/PAG_2.png'),
    (3,40,'/WebPush-PWA/files/icons/achievements/PAG_3.png')
  ) v(rn, reward_xp, image_url)
  JOIN t USING (rn)
  RETURNING id, reward_xp
),
tier AS (
  SELECT id, row_number() OVER (ORDER BY reward_xp) rn
  FROM tier_ins
)
INSERT INTO Achievement_Set(title, description, body, tier1_id, tier2_id, tier3_id)
SELECT
  'Pure Air Guardian',
  'Measured ultra-low fine particle pollution.',
  'You’ve hit the next tier of Pure Air Guardian! PM2.5 is exceptionally low again.',
  max(id) FILTER (WHERE rn=1),
  max(id) FILTER (WHERE rn=2),
  max(id) FILTER (WHERE rn=3)
FROM tier;

-- =========================================================
-- Achievement-Set 3: Dust Peak Detector
-- =========================================================
WITH
c_ins AS (
  INSERT INTO Condition(type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold)
  VALUES
    (6,1,NULL,NULL,NULL,NULL,'>=',50),
    (6,1,NULL,NULL,NULL,NULL,'>=',100),
    (6,1,NULL,NULL,NULL,NULL,'>=',150)
  RETURNING id, threshold
),
c AS (
  SELECT id, row_number() OVER (ORDER BY threshold) rn
  FROM c_ins
),
t_ins AS (
  INSERT INTO Trigger(description, cron, time_once, active, last_triggered_at)
  VALUES
    ('Dust Peak Detector I',NULL,NULL,TRUE,NULL),
    ('Dust Peak Detector II',NULL,NULL,TRUE,NULL),
    ('Dust Peak Detector III',NULL,NULL,TRUE,NULL)
  RETURNING id, description
),
t AS (
  SELECT id, row_number() OVER (ORDER BY description) rn
  FROM t_ins
),
tc AS (
  INSERT INTO Trigger_Condition(trigger_id, condition_id)
  SELECT t.id, c.id
  FROM t JOIN c USING (rn)
),
tier_ins AS (
  INSERT INTO Achievement_Tier(reward_xp, image_url, trigger_id)
  SELECT v.reward_xp, v.image_url, t.id
  FROM (VALUES
    (1,10,'/WebPush-PWA/files/icons/achievements/DPD_1.png'),
    (2,20,'/WebPush-PWA/files/icons/achievements/DPD_2.png'),
    (3,40,'/WebPush-PWA/files/icons/achievements/DPD_3.png')
  ) v(rn, reward_xp, image_url)
  JOIN t USING (rn)
  RETURNING id, reward_xp
),
tier AS (
  SELECT id, row_number() OVER (ORDER BY reward_xp) rn
  FROM tier_ins
)
INSERT INTO Achievement_Set(title, description, body, tier1_id, tier2_id, tier3_id)
SELECT
  'Dust Peak Detector',
  'Recorded unusually high PM10 concentrations.',
  'New tier reached: Dust Peak Detector! You recorded another major PM10 peak.',
  max(id) FILTER (WHERE rn=1),
  max(id) FILTER (WHERE rn=2),
  max(id) FILTER (WHERE rn=3)
FROM tier;

-- =========================================================
-- Achievement-Set 4: Clean Air Spotter (Achtung: Set-Titel/Texts wie im Original "Fine Dust Sentinel")
-- =========================================================
WITH
c_ins AS (
  INSERT INTO Condition(type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold)
  VALUES
    (5,1,NULL,NULL,NULL,NULL,'<=',5),
    (5,1,NULL,NULL,NULL,NULL,'<=',10),
    (5,1,NULL,NULL,NULL,NULL,'<=',15)
  RETURNING id, threshold
),
c AS (
  SELECT id, row_number() OVER (ORDER BY threshold DESC) rn
  FROM c_ins
),
t_ins AS (
  INSERT INTO Trigger(description, cron, time_once, active, last_triggered_at)
  VALUES
    ('Clean Air Spotter I',NULL,NULL,TRUE,NULL),
    ('Clean Air Spotter II',NULL,NULL,TRUE,NULL),
    ('Clean Air Spotter III',NULL,NULL,TRUE,NULL)
  RETURNING id, description
),
t AS (
  SELECT id, row_number() OVER (ORDER BY description) rn
  FROM t_ins
),
tc AS (
  INSERT INTO Trigger_Condition(trigger_id, condition_id)
  SELECT t.id, c.id
  FROM t JOIN c USING (rn)
),
tier_ins AS (
  INSERT INTO Achievement_Tier(reward_xp, image_url, trigger_id)
  SELECT v.reward_xp, v.image_url, t.id
  FROM (VALUES
    (1,10,'/WebPush-PWA/files/icons/achievements/CAS_1.png'),
    (2,20,'/WebPush-PWA/files/icons/achievements/CAS_2.png'),
    (3,40,'/WebPush-PWA/files/icons/achievements/CAS_3.png')
  ) v(rn, reward_xp, image_url)
  JOIN t USING (rn)
  RETURNING id, reward_xp
),
tier AS (
  SELECT id, row_number() OVER (ORDER BY reward_xp) rn
  FROM tier_ins
)
INSERT INTO Achievement_Set(title, description, body, tier1_id, tier2_id, tier3_id)
SELECT
  'Fine Dust Sentinel',
  'Capture extremely high PM2.5 values.',
  'Next tier achieved for Fine Dust Sentinel! Another extreme PM2.5 reading logged.',
  max(id) FILTER (WHERE rn=1),
  max(id) FILTER (WHERE rn=2),
  max(id) FILTER (WHERE rn=3)
FROM tier;

-- =========================================================
-- Achievement-Set 5: Marathon Mapper
-- =========================================================
WITH
c_ins AS (
  INSERT INTO Condition(type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold)
  VALUES
    (9,1,NULL,NULL,NULL,NULL,'>=',50),
    (9,1,NULL,NULL,NULL,NULL,'>=',100),
    (9,1,NULL,NULL,NULL,NULL,'>=',250)
  RETURNING id, threshold
),
c AS (
  SELECT id, row_number() OVER (ORDER BY threshold) rn
  FROM c_ins
),
t_ins AS (
  INSERT INTO Trigger(description, cron, time_once, active, last_triggered_at)
  VALUES
    ('Marathon Mapper I',NULL,NULL,TRUE,NULL),
    ('Marathon Mapper II',NULL,NULL,TRUE,NULL),
    ('Marathon Mapper III',NULL,NULL,TRUE,NULL)
  RETURNING id, description
),
t AS (
  SELECT id, row_number() OVER (ORDER BY description) rn
  FROM t_ins
),
tc AS (
  INSERT INTO Trigger_Condition(trigger_id, condition_id)
  SELECT t.id, c.id
  FROM t JOIN c USING (rn)
),
tier_ins AS (
  INSERT INTO Achievement_Tier(reward_xp, image_url, trigger_id)
  SELECT v.reward_xp, v.image_url, t.id
  FROM (VALUES
    (1,10,'/WebPush-PWA/files/icons/achievements/MM_1.png'),
    (2,20,'/WebPush-PWA/files/icons/achievements/MM_2.png'),
    (3,40,'/WebPush-PWA/files/icons/achievements/MM_3.png')
  ) v(rn, reward_xp, image_url)
  JOIN t USING (rn)
  RETURNING id, reward_xp
),
tier AS (
  SELECT id, row_number() OVER (ORDER BY reward_xp) rn
  FROM tier_ins
)
INSERT INTO Achievement_Set(title, description, body, tier1_id, tier2_id, tier3_id)
SELECT
  'Marathon Mapper',
  'Covered an impressive amount of distance while collecting data.',
  'Great progress! You reached a new Marathon Mapper tier by covering even more distance.',
  max(id) FILTER (WHERE rn=1),
  max(id) FILTER (WHERE rn=2),
  max(id) FILTER (WHERE rn=3)
FROM tier;

-- =========================================================
-- Achievement-Set 6: Unbroken Flame
-- =========================================================
WITH
c_ins AS (
  INSERT INTO Condition(type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold)
  VALUES
    (2,1,NULL,NULL,NULL,NULL,'>=',50),
    (2,1,NULL,NULL,NULL,NULL,'>=',250),
    (2,1,NULL,NULL,NULL,NULL,'>=',1000)
  RETURNING id, threshold
),
c AS (
  SELECT id, row_number() OVER (ORDER BY threshold) rn
  FROM c_ins
),
t_ins AS (
  INSERT INTO Trigger(description, cron, time_once, active, last_triggered_at)
  VALUES
    ('Unbroken Flame I',NULL,NULL,TRUE,NULL),
    ('Unbroken Flame II',NULL,NULL,TRUE,NULL),
    ('Unbroken Flame III',NULL,NULL,TRUE,NULL)
  RETURNING id, description
),
t AS (
  SELECT id, row_number() OVER (ORDER BY description) rn
  FROM t_ins
),
tc AS (
  INSERT INTO Trigger_Condition(trigger_id, condition_id)
  SELECT t.id, c.id
  FROM t JOIN c USING (rn)
),
tier_ins AS (
  INSERT INTO Achievement_Tier(reward_xp, image_url, trigger_id)
  SELECT v.reward_xp, v.image_url, t.id
  FROM (VALUES
    (1,10,'/WebPush-PWA/files/icons/achievements/UF_1.png'),
    (2,20,'/WebPush-PWA/files/icons/achievements/UF_2.png'),
    (3,40,'/WebPush-PWA/files/icons/achievements/UF_3.png')
  ) v(rn, reward_xp, image_url)
  JOIN t USING (rn)
  RETURNING id, reward_xp
),
tier AS (
  SELECT id, row_number() OVER (ORDER BY reward_xp) rn
  FROM tier_ins
)
INSERT INTO Achievement_Set(title, description, body, tier1_id, tier2_id, tier3_id)
SELECT
  'Unbroken Flame',
  'Maintained a long, unbroken series of measurements.',
  'Your streak keeps burning! You`ve reached the next Unbroken Flame tier.',
  max(id) FILTER (WHERE rn=1),
  max(id) FILTER (WHERE rn=2),
  max(id) FILTER (WHERE rn=3)
FROM tier;

-- =========================================================
-- Achievement-Set 7: Deep Freeze Explorer
-- =========================================================
WITH
c_ins AS (
  INSERT INTO Condition(type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold)
  VALUES
    (7,1,NULL,NULL,NULL,NULL,'<=',10),
    (7,1,NULL,NULL,NULL,NULL,'<=',0),
    (7,1,NULL,NULL,NULL,NULL,'<=',-10)
  RETURNING id, threshold
),
c AS (
  SELECT id, row_number() OVER (ORDER BY threshold DESC) rn
  FROM c_ins
),
t_ins AS (
  INSERT INTO Trigger(description, cron, time_once, active, last_triggered_at)
  VALUES
    ('Deep Freeze Explorer I',NULL,NULL,TRUE,NULL),
    ('Deep Freeze Explorer II',NULL,NULL,TRUE,NULL),
    ('Deep Freeze Explorer III',NULL,NULL,TRUE,NULL)
  RETURNING id, description
),
t AS (
  SELECT id, row_number() OVER (ORDER BY description) rn
  FROM t_ins
),
tc AS (
  INSERT INTO Trigger_Condition(trigger_id, condition_id)
  SELECT t.id, c.id
  FROM t JOIN c USING (rn)
),
tier_ins AS (
  INSERT INTO Achievement_Tier(reward_xp, image_url, trigger_id)
  SELECT v.reward_xp, v.image_url, t.id
  FROM (VALUES
    (1,10,'/WebPush-PWA/files/icons/achievements/DFE_1.png'),
    (2,20,'/WebPush-PWA/files/icons/achievements/DFE_2.png'),
    (3,40,'/WebPush-PWA/files/icons/achievements/DFE_3.png')
  ) v(rn, reward_xp, image_url)
  JOIN t USING (rn)
  RETURNING id, reward_xp
),
tier AS (
  SELECT id, row_number() OVER (ORDER BY reward_xp) rn
  FROM tier_ins
)
INSERT INTO Achievement_Set(title, description, body, tier1_id, tier2_id, tier3_id)
SELECT
  'Deep Freeze Explorer',
  'Collected data in extremely cold conditions.',
  'Next tier achieved: Deep Freeze Explorer! Your cold-weather measurements keep getting stronger.',
  max(id) FILTER (WHERE rn=1),
  max(id) FILTER (WHERE rn=2),
  max(id) FILTER (WHERE rn=3)
FROM tier;

-- =========================================================
-- Achievement-Set 8: Extreme Heat Scout
-- =========================================================
WITH
c_ins AS (
  INSERT INTO Condition(type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold)
  VALUES
    (8,1,NULL,NULL,NULL,NULL,'>=',25),
    (8,1,NULL,NULL,NULL,NULL,'>=',32),
    (8,1,NULL,NULL,NULL,NULL,'>=',40)
  RETURNING id, threshold
),
c AS (
  SELECT id, row_number() OVER (ORDER BY threshold) rn
  FROM c_ins
),
t_ins AS (
  INSERT INTO Trigger(description, cron, time_once, active, last_triggered_at)
  VALUES
    ('Extreme Heat Scout I',NULL,NULL,TRUE,NULL),
    ('Extreme Heat Scout II',NULL,NULL,TRUE,NULL),
    ('Extreme Heat Scout III',NULL,NULL,TRUE,NULL)
  RETURNING id, description
),
t AS (
  SELECT id, row_number() OVER (ORDER BY description) rn
  FROM t_ins
),
tc AS (
  INSERT INTO Trigger_Condition(trigger_id, condition_id)
  SELECT t.id, c.id
  FROM t JOIN c USING (rn)
),
tier_ins AS (
  INSERT INTO Achievement_Tier(reward_xp, image_url, trigger_id)
  SELECT v.reward_xp, v.image_url, t.id
  FROM (VALUES
    (1,10,'/WebPush-PWA/files/icons/achievements/EHS_1.png'),
    (2,20,'/WebPush-PWA/files/icons/achievements/EHS_2.png'),
    (3,40,'/WebPush-PWA/files/icons/achievements/EHS_3.png')
  ) v(rn, reward_xp, image_url)
  JOIN t USING (rn)
  RETURNING id, reward_xp
),
tier AS (
  SELECT id, row_number() OVER (ORDER BY reward_xp) rn
  FROM tier_ins
)
INSERT INTO Achievement_Set(title, description, body, tier1_id, tier2_id, tier3_id)
SELECT
  'Extreme Heat Scout',
  'Measured air quality during exceptionally high temperatures.',
  'You`ve reached the next tier of Extreme Heat Scout! Your measurements in extreme heat are leveling up.',
  max(id) FILTER (WHERE rn=1),
  max(id) FILTER (WHERE rn=2),
  max(id) FILTER (WHERE rn=3)
FROM tier;

-- =========================================================
-- Achievement-Set 9: Night Shift Monitor
-- =========================================================
WITH
c_ins AS (
  INSERT INTO Condition(type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold)
  VALUES
    (11,8,NULL,NULL,'20:00:00','23:59:59','>=',8),
    (11,8,NULL,NULL,'20:00:00','23:59:59','>=',25),
    (11,8,NULL,NULL,'20:00:00','23:59:59','>=',50)
  RETURNING id, threshold
),
c AS (
  SELECT id, row_number() OVER (ORDER BY threshold) rn
  FROM c_ins
),
t_ins AS (
  INSERT INTO Trigger(description, cron, time_once, active, last_triggered_at)
  VALUES
    ('Night Shift Monitor I',NULL,NULL,TRUE,NULL),
    ('Night Shift Monitor II',NULL,NULL,TRUE,NULL),
    ('Night Shift Monitor III',NULL,NULL,TRUE,NULL)
  RETURNING id, description
),
t AS (
  SELECT id, row_number() OVER (ORDER BY description) rn
  FROM t_ins
),
tc AS (
  INSERT INTO Trigger_Condition(trigger_id, condition_id)
  SELECT t.id, c.id
  FROM t JOIN c USING (rn)
),
tier_ins AS (
  INSERT INTO Achievement_Tier(reward_xp, image_url, trigger_id)
  SELECT v.reward_xp, v.image_url, t.id
  FROM (VALUES
    (1,10,'/WebPush-PWA/files/icons/achievements/NSM_1.png'),
    (2,20,'/WebPush-PWA/files/icons/achievements/NSM_2.png'),
    (3,40,'/WebPush-PWA/files/icons/achievements/NSM_3.png')
  ) v(rn, reward_xp, image_url)
  JOIN t USING (rn)
  RETURNING id, reward_xp
),
tier AS (
  SELECT id, row_number() OVER (ORDER BY reward_xp) rn
  FROM tier_ins
)
INSERT INTO Achievement_Set(title, description, body, tier1_id, tier2_id, tier3_id)
SELECT
  'Night Shift Monitor',
  'Performed measurements deep into the night.(8pm-12pm)',
  'Another night, another tier! Night Shift Monitor has reached the next level.',
  max(id) FILTER (WHERE rn=1),
  max(id) FILTER (WHERE rn=2),
  max(id) FILTER (WHERE rn=3)
FROM tier;

-- =========================================================
-- Achievement-Set 10: Dawn Tracker
-- =========================================================
WITH
c_ins AS (
  INSERT INTO Condition(type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold)
  VALUES
    (11,8,NULL,NULL,'02:00:00','06:00:00','>=',10),
    (11,8,NULL,NULL,'02:00:00','06:00:00','>=',25),
    (11,8,NULL,NULL,'02:00:00','06:00:00','>=',50)
  RETURNING id, threshold
),
c AS (
  SELECT id, row_number() OVER (ORDER BY threshold) rn
  FROM c_ins
),
t_ins AS (
  INSERT INTO Trigger(description, cron, time_once, active, last_triggered_at)
  VALUES
    ('Dawn Tracker I',NULL,NULL,TRUE,NULL),
    ('Dawn Tracker II',NULL,NULL,TRUE,NULL),
    ('Dawn Tracker III',NULL,NULL,TRUE,NULL)
  RETURNING id, description
),
t AS (
  SELECT id, row_number() OVER (ORDER BY description) rn
  FROM t_ins
),
tc AS (
  INSERT INTO Trigger_Condition(trigger_id, condition_id)
  SELECT t.id, c.id
  FROM t JOIN c USING (rn)
),
tier_ins AS (
  INSERT INTO Achievement_Tier(reward_xp, image_url, trigger_id)
  SELECT v.reward_xp, v.image_url, t.id
  FROM (VALUES
    (1,10,'/WebPush-PWA/files/icons/achievements/DT_1.png'),
    (2,20,'/WebPush-PWA/files/icons/achievements/DT_2.png'),
    (3,40,'/WebPush-PWA/files/icons/achievements/DT_3.png')
  ) v(rn, reward_xp, image_url)
  JOIN t USING (rn)
  RETURNING id, reward_xp
),
tier AS (
  SELECT id, row_number() OVER (ORDER BY reward_xp) rn
  FROM tier_ins
)
INSERT INTO Achievement_Set(title, description, body, tier1_id, tier2_id, tier3_id)
SELECT
  'Dawn Tracker',
  'Collected data at the earliest hours of the day.(2am-6am)',
  'You advanced to a new Dawn Tracker tier by measuring at dawn again.',
  max(id) FILTER (WHERE rn=1),
  max(id) FILTER (WHERE rn=2),
  max(id) FILTER (WHERE rn=3)
FROM tier;

COMMIT;
