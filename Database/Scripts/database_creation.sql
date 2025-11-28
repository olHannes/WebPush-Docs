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

CREATE TABLE Group_Picture (
    id SERIAL PRIMARY KEY,
    picture TEXT NOT NULL
);

INSERT INTO Group_Picture (picture) VALUES 
    ('profile_icon_1.png'), 
    ('profile_icon_2.png'), 
    ('profile_icon_3.png'), 
    ('profile_icon_4.png'), 
    ('profile_icon_5.png'), 
    ('profile_icon_6.png');

CREATE TABLE "Group" (
    id SERIAL PRIMARY KEY,
    data_table TEXT,
    last_activity TIMESTAMP,
    name TEXT UNIQUE NOT NULL,
    picture_id INT REFERENCES Group_Picture(id) ON DELETE SET NULL DEFAULT 1,
    streak INT NOT NULL DEFAULT 0 CHECK (streak >= 0),
    level_xp INT NOT NULL DEFAULT 0 CHECK (level_xp >= 0),
    current_xp INT NOT NULL DEFAULT 0 CHECK (current_xp >= 0)
);

CREATE TABLE Group_Member (
    member_id INT NOT NULL REFERENCES Member(id) ON DELETE CASCADE,
    group_id INT NOT NULL REFERENCES "Group"(id) ON DELETE CASCADE,
    PRIMARY KEY (member_id, group_id)
);

-- =========================================================
--  Notifications & Trigger System
-- =========================================================

CREATE TABLE Trigger (
    id SERIAL PRIMARY KEY,
    description TEXT NOT NULL,
    cron TEXT,
    time_once TIMESTAMP,
    last_triggered_at TIMESTAMP,
    active BOOLEAN DEFAULT TRUE
);

CREATE TABLE Condition_Type (
    id SERIAL PRIMARY KEY,
    type TEXT NOT NULL UNIQUE
);

INSERT INTO Condition_Type (type) VALUES
    ('streak'),
    ('level'),
    ('pm2_5_min'),
    ('pm2_5_max'),
    ('pm10_min'),
    ('pm10_max'),
    ('temp_min'),
    ('temp_max'),
    ('distance_all'),
    ('distance_month'),
    ('distance_week'),
    ('duration'),
    ('speed'),
    ('location');

CREATE TABLE Condition (
    id SERIAL PRIMARY KEY,
    type_id INT REFERENCES Condition_Type(id) ON DELETE cascade,
    operator TEXT NOT NULL CHECK (operator IN ('>', '<', '==', '>=', '<=', '!=')),
    threshold NUMERIC NOT NULL
);

CREATE TABLE Trigger_Condition (
    trigger_id INT REFERENCES Trigger(id) ON DELETE CASCADE,
    condition_id INT REFERENCES Condition(id) ON DELETE CASCADE
);

CREATE TABLE Action (
    id SERIAL PRIMARY KEY,
    action_type TEXT NOT NULL,
    title TEXT NOT NULL,
    icon TEXT
);

CREATE TABLE Notification (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    icon_url TEXT,
    image_url TEXT,
    renotify BOOLEAN DEFAULT FALSE,
    silent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    trigger_id INT REFERENCES Trigger(id) ON DELETE CASCADE
);

CREATE TABLE Notification_Action (
    action_id INT NOT NULL REFERENCES Action(id) ON DELETE CASCADE,
    notification_id INT NOT NULL REFERENCES Notification(id) ON DELETE CASCADE,
    PRIMARY KEY (action_id, notification_id)
);

CREATE TABLE History (
    id SERIAL PRIMARY KEY,
    notification_id INT REFERENCES Notification(id) ON DELETE SET NULL,
    timestamp TIMESTAMP DEFAULT NOW()
);

-- =========================================================
-- Lookup Tables
-- =========================================================
CREATE TABLE Event_Type (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);
INSERT INTO Event_Type (name) VALUES ('click'), ('swipe');


