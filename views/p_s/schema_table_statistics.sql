/* 
 * View: schema_table_statistics
 *
 * Mimic TABLE_STATISTICS from Google et al ordered by the total wait time descending
 * 
 * mysql> select * from schema_table_statistics limit 1\G
 * *************************** 1. row ***************************
 *                  table_schema: mem
 *                    table_name: mysqlserver
 *                  rows_fetched: 27087
 *                 fetch_latency: 442.72 ms
 *                 rows_inserted: 2
 *                insert_latency: 185.04 µs 
 *                  rows_updated: 5096
 *                update_latency: 1.39 s
 *                  rows_deleted: 0
 *                delete_latency: 0 ps
 *              io_read_requests: 2565
 *                 io_read_bytes: 1121627
 *               io_read_latency: 10.07 ms
 *             io_write_requests: 1691
 *                io_write_bytes: 128383
 *              io_write_latency: 14.17 ms
 *              io_misc_requests: 2698
 *               io_misc_latency: 433.66 ms
 * 
 * (Example from 5.6.6)
 *
 * Versions: 5.6.2+
 *
 */ 
 
DROP VIEW IF EXISTS schema_table_statistics;

CREATE SQL SECURITY INVOKER VIEW schema_table_statistics AS 
SELECT pst.object_schema AS table_schema,
       pst.object_name AS table_name,
       pst.count_fetch AS rows_fetched,
       ps_helper.format_time(pst.sum_timer_fetch) AS fetch_latency,
       pst.count_insert AS rows_inserted,
       ps_helper.format_time(pst.sum_timer_insert) AS insert_latency,
       pst.count_update AS rows_updated,
       ps_helper.format_time(pst.sum_timer_update) AS update_latency,
       pst.count_delete AS rows_deleted,
       ps_helper.format_time(pst.sum_timer_delete) AS delete_latency,
       SUM(fsbi.count_read) AS io_read_requests,
       ps_helper.format_bytes(SUM(fsbi.sum_number_of_bytes_read)) AS io_read,
       ps_helper.format_time(SUM(fsbi.sum_timer_read)) AS io_read_latency,
       SUM(fsbi.count_write) AS io_write_requests,
       ps_helper.format_bytes(SUM(fsbi.sum_number_of_bytes_write)) AS io_write,
       ps_helper.format_time(SUM(fsbi.sum_timer_write)) AS io_write_latency,
       SUM(fsbi.count_misc) AS io_misc_requests,
       ps_helper.format_time(SUM(fsbi.sum_timer_misc)) AS io_misc_latency
  FROM performance_schema.table_io_waits_summary_by_table AS pst
  LEFT JOIN performance_schema.file_summary_by_instance AS fsbi
    ON pst.object_schema = extract_schema_from_file_name(fsbi.file_name)
   AND pst.object_name = extract_table_from_file_name(fsbi.file_name)
 GROUP BY pst.object_schema, pst.object_name
 ORDER BY pst.sum_timer_wait DESC;

/* 
 * View: schema_table_statistics_raw
 *
 * Mimic TABLE_STATISTICS from Google et al ordered by the total wait time descending
 * 
 * mysql> SELECT * FROM schema_table_statistics_raw LIMIT 1\G
 * *************************** 1. row ***************************
 *      table_schema: common_schema
 *        table_name: help_content
 *      rows_fetched: 0
 *     fetch_latency: 0
 *     rows_inserted: 169
 *    insert_latency: 409815527680
 *      rows_updated: 0
 *    update_latency: 0
 *      rows_deleted: 0
 *    delete_latency: 0
 *  io_read_requests: 14
 *           io_read: 1180
 *   io_read_latency: 52406770
 * io_write_requests: 131
 *          io_write: 11719246
 *  io_write_latency: 133726902790
 *  io_misc_requests: 61
 *   io_misc_latency: 209081089750
 * 1 row in set (1.24 sec)
 * 
 * (Example from 5.6.6)
 *
 * Versions: 5.6.2+
 *
 */ 
 
DROP VIEW IF EXISTS schema_table_statistics_raw;

CREATE SQL SECURITY INVOKER VIEW schema_table_statistics_raw AS 
SELECT pst.object_schema AS table_schema,
       pst.object_name AS table_name,
       pst.count_fetch AS rows_fetched,
       pst.sum_timer_fetch AS fetch_latency,
       pst.count_insert AS rows_inserted,
       pst.sum_timer_insert AS insert_latency,
       pst.count_update AS rows_updated,
       pst.sum_timer_update AS update_latency,
       pst.count_delete AS rows_deleted,
       pst.sum_timer_delete AS delete_latency,
       SUM(fsbi.count_read) AS io_read_requests,
       SUM(fsbi.sum_number_of_bytes_read) AS io_read,
       SUM(fsbi.sum_timer_read) AS io_read_latency,
       SUM(fsbi.count_write) AS io_write_requests,
       SUM(fsbi.sum_number_of_bytes_write) AS io_write,
       SUM(fsbi.sum_timer_write) AS io_write_latency,
       SUM(fsbi.count_misc) AS io_misc_requests,
       SUM(fsbi.sum_timer_misc) AS io_misc_latency
  FROM performance_schema.table_io_waits_summary_by_table AS pst
  LEFT JOIN performance_schema.file_summary_by_instance AS fsbi
    ON pst.object_schema = extract_schema_from_file_name(fsbi.file_name)
   AND pst.object_name = extract_table_from_file_name(fsbi.file_name)
 GROUP BY pst.object_schema, pst.object_name
 ORDER BY pst.sum_timer_wait DESC;