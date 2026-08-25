-- 补全演示项目工作区数据：剧本分集/场次、分镜分集/场次，并将既有演示镜头绑定到分镜场次。
-- 前置依赖：V1.1.2.0.0 已创建演示项目、示例剧本与示例分镜（顶层容器）。
-- 幂等：已存在对应层级数据时不重复插入，可重复执行。

-- 1. 解析演示项目
SET @demo_project_id := COALESCE(
    (SELECT id FROM afv_project WHERE properties->>'$.demo' = 'true' AND deleted = 0 ORDER BY id LIMIT 1),
    0
);

-- 2. 解析演示剧本
SET @demo_script_id := COALESCE(
    (SELECT id FROM afv_script WHERE project_id = @demo_project_id AND deleted = 0 ORDER BY id LIMIT 1),
    0
);

-- 3. 幂等插入演示剧本分集（第 1 集）
INSERT INTO afv_script_episode (
    script_id, episode_number, title, synopsis, raw_content, duration_estimate,
    total_scenes, source_type, sort_order, parsing_status, status, version, deleted, create_time, update_time
)
SELECT
    @demo_script_id, 1, '第 1 集',
    '以城市清晨到傍晚为线索，用三个镜头展现一座城市的苏醒与繁华。',
    CONCAT(
        '场景一 · 晨雾街角（外景 清晨 雨后）\n',
        '清晨的城市在薄雾中苏醒，雨水打湿的街道反射着霓虹灯光。一名行人撑伞穿过街角，镜头缓慢推进。（全景→中景）\n\n',
        '场景二 · 天台日出（外景 清晨）\n',
        '镜头越过城市天际线，晨光逐渐照亮远处高楼，云层被染成金色，航拍镜头缓缓拉升。（航拍全景）\n\n',
        '场景三 · 江畔夜景（外景 傍晚）\n',
        '傍晚的江边，城市灯光依次亮起，镜头跟随飞鸟掠过江面，定格在灯火辉煌的城市全景。（远景→全景）'
    ),
    0, 3, 0, 0, 2, 1, 0, 0, NOW(), NOW()
WHERE @demo_script_id > 0
  AND NOT EXISTS (
      SELECT 1 FROM afv_script_episode WHERE script_id = @demo_script_id AND deleted = 0
  );

-- 4. 解析演示剧本分集
SET @demo_script_episode_id := COALESCE(
    (SELECT id FROM afv_script_episode WHERE script_id = @demo_script_id AND deleted = 0 ORDER BY id LIMIT 1),
    0
);

-- 5. 幂等插入演示剧本场次（3 个场景）
INSERT INTO afv_script_scene_item (
    episode_id, script_id, scene_number, scene_heading, location, time_of_day, int_ext,
    scene_description, sort_order, status, version, deleted, create_time, update_time
)
SELECT s.episode_id, s.script_id, s.scene_number, s.scene_heading, s.location, s.time_of_day, s.int_ext,
       s.scene_description, s.sort_order, 1, 0, 0, NOW(), NOW()
FROM (
    SELECT @demo_script_episode_id AS episode_id, @demo_script_id AS script_id,
           '1-1' AS scene_number, '外景 晨雾街角 清晨' AS scene_heading, '晨雾街角' AS location,
           '清晨' AS time_of_day, '外景' AS int_ext,
           '雨后的街道反射着霓虹灯光，一名行人撑伞穿过街角，镜头缓慢推进，雾气在灯光下氤氲。' AS scene_description,
           0 AS sort_order
    UNION ALL
    SELECT @demo_script_episode_id, @demo_script_id, '1-2', '外景 天台日出 清晨', '城市天台', '清晨', '外景',
           '镜头越过城市天际线，晨光逐渐照亮远处高楼，云层被染成金色，航拍镜头缓缓拉升。', 1
    UNION ALL
    SELECT @demo_script_episode_id, @demo_script_id, '1-3', '外景 江畔夜景 傍晚', '江畔', '傍晚', '外景',
           '傍晚的江边，城市灯光依次亮起，镜头跟随飞鸟掠过江面，定格在灯火辉煌的城市全景。', 2
) AS s
WHERE @demo_script_episode_id > 0
  AND NOT EXISTS (
      SELECT 1 FROM afv_script_scene_item WHERE episode_id = @demo_script_episode_id AND deleted = 0
  );