CREATE TABLE Statistic (
    id SERIAL PRIMARY KEY,
    history_id INT NOT NULL REFERENCES History(id) ON DELETE CASCADE,
    event_type_id INT NOT NULL REFERENCES Event_Type(id) ON DELETE RESTRICT,
    action_id INT REFERENCES Action(id),
    created_at TIMESTAMP DEFAULT NOW()
);

-- =========================================================
--  Achievements / gamification
-- =========================================================

CREATE TABLE Achievement (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    message TEXT NOT NULL,
    reward_xp INT DEFAULT 0 CHECK (reward_xp >= 0),
    image_url TEXT,
    trigger_id INT REFERENCES Trigger(id) ON DELETE SET NULL
);

CREATE TABLE Group_Achievement (
    group_id INT NOT NULL REFERENCES "Group"(id) ON DELETE CASCADE,
    achievement_id INT NOT NULL REFERENCES Achievement(id) ON DELETE CASCADE,
    PRIMARY KEY (group_id, achievement_id)
);

-- =========================================================
--  Useful Indexes
-- =========================================================

CREATE INDEX idx_member_name ON Member(name);
CREATE UNIQUE INDEX idx_member_endpoint ON Member(endpoint);

CREATE INDEX idx_group_name ON "Group"(name);
CREATE INDEX idx_group_level_xp ON "Group"(level_xp DESC, current_xp DESC);
CREATE INDEX idx_group_streak ON "Group"(streak DESC);

CREATE INDEX idx_triggers_active ON Trigger(active);
CREATE INDEX idx_triggers_type ON Trigger(description);
CREATE INDEX idx_triggers_last_triggered ON Trigger(last_triggered_at);

CREATE INDEX idx_notifications_trigger ON Notification(trigger_id);
CREATE INDEX idx_notifications_created_at ON Notification(created_at DESC);

CREATE INDEX idx_notif_actions_action ON Notification_Action(action_id);
CREATE INDEX idx_notif_actions_notif ON Notification_Action(notification_id);

CREATE INDEX idx_history_notification ON History(notification_id);
CREATE INDEX idx_stats_event_type ON Statistic(event_type_id);
CREATE INDEX idx_stats_action ON Statistic(action_id);
CREATE INDEX idx_stats_history ON Statistic(history_id);

CREATE INDEX idx_achievement_trigger ON Achievement(trigger_id);
CREATE INDEX idx_group_achievement_group ON Group_Achievement(group_id);
CREATE INDEX idx_group_achievement_achievement ON Group_Achievement(achievement_id);


-- =========================================================
-- Constraints
-- =========================================================
ALTER TABLE Trigger
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
    t.active,
    CASE
        WHEN t.cron IS NULL AND t.time_once IS NULL THEN 'event'
        WHEN t.cron IS NULL AND t.time_once IS NOT NULL THEN 'once'
        WHEN t.cron IS NOT NULL AND t.time_once IS NULL THEN 'time'
        ELSE 'invalid'
    END AS type
FROM gamification.Trigger t;


CREATE OR REPLACE VIEW view_triggers_with_schedule AS
SELECT
    t.id AS trigger_id,
    t.description,
    t.active,
    t.last_triggered_at,
    t.cron,
    t.time_once,
    COALESCE(
        json_agg(
            CASE
                WHEN c.id IS NOT NULL THEN
                    json_build_object(
                        'condition_id', c.id,
                        'type', ct.type,
                        'operator', c.operator,
                        'threshold', c.threshold
                    )
            END
            ORDER BY c.id
        ) FILTER (WHERE c.id IS NOT NULL),
        '[]'::json
    ) AS conditions
FROM Trigger t
LEFT JOIN Trigger_Condition tc ON t.id = tc.trigger_id
LEFT JOIN Condition c ON c.id = tc.condition_id
LEFT JOIN Condition_Type ct ON c.type_id = ct.id
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
    COALESCE(
        json_agg(
            CASE
                WHEN c.id IS NOT NULL THEN
                    json_build_object(
                        'condition_id', c.id,
                        'type', ct.type,
                        'operator', c.operator,
                        'threshold', c.threshold
                    )
            END
            ORDER BY c.id
        ) FILTER (WHERE c.id IS NOT NULL),
        '[]'::json
    ) AS conditions
