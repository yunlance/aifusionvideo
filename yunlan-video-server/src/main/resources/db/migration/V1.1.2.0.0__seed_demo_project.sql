-- 内置影视演示项目：包含演示说明、示例剧本与示例分镜，供用户参考上手。
-- 幂等：已存在演示项目时不重复插入，并支持重复执行。

-- 1. 找到初始化管理员用户作为演示项目归属人
SET @demo_owner_user_id := (
    SELECT su.id
    FROM sys_user su
    INNER JOIN sys_user_role sur ON sur.user_id = su.id
    INNER JOIN sys_role sr ON sr.id = sur.role_id
    WHERE sr.code = 'admin'
    ORDER BY su.id
    LIMIT 1
);

-- 2. 幂等插入演示项目
INSERT INTO afv_project (
    name, description, cover_url, scope, owner_type, owner_id, status,
    properties, art_style, deleted, create_time, update_time
)
SELECT
    '影视演示项目',
    CONCAT(
        '这是一条内置的演示数据，帮助你快速了解用「云揽镜」完成一部短视频的完整流程。\n',
        '演示项目采用「宣传片」类型、16:9 画幅、写实画风，已内置示例剧本与示例分镜。\n\n',
        '上手步骤：\n',
        '1. 剧本：查看内置示例剧本，了解镜头脚本的写法；\n',
        '2. 分镜：剧本已拆分为示例分镜（含景别、镜头运动、画面描述与 AI 提示词）；\n',
        '3. 生成：进入「生视频」页，选择模型并粘贴分镜中的示例提示词，即可生成对应视频；\n',
        '4. 资产：生成的视频与图片会自动归档到本项目的资产库。\n\n',
        '本项目可任意修改，不影响系统。'
    ),
    NULL, 1, 1, su.id, 1,
    '{"type":"宣传片","aspectRatio":"16:9","demo":true}', 'realistic', 0, NOW(), NOW()
FROM sys_user su
WHERE su.id = @demo_owner_user_id
  AND NOT EXISTS (
      SELECT 1 FROM afv_project WHERE properties->>'$.demo' = 'true'
  );

-- 取演示项目 ID（无论本次是否新插入，都解析到已有记录）
SET @demo_project_id := COALESCE(
    (SELECT id FROM afv_project WHERE properties->>'$.demo' = 'true' ORDER BY id LIMIT 1),
    0
);

-- 3. 幂等插入演示剧本
INSERT INTO afv_script (
    project_id, title, content, raw_content, total_episodes, story_synopsis,
    source_type, parsing_status, scope, owner_type, owner_id, status, deleted, create_time, update_time
)
SELECT
    @demo_project_id,
    '影视演示项目',
    NULL,
    CONCAT(
        '【城市印象 · 示例剧本】\n\n',
        '场景一 · 晨雾街角（外景 清晨 雨后）\n',
        '清晨的城市在薄雾中苏醒，雨水打湿的街道反射着霓虹灯光。一名行人撑伞穿过街角，镜头缓慢推进。（全景→中景）\n\n',
        '场景二 · 天台日出（外景 清晨）\n',
        '镜头越过城市天际线，晨光逐渐照亮远处高楼，云层被染成金色，航拍镜头缓缓拉升。（航拍全景）\n\n',
        '场景三 · 江畔夜景（外景 傍晚）\n',
        '傍晚的江边，城市灯光依次亮起，镜头跟随飞鸟掠过江面，定格在灯火辉煌的城市全景。（远景→全景）'
    ),
    0, '以城市清晨到傍晚为线索，用三个镜头展现一座城市的苏醒与繁华。',
    0, 0, 1, 1, @demo_owner_user_id, 1, 0, NOW(), NOW()
WHERE @demo_project_id > 0
  AND NOT EXISTS (
      SELECT 1 FROM afv_script WHERE project_id = @demo_project_id
  );

