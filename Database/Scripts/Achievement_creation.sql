-- ---------------------------------------------------------
-- Achievement-Set 1: Fine Dust Sentinel
-- Conditions (ids 7-9)
INSERT INTO Condition (id, type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold) VALUES
(7,  4, 1, NULL, NULL, NULL, NULL, '>=', 40),
(8,  4, 1, NULL, NULL, NULL, NULL, '>=', 60),
(9,  4, 1, NULL, NULL, NULL, NULL, '>=', 80);

-- Trigger (ids 19-21)
INSERT INTO Trigger (id, description, cron, time_once, active, last_triggered_at) VALUES
(19, 'Fine Dust Sentinel I',   NULL, NULL, TRUE, NULL),
(20, 'Fine Dust Sentinel II',  NULL, NULL, TRUE, NULL),
(21, 'Fine Dust Sentinel III', NULL, NULL, TRUE, NULL);

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(19, 7),
(20, 8),
(21, 9);

-- Tiers (ids 1-3)
INSERT INTO Achievement_Tier (id, reward_xp, image_url, trigger_id) VALUES
(1, 10, '/WebPush-PWA/files/icons/achievements/FDS_1.png', 19),
(2, 20, '/WebPush-PWA/files/icons/achievements/FDS_2.png', 20),
(3, 40, '/WebPush-PWA/files/icons/achievements/FDS_3.png', 21);

-- Set (id 1)
INSERT INTO Achievement_Set (id, title, description, body, tier1_id, tier2_id, tier3_id) VALUES
(1, 'Fine Dust Sentinel',
    'Capture extremely high PM2.5 values.',
    'Next tier achieved for Fine Dust Sentinel! Another extreme PM2.5 reading logged.',
    1, 2, 3);

-- ---------------------------------------------------------
-- Achievement-Set 2: Pure Air Guardian
INSERT INTO Condition (id, type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold) VALUES
(10, 3, 1, NULL, NULL, NULL, NULL, '<=', 15),
(11, 3, 1, NULL, NULL, NULL, NULL, '<=', 10),
(12, 3, 1, NULL, NULL, NULL, NULL, '<=', 5);

INSERT INTO Trigger (id, description, cron, time_once, active, last_triggered_at) VALUES
(22, 'Pure Air Guardian I',   NULL, NULL, TRUE, NULL),
(23, 'Pure Air Guardian II',  NULL, NULL, TRUE, NULL),
(24, 'Pure Air Guardian III', NULL, NULL, TRUE, NULL);

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(22, 10),
(23, 11),
(24, 12);

INSERT INTO Achievement_Tier (id, reward_xp, image_url, trigger_id) VALUES
(4, 10, '/WebPush-PWA/files/icons/achievements/PAG_1.png', 22),
(5, 20, '/WebPush-PWA/files/icons/achievements/PAG_2.png', 23),
(6, 40, '/WebPush-PWA/files/icons/achievements/PAG_3.png', 24);

INSERT INTO Achievement_Set (id, title, description, body, tier1_id, tier2_id, tier3_id) VALUES
(2, 'Pure Air Guardian',
    'Measured ultra-low fine particle pollution.',
    'You’ve hit the next tier of Pure Air Guardian! PM2.5 is exceptionally low again.',
    4, 5, 6);

-- ---------------------------------------------------------
-- Achievement-Set 3: Dust Peak Detector
INSERT INTO Condition (id, type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold) VALUES
(13, 6, 1, NULL, NULL, NULL, NULL, '>=', 50),
(14, 6, 1, NULL, NULL, NULL, NULL, '>=', 100),
(15, 6, 1, NULL, NULL, NULL, NULL, '>=', 150);

INSERT INTO Trigger (id, description, cron, time_once, active, last_triggered_at) VALUES
(25, 'Dust Peak Detector I',   NULL, NULL, TRUE, NULL),
(26, 'Dust Peak Detector II',  NULL, NULL, TRUE, NULL),
(27, 'Dust Peak Detector III', NULL, NULL, TRUE, NULL);

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(25, 13),
(26, 14),
(27, 15);

