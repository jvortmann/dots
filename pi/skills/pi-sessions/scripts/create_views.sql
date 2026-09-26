-- Create convenience views for Pi session inspection and analytics.
--
-- Usage:
--   PI_SESSIONS_GLOB='<sessions>/--project--/*.jsonl' \
--     duckdb -bail pi_sessions.duckdb < scripts/create_views.sql
--
-- The data is newline-delimited JSONL under $PI_CODING_AGENT_DIR/sessions/**,
-- or ~/.pi/agent/sessions/** when that variable is unset. PI_SESSIONS_GLOB
-- names the files to read, such as the sessions of one project.

-- A scan of the whole history once took every core and spilled GBs to disk.
-- So the views read only PI_SESSIONS_GLOB, and refuse to build without it.
SET threads = 4;
SET memory_limit = '4GB';
SELECT error('Set PI_SESSIONS_GLOB to the sessions of one project first')
WHERE nullif(getenv('PI_SESSIONS_GLOB'), '') IS NULL;

CREATE OR REPLACE VIEW pi_events AS
SELECT
  *,
  -- UUID at the end of the file name (matches how Pi names session files)
  regexp_extract(filename, '([0-9a-f\-]{36})\.jsonl$', 1) AS session_id,
  -- Folder name under sessions/, e.g. "--Users-alice-Code-myproj--"
  regexp_extract(filename, '/sessions/([^/]+)/', 1) AS session_group
FROM read_json_auto(
  coalesce(nullif(getenv('PI_SESSIONS_GLOB'), ''), '/nonexistent/pi-sessions-glob-unset/*.jsonl'),
  format='newline_delimited',
  filename=true,
  ignore_errors=true
);

-- Only the message events.
CREATE OR REPLACE VIEW pi_messages AS
SELECT
  session_id,
  session_group,
  filename,
  id AS event_id,
  timestamp AS event_timestamp,
  message.role AS role,
  message.timestamp AS message_timestamp,
  message.content AS content
FROM pi_events
WHERE type = 'message';

-- User and assistant conversational text, excluding other content shapes by projection.
CREATE OR REPLACE VIEW pi_conversation AS
SELECT
  session_id,
  session_group,
  filename,
  event_id,
  event_timestamp,
  role,
  string_agg(item->>'text', chr(10) ORDER BY ordinality) AS text
FROM pi_messages,
  UNNEST(CAST(CASE WHEN json_type(content) = 'ARRAY' THEN content ELSE '[]' END AS JSON[])) WITH ORDINALITY AS u(item, ordinality)
WHERE
  role IN ('user', 'assistant')
  AND (item->>'type') = 'text'
GROUP BY
  session_id,
  session_group,
  filename,
  event_id,
  event_timestamp,
  role;

-- Tool calls are embedded in assistant message content[] entries.
CREATE OR REPLACE VIEW pi_tool_calls AS
SELECT
  session_id,
  session_group,
  filename,
  timestamp AS event_timestamp,
  (item->>'id') AS tool_call_id,
  (item->>'name') AS tool_name,
  (item->'arguments') AS tool_arguments
FROM pi_events,
  UNNEST(CAST(CASE WHEN json_type(message.content) = 'ARRAY' THEN message.content ELSE '[]' END AS JSON[])) AS u(item)
WHERE
  type = 'message'
  AND message.role = 'assistant'
  AND (item->>'type') = 'toolCall';
