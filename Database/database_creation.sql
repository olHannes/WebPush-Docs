-- =========================================================
--  SCHEMA RESET
-- =========================================================

-- Schema neu erstellen
DROP SCHEMA IF EXISTS gamification CASCADE;
CREATE SCHEMA gamification;
SET search_path TO gamification;


-- Reihenfolge ist wichtig wegen Foreign Keys.
-- Erst die abhängigen Tabellen löschen, dann die Basistabellen.

DROP TABLE IF EXISTS 
    Notification_statistics,
    History,
    Notification_actions,
    Notifications,
    Triggers,
    Group_Achievement,
    Achievement,
    Group_Member,
    Groups,
    Member
CASCADE;

-- =========================================================
--  Base Entities
-- =========================================================

CREATE TABLE Member (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    subscription JSONB NOT NULL  -- { endpoint, key, auth }
);

CREATE TABLE Groups (
    id SERIAL PRIMARY KEY,
    data_table TEXT,
    streak INT NOT NULL DEFAULT 0,
    level INT NOT NULL DEFAULT 0,
    xp INT NOT NULL DEFAULT 0
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
    type TEXT NOT NULL,
    config JSONB NOT NULL,  -- condition (time / data)
    last_triggered_at TIMESTAMP,
    active BOOLEAN DEFAULT TRUE
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
    trigger_id INT REFERENCES Triggers(id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE Notification_actions (
    id SERIAL PRIMARY KEY,
    notification_id INT NOT NULL REFERENCES Notifications(id) ON DELETE CASCADE,
    action TEXT NOT NULL,
    title TEXT,
    icon TEXT
);

CREATE TABLE History (
    id SERIAL PRIMARY KEY,
    notification_id INT NOT NULL REFERENCES Notifications(id) ON DELETE CASCADE,
    group_id INT REFERENCES Groups(id) ON DELETE CASCADE,
    timestamp TIMESTAMP DEFAULT NOW()
);

CREATE TABLE Notification_statistics (
    id SERIAL PRIMARY KEY,
    history_id INT NOT NULL REFERENCES History(id) ON DELETE CASCADE,
    group_id INT REFERENCES Groups(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =========================================================
--  Achievements / gamification
-- =========================================================

CREATE TABLE Achievement (
    id SERIAL PRIMARY KEY,
    type TEXT NOT NULL,
    message TEXT NOT NULL,
    image_url TEXT,
    config JSONB NOT NULL   -- condition (time / data)
);

CREATE TABLE Group_Achievement (
    group_id INT NOT NULL REFERENCES Groups(id) ON DELETE CASCADE,
    achievement_id INT NOT NULL REFERENCES Achievement(id) ON DELETE CASCADE,
    PRIMARY KEY (group_id, achievement_id)
);

-- =========================================================
--  Optional: Constraints and Checks
-- =========================================================

ALTER TABLE Notification_statistics
  ADD CONSTRAINT chk_event_type CHECK (event_type IN ('click', 'swipe', 'view', 'sent'));

-- =========================================================
--  Useful Indexes
-- =========================================================

CREATE INDEX idx_trigger_active ON Triggers(active);
CREATE INDEX idx_notifications_active ON Notifications(is_active);
CREATE INDEX idx_notification_stats_group ON Notification_statistics(group_id);
CREATE INDEX idx_history_group ON History(group_id);