FROM Trigger t
LEFT JOIN Trigger_Condition tc ON t.id = tc.trigger_id
LEFT JOIN Condition c ON c.id = tc.condition_id
LEFT JOIN Condition_Type ct ON c.type_id = ct.id
WHERE t.active = TRUE
  AND (t.cron IS NULL AND t.time_once IS NULL)
GROUP BY
    t.id, t.description, t.active, t.last_triggered_at, t.cron, t.time_once;

CREATE OR REPLACE VIEW view_triggers_with_conditions AS
SELECT
    t.id AS trigger_id,
    t.description,
    t.active,
    t.last_triggered_at,
    t.cron,
    t.time_once,
    COALESCE(
        json_agg(
            CASE
                WHEN c.id IS NOT NULL THEN
                    json_build_object(
                        'condition_id', c.id,
                        'type', ct.type,
                        'operator', c.operator,
                        'threshold', c.threshold
                    )
            END
            ORDER BY c.id
        ) FILTER (WHERE c.id IS NOT NULL),
        '[]'::json
    ) AS conditions
FROM Trigger t
LEFT JOIN Trigger_Condition tc ON t.id = tc.trigger_id
LEFT JOIN Condition c ON c.id = tc.condition_id
LEFT JOIN Condition_Type ct ON c.type_id = ct.id
WHERE t.active = TRUE
GROUP BY
    t.id, t.description, t.active, t.last_triggered_at, t.cron, t.time_once;

-- Groups, Members and Leaderboard / Achievements
CREATE OR REPLACE VIEW view_leaderboard AS
SELECT
    g.id AS group_id,
    g.name AS group_name,
    g.data_table,
    g.level_xp,
    g.current_xp,
    g.streak,
    g.picture_id,
    p.picture,
    RANK() OVER (ORDER BY g.current_xp DESC, g.level_xp DESC) AS rank
FROM gamification."Group" g
LEFT JOIN gamification.Group_Picture p ON g.picture_id = p.id
ORDER BY g.current_xp DESC;

CREATE OR REPLACE VIEW view_groups AS 
SELECT
    g.id AS group_id,
    g.data_table,
    g.last_activity,
    g.name AS group_name,
    g.streak,
    g.level_xp,
    g.current_xp,
    g.picture_id,
    p.picture
FROM gamification."Group" g
LEFT JOIN gamification.Group_Picture p ON g.picture_id = p.id;


CREATE OR REPLACE VIEW view_group_achievements AS
SELECT
    g.id AS group_id,
    g.name AS group_name,
    g.picture_id,
    p.picture,
    g.data_table,
    a.id AS achievement_id,
    a.title AS achievement_title,
    a.description AS achievement_description,
    a.image_url AS achievement_image_url,
    a.reward_xp AS achievement_reward_xp,
    a.trigger_id
FROM Group_Achievement ga
JOIN "Group" g ON ga.group_id = g.id
LEFT JOIN gamification.Group_Picture p ON g.picture_id = p.id
JOIN Achievement a ON ga.achievement_id = a.id;


CREATE OR REPLACE VIEW view_group_members AS
SELECT
    g.id AS group_id,
    g.name AS group_name,
    g.picture_id,
    p.picture,
    g.data_table,
    g.level_xp,
    g.current_xp,
    g.streak,
    m.id AS member_id,
    m.name AS member_name,
    m.endpoint AS member_endpoint
FROM gamification.Group_Member gm
JOIN gamification."Group" g ON gm.group_id = g.id
JOIN gamification.Member m ON gm.member_id = m.id
LEFT JOIN gamification.Group_Picture p ON g.picture_id = p.id
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
FROM gamification.Notification n
LEFT JOIN gamification.Trigger t
    ON n.trigger_id = t.id;