INSERT INTO Achievement_Tier (id, reward_xp, image_url, trigger_id) VALUES
(7, 10, '/WebPush-PWA/files/icons/achievements/DPD_1.png', 25),
(8, 20, '/WebPush-PWA/files/icons/achievements/DPD_2.png', 26),
(9, 40, '/WebPush-PWA/files/icons/achievements/DPD_3.png', 27);

INSERT INTO Achievement_Set (id, title, description, body, tier1_id, tier2_id, tier3_id) VALUES
(3, 'Dust Peak Detector',
    'Recorded unusually high PM10 concentrations.',
    'New tier reached: Dust Peak Detector! You recorded another major PM10 peak.',
    7, 8, 9);

-- ---------------------------------------------------------
-- Achievement-Set 4: Clean Air Spotter
INSERT INTO Condition (id, type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold) VALUES
(16, 5, 1, NULL, NULL, NULL, NULL, '<=', 5),
(17, 5, 1, NULL, NULL, NULL, NULL, '<=', 10),
(18, 5, 1, NULL, NULL, NULL, NULL, '<=', 15);

INSERT INTO Trigger (id, description, cron, time_once, active, last_triggered_at) VALUES
(28, 'Clean Air Spotter I',   NULL, NULL, TRUE, NULL),
(29, 'Clean Air Spotter II',  NULL, NULL, TRUE, NULL),
(30, 'Clean Air Spotter III', NULL, NULL, TRUE, NULL);

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(28, 16),
(29, 17),
(30, 18);

INSERT INTO Achievement_Tier (id, reward_xp, image_url, trigger_id) VALUES
(10, 10, '/WebPush-PWA/files/icons/achievements/CAS_1.png', 28),
(11, 20, '/WebPush-PWA/files/icons/achievements/CAS_2.png', 29),
(12, 40, '/WebPush-PWA/files/icons/achievements/CAS_3.png', 30);

-- Achtung: In der Datei steht hier als Set-Titel/Description/Body nochmal "Fine Dust Sentinel" (wir übernehmen es 1:1).
INSERT INTO Achievement_Set (id, title, description, body, tier1_id, tier2_id, tier3_id) VALUES
(4, 'Fine Dust Sentinel',
    'Capture extremely high PM2.5 values.',
    'Next tier achieved for Fine Dust Sentinel! Another extreme PM2.5 reading logged.',
    10, 11, 12);

-- ---------------------------------------------------------
-- Achievement-Set 5: Marathon Mapper
INSERT INTO Condition (id, type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold) VALUES
(19, 9, 1, NULL, NULL, NULL, NULL, '>=', 50),
(20, 9, 1, NULL, NULL, NULL, NULL, '>=', 100),
(21, 9, 1, NULL, NULL, NULL, NULL, '>=', 250);

INSERT INTO Trigger (id, description, cron, time_once, active, last_triggered_at) VALUES
(31, 'Marathon Mapper I',   NULL, NULL, TRUE, NULL),
(32, 'Marathon Mapper II',  NULL, NULL, TRUE, NULL),
(33, 'Marathon Mapper III', NULL, NULL, TRUE, NULL);

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(31, 19),
(32, 20),
(33, 21);

INSERT INTO Achievement_Tier (id, reward_xp, image_url, trigger_id) VALUES
(13, 10, '/WebPush-PWA/files/icons/achievements/MM_1.png', 31),
(14, 20, '/WebPush-PWA/files/icons/achievements/MM_2.png', 32),
(15, 40, '/WebPush-PWA/files/icons/achievements/MM_3.png', 33);

INSERT INTO Achievement_Set (id, title, description, body, tier1_id, tier2_id, tier3_id) VALUES
(5, 'Marathon Mapper',
    'Covered an impressive amount of distance while collecting data.',
    'Great progress! You reached a new Marathon Mapper tier by covering even more distance.',
    13, 14, 15);

