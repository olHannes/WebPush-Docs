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

CREATE TABLE "group" (
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
    group_id INT NOT NULL REFERENCES "group"(id) ON DELETE CASCADE,
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
    type TEXT NOT NULL UNIQUE,
    url TEXT NULL
);

INSERT INTO Condition_Type (type, url) VALUES
    ('count', 'http://localhost:8080/SmartDataAirquality/smartdata/records/'),
    -- könnte durch count gelöst werden: ('active', 'http://localhost:8080/SmartDataAirquality/smartdata/records/group?storage=gamification&includes=last_activity&filter=id,eq,{id}filter=last_activity,ge,{activity_date}&filter=last_activity,lt,{activity_date}'),
    ('streak', NULL/*'http://localhost:8080/SmartDataAirquality/smartdata/records/group/{id}?storage=gamification&includes=streak'*/),
    ('level', NULL/*'http://localhost:8080/SmartDataAirquality/smartdata/records/group/{id}?storage=gamification&includes=level_xp'*/),
    ('xp', NULL/*'http://localhost:8080/SmartDataAirquality/smartdata/records/group/{id}?storage=gamification&includes=current_xp'*/),
    ('pm2_5_min', 'http://localhost:8080/SmartDataLyser/smartdatalyser/statistic/minmaxspan?smartdataurl=/SmartDataAirquality&storage=smartmonitoring&column=pm2_5'),
    ('pm2_5_max', 'http://localhost:8080/SmartDataLyser/smartdatalyser/statistic/minmaxspan?smartdataurl=/SmartDataAirquality&storage=smartmonitoring&column=pm2_5'),
    ('pm10_0_min', 'http://localhost:8080/SmartDataLyser/smartdatalyser/statistic/minmaxspan?smartdataurl=/SmartDataAirquality&storage=smartmonitoring&column=pm10_0'),
    ('pm10_0_max', 'http://localhost:8080/SmartDataLyser/smartdatalyser/statistic/minmaxspan?smartdataurl=/SmartDataAirquality&storage=smartmonitoring&column=pm10_0'),
    ('temp_min', 'http://localhost:8080/SmartDataLyser/smartdatalyser/statistic/minmaxspan?smartdataurl=/SmartDataAirquality&storage=smartmonitoring&column=temp1'),
    ('temp_max', 'http://localhost:8080/SmartDataLyser/smartdatalyser/statistic/minmaxspan?smartdataurl=/SmartDataAirquality&storage=smartmonitoring&column=temp1'),
    ('distance', 'http://localhost:8080/SmartDataLyser/smartdatalyser/geo/distance?smartdataurl=/SmartDataAirquality&storage=smartmonitoring'),
    ('duration', 'http://localhost:8080/SmartDataLyser/smartdatalyser/geo/duration?smartdataurl=/SmartDataAirquality&storage=smartmonitoring'),
    ('speed', 'http://localhost:8080/SmartDataLyser/smartdatalyser/geo/speed?smartdataurl=/SmartDataAirquality&storage=smartmonitoring'),
    ('location', '');

CREATE TABLE Condition_Period (
    id SERIAL PRIMARY KEY,
    type TEXT NOT NULL DEFAULT 'all'
        CHECK (type IN ('all', 'year', 'month', 'week', 'day', 'route', 'date', 'daily_time', 'range')),
    period_date DATE NULL,
    time_start TIME NULL,
    time_end   TIME NULL,
    range_start TIMESTAMP NULL,
    range_end   TIMESTAMP NULL,
    CONSTRAINT period_validation CHECK (
        (type = 'date'
        AND period_date IS NOT NULL
        AND time_start IS NULL AND time_end IS NULL
        AND range_start IS NULL AND range_end IS NULL)
        OR
        (type = 'daily_time'
            AND time_start IS NOT NULL AND time_end IS NOT NULL
            AND period_date IS NULL
            AND range_start IS NULL AND range_end IS NULL)
        OR
        (type = 'range'
            AND range_start IS NOT NULL AND range_end IS NOT NULL
            AND period_date IS NULL
            AND time_start IS NULL AND time_end IS NULL)
        OR
        (type IN ('all', 'year', 'month', 'week', 'day', 'route')
            AND period_date IS NULL
            AND time_start IS NULL AND time_end IS NULL
            AND range_start IS NULL AND range_end IS NULL)
    )
);

