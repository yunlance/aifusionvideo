-- 扩充演示项目工作区数据：新增第 2 集（市井烟火）及其剧本场次、分镜集/场次/镜头，使演示内容更丰富。
-- 前置依赖：V1.1.2.0.0 已创建演示项目、示例剧本与示例分镜（顶层容器）；V1.1.2.0.1 已补齐第 1 集层级。
-- 幂等：已存在对应数据时不重复插入，可重复执行。

-- 1. 解析演示项目 / 剧本 / 分镜（不依赖上一迁移的会话变量）
SET @demo_project_id := COALESCE(
    (SELECT id FROM afv_project WHERE properties->>'$.demo' = 'true' AND deleted = 0 ORDER BY id LIMIT 1),
    0
);
SET @demo_script_id := COALESCE(
    (SELECT id FROM afv_script WHERE project_id = @demo_project_id AND deleted = 0 ORDER BY id LIMIT 1),
    0
);
SET @demo_storyboard_id := COALESCE(
    (SELECT id FROM afv_storyboard WHERE project_id = @demo_project_id AND deleted = 0 ORDER BY id LIMIT 1),
    0
);

-- 2. 幂等插入演示剧本分集（第 2 集 · 市井烟火）
INSERT INTO afv_script_episode (
    script_id, episode_number, title, synopsis, raw_content, duration_estimate,
    total_scenes, source_type, sort_order, parsing_status, status, version, deleted, create_time, update_time
)
SELECT
    @demo_script_id, 2, '第 2 集 · 市井烟火',
    '从一碗面开始，记录普通人清晨到黄昏的烟火日常。',
    CONCAT(
        '场景一 · 老街面馆（内景 清晨）\n',
        '面馆热气蒸腾，老板娘与常客寒暄，镜头从中景带入市井温度，一句「老规矩，加辣？」点出熟稔。（中景）\n\n',
        '场景二 · 社区菜市（外景 上午）\n',
        '菜市场人声鼎沸，摊主吆喝、顾客讨价还价，镜头以全景铺陈最鲜活的烟火气。（全景→摇）\n\n',
        '场景三 · 地铁口（外景 黄昏）\n',
        '黄昏下班人流如织，主角汇入人群走向地铁，镜头拉远收束一日，留白余韵。（远景→淡出）'
    ),
    0, 3, 0, 1, 2, 1, 0, 0, NOW(), NOW()
WHERE @demo_script_id > 0
  AND NOT EXISTS (
      SELECT 1 FROM afv_script_episode WHERE script_id = @demo_script_id AND episode_number = 2 AND deleted = 0
  );

-- 3. 解析第 2 集剧本分集
SET @demo_script_episode2_id := COALESCE(
    (SELECT id FROM afv_script_episode WHERE script_id = @demo_script_id AND episode_number = 2 AND deleted = 0 ORDER BY id LIMIT 1),
    0
);

-- 4. 幂等插入演示剧本场次（第 2 集 3 个场景）
INSERT INTO afv_script_scene_item (
    episode_id, script_id, scene_number, scene_heading, location, time_of_day, int_ext,
    scene_description, sort_order, status, version, deleted, create_time, update_time
)
SELECT s.episode_id, s.script_id, s.scene_number, s.scene_heading, s.location, s.time_of_day, s.int_ext,
       s.scene_description, s.sort_order, 1, 0, 0, NOW(), NOW()
FROM (
    SELECT @demo_script_episode2_id AS episode_id, @demo_script_id AS script_id,
           '2-1' AS scene_number, '内景 面馆 清晨' AS scene_heading, '老街面馆' AS location,
           '清晨' AS time_of_day, '内景' AS int_ext,
           '面馆热气蒸腾，老板娘擦着桌子与常客寒暄，镜头从中景带入市井温度，一句「老规矩，加辣？」点出熟稔。' AS scene_description,
           0 AS sort_order
    UNION ALL
    SELECT @demo_script_episode2_id, @demo_script_id, '2-2', '外景 菜市场 上午', '社区菜市', '上午', '外景',
           '菜市场人声鼎沸，摊主吆喝、顾客讨价还价，镜头以全景铺陈最鲜活的烟火气。', 1
    UNION ALL
    SELECT @demo_script_episode2_id, @demo_script_id, '2-3', '外景 街口 黄昏', '地铁口', '黄昏', '外景',
           '黄昏下班人流如织，主角汇入人群走向地铁，镜头拉远收束一日，留白余韵。', 2
) AS s
WHERE @demo_script_episode2_id > 0
  AND NOT EXISTS (
      SELECT 1 FROM afv_script_scene_item WHERE episode_id = @demo_script_episode2_id AND deleted = 0
  );

-- 5. 幂等插入演示分镜集（第 2 集，绑定剧本分集）
INSERT INTO afv_storyboard_episode (
    storyboard_id, script_episode_id, episode_number, title, synopsis, sort_order, status,
    deleted, deleted_id, compose_status, create_time, update_time
)
SELECT
    @demo_storyboard_id, @demo_script_episode2_id, 2, '第 2 集 · 市井烟火',
    '从一碗面开始，记录普通人清晨到黄昏的烟火日常。',
    1, 1, 0, 0, 0, NOW(), NOW()
