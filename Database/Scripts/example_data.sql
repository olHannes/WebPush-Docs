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
INSERT INTO Groups (data_table, name, streak, level, xp) VALUES
('sensor_table_m1', 'Sensor M1', 3, 1, 55),
('sensor_table_m2', 'Sensor M2', 7, 2, 140),
('sensor_table_m3', 'Sensor M3', 1, 0, 10);

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
-- 1️⃣  Täglicher Check um 08:00
INSERT INTO Triggers (description, cron, time_once, active, last_triggered_at)
VALUES ('Täglicher 8-Uhr-Check', '0 0 8 * * ?', NULL, TRUE, '2025-11-14 08:00:00.000');

-- 2️⃣  Wöchentlicher Montag-Trigger
INSERT INTO Triggers (description, cron, time_once, active, last_triggered_at)
VALUES ('Montags-Statistik-Trigger', '0 0 9 ? * MON', NULL, TRUE, '2025-11-10 09:00:00.000');

-- Trigger ohne Zeitplan (nur durch Datenbedingungen ausgelöst)
INSERT INTO Triggers (description, cron, time_once, active, last_triggered_at)
VALUES ('Datenbedingter Trigger', NULL, NULL, TRUE, NULL);
-- =========================================================
--  Conditions
--  Jede Condition ist eine einfache Prüfung.
-- =========================================================

-- Beispiel-Trigger 1: Täglicher Check
-- Condition-Logik:
-- streak >= 5
-- xp     >= 100
INSERT INTO Conditions (data_field, operator, threshold) VALUES
('gamification:groups:streak', '>=', 5),   -- id 1
('gamification:groups:xp', '>=', 100);     -- id 2

INSERT INTO Trigger_Conditions (trigger_id, condition_id) VALUES
(1, 1),
(1, 2);


-- Beispiel-Trigger 2: Montags-Statistik-Trigger
-- Condition-Logik: -> Idee von Chat
-- count_today >= 50
INSERT INTO Conditions (data_field, operator, threshold) VALUES
('gamification:group_today_stats():has_today', '==', 1);  -- id 3

INSERT INTO Trigger_Conditions (trigger_id, condition_id) VALUES
(2, 1);
-- (2, 3);


-- Beispiel-Trigger 3: Einmaliger Trigger
-- Keine Conditions nötig → reine Zeitaktion


-- Beispiel-Trigger 4: Datenbedingter Trigger
-- Condition-Logik:
-- sensor_temp > 30
-- sensor_humidity < 20
INSERT INTO Conditions (data_field, operator, threshold) VALUES
('sensor:temperature', '>', 30),  -- id 4
('sensor:humidity', '<', 20);     -- id 5

INSERT INTO Trigger_Conditions (trigger_id, condition_id) VALUES
(3, 4),
(3, 5);



-- =========================================================
--  Actions (verfügbare Interaktionen)
-- =========================================================
INSERT INTO Actions (action_type, title, icon) VALUES
('open', 'Öffnen', 'https://icons/open.png'),
('dismiss', 'Schließen', 'https://icons/close.png'),
('measure', 'Messung starten', 'https://icons/start.png'),
('leaderboard', 'Rangliste', 'https://icons/rank.png');

-- =========================================================
--  Notifications
-- =========================================================
INSERT INTO Notifications (title, body, icon_url, renotify, silent, trigger_id) VALUES
('Daily Check', 'Dein täglicher Check wurde ausgeführt.', 'https://icons/info.png', FALSE, FALSE, 1),
('Montagsbericht', 'Dein Wochenbericht ist verfügbar.', 'https://icons/report.png', FALSE, FALSE, 2),
('Einmalige Erinnerung', 'Dies ist eine einmalige Nachricht.', 'https://icons/once.png', TRUE, FALSE, 3),
('Sensorwarnung', 'Temperatur oder Luftfeuchtigkeit außerhalb der Norm!', 'https://icons/warning.png', FALSE, FALSE, 3);

-- =========================================================
--  Notification-Actions Zuordnung
-- =========================================================
INSERT INTO Notification_Actions (action_id, notification_id) VALUES
(1, 1),
(2, 1),
(1, 2),
(4, 2),
(1, 3),
(1, 4),
(2, 4);

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
INSERT INTO Statistics (history_id, event_type_id, action_id, created_at) VALUES
(1, 1, 1, NOW() - INTERVAL '50 minutes'),
(1, 2, 2, NOW() - INTERVAL '40 minutes'),
(2, 1, 1, NOW() - INTERVAL '2 hours'),
(4, 1, 1, NOW() - INTERVAL '10 minutes');

-- =========================================================
--  Achievements
-- =========================================================
INSERT INTO Achievements (title, description, message, reward_xp, image_url, trigger_id) VALUES
('Level 1 erreicht', 'Deine Gruppe hat Level 1 erreicht.', 'Glückwunsch zu Level 1!', 25, NULL, 1),
('Wochenziel erreicht', '50 Aktionen in einer Woche!', 'Sehr gute Aktivität!', 50, NULL, 2),
('Alarmreaktion', 'Du hast auf kritische Werte reagiert.', 'Gut aufgepasst!', 20, NULL, 3);
-- =========================================================
--  Zugewiesene Achievements zu Gruppen
-- =========================================================
INSERT INTO Group_Achievement (group_id, achievement_id) VALUES
(1, 1),
(2, 2),
(3, 3);
