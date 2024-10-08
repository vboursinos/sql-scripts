SELECT
  col_s_1, col_t_m, MAX(col_s_t_d) as col_m_t_d,
   SUM(
   CASE WHEN col_s_c_d_i='D' THEN col_s_t_u_a
   WHEN col_s_c_d_i='C' THEN -1*col_s_t_u_a
   ELSE 0 END
      ) AS col_s_c,
   SUM(CASE WHEN col_s_c_d_i='D' THEN col_s_t_u_a ELSE 0 END) AS col_d_c,
   SUM(CASE WHEN col_s_c_d_i='C' THEN col_s_t_u_a ELSE 0 END) AS col_c_cv,
   SUM(CASE WHEN col_s_c_d_i='D' THEN 1 ELSE 0 END) AS col_s_r,
   SUM(CASE WHEN col_s_c_d_i='C' THEN 1 ELSE 0 END) AS col_c_r
   FROM
   (
    SELECT a.col_s_1,
    CASE WHEN col_s_c_d_i ='D' THEN col_s_t_d ELSE NULL END as col_s_t_d,
    CEILING(EXTRACT(MONTH FROM AGE(CAST('2022-11-01' AS DATE), CAST(b.col_s_t_d AS DATE)))) as col_t_m,
    b.col_s_c_d_i, b.col_s_t_u_a
    FROM demo.tab_oab AS a
    INNER JOIN demo.tab_c_gt b
    ON a.col_s_1 = b.col_s_s_1
    AND TRIM(CAST(b.col_se_s_1 AS TEXT)) <> TRIM(CAST(b.col_s_s_1 AS TEXT))
    AND a.col_m_p_i NOT IN ('PROP')
    AND b.col_s_t_d >= (CAST('2022-11-01' AS DATE) - INTERVAL '24 months')
    AND b.col_s_t_d < CAST('2022-11-01' AS DATE)
) AS c
GROUP BY col_s_1, col_t_m;
