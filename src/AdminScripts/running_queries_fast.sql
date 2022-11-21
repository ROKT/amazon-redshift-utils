/**********************************************************************************************
user :			User name
pid :			Pid of the session
xid :			Transaction identity
query :			Query Id
q :				Queue
slt :			Slots Uses
start :			Time query was issued
state :			Current State
q_sec :			Seconds in queue
exe_sec :		Seconds Executed
cpu_sec :		CPU seconds consumed
read_mb :		MB read by the query
spill_mb :		MB spilled to disk
ret_rows :		Rows returned to Leader -> Client
nl_rows :		# of rows of Nested Loop Join
**********************************************************************************************/
SELECT
    "user",
    pid,
    xid,
    query,
    service_class,
    slot_count,
    start,
    state,
    queue_seconds,
    exec_seconds,
    text
FROM
    (SELECT
         TRIM(u.usename)                        AS "user",
         s.pid,
         q.xid,
         q.query,
         q.service_class,
         q.slot_count,
         DATE_TRUNC('second', q.wlm_start_time) AS start,
         DECODE(TRIM(q.state), 'Running', 'Run', 'QueuedWaiting', 'Queue', 'Returning', 'Return',
                TRIM(q.state))                  AS state,
         q.queue_Time / 1000000                 AS queue_seconds,
         q.exec_time / 1000000                  AS exec_seconds,
         s.text
     FROM
         stv_wlm_query_state q
         JOIN stl_querytext s
              ON (s.query = q.query AND sequence = 0)
         JOIN pg_user u
              ON (s.userid = u.usesysid)) AS qsu
ORDER BY
    service_class, exec_seconds DESC, start;

