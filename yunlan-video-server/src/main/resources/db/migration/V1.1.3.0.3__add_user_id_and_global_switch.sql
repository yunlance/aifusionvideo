-- ============================================
-- BYOK：渠道/模型增加归属用户字段 + 全局/私有总开关
-- user_id = NULL 表示全局配置（管理员维护），非 NULL 表示该用户私有
-- ============================================

-- 渠道表增加归属字段
ALTER TABLE `afv_api_config`
    ADD COLUMN `user_id` bigint NULL DEFAULT NULL COMMENT '归属用户ID；NULL表示全局配置' AFTER `model_id`;
CREATE INDEX `idx_api_config_user_id` ON `afv_api_config` (`user_id`);

-- 模型表增加归属字段
ALTER TABLE `afv_ai_model`
    ADD COLUMN `user_id` bigint NULL DEFAULT NULL COMMENT '归属用户ID；NULL表示全局配置' AFTER `api_config_id`;
CREATE INDEX `idx_ai_model_user_id` ON `afv_ai_model` (`user_id`);

-- 全局/私有总开关（默认私有模式=false）
INSERT INTO `afv_system_config` (`config_key`, `config_value`, `remark`)
SELECT 'model_use_global', 'false', '模型使用模式：true-所有用户统一使用全局模型；false-每个用户使用自己的私有模型'
WHERE NOT EXISTS (
    SELECT 1
    FROM `afv_system_config`
    WHERE `config_key` = 'model_use_global'
);
