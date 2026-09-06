/*
 Navicat Premium Data Transfer

 Source Server         : localhost
 Source Server Type    : MySQL
 Source Server Version : 50738 (5.7.38-log)
 Source Host           : 127.0.0.1:3306
 Source Schema         : ai_fusion_video

 Target Server Type    : MySQL
 Target Server Version : 50738 (5.7.38-log)
 File Encoding         : 65001

 Date: 06/09/2026 12:14:45
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for afv_agent_conversation
-- ----------------------------
DROP TABLE IF EXISTS `afv_agent_conversation`;
CREATE TABLE `afv_agent_conversation`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `conversation_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '瀵硅瘽鍞竴鏍囪瘑锛圲UID锛?,
  `user_id` bigint(20) NULL DEFAULT NULL COMMENT '鎵€灞炵敤鎴稩D',
  `project_id` bigint(20) NULL DEFAULT NULL COMMENT '鍏宠仈椤圭洰ID',
  `context_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '涓婁笅鏂囩被鍨嬶紙project/script/storyboard锛?,
  `agent_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Agent绫诲瀷锛坰cript_parser/storyboard_creator锛?,
  `category` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '瀵硅瘽鍒嗙被鏍囩',
  `context_id` bigint(20) NULL DEFAULT NULL COMMENT '涓婁笅鏂囧璞D',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '鏂板璇? COMMENT '瀵硅瘽鏍囬',
  `message_count` int(11) NULL DEFAULT 0 COMMENT '娑堟伅鎬绘暟',
  `last_message_time` datetime NULL DEFAULT NULL COMMENT '鏈€鍚庢秷鎭椂闂?,
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '瀵硅瘽鐘舵€侊細active/closed',
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `next_message_order` bigint(20) NOT NULL DEFAULT 1,
  `agent_state_last_active_at` datetime(3) NULL DEFAULT NULL,
  `agent_state_expired_at` datetime(3) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `conversation_id`(`conversation_id`) USING BTREE,
  INDEX `idx_conv_project_context`(`project_id`, `context_type`, `context_id`) USING BTREE,
  INDEX `idx_conv_user`(`user_id`) USING BTREE,
  INDEX `idx_agent_conversation_state_retention`(`agent_state_expired_at`, `agent_state_last_active_at`, `id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_spanish2_ci COMMENT = 'Agent瀵硅瘽绱㈠紩琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_agent_conversation
-- ----------------------------

-- ----------------------------
-- Table structure for afv_agent_event
-- ----------------------------
DROP TABLE IF EXISTS `afv_agent_event`;
CREATE TABLE `afv_agent_event`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `run_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `sequence_no` bigint(20) NOT NULL,
  `schema_version` int(11) NOT NULL DEFAULT 1,
  `raw_event_id` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `raw_event_type` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `source` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `reply_id` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `block_id` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `tool_call_id` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `parent_tool_call_id` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `agent_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `output_type` varchar(32) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `payload_json` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_created_at` datetime(3) NULL DEFAULT NULL,
  `redis_published_at` datetime(3) NULL DEFAULT NULL,
  `publish_required` tinyint(4) NOT NULL,
  `publish_status` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `publish_claim_owner` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `publish_claim_until` datetime(3) NULL DEFAULT NULL,
  `next_publish_attempt_at` datetime(3) NULL DEFAULT NULL,
  `last_publish_error` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `publish_attempts` int(11) NOT NULL DEFAULT 0,
  `create_time` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_agent_event_sequence`(`run_id`, `sequence_no`) USING BTREE,
  INDEX `idx_agent_event_projection`(`run_id`, `output_type`, `sequence_no`) USING BTREE,
  INDEX `idx_agent_event_publish`(`publish_status`, `next_publish_attempt_at`, `id`) USING BTREE,
  INDEX `idx_agent_event_raw`(`run_id`, `raw_event_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AgentScope V2 committed event journal' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_agent_event
-- ----------------------------

-- ----------------------------
-- Table structure for afv_agent_mcp_server
-- ----------------------------
DROP TABLE IF EXISTS `afv_agent_mcp_server`;
CREATE TABLE `afv_agent_mcp_server`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭',
  `user_id` bigint(20) NOT NULL COMMENT '鎵€灞炵敤鎴?,
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鏈嶅姟鍚嶇О',
  `transport` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'http/sse',
  `url` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'MCP 鍦板潃',
  `headers_json` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '璇锋眰澶?JSON',
  `query_params_json` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '鏌ヨ鍙傛暟 JSON',
  `enabled_tools_json` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '鍚敤宸ュ叿 JSON',
  `protocol_versions_json` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '鍗忚鐗堟湰 JSON',
  `timeout_seconds` int(11) NOT NULL DEFAULT 120,
  `initialization_timeout_seconds` int(11) NOT NULL DEFAULT 30,
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '0 绂佺敤 1 鍚敤',
  `last_test_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `last_test_message` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_agent_mcp_user_status`(`user_id`, `status`, `id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鐢ㄦ埛鑷畾涔?MCP 鏈嶅姟' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_agent_mcp_server
-- ----------------------------

-- ----------------------------
-- Table structure for afv_agent_message
-- ----------------------------
DROP TABLE IF EXISTS `afv_agent_message`;
CREATE TABLE `afv_agent_message`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `conversation_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鎵€灞炲璇滻D锛圲UID锛?,
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '娑堟伅瑙掕壊锛歶ser/assistant/system/tool',
  `content` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '娑堟伅鏂囨湰鍐呭',
  `references_json` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '寮曠敤璧勬簮JSON',
  `tool_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '宸ュ叿璋冪敤鍚嶇О锛坮ole=tool鏃讹級',
  `tool_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '宸ュ叿鎵ц鐘舵€侊細running/success/error',
  `tool_call_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '宸ュ叿璋冪敤ID锛堝叧鑱斿悓涓€娆¤皟鐢ㄧ殑鍙戣捣鍜岀粨鏋滐級',
  `parent_tool_call_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鐖剁骇宸ュ叿璋冪敤ID锛堝瓙Agent浜嬩欢褰掑睘鍒扮埗宸ュ叿璋冪敤锛?,
  `reasoning_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'AI鎺ㄧ悊杩囩▼鍐呭锛堟€濈淮閾撅級',
  `reasoning_duration_ms` bigint(20) NULL DEFAULT NULL COMMENT 'AI鎺ㄧ悊鑰楁椂锛堟绉掞級',
  `message_order` bigint(20) NOT NULL,
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `run_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `projection_key` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_agent_message_conv_order`(`conversation_id`, `message_order`) USING BTREE,
  UNIQUE INDEX `uk_agent_message_projection_key`(`projection_key`) USING BTREE,
  INDEX `idx_msg_conversation`(`conversation_id`) USING BTREE,
  INDEX `idx_agent_message_conv_run_order`(`conversation_id`, `run_id`, `message_order`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Agent娑堟伅琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_agent_message
-- ----------------------------

-- ----------------------------
-- Table structure for afv_agent_model_call_usage
-- ----------------------------
DROP TABLE IF EXISTS `afv_agent_model_call_usage`;
CREATE TABLE `afv_agent_model_call_usage`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `run_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `model_call_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `provider` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `model_code` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `status` varchar(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `input_tokens` bigint(20) NULL DEFAULT NULL,
  `output_tokens` bigint(20) NULL DEFAULT NULL,
  `reasoning_tokens` bigint(20) NULL DEFAULT NULL,
  `cache_tokens` bigint(20) NULL DEFAULT NULL,
  `usage_json` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `settlement_status` varchar(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `settlement_attempts` int(11) NOT NULL DEFAULT 0,
  `next_settlement_attempt_at` datetime(3) NULL DEFAULT NULL,
  `settlement_claim_owner` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `settlement_claim_until` datetime(3) NULL DEFAULT NULL,
  `downstream_settlement_id` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `last_settlement_error` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `started_at` datetime(3) NOT NULL,
  `finished_at` datetime(3) NULL DEFAULT NULL,
  `create_time` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `update_time` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_agent_usage_call`(`run_id`, `model_call_id`) USING BTREE,
  INDEX `idx_agent_usage_settlement`(`settlement_status`, `next_settlement_attempt_at`, `id`) USING BTREE,
  INDEX `idx_agent_usage_run_status`(`run_id`, `status`, `id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AgentScope V2 model-call usage ledger' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_agent_model_call_usage
-- ----------------------------

-- ----------------------------
-- Table structure for afv_agent_run
-- ----------------------------
DROP TABLE IF EXISTS `afv_agent_run`;
CREATE TABLE `afv_agent_run`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `run_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `conversation_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `project_id` bigint(20) NULL DEFAULT NULL,
  `agent_type` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `parent_run_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `parent_tool_call_id` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `agent_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `kernel_fingerprint` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `agent_definition_snapshot_json` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `agent_state_session_id` varchar(255) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `status` varchar(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `owner_instance_id` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `owner_epoch` bigint(20) NOT NULL DEFAULT 0,
  `lease_until` datetime(3) NULL DEFAULT NULL,
  `next_sequence` bigint(20) NOT NULL DEFAULT 1,
  `terminal_sequence` bigint(20) NULL DEFAULT NULL,
  `terminal_output_type` varchar(32) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `cancel_requested_at` datetime(3) NULL DEFAULT NULL,
  `cancel_broadcast_at` datetime(3) NULL DEFAULT NULL,
  `cancel_acknowledged_at` datetime(3) NULL DEFAULT NULL,
  `cancel_next_attempt_at` datetime(3) NULL DEFAULT NULL,
  `waiting_reply_id` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `waiting_tool_call_id` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `waiting_tool_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `wait_expires_at` datetime(3) NULL DEFAULT NULL,
  `paused_through_sequence` bigint(20) NULL DEFAULT NULL,
  `deadline_at` datetime(3) NOT NULL,
  `started_at` datetime(3) NOT NULL,
  `heartbeat_at` datetime(3) NULL DEFAULT NULL,
  `finished_at` datetime(3) NULL DEFAULT NULL,
  `error_code` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `usage_settled` tinyint(4) NOT NULL DEFAULT 0,
  `usage_settled_at` datetime(3) NULL DEFAULT NULL,
  `projected_through_sequence` bigint(20) NOT NULL DEFAULT 0,
  `projection_completed_at` datetime(3) NULL DEFAULT NULL,
  `active_conversation_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin GENERATED ALWAYS AS ((case when (isnull(`parent_run_id`) and (`status` in (_ascii'RUNNING',_ascii'WAITING_CONFIRMATION',_ascii'WAITING_EXTERNAL',_ascii'CANCEL_REQUESTED'))) then `conversation_id` end)) STORED NULL,
  `create_time` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `update_time` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_agent_run_id`(`run_id`) USING BTREE,
  UNIQUE INDEX `uk_agent_run_active`(`active_conversation_id`) USING BTREE,
  UNIQUE INDEX `uk_agent_run_parent_tool`(`parent_run_id`, `parent_tool_call_id`) USING BTREE,
  INDEX `idx_agent_run_conversation_status`(`conversation_id`, `status`, `id`) USING BTREE,
  INDEX `idx_agent_run_parent_status`(`parent_run_id`, `status`, `id`) USING BTREE,
  INDEX `idx_agent_run_user_status`(`user_id`, `status`, `update_time`) USING BTREE,
  INDEX `idx_agent_run_lease`(`status`, `lease_until`) USING BTREE,
  INDEX `idx_agent_run_status_deadline`(`status`, `deadline_at`, `id`) USING BTREE,
  INDEX `idx_agent_run_cancel`(`status`, `cancel_next_attempt_at`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AgentScope V2 durable run' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_agent_run
-- ----------------------------

-- ----------------------------
-- Table structure for afv_agent_state
-- ----------------------------
DROP TABLE IF EXISTS `afv_agent_state`;
CREATE TABLE `afv_agent_state`  (
  `session_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `state_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_index` int(11) NOT NULL DEFAULT 0,
  `state_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`session_id`, `state_key`, `item_index`) USING BTREE,
  INDEX `idx_agent_state_updated_at`(`updated_at`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_agent_state
-- ----------------------------

-- ----------------------------
-- Table structure for afv_agent_state_cleanup_policy
-- ----------------------------
DROP TABLE IF EXISTS `afv_agent_state_cleanup_policy`;
CREATE TABLE `afv_agent_state_cleanup_policy`  (
  `id` bigint(20) NOT NULL,
  `cleanup_interval_days` int(11) NOT NULL DEFAULT 1,
  `retention_days` int(11) NOT NULL DEFAULT 30,
  `next_cleanup_at` datetime(3) NOT NULL,
  `cleanup_lease_owner` varchar(160) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `cleanup_lease_until` datetime(3) NULL DEFAULT NULL,
  `last_cleanup_at` datetime(3) NULL DEFAULT NULL,
  `create_time` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `update_time` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_agent_state_cleanup_policy
-- ----------------------------

-- ----------------------------
-- Table structure for afv_agent_workspace_config
-- ----------------------------
DROP TABLE IF EXISTS `afv_agent_workspace_config`;
CREATE TABLE `afv_agent_workspace_config`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭',
  `backend_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'database' COMMENT 'database/local/object_storage',
  `storage_config_id` bigint(20) NULL DEFAULT NULL COMMENT '瀵硅薄瀛樺偍閰嶇疆 ID',
  `local_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鏈湴宸ヤ綔绌洪棿鏍圭洰褰?,
  `migration_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'idle' COMMENT 'idle/copying/verifying/cutover/failed',
  `active_migration_id` bigint(20) NULL DEFAULT NULL COMMENT '褰撳墠杩佺Щ浠诲姟 ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_agent_workspace_storage_config`(`storage_config_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鏅鸿兘浣撳伐浣滅┖闂撮厤缃? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_agent_workspace_config
-- ----------------------------
INSERT INTO `afv_agent_workspace_config` VALUES (1, 'database', NULL, NULL, 'idle', NULL, '2026-08-03 02:11:46', '2026-08-03 02:11:46', b'0');

-- ----------------------------
-- Table structure for afv_agent_workspace_entry
-- ----------------------------
DROP TABLE IF EXISTS `afv_agent_workspace_entry`;
CREATE TABLE `afv_agent_workspace_entry`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭',
  `namespace_hash` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鍛藉悕绌洪棿 SHA-256',
  `namespace_key` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'AgentScope 鍛藉悕绌洪棿',
  `item_hash` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鏂囦欢閿?SHA-256',
  `item_key` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '宸ヤ綔绌洪棿鏂囦欢閿?,
  `backend_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '姝ｆ枃鎵€鍦ㄥ悗绔?,
  `storage_config_id` bigint(20) NULL DEFAULT NULL COMMENT '姝ｆ枃鎵€鍦ㄥ璞″瓨鍌ㄩ厤缃?ID',
  `local_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '姝ｆ枃鎵€鍦ㄦ湰鍦板瓨鍌ㄦ牴鐩綍',
  `content_ref` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鏈湴鐩稿璺緞鎴栧璞￠敭',
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '鏁版嵁搴撳悗绔鏂?JSON',
  `content_sha256` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '姝ｆ枃 SHA-256',
  `content_size` bigint(20) NOT NULL DEFAULT 0 COMMENT '姝ｆ枃瀛楄妭鏁?,
  `version` bigint(20) NOT NULL DEFAULT 1 COMMENT 'CAS 鐗堟湰',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_agent_workspace_entry`(`namespace_hash`, `item_hash`, `deleted`) USING BTREE,
  INDEX `idx_agent_workspace_namespace`(`namespace_hash`, `id`) USING BTREE,
  INDEX `idx_agent_workspace_backend`(`backend_type`, `storage_config_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鏅鸿兘浣撳伐浣滅┖闂存潯鐩? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_agent_workspace_entry
-- ----------------------------

-- ----------------------------
-- Table structure for afv_agent_workspace_migration
-- ----------------------------
DROP TABLE IF EXISTS `afv_agent_workspace_migration`;
CREATE TABLE `afv_agent_workspace_migration`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭',
  `source_backend_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `source_storage_config_id` bigint(20) NULL DEFAULT NULL,
  `source_local_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `target_backend_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_storage_config_id` bigint(20) NULL DEFAULT NULL,
  `target_local_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'copying/verifying/cutover/completed/failed/rolled_back',
  `total_count` bigint(20) NOT NULL DEFAULT 0,
  `copied_count` bigint(20) NOT NULL DEFAULT 0,
  `failed_count` bigint(20) NOT NULL DEFAULT 0,
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `started_at` datetime NULL DEFAULT NULL,
  `finished_at` datetime NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_agent_workspace_migration_status`(`status`, `id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鏅鸿兘浣撳伐浣滅┖闂磋縼绉讳换鍔? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_agent_workspace_migration
-- ----------------------------

-- ----------------------------
-- Table structure for afv_agent_workspace_migration_item
-- ----------------------------
DROP TABLE IF EXISTS `afv_agent_workspace_migration_item`;
CREATE TABLE `afv_agent_workspace_migration_item`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭',
  `migration_id` bigint(20) NOT NULL,
  `entry_id` bigint(20) NOT NULL,
  `source_backend_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `source_storage_config_id` bigint(20) NULL DEFAULT NULL,
  `source_local_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `source_content_ref` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `source_payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `target_backend_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_storage_config_id` bigint(20) NULL DEFAULT NULL,
  `target_local_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `target_content_ref` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `target_payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `content_sha256` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_size` bigint(20) NOT NULL DEFAULT 0,
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'copied',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_agent_workspace_migration_item`(`migration_id`, `entry_id`, `deleted`) USING BTREE,
  INDEX `idx_agent_workspace_migration_item_entry`(`entry_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鏅鸿兘浣撳伐浣滅┖闂磋縼绉绘槑缁? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_agent_workspace_migration_item
-- ----------------------------

-- ----------------------------
-- Table structure for afv_ai_model
-- ----------------------------
DROP TABLE IF EXISTS `afv_ai_model`;
CREATE TABLE `afv_ai_model`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '妯″瀷鏄剧ず鍚嶇О',
  `code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '妯″瀷浠ｇ爜鏍囪瘑锛堝 deepseek-chat銆乹wen-vl-max锛?,
  `model_protocol` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '妯″瀷鍗忚鏍囪瘑',
  `capability_preset_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '妯″瀷鑳藉姏棰勮浠ｇ爜锛汵ULL 琛ㄧず鑷畾涔夎兘鍔涢厤缃?,
  `model_type` int(11) NOT NULL COMMENT '妯″瀷绫诲瀷锛?-鏂囨湰瀵硅瘽 2-鍥剧墖鐢熸垚 3-瑙嗛鐢熸垚',
  `icon` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '妯″瀷鍥炬爣URL',
  `description` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '妯″瀷鎻忚堪璇存槑',
  `sort` int(11) NULL DEFAULT 0 COMMENT '鎺掑垪椤哄簭',
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '鐘舵€侊細0-绂佺敤 1-鍚敤',
  `config` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '妯″瀷鐗瑰畾閰嶇疆JSON锛坱emperature銆乼op_p绛夛級',
  `default_model` tinyint(4) NULL DEFAULT 0 COMMENT '鏄惁涓洪粯璁ゆā鍨?,
  `max_concurrency` int(11) NULL DEFAULT 5 COMMENT '鏈€澶у苟鍙戣姹傛暟',
  `api_config_id` bigint(20) NULL DEFAULT NULL COMMENT '鍏宠仈API閰嶇疆ID',
  `user_id` bigint(20) NULL DEFAULT NULL COMMENT '褰掑睘鐢ㄦ埛ID锛汵ULL琛ㄧず鍏ㄥ眬閰嶇疆',
  `comfyui_workflow_id` bigint(20) NULL DEFAULT NULL COMMENT '鍏宠仈鐨?ComfyUI 宸ヤ綔娴佹爣璇?,
  `support_vision` tinyint(4) NULL DEFAULT 0 COMMENT '鏄惁鏀寔瑙嗚鐞嗚В锛堜紶鍥剧墖锛?,
  `multimodal_input_types` json NOT NULL COMMENT '鏀寔鐨勫妯℃€佽緭鍏ョ被鍨嬶細image/video/audio/file',
  `multimodal_input_transports` json NOT NULL COMMENT '鍚勮緭鍏ョ被鍨嬫敮鎸佺殑浼犺緭鏂瑰紡锛歶rl/base64',
  `support_reasoning` tinyint(4) NULL DEFAULT 0 COMMENT '鏄惁鏀寔娣卞害鎬濊€冿紙reasoning锛?,
  `reasoning_effort_levels` json NOT NULL COMMENT '鎬濊€冪瓑绾у垪琛紝鎸夎兘鍔涗粠楂樺埌浣庢帓搴?,
  `context_window` int(11) NULL DEFAULT NULL COMMENT '涓婁笅鏂囩獥鍙ｅぇ灏忥紙token鏁帮級',
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `deleted_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎闅旂鏍囪瘑锛?-鏈垹闄わ紝鍒犻櫎鍚庝负璁板綍ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_api_config_code`(`api_config_id`, `code`, `deleted_id`) USING BTREE,
  INDEX `idx_ai_model_comfyui_workflow`(`comfyui_workflow_id`) USING BTREE,
  INDEX `idx_ai_model_user_id`(`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI妯″瀷琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_ai_model
-- ----------------------------

-- ----------------------------
-- Table structure for afv_api_config
-- ----------------------------
DROP TABLE IF EXISTS `afv_api_config`;
CREATE TABLE `afv_api_config`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '閰嶇疆鍚嶇О',
  `platform` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '骞冲彴鏍囪瘑锛歞eepseek/dashscope/openai_compatible/ollama/anthropic/vertex_ai',
  `text_protocol` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鏂囨湰妯″瀷榛樿璇锋眰鍗忚',
  `image_protocol` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍥剧墖妯″瀷榛樿璇锋眰鍗忚',
  `video_protocol` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '瑙嗛妯″瀷榛樿璇锋眰鍗忚',
  `api_type` int(11) NULL DEFAULT NULL COMMENT 'API绫诲瀷锛?-鏂囨湰瀵硅瘽 2-鍥剧墖鐢熸垚 3-瑙嗛鐢熸垚',
  `api_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'API鎺ュ彛鍦板潃',
  `auto_append_v1_path` tinyint(4) NOT NULL DEFAULT 1 COMMENT 'OpenAI鍏煎璇锋眰鏄惁鑷姩琛ュ厖/v1璺緞',
  `proxy_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍑虹珯浠ｇ悊绫诲瀷锛歯one/http/socks5',
  `proxy_host` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍑虹珯浠ｇ悊涓绘満',
  `proxy_port` int(11) NULL DEFAULT NULL COMMENT '鍑虹珯浠ｇ悊绔彛',
  `proxy_username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍑虹珯浠ｇ悊璁よ瘉鐢ㄦ埛鍚?,
  `proxy_password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍑虹珯浠ｇ悊璁よ瘉瀵嗙爜',
  `api_key` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'API瀵嗛挜',
  `app_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '搴旂敤ID锛堥儴鍒嗗钩鍙伴渶瑕侊級',
  `app_secret` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '搴旂敤瀵嗛挜/鏈嶅姟璐﹀彿 JSON Key锛堥儴鍒嗗钩鍙伴渶瑕侊紝濡?Vertex AI Service Account锛?,
  `model_id` bigint(20) NULL DEFAULT NULL COMMENT '鍏宠仈妯″瀷ID',
  `user_id` bigint(20) NULL DEFAULT NULL COMMENT '褰掑睘鐢ㄦ埛ID锛汵ULL琛ㄧず鍏ㄥ眬閰嶇疆',
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '鐘舵€侊細0-绂佺敤 1-鍚敤',
  `remark` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '澶囨敞璇存槑',
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_api_config_user_id`(`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'API閰嶇疆琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_api_config
-- ----------------------------

-- ----------------------------
-- Table structure for afv_asset
-- ----------------------------
DROP TABLE IF EXISTS `afv_asset`;
CREATE TABLE `afv_asset`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `user_id` bigint(20) NULL DEFAULT NULL COMMENT '鍒涘缓鑰呯敤鎴稩D',
  `project_id` bigint(20) NULL DEFAULT NULL COMMENT '鎵€灞為」鐩甀D',
  `type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '璧勪骇绫诲瀷锛歝haracter/scene/prop/vehicle/building/costume/effect',
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '璧勪骇鍚嶇О',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '璧勪骇鎻忚堪',
  `cover_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '灏侀潰鍥綰RL',
  `properties` json NULL COMMENT '鍔ㄦ€佸睘鎬SON锛堝瑙掕壊鐨刟ppearance銆乤ge绛夛級',
  `tags` json NULL COMMENT '鏍囩鍒楄〃JSON',
  `source_type` int(11) NULL DEFAULT 1 COMMENT '鏉ユ簮绫诲瀷锛?-鐢ㄦ埛涓婁紶 2-AI鐢熸垚',
  `ai_prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'AI鐢熸垚鏃朵娇鐢ㄧ殑鎻愮ず璇?,
  `owner_type` int(11) NULL DEFAULT NULL COMMENT '鎷ユ湁鑰呯被鍨嬶細1-涓汉 2-鍥㈤槦',
  `owner_id` bigint(20) NULL DEFAULT NULL COMMENT '鎷ユ湁鑰匢D',
  `status` int(11) NULL DEFAULT 1 COMMENT '鐘舵€侊細0-鑽夌 1-姝ｅ父',
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_asset_project`(`project_id`) USING BTREE,
  INDEX `idx_asset_owner`(`owner_type`, `owner_id`) USING BTREE,
  INDEX `idx_asset_type`(`project_id`, `type`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '璧勪骇琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_asset
-- ----------------------------

-- ----------------------------
-- Table structure for afv_asset_item
-- ----------------------------
DROP TABLE IF EXISTS `afv_asset_item`;
CREATE TABLE `afv_asset_item`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `asset_id` bigint(20) NOT NULL COMMENT '鎵€灞炰富璧勪骇ID',
  `item_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '瀛愯祫浜х被鍨嬶細front/side/back/detail/expression/pose/variant/original',
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '瀛愯祫浜у悕绉?,
  `image_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍥剧墖URL',
  `thumbnail_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '缂╃暐鍥綰RL',
  `properties` json NULL COMMENT '鍔ㄦ€佸睘鎬SON',
  `sort_order` int(11) NULL DEFAULT 0 COMMENT '鎺掑垪椤哄簭',
  `source_type` int(11) NULL DEFAULT 1 COMMENT '鏉ユ簮绫诲瀷锛?-鐢ㄦ埛涓婁紶 2-AI鐢熸垚',
  `ai_prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'AI鐢熸垚鏃朵娇鐢ㄧ殑鎻愮ず璇?,
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_asset_item_asset`(`asset_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '瀛愯祫浜ц〃' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_asset_item
-- ----------------------------

-- ----------------------------
-- Table structure for afv_comfyui_workflow
-- ----------------------------
DROP TABLE IF EXISTS `afv_comfyui_workflow`;
CREATE TABLE `afv_comfyui_workflow`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭',
  `api_config_id` bigint(20) NOT NULL COMMENT 'ComfyUI 鎺ュ彛閰嶇疆鏍囪瘑',
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '宸ヤ綔娴佹樉绀哄悕绉?,
  `code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '宸ヤ綔娴佺ǔ瀹氭爣璇?,
  `model_type` int(11) NOT NULL COMMENT '妯″瀷绫诲瀷锛?-鍥剧墖锛?-瑙嗛',
  `description` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '宸ヤ綔娴佽鏄?,
  `active_version_id` bigint(20) NULL DEFAULT NULL COMMENT '褰撳墠鍙戝竷鐨勫伐浣滄祦鐗堟湰鏍囪瘑',
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '鐘舵€侊細0-绂佺敤锛?-鍚敤',
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囪',
  `deleted_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎闅旂鏍囪瘑',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_comfyui_workflow_code`(`api_config_id`, `code`, `deleted_id`) USING BTREE,
  INDEX `idx_comfyui_workflow_api_config`(`api_config_id`, `status`) USING BTREE,
  INDEX `idx_comfyui_workflow_active_version`(`active_version_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ComfyUI 宸ヤ綔娴? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_comfyui_workflow
-- ----------------------------

-- ----------------------------
-- Table structure for afv_comfyui_workflow_version
-- ----------------------------
DROP TABLE IF EXISTS `afv_comfyui_workflow_version`;
CREATE TABLE `afv_comfyui_workflow_version`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭',
  `workflow_id` bigint(20) NOT NULL COMMENT '宸ヤ綔娴佹爣璇?,
  `version_no` int(11) NOT NULL COMMENT '鍗曡皟閫掑鐨勭増鏈彿',
  `ui_workflow_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '鍙€夌殑 ComfyUI 鐣岄潰鏍煎紡宸ヤ綔娴?,
  `api_workflow_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'ComfyUI 鎺ュ彛鏍煎紡宸ヤ綔娴?,
  `input_bindings_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '骞冲彴杈撳叆缁戝畾',
  `output_bindings_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鏄惧紡杈撳嚭缁戝畾',
  `required_nodes_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '蹇呴渶鑺傜偣绫诲垪琛?,
  `workflow_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '瑙勮寖鍖栨墽琛屽畾涔夌殑鍝堝笇鍊?,
  `validation_status` int(11) NOT NULL DEFAULT 0 COMMENT '鏍￠獙鐘舵€侊細0-鏈牎楠岋紝1-鏈夋晥锛?-鏃犳晥',
  `validation_message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '鏍￠獙璇︽儏',
  `test_status` int(11) NOT NULL DEFAULT 0 COMMENT '璇曡繍琛岀姸鎬侊細0-鏈瘯杩愯锛?-閫氳繃锛?-澶辫触',
  `test_message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '璇曡繍琛岃鎯?,
  `last_test_time` datetime NULL DEFAULT NULL COMMENT '鏈€鍚庤瘯杩愯鏃堕棿',
  `published` tinyint(4) NOT NULL DEFAULT 0 COMMENT '姝ょ増鏈槸鍚︽浘缁忓彂甯?,
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囪',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_comfyui_workflow_version`(`workflow_id`, `version_no`) USING BTREE,
  INDEX `idx_comfyui_workflow_version_status`(`workflow_id`, `validation_status`, `test_status`, `published`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '涓嶅彲鍙樼殑 ComfyUI 宸ヤ綔娴佺増鏈? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_comfyui_workflow_version
-- ----------------------------

-- ----------------------------
-- Table structure for afv_image_item
-- ----------------------------
DROP TABLE IF EXISTS `afv_image_item`;
CREATE TABLE `afv_image_item`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `task_id` bigint(20) NOT NULL COMMENT '鎵€灞炵敓鍥句换鍔D',
  `platform_task_id` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '骞冲彴渚т换鍔D',
  `image_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鐢熸垚鐨勫浘鐗嘦RL',
  `thumbnail_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '缂╃暐鍥綰RL',
  `width` int(11) NULL DEFAULT NULL COMMENT '鍥剧墖瀹藉害锛堝儚绱狅級',
  `height` int(11) NULL DEFAULT NULL COMMENT '鍥剧墖楂樺害锛堝儚绱狅級',
  `file_size` bigint(20) NULL DEFAULT NULL COMMENT '鏂囦欢澶у皬锛堝瓧鑺傦級',
  `status` int(11) NULL DEFAULT 0 COMMENT '鐘舵€侊細0-鐢熸垚涓?1-鎴愬姛 2-澶辫触',
  `error_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '澶辫触閿欒淇℃伅',
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_image_item_task`(`task_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鐢熷浘鏉＄洰琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_image_item
-- ----------------------------

-- ----------------------------
-- Table structure for afv_image_task
-- ----------------------------
DROP TABLE IF EXISTS `afv_image_task`;
CREATE TABLE `afv_image_task`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `task_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '浠诲姟鍞竴鏍囪瘑',
  `user_id` bigint(20) NOT NULL COMMENT '鍙戣捣鐢ㄦ埛ID',
  `project_id` bigint(20) NULL DEFAULT NULL COMMENT '鍏宠仈椤圭洰ID',
  `prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '鐢熷浘鎻愮ず璇?,
  `prompt_template_id` bigint(20) NULL DEFAULT NULL COMMENT '鎻愮ず璇嶆ā鏉縄D',
  `ref_image_urls` json NULL COMMENT '鍙傝€冨浘鐗嘦RL鍒楄〃JSON',
  `ratio` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鐢婚潰姣斾緥锛堝16:9锛?,
  `resolution` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍒嗚鲸鐜囷紙濡?920x1080锛?,
  `aspect_ratio` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '瀹介珮姣旀弿杩?,
  `width` int(11) NULL DEFAULT NULL COMMENT '鍥剧墖瀹藉害锛堝儚绱狅級',
  `height` int(11) NULL DEFAULT NULL COMMENT '鍥剧墖楂樺害锛堝儚绱狅級',
  `count` int(11) NULL DEFAULT 1 COMMENT '鐢熸垚鏁伴噺',
  `success_count` int(11) NULL DEFAULT 0 COMMENT '宸叉垚鍔熺敓鎴愭暟閲?,
  `status` int(11) NULL DEFAULT 0 COMMENT '浠诲姟鐘舵€侊細0-鎺掗槦涓?1-澶勭悊涓?2-宸插畬鎴?3-澶辫触',
  `error_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '澶辫触閿欒淇℃伅',
  `model_id` bigint(20) NULL DEFAULT NULL COMMENT '浣跨敤鐨凙I妯″瀷ID',
  `workflow_version_id` bigint(20) NULL DEFAULT NULL COMMENT '鍥哄畾鐨?ComfyUI 宸ヤ綔娴佺増鏈爣璇?,
  `category` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '浠诲姟鍒嗙被鏍囩',
  `owner_type` int(11) NULL DEFAULT NULL COMMENT '鎷ユ湁鑰呯被鍨嬶細1-涓汉 2-鍥㈤槦',
  `owner_id` bigint(20) NULL DEFAULT NULL COMMENT '鎷ユ湁鑰匢D',
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `task_id`(`task_id`) USING BTREE,
  INDEX `idx_image_task_workflow_version`(`workflow_version_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鐢熷浘浠诲姟琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_image_task
-- ----------------------------

-- ----------------------------
-- Table structure for afv_project
-- ----------------------------
DROP TABLE IF EXISTS `afv_project`;
CREATE TABLE `afv_project`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `name` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '椤圭洰鍚嶇О',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '椤圭洰鎻忚堪',
  `cover_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '椤圭洰灏侀潰鍥綰RL',
  `scope` int(11) NULL DEFAULT 2 COMMENT '鍙鑼冨洿锛?-鍏紑 2-绉佹湁 3-浠呭洟闃熷彲瑙?,
  `owner_type` int(11) NOT NULL COMMENT '鎷ユ湁鑰呯被鍨嬶細1-涓汉 2-鍥㈤槦',
  `owner_id` bigint(20) NOT NULL COMMENT '鎷ユ湁鑰匢D',
  `status` int(11) NULL DEFAULT 0 COMMENT '鐘舵€侊細0-绛瑰涓?1-杩涜涓?2-宸插畬鎴?3-宸插綊妗?,
  `properties` json NULL COMMENT '鎵╁睍閰嶇疆JSON',
  `art_style` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鐢婚key锛堥璁緆ey鎴朿ustom锛?,
  `art_style_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '鐢婚涓枃鎻忚堪',
  `art_style_image_prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '鐢婚鑻辨枃鎻愮ず璇?,
  `art_style_image_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鐢婚鍙傝€冨浘璺緞',
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '瑙嗛椤圭洰琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_project
-- ----------------------------
INSERT INTO `afv_project` VALUES (1, '褰辫婕旂ず椤圭洰', '杩欐槸涓€鏉″唴缃殑婕旂ず鏁版嵁锛屽府鍔╀綘蹇€熶簡瑙ｇ敤銆屼簯鎻介暅銆嶅畬鎴愪竴閮ㄧ煭瑙嗛鐨勫畬鏁存祦绋嬨€俓n婕旂ず椤圭洰閲囩敤銆屽浼犵墖銆嶇被鍨嬨€?6:9 鐢诲箙銆佸啓瀹炵敾椋庯紝宸插唴缃ず渚嬪墽鏈笌绀轰緥鍒嗛暅銆俓n\n涓婃墜姝ラ锛歕n1. 鍓ф湰锛氭煡鐪嬪唴缃ず渚嬪墽鏈紝浜嗚В闀滃ご鑴氭湰鐨勫啓娉曪紱\n2. 鍒嗛暅锛氬墽鏈凡鎷嗗垎涓虹ず渚嬪垎闀滐紙鍚櫙鍒€侀暅澶磋繍鍔ㄣ€佺敾闈㈡弿杩颁笌 AI 鎻愮ず璇嶏級锛沑n3. 鐢熸垚锛氳繘鍏ャ€岀敓瑙嗛銆嶉〉锛岄€夋嫨妯″瀷骞剁矘璐村垎闀滀腑鐨勭ず渚嬫彁绀鸿瘝锛屽嵆鍙敓鎴愬搴旇棰戯紱\n4. 璧勪骇锛氱敓鎴愮殑瑙嗛涓庡浘鐗囦細鑷姩褰掓。鍒版湰椤圭洰鐨勮祫浜у簱銆俓n\n鏈」鐩彲浠绘剰淇敼锛屼笉褰卞搷绯荤粺銆?, NULL, 1, 1, 1, 1, '{\"demo\": true, \"type\": \"瀹ｄ紶鐗嘰", \"aspectRatio\": \"16:9\"}', 'realistic', NULL, NULL, NULL, 0, '2026-08-30 20:57:40', '2026-08-30 20:57:40');

-- ----------------------------
-- Table structure for afv_project_member
-- ----------------------------
DROP TABLE IF EXISTS `afv_project_member`;
CREATE TABLE `afv_project_member`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `project_id` bigint(20) NOT NULL COMMENT '鎵€灞為」鐩甀D',
  `user_id` bigint(20) NOT NULL COMMENT '鎴愬憳鐢ㄦ埛ID',
  `role` int(11) NOT NULL DEFAULT 3 COMMENT '鎴愬憳瑙掕壊锛?-鎷ユ湁鑰?2-绠＄悊鍛?3-鏅€氭垚鍛?,
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_project_user`(`project_id`, `user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '椤圭洰鎴愬憳琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_project_member
-- ----------------------------

-- ----------------------------
-- Table structure for afv_script
-- ----------------------------
DROP TABLE IF EXISTS `afv_script`;
CREATE TABLE `afv_script`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `project_id` bigint(20) NOT NULL COMMENT '鎵€灞為」鐩甀D',
  `title` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍓ф湰鏍囬',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '鍓ф湰姝ｆ枃鍐呭锛堟牸寮忓寲鍚庯級',
  `raw_content` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '鍓ф湰鍘熷鍐呭锛堢敤鎴风矘璐寸殑鍘熸枃锛?,
  `total_episodes` int(11) NULL DEFAULT 0 COMMENT '鎬婚泦鏁?,
  `story_synopsis` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '鏁呬簨姊楁',
  `characters_json` json NULL COMMENT '瑙掕壊鍒楄〃JSON',
  `source_type` int(11) NULL DEFAULT 0 COMMENT '鏉ユ簮绫诲瀷锛?-鎵嬪姩鍒涘缓 1-鏂囦欢瀵煎叆 2-AI鐢熸垚',
  `parsing_status` int(11) NULL DEFAULT 0 COMMENT '瑙ｆ瀽鐘舵€侊細0-鏈В鏋?1-瑙ｆ瀽涓?2-瑙ｆ瀽瀹屾垚 3-瑙ｆ瀽澶辫触',
  `parsing_progress` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '瑙ｆ瀽杩涘害鎻忚堪',
  `summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'AI鐢熸垚鐨勫墽鏈憳瑕?,
  `genre` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍓ф湰绫诲瀷/棰樻潗',
  `target_audience` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鐩爣鍙椾紬',
  `duration_estimate` int(11) NULL DEFAULT NULL COMMENT '棰勪及鎬绘椂闀匡紙鍒嗛挓锛?,
  `scope` int(11) NULL DEFAULT 3 COMMENT '鍙鑼冨洿锛?-鍏紑 2-绉佹湁 3-浠呭洟闃熷彲瑙?,
  `owner_type` int(11) NULL DEFAULT NULL COMMENT '鎷ユ湁鑰呯被鍨嬶細1-涓汉 2-鍥㈤槦',
  `owner_id` bigint(20) NULL DEFAULT NULL COMMENT '鎷ユ湁鑰匢D',
  `ai_generated` tinyint(4) NULL DEFAULT 0 COMMENT '鏄惁鐢盇I鐢熸垚',
  `version` int(11) NULL DEFAULT 0 COMMENT '涔愯閿佺増鏈彿',
  `status` int(11) NULL DEFAULT 0 COMMENT '鐘舵€侊細0-鑽夌 1-姝ｅ父',
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_script_project`(`project_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鍓ф湰琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_script
-- ----------------------------
INSERT INTO `afv_script` VALUES (1, 1, '褰辫婕旂ず椤圭洰', NULL, '銆愬煄甯傚嵃璞?路 绀轰緥鍓ф湰銆慭n\n鍦烘櫙涓€ 路 鏅ㄩ浘琛楄锛堝鏅?娓呮櫒 闆ㄥ悗锛塡n娓呮櫒鐨勫煄甯傚湪钖勯浘涓嫃閱掞紝闆ㄦ按鎵撴箍鐨勮閬撳弽灏勭潃闇撹櫣鐏厜銆備竴鍚嶈浜烘拺浼炵┛杩囪瑙掞紝闀滃ご缂撴參鎺ㄨ繘銆傦紙鍏ㄦ櫙鈫掍腑鏅級\n\n鍦烘櫙浜?路 澶╁彴鏃ュ嚭锛堝鏅?娓呮櫒锛塡n闀滃ご瓒婅繃鍩庡競澶╅檯绾匡紝鏅ㄥ厜閫愭笎鐓т寒杩滃楂樻ゼ锛屼簯灞傝鏌撴垚閲戣壊锛岃埅鎷嶉暅澶寸紦缂撴媺鍗囥€傦紙鑸媿鍏ㄦ櫙锛塡n\n鍦烘櫙涓?路 姹熺晹澶滄櫙锛堝鏅?鍌嶆櫄锛塡n鍌嶆櫄鐨勬睙杈癸紝鍩庡競鐏厜渚濇浜捣锛岄暅澶磋窡闅忛楦熸帬杩囨睙闈紝瀹氭牸鍦ㄧ伅鐏緣鐓岀殑鍩庡競鍏ㄦ櫙銆傦紙杩滄櫙鈫掑叏鏅級', 0, '浠ュ煄甯傛竻鏅ㄥ埌鍌嶆櫄涓虹嚎绱紝鐢ㄤ笁涓暅澶村睍鐜颁竴搴у煄甯傜殑鑻忛啋涓庣箒鍗庛€?, NULL, 0, 0, NULL, NULL, NULL, NULL, NULL, 1, 1, 1, 0, 0, 1, 0, '2026-08-30 20:57:40', '2026-08-30 20:57:40');

-- ----------------------------
-- Table structure for afv_script_episode
-- ----------------------------
DROP TABLE IF EXISTS `afv_script_episode`;
CREATE TABLE `afv_script_episode`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `script_id` bigint(20) NOT NULL COMMENT '鎵€灞炲墽鏈琁D',
  `episode_number` int(11) NULL DEFAULT NULL COMMENT '闆嗗彿锛堜粠1寮€濮嬶級',
  `title` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鏈泦鏍囬',
  `synopsis` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '鏈泦鍓ф儏姊楁',
  `raw_content` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '鏈泦鍘熷鍓ф湰鍐呭',
  `duration_estimate` int(11) NULL DEFAULT NULL COMMENT '棰勪及鏃堕暱锛堝垎閽燂級',
  `total_scenes` int(11) NULL DEFAULT 0 COMMENT '鏈泦鎬诲満娆℃暟',
  `source_type` int(11) NULL DEFAULT 0 COMMENT '鏉ユ簮绫诲瀷锛?-AI瑙ｆ瀽 1-鎵嬪姩娣诲姞',
  `sort_order` int(11) NULL DEFAULT 0 COMMENT '鎺掑垪椤哄簭',
  `parsing_status` int(11) NULL DEFAULT 0 COMMENT '瑙ｆ瀽鐘舵€侊細0-鏈В鏋?1-瑙ｆ瀽涓?2-瑙ｆ瀽瀹屾垚 3-瑙ｆ瀽澶辫触',
  `status` int(11) NULL DEFAULT 0 COMMENT '鐘舵€侊細0-鑽夌 1-姝ｅ父',
  `version` int(11) NULL DEFAULT 0 COMMENT '涔愯閿佺増鏈彿',
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_episode_script`(`script_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鍒嗛泦鍓ф湰琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_script_episode
-- ----------------------------

-- ----------------------------
-- Table structure for afv_script_scene_item
-- ----------------------------
DROP TABLE IF EXISTS `afv_script_scene_item`;
CREATE TABLE `afv_script_scene_item`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `episode_id` bigint(20) NOT NULL COMMENT '鎵€灞炲垎闆咺D',
  `script_id` bigint(20) NOT NULL COMMENT '鎵€灞炲墽鏈琁D',
  `scene_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍦烘缂栧彿锛堝1-1琛ㄧず绗?闆嗙1鍦猴級',
  `scene_heading` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍦烘櫙鏍囧ご锛堝\"鍐呮櫙 瀹㈠巺 澶淺"锛?,
  `location` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍦烘櫙鍦扮偣',
  `time_of_day` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鏃堕棿娈碉細鏃?澶?榛勬槒/娓呮櫒绛?,
  `int_ext` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍐呭鏅爣璇嗭細鍐呮櫙/澶栨櫙/鍐呭鏅?,
  `characters` json NULL COMMENT '鍑哄満瑙掕壊鍚嶅垪琛↗SON',
  `character_asset_ids` json NULL COMMENT '鍑哄満瑙掕壊璧勪骇ID鍒楄〃JSON',
  `scene_asset_id` bigint(20) NULL DEFAULT NULL COMMENT '鍦烘櫙璧勪骇ID',
  `prop_asset_ids` json NULL COMMENT '閬撳叿璧勪骇ID鍒楄〃JSON',
  `scene_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '鍦烘櫙姘涘洿/鐜鎻忚堪',
  `dialogues` json NULL COMMENT '瀵圭櫧/鍔ㄤ綔鍏冪礌鍒楄〃JSON',
  `sort_order` int(11) NULL DEFAULT 0 COMMENT '鎺掑垪椤哄簭',
  `status` int(11) NULL DEFAULT 0 COMMENT '鐘舵€侊細0-鑽夌 1-姝ｅ父',
  `version` int(11) NULL DEFAULT 0 COMMENT '涔愯閿佺増鏈彿',
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_script_scene_episode`(`episode_id`) USING BTREE,
  INDEX `idx_script_scene_script`(`script_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鍓ф湰鍒嗗満娆¤〃' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_script_scene_item
-- ----------------------------

-- ----------------------------
-- Table structure for afv_storage_config
-- ----------------------------
DROP TABLE IF EXISTS `afv_storage_config`;
CREATE TABLE `afv_storage_config`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '閰嶇疆鍚嶇О',
  `type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '瀛樺偍绫诲瀷锛歭ocal / aliyun_oss / tencent_cos / s3',
  `provider` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'S3鍏煎鍘傚晢锛歡eneric_s3/aliyun_oss/tencent_cos/qiniu_kodo/ctyun_zos/minio',
  `endpoint` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'OSS 绔偣鍦板潃',
  `bucket_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'OSS 瀛樺偍妗跺悕绉?,
  `access_key` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'OSS Access Key',
  `secret_key` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'OSS Secret Key',
  `region` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍖哄煙',
  `base_path` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '瀛樺偍鏍硅矾寰勶紙鏈湴涓虹鐩樿矾寰勶紝OSS 涓?key 鍓嶇紑锛?,
  `custom_domain` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鑷畾涔夊煙鍚嶏紙CDN 鍩熷悕绛夛級',
  `options` json NULL COMMENT '鍘傚晢鎵╁睍閰嶇疆JSON',
  `is_default` tinyint(4) NOT NULL DEFAULT 0 COMMENT '鏄惁涓洪粯璁ゅ瓨鍌ㄩ厤缃?,
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '鐘舵€侊細0-绂佺敤 1-鍚敤',
  `remark` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '澶囨敞',
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '瀛樺偍閰嶇疆琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_storage_config
-- ----------------------------

-- ----------------------------
-- Table structure for afv_storyboard
-- ----------------------------
DROP TABLE IF EXISTS `afv_storyboard`;
CREATE TABLE `afv_storyboard`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `project_id` bigint(20) NULL DEFAULT NULL COMMENT '鎵€灞為」鐩甀D',
  `script_id` bigint(20) NULL DEFAULT NULL COMMENT '鍏宠仈鍓ф湰ID',
  `title` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍒嗛暅鏍囬',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '鍒嗛暅鎻忚堪',
  `custom_columns` json NULL COMMENT '鑷畾涔夊垪閰嶇疆JSON',
  `scope` int(11) NULL DEFAULT 3 COMMENT '鍙鑼冨洿锛?-鍏紑 2-绉佹湁 3-浠呭洟闃熷彲瑙?,
  `owner_type` int(11) NULL DEFAULT NULL COMMENT '鎷ユ湁鑰呯被鍨嬶細1-涓汉 2-鍥㈤槦',
  `owner_id` bigint(20) NULL DEFAULT NULL COMMENT '鎷ユ湁鑰匢D',
  `total_duration` int(11) NULL DEFAULT NULL COMMENT '棰勪及鎬绘椂闀匡紙绉掞級',
  `status` int(11) NULL DEFAULT 0 COMMENT '鐘舵€侊細0-鑽夌 1-姝ｅ父',
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_storyboard_project`(`project_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鍒嗛暅鑴氭湰琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_storyboard
-- ----------------------------
INSERT INTO `afv_storyboard` VALUES (1, 1, 1, '褰辫婕旂ず椤圭洰', '鍐呯疆绀轰緥鍒嗛暅锛氫笁涓暅澶达紝灞曠ず鏅埆銆侀暅澶磋繍鍔ㄣ€佺敾闈㈡弿杩颁笌 AI 鎻愮ず璇嶇殑鍐欐硶銆?, NULL, 1, 1, 1, NULL, 1, 0, '2026-08-30 20:57:40', '2026-08-30 20:57:40');

-- ----------------------------
-- Table structure for afv_storyboard_episode
-- ----------------------------
DROP TABLE IF EXISTS `afv_storyboard_episode`;
CREATE TABLE `afv_storyboard_episode`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `storyboard_id` bigint(20) NOT NULL COMMENT '鎵€灞炲垎闀淚D',
  `script_episode_id` bigint(20) NULL DEFAULT NULL COMMENT '鍏宠仈鐨勫墽鏈垎闆咺D',
  `episode_number` int(11) NULL DEFAULT NULL COMMENT '闆嗗彿',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '闆嗘爣棰?,
  `synopsis` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '鏈泦姊楁',
  `sort_order` int(11) NULL DEFAULT 0 COMMENT '鎺掑垪椤哄簭',
  `status` int(11) NULL DEFAULT 0 COMMENT '鐘舵€侊細0-鑽夌 1-姝ｅ父',
  `deleted` tinyint(4) NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `deleted_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎闅旂鏍囪瘑锛?-鏈垹闄わ紝鍒犻櫎鍚庝负璁板綍ID',
  `create_time` datetime NULL DEFAULT NULL COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NULL DEFAULT NULL COMMENT '鏇存柊鏃堕棿',
  `composed_video_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鏈泦鍚堟垚瑙嗛URL',
  `compose_status` tinyint(4) NOT NULL DEFAULT 0 COMMENT '鍚堟垚鐘舵€? 0鏈紑濮?1鍚堟垚涓?2宸插畬鎴?3澶辫触',
  `compose_error_msg` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍚堟垚澶辫触鍘熷洜',
  `composed_at` datetime NULL DEFAULT NULL COMMENT '鍚堟垚瀹屾垚鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_sb_episode_script_episode`(`storyboard_id`, `script_episode_id`, `deleted_id`) USING BTREE,
  INDEX `idx_sb_episode_storyboard`(`storyboard_id`) USING BTREE,
  INDEX `idx_sb_episode_script_episode`(`script_episode_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鍒嗛暅闆嗚〃' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_storyboard_episode
-- ----------------------------

-- ----------------------------
-- Table structure for afv_storyboard_item
-- ----------------------------
DROP TABLE IF EXISTS `afv_storyboard_item`;
CREATE TABLE `afv_storyboard_item`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `storyboard_id` bigint(20) NOT NULL COMMENT '鎵€灞炲垎闀淚D',
  `storyboard_episode_id` bigint(20) NULL DEFAULT NULL COMMENT '鎵€灞炲垎闀滈泦ID',
  `storyboard_scene_id` bigint(20) NULL DEFAULT NULL COMMENT '鎵€灞炲垎闀滃満娆D',
  `sort_order` int(11) NULL DEFAULT 0 COMMENT '鎺掑垪椤哄簭',
  `shot_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '闀滃彿',
  `auto_shot_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鑷姩缂栧彿锛堢郴缁熺敓鎴愶級',
  `image_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鐢ㄦ埛涓婁紶鍙傝€冨浘鐗嘦RL',
  `reference_image_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '澶栭儴鍙傝€冨浘鐗嘦RL',
  `video_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '瑙嗛URL锛堟渶缁堟垚鍝侊級',
  `generated_image_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'AI鐢熸垚鐨勫浘鐗嘦RL',
  `first_frame_image_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '棣栧抚鍙傝€冨浘鐗嘦RL',
  `last_frame_image_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '灏惧抚鍙傝€冨浘鐗嘦RL',
  `first_frame_prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'AI鐢熸垚棣栧抚鏃朵娇鐢ㄧ殑鎻愮ず璇?,
  `last_frame_prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'AI鐢熸垚灏惧抚鏃朵娇鐢ㄧ殑鎻愮ず璇?,
  `generated_video_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'AI鐢熸垚鐨勮棰慤RL',
  `shot_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鏅埆锛氳繙鏅?鍏ㄦ櫙/涓櫙/杩戞櫙/鐗瑰啓',
  `duration` decimal(10, 2) NULL DEFAULT NULL COMMENT '棰勪及鏃堕暱锛堢锛?,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '鐢婚潰鍐呭鎻忚堪',
  `scene_expectation` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '鐢婚潰鏈熸湜鎻忚堪锛圓I鐢熷浘鎻愮ず锛?,
  `sound` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '澹伴煶鎻忚堪',
  `dialogue` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '鍙拌瘝/鏃佺櫧',
  `sound_effect` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '闊虫晥',
  `music` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '閰嶄箰寤鸿',
  `camera_movement` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '闀滃ご杩愬姩锛氭帹/鎷?鎽?绉?璺?鍗?闄?,
  `camera_angle` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '闀滃ご瑙掑害锛氬钩瑙?淇/浠拌',
  `camera_equipment` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鎽勫儚鏈鸿澶?,
  `focal_length` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '闀滃ご鐒︽',
  `transition` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '杞満鏁堟灉锛氬垏/娣″叆/娣″嚭/婧?鍒?,
  `character_ids` json NULL COMMENT '鍑哄満瑙掕壊瀛愯祫浜D鍒楄〃 JSON (List<Long> of AssetItem.id)',
  `scene_asset_item_id` bigint(20) NULL DEFAULT NULL COMMENT '鍦烘櫙瀛愯祫浜D (AssetItem.id)',
  `prop_ids` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '閬撳叿瀛愯祫浜D鍒楄〃 JSON (List<Long> of AssetItem.id)',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '澶囨敞',
  `custom_data` json NULL COMMENT '鑷畾涔夋墿灞曟暟鎹甁SON',
  `ai_generated` tinyint(4) NULL DEFAULT 0 COMMENT '鏄惁鐢盇I鐢熸垚',
  `status` int(11) NULL DEFAULT 0 COMMENT '鐘舵€侊細0-鑽夌 1-姝ｅ父',
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `video_prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'AI鐢熸垚瑙嗛鏃朵娇鐢ㄧ殑鎻愮ず璇嶏紙淇濆瓨浠ヤ究澶嶇敤鍜屾墜鍔ㄨ皟鏁达級',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_sb_item_storyboard`(`storyboard_id`) USING BTREE,
  INDEX `idx_sb_item_scene`(`storyboard_scene_id`) USING BTREE,
  INDEX `idx_sb_item_episode`(`storyboard_episode_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鍒嗛暅鏉＄洰琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_storyboard_item
-- ----------------------------
INSERT INTO `afv_storyboard_item` VALUES (1, 1, NULL, NULL, 1, '1-1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '鍏ㄦ櫙', 5.00, '婀挎鼎琛楅亾鍙嶅皠闇撹櫣锛岃浜烘拺浼炵┛杩囪瑙?, 'cinematic film still, rainy city street at dawn, neon reflections on wet asphalt, a pedestrian with an umbrella crossing, slow push-in, muted color grade, 16:9', '闆ㄥ０銆佸煄甯傝繙澶勮溅娴佸０', NULL, '闆ㄥ０', '杞绘煍閽㈢惔', '鎺?, '骞宠', NULL, NULL, '鍒?, NULL, NULL, NULL, NULL, NULL, 0, 1, 0, '2026-08-30 20:57:40', '2026-08-30 20:57:40', NULL);
INSERT INTO `afv_storyboard_item` VALUES (2, 1, NULL, NULL, 2, '1-2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '杩滄櫙', 5.00, '浜戞捣鏅ㄥ厜涓殑鍩庡競澶╅檯绾匡紝鑸媿鎷夊崌', 'aerial view over sea of clouds at sunrise, city skyline emerging, golden morning light, drone rising slowly, cinematic, 16:9', '椋庡０銆佹瀬杞荤殑寮︿箰閾哄簳', NULL, '椋庡０', '寮︿箰', '鍗?, '淇', NULL, NULL, '婧?, NULL, NULL, NULL, NULL, NULL, 0, 1, 0, '2026-08-30 20:57:40', '2026-08-30 20:57:40', NULL);
INSERT INTO `afv_storyboard_item` VALUES (3, 1, NULL, NULL, 3, '1-3', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '鍏ㄦ櫙', 5.00, '钃濊皟鏃跺埢姹熺晹澶滄櫙锛屽煄甯傜伅鍏夋笎浜紝椋為笩鎺犺繃', 'blue hour riverside cityscape, city lights turning on one by one, birds flying across the river, gentle pan, cinematic, 16:9', '姹熸按澹般€佽繙澶勫煄甯傜櫧鍣０', NULL, '姹熸按澹?, '姘涘洿鐢靛瓙', '鎽?, '骞宠', NULL, NULL, '鍒?, NULL, NULL, NULL, NULL, NULL, 0, 1, 0, '2026-08-30 20:57:40', '2026-08-30 20:57:40', NULL);

-- ----------------------------
-- Table structure for afv_storyboard_scene
-- ----------------------------
DROP TABLE IF EXISTS `afv_storyboard_scene`;
CREATE TABLE `afv_storyboard_scene`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `episode_id` bigint(20) NOT NULL COMMENT '鎵€灞炲垎闀滈泦ID',
  `storyboard_id` bigint(20) NOT NULL COMMENT '鎵€灞炲垎闀淚D锛堝啑浣欙級',
  `scene_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍦烘缂栧彿',
  `scene_heading` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍦烘櫙鏍囧ご',
  `location` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍦烘櫙鍦扮偣',
  `time_of_day` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鏃堕棿娈?,
  `int_ext` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍐呭鏅爣璇?,
  `sort_order` int(11) NULL DEFAULT 0 COMMENT '鎺掑垪椤哄簭',
  `status` int(11) NULL DEFAULT 0 COMMENT '鐘舵€侊細0-鑽夌 1-姝ｅ父',
  `deleted` tinyint(4) NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NULL DEFAULT NULL COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NULL DEFAULT NULL COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_sb_scene_episode`(`episode_id`) USING BTREE,
  INDEX `idx_sb_scene_storyboard`(`storyboard_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鍒嗛暅鍦烘琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_storyboard_scene
-- ----------------------------

-- ----------------------------
-- Table structure for afv_system_config
-- ----------------------------
DROP TABLE IF EXISTS `afv_system_config`;
CREATE TABLE `afv_system_config`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `config_key` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '閰嶇疆閿?,
  `config_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '閰嶇疆鍊?,
  `remark` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '澶囨敞',
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_config_key`(`config_key`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '绯荤粺閰嶇疆琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_system_config
-- ----------------------------
INSERT INTO `afv_system_config` VALUES (1, 'allow_register', 'true', '鏄惁鍏佽鍏紑娉ㄥ唽', 0, '2026-08-03 02:11:43', '2026-08-03 02:11:43');
INSERT INTO `afv_system_config` VALUES (2, 'allow_email_register', 'true', '鏄惁寮€鍚偖绠遍獙璇佺爜娉ㄥ唽锛堝紑鍚悗娉ㄥ唽椤讳娇鐢ㄩ偖绠?楠岃瘉鐮侊級', 0, '2026-08-03 02:11:43', '2026-08-03 02:11:43');
INSERT INTO `afv_system_config` VALUES (3, 'model_use_global', 'true', '妯″瀷浣跨敤妯″紡锛歵rue-鎵€鏈夌敤鎴风粺涓€浣跨敤鍏ㄥ眬妯″瀷锛沠alse-姣忎釜鐢ㄦ埛浣跨敤鑷繁鐨勭鏈夋ā鍨?, 0, '2026-08-30 20:57:37', '2026-08-30 20:57:37');
INSERT INTO `afv_system_config` VALUES (4, 'demo_project_id', '1', '婕旂ず椤圭洰ID锛堝鎵€鏈夌敤鎴峰彲瑙侊紝浣滀负鍙傝€冪ず渚嬶級', 0, '2026-08-30 20:57:40', '2026-08-30 20:57:40');
INSERT INTO `afv_system_config` VALUES (5, 'site_base_url', 'http://127.0.0.1:15858', NULL, 0, '2026-09-01 08:24:02', '2026-09-01 08:24:02');
INSERT INTO `afv_system_config` VALUES (6, 'resource_base_url', 'http://127.0.0.1:15858', NULL, 0, '2026-09-01 08:24:02', '2026-09-01 08:24:02');
INSERT INTO `afv_system_config` VALUES (7, 'mail_smtp_host', '', NULL, 0, '2026-09-01 08:24:02', '2026-09-06 11:58:14');
INSERT INTO `afv_system_config` VALUES (8, 'mail_smtp_port', '', NULL, 0, '2026-09-01 08:24:02', '2026-09-06 11:58:12');
INSERT INTO `afv_system_config` VALUES (9, 'mail_username', '', NULL, 0, '2026-09-01 08:24:02', '2026-09-06 11:58:11');
INSERT INTO `afv_system_config` VALUES (10, 'mail_password', '', NULL, 0, '2026-09-01 08:24:02', '2026-09-06 11:58:09');
INSERT INTO `afv_system_config` VALUES (11, 'mail_ssl', 'true', NULL, 0, '2026-09-01 08:24:02', '2026-09-01 08:24:02');
INSERT INTO `afv_system_config` VALUES (12, 'mail_from', '瑙嗛骞冲彴', NULL, 0, '2026-09-01 08:24:02', '2026-09-06 11:58:17');

-- ----------------------------
-- Table structure for afv_team
-- ----------------------------
DROP TABLE IF EXISTS `afv_team`;
CREATE TABLE `afv_team`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鍥㈤槦鍚嶇О',
  `logo` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍥㈤槦LOGO鍥剧墖URL',
  `description` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍥㈤槦鎻忚堪',
  `owner_user_id` bigint(20) NOT NULL COMMENT '鍒涘缓鑰呯敤鎴稩D',
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '鐘舵€侊細0-绂佺敤 1-鍚敤',
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鍥㈤槦琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_team
-- ----------------------------
INSERT INTO `afv_team` VALUES (1, '榛樿鍥㈤槦', NULL, NULL, 1, 1, 0, '2026-09-02 16:46:23', '2026-09-02 16:46:23');

-- ----------------------------
-- Table structure for afv_team_member
-- ----------------------------
DROP TABLE IF EXISTS `afv_team_member`;
CREATE TABLE `afv_team_member`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `team_id` bigint(20) NOT NULL COMMENT '鎵€灞炲洟闃烮D',
  `user_id` bigint(20) NOT NULL COMMENT '鎴愬憳鐢ㄦ埛ID',
  `role` int(11) NOT NULL DEFAULT 3 COMMENT '瑙掕壊锛?-鍒涘缓鑰?2-绠＄悊鍛?3-鏅€氭垚鍛?,
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '鐘舵€侊細0-绂佺敤 1-鍚敤',
  `join_time` datetime NULL DEFAULT NULL COMMENT '鍔犲叆鏃堕棿',
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_team_user`(`team_id`, `user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鍥㈤槦鎴愬憳琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_team_member
-- ----------------------------

-- ----------------------------
-- Table structure for afv_user_api_key
-- ----------------------------
DROP TABLE IF EXISTS `afv_user_api_key`;
CREATE TABLE `afv_user_api_key`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `user_id` bigint(20) NOT NULL COMMENT '褰掑睘鐢ㄦ埛ID',
  `platform` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '骞冲彴鏍囪瘑锛歯ewapi/comfyui',
  `api_key` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鍔犲瘑鍚庣殑API瀵嗛挜',
  `app_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '搴旂敤ID锛堝彲閫夛級',
  `app_secret` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍔犲瘑鍚庣殑搴旂敤瀵嗛挜锛堝彲閫夛級',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '鐘舵€侊細0-绂佺敤 1-鍚敤',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '澶囨敞璇存槑',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_platform`(`user_id`, `platform`, `deleted`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鐢ㄦ埛鑷甫妯″瀷瀵嗛挜琛紙涓庡叏灞€娓犻亾闅旂锛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_user_api_key
-- ----------------------------

-- ----------------------------
-- Table structure for afv_video_item
-- ----------------------------
DROP TABLE IF EXISTS `afv_video_item`;
CREATE TABLE `afv_video_item`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `task_id` bigint(20) NOT NULL COMMENT '鎵€灞炵敓瑙嗛浠诲姟ID',
  `platform_task_id` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '骞冲彴渚т换鍔D',
  `video_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鐢熸垚鐨勮棰慤RL',
  `cover_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '瑙嗛灏侀潰鍥綰RL',
  `duration` int(11) NULL DEFAULT NULL COMMENT '瑙嗛鏃堕暱锛堢锛?,
  `file_size` bigint(20) NULL DEFAULT NULL COMMENT '鏂囦欢澶у皬锛堝瓧鑺傦級',
  `status` int(11) NULL DEFAULT 0 COMMENT '鐘舵€侊細0-鐢熸垚涓?1-鎴愬姛 2-澶辫触',
  `error_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '澶辫触閿欒淇℃伅',
  `first_frame_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '瑙嗛棣栧抚鍥剧墖URL',
  `last_frame_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '瑙嗛灏惧抚鍥剧墖URL',
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_video_item_task`(`task_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鐢熻棰戞潯鐩〃' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_video_item
-- ----------------------------

-- ----------------------------
-- Table structure for afv_video_task
-- ----------------------------
DROP TABLE IF EXISTS `afv_video_task`;
CREATE TABLE `afv_video_task`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `task_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '浠诲姟鍞竴鏍囪瘑',
  `user_id` bigint(20) NOT NULL COMMENT '鍙戣捣鐢ㄦ埛ID',
  `project_id` bigint(20) NULL DEFAULT NULL COMMENT '鍏宠仈椤圭洰ID',
  `prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '鐢熻棰戞彁绀鸿瘝',
  `prompt_template_id` bigint(20) NULL DEFAULT NULL COMMENT '鎻愮ず璇嶆ā鏉縄D',
  `generate_mode` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鐢熸垚妯″紡锛歵ext2video/image2video',
  `first_frame_image_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '棣栧抚鍙傝€冨浘鐗嘦RL',
  `last_frame_image_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '灏惧抚鍙傝€冨浘鐗嘦RL',
  `reference_image_urls` json NULL COMMENT '鍙傝€冨浘鐗嘦RL鍒楄〃JSON',
  `reference_video_urls` json NULL COMMENT '鍙傝€冭棰慤RL鍒楄〃 JSON',
  `reference_audio_urls` json NULL COMMENT '鍙傝€冮煶棰慤RL鍒楄〃 JSON',
  `ratio` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鐢婚潰姣斾緥锛堝16:9锛?,
  `resolution` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍒嗚鲸鐜囷紙濡?920x1080锛?,
  `duration` int(11) NULL DEFAULT NULL COMMENT '瑙嗛鏃堕暱锛堢锛?,
  `watermark` tinyint(4) NULL DEFAULT 0 COMMENT '鏄惁娣诲姞姘村嵃',
  `generate_audio` tinyint(4) NULL DEFAULT 0 COMMENT '鏄惁鐢熸垚閰嶉煶',
  `seed` bigint(20) NULL DEFAULT NULL COMMENT '闅忔満绉嶅瓙锛堢敤浜庡鐜帮級',
  `camera_fixed` tinyint(4) NULL DEFAULT 0 COMMENT '鏄惁鍥哄畾闀滃ご',
  `count` int(11) NULL DEFAULT 1 COMMENT '鐢熸垚鏁伴噺',
  `success_count` int(11) NULL DEFAULT 0 COMMENT '宸叉垚鍔熺敓鎴愭暟閲?,
  `status` int(11) NULL DEFAULT 0 COMMENT '浠诲姟鐘舵€侊細0-鎺掗槦涓?1-澶勭悊涓?2-宸插畬鎴?3-澶辫触',
  `error_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '澶辫触閿欒淇℃伅',
  `model_id` bigint(20) NULL DEFAULT NULL COMMENT '浣跨敤鐨凙I妯″瀷ID',
  `workflow_version_id` bigint(20) NULL DEFAULT NULL COMMENT '鍥哄畾鐨?ComfyUI 宸ヤ綔娴佺増鏈爣璇?,
  `category` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '浠诲姟鍒嗙被鏍囩',
  `owner_type` int(11) NULL DEFAULT NULL COMMENT '鎷ユ湁鑰呯被鍨嬶細1-涓汉 2-鍥㈤槦',
  `owner_id` bigint(20) NULL DEFAULT NULL COMMENT '鎷ユ湁鑰匢D',
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `task_id`(`task_id`) USING BTREE,
  INDEX `idx_video_task_workflow_version`(`workflow_version_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鐢熻棰戜换鍔¤〃' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_video_task
-- ----------------------------

-- ----------------------------
-- ----------------------------
  `installed_rank` int(11) NOT NULL,
  `version` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `script` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `checksum` int(11) NULL DEFAULT NULL,
  `installed_by` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `installed_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `execution_time` int(11) NOT NULL,
  `success` tinyint(1) NOT NULL,
  PRIMARY KEY (`installed_rank`) USING BTREE,
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- ----------------------------

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '瑙掕壊鍚嶇О',
  `code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '瑙掕壊浠ｇ爜鏍囪瘑锛堝 admin銆乽ser锛?,
  `sort` int(11) NULL DEFAULT 0 COMMENT '鎺掑垪椤哄簭',
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '鐘舵€侊細0-绂佺敤 1-鍚敤',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '澶囨敞璇存槑',
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `code`(`code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '瑙掕壊琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '瓒呯骇绠＄悊鍛?, 'admin', 1, 1, '绯荤粺瓒呯骇绠＄悊鍛?, 0, '2026-04-16 16:03:20', '2026-04-16 16:03:20');
INSERT INTO `sys_role` VALUES (2, '鏅€氱敤鎴?, 'user', 2, 1, '榛樿鐢ㄦ埛瑙掕壊', 0, '2026-04-16 16:03:20', '2026-04-16 16:03:20');

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鐧诲綍鐢ㄦ埛鍚嶏紙鍞竴锛?,
  `password` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鐧诲綍瀵嗙爜锛圔Crypt鍔犲瘑锛?,
  `nickname` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鐢ㄦ埛鏄电О',
  `avatar` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '澶村儚URL',
  `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '閭鍦板潃',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鎵嬫満鍙风爜',
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '鐘舵€侊細0-绂佺敤 1-鍚敤',
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鐢ㄦ埛琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '涓婚敭ID',
  `user_id` bigint(20) NOT NULL COMMENT '鐢ㄦ埛ID',
  `role_id` bigint(20) NOT NULL COMMENT '瑙掕壊ID',
  `deleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '閫昏緫鍒犻櫎鏍囧織',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_role`(`user_id`, `role_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '鐢ㄦ埛瑙掕壊鍏宠仈琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
