USE DATABASE STAR_DEV;
USE SCHEMA PROFILE;

-- NAMES
-- ============================================================
-- UDF: generic_clean_name
-- Useful for simple clean-up of names
-- ============================================================
CREATE
OR REPLACE FUNCTION generic_clean_name(raw_name STRING) 
    RETURNS STRING 
    LANGUAGE SQL AS 
    $$
    WITH step1 AS (
        -- Remove control characters
        SELECT REGEXP_REPLACE(raw_name, '[\\x00-\\x1F\\x7F]', '') AS v
    ),
    step2 AS (
        -- Strip digits entirely
        SELECT REGEXP_REPLACE(v, '[0-9]', '') AS v FROM step1
    ),
    step3 AS (
        -- Keep only: letters (incl. accented), spaces, hyphens, apostrophes, periods
        -- Everything else (punctuation, symbols) is removed
        SELECT REGEXP_REPLACE(v, '[^a-zA-Z\\s\\-\\.\']', '') AS v 
        FROM step2
    ),
    step4 AS (
        -- Collapse repeated hyphens, apostrophes, periods to single instance
        SELECT
            REGEXP_REPLACE(
            REGEXP_REPLACE(
            REGEXP_REPLACE(v,
                '-{2,}', '-'),
                '\'{2,}', ''''),
                '\\.{2,}', '.')
        AS v FROM step3
    ),
    step5 AS (
        -- Strip leading/trailing punctuation (hyphen, apostrophe, period)
        SELECT REGEXP_REPLACE(
            REGEXP_REPLACE(v, '^[\\-\\.\']+', ''),
            '[\\-\\.\']+$', ''
        ) AS v FROM step4
    ),
    step6 AS (
        -- Collapse multiple spaces to one, final trim
        SELECT TRIM(REGEXP_REPLACE(v, '\\s+', ' ')) AS v FROM step5
    )
    SELECT NULLIF(v, '') FROM step6
$$;

--TEST
SELECT generic_clean_name('    ****JOE     ***BAG-----ADOUNUTS005,,,,,,,');

-- ============================================================
-- UDF: normalize_first_name
-- Strip non-sensical punctuation; keep hyphen, apostrophe, period
-- Collapse repeated hyphens, apostrophes, periods
-- Strip leading/trailing hyphens, apostrophes, periods
-- Proper-case each hyphen-separated segment
-- Handles: "JOHN" → "John", "mary-jane" → "Mary-Jane",
--          "J." → "J", "j" → "J"
-- ============================================================
CREATE
OR REPLACE FUNCTION normalize_first_name(raw_first STRING) 
   RETURNS STRING 
   LANGUAGE SQL AS 
   $$
    WITH step1 AS (
        SELECT UPPER(TRIM(raw_first)) AS v
    ),
    step2 AS (
        -- Collapse multiple spaces
        SELECT TRIM(REGEXP_REPLACE(v, '\\s+', ' ')) AS v FROM step1
    ),
    step3 AS (
        -- Strip digits
        SELECT TRANSLATE(v,
            '0123456789', '') AS v FROM step2
    ),
    step4 AS (
        -- Strip non-sensical punctuation; keep hyphen, apostrophe, period
        SELECT TRANSLATE(v,
            '!@#$%^&*()+=[]{}|\\/:;"<>?,`~_',
            '') AS v FROM step3
    ),
    step5 AS (
        -- Collapse repeated hyphens, apostrophes, periods
        SELECT
            REGEXP_REPLACE(
            REGEXP_REPLACE(
            REGEXP_REPLACE(v,
                '-{2,}', '-'),
                '\'{2,}', ''''),
                '\\.{2,}', '.')
        AS v FROM step4
    ),
    step6 AS (
        -- Strip leading/trailing hyphens, apostrophes, periods
        SELECT REGEXP_REPLACE(
            REGEXP_REPLACE(v, '^[\\-\\.\']+', ''),
            '[\\-\\.\']+$', ''
        ) AS v FROM step5
    ),
    step7 AS (
        -- Strip trailing period (initial like "J.")
        SELECT REGEXP_REPLACE(v, '\\.$', '') AS v FROM step6
    ),
    step8 AS (
        -- Proper-case each hyphen-separated segment
        SELECT
            ARRAY_TO_STRING(
                TRANSFORM(
                    SPLIT(v, '-'),
                    seg ->
                        CASE
                            WHEN LENGTH(seg) = 0 THEN ''
                            ELSE UPPER(LEFT(seg, 1)) || LOWER(SUBSTR(seg, 2))
                        END
                ),
                '-'
            ) AS v
        FROM step7
    )
    SELECT
        CASE
            WHEN v IS NULL OR LENGTH(TRIM(v)) = 0 THEN NULL
            ELSE v
        END
    FROM step8
$$;

--TEST
SELECT
    normalize_first_name('    ****JOE----BaGGA005,,,,,,,');
    
-- ============================================================
-- UDF: normalize_last_name
-- Collapse multiple spaces
-- Strip digits
-- Strip non-sensical punctuation; keep hyphen, apostrophe, period
-- Collapse repeated hyphens, apostrophes, periods
-- Strip leading/trailing hyphens, apostrophes, periods
-- Strip leading/trailing hyphens, apostrophes, periods
-- Split on hyphen, apply Mc / O' / standard proper-case per segment
-- Normalize suffixes via CASE (avoids backreference regex)
-- ============================================================
CREATE
OR REPLACE FUNCTION normalize_last_name(raw_last STRING) RETURNS STRING LANGUAGE SQL AS $$
WITH step1 AS (
    SELECT UPPER(TRIM(raw_last)) AS v
),
step2 AS (
    -- Collapse multiple spaces
    SELECT TRIM(REGEXP_REPLACE(v, '\\s+', ' ')) AS v FROM step1
),
step3 AS (
    -- Strip digits
    SELECT TRANSLATE(v,
        '0123456789', '') AS v FROM step2
),
step4 AS (
    -- Strip non-sensical punctuation; keep hyphen, apostrophe, period
    SELECT TRANSLATE(v,
        '!@#$%^&*()+=[]{}|\\/:;"<>?,`~_',
        '') AS v FROM step3
),
step5 AS (
    -- Collapse repeated hyphens, apostrophes, periods
    SELECT
        REGEXP_REPLACE(
        REGEXP_REPLACE(
        REGEXP_REPLACE(v,
            '-{2,}', '-'),
            '\'{2,}', ''''),
            '\\.{2,}', '.')
    AS v FROM step4
),
step6 AS (
    -- Strip leading/trailing hyphens, apostrophes, periods
    SELECT REGEXP_REPLACE(
        REGEXP_REPLACE(v, '^[\\-\\.\']+', ''),
        '[\\-\\.\']+$', ''
    ) AS v FROM step5
),
step7 AS (
    -- Split on hyphen, apply Mc / O' / standard proper-case per segment
    SELECT
        ARRAY_TO_STRING(
            TRANSFORM(
                SPLIT(v, '-'),
                seg ->
                    CASE
                        WHEN LOWER(LEFT(seg, 2)) = 'mc' AND LENGTH(seg) > 2
                            THEN 'Mc' || UPPER(SUBSTR(seg, 3, 1)) || LOWER(SUBSTR(seg, 4))
                        WHEN LEFT(seg, 2) = 'O'''
                            THEN 'O''' || UPPER(SUBSTR(seg, 3, 1)) || LOWER(SUBSTR(seg, 4))
                        ELSE UPPER(LEFT(seg, 1)) || LOWER(SUBSTR(seg, 2))
                    END
            ),
            '-'
        ) AS v
    FROM step6
),
step8 AS (
    -- Re-lowercase noble/language particles
    SELECT
        ARRAY_TO_STRING(
            TRANSFORM(
                SPLIT(v, ' '),
                w ->
                    CASE
                        WHEN ARRAY_CONTAINS(
                            LOWER(w)::VARIANT,
                            ARRAY_CONSTRUCT(
                                'de', 'del', 'della', 'di', 'da',
                                'van', 'von', 'la', 'le', 'les',
                                'du', 'des', 'el', 'al',
                                'bin', 'bint'
                            )
                        ) THEN LOWER(w)
                        ELSE w
                    END
            ),
            ' '
        ) AS v
    FROM step7
),
step9 AS (
    -- Normalize suffixes via CASE (avoids backreference regex)
    SELECT
        ARRAY_TO_STRING(
            TRANSFORM(
                SPLIT(v, ' '),
                w ->
                    CASE UPPER(w)
                        WHEN 'JR'     THEN 'Jr'
                        WHEN 'JUNIOR' THEN 'Jr'
                        WHEN 'SR'     THEN 'Sr'
                        WHEN 'SENIOR' THEN 'Sr'
                        WHEN 'II'     THEN 'II'
                        WHEN 'III'    THEN 'III'
                        WHEN 'IV'     THEN 'IV'
                        WHEN 'V'      THEN 'V'
                        ELSE w
                    END
            ),
            ' '
        ) AS v
    FROM step8
)
SELECT
    CASE
        WHEN v IS NULL OR LENGTH(TRIM(v)) = 0 THEN NULL
        ELSE v
    END
FROM step9
$$;

--TEST: Combine function call
--    : Use DIM_PATIENT
SELECT
    DIM_PATIENT_KEY,
    FIRST_NAME,
    normalize_first_name(FIRST_NAME) AS FIRST_NAME_std,
    LAST_NAME,
    normalize_last_name(LAST_NAME) AS LAST_NAME_std,
    CASE
        WHEN LENGTH(TRIM(FIRST_NAME)) <= 1 THEN 'review:initial_only'
        WHEN FIRST_NAME RLIKE '^[0-9]' THEN 'review:starts_with_digit'
        WHEN FIRST_NAME RLIKE '[0-9]{3}' THEN 'review:contains_digits'
        WHEN FIRST_NAME RLIKE '.*[!@#\\$%\\^&\\*\\(\\)\\+=\\[\\]\\{\\}\\|\\\\/:;"<>\\?,`~_].*' THEN 'review:odd_punctuation'
        ELSE NULL
    END AS first_name_flag,
    CASE
        WHEN LENGTH(TRIM(LAST_NAME)) <= 1 THEN 'review:initial_only'
        WHEN LAST_NAME RLIKE '^[0-9]' THEN 'review:starts_with_digit'
        WHEN LAST_NAME RLIKE '.*[!@#\\$%\\^&\\*\\(\\)\\+=\\[\\]\\{\\}\\|\\\\/:;"<>\\?,`~_].*' THEN 'review:odd_punctuation'
        ELSE NULL
    END AS last_name_flag
FROM
    STAR.DIM_MODEL.DIM_PATIENT
ORDER BY
    LAST_NAME ASC;

