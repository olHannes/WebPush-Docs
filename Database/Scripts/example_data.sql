-- =========================================================
--  Beispiel-Datensätze für das neue Gamification-System
-- =========================================================

-- =========================================================
--  Member
-- =========================================================
INSERT INTO Member (name, endpoint, member_key, auth) VALUES
('Member_01', 'https://member_01_endpoint', 'abc123', 'token123'),
('Member_02', 'https://member_02_endpoint', 'def456', 'token456'),
('Member_03', 'https://member_03_endpoint', 'ghi789', 'token789'),
('Member_04', 'https://member_04_endpoint', 'jkl321', 'token321');

-- =========================================================
--  Groups
-- =========================================================
INSERT INTO Groups (data_table, name, streak, level, xp) VALUES
('sensor_0001324j3214js', 'RaspberryGroup01', 5, 3, 150),
('sensor_0x82698_e07', 'WeatherStation02', 2, 1, 40),
('sensor_airq_2025', 'AirQualityTeam03', 8, 4, 280);

-- =========================================================
--  Group-Member Zuordnung
-- =========================================================
INSERT INTO Group_Member (member_id, group_id) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 3);

-- =========================================================
--  Trigger Beispiel (komplexe Konfiguration)
-- =========================================================
-- 1️⃣  Täglicher Streak-Check
INSERT INTO Triggers (description, config, last_triggered_at, active) VALUES
(
  'Tägliche Streak-Erinnerung',
  '{
    "when": {
      "schedule": { "type": "recurring", "cron": "0 18 * * *", "timestamp": "" },
      "conditions": [
        { "type": "streak_check", "group_id": "RaspberryGroup01", "missing_activity_for": "24h" }
      ]
    }
  }',
  NOW() - INTERVAL '2 hours',
  TRUE
);

-- 2️⃣  Wöchentlicher Daten-Reminder (abhängig von Sensorwert)
INSERT INTO Triggers (description, config, last_triggered_at, active) VALUES
(
  'wöchentlicher Reminder',
  '{
    "when": {
      "schedule": { "type": "recurring", "cron": "0 9 * * 1", "timestamp": "" },
      "conditions": [
        { "type": "data_threshold", "sensor_id": "2.5pm", "operator": ">", "threshold": 35 }
      ]
    }
  }',
  NOW() - INTERVAL '3 days',
  TRUE
);

-- 3️⃣  Einmaliger Reminder
INSERT INTO Triggers (description, config, last_triggered_at, active) VALUES
(
  'Einmalige Erinnerung',
  '{
    "when": {
      "schedule": { "type": "once", "cron": "", "timestamp": "2025-11-03T09:00:00Z" }
    }
  }',
  NULL,
  TRUE
);

-- 4️⃣  Datenbasierter Trigger (z. B. 100 Messwerte)
INSERT INTO Triggers (description, config, last_triggered_at, active) VALUES
(
  'Erreichte 100 Messwerte',
  '{
    "when": {
      "conditions": [
        {
          "type": "data_count",
          "group_id": "AirQualityTeam03",
          "time_range": "today",
          "operator": ">=",
          "threshold": 100
        }
      ]
    }
  }',
  NOW() - INTERVAL '5 hours',
  TRUE
);

-- 5️⃣  Komplexer Kombi-Trigger (zeit- + datenabhängig)
INSERT INTO Triggers (description, config, last_triggered_at, active) VALUES
(
  'zeitlich und datenbasierter trigger',
  '{
    "when": {
      "schedule": { "type": "recurring", "cron": "0 9 * * *", "timestamp": ""},
      "conditions": [
        { "type": "data_threshold", "sensor_id": "raspi_23_temp", "operator": ">", "threshold": 35.0, "duration": "5m" },
        { "type": "streak_check", "group_id": "WeatherStation02", "streak_target": 7, "last_activity_before": "24h" }
      ]
    }
  }',
  NOW() - INTERVAL '1 day',
  TRUE
);

-- =========================================================
--  Actions (verfügbare Interaktionen)
-- =========================================================
INSERT INTO Actions (action_type, title, icon) VALUES
('open', 'Details anzeigen', 'https://example.com/open.png'),
('dismiss', 'Schließen', 'https://example.com/close.png'),
('measure', 'Messung starten', 'https://example.com/start.png'),
('leaderboard', 'Rangliste anzeigen', 'https://example.com/rank.png'),
('share', 'Erfolg teilen', 'https://example.com/share.png');

