# Job Scheduling Rules

This document defines the behavior of the job scheduling system and
describes how the optional parameters **Active**, **Start**, **Stop**,
and **RepeatSeconds** interact.

## Overview

A job can be configured with the following optional parameters:

-   **Active** (`bool`)\
    Indicates whether the job should be considered for execution.

-   **Start** (`Timestamp`)\
    The earliest time the job is allowed to run.

-   **Stop** (`Timestamp`)\
    The latest time the job is allowed to run (exclusive cutoff).

-   **RepeatSeconds** (`int`)\
    Interval for repeated execution.\
    If null → job is considered **one-time**.

If a parameter is omitted, the scheduler applies the defaults described
below.

---

## Default Semantics

-   `Active` missing →
-   `Start` missing → defaults to **now**
-   `Stop` missing → no end date (infinite)
-   `RepeatSeconds` missing → one-time job

### General Rules

1.  If `Active == false`, the job **never runs**.
2.  If `RepeatSeconds == null`, the job runs **exactly once** at the
    start time.
3.  If `RepeatSeconds != null`, the job runs **periodically** starting
    at or after the start time.
4.  `Stop` acts as an **exclusive** boundary: no execution time may be
    **greater than or equal to** `Stop`.
5.  If both `Start` and `Stop` are provided and `Start >= Stop`, the
    configuration is **invalid** and the job is never executed.

---

## Parameter Combinations

Below is the expected behavior for each relevant combination (assuming
`Active = true`).

### 1. No Start, No Stop, No Repeat
```
Start = null  
Stop = null  
RepeatSeconds = null
```

-   One-time job that should run **immediately** (on the next scheduler
    cycle).

---

### 2. Only Start

```
Start = T  
RepeatSeconds = null  
Stop = null
```

-   One-time job executed **exactly at `T`**.

---

### 3. Only Stop

```
Stop = S  
Start = null  
RepeatSeconds = null
```

- Treated as if configured with:

```
Start = now
Stop = S
RepeatSeconds = null
````

---

### 4. Only RepeatSeconds

```
RepeatSeconds = R  
Start = null  
Stop = null
````

-   Periodic job starting **now**, repeating every `R` seconds without
    an end date.

---

### 5. Start + RepeatSeconds

```
Start = T  
RepeatSeconds = R  
Stop = null
```

-   Periodic job starting at `T`, repeating every `R` seconds
    indefinitely.

---

### 6. Stop + RepeatSeconds (No Start)

```
Stop = S  
RepeatSeconds = R  
Start = null
````

-   Periodic job starting **now**, repeating every `R` seconds.
-   Execution stops when the next run would be `>= S`.

If `now >= S`, the job never runs.

---

### 7. Start + Stop (No Repeat)

```
Start = T  
Stop = S  
RepeatSeconds = null
````

-   One-time job executed **at `T`**, but only if `T < S`.

If `T >= S`, the job is **invalid** and never runs.

---

### 8. Start + Stop + RepeatSeconds

```
Start = T  
Stop = S  
RepeatSeconds = R
````

-   Periodic job running at\
    `T`, `T + R`, `T + 2R`, ...\
    as long as each execution time is **\< S**.

If `T >= S`, the job is invalid.

---

## Special Cases and Edge Behavior

### Start in the Past

- **One-time jobs** (`RepeatSeconds == null`):  
  - If `Start < now`, the job does **not** run.
-   **Periodic job**
    -   Compute the first execution time **≥ now** based on the
        interval:

            n = ceil((now - Start) / RepeatSeconds)
            nextRun = Start + n * RepeatSeconds

    -   Only run if `nextRun < Stop` (if defined).

---
