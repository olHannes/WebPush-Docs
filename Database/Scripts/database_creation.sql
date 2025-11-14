-- =========================================================
--  SCHEMA RESET
-- =========================================================

-- Schema neu erstellen
DROP SCHEMA IF EXISTS gamification CASCADE;
CREATE SCHEMA gamification;
SET search_path TO gamification;

-- =========================================================
--  Base Entities
-- =========================================================

CREATE TABLE Member (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    endpoint TEXT NOT NULL,
    "key" TEXT NOT NULL,
    auth TEXT NOT NULL
);

CREATE TABLE Groups (
    id SERIAL PRIMARY KEY,
    data_table TEXT,
    name TEXT UNIQUE NOT NULL,
    streak INT NOT NULL DEFAULT 0 CHECK (streak >= 0),
    level INT NOT NULL DEFAULT 0 CHECK (level >= 0),
    xp INT NOT NULL DEFAULT 0 CHECK (xp >= 0)
);

CREATE TABLE Group_Member (
    member_id INT NOT NULL REFERENCES Member(id) ON DELETE CASCADE,
    group_id INT NOT NULL REFERENCES Groups(id) ON DELETE CASCADE,
    PRIMARY KEY (member_id, group_id)
);

-- =========================================================
--  Notifications & Trigger System
-- =========================================================

CREATE TABLE Triggers (
    id SERIAL PRIMARY KEY,
    description TEXT NOT NULL,
    cron TEXT,
    time_once TIMESTAMP,
    last_triggered_at TIMESTAMP,
    active BOOLEAN DEFAULT TRUE
);

CREATE TABLE Condition (
    id SERIAL PRIMARY KEY,
    data_field TEXT NOT NULL,
    operator TEXT NOT NULL CHECK (operator IN ('>', '<', '=', '>=', '<=', '!=')),
    threshold NUMERIC NOT NULL
);

CREATE TABLE Trigger_Conditions (
    trigger_id INT REFERENCES Triggers(id) ON DELETE CASCADE,
    condition_id INT REFERENCES Condition(id) ON DELETE CASCADE
);

CREATE TABLE Actions (
    id SERIAL PRIMARY KEY,
    action_type TEXT NOT NULL,
    title TEXT NOT NULL,
    icon TEXT
);

CREATE TABLE Notifications (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT,
    icon_url TEXT,
    image_url TEXT,
    renotify BOOLEAN DEFAULT FALSE,
    silent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    trigger_id INT REFERENCES Triggers(id) ON DELETE SET NULL
);

CREATE TABLE Notification_Actions (
    action_id INT NOT NULL REFERENCES Actions(id) ON DELETE CASCADE,
    notification_id INT NOT NULL REFERENCES Notifications(id) ON DELETE CASCADE,
    PRIMARY KEY (action_id, notification_id)
);

CREATE TABLE History (
    id SERIAL PRIMARY KEY,
    notification_id INT NOT NULL REFERENCES Notifications(id) ON DELETE CASCADE,
    timestamp TIMESTAMP DEFAULT NOW()
);

-- =========================================================
-- Lookup Tables
-- =========================================================
CREATE TABLE Event_Types (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);
INSERT INTO Event_Types (name) VALUES ('click'), ('swipe');


CREATE TABLE Statistics (
    id SERIAL PRIMARY KEY,
    history_id INT NOT NULL REFERENCES History(id) ON DELETE CASCADE,
    event_type_id INT NOT NULL REFERENCES Event_Types(id) ON DELETE RESTRICT,
    action_id INT REFERENCES Actions(id),
    created_at TIMESTAMP DEFAULT NOW()
);

-- =========================================================
--  Achievements / gamification
-- =========================================================

CREATE TABLE Achievements (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    message TEXT NOT NULL,
    reward_xp INT DEFAULT 0 CHECK (reward_xp >= 0),
    image_url TEXT,
    trigger_id INT REFERENCES Triggers(id) ON DELETE SET NULL
);

CREATE TABLE Group_Achievement (
    group_id INT NOT NULL REFERENCES Groups(id) ON DELETE CASCADE,
    achievement_id INT NOT NULL REFERENCES Achievements(id) ON DELETE CASCADE,
    PRIMARY KEY (group_id, achievement_id)
);

-- =========================================================
--  Useful Indexes
-- =========================================================

CREATE INDEX idx_member_name ON Member(name);
CREATE UNIQUE INDEX idx_member_endpoint ON Member(endpoint);

CREATE INDEX idx_group_name ON GROUPS(name);
CREATE INDEX idx_group_level_xp ON GROUPS(level DESC, xp DESC);
CREATE INDEX idx_group_streak ON GROUPS(streak DESC);

CREATE INDEX idx_triggers_active ON Triggers(active);
CREATE INDEX idx_triggers_type ON Triggers(description);
CREATE INDEX idx_triggers_last_triggered ON Triggers(last_triggered_at);

CREATE INDEX idx_notifications_trigger ON Notifications(trigger_id);
CREATE INDEX idx_notifications_created_at ON Notifications(created_at DESC);

