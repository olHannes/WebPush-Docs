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
-- 1️⃣ Täglicher Check um 08:00 Uhr
('Täglicher 8-Uhr-Check', '0 0 8 * * ?', NULL, TRUE, '2025-11-14 08:00:00.000'),
-- 2️⃣ Wöchentlicher Montag-Trigger
('Montags-Statistik-Trigger', '0 0 9 ? * MON', NULL, TRUE, '2025-11-10 09:00:00.000'),
-- 3️⃣ Trigger ohne Zeitplan (nur durch Datenbedingungen ausgelöst)
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
('Achievement Test', NULL, NULL, TRUE, NULL);

-- =========================================================
--  Conditions
--  Jede Condition ist eine einfache Prüfung.
-- =========================================================
INSERT INTO Condition_Period (type, period_date, time_start, time_end, range_start, range_end) VALUES                                                                         -- id 6
('date', '2025-12-25', NULL, NULL, NULL, NULL),                                     -- id 7
('daily_time', NULL, '14:00:00', '16:00:00', NULL, NULL),                           -- id 8
('range', NULL, NULL, NULL, '2025-10-28 06:13:51.071', '2025-10-28 06:56:47.317');  -- id 9

-- Beispiel-Trigger 1: Täglicher Check
-- Condition-Logik:
-- streak >= 5
-- xp     >= 100
INSERT INTO Condition (type_id, period_id, operator, threshold) VALUES
(1, 1, '>=', 5),   -- id 1
(12, 1, '>=', 100);     -- id 2

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(1, 1),
(1, 2);


-- Beispiel-Trigger 2: Montags-Statistik-Trigger
-- Condition-Logik: -> Idee von Chat
-- count_today >= 50
INSERT INTO Condition (type_id, period_id, operator, threshold) VALUES
(9, 1, '==', 1);   -- has_today == 1

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
(1, 1, '>', 30),  -- id 4
(2, 1, '<', 20);     -- id 5

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(3, 4),
(3, 5);


INSERT INTO Condition (type_id, period_id, operator, threshold) VALUES
(1, 6, '>', 5),    -- id 6
(2, 6, '>=', 42),  -- id 7
(5, 6, '<', 15),   -- id 8
(11, 6, '>', 3),   -- id 9
(12, 6, '<=', 3),  -- id 10
(13, 6, '!=', 50); -- id 11

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(18, 6),
(18, 7),
(18, 8),
(18, 9),
(18, 10),
(18, 11);


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
('Daily Streak Reminder 🍃', 'Keep your streak going!', 'http://localhost:8080/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 13),
('Weekly XP Summary 📊', 'Your weekly XP summary is here!', 'http://localhost:8080/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 14),
('Monthly Achievement Summary 📅', 'Your monthly achievement overview is available!', 'http://localhost:8080/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 15),
('Leaderboard Reset Reminder 🔁', 'The leaderboard reset is imminent!', 'http://localhost:8080/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 16),
('WebPush Anniversary 🥳', 'Celebrate our Anniversary with us!', 'http://localhost:8080/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 17);


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
-- Achievement-Set 1: Level erreicht (Tier 1–3)
INSERT INTO Achievement_Tier (reward_xp, image_url, trigger_id) VALUES
(10, 'level_1.png', 1),  -- Tier 1
(20, 'level_2.png', 2),  -- Tier 2
(40, 'level_3.png', 3);

INSERT INTO Achievement_Set (title, description, message, tier1_id, tier2_id, tier3_id)
VALUES (
    'Level-Meister',
    'Erreiche Level 1, 2 und 3.',
    'Deine Gruppe steigt im Level auf!',
    1, 2, 3
);

INSERT INTO Achievement_Tier (reward_xp, image_url, trigger_id) VALUES
(15, 'activity_1.png', 4),
(30, 'activity_2.png', 5),
(60, 'activity_3.png', 6);

INSERT INTO Achievement_Set (title, description, message, tier1_id, tier2_id, tier3_id)
VALUES (
    'Wöchentliche Aktivität',
    'Sammle Aktionen über mehrere Wochen.',
    'Starke Aktivität pro Woche!',
    4, 5, 6
);

INSERT INTO Achievement_Tier (reward_xp, image_url, trigger_id) VALUES
(5, 'alert_1.png', 7),
(10, 'alert_2.png', 8),
(25, 'alert_3.png', 9);

INSERT INTO Achievement_Set (title, description, message, tier1_id, tier2_id, tier3_id)
VALUES (
    'Alarmreaktionen',
    'Reagiere auf kritische Werte.',
    'Schnell & aufmerksam!',
    7, 8, 9
);

-- Gruppe 1 hat Level 1 erreicht
INSERT INTO Group_Achievement (group_id, achievement_id) VALUES (1, 1);

-- Gruppe 2 hat Level 2 erreicht
INSERT INTO Group_Achievement (group_id, achievement_id) VALUES (2, 2);

-- Gruppe 3 hat Alarmreaktion Tier 1 erreicht
INSERT INTO Group_Achievement (group_id, achievement_id) VALUES (3, 7);

