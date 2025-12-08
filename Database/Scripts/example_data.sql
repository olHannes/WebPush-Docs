-- =========================================================
--  Beispiel-Datensätze für das neue Gamification-System
-- =========================================================

-- =========================================================
--  Member
-- =========================================================
INSERT INTO Member (name, endpoint, key, auth) VALUES
('Alice', 'https://endpoint/member1', 'keyA1', 'authA1'),
('Bob', 'https://endpoint/member2', 'keyB2', 'authB2'),
('Charlie', 'https://endpoint/member3', 'keyC3', 'authC3'),
('Diana', 'https://endpoint/member4', 'keyD4', 'authD4');

-- =========================================================
--  Groups
-- =========================================================
INSERT INTO "group" (data_table, name, picture_id, streak, level_xp, current_xp) VALUES
('sensor_table_m1', 'Sensor M1', 1, 3, 1, 55),
('sensor_table_m2', 'Sensor M2', 4, 7, 2, 140),
('sensor_table_m3', 'Sensor M3', 6, 1, 0, 10);

-- =========================================================
--  Group-Member Zuordnung
-- =========================================================
INSERT INTO Group_Member (member_id, group_id) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 3);

-- =========================================================
--  Trigger Beispiel
-- =========================================================
INSERT INTO Trigger (description, cron, time_once, active, last_triggered_at) VALUES
('Täglicher 8-Uhr-Check', '0 0 8 * * ?', NULL, TRUE, '2025-11-14 08:00:00.000'),
('Montags-Statistik-Trigger', '0 0 9 ? * MON', NULL, TRUE, '2025-11-10 09:00:00.000'),
('Datenbedingter Trigger', NULL, NULL, TRUE, NULL),
('Leaderboard Reset', '0 0 12 1 * ?', NULL, TRUE, NULL),
('Star Wars Tag', '0 38 11 4 MAY ?', NULL, TRUE, NULL),
('Frohe Weihnachten', '0 0 12 25 DEC ?', NULL, TRUE, NULL),
('Silvester', '0 0 12 31 DEC ?', NULL, TRUE, NULL),
('Neujahr', '0 0 0 1 JAN ?', NULL, TRUE, NULL),
('Valentinstag', '0 0 9 14 FEB ?', NULL, TRUE, NULL),
('Halloween', '0 0 18 31 OCT ?', NULL, TRUE, NULL),
('Ostern', '0 0 9 1 APR ?', NULL, TRUE, NULL),
('Tag der Arbeit', '0 0 9 1 MAY ?', NULL, TRUE, NULL),
('Daily Streak Reminder', '0 0 18 * * ?', NULL, TRUE, NULL),
('Weekly XP Summary', '0 0 20 ? * FRI', NULL, TRUE, NULL),
('Monthly Achievement Summary', '0 0 20 1 * ?', NULL, TRUE, NULL),
('Leaderboard Reset Reminder', '0 0 12 L-2 * ?', NULL, TRUE, NULL),
('WebPush Anniversary', '0 10 14 14 OCT ?', NULL, TRUE, NULL),
('Streak Reset', '0 59 23 * * ?', NULL, TRUE, NULL);

-- =========================================================
--  Conditions
--  Jede Condition ist eine einfache Prüfung.
-- =========================================================
INSERT INTO Condition_Period (type, period_date, period_start, period_end) VALUES
('date', '2025-12-25', NULL, NULL),  -- id 7
('daily_time', NULL, CURRENT_DATE + time '00:00:00', CURRENT_DATE + time '23:59:59'), -- id 8
('range', NULL, '2025-10-28 06:13:51', '2025-10-28 06:56:47'); -- id 9

-- Beispiel-Trigger 1: Täglicher Check
-- Condition-Logik:
-- streak >= 5
-- xp     >= 100
INSERT INTO Condition (type_id, period_id, operator, threshold) VALUES
(1, 1, '>=', 5),   -- id 1
(12, 1, '>=', 100),     -- id 2
(1, 8, '>', 0);    -- id 3

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(1, 1),
(1, 2),
(18, 3);


-- Beispiel-Trigger 2: Montags-Statistik-Trigger
-- Condition-Logik: -> Idee von Chat
-- count_today >= 50
INSERT INTO Condition (type_id, period_id, operator, threshold) VALUES
(9, 1, '==', 1);   -- id 4

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(2, 1);
-- (2, 3);


-- Beispiel-Trigger 3: Einmaliger Trigger
-- Keine Conditions nötig → reine Zeitaktion


