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
    operator TEXT NOT NULL CHECK (operator IN ('>', '<', '==', '>=', '<=', '!=')),
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
ADD CONSTRAINT chk_triggers_cron_xor_time_once
CHECK (cron IS NULL OR time_once IS NULL);





-- =========================================================
-- Views
-- =========================================================

-- Trigger-Views:
CREATE OR REPLACE VIEW view_triggers AS 
SELECT
    t.id AS t_id,
    t.description,
    t.cron,
    t.time_once,
    t.last_triggered_at,
    t.active
FROM gamification.Triggers t;


CREATE OR REPLACE VIEW view_triggers_with_schedule AS
SELECT
    t.id AS trigger_id,
    t.description,
    t.active,
    t.last_triggered_at,
    t.cron,
    t.time_once,
    json_agg(
        json_build_object(
            'condition_id', c.id,
            'data_field', c.data_field,
            'operator', c.operator,
            'threshold', c.threshold
        )
        ORDER BY c.id
    ) AS conditions
FROM Triggers t
JOIN Trigger_Conditions tc ON t.id = tc.trigger_id
JOIN Condition c ON c.id = tc.condition_id
WHERE t.active = TRUE
  AND (t.cron IS NOT NULL OR t.time_once IS NOT NULL)
GROUP BY
    t.id, t.description, t.active, t.last_triggered_at, t.cron, t.time_once;


CREATE OR REPLACE VIEW view_triggers_without_schedule AS
SELECT
    t.id AS trigger_id,
    t.description,
    t.active,
    t.last_triggered_at,
    t.cron,
    t.time_once,
    json_agg(
        json_build_object(
            'condition_id', c.id,
            'data_field', c.data_field,
            'operator', c.operator,
            'threshold', c.threshold
        )
        ORDER BY c.id
    ) AS conditions
FROM Triggers t
JOIN Trigger_Conditions tc ON t.id = tc.trigger_id
JOIN Condition c ON c.id = tc.condition_id
WHERE t.active = TRUE
  AND (t.cron IS NULL AND t.time_once IS NULL)
GROUP BY
    t.id, t.description, t.active, t.last_triggered_at, t.cron, t.time_once;



-- Groups, Members and Leaderboard / Achievements
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



-- Notifications
CREATE OR REPLACE VIEW view_notifications_with_type AS
SELECT
    n.id AS notification_id,
    n.title,
    n.body,
    n.icon_url,
    n.image_url,
    n.renotify,
    n.silent,
    n.created_at,
    t.id AS trigger_id,
    t.description AS trigger_description,
    CASE
        WHEN t.cron IS NULL AND t.time_once IS NULL THEN 'event'
        WHEN t.cron IS NULL AND t.time_once IS NOT NULL THEN 'once'
        WHEN t.cron IS NOT NULL AND t.time_once IS NULL THEN 'time'
        ELSE 'invalid'
    END AS type
FROM gamification.Notifications n
LEFT JOIN gamification.Triggers t
    ON n.trigger_id = t.id;


CREATE OR REPLACE VIEW view_sent_notifications AS
SELECT
    h.id AS history_id,
    n.notification_id,
    n.title AS notification_title,
    n.body AS notification_body,
    n.icon_url,
    n.image_url,
    n.renotify,
    n.silent,
    n.type,

    DATE(n.created_at) AS notification_date,
    TO_CHAR(n.created_at, 'HH24:MI:SS') AS notification_time,
    DATE(h.timestamp) AS sent_date,
    TO_CHAR(h.timestamp, 'HH24:MI:SS') AS sent_time,

    t.id AS trigger_id,
    t.description AS trigger_description
FROM gamification.History h
JOIN gamification.view_notifications_with_type n ON h.notification_id = n.notification_id
LEFT JOIN gamification.Triggers t ON n.trigger_id = t.id
ORDER BY h.timestamp DESC;


-- Check Group Activities
-- DROP FUNCTION gamification.group_today_stats();

CREATE OR REPLACE FUNCTION gamification.group_today_stats()
RETURNS TABLE(
    group_id integer,
    group_name text,
    has_today boolean,
    pm2_5_min double precision,
    pm2_5_max double precision,
    pm10_0_min double precision,
    pm10_0_max double precision,
    temp1_min double precision,
    temp1_max double precision,
    temp2_min double precision,
    temp2_max double precision,
    temp3_min double precision,
    temp3_max double precision
)
LANGUAGE plpgsql
AS $function$
DECLARE
    tbl TEXT;
    g_name TEXT;
    g_id INTEGER;
    sql TEXT;