CREATE OR REPLACE VIEW view_sent_notifications AS
SELECT
    h.id AS history_id,
    
    h.notification_id,
    COALESCE(n.title, 'Deleted') AS notification_title,
    COALESCE(n.body, 'Deleted') AS notification_body,
    n.icon_url,
    n.image_url,
    n.renotify,
    n.silent,

    COALESCE(n.type, 'deleted') AS type,

    COALESCE(DATE(n.created_at), DATE(h.timestamp)) AS notification_date,
    COALESCE(TO_CHAR(n.created_at, 'HH24:MI:SS'), '') AS notification_time,

    DATE(h.timestamp) AS sent_date,
    TO_CHAR(h.timestamp, 'HH24:MI:SS') AS sent_time,

    t.id AS trigger_id,
    t.description AS trigger_description

FROM gamification.History h
LEFT JOIN gamification.view_notifications_with_type n
       ON h.notification_id = n.notification_id
LEFT JOIN gamification.Trigger t
       ON n.trigger_id = t.id
ORDER BY h.timestamp DESC;



-- Check Group Activities
-- DROP FUNCTION gamification.group_stats_today();
CREATE OR REPLACE FUNCTION gamification.group_stats_today()
 RETURNS TABLE(group_id integer, group_name text, has_today boolean, pm2_5_min double precision, pm2_5_max double precision, pm2_5_mean double precision, pm10_0_min double precision, pm10_0_max double precision, pm10_0_mean double precision, temp1_min double precision, temp1_max double precision, temp1_mean double precision, temp2_min double precision, temp2_max double precision, temp2_mean double precision, temp3_min double precision, temp3_max double precision, temp3_mean double precision, distance_km double precision)
 LANGUAGE plpgsql
AS $function$
DECLARE
    tbl TEXT;
    g_name TEXT;
    g_id INTEGER;
    sql TEXT;
BEGIN
    FOR g_id, tbl, g_name IN
        SELECT id, data_table, name
        FROM gamification."Group"
    LOOP
        -- Tabelle existiert?
        PERFORM 1
        FROM information_schema.tables
        WHERE table_schema = 'smartmonitoring'
          AND table_name  = tbl;

        IF NOT FOUND THEN
            RAISE NOTICE 'Tabelle % nicht gefunden. Überspringe.', tbl;
            CONTINUE;
        END IF;

        sql := format($f$
            WITH filtered AS (
                SELECT *
                FROM smartmonitoring.%I
                WHERE ts::date = CURRENT_DATE
            ),
            ordered AS (
                SELECT
                    *,
                    lag(ts)  OVER (ORDER BY ts) AS prev_ts,
                    lag(pos) OVER (ORDER BY ts) AS prev_pos
                FROM filtered
            ),
            sessionized AS (
                SELECT *,
                    CASE
                        WHEN prev_ts IS NULL OR ts - prev_ts > INTERVAL '5 minutes'
                        THEN 1 ELSE 0
                    END AS session_break
                FROM ordered
            ),
            session_ids AS (
                SELECT *,
                    SUM(session_break) OVER (ORDER BY ts) AS session_id
                FROM sessionized
            ),
            distances AS (
                SELECT *,
                    CASE
                        WHEN session_id =
                             lag(session_id) OVER (ORDER BY ts)
                        THEN ST_DistanceSphere(prev_pos, pos)
                        ELSE 0
                    END AS segment_m
                FROM session_ids
            )
            SELECT
                %s AS group_id,
                '%s' AS group_name,
                EXISTS(SELECT 1 FROM filtered) AS has_today,

                MIN(pm2_5), MAX(pm2_5), AVG(pm2_5),
                MIN(pm10_0), MAX(pm10_0), AVG(pm10_0),
                MIN(temp1), MAX(temp1), AVG(temp1),
                MIN(temp2), MAX(temp2), AVG(temp2),
                MIN(temp3), MAX(temp3), AVG(temp3),

                COALESCE(SUM(segment_m) / 1000.0, 0) AS distance_km
            FROM distances
        $f$, tbl, g_id, g_name);

        RETURN QUERY EXECUTE sql;
    END LOOP;
