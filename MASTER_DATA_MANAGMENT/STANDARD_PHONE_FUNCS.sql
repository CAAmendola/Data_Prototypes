    -- ============================================================
    -- UDF: normalize_phone
    -- Returns: E.164 format (+1XXXXXXXXXX for US/CA,
    --          +CCXXXXXXXXX for international)
    -- Also sets a flag for unclassifiable numbers
    -- ============================================================
    CREATE
    OR REPLACE FUNCTION normalize_phone(raw_phone STRING) RETURNS OBJECT --VARIANT
    LANGUAGE SQL AS $$
    WITH step1 AS (
        -- Null / empty guard
        SELECT
            CASE
                WHEN raw_phone IS NULL OR LENGTH(TRIM(raw_phone)) = 0
                THEN NULL
                ELSE TRIM(raw_phone)
            END AS v
    ),
    step2 AS (
        -- Preserve leading + before stripping everything else
        SELECT
            CASE
                WHEN LEFT(v, 1) = '+' THEN '+' || REGEXP_REPLACE(SUBSTR(v, 2), '[^0-9]', '')
                WHEN LEFT(v, 2) = '00' THEN '+' || REGEXP_REPLACE(SUBSTR(v, 3), '[^0-9]', '')
                ELSE REGEXP_REPLACE(v, '[^0-9]', '')
            END AS v
        FROM step1
    ),
    step3 AS (
        -- Strip common vanity / extension suffixes
        -- e.g. "212-555-1234 x42" → "2125551234"
        --      "212-555-1234 ext 42" → "2125551234"
        SELECT
            REGEXP_REPLACE(
                REGEXP_REPLACE(v,
                    '[xX][0-9]+$', ''),        -- trailing x42
                '(EXT|EXTN|EXTENSION)[0-9]+$', ''  -- trailing ext42
            ) AS v
        FROM step2
    ),
    step4 AS (
        -- Classify and normalize to E.164
        SELECT
            v,
            LENGTH(v)                          AS digit_len,
            CASE
                -- Already has country code prefix from + or 00
                WHEN LEFT(v, 1) = '+'
                    THEN v

                -- US/Canada: 10 digits → prepend +1
                WHEN LENGTH(v) = 10
                 AND LEFT(v, 1) != '0'
                    THEN '+1' || v

                -- US/Canada: 11 digits starting with 1 → prepend +
                WHEN LENGTH(v) = 11
                 AND LEFT(v, 1) = '1'
                    THEN '+' || v

                ELSE NULL   -- unclassifiable
            END AS e164
        FROM step3
    ),
    step5 AS (
        -- Validate E.164: must be + followed by 7-15 digits
        SELECT
            v                                   AS digits_only,
            e164,
            digit_len,
            CASE
                WHEN e164 IS NULL
                    THEN 'review:unclassifiable'
                WHEN NOT (e164 RLIKE '^\\+[1-9][0-9]{6,14}$')
                    THEN 'review:invalid_length'
                WHEN e164 RLIKE '^\\+1(0|1)'
                    THEN 'review:invalid_us_area_code'
                WHEN e164 RLIKE '^\\+1[0-9]{3}(555)(01[0-9][0-9]|1[2-9][0-9]{2})'
                    THEN 'review:fictitious_555_number'
                ELSE NULL
            END AS phone_flag
        FROM step4
    ),
    step6 AS (
        -- Build formatted display variants for valid US numbers
        SELECT
            digits_only,
            e164,
            digit_len,
            phone_flag,
            CASE
                WHEN phone_flag IS NULL AND e164 RLIKE '^\\+1[0-9]{10}$'
                    THEN '(' || SUBSTR(e164, 3, 3) || ') '
                          || SUBSTR(e164, 6, 3) || '-'
                          || SUBSTR(e164, 9, 4)
                ELSE NULL
            END AS fmt_us_local,        -- (212) 555-1234

            CASE
                WHEN phone_flag IS NULL AND e164 RLIKE '^\\+1[0-9]{10}$'
                    THEN SUBSTR(e164, 3, 3) || '-'
                          || SUBSTR(e164, 6, 3) || '-'
                          || SUBSTR(e164, 9, 4)
                ELSE NULL
            END AS fmt_us_dashes,       -- 212-555-1234

            CASE
                WHEN phone_flag IS NULL AND e164 RLIKE '^\\+1[0-9]{10}$'
                    THEN SUBSTR(e164, 3, 3) || '.'
                          || SUBSTR(e164, 6, 3) || '.'
                          || SUBSTR(e164, 9, 4)
                ELSE NULL
            END AS fmt_us_dots,         -- 212.555.1234

            CASE
                WHEN phone_flag IS NULL AND e164 RLIKE '^\\+1[0-9]{10}$'
                    THEN '+1 (' || SUBSTR(e164, 3, 3) || ') '
                          || SUBSTR(e164, 6, 3) || '-'
                          || SUBSTR(e164, 9, 4)
                ELSE NULL
            END AS fmt_us_intl          -- +1 (212) 555-1234
        FROM step5
    )
    SELECT OBJECT_CONSTRUCT(
        'e164',          e164,
        'fmt_us_local',  fmt_us_local,
        'fmt_us_dashes', fmt_us_dashes,
        'fmt_us_dots',   fmt_us_dots,
        'fmt_us_intl',   fmt_us_intl,
        'digits_only',   digits_only,
        'digit_len',     digit_len,
        'phone_flag',    phone_flag
    )
    FROM step6
$$;
    --TEST
    --CREATE OR REPLACE TABLE phone_normalized AS
    WITH parsed AS (
        SELECT
            DIM_PATIENT_KEY,
            FIRST_NAME,
            LAST_NAME,
            HOME_NUMBER,
            normalize_phone(HOME_NUMBER) AS result
        FROM
            STAR.DIM_MODEL.DIM_PATIENT
    )
SELECT
    DIM_PATIENT_KEY,
    FIRST_NAME,
    LAST_NAME,
    HOME_NUMBER,
    result ['e164']::STRING AS phone_e164,
    result ['fmt_us_local']::STRING AS phone_fmt_local,
    result ['fmt_us_dashes']::STRING AS phone_fmt_dashes,
    result ['fmt_us_dots']::STRING AS phone_fmt_dots,
    result ['fmt_us_intl']::STRING AS phone_fmt_intl,
    result ['digits_only']::STRING AS phone_digits_only,
    result ['digit_len']::INT AS phone_digit_len,
    result ['phone_flag']::STRING AS phone_flag
FROM
    parsed;