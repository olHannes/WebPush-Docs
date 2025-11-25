# Notizen für die Gamifikation - Features

> Gamification.Groups unterstützen derzeit: `xp`, `level`, `streak`

## 1. XP + Levelsystem
- `XP` steigt durch Aktivität 
- `Level` steigt automatisch bei bestimmter XP-Schwelle
- XP wird jedne Monat zurückgesetzt -> fairer Wettbewerb
> Level bleibt erhalten

## 2. Leaderboard
- Leaderboard nach `Montalichen XP`
- Leaderboard nach `Level`

## 2. Streaks
- `X Tage hintereinander aktiv`
- wird bei Tag ohne Daten auf 0 gesetzt (*oder schrumpft*)

## 3. Achievements
- Ein Achievement hat einen `Trigger` mit mindestens Condition
- Zusätzlich gibt es `reward_xp` als Belohnung bei Erreichen des Ziels

## 4. Quests
- `Datenbasierte Trigger`:
    - "Heute 500 Meter gelaufen" / "5 Temperaturmessungen über 25°C"
    - gibt `reward_xp` -> wiederkehrendes Achievement
- *zeitlich begrenzt -> z.B. nur im Sommer*

## 5. Negative Gamification
- `XP-Verlust bei inaktiven Tagen`
- `Streak-Verlust` bei Ausfall (oder schrumpfender Streak -> /2)
> Vorsichtig einsetzen

## 6. Store & Items
- zusätzlicher `Coins` Eintrag pro Gruppe
- erhöht sich durch `Achievements`
- Können in *kleinem Shop* eingesetzt werden
    - Items:
        - Skins (default = normale Taube, 10 Coins = lilane Taube, 20 Coins = goldene Taube, ...)
        - Banner für App-Aussehen
    (neue Tabellen notwendig)
