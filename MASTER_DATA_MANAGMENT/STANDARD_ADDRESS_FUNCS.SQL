-- ============================================================
-- Reference: USPS street type abbreviations
-- ============================================================
CREATE
OR REPLACE TABLE usps_street_types (
    input_variant STRING,
    -- what people write
    usps_abbrev STRING -- official USPS abbreviation
);
INSERT INTO
    usps_street_types
VALUES
    -- Most common
    ('STREET', 'ST'),
    ('ST', 'ST'),
    ('AVENUE', 'AVE'),
    ('AVE', 'AVE'),
    ('AV', 'AVE'),
    ('BOULEVARD', 'BLVD'),
    ('BLVD', 'BLVD'),
    ('BOUL', 'BLVD'),
    ('DRIVE', 'DR'),
    ('DR', 'DR'),
    ('ROAD', 'RD'),
    ('RD', 'RD'),
    ('LANE', 'LN'),
    ('LN', 'LN'),
    ('COURT', 'CT'),
    ('CT', 'CT'),
    ('PLACE', 'PL'),
    ('PL', 'PL'),
    ('CIRCLE', 'CIR'),
    ('CIR', 'CIR'),
    ('TRAIL', 'TRL'),
    ('TRL', 'TRL'),
    ('TR', 'TRL'),
    ('WAY', 'WAY'),
    ('HIGHWAY', 'HWY'),
    ('HWY', 'HWY'),
    ('HIWAY', 'HWY'),
    ('FREEWAY', 'FWY'),
    ('FWY', 'FWY'),
    ('EXPRESSWAY', 'EXPY'),
    ('EXPY', 'EXPY'),
    ('PARKWAY', 'PKWY'),
    ('PKWY', 'PKWY'),
    ('PRKWY', 'PKWY'),
    ('TERRACE', 'TER'),
    ('TER', 'TER'),
    ('TERR', 'TER'),
    ('LOOP', 'LOOP'),
    ('PASS', 'PASS'),
    ('PATH', 'PATH'),
    ('PIKE', 'PIKE'),
    ('RUN', 'RUN'),
    ('SQUARE', 'SQ'),
    ('SQ', 'SQ'),
    ('CROSSING', 'XING'),
    ('XING', 'XING'),
    ('JUNCTION', 'JCT'),
    ('JCT', 'JCT'),
    ('ALLEY', 'ALY'),
    ('ALY', 'ALY'),
    ('ALLEE', 'ALY'),
    ('BRIDGE', 'BRG'),
    ('BRG', 'BRG'),
    ('BYPASS', 'BYP'),
    ('BYP', 'BYP'),
    ('CANYON', 'CYN'),
    ('CYN', 'CYN'),
    ('CENTER', 'CTR'),
    ('CTR', 'CTR'),
    ('CENTRE', 'CTR'),
    ('CREEK', 'CRK'),
    ('CRK', 'CRK'),
    ('CREST', 'CRST'),
    ('RIDGE', 'RDG'),
    ('RDG', 'RDG'),
    ('GROVE', 'GRV'),
    ('GRV', 'GRV'),
    ('HARBOR', 'HBR'),
    ('HBR', 'HBR'),
    ('ISLE', 'ISLE'),
    ('KNOLL', 'KNL'),
    ('KNL', 'KNL'),
    ('LANDING', 'LNDG'),
    ('LNDG', 'LNDG'),
    ('MANOR', 'MNR'),
    ('MNR', 'MNR'),
    ('MEADOWS', 'MDWS'),
    ('MDWS', 'MDWS'),
    ('MILLS', 'MLS'),
    ('MLS', 'MLS'),
    ('ORCHARD', 'ORCH'),
    ('ORCH', 'ORCH'),
    ('POINT', 'PT'),
    ('PT', 'PT'),
    ('PORT', 'PRT'),
    ('PRT', 'PRT'),
    ('PRAIRIE', 'PR'),
    ('PR', 'PR'),
    ('SHORE', 'SHR'),
    ('SHR', 'SHR'),
    ('SPRING', 'SPG'),
    ('SPG', 'SPG'),
    ('SUMMIT', 'SMT'),
    ('SMT', 'SMT'),
    ('TRACE', 'TRCE'),
    ('TRCE', 'TRCE'),
    ('TRACK', 'TRAK'),
    ('VALLEY', 'VLY'),
    ('VLY', 'VLY'),
    ('VIADUCT', 'VIA'),
    ('VIA', 'VIA'),
    ('VIEW', 'VW'),
    ('VW', 'VW'),
    ('VILLAGE', 'VLG'),
    ('VLG', 'VLG'),
    ('WALK', 'WALK'),
    ('WELL', 'WL'),
    ('WOODS', 'WDS');
    
