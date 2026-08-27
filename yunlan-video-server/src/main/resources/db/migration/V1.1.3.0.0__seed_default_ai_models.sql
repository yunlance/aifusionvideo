-- 内置默认 AI 模型与 API 网关配置，供新用户开箱即用。
-- 幂等：已存在对应配置时不重复插入，支持重复执行。
-- 注意：API 密钥留空，由用户部署后自行填写；不内置任何真实密钥。

-- 1. 幂等插入默认 API 网关配置
INSERT INTO afv_api_config (
    name, platform, text_protocol, image_protocol, video_protocol, api_type,
    api_url, auto_append_v1_path, api_key, app_id, app_secret, status, remark, deleted, create_time, update_time
)
SELECT
    'AI大模型', 'newapi', 'openai_compatible', 'newapi', 'newapi', NULL,
    'https://gate.xinchyun.com', 1, '', '', '', 1, '', 0, NOW(), NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM afv_api_config WHERE name = 'AI大模型' AND deleted = 0
);

-- 2. 解析 API 配置 ID（无论本次是否新插入，都解析到已有记录）
SET @api_config_id := COALESCE(
    (SELECT id FROM afv_api_config WHERE name = 'AI大模型' AND deleted = 0 ORDER BY id LIMIT 1),
    0
);

-- 3. 幂等插入默认 AI 模型（关联到上述 API 配置）
INSERT INTO afv_ai_model (
    name, code, model_type, sort, status, config, default_model, max_concurrency, api_config_id,
    support_vision, multimodal_input_types, multimodal_input_transports, support_reasoning,
    reasoning_effort_levels, deleted, deleted_id, create_time, update_time
)
SELECT m.name, m.code, m.model_type, m.sort, m.status, NULL, m.default_model, m.max_concurrency,
       @api_config_id, 0, '[]', '{}', 0, '[]', 0, 0, NOW(), NOW()
FROM (
    SELECT 'deepseek-v4-flash' AS name, 'deepseek-v4-flash' AS code, 1 AS model_type, 0 AS sort, 1 AS status, 1 AS default_model, 5 AS max_concurrency
    UNION ALL SELECT 'deepseek-v4-pro', 'deepseek-v4-pro', 1, 0, 1, 0, 5
    UNION ALL SELECT 'deepseek-v4-pro-202606', 'deepseek-v4-pro-202606', 1, 0, 1, 0, 5
    UNION ALL SELECT 'hy3', 'hy3', 1, 0, 1, 0, 5
    UNION ALL SELECT 'kimi-k3', 'kimi-k3', 1, 0, 1, 0, 5
    UNION ALL SELECT 'qwen-image-3.0', 'qwen-image-3.0', 2, 0, 1, 1, 5
    UNION ALL SELECT 'qwen-image-3.0-pro', 'qwen-image-3.0-pro', 2, 0, 1, 0, 5
    UNION ALL SELECT 'qwen3.7-plus', 'qwen3.7-plus', 1, 0, 1, 0, 5
    UNION ALL SELECT 'qwen3.8-max', 'qwen3.8-max', 1, 0, 1, 0, 5
) AS m
WHERE @api_config_id > 0
  AND NOT EXISTS (
      SELECT 1 FROM afv_ai_model WHERE api_config_id = @api_config_id AND deleted = 0
  );
