select
    u.usename,
    q.*,
    nvl(qrytext_cur.text, trim(q.querytxt))                   as qrytext,
    md5(nvl(qrytext_cur.text, trim(q.querytxt)))              as qry_md5,
    datediff(seconds, q.starttime, q.endtime)::numeric(12, 2) as run_seconds,
    qs.service_Class,
    qs.query_cpu_time                                         as cpu,
    qs.query_cpu_usage_percent                                as cpupct,
    qs.query_temp_blocks_to_disk                              as spill,
    qs.query_blocks_read                                      as mb_read,
    qs.return_row_count                                       as rows_ret
from
    stl_query q
    left outer join pg_user u
                    on (q.userid = u.usesysid)
    left outer Join svl_Query_metrics_summary qs
                    on (q.userid = qs.userid and q.query = qs.query)
    LEFT OUTER JOIN (SELECT
                         ut.xid,
                         'CURSOR ' ||
                         TRIM(substring(TEXT from strpos(upper(TEXT), 'SELECT'))) as TEXT
                     FROM
                         stl_utilitytext ut
                     WHERE
                         sequence = 0 AND
                         upper(TEXT) like 'DECLARE%'
                     GROUP BY text, ut.xid) qrytext_cur
                    ON (q.xid = qrytext_cur.xid)
where
    qry_md5 = '0e9b14ec469e0b6f2d03d111475ce403'