-- ---------------------------------------------------------
-- Achievement-Set 6: Unbroken Flame
INSERT INTO Condition (id, type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold) VALUES
(22, 2, 1, NULL, NULL, NULL, NULL, '>=', 50),
(23, 2, 1, NULL, NULL, NULL, NULL, '>=', 250),
(24, 2, 1, NULL, NULL, NULL, NULL, '>=', 1000);

INSERT INTO Trigger (id, description, cron, time_once, active, last_triggered_at) VALUES
(34, 'Unbroken Flame I',   NULL, NULL, TRUE, NULL),
(35, 'Unbroken Flame II',  NULL, NULL, TRUE, NULL),
(36, 'Unbroken Flame III', NULL, NULL, TRUE, NULL);

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(34, 22),
(35, 23),
(36, 24);

INSERT INTO Achievement_Tier (id, reward_xp, image_url, trigger_id) VALUES
(16, 10, '/WebPush-PWA/files/icons/achievements/UF_1.png', 34),
(17, 20, '/WebPush-PWA/files/icons/achievements/UF_2.png', 35),
(18, 40, '/WebPush-PWA/files/icons/achievements/UF_3.png', 36);

INSERT INTO Achievement_Set (id, title, description, body, tier1_id, tier2_id, tier3_id) VALUES
(6, 'Unbroken Flame',
    'Maintained a long, unbroken series of measurements.',
    'Your streak keeps burning! You`ve reached the next Unbroken Flame tier.',
    16, 17, 18);

-- ---------------------------------------------------------
-- Achievement-Set 7: Deep Freeze Explorer
INSERT INTO Condition (id, type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold) VALUES
(25, 7, 1, NULL, NULL, NULL, NULL, '<=', 10),
(26, 7, 1, NULL, NULL, NULL, NULL, '<=', 0),
(27, 7, 1, NULL, NULL, NULL, NULL, '<=', -10);

INSERT INTO Trigger (id, description, cron, time_once, active, last_triggered_at) VALUES
(37, 'Deep Freeze Explorer I',   NULL, NULL, TRUE, NULL),
(38, 'Deep Freeze Explorer II',  NULL, NULL, TRUE, NULL),
(39, 'Deep Freeze Explorer III', NULL, NULL, TRUE, NULL);

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(37, 25),
(38, 26),
(39, 27);

INSERT INTO Achievement_Tier (id, reward_xp, image_url, trigger_id) VALUES
(19, 10, '/WebPush-PWA/files/icons/achievements/DFE_1.png', 37),
(20, 20, '/WebPush-PWA/files/icons/achievements/DFE_2.png', 38),
(21, 40, '/WebPush-PWA/files/icons/achievements/DFE_3.png', 39);

INSERT INTO Achievement_Set (id, title, description, body, tier1_id, tier2_id, tier3_id) VALUES
(7, 'Deep Freeze Explorer',
    'Collected data in extremely cold conditions.',
    'Next tier achieved: Deep Freeze Explorer! Your cold-weather measurements keep getting stronger.',
    19, 20, 21);

-- ---------------------------------------------------------
-- Achievement-Set 8: Extreme Heat Scout
INSERT INTO Condition (id, type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold) VALUES
(28, 8, 1, NULL, NULL, NULL, NULL, '>=', 25),
(29, 8, 1, NULL, NULL, NULL, NULL, '>=', 32),
(30, 8, 1, NULL, NULL, NULL, NULL, '>=', 40);

INSERT INTO Trigger (id, description, cron, time_once, active, last_triggered_at) VALUES
(40, 'Extreme Heat Scout I',   NULL, NULL, TRUE, NULL),
(41, 'Extreme Heat Scout II',  NULL, NULL, TRUE, NULL),
(42, 'Extreme Heat Scout III', NULL, NULL, TRUE, NULL);

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(40, 28),
(41, 29),
(42, 30);