-- ============================================================
-- Reference: unit type abbreviations
-- ============================================================
CREATE
    OR REPLACE TABLE usps_unit_types (input_variant STRING, usps_abbrev STRING);
INSERT INTO
    usps_unit_types
VALUES
    ('APARTMENT', 'APT'),
    ('APT', 'APT'),
    ('AP', 'APT'),
    ('SUITE', 'STE'),
    ('STE', 'STE'),
    ('SUIT', 'STE'),
    ('UNIT', 'UNIT'),
    ('FLOOR', 'FL'),
    ('FL', 'FL'),
    ('FLR', 'FL'),
    ('BUILDING', 'BLDG'),
    ('BLDG', 'BLDG'),
    ('BLD', 'BLDG'),
    ('ROOM', 'RM'),
    ('RM', 'RM'),
    ('DEPARTMENT', 'DEPT'),
    ('DEPT', 'DEPT'),
    ('SPACE', 'SPC'),
    ('SPC', 'SPC'),
    ('LOT', 'LOT'),
    ('PIER', 'PIER'),
    ('SLIP', 'SLIP'),
    ('STOP', 'STOP'),
    ('TRAILER', 'TRLR'),
    ('TRLR', 'TRLR'),
    ('HANGER', 'HNGR'),
    ('KEY', 'KEY'),
    ('OFFICE', 'OFC'),
    ('OFC', 'OFC'),
    ('#', 'APT');
    -- bare "#" treated as APT
    
-- ============================================================
-- Reference: directional prefixes and suffixes
-- ============================================================
CREATE
    OR REPLACE TABLE usps_directionals (input_variant STRING, usps_abbrev STRING);
INSERT INTO
    usps_directionals
VALUES
    ('NORTH', 'N'),
    ('N', 'N'),
    ('SOUTH', 'S'),
    ('S', 'S'),
    ('EAST', 'E'),
    ('E', 'E'),
    ('WEST', 'W'),
    ('W', 'W'),
    ('NORTHEAST', 'NE'),
    ('NE', 'NE'),
    ('NORTHWEST', 'NW'),
    ('NW', 'NW'),
    ('SOUTHEAST', 'SE'),
    ('SE', 'SE'),
    ('SOUTHWEST', 'SW'),
    ('SW', 'SW');
    
-- ============================================================
-- UDF: cleanse_street_address
-- Uppercases, trims, collapses whitespace, removes punctuation
-- except hyphens (for hyphenated house numbers like 12-14)
-- ============================================================
CREATE
OR REPLACE FUNCTION cleanse_street_address(RAW STRING) RETURNS STRING LANGUAGE SQL AS $$
TRIM(
    REGEXP_REPLACE(
        REGEXP_REPLACE(
            REGEXP_REPLACE(
                UPPER(raw),
                '[\\x00-\\x1F\\x7F]', ''    -- control chars
            ),
            '[^A-Z0-9\\s\\-\\/\\#\\.]', ''  -- keep alphanum, space, hyphen, slash, #, period
        ),
        '\\s+', ' '                          -- collapse whitespace
    )
)
$$;

-- ============================================================
-- UDF: normalize_street_number
-- Handles: "007 " → "7", "12-14" → "12-14" (range kept),
--          "1/2" fractional → kept, letters like "123B" → kept
-- ============================================================
CREATE
OR REPLACE FUNCTION normalize_street_number(num_raw STRING) RETURNS STRING LANGUAGE SQL AS $$
WITH cleaned AS (
    SELECT TRIM(num_raw) AS v
),
-- Remove leading zeros from numeric portion only
stripped AS (
    SELECT
        CASE
            -- Range like 12-14 or 12A-14B: normalize each side
            WHEN v RLIKE '^[0-9]+[A-Z]?-[0-9]+[A-Z]?$'
                THEN REGEXP_REPLACE(v, '^0+([1-9][0-9]*)', '\\1')
            -- Fraction like 1/2 or 123 1/2
            WHEN v RLIKE '^[0-9]+ [0-9]+/[0-9]+$'
                THEN REGEXP_REPLACE(v, '^0+([1-9])', '\\1')
            -- Plain number, possibly with letter suffix (123B)
            WHEN v RLIKE '^0*[0-9]+[A-Z]?$'
                THEN REGEXP_REPLACE(v, '^0+([0-9])', '\\1')
            ELSE v
        END AS v
    FROM cleaned
)
SELECT NULLIF(TRIM(v), '') FROM stripped
$$;

