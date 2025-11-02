-- =========================================================
--  Beispiel-Datensätze für das neue Gamification-System
-- =========================================================

-- =========================================================
--  Member
-- =========================================================
INSERT INTO Member (name, endpoint, member_key, auth) VALUES
('Member_01', 'https://member_01_endpoint', 'abc123', 'token123'),
('Member_02', 'https://member_02_endpoint', 'def456', 'token456'),
('Member_03', 'https://member_03_endpoint', 'ghi789', 'token789');

-- =========================================================
--  Groups
-- =========================================================
INSERT INTO Groups (data_table, name, streak, level, xp) VALUES
('sensor_0001324j3214js', 'RaspberryGroup01', 5, 3, 150),
('sensor_0x82698_e07', 'WeatherStation02', 2, 1, 40);

-- =========================================================
--  Group-Member Zuordnung
-- =========================================================
INSERT INTO Group_Member (member_id, group_id) VALUES
(1, 1),
(2, 1),
(3, 2);

-- =========================================================
--  Trigger Beispiel (komplexe Konfiguration)
-- =========================================================
INSERT INTO Triggers (type, config, last_triggered_at, active) VALUES
(
  'complex_combined',
  '{
    "when": {
      "schedule": {
        "type": "recurring",
        "frequency": "daily",
        "time": "09:00"
      },
      "conditions": [
        {
          "type": "data_threshold",
          "sensor_id": "raspi_23_temp",
          "operator": ">",
          "threshold": 35.0,
          "duration": "5m"
        },
        {
          "type": "streak_check",
          "group_id": "RaspberryGroup01",
          "streak_target": 7,
          "last_activity_before": "24h"
        }
      ]
    },
    "action": {
      "notification_id": 1,
      "delay": "0s"
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
('measure', 'Messung starten', 'https://example.com/start.png');

-- =========================================================
--  Notifications
-- =========================================================
INSERT INTO Notifications (title, body, icon_url, image_url, renotify, silent, trigger_id) VALUES
('Level erreicht!', 'Gratuliere! Deine Gruppe hat Level 4 erreicht.', 'https://example.com/icon.png', 'https://example.com/banner.png', FALSE, FALSE, 1),
('Messungserinnerung', 'Denk an deine tägliche Messung!', 'https://example.com/reminder.png', NULL, TRUE, FALSE, NULL);

-- =========================================================
--  Notification-Actions Zuordnung
-- =========================================================
-- (1. Notification hat zwei Aktionen, 2. Notification eine)
INSERT INTO Notification_Actions (action_id, notification_id) VALUES
(1, 1),
(2, 1),
(3, 2);

-- =========================================================
--  Notification-History (gesendete Nachrichten)
-- =========================================================
INSERT INTO History (notification_id, timestamp) VALUES
(1, NOW() - INTERVAL '5 minutes'),
(2, NOW() - INTERVAL '1 hour');

-- =========================================================
--  Statistics (Interaktionen)
-- =========================================================
-- Hinweis: Event_Types wurde beim Schema bereits mit ('click', 'swipe') befüllt.
-- IDs: 1 = click, 2 = swipe
INSERT INTO Statistics (history_id, event_type_id, action_id, created_at) VALUES
(1, 1, 1, NOW() - INTERVAL '4 minutes'),  -- click
(1, 2, 2, NOW() - INTERVAL '3 minutes'),  -- swipe
(2, 1, 3, NOW() - INTERVAL '50 minutes'); -- click

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
  NULL
);

-- =========================================================
--  Zugewiesene Achievements zu Gruppen
-- =========================================================
INSERT INTO Group_Achievement (group_id, achievement_id) VALUES
(1, 1),
(1, 2);