WHERE @demo_storyboard_id > 0
  AND @demo_script_episode2_id > 0
  AND NOT EXISTS (
      SELECT 1 FROM afv_storyboard_episode WHERE storyboard_id = @demo_storyboard_id AND episode_number = 2 AND deleted = 0
  );

-- 6. 解析第 2 集分镜集
SET @demo_storyboard_episode2_id := COALESCE(
    (SELECT id FROM afv_storyboard_episode WHERE storyboard_id = @demo_storyboard_id AND episode_number = 2 AND deleted = 0 ORDER BY id LIMIT 1),
    0
);

-- 7. 幂等插入演示分镜场次（第 2 集 3 个场景）
INSERT INTO afv_storyboard_scene (
    episode_id, storyboard_id, scene_number, scene_heading, location, time_of_day, int_ext,
    sort_order, status, deleted, create_time, update_time
)
SELECT s.episode_id, s.storyboard_id, s.scene_number, s.scene_heading, s.location, s.time_of_day, s.int_ext,
       s.sort_order, 1, 0, NOW(), NOW()
FROM (
    SELECT @demo_storyboard_episode2_id AS episode_id, @demo_storyboard_id AS storyboard_id,
           '2-1' AS scene_number, '内景 面馆 清晨' AS scene_heading, '老街面馆' AS location,
           '清晨' AS time_of_day, '内景' AS int_ext, 0 AS sort_order
    UNION ALL
    SELECT @demo_storyboard_episode2_id, @demo_storyboard_id, '2-2', '外景 菜市场 上午', '社区菜市', '上午', '外景', 1
    UNION ALL
    SELECT @demo_storyboard_episode2_id, @demo_storyboard_id, '2-3', '外景 街口 黄昏', '地铁口', '黄昏', '外景', 2
) AS s
WHERE @demo_storyboard_episode2_id > 0
  AND NOT EXISTS (
      SELECT 1 FROM afv_storyboard_scene WHERE episode_id = @demo_storyboard_episode2_id AND deleted = 0
  );

-- 8. 幂等插入演示分镜镜头（第 2 集 3 个镜头，按场次编号绑定分镜场次）
INSERT INTO afv_storyboard_item (
    storyboard_id, storyboard_episode_id, storyboard_scene_id, sort_order, shot_number, shot_type, duration,
    content, scene_expectation, sound, dialogue, sound_effect, music, camera_movement, camera_angle, transition,
    status, deleted, create_time, update_time
)
SELECT
    @demo_storyboard_id, @demo_storyboard_episode2_id, sc.id,
    it.sort_order, it.shot_number, it.shot_type, it.duration,
    it.content, it.scene_expectation, it.sound, it.dialogue, it.sound_effect, it.music,
    it.camera_movement, it.camera_angle, it.transition,
    1, 0, NOW(), NOW()
FROM (
    SELECT '2-1' AS scene_number, 1 AS sort_order, '2-1' AS shot_number, '中景' AS shot_type, 5.00 AS duration,
           '面馆里热气蒸腾，老板娘擦着桌子与常客寒暄' AS content,
           'cozy noodle shop interior, steam rising, warm morning light, a shopkeeper chatting with a regular, medium shot, cinematic, 16:9' AS scene_expectation,
           '碗筷碰撞声、远处叫卖' AS sound, '老板娘：「老规矩，加辣？」' AS dialogue, '碗筷声' AS sound_effect, '轻快吉他' AS music,
           '固定' AS camera_movement, '平视' AS camera_angle, '切' AS transition
    UNION ALL
    SELECT '2-2', 2, '2-2', '全景', 5.00, '菜市场人群熙攘，摊主吆喝、顾客讨价还价',
           'busy morning market, vendors shouting, crowd bargaining, overhead wide shot, vibrant colors, cinematic, 16:9',
           '嘈杂人声、叫卖', '摊主：「新鲜青菜，便宜卖咯！」', '叫卖声', '市集氛围',
           '摇', '俯视', '切'
    UNION ALL
    SELECT '2-3', 3, '2-3', '远景', 5.00, '黄昏下班人流如织，主角汇入人群走向地铁',
           'golden hour city street, commuters flooding out, protagonist merging into crowd toward subway, wide shot, cinematic, 16:9',
           '地铁报站、脚步声', '主角（画外）：「又是普通的一天。」', '脚步声', '舒缓弦乐',
           '跟', '平视', '淡出'
) AS it
JOIN afv_storyboard_scene sc
  ON sc.episode_id = @demo_storyboard_episode2_id AND sc.scene_number = it.scene_number AND sc.deleted = 0
WHERE @demo_storyboard_id > 0
  AND @demo_storyboard_episode2_id > 0
  AND NOT EXISTS (
      SELECT 1 FROM afv_storyboard_item WHERE storyboard_id = @demo_storyboard_id AND shot_number IN ('2-1', '2-2', '2-3') AND deleted = 0
  );

-- 9. 同步演示剧本总集数为 2
UPDATE afv_script
SET total_episodes = 2, update_time = NOW()
WHERE id = @demo_script_id AND deleted = 0;
