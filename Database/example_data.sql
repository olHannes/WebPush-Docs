-- =========================================================
--  Beispiel-Datensätze für das Gamification-System
-- =========================================================

-- Mitglieder (Member)
INSERT INTO Member (name, subscription) VALUES
('Member_01', '{"endpoint": "https://member_01_endpoint", "key": "abc123", "auth": "token123"}'),
('Member_02', '{"endpoint": "https://member_02_endpoint", "key": "def456", "auth": "token456"}'),
('Member_03', '{"endpoint": "https://member_03_endpoint", "key": "ghi789", "auth": "token789"}');

-- Gruppen (Groups)
INSERT INTO Groups (data_table, streak, level, xp) VALUES
('sensor_0001324j3214js', 5, 3, 150),
('sensor_0x82698_e07', 2, 1, 40);

-- Zuordnung Member <-> Group
INSERT INTO Group_Member (member_id, group_id) VALUES
(1, 1),
(2, 1),
(3, 2);

-- =========================================================
--  Trigger-Beispiel (mit komplexer Konfiguration)
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
          "group_id": "Pi01",
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
--  Notifications
-- =========================================================

INSERT INTO Notifications (title, body, icon_url, image_url, renotify, silent, trigger_id, is_active) VALUES
('Level erreicht!', 'Gratuliere! Deine Gruppe hat Level 4 erreicht.', 'https://example.com/icon.png', 'https://example.com/banner.png', FALSE, FALSE, 1, TRUE),
('Messungserinnerung', 'Denk an deine tägliche Messung!', 'https://example.com/reminder.png', NULL, TRUE, FALSE, NULL, TRUE);

-- Actions für Notifications
INSERT INTO Notification_actions (notification_id, action, title, icon) VALUES
(1, 'open', 'Details anzeigen', 'https://example.com/open.png'),
(1, 'dismiss', 'Schließen', 'https://example.com/close.png'),
(2, 'measure', 'Messung starten', 'https://example.com/start.png');

-- =========================================================
--  Notification-Historie und Statistik
-- =========================================================

-- Nachricht an Gruppe 1 gesendet
INSERT INTO History (notification_id, group_id, timestamp) VALUES
(1, 1, NOW() - INTERVAL '5 minutes'),
(2, 2, NOW() - INTERVAL '1 hour');

-- Klicks / Swipes erfassen
INSERT INTO Notification_statistics (history_id, group_id, event_type) VALUES
(1, 1, 'click'),
(1, 1, 'swipe'),
(2, 2, 'click');

-- =========================================================
--  Achievements
-- =========================================================

INSERT INTO Achievement (type, message, image_url, config) VALUES
(
  'streak_master',
  'Du hast 7 Tage in Folge Daten gesammelt!',
  'https://example.com/ach_streak.png',
  '{
    "conditions": [
      {
        "type": "streak_check",
        "group_id": "Pi01",
        "streak_target": 7
      }
    ],
    "reward": { "xp": 50 }
  }'
),
(
  'data_champion',
  'Über 100 Messwerte an einem Tag!',
  'https://example.com/ach_data.png',
  '{
    "conditions": [
      {
        "type": "data_count",
        "group_id": "Pi01",
        "time_range": "today",
        "operator": ">=",
        "threshold": 100
      }
    ],
    "reward": { "xp": 100 }
  }'
);

-- Zugewiesene Achievements
INSERT INTO Group_Achievement (group_id, achievement_id) VALUES
(1, 1),
(1, 2);