-- ============================================================
-- UDF: normalize_street_name
-- Handles: ordinals (1ST, 2ND, 3RD, 4TH), proper case,
--          common abbreviations (SAINT→ST, MOUNT→MT, etc.)
-- ============================================================
CREATE
OR REPLACE FUNCTION normalize_street_name(name_raw STRING) RETURNS STRING LANGUAGE SQL AS $$
WITH upped AS (
    SELECT TRIM(name_raw) AS v
),
-- Expand / contract common name tokens
substituted AS (
    SELECT
        REGEXP_REPLACE(
        REGEXP_REPLACE(
        REGEXP_REPLACE(
        REGEXP_REPLACE(
        REGEXP_REPLACE(
        REGEXP_REPLACE(
        REGEXP_REPLACE(
            v,
            '\\bSAINT\\b',  'ST'),
            '\\bSANT\\b',   'ST'),
            '\\bMOUNT\\b',  'MT'),
            '\\bFORT\\b',   'FT'),
            '\\bMTN\\b',    'MOUNTAIN'),
            -- Ordinal normalization: 1ST 2ND 3RD 4TH...
            '\\b([0-9]+)(ST|ND|RD|TH)\\b', '\\1\\2'),
            -- Remove periods from abbreviations (U.S. → US)
            '\\.', ''
        ) AS v
    FROM upped
),
-- Title-case (proper case) each word
words AS (
    SELECT SPLIT(v, ' ') AS arr FROM substituted
),
proper AS (
    SELECT
        ARRAY_TO_STRING(
            TRANSFORM(arr, w ->
                CASE
                    -- Keep ordinals uppercase: 1ST, 42ND, etc.
                    WHEN w RLIKE '^[0-9]+(ST|ND|RD|TH)$' THEN w
                    -- Keep pure uppercase abbreviations ≤ 3 chars as-is
                    WHEN LENGTH(w) <= 3 AND w RLIKE '^[A-Z]+$' THEN w
                    ELSE UPPER(LEFT(w, 1)) || LOWER(SUBSTR(w, 2))
                END
            ),
            ' '
        ) AS v
    FROM words
)
SELECT NULLIF(TRIM(v), '') FROM proper
$$;


