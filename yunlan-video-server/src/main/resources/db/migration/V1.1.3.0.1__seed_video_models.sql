-- 内置默认视频生成模型（可灵 / 即梦），供新用户开箱即用。
-- 幂等：已存在对应配置时不重复插入，支持重复执行。
-- 说明：仅内置「云揽川网关已实现视频生成适配器」的平台（可灵 kling、即梦 jimeng）。
--       混元（HY-Video）、YT 等网关尚未支持视频生成的平台，不在此内置。

-- 1. 解析 API 配置 ID（无论是否已存在，都解析到 AI大模型 网关记录）
SET @api_config_id := COALESCE(
    (SELECT id FROM afv_api_config WHERE name = 'AI大模型' AND deleted = 0 ORDER BY id LIMIT 1),
    0
);

-- 2. 幂等插入视频模型
--    model_protocol：决定专用协议路由（kling -> /kling/v1/videos/...，jimeng -> 即梦协议）
--    capability_preset_code：绑定内置能力预设，自动补全时长/分辨率/帧率等参数
INSERT INTO afv_ai_model (
    name, code, model_protocol, capability_preset_code, model_type, sort, status, config,
    default_model, max_concurrency, api_config_id, support_vision, multimodal_input_types,
    multimodal_input_transports, support_reasoning, reasoning_effort_levels, deleted, deleted_id,
    create_time, update_time
)
SELECT m.name, m.code, m.protocol, m.preset, 3, 10, 1, NULL, 0, 5, @api_config_id,
       0, '[]', '{}', 0, '[]', 0, 0, NOW(), NOW()
FROM (
    SELECT 'Kling Video 1.6' AS name, 'kling-v1-6' AS code, 'kling' AS protocol, 'kling-v1-6-video' AS preset
    UNION ALL SELECT 'Kling Video 2.1', 'kling-v2-1', 'kling', 'kling-v2-1-video'
    UNION ALL SELECT 'Kling Video 2.5 Turbo', 'kling-v2-5-turbo', 'kling', 'kling-v2-5-turbo-video'
    UNION ALL SELECT 'Jimeng Video 3.0 Pro', 'jimeng-video-3.0-pro', 'jimeng', 'jimeng-video-3.0-pro'
) AS m
WHERE @api_config_id > 0
  AND NOT EXISTS (
      SELECT 1 FROM afv_ai_model WHERE api_config_id = @api_config_id AND code = m.code AND deleted = 0
  );
