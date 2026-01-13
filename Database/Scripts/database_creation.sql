-- =========================================================
--  Schema Reset and Creation
-- =========================================================

DROP SCHEMA IF EXISTS gamification CASCADE;
CREATE SCHEMA gamification;
SET search_path TO gamification;

-- =========================================================
--  Members & Groups
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
    current_xp INT NOT NULL DEFAULT 0 CHECK (current_xp >= 0),
    last_xp INT NOT NULL DEFAULT 0 CHECK (last_xp >= 0)
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
    url TEXT NOT NULL,
    periodic BOOLEAN DEFAULT FALSE
);

INSERT INTO Condition_Type (type, url, periodic) VALUES
('count', 'http://localhost:8080/WebPush/webpush/condition/count?smartdataurl=/SmartDataAirquality&storage=smartmonitoring&collection=<collection>', TRUE),                                 -- id 1
('streak', 'http://localhost:8080/SmartDataAirquality/smartdata/records/view_groups?storage=gamification&filter=group_id,eq,<id>', FALSE),                                                  -- id 2
('level', 'http://localhost:8080/SmartDataAirquality/smartdata/records/view_groups?storage=gamification&filter=group_id,eq,<id>', FALSE),                                                   -- id 3
('xp', 'http://localhost:8080/SmartDataAirquality/smartdata/records/view_groups?storage=gamification&filter=group_id,eq,<id>', FALSE),                                                      -- id 4
('pm2_5_min', 'http://localhost:8080/SmartDataLyser/smartdatalyser/statistic/min?smartdataurl=/SmartDataAirquality&storage=smartmonitoring&collection=<collection>&column=pm2_5', TRUE),    -- id 5
('pm2_5_max', 'http://localhost:8080/SmartDataLyser/smartdatalyser/statistic/max?smartdataurl=/SmartDataAirquality&storage=smartmonitoring&collection=<collection>&column=pm2_5', TRUE),    -- id 6
('pm10_0_min', 'http://localhost:8080/SmartDataLyser/smartdatalyser/statistic/min?smartdataurl=/SmartDataAirquality&storage=smartmonitoring&collection=<collection>&column=pm10_0', TRUE),  -- id 7
('pm10_0_max', 'http://localhost:8080/SmartDataLyser/smartdatalyser/statistic/max?smartdataurl=/SmartDataAirquality&storage=smartmonitoring&collection=<collection>&column=pm10_0', TRUE),  -- id 8
('temp_min', 'http://localhost:8080/SmartDataLyser/smartdatalyser/statistic/min?smartdataurl=/SmartDataAirquality&storage=smartmonitoring&collection=<collection>&column=temp1', TRUE),     -- id 9
('temp_max', 'http://localhost:8080/SmartDataLyser/smartdatalyser/statistic/max?smartdataurl=/SmartDataAirquality&storage=smartmonitoring&collection=<collection>&column=temp1', TRUE),     -- id 10
('distance', 'http://localhost:8080/SmartDataLyser/smartdatalyser/geo/distance?smartdataurl=/SmartDataAirquality&storage=smartmonitoring&collection=<collection>', TRUE),                   -- id 11
('duration', 'http://localhost:8080/SmartDataLyser/smartdatalyser/geo/duration?smartdataurl=/SmartDataAirquality&storage=smartmonitoring&collection=<collection>', TRUE),                   -- id 12
('speed', 'http://localhost:8080/SmartDataLyser/smartdatalyser/geo/speed?smartdataurl=/SmartDataAirquality&storage=smartmonitoring&collection=<collection>', TRUE);                         -- id 13

CREATE TABLE Condition_Period (
    id SERIAL PRIMARY KEY,
    type TEXT NOT NULL
);

INSERT INTO Condition_Period (type) VALUES
('all'),    -- id 1
('year'),   -- id 2
('month'),  -- id 3
('week'),   -- id 4
('day'),    -- id 5
('route'),  -- id 6
('date'),   -- id 7
('time'),   -- id 8
('range');  -- id 9