-- Beispiel-Trigger 4: Datenbedingter Trigger
-- Condition-Logik:
-- sensor_temp > 30
-- sensor_humidity < 20
INSERT INTO Condition (type_id, period_id,operator, threshold) VALUES
(1, 1, '>', 30),  -- id 5
(2, 1, '<', 20);     -- id 6

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(3, 5),
(3, 6);


-- =========================================================
--  Actions (verfügbare Interaktionen)
-- =========================================================
INSERT INTO Action (action_type, title, icon) VALUES
('open', 'Öffnen', 'https://icons/open.png'),
('dismiss', 'Schließen', 'https://icons/close.png'),
('measure', 'Messung starten', 'https://icons/start.png'),
('leaderboard', 'Rangliste', 'https://icons/rank.png');

-- =========================================================
--  Notification
-- =========================================================
INSERT INTO Notification (title, body, icon_url, renotify, silent, trigger_id) VALUES
('Daily Check', 'Dein täglicher Check wurde ausgeführt.', 'http://localhost:8080/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 1),
('Montagsbericht', 'Dein Wochenbericht ist verfügbar.', 'http://localhost:8080/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 2),
('Einmalige Erinnerung 🕒', 'Dies ist eine einmalige Nachricht.', 'http://localhost:8080/WebPush-PWA/files/icons/logo.png', TRUE, FALSE, 3),
('Leaderboard Reset 🆕', 'Collect new data now and climb the ranks!', 'http://localhost:8080/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 4),
('Happy Star Wars Day 💫', 'May the 4th be with you!', 'http://localhost:8080/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 5),
('Merry Christmas 🎄', 'Merry Christmas and a happy New Year!', 'http://localhost:8080/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 6),
('New Year''s Eve 🎉', 'Celebrate the turn of the year!', 'http://localhost:8080/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 7),
('New Year 🎆', 'Welcome to the new year!', 'http://localhost:8080/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 8),
('Valentine''s Day 💘', 'Share the love on Valentine''s Day!', 'http://localhost:8080/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 9),
('Halloween 🎃', 'Spooky greetings for Halloween!', 'http://localhost:8080/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 10),
('Easter 🐰', 'Happy Easter!', 'http://localhost:8080/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 11),
('Tag der Arbeit 🛠️', 'Es ist Zeit Daten zu sammeln!', 'http://localhost:8080/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 12),
('Daily Streak Reminder 🍃', 'Keep your streak going! Only a few hours left to maintain your streak.', 'http://localhost:8080/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 13),
('Weekly XP Summary 📊', 'Your weekly XP summary is here!', 'http://localhost:8080/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 14),
('Monthly Achievement Summary 📅', 'Your monthly achievement overview is available!', 'http://localhost:8080/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 15),
('Leaderboard Reset Reminder 🔁', 'The leaderboard reset is imminent!', 'http://localhost:8080/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 16),
('WebPush Anniversary 🥳', 'Celebrate our Anniversary with us!', 'http://localhost:8080/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 17),
('Streak Reset 🔥', 'Your streak has been reset. Start anew today!', 'http://localhost:8080/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 18);


-- =========================================================
--  Notification-Actions Zuordnung
-- =========================================================
INSERT INTO Notification_Action (action_id, notification_id) VALUES
(1, 1),
(2, 1),
(1, 2),
(1, 3),
(4, 4),
(1, 4),
(2, 4),
(1, 13),
(2, 13),
(1, 16),
(2, 16),
(4, 16),
(1, 14),
(2, 14),
(1, 15),
(2, 15);

-- =========================================================
--  Notification-History (gesendete Nachrichten)
-- =========================================================
INSERT INTO History (notification_id, timestamp) VALUES
(1, NOW() - INTERVAL '1 hour'),
(2, NOW() - INTERVAL '3 hours'),
(3, NOW() - INTERVAL '1 day'),
(4, NOW() - INTERVAL '30 minutes');

-- =========================================================
--  Statistics (Interaktionen)
-- =========================================================
-- Hinweis: Event_Types wurde beim Schema bereits mit ('click', 'swipe') befüllt.
-- IDs: 1 = click, 2 = swipe
INSERT INTO Statistic (history_id, event_type_id, action_id, created_at) VALUES
(1, 1, 1, NOW() - INTERVAL '50 minutes'),
(1, 2, 2, NOW() - INTERVAL '40 minutes'),
(2, 1, 1, NOW() - INTERVAL '2 hours'),
(4, 1, 1, NOW() - INTERVAL '10 minutes');

-- =========================================================
--  Achievements
-- =========================================================

-- Achievement-Set 1: Fine Dust Sentinel
INSERT INTO condition (type_id, period_id, operator, threshold) VALUES
(4, 1, '>=', 40),
(4, 1, '>=', 60),    
(4, 1, '>=', 80);   

INSERT INTO Trigger (description, cron, time_once, active, last_triggered_at) VALUES
('Fine Dust Sentinel I', NUll, NULL, TRUE, NULL),
('Fine Dust Sentinel II', NULL, NULL, TRUE, NULL),
('Fine Dust Sentinel III', NULL, NULL, TRUE, NULL);

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(19, 6),
(20, 7),
(21, 8);

INSERT INTO Achievement_Tier (reward_xp, image_url, trigger_id) VALUES
(10, 'FDS_1.png', 19), 
(20, 'FDS_2.png', 20), 
(40, 'FDS_3.png', 21);

INSERT INTO Achievement_Set (title, description, body, tier1_id, tier2_id, tier3_id)
VALUES (
    'Fine Dust Sentinel',
    'Capture extremely high PM2.5 values.',
    'Next tier achieved for Fine Dust Sentinel! Another extreme PM2.5 reading logged.',
    1, 2, 3
);

INSERT INTO Group_Achievement (group_id, achievement_id) VALUES 
(1, 1),
(1, 2),
(2, 1),
(3, 1),
(3, 2),
(3, 3);

-- Achievement-Set 2: Pure Air Guardian
INSERT INTO condition (type_id, period_id, operator, threshold) VALUES
(3, 1, '<=', 15),
(3, 1, '<=', 10),    
(3, 1, '<=', 5);   

INSERT INTO Trigger (description, cron, time_once, active, last_triggered_at) VALUES
('Pure Air Guardian I', NUll, NULL, TRUE, NULL),
('Pure Air Guardian II', NULL, NULL, TRUE, NULL),
('Pure Air Guardian III', NULL, NULL, TRUE, NULL);

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(22, 9),
(23, 10),
(24, 11);

INSERT INTO Achievement_Tier (reward_xp, image_url, trigger_id) VALUES
(10, 'PAG_1.png', 22), 
(20, 'PAG_2.png', 23), 
(40, 'PAG_3.png', 24);

INSERT INTO Achievement_Set (title, description, body, tier1_id, tier2_id, tier3_id)
VALUES (
    'Pure Air Guardian',
    'Measured ultra-low fine particle pollution.',
    'You’ve hit the next tier of Pure Air Guardian! PM2.5 is exceptionally low again.',
    4, 5, 6
);

INSERT INTO Group_Achievement (group_id, achievement_id) VALUES 
(2, 4),
(2, 5),
(3, 4);

-- Achievement-Set 3: Dust Peak Detector
INSERT INTO condition (type_id, period_id, operator, threshold) VALUES
(6, 1, '>=', 50),
(6, 1, '>=', 100),    
(6, 1, '>=', 150);   

INSERT INTO Trigger (description, cron, time_once, active, last_triggered_at) VALUES
('Dust Peak Detector I', NUll, NULL, TRUE, NULL),
('Dust Peak Detector II', NULL, NULL, TRUE, NULL),
('Dust Peak Detector III', NULL, NULL, TRUE, NULL);

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(25, 12),
(26, 13),
(27, 14);

INSERT INTO Achievement_Tier (reward_xp, image_url, trigger_id) VALUES
(10, 'DPD_1.png', 25), 
(20, 'DPD_2.png', 26), 
(40, 'DPD_3.png', 27);

INSERT INTO Achievement_Set (title, description, body, tier1_id, tier2_id, tier3_id)
VALUES (
    'Dust Peak Detector',
    'Recorded unusually high PM10 concentrations.',
    'New tier reached: Dust Peak Detector! You recorded another major PM10 peak.',
    7, 8, 9
);

INSERT INTO Group_Achievement (group_id, achievement_id) VALUES 
(1, 7),
(1, 8),
(2, 7),
(2, 8),
(2, 9);

-- Achievement-Set 4: Clean Air Spotter
INSERT INTO condition (type_id, period_id, operator, threshold) VALUES
(5, 1, '<=', 5),
(5, 1, '<=', 10),    
(5, 1, '<=', 15);   

INSERT INTO Trigger (description, cron, time_once, active, last_triggered_at) VALUES
('Clean Air Spotter I', NUll, NULL, TRUE, NULL),
('Clean Air Spotter II', NULL, NULL, TRUE, NULL),
('Clean Air Spotter III', NULL, NULL, TRUE, NULL);

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(28, 15),
(29, 16),
(30, 17);

INSERT INTO Achievement_Tier (reward_xp, image_url, trigger_id) VALUES
(10, 'CAS_1.png', 28), 
(20, 'CAS_2.png', 29), 
(40, 'CAS_3.png', 30);

INSERT INTO Achievement_Set (title, description, body, tier1_id, tier2_id, tier3_id)
VALUES (
    'Fine Dust Sentinel',
    'Capture extremely high PM2.5 values.',
    'Next tier achieved for Fine Dust Sentinel! Another extreme PM2.5 reading logged.',
    10, 11, 12
);

INSERT INTO Group_Achievement (group_id, achievement_id) VALUES 
(1, 10),
(1, 11),
(2, 10),
(3, 10),
(3, 11),
(3, 12);

-- Achievement-Set 5: Marathon Mapper
INSERT INTO condition (type_id, period_id, operator, threshold) VALUES
(9, 1, '>=', 50),
(9, 1, '>=', 100),    
(9, 1, '>=', 250);   

INSERT INTO Trigger (description, cron, time_once, active, last_triggered_at) VALUES
('Marathon Mapper I', NUll, NULL, TRUE, NULL),
('Marathon Mapper II', NULL, NULL, TRUE, NULL),
('Marathon Mapper III', NULL, NULL, TRUE, NULL);

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(31, 18),
(32, 19),
(33, 20);

INSERT INTO Achievement_Tier (reward_xp, image_url, trigger_id) VALUES
(10, 'MM_1.png', 31), 
(20, 'MM_2.png', 32), 
(40, 'MM_3.png', 33);

INSERT INTO Achievement_Set (title, description, body, tier1_id, tier2_id, tier3_id)
VALUES (
    'Marathon Mapper',
    'Covered an impressive amount of distance while collecting data.',
    'Great progress! You reached a new Marathon Mapper tier by covering even more distance.',
    13, 14, 15
);

INSERT INTO Group_Achievement (group_id, achievement_id) VALUES 
(1, 13),
(1, 14),
(1, 15),
(2, 13),
(3, 13);

-- Achievement-Set 6: Unbroken Flame
INSERT INTO condition (type_id, period_id, operator, threshold) VALUES
(2, 1, '>=', 50),
(2, 1, '>=', 250),    
(2, 1, '>=', 1000);   

INSERT INTO Trigger (description, cron, time_once, active, last_triggered_at) VALUES
('Unbroken Flame I', NUll, NULL, TRUE, NULL),
('Unbroken Flame II', NULL, NULL, TRUE, NULL),
('Unbroken Flame III', NULL, NULL, TRUE, NULL);

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(34, 21),
(35, 22),
(36, 23);

INSERT INTO Achievement_Tier (reward_xp, image_url, trigger_id) VALUES
(10, 'UF_1.png', 34), 
(20, 'UF_2.png', 35), 
(40, 'UF_3.png', 36);

INSERT INTO Achievement_Set (title, description, body, tier1_id, tier2_id, tier3_id)
VALUES (
    'Unbroken Flame',
    'Maintained a long, unbroken series of measurements.',
    'Your streak keeps burning! You`ve reached the next Unbroken Flame tier.',
    16, 17, 18
);

INSERT INTO Group_Achievement (group_id, achievement_id) VALUES 
(1, 16),
(1, 17),
(2, 16),
(3, 16),
(3, 17),
(3, 18);

-- Achievement-Set 7: Deep Freeze Explorer
INSERT INTO condition (type_id, period_id, operator, threshold) VALUES
(7, 1, '<=', 10),
(7, 1, '<=', 0),    
(7, 1, '<=', -10);   

INSERT INTO Trigger (description, cron, time_once, active, last_triggered_at) VALUES
('Deep Freeze Explorer I', NUll, NULL, TRUE, NULL),
('Deep Freeze Explorer II', NULL, NULL, TRUE, NULL),
('Deep Freeze Explorer III', NULL, NULL, TRUE, NULL);

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(37, 24),
(38, 25),
(39, 26);

INSERT INTO Achievement_Tier (reward_xp, image_url, trigger_id) VALUES
(10, 'DFE_1.png', 37), 
(20, 'DFE_2.png', 38), 
(40, 'DFE_3.png', 39);

INSERT INTO Achievement_Set (title, description, body, tier1_id, tier2_id, tier3_id)
VALUES (
    'Deep Freeze Explorer',
    'Collected data in extremely cold conditions.',
    'Next tier achieved: Deep Freeze Explorer! Your cold-weather measurements keep getting stronger.',
    19, 20, 21
);

INSERT INTO Group_Achievement (group_id, achievement_id) VALUES 
(1, 19),
(2, 19),
(2, 20),
(2, 21),
(3, 19);

-- Achievement-Set 8: Extreme Heat Scout
INSERT INTO condition (type_id, period_id, operator, threshold) VALUES
(8, 1, '>=', 25),
(8, 1, '>=', 32),    
(8, 1, '>=', 40);   

INSERT INTO Trigger (description, cron, time_once, active, last_triggered_at) VALUES
('Extreme Heat Scout I', NUll, NULL, TRUE, NULL),
('Extreme Heat Scout II', NULL, NULL, TRUE, NULL),
('Extreme Heat Scout III', NULL, NULL, TRUE, NULL);

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(40, 27),
(41, 28),
(42, 29);

INSERT INTO Achievement_Tier (reward_xp, image_url, trigger_id) VALUES
(10, 'EHS_1.png', 40), 
(20, 'EHS_2.png', 41), 
(40, 'EHS_3.png', 42);

INSERT INTO Achievement_Set (title, description, body, tier1_id, tier2_id, tier3_id)
VALUES (
    'Extreme Heat Scout',
    'Measured air quality during exceptionally high temperatures.',
    'You`ve reached the next tier of Extreme Heat Scout! Your measurements in extreme heat are leveling up.',
    22, 23, 24
);

INSERT INTO Group_Achievement (group_id, achievement_id) VALUES 
(1, 22),
(1, 23),
(2, 22),
(3, 22),
(3, 23),
(3, 24);

-- Achievement-Set 9: Night Shift Monitor
INSERT INTO Condition_Period (type, period_date, period_start, period_end) VALUES
('daily_time', NULL, '2025-12-06 20:00:00', '2025-12-06 23:59:59'); -- id 10                                 

INSERT INTO condition (type_id, period_id, operator, threshold) VALUES
(11, 10, '>=', 10),
(11, 10, '>=', 25),    
(11, 10, '>=', 50);   

INSERT INTO Trigger (description, cron, time_once, active, last_triggered_at) VALUES
('Night Shift Monitor I', NUll, NULL, TRUE, NULL),
('Night Shift Monitor II', NULL, NULL, TRUE, NULL),
('Night Shift Monitor III', NULL, NULL, TRUE, NULL);

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(43, 30),
(44, 31),
(45, 32);

INSERT INTO Achievement_Tier (reward_xp, image_url, trigger_id) VALUES
(10, 'NSM_1.png', 43), 
(20, 'NSM_2.png', 44), 
(40, 'NSM_3.png', 45);

INSERT INTO Achievement_Set (title, description, body, tier1_id, tier2_id, tier3_id)
VALUES (
    'Night Shift Monitor',
    'Performed measurements deep into the night.(8pm-12pm)',
    'Another night, another tier! Night Shift Monitor has reached the next level.',
    25, 26, 27
);

INSERT INTO Group_Achievement (group_id, achievement_id) VALUES 
(1, 25),
(1, 26),
(2, 25),
(3, 25),
(3, 26),
(3, 27);

-- Achievement-Set 10: Dawn Tracker
INSERT INTO Condition_Period (type, period_date, period_start, period_end) VALUES
('daily_time', NULL, '2025-12-06 02:00:00', '2025-12-06 06:00:00'); -- id 11                                    

INSERT INTO condition (type_id, period_id, operator, threshold) VALUES
(11, 11, '>=', 10),
(11, 11, '>=', 25),    
(11, 11, '>=', 50);   

INSERT INTO Trigger (description, cron, time_once, active, last_triggered_at) VALUES
('Dawn Tracker I', NUll, NULL, TRUE, NULL),
('Dawn Tracker II', NULL, NULL, TRUE, NULL),
('Dawn Tracker III', NULL, NULL, TRUE, NULL);

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(46, 33),
(47, 34),
(48, 35);

INSERT INTO Achievement_Tier (reward_xp, image_url, trigger_id) VALUES
(10, 'DT_1.png', 46), 
(20, 'DT_2.png', 47), 
(40, 'DT_3.png', 48);

INSERT INTO Achievement_Set (title, description, body, tier1_id, tier2_id, tier3_id)
VALUES (
    'Dawn Tracker',
    'Collected data at the earliest hours of the day.(2am-6am)',
    'You advanced to a new Dawn Tracker tier by measuring at dawn again.',
    28, 29, 30
);

INSERT INTO Group_Achievement (group_id, achievement_id) VALUES 
(1, 28),
(2, 28),
(2, 29),
(2, 30),
(3, 28),
(3, 29);

