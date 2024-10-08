SELECT 
	a.col_o_i,
	SUM(
	    CASE
			WHEN b.col_s_c_d_i='D'
			THEN b.col_s_t_u_a
			WHEN b.col_s_c_d_i='C'
			THEN -1 * b.col_s_t_u_a
			ELSE 0
		END) as col_s_c_c
FROM
    demo.tab_sbfa as a
INNER JOIN
	demo.tab_c_gt AS b
	ON a.col_s_1 = b.col_s_s_1
	AND TRIM(CAST(b.col_se_s_1 AS TEXT)) <> TRIM(CAST(b.col_s_s_1 AS TEXT))
WHERE
	a.col_m_p_i NOT IN ('PROP')
AND b.col_s_t_d >= CAST('2022-11-01' AS DATE) - INTERVAL '12 months'
AND b.col_s_t_d < CAST('2022-11-01' AS DATE)
GROUP BY
	a.col_o_i;