END;
$function$
;



-- DROP FUNCTION gamification.group_stats_global();

CREATE OR REPLACE FUNCTION gamification.group_stats_global()
 RETURNS TABLE(group_id integer, group_name text, pm2_5_min double precision, pm2_5_max double precision, pm2_5_mean double precision, pm10_0_min double precision, pm10_0_max double precision, pm10_0_mean double precision, temp1_min double precision, temp1_max double precision, temp1_mean double precision, temp2_min double precision, temp2_max double precision, temp2_mean double precision, temp3_min double precision, temp3_max double precision, temp3_mean double precision, distance_km double precision)
 LANGUAGE plpgsql
AS $function$
DECLARE
    tbl TEXT;
    g_name TEXT;
    g_id INTEGER;
    sql TEXT;
BEGIN
    FOR g_id, tbl, g_name IN
        SELECT id, data_table, name
        FROM gamification."Group"
    LOOP
        -- Tabelle existiert?
        PERFORM 1
        FROM information_schema.tables
        WHERE table_schema = 'smartmonitoring'
          AND table_name  = tbl;

        IF NOT FOUND THEN
            RAISE NOTICE 'Tabelle % nicht gefunden. Überspringe.', tbl;
            CONTINUE;
        END IF;

        sql := format($f$
            WITH ordered AS (
                SELECT
                    *,
                    lag(ts)  OVER (ORDER BY ts) AS prev_ts,
                    lag(pos) OVER (ORDER BY ts) AS prev_pos
                FROM smartmonitoring.%I
            ),
            sessionized AS (
                SELECT *,
                    CASE
                        WHEN prev_ts IS NULL OR ts - prev_ts > INTERVAL '5 minutes'
                        THEN 1 ELSE 0
                    END AS session_break
                FROM ordered
            ),
            session_ids AS (
                SELECT *,
                    SUM(session_break) OVER (ORDER BY ts) AS session_id
                FROM sessionized
            ),
            distances AS (
                SELECT *,
                    CASE
                        WHEN session_id =
                             lag(session_id) OVER (ORDER BY ts)
                        THEN ST_DistanceSphere(prev_pos, pos)
                        ELSE 0
                    END AS segment_m
                FROM session_ids
            )
            SELECT
                %s AS group_id,
                '%s' AS group_name,

                MIN(pm2_5), MAX(pm2_5), AVG(pm2_5),
                MIN(pm10_0), MAX(pm10_0), AVG(pm10_0),
                MIN(temp1), MAX(temp1), AVG(temp1),
                MIN(temp2), MAX(temp2), AVG(temp2),
                MIN(temp3), MAX(temp3), AVG(temp3),

                COALESCE(SUM(segment_m) / 1000.0, 0) AS distance_km
            FROM distances
        $f$, tbl, g_id, g_name);

        RETURN QUERY EXECUTE sql;
    END LOOP;
END;
$function$
;


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
    JOIN gamification.Statistic s
        ON s.history_id = h.id
    LEFT JOIN gamification.Action a
        ON a.id = s.action_id
    LEFT JOIN gamification.Event_Type et
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
    FROM gamification.Statistic s
    JOIN gamification.History h ON h.id = s.history_id
), 
actions AS (
    SELECT
        s.history_id,
        COALESCE(a.action_type, et.name) AS action_name,
        COUNT(*) AS amount
    FROM stats s
    LEFT JOIN gamification.Action a ON a.id = s.action_id
    LEFT JOIN gamification.Event_Type et ON et.id = s.event_type_id
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



CREATE OR REPLACE VIEW view_global_statistics_all AS
WITH
period_actions AS (
    SELECT
        action_name,
        SUM(amount) AS total_amount
    FROM view_global_statistics_base
    WHERE action_name IS NOT NULL
    GROUP BY action_name
)
SELECT jsonb_build_object(
    'period', 'all',
    'since', (SELECT MIN(timestamp) FROM gamification.History),
    'sent_notifications',
        (SELECT COUNT(*) FROM gamification.History),
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