-- =========================================================
--  Notifications
-- =========================================================
INSERT INTO Notifications (title, body, icon_url, image_url, renotify, silent, trigger_id) VALUES
('Streak Erinnerung', 'Deine Gruppe war heute noch nicht aktiv – bleib dran!', 'https://example.com/reminder1.png', NULL, TRUE, FALSE, 1),
('Sensorwert zu hoch', 'Die Feinstaubbelastung liegt über dem Grenzwert!', 'https://example.com/alert.png', 'https://example.com/banner_alert.png', FALSE, FALSE, 2),
('Messungserinnerung', 'Bitte starte heute deine tägliche Messung.', 'https://example.com/reminder2.png', NULL, TRUE, FALSE, 3),
('Datenziel erreicht!', 'Über 100 Messwerte gesammelt – großartige Leistung!', 'https://example.com/goal.png', 'https://example.com/data_banner.png', FALSE, FALSE, 4),
('Kombinierter Check', 'Mehrere Bedingungen wurden erfüllt. Schau nach den Details!', 'https://example.com/combined.png', NULL, FALSE, TRUE, 5);

-- =========================================================
--  Notification-Actions Zuordnung
-- =========================================================
-- (1. Notification hat zwei Aktionen, 2. Notification eine)
INSERT INTO Notification_Actions (action_id, notification_id) VALUES
-- Für Streak Erinnerung
(1, 1),
(2, 1),
-- Für Sensorwertwarnung
(1, 2),
(5, 2),
-- Für tägliche Messung
(3, 3),
-- Für Datenziel erreicht
(1, 4),
(4, 4),
(5, 4),
-- Für Kombi-Trigger
(1, 5),
(2, 5),
(5, 5);

-- =========================================================
--  Notification-History (gesendete Nachrichten)
-- =========================================================
INSERT INTO History (notification_id, timestamp) VALUES
(1, NOW() - INTERVAL '6 hours'),
(2, NOW() - INTERVAL '1 day'),
(3, NOW() - INTERVAL '3 hours'),
(4, NOW() - INTERVAL '2 hours'),
(5, NOW() - INTERVAL '30 minutes');

-- =========================================================
--  Statistics (Interaktionen)
-- =========================================================
-- Hinweis: Event_Types wurde beim Schema bereits mit ('click', 'swipe') befüllt.
-- IDs: 1 = click, 2 = swipe
INSERT INTO Statistics (history_id, event_type_id, action_id, created_at) VALUES
(1, 1, 1, NOW() - INTERVAL '5 hours'),
(1, 2, 2, NOW() - INTERVAL '4 hours'),
(2, 1, 1, NOW() - INTERVAL '23 hours'),
(3, 1, 3, NOW() - INTERVAL '2 hours'),
(4, 1, 5, NOW() - INTERVAL '1 hour'),
(5, 1, 4, NOW() - INTERVAL '10 minutes');

-- =========================================================
--  Achievements
-- =========================================================
INSERT INTO Achievements (title, description, message, reward_xp, image_url, trigger_id) VALUES
(
  'Streak Master',
  '7 Tage in Folge Daten gesammelt.',
  'Du hast 7 Tage in Folge Daten gesammelt!',
  50,
  'https://example.com/ach_streak.png',
  1
),
(
  'Data Champion',
  'Über 100 Messwerte an einem Tag erreicht.',
  'Über 100 Messwerte an einem Tag! Weiter so!',
  100,
  'https://example.com/ach_data.png',
  4
),
(
  'Consistency Hero',
  'Tägliche Aktivität für einen Monat.',
  'Unglaublich – 30 Tage in Folge aktiv!',
  250,
  'https://example.com/ach_consistency.png',
  1
),
(
  'Alert Guardian',
  'Schnelle Reaktion auf kritische Sensorwerte.',
  'Du hast sofort reagiert, als Werte zu hoch waren!',
  75,
  'https://example.com/ach_alert.png',
  2
);

-- =========================================================
--  Zugewiesene Achievements zu Gruppen
-- =========================================================
INSERT INTO Group_Achievement (group_id, achievement_id) VALUES
(1, 1),
(1, 2),
(2, 4),
(3, 3);
