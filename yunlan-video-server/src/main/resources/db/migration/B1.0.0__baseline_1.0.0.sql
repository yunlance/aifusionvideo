/*
 Navicat Premium Data Transfer

 Source Server         : Docker-mysql-my
 Source Server Type    : MySQL
 Source Server Version : 80046 (8.0.46)
 Source Host           : localhost:53306
 Source Schema         : aifusionvideo

 Target Server Type    : MySQL
 Target Server Version : 80046 (8.0.46)
 File Encoding         : 65001

 Date: 30/08/2026 17:04:05
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for afv_agent_conversation
-- ----------------------------
DROP TABLE IF EXISTS `afv_agent_conversation`;
CREATE TABLE `afv_agent_conversation`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `conversation_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '对话唯一标识（UUID）',
  `user_id` bigint NULL DEFAULT NULL COMMENT '所属用户ID',
  `project_id` bigint NULL DEFAULT NULL COMMENT '关联项目ID',
  `context_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '上下文类型（project/script/storyboard）',
  `agent_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Agent类型（script_parser/storyboard_creator）',
  `category` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '对话分类标签',
  `context_id` bigint NULL DEFAULT NULL COMMENT '上下文对象ID',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '新对话' COMMENT '对话标题',
  `message_count` int NULL DEFAULT 0 COMMENT '消息总数',
  `last_message_time` datetime NULL DEFAULT NULL COMMENT '最后消息时间',
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '对话状态：active/closed',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `next_message_order` bigint NOT NULL DEFAULT 1,
  `agent_state_last_active_at` datetime(3) NULL DEFAULT NULL,
  `agent_state_expired_at` datetime(3) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `conversation_id`(`conversation_id` ASC) USING BTREE,
  INDEX `idx_conv_project_context`(`project_id` ASC, `context_type` ASC, `context_id` ASC) USING BTREE,
  INDEX `idx_conv_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_agent_conversation_state_retention`(`agent_state_expired_at` ASC, `agent_state_last_active_at` ASC, `id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Agent对话索引表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_agent_conversation
-- ----------------------------

-- ----------------------------
-- Table structure for afv_agent_event
-- ----------------------------
DROP TABLE IF EXISTS `afv_agent_event`;
CREATE TABLE `afv_agent_event`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `run_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `sequence_no` bigint NOT NULL,
  `schema_version` int NOT NULL DEFAULT 1,
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
  `publish_required` tinyint NOT NULL,
  `publish_status` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `publish_claim_owner` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `publish_claim_until` datetime(3) NULL DEFAULT NULL,
  `next_publish_attempt_at` datetime(3) NULL DEFAULT NULL,
  `last_publish_error` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `publish_attempts` int NOT NULL DEFAULT 0,
  `create_time` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_agent_event_sequence`(`run_id` ASC, `sequence_no` ASC) USING BTREE,
  INDEX `idx_agent_event_projection`(`run_id` ASC, `output_type` ASC, `sequence_no` ASC) USING BTREE,
  INDEX `idx_agent_event_publish`(`publish_status` ASC, `next_publish_attempt_at` ASC, `id` ASC) USING BTREE,
  INDEX `idx_agent_event_raw`(`run_id` ASC, `raw_event_id` ASC) USING BTREE,
  CONSTRAINT `chk_agent_event_publish_attempts` CHECK (`publish_attempts` >= 0),
  CONSTRAINT `chk_agent_event_publish_state` CHECK (((`publish_required` = 0) and (`publish_status` = _utf8mb4'NOT_REQUIRED')) or ((`publish_required` = 1) and (`publish_status` in (_utf8mb4'PENDING',_utf8mb4'CLAIMED',_utf8mb4'PUBLISHED')))),
  CONSTRAINT `chk_agent_event_schema_version` CHECK (`schema_version` >= 1),
  CONSTRAINT `chk_agent_event_sequence` CHECK (`sequence_no` >= 1)
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AgentScope V2 committed event journal' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_agent_event
-- ----------------------------

-- ----------------------------
-- Table structure for afv_agent_mcp_server
-- ----------------------------
DROP TABLE IF EXISTS `afv_agent_mcp_server`;
CREATE TABLE `afv_agent_mcp_server`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '所属用户',
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '服务名称',
  `transport` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'http/sse',
  `url` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'MCP 地址',
  `headers_json` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '请求头 JSON',
  `query_params_json` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '查询参数 JSON',
  `enabled_tools_json` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '启用工具 JSON',
  `protocol_versions_json` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '协议版本 JSON',
  `timeout_seconds` int NOT NULL DEFAULT 120,
  `initialization_timeout_seconds` int NOT NULL DEFAULT 30,
  `status` int NOT NULL DEFAULT 1 COMMENT '0 禁用 1 启用',
  `last_test_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `last_test_message` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_agent_mcp_user_status`(`user_id` ASC, `status` ASC, `id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户自定义 MCP 服务' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_agent_mcp_server
-- ----------------------------

-- ----------------------------
-- Table structure for afv_agent_message
-- ----------------------------
DROP TABLE IF EXISTS `afv_agent_message`;
CREATE TABLE `afv_agent_message`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `conversation_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '所属对话ID（UUID）',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '消息角色：user/assistant/system/tool',
  `content` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '消息文本内容',
  `references_json` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '引用资源JSON',
  `tool_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工具调用名称（role=tool时）',
  `tool_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工具执行状态：running/success/error',
  `tool_call_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工具调用ID（关联同一次调用的发起和结果）',
  `parent_tool_call_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '父级工具调用ID（子Agent事件归属到父工具调用）',
  `reasoning_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'AI推理过程内容（思维链）',
  `reasoning_duration_ms` bigint NULL DEFAULT NULL COMMENT 'AI推理耗时（毫秒）',
  `message_order` bigint NOT NULL,
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `run_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `projection_key` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_agent_message_conv_order`(`conversation_id` ASC, `message_order` ASC) USING BTREE,
  UNIQUE INDEX `uk_agent_message_projection_key`(`projection_key` ASC) USING BTREE,
  INDEX `idx_msg_conversation`(`conversation_id` ASC) USING BTREE,
  INDEX `idx_agent_message_conv_run_order`(`conversation_id` ASC, `run_id` ASC, `message_order` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Agent消息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_agent_message
-- ----------------------------

-- ----------------------------
-- Table structure for afv_agent_model_call_usage
-- ----------------------------
DROP TABLE IF EXISTS `afv_agent_model_call_usage`;
CREATE TABLE `afv_agent_model_call_usage`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `run_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `model_call_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `provider` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `model_code` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `status` varchar(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `input_tokens` bigint NULL DEFAULT NULL,
  `output_tokens` bigint NULL DEFAULT NULL,
  `reasoning_tokens` bigint NULL DEFAULT NULL,
  `cache_tokens` bigint NULL DEFAULT NULL,
  `usage_json` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `settlement_status` varchar(24) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `settlement_attempts` int NOT NULL DEFAULT 0,
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
  UNIQUE INDEX `uk_agent_usage_call`(`run_id` ASC, `model_call_id` ASC) USING BTREE,
  INDEX `idx_agent_usage_settlement`(`settlement_status` ASC, `next_settlement_attempt_at` ASC, `id` ASC) USING BTREE,
  INDEX `idx_agent_usage_run_status`(`run_id` ASC, `status` ASC, `id` ASC) USING BTREE,
  CONSTRAINT `chk_agent_usage_settlement` CHECK (`settlement_status` in (_utf8mb4'PENDING',_utf8mb4'CLAIMED',_utf8mb4'SETTLED')),
  CONSTRAINT `chk_agent_usage_settlement_attempts` CHECK (`settlement_attempts` >= 0),
  CONSTRAINT `chk_agent_usage_status` CHECK (`status` in (_utf8mb4'STARTED',_utf8mb4'COMPLETED',_utf8mb4'FAILED',_utf8mb4'CANCELLED')),
  CONSTRAINT `chk_agent_usage_tokens` CHECK (((`input_tokens` is null) or (`input_tokens` >= 0)) and ((`output_tokens` is null) or (`output_tokens` >= 0)) and ((`reasoning_tokens` is null) or (`reasoning_tokens` >= 0)) and ((`cache_tokens` is null) or (`cache_tokens` >= 0)))
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AgentScope V2 model-call usage ledger' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_agent_model_call_usage
-- ----------------------------

-- ----------------------------
-- Table structure for afv_agent_run
-- ----------------------------
DROP TABLE IF EXISTS `afv_agent_run`;
CREATE TABLE `afv_agent_run`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `run_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `conversation_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `user_id` bigint NOT NULL,
  `project_id` bigint NULL DEFAULT NULL,
  `agent_type` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `parent_run_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `parent_tool_call_id` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `agent_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `kernel_fingerprint` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `agent_definition_snapshot_json` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `agent_state_session_id` varchar(255) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `status` varchar(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `owner_instance_id` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `owner_epoch` bigint NOT NULL DEFAULT 0,
  `lease_until` datetime(3) NULL DEFAULT NULL,
  `next_sequence` bigint NOT NULL DEFAULT 1,
  `terminal_sequence` bigint NULL DEFAULT NULL,
  `terminal_output_type` varchar(32) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `cancel_requested_at` datetime(3) NULL DEFAULT NULL,
  `cancel_broadcast_at` datetime(3) NULL DEFAULT NULL,
  `cancel_acknowledged_at` datetime(3) NULL DEFAULT NULL,
  `cancel_next_attempt_at` datetime(3) NULL DEFAULT NULL,
  `waiting_reply_id` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `waiting_tool_call_id` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `waiting_tool_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `wait_expires_at` datetime(3) NULL DEFAULT NULL,
  `paused_through_sequence` bigint NULL DEFAULT NULL,
  `deadline_at` datetime(3) NOT NULL,
  `started_at` datetime(3) NOT NULL,
  `heartbeat_at` datetime(3) NULL DEFAULT NULL,
  `finished_at` datetime(3) NULL DEFAULT NULL,
  `error_code` varchar(64) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `usage_settled` tinyint NOT NULL DEFAULT 0,
  `usage_settled_at` datetime(3) NULL DEFAULT NULL,
  `projected_through_sequence` bigint NOT NULL DEFAULT 0,
  `projection_completed_at` datetime(3) NULL DEFAULT NULL,
  `active_conversation_id` varchar(64) CHARACTER SET ascii COLLATE ascii_bin GENERATED ALWAYS AS ((case when ((`parent_run_id` is null) and (`status` in (_ascii'RUNNING',_ascii'WAITING_CONFIRMATION',_ascii'WAITING_EXTERNAL',_ascii'CANCEL_REQUESTED'))) then `conversation_id` end)) STORED NULL,
  `create_time` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `update_time` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_agent_run_id`(`run_id` ASC) USING BTREE,
  UNIQUE INDEX `uk_agent_run_active`(`active_conversation_id` ASC) USING BTREE,
  UNIQUE INDEX `uk_agent_run_parent_tool`(`parent_run_id` ASC, `parent_tool_call_id` ASC) USING BTREE,
  INDEX `idx_agent_run_conversation_status`(`conversation_id` ASC, `status` ASC, `id` ASC) USING BTREE,
  INDEX `idx_agent_run_parent_status`(`parent_run_id` ASC, `status` ASC, `id` ASC) USING BTREE,
  INDEX `idx_agent_run_user_status`(`user_id` ASC, `status` ASC, `update_time` ASC) USING BTREE,
  INDEX `idx_agent_run_lease`(`status` ASC, `lease_until` ASC) USING BTREE,
  INDEX `idx_agent_run_status_deadline`(`status` ASC, `deadline_at` ASC, `id` ASC) USING BTREE,
  INDEX `idx_agent_run_cancel`(`status` ASC, `cancel_next_attempt_at` ASC) USING BTREE,
  CONSTRAINT `chk_agent_run_parent_identity` CHECK (((`parent_run_id` is null) and (`parent_tool_call_id` is null)) or ((`parent_run_id` is not null) and (`parent_tool_call_id` is not null) and (`agent_name` is not null))),
  CONSTRAINT `chk_agent_run_status` CHECK (`status` in (_utf8mb4'RUNNING',_utf8mb4'WAITING_CONFIRMATION',_utf8mb4'WAITING_EXTERNAL',_utf8mb4'CANCEL_REQUESTED',_utf8mb4'COMPLETED',_utf8mb4'FAILED',_utf8mb4'CANCELLED')),
  CONSTRAINT `chk_agent_run_usage_settled` CHECK (`usage_settled` in (0,1))
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
  `item_index` int NOT NULL DEFAULT 0,
  `state_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`session_id`, `state_key`, `item_index`) USING BTREE,
  INDEX `idx_agent_state_updated_at`(`updated_at` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_agent_state
-- ----------------------------

-- ----------------------------
-- Table structure for afv_agent_state_cleanup_policy
-- ----------------------------
DROP TABLE IF EXISTS `afv_agent_state_cleanup_policy`;
CREATE TABLE `afv_agent_state_cleanup_policy`  (
  `id` bigint NOT NULL,
  `cleanup_interval_days` int NOT NULL DEFAULT 1,
  `retention_days` int NOT NULL DEFAULT 30,
  `next_cleanup_at` datetime(3) NOT NULL,
  `cleanup_lease_owner` varchar(160) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  `cleanup_lease_until` datetime(3) NULL DEFAULT NULL,
  `last_cleanup_at` datetime(3) NULL DEFAULT NULL,
  `create_time` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `update_time` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`) USING BTREE,
  CONSTRAINT `chk_agent_state_cleanup_interval` CHECK (`cleanup_interval_days` between 1 and 365),
  CONSTRAINT `chk_agent_state_retention_days` CHECK (`retention_days` between 1 and 3650)
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_agent_state_cleanup_policy
-- ----------------------------

-- ----------------------------
-- Table structure for afv_agent_workspace_config
-- ----------------------------
DROP TABLE IF EXISTS `afv_agent_workspace_config`;
CREATE TABLE `afv_agent_workspace_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `backend_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'database' COMMENT 'database/local/object_storage',
  `storage_config_id` bigint NULL DEFAULT NULL COMMENT '对象存储配置 ID',
  `local_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '本地工作空间根目录',
  `migration_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'idle' COMMENT 'idle/copying/verifying/cutover/failed',
  `active_migration_id` bigint NULL DEFAULT NULL COMMENT '当前迁移任务 ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_agent_workspace_storage_config`(`storage_config_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '智能体工作空间配置' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_agent_workspace_config
-- ----------------------------

-- ----------------------------
-- Table structure for afv_agent_workspace_entry
-- ----------------------------
DROP TABLE IF EXISTS `afv_agent_workspace_entry`;
CREATE TABLE `afv_agent_workspace_entry`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `namespace_hash` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '命名空间 SHA-256',
  `namespace_key` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'AgentScope 命名空间',
  `item_hash` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '文件键 SHA-256',
  `item_key` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '工作空间文件键',
  `backend_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '正文所在后端',
  `storage_config_id` bigint NULL DEFAULT NULL COMMENT '正文所在对象存储配置 ID',
  `local_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '正文所在本地存储根目录',
  `content_ref` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '本地相对路径或对象键',
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '数据库后端正文 JSON',
  `content_sha256` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '正文 SHA-256',
  `content_size` bigint NOT NULL DEFAULT 0 COMMENT '正文字节数',
  `version` bigint NOT NULL DEFAULT 1 COMMENT 'CAS 版本',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_agent_workspace_entry`(`namespace_hash` ASC, `item_hash` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_agent_workspace_namespace`(`namespace_hash` ASC, `id` ASC) USING BTREE,
  INDEX `idx_agent_workspace_backend`(`backend_type` ASC, `storage_config_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '智能体工作空间条目' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_agent_workspace_entry
-- ----------------------------

-- ----------------------------
-- Table structure for afv_agent_workspace_migration
-- ----------------------------
DROP TABLE IF EXISTS `afv_agent_workspace_migration`;
CREATE TABLE `afv_agent_workspace_migration`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `source_backend_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `source_storage_config_id` bigint NULL DEFAULT NULL,
  `source_local_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `target_backend_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_storage_config_id` bigint NULL DEFAULT NULL,
  `target_local_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'copying/verifying/cutover/completed/failed/rolled_back',
  `total_count` bigint NOT NULL DEFAULT 0,
  `copied_count` bigint NOT NULL DEFAULT 0,
  `failed_count` bigint NOT NULL DEFAULT 0,
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `started_at` datetime NULL DEFAULT NULL,
  `finished_at` datetime NULL DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_agent_workspace_migration_status`(`status` ASC, `id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '智能体工作空间迁移任务' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_agent_workspace_migration
-- ----------------------------

-- ----------------------------
-- Table structure for afv_agent_workspace_migration_item
-- ----------------------------
DROP TABLE IF EXISTS `afv_agent_workspace_migration_item`;
CREATE TABLE `afv_agent_workspace_migration_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `migration_id` bigint NOT NULL,
  `entry_id` bigint NOT NULL,
  `source_backend_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `source_storage_config_id` bigint NULL DEFAULT NULL,
  `source_local_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `source_content_ref` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `source_payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `target_backend_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_storage_config_id` bigint NULL DEFAULT NULL,
  `target_local_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `target_content_ref` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `target_payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `content_sha256` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_size` bigint NOT NULL DEFAULT 0,
  `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'copied',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_agent_workspace_migration_item`(`migration_id` ASC, `entry_id` ASC, `deleted` ASC) USING BTREE,
  INDEX `idx_agent_workspace_migration_item_entry`(`entry_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '智能体工作空间迁移明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of afv_agent_workspace_migration_item
-- ----------------------------

-- ----------------------------
-- Table structure for afv_ai_model
-- ----------------------------
DROP TABLE IF EXISTS `afv_ai_model`;
CREATE TABLE `afv_ai_model`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '模型显示名称',
  `code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '模型代码标识（如 deepseek-chat、qwen-vl-max）',
  `model_protocol` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '模型协议标识',
  `capability_preset_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '模型能力预设代码；NULL 表示自定义能力配置',
  `model_type` int NOT NULL COMMENT '模型类型：1-文本对话 2-图片生成 3-视频生成',
  `icon` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '模型图标URL',
  `description` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '模型描述说明',
  `sort` int NULL DEFAULT 0 COMMENT '排列顺序',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态：0-禁用 1-启用',
  `config` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '模型特定配置JSON（temperature、top_p等）',
  `default_model` tinyint NULL DEFAULT 0 COMMENT '是否为默认模型',
  `max_concurrency` int NULL DEFAULT 5 COMMENT '最大并发请求数',
  `api_config_id` bigint NULL DEFAULT NULL COMMENT '关联API配置ID',
  `user_id` bigint NULL DEFAULT NULL COMMENT '归属用户ID；NULL表示全局配置',
  `comfyui_workflow_id` bigint NULL DEFAULT NULL COMMENT '关联的 ComfyUI 工作流标识',
  `support_vision` tinyint NULL DEFAULT 0 COMMENT '是否支持视觉理解（传图片）',
  `multimodal_input_types` json NOT NULL COMMENT '支持的多模态输入类型：image/video/audio/file',
  `multimodal_input_transports` json NOT NULL COMMENT '各输入类型支持的传输方式：url/base64',
  `support_reasoning` tinyint NULL DEFAULT 0 COMMENT '是否支持深度思考（reasoning）',
  `reasoning_effort_levels` json NOT NULL COMMENT '思考等级列表，按能力从高到低排序',
  `context_window` int NULL DEFAULT NULL COMMENT '上下文窗口大小（token数）',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `deleted_id` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除隔离标识，0-未删除，删除后为记录ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_api_config_code`(`api_config_id` ASC, `code` ASC, `deleted_id` ASC) USING BTREE,
  INDEX `idx_ai_model_comfyui_workflow`(`comfyui_workflow_id` ASC) USING BTREE,
  INDEX `idx_ai_model_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 205 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI模型表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_ai_model
-- ----------------------------
INSERT INTO `afv_ai_model` VALUES (1, 'deepseek-v4-flash', 'deepseek-v4-flash', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 1, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-25 20:26:21', '2026-08-25 20:26:21');
INSERT INTO `afv_ai_model` VALUES (2, 'deepseek-v4-pro', 'deepseek-v4-pro', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-25 20:26:21', '2026-08-25 20:26:21');
INSERT INTO `afv_ai_model` VALUES (3, 'deepseek-v4-pro-202606', 'deepseek-v4-pro-202606', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-25 20:26:21', '2026-08-25 20:26:21');
INSERT INTO `afv_ai_model` VALUES (4, 'hy3', 'hy3', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-25 20:26:21', '2026-08-25 20:26:21');
INSERT INTO `afv_ai_model` VALUES (5, 'kimi-k3', 'kimi-k3', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-25 20:26:21', '2026-08-25 20:26:21');
INSERT INTO `afv_ai_model` VALUES (6, 'qwen-image-3.0', 'qwen-image-3.0', NULL, NULL, 2, NULL, NULL, 0, 1, NULL, 1, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-25 20:26:21', '2026-08-25 20:26:21');
INSERT INTO `afv_ai_model` VALUES (7, 'qwen-image-3.0-pro', 'qwen-image-3.0-pro', NULL, NULL, 2, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-25 20:26:21', '2026-08-25 20:26:21');
INSERT INTO `afv_ai_model` VALUES (8, 'qwen3.7-plus', 'qwen3.7-plus', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-25 20:26:21', '2026-08-25 20:26:21');
INSERT INTO `afv_ai_model` VALUES (9, 'qwen3.8-max', 'qwen3.8-max', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-25 20:26:21', '2026-08-25 20:26:21');
INSERT INTO `afv_ai_model` VALUES (10, 'HY-3D-3.0', 'HY-3D-3.0', NULL, NULL, 2, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 12:23:09', '2026-08-26 12:23:09');
INSERT INTO `afv_ai_model` VALUES (11, 'HY-3D-Component', 'HY-3D-Component', NULL, NULL, 2, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 12:23:09', '2026-08-26 12:23:09');
INSERT INTO `afv_ai_model` VALUES (12, 'HY-3D-Express', 'HY-3D-Express', NULL, NULL, 2, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 12:23:09', '2026-08-26 12:23:09');
INSERT INTO `afv_ai_model` VALUES (13, 'HY-Video-1.5', 'HY-Video-1.5', NULL, NULL, 3, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 12:23:09', '2026-08-26 18:24:55');
INSERT INTO `afv_ai_model` VALUES (14, 'HY-Vision-2.0-Instruct', 'HY-Vision-2.0-Instruct', NULL, NULL, 2, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 12:23:09', '2026-08-26 12:23:09');
INSERT INTO `afv_ai_model` VALUES (15, 'HY-Vision-Video', 'HY-Vision-Video', NULL, NULL, 3, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 12:23:09', '2026-08-26 18:24:57');
INSERT INTO `afv_ai_model` VALUES (16, 'Kimi K3', 'Kimi K3', NULL, NULL, 2, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 12:23:09', '2026-08-26 12:23:09');
INSERT INTO `afv_ai_model` VALUES (17, 'MiniMax-M3', 'MiniMax-M3', NULL, NULL, 2, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 12:23:09', '2026-08-26 12:23:09');
INSERT INTO `afv_ai_model` VALUES (18, 'YT-VITA', 'YT-VITA', NULL, NULL, 2, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 12:23:09', '2026-08-26 12:23:09');
INSERT INTO `afv_ai_model` VALUES (19, 'YT-Video-FX', 'YT-Video-FX', NULL, NULL, 3, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 12:23:09', '2026-08-26 18:25:06');
INSERT INTO `afv_ai_model` VALUES (20, 'YT-Video-HumanActor', 'YT-Video-HumanActor', NULL, NULL, 3, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 12:23:09', '2026-08-26 18:25:07');
INSERT INTO `afv_ai_model` VALUES (21, 'Kling Video 1.6', 'kling-v1-6', 'kling', 'kling-v1-6-video', 3, NULL, NULL, 10, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 13:38:12', '2026-08-26 13:38:12');
INSERT INTO `afv_ai_model` VALUES (22, 'Kling Video 2.1', 'kling-v2-1', 'kling', 'kling-v2-1-video', 3, NULL, NULL, 10, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 13:38:12', '2026-08-26 13:38:12');
INSERT INTO `afv_ai_model` VALUES (23, 'Kling Video 2.5 Turbo', 'kling-v2-5-turbo', 'kling', 'kling-v2-5-turbo-video', 3, NULL, NULL, 10, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 13:38:12', '2026-08-26 13:38:12');
INSERT INTO `afv_ai_model` VALUES (24, 'Jimeng Video 3.0 Pro', 'jimeng-video-3.0-pro', 'jimeng', 'jimeng-video-3.0-pro', 3, NULL, NULL, 10, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 13:38:12', '2026-08-26 13:38:12');
INSERT INTO `afv_ai_model` VALUES (25, 'happyhorse-1.1-i2v', 'happyhorse-1.1-i2v', NULL, NULL, 3, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 18:54:54', '2026-08-26 18:54:54');
INSERT INTO `afv_ai_model` VALUES (26, 'happyhorse-1.1-r2v', 'happyhorse-1.1-r2v', NULL, NULL, 3, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 18:54:54', '2026-08-26 18:54:54');
INSERT INTO `afv_ai_model` VALUES (27, 'happyhorse-1.1-t2v', 'happyhorse-1.1-t2v', NULL, NULL, 3, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 18:54:54', '2026-08-26 18:54:54');
INSERT INTO `afv_ai_model` VALUES (28, 'paraformer-v1', 'paraformer-v1', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 18:54:54', '2026-08-26 18:54:54');
INSERT INTO `afv_ai_model` VALUES (29, 'paraformer-v2', 'paraformer-v2', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 18:54:54', '2026-08-26 18:54:54');
INSERT INTO `afv_ai_model` VALUES (30, 'sambert-zhida-v1', 'sambert-zhida-v1', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 18:54:54', '2026-08-26 18:54:54');
INSERT INTO `afv_ai_model` VALUES (31, 'sambert-zhide-v1', 'sambert-zhide-v1', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 18:54:54', '2026-08-26 18:54:54');
INSERT INTO `afv_ai_model` VALUES (32, 'sambert-zhishu-v1', 'sambert-zhishu-v1', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 18:54:54', '2026-08-26 18:54:54');
INSERT INTO `afv_ai_model` VALUES (33, 'wan3.0-video', 'wan3.0-video', NULL, NULL, 3, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 18:54:54', '2026-08-26 18:54:54');
INSERT INTO `afv_ai_model` VALUES (34, 'wan3.0-video-prime', 'wan3.0-video-prime', NULL, NULL, 3, NULL, NULL, 0, 1, NULL, 0, 5, 1, NULL, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-26 18:54:54', '2026-08-26 18:54:54');
INSERT INTO `afv_ai_model` VALUES (171, 'deepseek-v4-flash', 'deepseek-v4-flash', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 1, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (172, 'deepseek-v4-pro', 'deepseek-v4-pro', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (173, 'deepseek-v4-pro-202606', 'deepseek-v4-pro-202606', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (174, 'happyhorse-1.1-i2v', 'happyhorse-1.1-i2v', NULL, NULL, 3, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (175, 'happyhorse-1.1-r2v', 'happyhorse-1.1-r2v', NULL, NULL, 3, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (176, 'happyhorse-1.1-t2v', 'happyhorse-1.1-t2v', NULL, NULL, 3, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (177, 'HY-3D-3.0', 'HY-3D-3.0', NULL, NULL, 2, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (178, 'HY-3D-Component', 'HY-3D-Component', NULL, NULL, 2, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (179, 'HY-3D-Express', 'HY-3D-Express', NULL, NULL, 2, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (180, 'HY-Video-1.5', 'HY-Video-1.5', NULL, NULL, 3, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (181, 'HY-Vision-2.0-Instruct', 'HY-Vision-2.0-Instruct', NULL, NULL, 2, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (182, 'HY-Vision-Video', 'HY-Vision-Video', NULL, NULL, 3, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (183, 'hy3', 'hy3', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (184, 'Jimeng Video 3.0 Pro', 'jimeng-video-3.0-pro', 'jimeng', 'jimeng-video-3.0-pro', 3, NULL, NULL, 10, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (185, 'Kimi K3', 'Kimi K3', NULL, NULL, 2, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (186, 'kimi-k3', 'kimi-k3', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (187, 'Kling Video 1.6', 'kling-v1-6', 'kling', 'kling-v1-6-video', 3, NULL, NULL, 10, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (188, 'Kling Video 2.1', 'kling-v2-1', 'kling', 'kling-v2-1-video', 3, NULL, NULL, 10, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (189, 'Kling Video 2.5 Turbo', 'kling-v2-5-turbo', 'kling', 'kling-v2-5-turbo-video', 3, NULL, NULL, 10, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (190, 'MiniMax-M3', 'MiniMax-M3', NULL, NULL, 2, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (191, 'paraformer-v1', 'paraformer-v1', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (192, 'paraformer-v2', 'paraformer-v2', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (193, 'qwen-image-3.0', 'qwen-image-3.0', NULL, NULL, 2, NULL, NULL, 0, 1, NULL, 1, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (194, 'qwen-image-3.0-pro', 'qwen-image-3.0-pro', NULL, NULL, 2, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (195, 'qwen3.7-plus', 'qwen3.7-plus', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (196, 'qwen3.8-max', 'qwen3.8-max', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (197, 'sambert-zhida-v1', 'sambert-zhida-v1', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (198, 'sambert-zhide-v1', 'sambert-zhide-v1', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (199, 'sambert-zhishu-v1', 'sambert-zhishu-v1', NULL, NULL, 1, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (200, 'wan3.0-video', 'wan3.0-video', NULL, NULL, 3, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (201, 'wan3.0-video-prime', 'wan3.0-video-prime', NULL, NULL, 3, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (202, 'YT-Video-FX', 'YT-Video-FX', NULL, NULL, 3, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (203, 'YT-Video-HumanActor', 'YT-Video-HumanActor', NULL, NULL, 3, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');
INSERT INTO `afv_ai_model` VALUES (204, 'YT-VITA', 'YT-VITA', NULL, NULL, 2, NULL, NULL, 0, 1, NULL, 0, 5, 6, 3, NULL, 0, '[]', '{}', 0, '[]', NULL, 0, 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');

-- ----------------------------
-- Table structure for afv_api_config
-- ----------------------------
DROP TABLE IF EXISTS `afv_api_config`;
CREATE TABLE `afv_api_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置名称',
  `platform` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '平台标识：deepseek/dashscope/openai_compatible/ollama/anthropic/vertex_ai',
  `text_protocol` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '文本模型默认请求协议',
  `image_protocol` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图片模型默认请求协议',
  `video_protocol` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '视频模型默认请求协议',
  `api_type` int NULL DEFAULT NULL COMMENT 'API类型：1-文本对话 2-图片生成 3-视频生成',
  `api_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'API接口地址',
  `auto_append_v1_path` tinyint NOT NULL DEFAULT 1 COMMENT 'OpenAI兼容请求是否自动补充/v1路径',
  `proxy_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '出站代理类型：none/http/socks5',
  `proxy_host` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '出站代理主机',
  `proxy_port` int NULL DEFAULT NULL COMMENT '出站代理端口',
  `proxy_username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '出站代理认证用户名',
  `proxy_password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '出站代理认证密码',
  `api_key` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'API密钥',
  `app_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '应用ID（部分平台需要）',
  `app_secret` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '应用密钥/服务账号 JSON Key（部分平台需要，如 Vertex AI Service Account）',
  `model_id` bigint NULL DEFAULT NULL COMMENT '关联模型ID',
  `user_id` bigint NULL DEFAULT NULL COMMENT '归属用户ID；NULL表示全局配置',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态：0-禁用 1-启用',
  `remark` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注说明',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_api_config_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'API配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_api_config
-- ----------------------------
INSERT INTO `afv_api_config` VALUES (1, 'AI大模型', 'newapi', 'openai_compatible', 'newapi', 'newapi', NULL, 'https://gate.xinchyun.com', 1, NULL, NULL, NULL, NULL, NULL,NULL, '', '', NULL, NULL, 1, '', 0, '2026-08-25 20:26:21', '2026-08-25 20:26:21');
INSERT INTO `afv_api_config` VALUES (6, '我的配置', 'newapi', 'openai_compatible', 'newapi', 'newapi', NULL, 'https://gate.xinchyun.com', 1, NULL, NULL, NULL, NULL, NULL,NULL, '', '', NULL, 3, 1, '', 0, '2026-08-29 21:05:28', '2026-08-29 21:05:28');

-- ----------------------------
-- Table structure for afv_asset
-- ----------------------------
DROP TABLE IF EXISTS `afv_asset`;
CREATE TABLE `afv_asset`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NULL DEFAULT NULL COMMENT '创建者用户ID',
  `project_id` bigint NULL DEFAULT NULL COMMENT '所属项目ID',
  `type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '资产类型：character/scene/prop/vehicle/building/costume/effect',
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '资产名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '资产描述',
  `cover_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '封面图URL',
  `properties` json NULL COMMENT '动态属性JSON（如角色的appearance、age等）',
  `tags` json NULL COMMENT '标签列表JSON',
  `source_type` int NULL DEFAULT 1 COMMENT '来源类型：1-用户上传 2-AI生成',
  `ai_prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'AI生成时使用的提示词',
  `owner_type` int NULL DEFAULT NULL COMMENT '拥有者类型：1-个人 2-团队',
  `owner_id` bigint NULL DEFAULT NULL COMMENT '拥有者ID',
  `status` int NULL DEFAULT 1 COMMENT '状态：0-草稿 1-正常',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_asset_project`(`project_id` ASC) USING BTREE,
  INDEX `idx_asset_owner`(`owner_type` ASC, `owner_id` ASC) USING BTREE,
  INDEX `idx_asset_type`(`project_id` ASC, `type` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '资产表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_asset
-- ----------------------------

-- ----------------------------
-- Table structure for afv_asset_item
-- ----------------------------
DROP TABLE IF EXISTS `afv_asset_item`;
CREATE TABLE `afv_asset_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `asset_id` bigint NOT NULL COMMENT '所属主资产ID',
  `item_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '子资产类型：front/side/back/detail/expression/pose/variant/original',
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '子资产名称',
  `image_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图片URL',
  `thumbnail_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '缩略图URL',
  `properties` json NULL COMMENT '动态属性JSON',
  `sort_order` int NULL DEFAULT 0 COMMENT '排列顺序',
  `source_type` int NULL DEFAULT 1 COMMENT '来源类型：1-用户上传 2-AI生成',
  `ai_prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'AI生成时使用的提示词',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_asset_item_asset`(`asset_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '子资产表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_asset_item
-- ----------------------------

-- ----------------------------
-- Table structure for afv_comfyui_workflow
-- ----------------------------
DROP TABLE IF EXISTS `afv_comfyui_workflow`;
CREATE TABLE `afv_comfyui_workflow`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `api_config_id` bigint NOT NULL COMMENT 'ComfyUI 接口配置标识',
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '工作流显示名称',
  `code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '工作流稳定标识',
  `model_type` int NOT NULL COMMENT '模型类型：2-图片，3-视频',
  `description` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '工作流说明',
  `active_version_id` bigint NULL DEFAULT NULL COMMENT '当前发布的工作流版本标识',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  `deleted_id` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除隔离标识',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_comfyui_workflow_code`(`api_config_id` ASC, `code` ASC, `deleted_id` ASC) USING BTREE,
  INDEX `idx_comfyui_workflow_api_config`(`api_config_id` ASC, `status` ASC) USING BTREE,
  INDEX `idx_comfyui_workflow_active_version`(`active_version_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'ComfyUI 工作流' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_comfyui_workflow
-- ----------------------------

-- ----------------------------
-- Table structure for afv_comfyui_workflow_version
-- ----------------------------
DROP TABLE IF EXISTS `afv_comfyui_workflow_version`;
CREATE TABLE `afv_comfyui_workflow_version`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `workflow_id` bigint NOT NULL COMMENT '工作流标识',
  `version_no` int NOT NULL COMMENT '单调递增的版本号',
  `ui_workflow_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '可选的 ComfyUI 界面格式工作流',
  `api_workflow_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'ComfyUI 接口格式工作流',
  `input_bindings_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '平台输入绑定',
  `output_bindings_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '显式输出绑定',
  `required_nodes_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '必需节点类列表',
  `workflow_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT '规范化执行定义的哈希值',
  `validation_status` int NOT NULL DEFAULT 0 COMMENT '校验状态：0-未校验，1-有效，2-无效',
  `validation_message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '校验详情',
  `test_status` int NOT NULL DEFAULT 0 COMMENT '试运行状态：0-未试运行，1-通过，2-失败',
  `test_message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '试运行详情',
  `last_test_time` datetime NULL DEFAULT NULL COMMENT '最后试运行时间',
  `published` tinyint NOT NULL DEFAULT 0 COMMENT '此版本是否曾经发布',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标记',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_comfyui_workflow_version`(`workflow_id` ASC, `version_no` ASC) USING BTREE,
  INDEX `idx_comfyui_workflow_version_status`(`workflow_id` ASC, `validation_status` ASC, `test_status` ASC, `published` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '不可变的 ComfyUI 工作流版本' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_comfyui_workflow_version
-- ----------------------------

-- ----------------------------
-- Table structure for afv_image_item
-- ----------------------------
DROP TABLE IF EXISTS `afv_image_item`;
CREATE TABLE `afv_image_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `task_id` bigint NOT NULL COMMENT '所属生图任务ID',
  `platform_task_id` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '平台侧任务ID',
  `image_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '生成的图片URL',
  `thumbnail_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '缩略图URL',
  `width` int NULL DEFAULT NULL COMMENT '图片宽度（像素）',
  `height` int NULL DEFAULT NULL COMMENT '图片高度（像素）',
  `file_size` bigint NULL DEFAULT NULL COMMENT '文件大小（字节）',
  `status` int NULL DEFAULT 0 COMMENT '状态：0-生成中 1-成功 2-失败',
  `error_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '失败错误信息',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_image_item_task`(`task_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '生图条目表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_image_item
-- ----------------------------

-- ----------------------------
-- Table structure for afv_image_task
-- ----------------------------
DROP TABLE IF EXISTS `afv_image_task`;
CREATE TABLE `afv_image_task`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `task_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务唯一标识',
  `user_id` bigint NOT NULL COMMENT '发起用户ID',
  `project_id` bigint NULL DEFAULT NULL COMMENT '关联项目ID',
  `prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '生图提示词',
  `prompt_template_id` bigint NULL DEFAULT NULL COMMENT '提示词模板ID',
  `ref_image_urls` json NULL COMMENT '参考图片URL列表JSON',
  `ratio` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '画面比例（如16:9）',
  `resolution` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '分辨率（如1920x1080）',
  `aspect_ratio` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '宽高比描述',
  `width` int NULL DEFAULT NULL COMMENT '图片宽度（像素）',
  `height` int NULL DEFAULT NULL COMMENT '图片高度（像素）',
  `count` int NULL DEFAULT 1 COMMENT '生成数量',
  `success_count` int NULL DEFAULT 0 COMMENT '已成功生成数量',
  `status` int NULL DEFAULT 0 COMMENT '任务状态：0-排队中 1-处理中 2-已完成 3-失败',
  `error_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '失败错误信息',
  `model_id` bigint NULL DEFAULT NULL COMMENT '使用的AI模型ID',
  `workflow_version_id` bigint NULL DEFAULT NULL COMMENT '固定的 ComfyUI 工作流版本标识',
  `category` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务分类标签',
  `owner_type` int NULL DEFAULT NULL COMMENT '拥有者类型：1-个人 2-团队',
  `owner_id` bigint NULL DEFAULT NULL COMMENT '拥有者ID',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `task_id`(`task_id` ASC) USING BTREE,
  INDEX `idx_image_task_workflow_version`(`workflow_version_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '生图任务表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_image_task
-- ----------------------------

-- ----------------------------
-- Table structure for afv_project
-- ----------------------------
DROP TABLE IF EXISTS `afv_project`;
CREATE TABLE `afv_project`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '项目名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '项目描述',
  `cover_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '项目封面图URL',
  `scope` int NULL DEFAULT 2 COMMENT '可见范围：1-公开 2-私有 3-仅团队可见',
  `owner_type` int NOT NULL COMMENT '拥有者类型：1-个人 2-团队',
  `owner_id` bigint NOT NULL COMMENT '拥有者ID',
  `status` int NULL DEFAULT 0 COMMENT '状态：0-筹备中 1-进行中 2-已完成 3-已归档',
  `properties` json NULL COMMENT '扩展配置JSON',
  `art_style` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '画风key（预设key或custom）',
  `art_style_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '画风中文描述',
  `art_style_image_prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '画风英文提示词',
  `art_style_image_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '画风参考图路径',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '视频项目表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_project
-- ----------------------------
INSERT INTO `afv_project` VALUES (1, '影视演示项目', '这是一条内置的演示数据，帮助你快速了解用「云揽镜」完成一部短视频的完整流程。\n演示项目采用「宣传片」类型、16:9 画幅、写实画风，已内置示例剧本与示例分镜。\n\n上手步骤：\n1. 剧本：查看内置示例剧本，了解镜头脚本的写法；\n2. 分镜：剧本已拆分为示例分镜（含景别、镜头运动、画面描述与 AI 提示词）；\n3. 生成：进入「生视频」页，选择模型并粘贴分镜中的示例提示词，即可生成对应视频；\n4. 资产：生成的视频与图片会自动归档到本项目的资产库。\n\n本项目可任意修改，不影响系统。', NULL, 1, 1, 1, 1, '{\"demo\": true, \"type\": \"宣传片\", \"aspectRatio\": \"16:9\"}', 'realistic', NULL, NULL, NULL, 0, '2026-08-25 20:26:25', '2026-08-25 20:26:25');

-- ----------------------------
-- Table structure for afv_project_member
-- ----------------------------
DROP TABLE IF EXISTS `afv_project_member`;
CREATE TABLE `afv_project_member`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `project_id` bigint NOT NULL COMMENT '所属项目ID',
  `user_id` bigint NOT NULL COMMENT '成员用户ID',
  `role` int NOT NULL DEFAULT 3 COMMENT '成员角色：1-拥有者 2-管理员 3-普通成员',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_project_user`(`project_id` ASC, `user_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '项目成员表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_project_member
-- ----------------------------

-- ----------------------------
-- Table structure for afv_script
-- ----------------------------
DROP TABLE IF EXISTS `afv_script`;
CREATE TABLE `afv_script`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `project_id` bigint NOT NULL COMMENT '所属项目ID',
  `title` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '剧本标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '剧本正文内容（格式化后）',
  `raw_content` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '剧本原始内容（用户粘贴的原文）',
  `total_episodes` int NULL DEFAULT 0 COMMENT '总集数',
  `story_synopsis` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '故事梗概',
  `characters_json` json NULL COMMENT '角色列表JSON',
  `source_type` int NULL DEFAULT 0 COMMENT '来源类型：0-手动创建 1-文件导入 2-AI生成',
  `parsing_status` int NULL DEFAULT 0 COMMENT '解析状态：0-未解析 1-解析中 2-解析完成 3-解析失败',
  `parsing_progress` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '解析进度描述',
  `summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'AI生成的剧本摘要',
  `genre` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '剧本类型/题材',
  `target_audience` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '目标受众',
  `duration_estimate` int NULL DEFAULT NULL COMMENT '预估总时长（分钟）',
  `scope` int NULL DEFAULT 3 COMMENT '可见范围：1-公开 2-私有 3-仅团队可见',
  `owner_type` int NULL DEFAULT NULL COMMENT '拥有者类型：1-个人 2-团队',
  `owner_id` bigint NULL DEFAULT NULL COMMENT '拥有者ID',
  `ai_generated` tinyint NULL DEFAULT 0 COMMENT '是否由AI生成',
  `version` int NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `status` int NULL DEFAULT 0 COMMENT '状态：0-草稿 1-正常',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_script_project`(`project_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '剧本表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_script
-- ----------------------------
INSERT INTO `afv_script` VALUES (1, 1, '影视演示项目', NULL, '【城市印象 · 示例剧本】\n\n场景一 · 晨雾街角（外景 清晨 雨后）\n清晨的城市在薄雾中苏醒，雨水打湿的街道反射着霓虹灯光。一名行人撑伞穿过街角，镜头缓慢推进。（全景→中景）\n\n场景二 · 天台日出（外景 清晨）\n镜头越过城市天际线，晨光逐渐照亮远处高楼，云层被染成金色，航拍镜头缓缓拉升。（航拍全景）\n\n场景三 · 江畔夜景（外景 傍晚）\n傍晚的江边，城市灯光依次亮起，镜头跟随飞鸟掠过江面，定格在灯火辉煌的城市全景。（远景→全景）', 0, '以城市清晨到傍晚为线索，用三个镜头展现一座城市的苏醒与繁华。', NULL, 0, 0, NULL, NULL, NULL, NULL, NULL, 1, 1, 1, 0, 0, 1, 0, '2026-08-25 20:26:25', '2026-08-25 20:26:25');

-- ----------------------------
-- Table structure for afv_script_episode
-- ----------------------------
DROP TABLE IF EXISTS `afv_script_episode`;
CREATE TABLE `afv_script_episode`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `script_id` bigint NOT NULL COMMENT '所属剧本ID',
  `episode_number` int NULL DEFAULT NULL COMMENT '集号（从1开始）',
  `title` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '本集标题',
  `synopsis` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '本集剧情梗概',
  `raw_content` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '本集原始剧本内容',
  `duration_estimate` int NULL DEFAULT NULL COMMENT '预估时长（分钟）',
  `total_scenes` int NULL DEFAULT 0 COMMENT '本集总场次数',
  `source_type` int NULL DEFAULT 0 COMMENT '来源类型：0-AI解析 1-手动添加',
  `sort_order` int NULL DEFAULT 0 COMMENT '排列顺序',
  `parsing_status` int NULL DEFAULT 0 COMMENT '解析状态：0-未解析 1-解析中 2-解析完成 3-解析失败',
  `status` int NULL DEFAULT 0 COMMENT '状态：0-草稿 1-正常',
  `version` int NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_episode_script`(`script_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '分集剧本表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_script_episode
-- ----------------------------

-- ----------------------------
-- Table structure for afv_script_scene_item
-- ----------------------------
DROP TABLE IF EXISTS `afv_script_scene_item`;
CREATE TABLE `afv_script_scene_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `episode_id` bigint NOT NULL COMMENT '所属分集ID',
  `script_id` bigint NOT NULL COMMENT '所属剧本ID',
  `scene_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '场次编号（如1-1表示第1集第1场）',
  `scene_heading` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '场景标头（如\"内景 客厅 夜\"）',
  `location` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '场景地点',
  `time_of_day` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '时间段：日/夜/黄昏/清晨等',
  `int_ext` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '内外景标识：内景/外景/内外景',
  `characters` json NULL COMMENT '出场角色名列表JSON',
  `character_asset_ids` json NULL COMMENT '出场角色资产ID列表JSON',
  `scene_asset_id` bigint NULL DEFAULT NULL COMMENT '场景资产ID',
  `prop_asset_ids` json NULL COMMENT '道具资产ID列表JSON',
  `scene_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '场景氛围/环境描述',
  `dialogues` json NULL COMMENT '对白/动作元素列表JSON',
  `sort_order` int NULL DEFAULT 0 COMMENT '排列顺序',
  `status` int NULL DEFAULT 0 COMMENT '状态：0-草稿 1-正常',
  `version` int NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_script_scene_episode`(`episode_id` ASC) USING BTREE,
  INDEX `idx_script_scene_script`(`script_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '剧本分场次表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_script_scene_item
-- ----------------------------

-- ----------------------------
-- Table structure for afv_storage_config
-- ----------------------------
DROP TABLE IF EXISTS `afv_storage_config`;
CREATE TABLE `afv_storage_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置名称',
  `type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '存储类型：local / aliyun_oss / tencent_cos / s3',
  `provider` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'S3兼容厂商：generic_s3/aliyun_oss/tencent_cos/qiniu_kodo/ctyun_zos/minio',
  `endpoint` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'OSS 端点地址',
  `bucket_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'OSS 存储桶名称',
  `access_key` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'OSS Access Key',
  `secret_key` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'OSS Secret Key',
  `region` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '区域',
  `base_path` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '存储根路径（本地为磁盘路径，OSS 为 key 前缀）',
  `custom_domain` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '自定义域名（CDN 域名等）',
  `options` json NULL COMMENT '厂商扩展配置JSON',
  `is_default` tinyint NOT NULL DEFAULT 0 COMMENT '是否为默认存储配置',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态：0-禁用 1-启用',
  `remark` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '存储配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_storage_config
-- ----------------------------

-- ----------------------------
-- Table structure for afv_storyboard
-- ----------------------------
DROP TABLE IF EXISTS `afv_storyboard`;
CREATE TABLE `afv_storyboard`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `project_id` bigint NULL DEFAULT NULL COMMENT '所属项目ID',
  `script_id` bigint NULL DEFAULT NULL COMMENT '关联剧本ID',
  `title` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '分镜标题',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '分镜描述',
  `custom_columns` json NULL COMMENT '自定义列配置JSON',
  `scope` int NULL DEFAULT 3 COMMENT '可见范围：1-公开 2-私有 3-仅团队可见',
  `owner_type` int NULL DEFAULT NULL COMMENT '拥有者类型：1-个人 2-团队',
  `owner_id` bigint NULL DEFAULT NULL COMMENT '拥有者ID',
  `total_duration` int NULL DEFAULT NULL COMMENT '预估总时长（秒）',
  `status` int NULL DEFAULT 0 COMMENT '状态：0-草稿 1-正常',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_storyboard_project`(`project_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '分镜脚本表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_storyboard
-- ----------------------------
INSERT INTO `afv_storyboard` VALUES (1, 1, 1, '影视演示项目', '内置示例分镜：三个镜头，展示景别、镜头运动、画面描述与 AI 提示词的写法。', NULL, 1, 1, 1, NULL, 1, 0, '2026-08-25 20:26:25', '2026-08-25 20:26:25');

-- ----------------------------
-- Table structure for afv_storyboard_episode
-- ----------------------------
DROP TABLE IF EXISTS `afv_storyboard_episode`;
CREATE TABLE `afv_storyboard_episode`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `storyboard_id` bigint NOT NULL COMMENT '所属分镜ID',
  `script_episode_id` bigint NULL DEFAULT NULL COMMENT '关联的剧本分集ID',
  `episode_number` int NULL DEFAULT NULL COMMENT '集号',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '集标题',
  `synopsis` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '本集梗概',
  `sort_order` int NULL DEFAULT 0 COMMENT '排列顺序',
  `status` int NULL DEFAULT 0 COMMENT '状态：0-草稿 1-正常',
  `deleted` tinyint NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `deleted_id` bigint NOT NULL DEFAULT 0 COMMENT '逻辑删除隔离标识，0-未删除，删除后为记录ID',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `composed_video_url` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '本集合成视频URL',
  `compose_status` tinyint NOT NULL DEFAULT 0 COMMENT '合成状态: 0未开始 1合成中 2已完成 3失败',
  `compose_error_msg` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '合成失败原因',
  `composed_at` datetime NULL DEFAULT NULL COMMENT '合成完成时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_sb_episode_script_episode`(`storyboard_id` ASC, `script_episode_id` ASC, `deleted_id` ASC) USING BTREE,
  INDEX `idx_sb_episode_storyboard`(`storyboard_id` ASC) USING BTREE,
  INDEX `idx_sb_episode_script_episode`(`script_episode_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '分镜集表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_storyboard_episode
-- ----------------------------

-- ----------------------------
-- Table structure for afv_storyboard_item
-- ----------------------------
DROP TABLE IF EXISTS `afv_storyboard_item`;
CREATE TABLE `afv_storyboard_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `storyboard_id` bigint NOT NULL COMMENT '所属分镜ID',
  `storyboard_episode_id` bigint NULL DEFAULT NULL COMMENT '所属分镜集ID',
  `storyboard_scene_id` bigint NULL DEFAULT NULL COMMENT '所属分镜场次ID',
  `sort_order` int NULL DEFAULT 0 COMMENT '排列顺序',
  `shot_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '镜号',
  `auto_shot_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '自动编号（系统生成）',
  `image_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户上传参考图片URL',
  `reference_image_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '外部参考图片URL',
  `video_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '视频URL（最终成品）',
  `generated_image_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'AI生成的图片URL',
  `first_frame_image_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '首帧参考图片URL',
  `last_frame_image_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '尾帧参考图片URL',
  `first_frame_prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'AI生成首帧时使用的提示词',
  `last_frame_prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'AI生成尾帧时使用的提示词',
  `generated_video_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'AI生成的视频URL',
  `shot_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '景别：远景/全景/中景/近景/特写',
  `duration` decimal(10, 2) NULL DEFAULT NULL COMMENT '预估时长（秒）',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '画面内容描述',
  `scene_expectation` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '画面期望描述（AI生图提示）',
  `sound` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '声音描述',
  `dialogue` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '台词/旁白',
  `sound_effect` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '音效',
  `music` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '配乐建议',
  `camera_movement` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '镜头运动：推/拉/摇/移/跟/升/降',
  `camera_angle` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '镜头角度：平视/俯视/仰视',
  `camera_equipment` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '摄像机装备',
  `focal_length` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '镜头焦段',
  `transition` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '转场效果：切/淡入/淡出/溶/划',
  `character_ids` json NULL COMMENT '出场角色子资产ID列表 JSON (List<Long> of AssetItem.id)',
  `scene_asset_item_id` bigint NULL DEFAULT NULL COMMENT '场景子资产ID (AssetItem.id)',
  `prop_ids` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '道具子资产ID列表 JSON (List<Long> of AssetItem.id)',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '备注',
  `custom_data` json NULL COMMENT '自定义扩展数据JSON',
  `ai_generated` tinyint NULL DEFAULT 0 COMMENT '是否由AI生成',
  `status` int NULL DEFAULT 0 COMMENT '状态：0-草稿 1-正常',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `video_prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'AI生成视频时使用的提示词（保存以便复用和手动调整）',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_sb_item_storyboard`(`storyboard_id` ASC) USING BTREE,
  INDEX `idx_sb_item_scene`(`storyboard_scene_id` ASC) USING BTREE,
  INDEX `idx_sb_item_episode`(`storyboard_episode_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '分镜条目表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_storyboard_item
-- ----------------------------
INSERT INTO `afv_storyboard_item` VALUES (1, 1, NULL, NULL, 1, '1-1', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '全景', 5.00, '湿润街道反射霓虹，行人撑伞穿过街角', 'cinematic film still, rainy city street at dawn, neon reflections on wet asphalt, a pedestrian with an umbrella crossing, slow push-in, muted color grade, 16:9', '雨声、城市远处车流声', NULL, '雨声', '轻柔钢琴', '推', '平视', NULL, NULL, '切', NULL, NULL, NULL, NULL, NULL, 0, 1, 0, '2026-08-25 20:26:25', '2026-08-25 20:26:25', NULL);
INSERT INTO `afv_storyboard_item` VALUES (2, 1, NULL, NULL, 2, '1-2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '远景', 5.00, '云海晨光中的城市天际线，航拍拉升', 'aerial view over sea of clouds at sunrise, city skyline emerging, golden morning light, drone rising slowly, cinematic, 16:9', '风声、极轻的弦乐铺底', NULL, '风声', '弦乐', '升', '俯视', NULL, NULL, '溶', NULL, NULL, NULL, NULL, NULL, 0, 1, 0, '2026-08-25 20:26:25', '2026-08-25 20:26:25', NULL);
INSERT INTO `afv_storyboard_item` VALUES (3, 1, NULL, NULL, 3, '1-3', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '全景', 5.00, '蓝调时刻江畔夜景，城市灯光渐亮，飞鸟掠过', 'blue hour riverside cityscape, city lights turning on one by one, birds flying across the river, gentle pan, cinematic, 16:9', '江水声、远处城市白噪声', NULL, '江水声', '氛围电子', '摇', '平视', NULL, NULL, '切', NULL, NULL, NULL, NULL, NULL, 0, 1, 0, '2026-08-25 20:26:25', '2026-08-25 20:26:25', NULL);

-- ----------------------------
-- Table structure for afv_storyboard_scene
-- ----------------------------
DROP TABLE IF EXISTS `afv_storyboard_scene`;
CREATE TABLE `afv_storyboard_scene`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `episode_id` bigint NOT NULL COMMENT '所属分镜集ID',
  `storyboard_id` bigint NOT NULL COMMENT '所属分镜ID（冗余）',
  `scene_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '场次编号',
  `scene_heading` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '场景标头',
  `location` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '场景地点',
  `time_of_day` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '时间段',
  `int_ext` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '内外景标识',
  `sort_order` int NULL DEFAULT 0 COMMENT '排列顺序',
  `status` int NULL DEFAULT 0 COMMENT '状态：0-草稿 1-正常',
  `deleted` tinyint NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_sb_scene_episode`(`episode_id` ASC) USING BTREE,
  INDEX `idx_sb_scene_storyboard`(`storyboard_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '分镜场次表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_storyboard_scene
-- ----------------------------

-- ----------------------------
-- Table structure for afv_system_config
-- ----------------------------
DROP TABLE IF EXISTS `afv_system_config`;
CREATE TABLE `afv_system_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `config_key` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置键',
  `config_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '配置值',
  `remark` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_config_key`(`config_key` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_system_config
-- ----------------------------
INSERT INTO `afv_system_config` VALUES (1, 'allow_register', 'true', '是否允许公开注册', 0, '2026-08-03 02:11:43', '2026-08-03 02:11:43');
INSERT INTO `afv_system_config` VALUES (2, 'demo_project_id', '1', '演示项目ID（对所有用户可见，作为参考示例）', 0, '2026-08-25 20:26:25', '2026-08-25 20:26:25');
INSERT INTO `afv_system_config` VALUES (3, 'site_base_url', 'http://localhost:5000', NULL, 0, '2026-08-28 17:49:50', '2026-08-28 17:49:50');
INSERT INTO `afv_system_config` VALUES (4, 'resource_base_url', 'http://localhost:5000', NULL, 0, '2026-08-28 17:49:50', '2026-08-28 17:49:50');
INSERT INTO `afv_system_config` VALUES (5, 'allow_email_register', 'true', NULL, 0, '2026-08-28 17:49:50', '2026-08-29 21:07:11');
INSERT INTO `afv_system_config` VALUES (6, 'mail_smtp_host', 'smtp.163.com', NULL, 0, '2026-08-28 17:49:50', '2026-08-28 17:49:50');
INSERT INTO `afv_system_config` VALUES (7, 'mail_smtp_port', '465', NULL, 0, '2026-08-28 17:49:50', '2026-08-28 17:49:50');
INSERT INTO `afv_system_config` VALUES (8, 'mail_username', '', NULL, 0, '2026-08-28 17:49:50', '2026-08-28 17:49:50');
INSERT INTO `afv_system_config` VALUES (9, 'mail_password', '', NULL, 0, '2026-08-28 17:49:50', '2026-08-28 17:49:50');
INSERT INTO `afv_system_config` VALUES (10, 'mail_ssl', 'true', NULL, 0, '2026-08-28 17:49:50', '2026-08-28 17:49:50');
INSERT INTO `afv_system_config` VALUES (11, 'mail_from', '', NULL, 0, '2026-08-28 17:49:50', '2026-08-29 16:12:30');
INSERT INTO `afv_system_config` VALUES (12, 'model_use_global', 'false', '模型使用模式：true-所有用户统一使用全局模型；false-每个用户使用自己的私有模型', 0, '2026-08-29 19:58:32', '2026-08-29 19:58:32');

-- ----------------------------
-- Table structure for afv_team
-- ----------------------------
DROP TABLE IF EXISTS `afv_team`;
CREATE TABLE `afv_team`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '团队名称',
  `logo` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '团队LOGO图片URL',
  `description` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '团队描述',
  `owner_user_id` bigint NOT NULL COMMENT '创建者用户ID',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态：0-禁用 1-启用',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '团队表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_team
-- ----------------------------

-- ----------------------------
-- Table structure for afv_team_member
-- ----------------------------
DROP TABLE IF EXISTS `afv_team_member`;
CREATE TABLE `afv_team_member`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `team_id` bigint NOT NULL COMMENT '所属团队ID',
  `user_id` bigint NOT NULL COMMENT '成员用户ID',
  `role` int NOT NULL DEFAULT 3 COMMENT '角色：1-创建者 2-管理员 3-普通成员',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态：0-禁用 1-启用',
  `join_time` datetime NULL DEFAULT NULL COMMENT '加入时间',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_team_user`(`team_id` ASC, `user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '团队成员表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_team_member
-- ----------------------------

-- ----------------------------
-- Table structure for afv_video_item
-- ----------------------------
DROP TABLE IF EXISTS `afv_video_item`;
CREATE TABLE `afv_video_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `task_id` bigint NOT NULL COMMENT '所属生视频任务ID',
  `platform_task_id` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '平台侧任务ID',
  `video_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '生成的视频URL',
  `cover_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '视频封面图URL',
  `duration` int NULL DEFAULT NULL COMMENT '视频时长（秒）',
  `file_size` bigint NULL DEFAULT NULL COMMENT '文件大小（字节）',
  `status` int NULL DEFAULT 0 COMMENT '状态：0-生成中 1-成功 2-失败',
  `error_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '失败错误信息',
  `first_frame_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '视频首帧图片URL',
  `last_frame_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '视频尾帧图片URL',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_video_item_task`(`task_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '生视频条目表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_video_item
-- ----------------------------

-- ----------------------------
-- Table structure for afv_video_task
-- ----------------------------
DROP TABLE IF EXISTS `afv_video_task`;
CREATE TABLE `afv_video_task`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `task_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '任务唯一标识',
  `user_id` bigint NOT NULL COMMENT '发起用户ID',
  `project_id` bigint NULL DEFAULT NULL COMMENT '关联项目ID',
  `prompt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '生视频提示词',
  `prompt_template_id` bigint NULL DEFAULT NULL COMMENT '提示词模板ID',
  `generate_mode` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '生成模式：text2video/image2video',
  `first_frame_image_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '首帧参考图片URL',
  `last_frame_image_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '尾帧参考图片URL',
  `reference_image_urls` json NULL COMMENT '参考图片URL列表JSON',
  `reference_video_urls` json NULL COMMENT '参考视频URL列表 JSON',
  `reference_audio_urls` json NULL COMMENT '参考音频URL列表 JSON',
  `ratio` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '画面比例（如16:9）',
  `resolution` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '分辨率（如1920x1080）',
  `duration` int NULL DEFAULT NULL COMMENT '视频时长（秒）',
  `watermark` tinyint NULL DEFAULT 0 COMMENT '是否添加水印',
  `generate_audio` tinyint NULL DEFAULT 0 COMMENT '是否生成配音',
  `seed` bigint NULL DEFAULT NULL COMMENT '随机种子（用于复现）',
  `camera_fixed` tinyint NULL DEFAULT 0 COMMENT '是否固定镜头',
  `count` int NULL DEFAULT 1 COMMENT '生成数量',
  `success_count` int NULL DEFAULT 0 COMMENT '已成功生成数量',
  `status` int NULL DEFAULT 0 COMMENT '任务状态：0-排队中 1-处理中 2-已完成 3-失败',
  `error_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '失败错误信息',
  `model_id` bigint NULL DEFAULT NULL COMMENT '使用的AI模型ID',
  `workflow_version_id` bigint NULL DEFAULT NULL COMMENT '固定的 ComfyUI 工作流版本标识',
  `category` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '任务分类标签',
  `owner_type` int NULL DEFAULT NULL COMMENT '拥有者类型：1-个人 2-团队',
  `owner_id` bigint NULL DEFAULT NULL COMMENT '拥有者ID',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `task_id`(`task_id` ASC) USING BTREE,
  INDEX `idx_video_task_workflow_version`(`workflow_version_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '生视频任务表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of afv_video_task
-- ----------------------------

-- ----------------------------
-- ----------------------------

-- ----------------------------
-- ----------------------------

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '角色名称',
  `code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '角色代码标识（如 admin、user）',
  `sort` int NULL DEFAULT 0 COMMENT '排列顺序',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态：0-禁用 1-启用',
  `remark` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注说明',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `code`(`code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '角色表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '超级管理员', 'admin', 1, 1, '系统超级管理员', 0, '2026-04-16 16:03:20', '2026-04-16 16:03:20');
INSERT INTO `sys_role` VALUES (2, '普通用户', 'user', 2, 1, '默认用户角色', 0, '2026-04-16 16:03:20', '2026-04-16 16:03:20');

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '登录用户名（唯一）',
  `password` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '登录密码（BCrypt加密）',
  `nickname` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户昵称',
  `avatar` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像URL',
  `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '邮箱地址',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号码',
  `status` int NOT NULL DEFAULT 1 COMMENT '状态：0-禁用 1-启用',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user
-- ----------------------------

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_role`(`user_id` ASC, `role_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户角色关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