-- COMBINED SOLUTION
-- ============================================================
-- Main: normalize_street_address
-- Input column: raw_street_address
-- Output: parsed fields + normalized_street_address + flags
-- ============================================================
    --CREATE OR REPLACE TABLE address_normalized AS
    WITH -- Step A: cleanse
    cleansed AS (
        SELECT
            DIM_PATIENT_KEY,
            FIRST_NAME,
            LAST_NAME,
            PATIENT_ADDRESS1,
            cleanse_street_address(PATIENT_ADDRESS1) AS PATIENT_ADDRESS1_cln
        FROM
            STAR.DIM_MODEL.DIM_PATIENT
    ),
    -- Step B: extract street number (leading token before first space)
    with_number AS (
        SELECT
            *,
            SPLIT_PART(PATIENT_ADDRESS1_cln, ' ', 1) AS tok_number_raw,
            SUBSTR(
                PATIENT_ADDRESS1_cln,
                LENGTH(SPLIT_PART(PATIENT_ADDRESS1_cln, ' ', 1)) + 2
            ) AS addr_remainder
        FROM
            cleansed
    ),
    -- Step C: detect and extract leading directional from remainder
    with_predir AS (
        SELECT
            w.*,
            COALESCE(d.usps_abbrev, NULL) AS pre_directional,
            CASE
                WHEN d.usps_abbrev IS NOT NULL THEN SUBSTR(
                    w.addr_remainder,
                    LENGTH(SPLIT_PART(w.addr_remainder, ' ', 1)) + 2
                )
                ELSE w.addr_remainder
            END AS addr_after_predir
        FROM
            with_number w
            LEFT JOIN usps_directionals d ON d.input_variant = SPLIT_PART(w.addr_remainder, ' ', 1)
    ),
    -- Step D: extract unit type + number from the tail
    -- Pattern: last two tokens where first matches a unit type
    with_unit AS (
        SELECT
            p.*,
            -- Check second-to-last word against unit type table
            SPLIT_PART(p.addr_after_predir, ' ', -2) AS tok_unit_type_raw,
            SPLIT_PART(p.addr_after_predir, ' ', -1) AS tok_unit_num_raw,
            ut.usps_abbrev AS unit_type_abbrev
        FROM
            with_predir p
            LEFT JOIN usps_unit_types ut ON ut.input_variant = SPLIT_PART(p.addr_after_predir, ' ', -2)
    ),
    -- Remainder after stripping unit = "pre_dir STREETNAME STREETTYPE [post_dir]"
    with_core AS (
        SELECT
            w.*,
            CASE
                WHEN w.unit_type_abbrev IS NOT NULL -- Strip last two tokens (unit type + unit number)
                THEN TRIM(
                    REGEXP_REPLACE(w.addr_after_predir, '\\s+\\S+\\s+\\S+$', '')
                )
                ELSE w.addr_after_predir
            END AS core_addr -- STREETNAME STREETTYPE [post_dir]
        FROM
            with_unit w
    ),
    -- Step E: detect and extract trailing post-directional
    with_postdir AS (
        SELECT
            c.*,
            COALESCE(d.usps_abbrev, NULL) AS post_directional,
            CASE
                WHEN d.usps_abbrev IS NOT NULL THEN TRIM(REGEXP_REPLACE(c.core_addr, '\\s+\\S+$', ''))
                ELSE c.core_addr
            END AS core_no_postdir
        FROM
            with_core c
            LEFT JOIN usps_directionals d ON d.input_variant = SPLIT_PART(c.core_addr, ' ', -1)
    ),
    -- Step F: extract street type (last token of what remains)
    with_streettype AS (
        SELECT
            p.*,
            SPLIT_PART(p.core_no_postdir, ' ', -1) AS tok_type_raw,
            st.usps_abbrev AS street_type_abbrev,
            CASE
                WHEN st.usps_abbrev IS NOT NULL THEN TRIM(
                    REGEXP_REPLACE(p.core_no_postdir, '\\s+\\S+$', '')
                )
                ELSE p.core_no_postdir
            END AS street_name_raw
        FROM
            with_postdir p
            LEFT JOIN usps_street_types st ON st.input_variant = SPLIT_PART(p.core_no_postdir, ' ', -1)
    ),
    -- Step G: apply normalizers to each component
    normalized AS (
        SELECT
            DIM_PATIENT_KEY,
            FIRST_NAME,
            LAST_NAME,
            PATIENT_ADDRESS1,
            -- Normalized components
            normalize_street_number(tok_number_raw) AS street_number,
            tok_number_raw AS test,
            pre_directional,
            normalize_street_name(street_name_raw) AS street_name,
            --COALESCE(street_type_abbrev, tok_type_raw)      AS street_type,
            street_type_abbrev AS street_type,
            post_directional,
            CONCAT_WS(
                ' ',
                unit_type_abbrev,
                NULLIF(TRIM(tok_unit_num_raw), '')
            ) AS unit,
            -- Flags
            CASE
                WHEN tok_number_raw IS NULL
                OR NOT RLIKE(tok_number_raw, '[0-9].*') THEN 'review:no_street_number'
                WHEN street_name_raw IS NULL
                OR LENGTH(TRIM(street_name_raw)) = 0 THEN 'review:no_street_name'
                WHEN street_type_abbrev IS NULL THEN 'review:unknown_street_type'
                ELSE NULL
            END AS address_flag
        FROM
            with_streettype
    ),
    -- Step H: assemble final normalized address string
    assembled AS (
        SELECT
            *,
            TRIM(
                CONCAT_WS(
                    ' ',
                    COALESCE(street_number, ''),
                    COALESCE(pre_directional, ''),
                    COALESCE(street_name, ''),
                    COALESCE(street_type, ''),
                    COALESCE(post_directional, ''),
                    COALESCE(unit, '')
                )
            ) AS normalized_street_address
        FROM
            normalized
    )
SELECT
    DIM_PATIENT_KEY,
    FIRST_NAME,
    LAST_NAME,
    PATIENT_ADDRESS1,
    street_number,
    test,
    pre_directional,
    street_name,
    street_type,
    post_directional,
    unit,
    normalized_street_address,
    address_flag
FROM
    assembled;