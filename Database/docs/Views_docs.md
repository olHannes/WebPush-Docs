# Views Dokumentation
*Diese Datei beschreibt alle erstellten Views der Datenbank Smartmonitoring_airquality.gamification. Es soll außerdem als Hilfe bei der Entwicklung des Frontend's dienen*
> Jeder Eintrag hier sollte aus dem SQL-Script und einer dazugehörigen Beschreibung / Erklärung bestehen. 


## Trigger
### Zeitbasierte Trigger
```sql
CREATE OR REPLACE VIEW view_triggers_with_schedule AS
SELECT
    id AS trigger_id,
    description,
    active,
    last_triggered_at,
    config,
    config->'when'->'schedule' AS schedule_config,
    config->'when'->'conditions' AS conditions_config
FROM gamification.Triggers
WHERE active = TRUE
  AND config->'when'->'schedule' IS NOT NULL;
```
> Der View `view_triggers_with_schedule` liefert alle Trigger, welche zeitbasiert arbeiten. *Die Datenbasierten conditions müssen vor dem Senden trotzdem geprüft werden.*


### Datenbasierte Trigger
```sql
CREATE OR REPLACE VIEW view_triggers_without_schedule AS
SELECT
    id AS trigger_id,
    description,
    active,
    last_triggered_at,
    config,
    config->'when'->'conditions' AS conditions_config
FROM gamification.Triggers
WHERE active = TRUE
  AND (
      config->'when' IS NULL
      OR config->'when'->'schedule' IS NULL
  );
```
> Der View `view_triggers_without_schedule` liefert alle Trigger, welche rein datenbasiert arbeiten. *Die Liste an conditions müssen alle erfüllt sein.*

