-- Business Need: Identifying Underperforming Agents. Identify agents with an AHT higher than the team average and a CSAT score below the company average.
WITH CTE_team_aht AS (
    SELECT
        a.agent_id,
        AVG(TIMESTAMPDIFF(SECOND, c.start_time, c.end_time) + c.hold_time + c.after_work_call_time) AS agent_aht
    FROM calls c 
    INNER JOIN agents a ON c.agent_id = a.agent_id 
    GROUP BY a.agent_id
),
CTE_company_csat AS (
    SELECT
        AVG(satisfaction_score) AS company_avg_csat 
    FROM calls
)
SELECT 
    a.agent_name,
    t.team_name,
    ta.agent_aht,
    AVG(c.satisfaction_score) AS agent_csat
FROM 
    calls c 
INNER JOIN agents a ON c.agent_id = a.agent_id
INNER JOIN teams t ON a.team_id = t.team_id 
INNER JOIN CTE_team_aht ta ON a.agent_id = ta.agent_id 
CROSS JOIN CTE_company_csat csat
GROUP BY a.agent_name, t.team_name, ta.agent_aht
HAVING ta.agent_aht > (SELECT AVG(agent_aht) FROM CTE_team_aht)
    AND AVG(c.satisfaction_score) < (SELECT AVG(satisfaction_score) FROM calls);

-- With this query you discover agent 56 is underperforming. Write a SQL query to monitor agent 56 aht time and csat scores weekly.
SELECT 
    YEAR(call_date) AS year,
    WEEK(call_date) AS week, 
    AVG(TIMESTAMPDIFF(SECOND, start_time, end_time) + hold_time + after_work_call_time) AS avg_aht,
    AVG(satisfaction_score) AS avg_csat 
FROM calls 
WHERE agent_id = 56
GROUP BY YEAR(call_date), WEEK(call_date)
ORDER BY year DESC, week DESC;