INSERT INTO Condition_Period (type) VALUES
('all'),                                                                            -- id 1
('year'),                                                                           -- id 2
('month'),                                                                          -- id 3
('week'),                                                                           -- id 4
('day'),                                                                            -- id 5
('route');

CREATE TABLE Condition (
    id SERIAL PRIMARY KEY,
    type_id INT NOT NULL REFERENCES Condition_Type(id) ON DELETE CASCADE,
    period_id INT NOT NULL REFERENCES Condition_Period(id) ON DELETE CASCADE,
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
INSERT INTO Event_Type (name) VALUES ('click'), ('close');


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

CREATE TABLE Achievement_Tier (
    id SERIAL PRIMARY KEY,
    reward_xp INT DEFAULT 0 CHECK (reward_xp >= 0),
    image_url TEXT,
    trigger_id INT REFERENCES Trigger(id) ON DELETE SET NULL
);

CREATE TABLE Achievement_Set (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    body TEXT NOT NULL,
    tier1_id INT NOT NULL REFERENCES Achievement_Tier(id) ON DELETE CASCADE,
    tier2_id INT NOT NULL REFERENCES Achievement_Tier(id) ON DELETE CASCADE,
    tier3_id INT NOT NULL REFERENCES Achievement_Tier(id) ON DELETE CASCADE
);


CREATE TABLE Group_Achievement (
    group_id INT NOT NULL REFERENCES "group"(id) ON DELETE CASCADE,
    achievement_id INT NOT NULL REFERENCES Achievement_Tier(id) ON DELETE CASCADE,
    PRIMARY KEY (group_id, achievement_id)
);

-- =========================================================
--  Useful Indexes
-- =========================================================

CREATE INDEX idx_member_name ON Member(name);
CREATE UNIQUE INDEX idx_member_endpoint ON Member(endpoint);

CREATE INDEX idx_group_name ON "group"(name);
CREATE INDEX idx_group_level_xp ON "group"(level_xp DESC, current_xp DESC);
CREATE INDEX idx_group_streak ON "group"(streak DESC);

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

CREATE INDEX idx_achievement_trigger ON Achievement_Tier(trigger_id);
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
                        'url', ct.url,
                        'operator', c.operator,
                        'threshold', c.threshold,
                        'period_id', p.id,
                        'period_type', p.type,
                        'period_date', p.period_date,
                        'time_start', p.time_start,
                        'time_end', p.time_end,
                        'range_start', p.range_start,
                        'range_end', p.range_end
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
LEFT JOIN Condition_Period p ON p.id = c.period_id
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
                        'url', ct.url,
                        'operator', c.operator,
                        'threshold', c.threshold,
                        'period_id', p.id,
                        'period_type', p.type,
                        'period_date', p.period_date,
                        'time_start', p.time_start,
                        'time_end', p.time_end,
                        'range_start', p.range_start,
                        'range_end', p.range_end
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
LEFT JOIN Condition_Period p ON p.id = c.period_id
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
                        'url', ct.url,
                        'operator', c.operator,
                        'threshold', c.threshold,
                        'period_id', p.id,
                        'period_type', p.type,
                        'period_date', p.period_date,
                        'time_start', p.time_start,
                        'time_end', p.time_end,
                        'range_start', p.range_start,
                        'range_end', p.range_end
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
LEFT JOIN Condition_Period p ON p.id = c.period_id
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
FROM gamification."group" g
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
FROM gamification."group" g
LEFT JOIN gamification.Group_Picture p ON g.picture_id = p.id;


CREATE OR REPLACE VIEW view_group_achievements AS
SELECT
    g.id AS group_id,
    g.name AS group_name,
    p.picture,
    g.data_table,

    t.id AS achievement_tier_id,
    t.reward_xp,
    t.image_url AS tier_image_url,
    t.trigger_id,

    s.id AS achievement_set_id,
    s.title AS set_title,
    s.description AS set_description,
    s.body AS set_body
FROM Group_Achievement ga
JOIN "group" g ON ga.group_id = g.id
LEFT JOIN Group_Picture p ON g.picture_id = p.id
JOIN Achievement_Tier t ON ga.achievement_id = t.id
LEFT JOIN Achievement_Set s ON 
    s.tier1_id = t.id OR
    s.tier2_id = t.id OR
    s.tier3_id = t.id;


CREATE OR REPLACE VIEW view_group_achievement_progress AS 
SELECT
    g.id AS group_id,
    s.id AS achievement_set_id,
    s.title AS achievement_title,
    s.description AS achievement_description,
    s.body AS achievement_body,

    --level
    CASE
        WHEN ga3.achievement_id IS NOT NULL THEN 3
        WHEN ga2.achievement_id IS NOT NULL THEN 2
        WHEN ga1.achievement_id IS NOT NULL THEN 1
        ELSE 0
    END AS level,

    --image
    CASE
        WHEN ga3.achievement_id IS NOT NULL THEN t3.image_url
        WHEN ga2.achievement_id IS NOT NULL THEN t2.image_url
        WHEN ga1.achievement_id IS NOT NULL THEN t1.image_url
        ELSE NULL
    END AS img_url,

    --xp
    CASE
        WHEN ga3.achievement_id IS NOT NULL THEN t3.reward_xp
        WHEN ga2.achievement_id IS NOT NULL THEN t2.reward_xp
        WHEN ga1.achievement_id IS NOT NULL THEN t1.reward_xp
        ELSE 0
    END AS achievement_reward_xp

FROM "group" g
CROSS JOIN Achievement_Set s
LEFT JOIN Achievement_Tier t1 ON s.tier1_id = t1.id
LEFT JOIN Achievement_Tier t2 ON s.tier2_id = t2.id
LEFT JOIN Achievement_Tier t3 ON s.tier3_id = t3.id

LEFT JOIN Group_Achievement ga1 
    ON ga1.group_id = g.id AND ga1.achievement_id = s.tier1_id

LEFT JOIN Group_Achievement ga2 
    ON ga2.group_id = g.id AND ga2.achievement_id = s.tier2_id

LEFT JOIN Group_Achievement ga3 
    ON ga3.group_id = g.id AND ga3.achievement_id = s.tier3_id;



CREATE OR REPLACE VIEW view_group_achievement_tiers AS
SELECT
    g.id AS group_id,
    s.id AS achievement_set_id,
    s.title AS achievement_title,
    s.description AS achievement_description,
    s.body AS achievement_body,

    jsonb_build_array(
        jsonb_build_object(
            'tier', 1,
            'img_url', t1.image_url,
            'reward_xp', t1.reward_xp,
            'achieved', (ga1.achievement_id IS NOT NULL)
        ),
        jsonb_build_object(
            'tier', 2,
            'img_url', t2.image_url,
            'reward_xp', t2.reward_xp,
            'achieved', (ga2.achievement_id IS NOT NULL)
        ),
        jsonb_build_object(
            'tier', 3,
            'img_url', t3.image_url,
            'reward_xp', t3.reward_xp,
            'achieved', (ga3.achievement_id IS NOT NULL)
        )
    ) AS tiers

FROM "group" g
CROSS JOIN Achievement_Set s
LEFT JOIN Achievement_Tier t1 ON t1.id = s.tier1_id
LEFT JOIN Achievement_Tier t2 ON t2.id = s.tier2_id
LEFT JOIN Achievement_Tier t3 ON t3.id = s.tier3_id

LEFT JOIN Group_Achievement ga1 
    ON ga1.group_id = g.id AND ga1.achievement_id = s.tier1_id

LEFT JOIN Group_Achievement ga2 
    ON ga2.group_id = g.id AND ga2.achievement_id = s.tier2_id

LEFT JOIN Group_Achievement ga3 
    ON ga3.group_id = g.id AND ga3.achievement_id = s.tier3_id;



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
JOIN gamification."group" g ON gm.group_id = g.id
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