CREATE INDEX idx_notif_actions_action ON Notification_Actions(action_id);
CREATE INDEX idx_notif_actions_notif ON Notification_Actions(notification_id);

CREATE INDEX idx_history_notification ON History(notification_id);
CREATE INDEX idx_stats_event_type ON Statistics(event_type_id);
CREATE INDEX idx_stats_action ON Statistics(action_id);
CREATE INDEX idx_stats_history ON Statistics(history_id);

CREATE INDEX idx_achievement_trigger ON Achievements(trigger_id);
CREATE INDEX idx_group_achievement_group ON Group_Achievement(group_id);
CREATE INDEX idx_group_achievement_achievement ON Group_Achievement(achievement_id);


-- =========================================================
-- Constraints
-- =========================================================
ALTER TABLE Triggers
ADD CONSTRAINT chk_trigger_schedule_xor
CHECK (
    (cron IS NOT NULL AND time_once IS NULL)
 OR (cron IS NULL AND time_once IS NOT NULL)
);




-- =========================================================
-- Views
-- =========================================================

CREATE OR REPLACE VIEW view_notification_statistics AS
SELECT
    n.id AS notification_id,
    n.title AS notification_title,
    et.name AS event_type,
    a.action_type AS action_name,
    s.created_at AS event_time
FROM Statistics s
JOIN Event_Types et ON s.event_type_id = et.id
JOIN History h ON s.history_id = h.id
JOIN Notifications n ON h.notification_id = n.id
LEFT JOIN Actions a ON s.action_id = a.id;



-- Trigger-Views:
CREATE OR REPLACE VIEW view_triggers_with_schedule AS
SELECT
    id AS trigger_id,
    description,
    active,
    last_triggered_at,
    cron,
    time_once
FROM gamification.Triggers t
JOIN Trigger_Conditions tc ON t.id = tc.trigger_id
JOIN Condition c ON tc.condition_id = c.id
WHERE active = TRUE
  AND (cron IS NOT NULL OR time_once IS NOT NULL);


CREATE OR REPLACE VIEW view_triggers_without_schedule AS
SELECT
    id AS trigger_id,
    description,
    active,
    last_triggered_at,
    cron,
    time_once
FROM gamification.Triggers t
JOIN Trigger_Conditions tc ON t.id = tc.trigger_id
JOIN Condition c ON tc.condition_id = c.id
WHERE active = TRUE
  AND (
      cron IS NULL
      AND time_once IS NULL
  );


--- Leaderboard-View:
CREATE OR REPLACE VIEW view_leaderboard AS
SELECT
    g.id AS group_id,
    g.name AS group_name,
    g.data_table,
    g.level,
    g.xp,
    g.streak,
    RANK() OVER (ORDER BY g.xp DESC, g.level DESC) AS rank
FROM gamification.Groups g
ORDER BY g.xp DESC;


--- Group Achievements:
CREATE OR REPLACE VIEW view_group_achievements AS
SELECT
    g.id AS group_id,
    g.name AS group_name,
    g.data_table,
    a.id AS achievement_id,
    a.title AS achievement_title,
    a.description AS achievement_description,
    a.image_url AS achievement_image_url,
    a.reward_xp AS achievement_reward_xp,
    a.trigger_id
FROM Group_Achievement ga
JOIN Groups g ON ga.group_id = g.id
JOIN Achievements a ON ga.achievement_id = a.id;


-- Group-Members
CREATE OR REPLACE VIEW view_group_members AS
SELECT
    g.id AS group_id,
    g.name AS group_name,
    g.data_table,
    g.level,
    g.xp,
    g.streak,
    m.id AS member_id,
    m.name AS member_name,
    m.endpoint AS member_endpoint
FROM gamification.Group_Member gm
JOIN gamification.Groups g ON gm.group_id = g.id
JOIN gamification.Member m ON gm.member_id = m.id
ORDER BY g.id;

-- Send-Notifications
CREATE OR REPLACE VIEW view_sent_notifications AS
SELECT
    h.id AS history_id,
    n.id AS notification_id,
    n.title AS notification_title,
    n.body AS notification_body,
    n.icon_url,
    n.image_url,
    n.renotify,
    n.silent,
    n.created_at AS notification_created_at,
    h.timestamp AS sent_at,
    t.id AS trigger_id,
    t.description AS trigger_description
FROM gamification.History h
JOIN gamification.Notifications n ON h.notification_id = n.id
LEFT JOIN gamification.Triggers t ON n.trigger_id = t.id
ORDER BY h.timestamp DESC;




-- =========================================================
-- insert used data
-- =========================================================
INSERT INTO gamification.groups (name, data_table)
SELECT o.name, o.data_collection
FROM smartmonitoring.tbl_observedobject o
WHERE o.name LIKE 'SENSOR%'
	AND o.name ~* 'SENSORpi m[0-9]+'
	AND o.data_collection IS NOT NULL
	AND NOT EXISTS(
		SELECT 1
		FROM gamification."groups" g 
		WHERE g.name = o.name
	);
