#!/bin/bash

# Reset the SECONDS variable to track execution time
SECONDS=0

export $(grep -v '^#' .env | xargs)

if [[ -z "$POSTGRES_HOST" || -z "$POSTGRES_USER" || -z "$POSTGRES_PASSWORD" || -z "$POSTGRES_PORT" || -z "$POSTGRES_DB" ]]; then
    echo "Error: One or more environment variables are not set."
    exit 1
fi

export PGPASSWORD=$POSTGRES_PASSWORD

LOG_FILE="output.log"
> $LOG_FILE

create_views() {
    echo "Creating views from SQL commands..." | tee -a $LOG_FILE

    # Create view for the first query
    psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -c "
    CREATE OR REPLACE VIEW demo.view_select_code_1 AS
    SELECT
        col_s_1,
        SUM(
            CASE WHEN col_s_c_d_i='D' THEN col_s_t_u_a
                 WHEN col_s_c_d_i='C' THEN -1 * col_s_t_u_a
                 ELSE 0 END
        ) AS col_s_c,
        SUM(CASE WHEN col_s_c_d_i='D' THEN col_s_t_u_a ELSE 0 END) AS col_d_c,
        SUM(CASE WHEN col_s_c_d_i='C' THEN col_s_t_u_a ELSE 0 END) AS col_c_cv,
        SUM(CASE WHEN col_s_c_d_i='D' THEN 1 ELSE 0 END) AS col_s_r,
        SUM(CASE WHEN col_s_c_d_i='C' THEN 1 ELSE 0 END) AS col_c_r
    FROM (
        SELECT a.col_s_1,
               CASE WHEN col_s_c_d_i ='d' THEN col_s_t_d ELSE NULL END as col_s_t_d,
               CEILING(EXTRACT(MONTH FROM AGE(CAST('2022-11-01' AS DATE), CAST(b.col_s_t_d AS DATE)))) as col_t_m,
               b.col_s_c_d_i, b.col_s_t_u_a
        FROM demo.tab_oab AS a
        INNER JOIN demo.tab_c_gt b ON a.col_s_1 = CAST(b.col_s_s_1 AS INT8)
        AND a.col_m_p_i = 'PROP'
        AND b.col_s_t_d >= (CAST('2022-11-01' AS DATE) - INTERVAL '24 months')
        AND b.col_s_t_d < CAST('2022-11-01' AS DATE)
    ) as c
    GROUP BY col_s_1, col_t_m;" | tee -a $LOG_FILE

    psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -c "
    CREATE OR REPLACE VIEW demo.view_select_code_2 AS
    SELECT
        col_s_1, col_t_m, MAX(col_s_t_d) as col_m_t_d,
        SUM(
            CASE WHEN col_s_c_d_i='D' THEN col_s_t_u_a
                 WHEN col_s_c_d_i='C' THEN -1 * col_s_t_u_a
                 ELSE 0 END
        ) AS col_s_c,
        SUM(CASE WHEN col_s_c_d_i='D' THEN col_s_t_u_a ELSE 0 END) AS col_d_c,
        SUM(CASE WHEN col_s_c_d_i='C' THEN col_s_t_u_a ELSE 0 END) AS col_c_cv,
        SUM(CASE WHEN col_s_c_d_i='D' THEN 1 ELSE 0 END) AS col_s_r,
        SUM(CASE WHEN col_s_c_d_i='C' THEN 1 ELSE 0 END) AS col_c_r
    FROM (
        SELECT a.col_s_1,
               CASE WHEN col_s_c_d_i ='D' THEN col_s_t_d ELSE NULL END as col_s_t_d,
               CEILING(EXTRACT(MONTH FROM AGE(CAST('2022-11-01' AS DATE), CAST(b.col_s_t_d AS DATE)))) as col_t_m,
               b.col_s_c_d_i, b.col_s_t_u_a
        FROM demo.tab_oab AS a
        INNER JOIN demo.tab_c_gt b ON a.col_s_1 = b.col_s_s_1
        AND TRIM(CAST(b.col_se_s_1 AS TEXT)) <> TRIM(CAST(b.col_s_s_1 AS TEXT))
        AND a.col_m_p_i NOT IN ('PROP')
        AND b.col_s_t_d >= (CAST('2022-11-01' AS DATE) - INTERVAL '24 months')
        AND b.col_s_t_d < CAST('2022-11-01' AS DATE)
    ) AS c
    GROUP BY col_s_1, col_t_m;" | tee -a $LOG_FILE

    psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -c "
    CREATE OR REPLACE VIEW demo.view_select_code_4 AS
    SELECT
        a.col_o_i,
        SUM(
            CASE
                WHEN b.col_s_c_d_i = 'D' THEN b.col_s_t_u_a
                WHEN b.col_s_c_d_i = 'C' THEN -1 * b.col_s_t_u_a
                ELSE 0
            END
        ) AS col_s_c_c
    FROM demo.tab_sbfa AS a
    INNER JOIN demo.tab_c_gt AS b ON a.col_s_1::numeric = b.col_s_s_1::numeric
    WHERE a.col_m_p_i = 'PROP'
    AND b.col_s_t_d >= (CAST('2022-11-01' AS DATE) - INTERVAL '12 months')
    AND b.col_s_t_d < CAST('2022-11-01' AS DATE)
    GROUP BY a.col_o_i;" | tee -a $LOG_FILE

    psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -c "
    CREATE OR REPLACE VIEW demo.view_select_code_5 AS
    SELECT
        a.col_o_i,
        SUM(
            CASE
                WHEN b.col_s_c_d_i='D' THEN b.col_s_t_u_a
                WHEN b.col_s_c_d_i='C' THEN -1 * b.col_s_t_u_a
                ELSE 0
            END) as col_s_c_c
    FROM demo.tab_sbfa as a
    INNER JOIN demo.tab_c_gt AS b ON a.col_s_1 = b.col_s_s_1
    AND TRIM(CAST(b.col_se_s_1 AS TEXT)) <> TRIM(CAST(b.col_s_s_1 AS TEXT))
    WHERE a.col_m_p_i NOT IN ('PROP')
    AND b.col_s_t_d >= CAST('2022-11-01' AS DATE) - INTERVAL '12 months'
    AND b.col_s_t_d < CAST('2022-11-01' AS DATE)
    GROUP BY a.col_o_i;" | tee -a $LOG_FILE

    psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -c "
    CREATE OR REPLACE VIEW demo.view_select_code_7 AS
    SELECT
        a.col_s_1,
        a.col_o_i,
        b.col_s_t_d,
        SUM(
            CASE
                WHEN b.col_s_c_d_i='D' THEN b.col_s_t_u_a
                WHEN b.col_s_c_d_i='C' THEN -1 * b.col_s_t_u_a
                ELSE 0
            END
        ) AS col_s_c,
        SUM(
            CASE
                WHEN b.col_s_c_d_i='D' THEN 1
                ELSE 0
            END
        ) AS col_s_r
    FROM demo.tab_sbfa AS a
    INNER JOIN demo.tab_c_gt AS b ON a.col_s_1 = b.col_s_s_1
    WHERE a.col_m_p_i NOT IN ('PROP')
    AND b.col_s_t_d >= CAST('2022-11-01' AS DATE) - INTERVAL '12 months'
    AND b.col_s_t_d < CAST('2022-11-01' AS DATE)
    GROUP BY a.col_s_1, a.col_o_i, b.col_s_t_d
    HAVING SUM(
        CASE
            WHEN b.col_s_c_d_i='D' THEN b.col_s_t_u_a
            WHEN b.col_s_c_d_i='C' THEN -1 * b.col_s_t_u_a
            ELSE 0
        END
    ) > 10
    AND SUM(
        CASE
            WHEN b.col_s_c_d_i='D' THEN 1
            ELSE 0
        END
    ) > 0;" | tee -a $LOG_FILE

    # Create view for the sixth query
    psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT -c "
    CREATE OR REPLACE VIEW demo.view_select_code_8 AS
    SELECT
        a.col_s_1,
        a.col_o_i,
        b.col_s_t_d,
        SUM(
            CASE
                WHEN b.col_s_c_d_i = 'D' THEN b.col_s_t_u_a
                WHEN b.col_s_c_d_i = 'C' THEN -1 * b.col_s_t_u_a
                ELSE 0
            END) AS col_s_c,
        SUM(
            CASE
                WHEN b.col_s_c_d_i = 'D' THEN 1
                ELSE 0
            END) AS col_s_r
    FROM demo.tab_sbfa as a
    INNER JOIN demo.tab_c_gt b ON a.col_s_1::numeric = b.col_s_s_1::numeric
    AND TRIM(CAST(b.col_se_s_1 AS TEXT)) <> TRIM(CAST(b.col_s_s_1 AS TEXT))
    AND a.col_m_p_i NOT IN ('PROP')
    AND b.col_s_t_d >= CAST('2022-11-01' AS DATE) - INTERVAL '12 months'
    AND b.col_s_t_d < CAST('2022-11-01' AS DATE)
    GROUP BY a.col_s_1, a.col_o_i, b.col_s_t_d
    HAVING SUM(
        CASE
            WHEN b.col_s_c_d_i = 'D' THEN b.col_s_t_u_a
            WHEN b.col_s_c_d_i = 'C' THEN -1 * b.col_s_t_u_a
            ELSE 0
        END) > 10
    AND SUM(
        CASE
            WHEN b.col_s_c_d_i = 'D' THEN 1
            ELSE 0
        END) > 0;" | tee -a $LOG_FILE
}

{
    create_views
} 2>&1 | tee -a $LOG_FILE

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "Views created successfully. Check output.log for details." | tee -a $LOG_FILE
else
    echo "Error creating views. Check output.log for details." | tee -a $LOG_FILE
    exit 1
fi

# Print total execution time
echo "Total execution time: $SECONDS seconds" | tee -a $LOG_FILE