CREATE TABLE Condition (
    id SERIAL PRIMARY KEY,
    type_id INT NOT NULL REFERENCES Condition_Type(id) ON DELETE CASCADE,
    period_id INT NOT NULL REFERENCES Condition_Period(id) ON DELETE CASCADE DEFAULT 1,
    date_start DATE NULL,
    date_end DATE NULL,
    time_start TIME NULL,
    time_end   TIME NULL,
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

INSERT INTO Action (action_type, title, icon) VALUES
('open', 'Open', '/WebPush-PWA/files/icons/open.png'),                  -- id 1
('dismiss', 'Dismiss', '/WebPush-PWA/files/icons/close.png'),           -- id 2
('measure', 'Measure', '/WebPush-PWA/files/icons/start.png'),           -- id 3
('leaderboard', 'Leaderboard', '/WebPush-PWA/files/icons/rank.png');    -- id 4

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

CREATE TABLE Event_Type (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);
INSERT INTO Event_Type (name) VALUES ('click'), ('close');


CREATE TABLE Statistic (
    id SERIAL PRIMARY KEY,
    history_id INT NOT NULL REFERENCES History(id) ON DELETE CASCADE,
    event_type_id INT REFERENCES Event_Type(id) ON DELETE RESTRICT DEFAULT 1,
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

CREATE TABLE Settings (
    id SERIAL PRIMARY KEY,
    key TEXT UNIQUE NOT NULL,
    value TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'double'
);

INSERT INTO Settings ("key", value, type) VALUES
('first_server_start','', 'string');        -- id 1

INSERT INTO Settings ("key", value) VALUES
('base_xp_per_level','1000.0'),             -- id 2
('xp_increase_per_level','1.1'),            -- id 3
('base_xp_per_km','10.0'),                  -- id 4
('speed_soft_cap','30.0'),                  -- id 5
('min_speed_allowed_walking','1.0'),        -- id 6
('max_speed_allowed_walking','10.0'),       -- id 7
('min_speed_allowed_bicycle','3.0'),        -- id 8
('max_speed_allowed_bicycle','30.0'),       -- id 9
('min_speed_allowed_scooter/eBike','5.0'),  -- id 10
('max_speed_allowed_scooter/eBike','45.0'), -- id 11
('min_speed_allowed_car','10.0'),           -- id 12
('max_speed_allowed_car','200.0'),          -- id 13
('min_speed_allowed_motorcycle','10.0'),    -- id 14
('max_speed_allowed_motorcycle','200.0'),   -- id 15
('min_density_per_km','5.0'),               -- id 16
('max_density_per_km','300.0'),             -- id 17
('max_duration_multiplier','2.0'),          -- id 18
('min_duration_h','0'),                     -- id 19
('min_distance_km','0');                    -- id 20

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
CREATE OR REPLACE VIEW gamification.view_triggers AS
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
FROM gamification.trigger t
LEFT JOIN smartmonitoring.datajobs_params p
    ON t.id = p.value::numeric
   AND p.key = 'trigger_id';


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
                        'periodic', ct.periodic,
                        'operator', c.operator,
                        'threshold', c.threshold,
                        'period_id', c.period_id,
                        'period_type', p.type,
                        'date_start', c.date_start,
                        'date_end', c.date_end,
                        'time_start', c.time_start,
                        'time_end', c.time_end
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
                        'periodic', ct.periodic,
                        'operator', c.operator,
                        'threshold', c.threshold,
                        'period_id', c.period_id,
                        'period_type', p.type,
                        'date_start', c.date_start,
                        'date_end', c.date_end,
                        'time_start', c.time_start,
                        'time_end', c.time_end
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
WITH const AS (
    SELECT
        (SELECT value::numeric FROM gamification.settings WHERE key = 'base_xp_per_level') AS base_xp_per_level,
        (SELECT value::numeric FROM gamification.settings WHERE key = 'xp_increase_per_level') AS xp_increase_per_level
),
lvl AS (
    SELECT
        g.*,
        1 +
        FLOOR(
            LOG(
                GREATEST(g.level_xp, 0)::numeric * (const.xp_increase_per_level - 1)
                / const.base_xp_per_level + 1
            ) / LOG(const.xp_increase_per_level)
        ) AS level
    FROM gamification."group" g, const
),
calc AS (
    SELECT
        l.*,

        /* Level start XP */
        (
            const.base_xp_per_level *
            (
                POWER(const.xp_increase_per_level, l.level - 1) - 1
            ) / (const.xp_increase_per_level - 1)
        ) AS start_xp,

        /* Level end XP */
        (
            const.base_xp_per_level *
            (
                POWER(const.xp_increase_per_level, l.level) - 1
            ) / (const.xp_increase_per_level - 1)
        ) AS end_xp

    FROM lvl l, const
)
SELECT
    c.id AS group_id,
    c.data_table,
    c.last_activity,
    c.name AS group_name,
    c.streak,
    c.level_xp,
    c.current_xp as xp,
    c.level,
    c.picture_id,
    p.picture,

    /* progress in % */
    CASE
        WHEN c.level_xp < c.start_xp THEN 0
        WHEN c.end_xp = c.start_xp THEN 100
        ELSE
            ROUND(
                ((c.level_xp - c.start_xp)::numeric / NULLIF((c.end_xp - c.start_xp), 0)) * 100, 2
            )
    END AS progress

FROM calc c
LEFT JOIN gamification.Group_Picture p ON c.picture_id = p.id;


CREATE OR REPLACE VIEW view_achievement_all AS
SELECT
    s.id               AS achievement_set_id,
    s.title            AS title,
    s.description      AS description,
    s.body             AS body,

    -- Tier 1
    t1.id              AS tier_1_id,
    t1.reward_xp       AS tier_1_reward_xp,
    t1.image_url       AS tier_1_image_url,
    t1.trigger_id      AS tier_1_trigger_id,

    -- Tier 2
    t2.id              AS tier_2_id,
    t2.reward_xp       AS tier_2_reward_xp,
    t2.image_url       AS tier_2_image_url,
    t2.trigger_id      AS tier_2_trigger_id,

    -- Tier 3
    t3.id              AS tier_3_id,
    t3.reward_xp       AS tier_3_reward_xp,
    t3.image_url       AS tier_3_image_url,
    t3.trigger_id      AS tier_3_trigger_id

FROM gamification.Achievement_Set s
JOIN gamification.Achievement_Tier t1 ON t1.id = s.tier1_id
JOIN gamification.Achievement_Tier t2 ON t2.id = s.tier2_id
JOIN gamification.Achievement_Tier t3 ON t3.id = s.tier3_id;


CREATE OR REPLACE VIEW view_achievement_to_send AS
SELECT t.id AS tier_id,
    t.reward_xp,
    t.image_url AS icon_url,
    t.trigger_id,

    s.id AS set_id,
    s.title,
    s.description,
    s.body
FROM Achievement_Tier t JOIN Achievement_Set s ON
    s.tier1_id = t.id OR
    s.tier2_id = t.id OR
    s.tier3_id = t.id
WHERE t.trigger_id IS NOT NULL;

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
            'achieved', (ga1.achievement_id IS NOT NULL),
            'trigger_id', t1.trigger_id
        ),
        jsonb_build_object(
            'tier', 2,
            'img_url', t2.image_url,
            'reward_xp', t2.reward_xp,
            'achieved', (ga2.achievement_id IS NOT NULL),
            'trigger_id', t2.trigger_id
        ),
        jsonb_build_object(
            'tier', 3,
            'img_url', t3.image_url,
            'reward_xp', t3.reward_xp,
            'achieved', (ga3.achievement_id IS NOT NULL),
            'trigger_id', t3.trigger_id
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
WITH const AS (
    SELECT
        (SELECT value::numeric FROM Settings WHERE key = 'base_xp_per_level') AS base_xp_per_level,
        (SELECT value::numeric FROM Settings WHERE key = 'xp_increase_per_level') AS xp_increase_per_level
),
lvl AS (
    SELECT
        g.*,
        1 +
        FLOOR(
            LOG(
                GREATEST(g.level_xp, 0) * (const.xp_increase_per_level - 1)
                / const.base_xp_per_level + 1
            ) / LOG(const.xp_increase_per_level)
        ) AS level
    FROM gamification."group" g, const
)
SELECT
    l.id AS group_id,
    l.name AS group_name,
    l.picture_id,
    p.picture,
    l.data_table,
    l.level_xp,
    l.current_xp AS xp,
    l.streak,
    l.level,
    l.last_xp,
    m.id AS member_id,
    m.name AS member_name,
    m.endpoint AS member_endpoint

FROM lvl l
JOIN gamification.Group_Member gm ON gm.group_id = l.id
JOIN gamification.Member m ON gm.member_id = m.id
LEFT JOIN gamification.Group_Picture p ON l.picture_id = p.id
ORDER BY l.id;



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


-- =========================================================
-- Inserts
-- =========================================================


-- =========================================================
--  Trigger
-- =========================================================
INSERT INTO Trigger (description, cron, time_once, active) VALUES
('Route Report', NULL, NULL, TRUE),                             -- id 1
('Leaderboard Reset', '0 0 12 1 * ?', NULL, TRUE),              -- id 2
('Star Wars Tag', '0 38 11 4 MAY ?', NULL, TRUE),               -- id 3
('Frohe Weihnachten', '0 0 12 25 DEC ?', NULL, TRUE),           -- id 4
('Silvester', '0 0 12 31 DEC ?', NULL, TRUE),                   -- id 5
('Neujahr', '0 0 0 1 JAN ?', NULL, TRUE),                       -- id 6
('Valentinstag', '0 0 9 14 FEB ?', NULL, TRUE),                 -- id 7
('Halloween', '0 0 18 31 OCT ?', NULL, TRUE),                   -- id 8
('Ostern', '0 0 9 1 APR ?', NULL, TRUE),                        -- id 9
('Tag der Arbeit', '0 0 9 1 MAY ?', NULL, TRUE),                -- id 10
('Daily Streak Reminder', '0 0 18 * * ?', NULL, TRUE),          -- id 11
('Weekly XP Summary', '0 0 20 ? * FRI', NULL, TRUE),            -- id 12
('Monthly Achievement Summary', '0 0 20 1 * ?', NULL, TRUE),    -- id 13
('Leaderboard Reset Reminder', '0 0 12 L-2 * ?', NULL, TRUE),   -- id 14
('WebPush Anniversary', '0 10 14 14 OCT ?', NULL, TRUE);        -- id 15

-- =========================================================
--  Notification
-- =========================================================
INSERT INTO Notification (title, body, icon_url, renotify, silent, trigger_id) VALUES
('Yeah, <name>! Your group <group> has finished a route 📍', '+ <earned_xp> XP', '/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 1),                         -- id 1
('Leaderboard Reset 🆕', 'Collect new data now and climb the ranks!', '/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 2),                                    -- id 2
('Happy Star Wars Day 💫', 'May the 4th be with you!', '/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 3),                                                   -- id 3
('Merry Christmas 🎄', 'Merry Christmas and a happy New Year!', '/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 4),                                          -- id 4
('New Year''s Eve 🎉', 'Celebrate the turn of the year!', '/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 5),                                                -- id 5
('New Year 🎆', 'Welcome to the new year!', '/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 6),                                                              -- id 6
('Valentine''s Day 💘', 'Share the love on Valentine''s Day!', '/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 7),                                           -- id 7
('Halloween 🎃', 'Spooky greetings for Halloween!', '/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 8),                                                      -- id 8
('Easter 🐰', 'Happy Easter!', '/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 9),                                                                           -- id 9
('Tag der Arbeit 🛠️', 'Es ist Zeit Daten zu sammeln!', '/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 10),                                                  -- id 10
('Daily Streak Reminder 🍃', 'Keep your streak going! Only a few hours left to maintain your streak.', '/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 11),  -- id 11
('Weekly XP Summary 📊', 'Your weekly XP summary is here!', '/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 12),                                             -- id 12
('Monthly Achievement Summary 📅', 'Your monthly achievement overview is available!', '/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 13),                   -- id 13
('Leaderboard Reset Reminder 🔁', 'The leaderboard reset is imminent!', '/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 14),                                 -- id 14
('WebPush Anniversary 🥳', 'Celebrate our Anniversary with us!', '/WebPush-PWA/files/icons/logo.png', FALSE, FALSE, 15);                                        -- id 15

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
(1, 14),
(2, 14),
(1, 15),
(2, 15);

-- =========================================================
--  Achievements
-- =========================================================

-- Achievement-Set 1: Fine Dust Sentinel
INSERT INTO Condition (type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold) VALUES
(6, 1, NULL, NULL, NULL, NULL, '>=', 40),   -- id 1
(6, 1, NULL, NULL, NULL, NULL, '>=', 60),   -- id 2
(6, 1, NULL, NULL, NULL, NULL, '>=', 80);   -- id 3

INSERT INTO Trigger (description, cron, time_once, active, last_triggered_at) VALUES
('Fine Dust Sentinel I', NUll, NULL, TRUE, NULL),   -- id 16
('Fine Dust Sentinel II', NULL, NULL, TRUE, NULL),  -- id 17
('Fine Dust Sentinel III', NULL, NULL, TRUE, NULL); -- id 18

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(16, 1),
(17, 2),
(18, 3);

INSERT INTO Achievement_Tier (reward_xp, image_url, trigger_id) VALUES
(10, '/WebPush-PWA/files/icons/achievements/FDS_1.png', 16),    -- id 1
(20, '/WebPush-PWA/files/icons/achievements/FDS_2.png', 17),    -- id 2
(40, '/WebPush-PWA/files/icons/achievements/FDS_3.png', 18);    -- id 3

INSERT INTO Achievement_Set (title, description, body, tier1_id, tier2_id, tier3_id)
VALUES (
    'Fine Dust Sentinel',
    'Capture extremely high PM2.5 values.',
    'Next tier achieved for Fine Dust Sentinel! Another extreme PM2.5 reading logged.',
    1, 2, 3
);

-- Achievement-Set 2: Pure Air Guardian
INSERT INTO Condition (type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold) VALUES
(5, 1, NULL, NULL, NULL, NULL, '<=', 15),   -- id 4
(5, 1, NULL, NULL, NULL, NULL, '<=', 10),   -- id 5
(5, 1, NULL, NULL, NULL, NULL, '<=', 5);    -- id 6

INSERT INTO Trigger (description, cron, time_once, active, last_triggered_at) VALUES
('Pure Air Guardian I', NUll, NULL, TRUE, NULL),    -- id 19
('Pure Air Guardian II', NULL, NULL, TRUE, NULL),   -- id 20
('Pure Air Guardian III', NULL, NULL, TRUE, NULL);  -- id 21

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(19, 4),
(20, 5),
(21, 6);

INSERT INTO Achievement_Tier (reward_xp, image_url, trigger_id) VALUES
(10, '/WebPush-PWA/files/icons/achievements/PAG_1.png', 19),    -- id 4
(20, '/WebPush-PWA/files/icons/achievements/PAG_2.png', 20),    -- id 5
(40, '/WebPush-PWA/files/icons/achievements/PAG_3.png', 21);    -- id 6

INSERT INTO Achievement_Set (title, description, body, tier1_id, tier2_id, tier3_id)
VALUES (
    'Pure Air Guardian',
    'Measured ultra-low fine particle pollution.',
    'You’ve hit the next tier of Pure Air Guardian! PM2.5 is exceptionally low again.',
    4, 5, 6
);

-- Achievement-Set 3: Dust Peak Detector
INSERT INTO Condition (type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold) VALUES
(8, 1, NULL, NULL, NULL, NULL, '>=', 50),   -- id 7
(8, 1, NULL, NULL, NULL, NULL, '>=', 100),  -- id 8
(8, 1, NULL, NULL, NULL, NULL, '>=', 150);  -- id 9

INSERT INTO Trigger (description, cron, time_once, active, last_triggered_at) VALUES
('Dust Peak Detector I', NUll, NULL, TRUE, NULL),   -- id 22
('Dust Peak Detector II', NULL, NULL, TRUE, NULL),  -- id 23
('Dust Peak Detector III', NULL, NULL, TRUE, NULL); -- id 24

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(22, 7),
(23, 8),
(24, 9);

INSERT INTO Achievement_Tier (reward_xp, image_url, trigger_id) VALUES
(10, '/WebPush-PWA/files/icons/achievements/DPD_1.png', 22),    -- id 7
(20, '/WebPush-PWA/files/icons/achievements/DPD_2.png', 23),    -- id 8
(40, '/WebPush-PWA/files/icons/achievements/DPD_3.png', 24);    -- id 9

INSERT INTO Achievement_Set (title, description, body, tier1_id, tier2_id, tier3_id)
VALUES (
    'Dust Peak Detector',
    'Recorded unusually high PM10 concentrations.',
    'New tier reached: Dust Peak Detector! You recorded another major PM10 peak.',
    7, 8, 9
);

-- Achievement-Set 4: Clean Air Spotter
INSERT INTO Condition (type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold) VALUES
(7, 1, NULL, NULL, NULL, NULL, '<=', 15),   -- id 10
(7, 1, NULL, NULL, NULL, NULL, '<=', 10),   -- id 11
(7, 1, NULL, NULL, NULL, NULL, '<=', 5);    -- id 12

INSERT INTO Trigger (description, cron, time_once, active, last_triggered_at) VALUES
('Clean Air Spotter I', NUll, NULL, TRUE, NULL),    -- id 25
('Clean Air Spotter II', NULL, NULL, TRUE, NULL),   -- id 26
('Clean Air Spotter III', NULL, NULL, TRUE, NULL);  -- id 27

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(25, 10),
(26, 11),
(27, 12);

INSERT INTO Achievement_Tier (reward_xp, image_url, trigger_id) VALUES
(10, '/WebPush-PWA/files/icons/achievements/CAS_1.png', 25),    -- id 10
(20, '/WebPush-PWA/files/icons/achievements/CAS_2.png', 26),    -- id 11
(40, '/WebPush-PWA/files/icons/achievements/CAS_3.png', 27);    -- id 12

INSERT INTO Achievement_Set (title, description, body, tier1_id, tier2_id, tier3_id)
VALUES (
    'Clean Air Spotter',
    'Detected exceptionally low coarse particle levels.',
    'You advanced to the next tier of Clean Air Spotter! Ultra-low PM10 detected again.',
    10, 11, 12
);

-- Achievement-Set 5: Marathon Mapper
INSERT INTO Condition (type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold) VALUES
(11, 1, NULL, NULL, NULL, NULL, '>=', 50),   -- id 13
(11, 1, NULL, NULL, NULL, NULL, '>=', 100),  -- id 14
(11, 1, NULL, NULL, NULL, NULL, '>=', 250);  -- id 15

INSERT INTO Trigger (description, cron, time_once, active, last_triggered_at) VALUES
('Marathon Mapper I', NUll, NULL, TRUE, NULL),      -- id 28
('Marathon Mapper II', NULL, NULL, TRUE, NULL),     -- id 29
('Marathon Mapper III', NULL, NULL, TRUE, NULL);    -- id 30

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(28, 13),
(29, 14),
(30, 15);

INSERT INTO Achievement_Tier (reward_xp, image_url, trigger_id) VALUES
(10, '/WebPush-PWA/files/icons/achievements/MM_1.png', 28), -- id 13
(20, '/WebPush-PWA/files/icons/achievements/MM_2.png', 29), -- id 14
(40, '/WebPush-PWA/files/icons/achievements/MM_3.png', 30); -- id 15

INSERT INTO Achievement_Set (title, description, body, tier1_id, tier2_id, tier3_id)
VALUES (
    'Marathon Mapper',
    'Covered an impressive amount of distance while collecting data.',
    'Great progress! You reached a new Marathon Mapper tier by covering even more distance.',
    13, 14, 15
);

-- Achievement-Set 6: Unbroken Flame
INSERT INTO Condition (type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold) VALUES
(2, 1, NULL, NULL, NULL, NULL, '>=', 50),   -- id 16
(2, 1, NULL, NULL, NULL, NULL, '>=', 250),  -- id 17
(2, 1, NULL, NULL, NULL, NULL, '>=', 1000); -- id 18

INSERT INTO Trigger (description, cron, time_once, active, last_triggered_at) VALUES
('Unbroken Flame I', NUll, NULL, TRUE, NULL),   -- id 31
('Unbroken Flame II', NULL, NULL, TRUE, NULL),  -- id 32
('Unbroken Flame III', NULL, NULL, TRUE, NULL); -- id 33

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(31, 16),
(32, 17),
(33, 18);

INSERT INTO Achievement_Tier (reward_xp, image_url, trigger_id) VALUES
(10, '/WebPush-PWA/files/icons/achievements/UF_1.png', 31), -- id 16
(20, '/WebPush-PWA/files/icons/achievements/UF_2.png', 32), -- id 17
(40, '/WebPush-PWA/files/icons/achievements/UF_3.png', 33); -- id 18

INSERT INTO Achievement_Set (title, description, body, tier1_id, tier2_id, tier3_id)
VALUES (
    'Unbroken Flame',
    'Maintained a long, unbroken series of measurements.',
    'Your streak keeps burning! You`ve reached the next Unbroken Flame tier.',
    16, 17, 18
);

-- Achievement-Set 7: Deep Freeze Explorer
INSERT INTO Condition (type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold) VALUES
(9, 1, NULL, NULL, NULL, NULL, '<=', 10),   -- id 19
(9, 1, NULL, NULL, NULL, NULL, '<=', 0),    -- id 20
(9, 1, NULL, NULL, NULL, NULL, '<=', -10);  -- id 21

INSERT INTO Trigger (description, cron, time_once, active, last_triggered_at) VALUES
('Deep Freeze Explorer I', NUll, NULL, TRUE, NULL),     -- id 34
('Deep Freeze Explorer II', NULL, NULL, TRUE, NULL),    -- id 35
('Deep Freeze Explorer III', NULL, NULL, TRUE, NULL);   -- id 36

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(34, 19),
(35, 20),
(36, 21);

INSERT INTO Achievement_Tier (reward_xp, image_url, trigger_id) VALUES
(10, '/WebPush-PWA/files/icons/achievements/DFE_1.png', 34),    -- id 19
(20, '/WebPush-PWA/files/icons/achievements/DFE_2.png', 35),    -- id 20
(40, '/WebPush-PWA/files/icons/achievements/DFE_3.png', 36);    -- id 21

INSERT INTO Achievement_Set (title, description, body, tier1_id, tier2_id, tier3_id)
VALUES (
    'Deep Freeze Explorer',
    'Collected data in extremely cold conditions.',
    'Next tier achieved: Deep Freeze Explorer! Your cold-weather measurements keep getting stronger.',
    19, 20, 21
);

-- Achievement-Set 8: Extreme Heat Scout
INSERT INTO Condition (type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold) VALUES
(10, 1, NULL, NULL, NULL, NULL, '>=', 25),   -- id 22
(10, 1, NULL, NULL, NULL, NULL, '>=', 32),   -- id 23
(10, 1, NULL, NULL, NULL, NULL, '>=', 40);   -- id 24

INSERT INTO Trigger (description, cron, time_once, active, last_triggered_at) VALUES
('Extreme Heat Scout I', NUll, NULL, TRUE, NULL),   -- id 37
('Extreme Heat Scout II', NULL, NULL, TRUE, NULL),  -- id 38
('Extreme Heat Scout III', NULL, NULL, TRUE, NULL); -- id 39

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(37, 22),
(38, 23),
(39, 24);

INSERT INTO Achievement_Tier (reward_xp, image_url, trigger_id) VALUES
(10, '/WebPush-PWA/files/icons/achievements/EHS_1.png', 37),    -- id 22
(20, '/WebPush-PWA/files/icons/achievements/EHS_2.png', 38),    -- id 23
(40, '/WebPush-PWA/files/icons/achievements/EHS_3.png', 39);    -- id 24

INSERT INTO Achievement_Set (title, description, body, tier1_id, tier2_id, tier3_id)
VALUES (
    'Extreme Heat Scout',
    'Measured air quality during exceptionally high temperatures.',
    'You`ve reached the next tier of Extreme Heat Scout! Your measurements in extreme heat are leveling up.',
    22, 23, 24
);

-- Achievement-Set 9: Night Shift Monitor
INSERT INTO Condition (type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold) VALUES
(11, 8, NULL, NULL, '20:00:00', '23:59:59', '>=', 10),   -- id 25
(11, 8, NULL, NULL, '20:00:00', '23:59:59', '>=', 25),   -- id 26
(11, 8, NULL, NULL, '20:00:00', '23:59:59', '>=', 50);   -- id 27

INSERT INTO Trigger (description, cron, time_once, active, last_triggered_at) VALUES
('Night Shift Monitor I', NUll, NULL, TRUE, NULL),      -- id 40
('Night Shift Monitor II', NULL, NULL, TRUE, NULL),     -- id 41
('Night Shift Monitor III', NULL, NULL, TRUE, NULL);    -- id 42

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(40, 25),
(41, 26),
(42, 27);

INSERT INTO Achievement_Tier (reward_xp, image_url, trigger_id) VALUES
(10, '/WebPush-PWA/files/icons/achievements/NSM_1.png', 40),    -- id 25
(20, '/WebPush-PWA/files/icons/achievements/NSM_2.png', 41),    -- id 26
(40, '/WebPush-PWA/files/icons/achievements/NSM_3.png', 42);    -- id 27

INSERT INTO Achievement_Set (title, description, body, tier1_id, tier2_id, tier3_id)
VALUES (
    'Night Shift Monitor',
    'Performed measurements deep into the night.(8pm-12pm)',
    'Another night, another tier! Night Shift Monitor has reached the next level.',
    25, 26, 27
);

-- Achievement-Set 10: Dawn Tracker
INSERT INTO Condition (type_id, period_id, date_start, date_end, time_start, time_end, operator, threshold) VALUES
(11, 8, NULL, NULL, '02:00:00', '06:00:00', '>=', 10),  -- id 28
(11, 8, NULL, NULL, '02:00:00', '06:00:00', '>=', 25),  -- id 29
(11, 8, NULL, NULL, '02:00:00', '06:00:00', '>=', 50);  -- id 30

INSERT INTO Trigger (description, cron, time_once, active, last_triggered_at) VALUES
('Dawn Tracker I', NUll, NULL, TRUE, NULL),     -- id 43
('Dawn Tracker II', NULL, NULL, TRUE, NULL),    -- id 44
('Dawn Tracker III', NULL, NULL, TRUE, NULL);   -- id 45

INSERT INTO Trigger_Condition (trigger_id, condition_id) VALUES
(43, 28),
(44, 29),
(45, 30);

INSERT INTO Achievement_Tier (reward_xp, image_url, trigger_id) VALUES
(10, '/WebPush-PWA/files/icons/achievements/DT_1.png', 43), -- id 28
(20, '/WebPush-PWA/files/icons/achievements/DT_2.png', 44), -- id 29
(40, '/WebPush-PWA/files/icons/achievements/DT_3.png', 45); -- id 30

INSERT INTO Achievement_Set (title, description, body, tier1_id, tier2_id, tier3_id)
VALUES (
    'Dawn Tracker',
    'Collected data at the earliest hours of the day.(2am-6am)',
    'You advanced to a new Dawn Tracker tier by measuring at dawn again.',
    28, 29, 30
);