INSERT INTO Achievement_Tier (id, reward_xp, image_url, trigger_id) VALUES
(22, 10, '/WebPush-PWA/files/icons/achievements/EHS_1.png', 40),
(23, 20, '/WebPush-PWA/files/icons/achievements/EHS_2.png', 41),
(24, 40, '/WebPush-PWA/files/icons/achievements/EHS_3.png', 42);

INSERT INTO Achievement_Set (id, title, description, body, tier1_id, tier2_id, tier3_id) VALUES
(8, 'Extreme Heat Scout',
    'Measured air quality during exceptionally high temperatures.',
    'You`ve reached the next tier of Extreme Heat Scout! Your measurements in extreme heat are leveling up.',
    22, 23, 24);

-- ---------------------------------------------------------
-- Achievement-Set 9: Night Shift Monitor
INSERT INTO Condition (id, type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold) VALUES
(31, 11, 8, NULL, NULL, '20:00:00', '23:59:59', '>=', 8),
(32, 11, 8, NULL, NULL, '20:00:00', '23:59:59', '>=', 25),
(33, 11, 8, NULL, NULL, '20:00:00', '23:59:59', '>=', 50);

INSERT INTO Trigger (id, description, cron, time_once, active, last_triggered_at) VALUES
(43, 'Night Shift Monitor I',   NULL, NULL, TRUE, NULL),
(44, 'Night Shift Monitor II',  NULL, NULL, TRUE, NULL),
(45, 'Night Shift Monitor III', NULL, NULL, TRUE, NULL);

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(43, 31),
(44, 32),
(45, 33);

INSERT INTO Achievement_Tier (id, reward_xp, image_url, trigger_id) VALUES
(25, 10, '/WebPush-PWA/files/icons/achievements/NSM_1.png', 43),
(26, 20, '/WebPush-PWA/files/icons/achievements/NSM_2.png', 44),
(27, 40, '/WebPush-PWA/files/icons/achievements/NSM_3.png', 45);

INSERT INTO Achievement_Set (id, title, description, body, tier1_id, tier2_id, tier3_id) VALUES
(9, 'Night Shift Monitor',
    'Performed measurements deep into the night.(8pm-12pm)',
    'Another night, another tier! Night Shift Monitor has reached the next level.',
    25, 26, 27);

-- ---------------------------------------------------------
-- Achievement-Set 10: Dawn Tracker
INSERT INTO Condition (id, type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold) VALUES
(34, 11, 8, NULL, NULL, '02:00:00', '06:00:00', '>=', 10),
(35, 11, 8, NULL, NULL, '02:00:00', '06:00:00', '>=', 25),
(36, 11, 8, NULL, NULL, '02:00:00', '06:00:00', '>=', 50);

INSERT INTO Trigger (id, description, cron, time_once, active, last_triggered_at) VALUES
(46, 'Dawn Tracker I',   NULL, NULL, TRUE, NULL),
(47, 'Dawn Tracker II',  NULL, NULL, TRUE, NULL),
(48, 'Dawn Tracker III', NULL, NULL, TRUE, NULL);

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(46, 34),
(47, 35),
(48, 36);

INSERT INTO Achievement_Tier (id, reward_xp, image_url, trigger_id) VALUES
(28, 10, '/WebPush-PWA/files/icons/achievements/DT_1.png', 46),
(29, 20, '/WebPush-PWA/files/icons/achievements/DT_2.png', 47),
(30, 40, '/WebPush-PWA/files/icons/achievements/DT_3.png', 48);

INSERT INTO Achievement_Set (id, title, description, body, tier1_id, tier2_id, tier3_id) VALUES
(10, 'Dawn Tracker',
     'Collected data at the earliest hours of the day.(2am-6am)',
     'You advanced to a new Dawn Tracker tier by measuring at dawn again.',
     28, 29, 30);