-- 6. 解析演示分镜
SET @demo_storyboard_id := COALESCE(
    (SELECT id FROM afv_storyboard WHERE project_id = @demo_project_id AND deleted = 0 ORDER BY id LIMIT 1),
    0
);

-- 7. 幂等插入演示分镜集（第 1 集，绑定剧本分集）
INSERT INTO afv_storyboard_episode (
    storyboard_id, script_episode_id, episode_number, title, synopsis, sort_order, status,
    deleted, deleted_id, compose_status, create_time, update_time
)
SELECT
    @demo_storyboard_id, @demo_script_episode_id, 1, '第 1 集',
    '以城市清晨到傍晚为线索，用三个镜头展现一座城市的苏醒与繁华。',
    0, 1, 0, 0, 0, NOW(), NOW()
WHERE @demo_storyboard_id > 0
  AND @demo_script_episode_id > 0
  AND NOT EXISTS (
      SELECT 1 FROM afv_storyboard_episode WHERE storyboard_id = @demo_storyboard_id AND deleted = 0
  );

-- 8. 解析演示分镜集
SET @demo_storyboard_episode_id := COALESCE(
    (SELECT id FROM afv_storyboard_episode WHERE storyboard_id = @demo_storyboard_id AND deleted = 0 ORDER BY id LIMIT 1),
    0
);

-- 9. 幂等插入演示分镜场次（3 个场景）
INSERT INTO afv_storyboard_scene (
    episode_id, storyboard_id, scene_number, scene_heading, location, time_of_day, int_ext,
    sort_order, status, deleted, create_time, update_time
)
SELECT s.episode_id, s.storyboard_id, s.scene_number, s.scene_heading, s.location, s.time_of_day, s.int_ext,
       s.sort_order, 1, 0, NOW(), NOW()
FROM (
    SELECT @demo_storyboard_episode_id AS episode_id, @demo_storyboard_id AS storyboard_id,
           '1-1' AS scene_number, '外景 晨雾街角 清晨' AS scene_heading, '晨雾街角' AS location,
           '清晨' AS time_of_day, '外景' AS int_ext, 0 AS sort_order
    UNION ALL
    SELECT @demo_storyboard_episode_id, @demo_storyboard_id, '1-2', '外景 天台日出 清晨', '城市天台', '清晨', '外景', 1
    UNION ALL
    SELECT @demo_storyboard_episode_id, @demo_storyboard_id, '1-3', '外景 江畔夜景 傍晚', '江畔', '傍晚', '外景', 2
) AS s
WHERE @demo_storyboard_episode_id > 0
  AND NOT EXISTS (
      SELECT 1 FROM afv_storyboard_scene WHERE episode_id = @demo_storyboard_episode_id AND deleted = 0
  );

-- 10. 将既有演示镜头绑定到分镜集与场次（按镜号匹配场次编号）
UPDATE afv_storyboard_item i
JOIN afv_storyboard_scene s
  ON s.storyboard_id = i.storyboard_id
 AND s.scene_number = i.shot_number
 AND s.deleted = 0
SET i.storyboard_episode_id = s.episode_id,
    i.storyboard_scene_id = s.id,
    i.update_time = NOW()
WHERE i.storyboard_id = @demo_storyboard_id
  AND i.deleted = 0
  AND (i.storyboard_episode_id IS NULL OR i.storyboard_scene_id IS NULL)
  AND s.episode_id = @demo_storyboard_episode_id;

-- 11. 同步演示剧本总集数
UPDATE afv_script
SET total_episodes = 1, update_time = NOW()
WHERE id = @demo_script_id AND total_episodes = 0 AND deleted = 0;