BEGIN
    -- Tabellenname und Gruppeninformationen laden (hier z.B. erste Gruppe)
    SELECT id, data_table, name INTO g_id, tbl, g_name
    FROM gamification.groups
    LIMIT 1;

    IF tbl IS NULL THEN
        RAISE EXCEPTION 'No data_table found for group';
    END IF;

    -- Dynamisches SQL für die Messwerte der Tabelle
    sql := format(
        $f$
        SELECT
            %s AS group_id,
            '%s' AS group_name,
            EXISTS (
                SELECT 1 FROM smartmonitoring.%I
                WHERE ts::date = CURRENT_DATE
            ) AS has_today,
            MIN(pm2_5), MAX(pm2_5),
            MIN(pm10_0), MAX(pm10_0),
            MIN(temp1), MAX(temp1),
            MIN(temp2), MAX(temp2),
            MIN(temp3), MAX(temp3)
        FROM smartmonitoring.%I
        $f$,
        g_id, g_name, tbl, tbl
    );

    -- Ergebnis direkt als ResultSet zurückgeben
    RETURN QUERY EXECUTE sql;
END;
$function$;




-- Statistics
CREATE OR REPLACE VIEW view_statistics_by_history AS
SELECT
    h.id AS history_id,

    json_agg(
        json_build_object(
            'action', action_name,
            'amount', event_count
        )
        ORDER BY action_name
    ) AS statistics
FROM (
    SELECT
        h.id AS history_id,

        CASE
            WHEN s.action_id IS NOT NULL THEN a.action_type
            ELSE et.name
        END AS action_name,

        COUNT(*) AS event_count
    FROM gamification.History h
    JOIN gamification.Statistics s
        ON s.history_id = h.id
    LEFT JOIN gamification.Actions a
        ON a.id = s.action_id
    LEFT JOIN gamification.Event_Types et
        ON et.id = s.event_type_id
    GROUP BY h.id, action_name
) grouped
JOIN gamification.History h ON grouped.history_id = h.id
GROUP BY h.id;


-- global statistics for last week, month and year
CREATE OR REPLACE VIEW view_global_statistics_base AS
WITH
hist AS (
    SELECT *
    FROM gamification.History
), 
stats AS (
    SELECT
        s.*,
        h.timestamp AS sent_at
    FROM gamification.Statistics s
    JOIN gamification.History h ON h.id = s.history_id
), 
actions AS (
    SELECT
        s.history_id,
        COALESCE(a.action_type, et.name) AS action_name,
        COUNT(*) AS amount
    FROM stats s
    LEFT JOIN gamification.Actions a ON a.id = s.action_id
    LEFT JOIN gamification.Event_Types et ON et.id = s.event_type_id
    GROUP BY s.history_id, action_name
)
SELECT
    h.id AS history_id,
    h.timestamp AS sent_at,
    a.action_name,
    a.amount
FROM hist h
LEFT JOIN actions a ON a.history_id = h.id;


CREATE OR REPLACE VIEW view_global_statistics_week AS
WITH
period_actions AS (
    SELECT
        action_name,
        SUM(amount) AS total_amount
    FROM view_global_statistics_base
    WHERE 
        sent_at >= NOW() - INTERVAL '7 days'
        AND action_name IS NOT NULL
    GROUP BY action_name
)
SELECT jsonb_build_object(
    'period', 'week',
    'since', NOW() - INTERVAL '7 days',
    'sent_notifications',
        (SELECT COUNT(*)
         FROM gamification.History
         WHERE timestamp >= NOW() - INTERVAL '7 days'),
    'actions',
        (SELECT jsonb_agg(
            jsonb_build_object(
                'action', action_name,
                'amount', total_amount
            )
            ORDER BY total_amount DESC
        )
        FROM period_actions)
) AS result;


CREATE OR REPLACE VIEW view_global_statistics_month AS
WITH
period_actions AS (
    SELECT
        action_name,
        SUM(amount) AS total_amount
    FROM view_global_statistics_base
    WHERE 
        sent_at >= NOW() - INTERVAL '1 month'
        AND action_name IS NOT NULL
    GROUP BY action_name
)
SELECT jsonb_build_object(
    'period', 'month',
    'since', NOW() - INTERVAL '1 month',
    'sent_notifications',
        (SELECT COUNT(*)
         FROM gamification.History
         WHERE timestamp >= NOW() - INTERVAL '1 month'),
    'actions',
        (SELECT jsonb_agg(
            jsonb_build_object(
                'action', action_name,
                'amount', total_amount
            )
            ORDER BY total_amount DESC
        )
        FROM period_actions)
) AS result;


CREATE OR REPLACE VIEW view_global_statistics_year AS
WITH
period_actions AS (
    SELECT
        action_name,
        SUM(amount) AS total_amount
    FROM view_global_statistics_base
    WHERE 
        sent_at >= NOW() - INTERVAL '1 year'
        AND action_name IS NOT NULL
    GROUP BY action_name
)
SELECT jsonb_build_object(
    'period', 'year',
    'since', NOW() - INTERVAL '1 year',
    'sent_notifications',
        (SELECT COUNT(*)
         FROM gamification.History
         WHERE timestamp >= NOW() - INTERVAL '1 year'),
    'actions',
        (SELECT jsonb_agg(
            jsonb_build_object(
                'action', action_name,
                'amount', total_amount
            )
            ORDER BY total_amount DESC
        )
        FROM period_actions)
) AS result;

