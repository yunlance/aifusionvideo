-- ============================================
-- 新增"邮箱验证码注册"配置项
-- 开启后，前端注册页将要求使用邮箱 + 验证码注册（邮箱即账号）
-- 幂等：若初始化脚本（baseline/V1.0.5.0.1）已插入过，此处自动跳过
-- ============================================
INSERT INTO `afv_system_config` (`config_key`, `config_value`, `remark`)
SELECT 'allow_email_register', 'false', '是否开启邮箱验证码注册（开启后注册须使用邮箱+验证码）'
WHERE NOT EXISTS (
    SELECT 1
    FROM afv_system_config
    WHERE config_key = 'allow_email_register'
);