SET @demo_script_id := COALESCE(
    (SELECT id FROM afv_script WHERE project_id = @demo_project_id ORDER BY id LIMIT 1),
    0
);

-- 4. 幂等插入演示分镜
INSERT INTO afv_storyboard (
    project_id, script_id, title, description, scope, owner_type, owner_id, status, deleted, create_time, update_time
)
SELECT
    @demo_project_id, @demo_script_id, '影视演示项目',
    '内置示例分镜：三个镜头，展示景别、镜头运动、画面描述与 AI 提示词的写法。',
    1, 1, @demo_owner_user_id, 1, 0, NOW(), NOW()
WHERE @demo_project_id > 0
  AND NOT EXISTS (
      SELECT 1 FROM afv_storyboard WHERE project_id = @demo_project_id
  );

SET @demo_storyboard_id := COALESCE(
    (SELECT id FROM afv_storyboard WHERE project_id = @demo_project_id ORDER BY id LIMIT 1),
    0
);

-- 5. 幂等插入示例分镜条目（3 个镜头）
INSERT INTO afv_storyboard_item (
    storyboard_id, sort_order, shot_number, shot_type, duration, content, scene_expectation,
    sound, dialogue, sound_effect, music, camera_movement, camera_angle, transition,
    status, deleted, create_time, update_time
)
SELECT demo_items.storyboard_id, demo_items.sort_order, demo_items.shot_number, demo_items.shot_type,
       demo_items.duration, demo_items.content, demo_items.scene_expectation,
       demo_items.sound, demo_items.dialogue, demo_items.sound_effect, demo_items.music,
       demo_items.camera_movement, demo_items.camera_angle, demo_items.transition,
       demo_items.status, 0, NOW(), NOW()
FROM (
    SELECT @demo_storyboard_id AS storyboard_id, 1 AS sort_order, '1-1' AS shot_number, '全景' AS shot_type,
           5.00 AS duration, '湿润街道反射霓虹，行人撑伞穿过街角' AS content,
           'cinematic film still, rainy city street at dawn, neon reflections on wet asphalt, a pedestrian with an umbrella crossing, slow push-in, muted color grade, 16:9' AS scene_expectation,
           '雨声、城市远处车流声' AS sound, NULL AS dialogue, '雨声' AS sound_effect, '轻柔钢琴' AS music,
           '推' AS camera_movement, '平视' AS camera_angle, '切' AS transition, 1 AS status
    UNION ALL
    SELECT @demo_storyboard_id, 2, '1-2', '远景',
           5.00, '云海晨光中的城市天际线，航拍拉升',
           'aerial view over sea of clouds at sunrise, city skyline emerging, golden morning light, drone rising slowly, cinematic, 16:9',
           '风声、极轻的弦乐铺底', NULL, '风声', '弦乐',
           '升', '俯视', '溶', 1
    UNION ALL
    SELECT @demo_storyboard_id, 3, '1-3', '全景',
           5.00, '蓝调时刻江畔夜景，城市灯光渐亮，飞鸟掠过',
           'blue hour riverside cityscape, city lights turning on one by one, birds flying across the river, gentle pan, cinematic, 16:9',
           '江水声、远处城市白噪声', NULL, '江水声', '氛围电子',
           '摇', '平视', '切', 1
) AS demo_items
WHERE @demo_storyboard_id > 0
  AND NOT EXISTS (
      SELECT 1 FROM afv_storyboard_item WHERE storyboard_id = @demo_storyboard_id
  );

-- 6. 记录演示项目 ID 到系统配置（供后端对任意用户放行可见）
INSERT INTO afv_system_config (config_key, config_value, remark, deleted, create_time, update_time)
SELECT 'demo_project_id', CAST(@demo_project_id AS CHAR), '演示项目ID（对所有用户可见，作为参考示例）', 0, NOW(), NOW()
WHERE @demo_project_id > 0
  AND NOT EXISTS (
      SELECT 1 FROM afv_system_config WHERE config_key = 'demo_project_id'
  );
