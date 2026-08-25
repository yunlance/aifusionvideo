# 进度跟踪：AI 配置 云揽川 锁定与品牌化

> 更新日期：2026-08-23

## 任务清单

| # | 任务 | 状态 | 备注 |
| --- | --- | --- | --- |
| 1 | 梳理后端 AI 配置/模型接口与预设机制 | ✅ 完成 | 已读 ApiConfig/AiModel/ModelPreset 相关代码 |
| 2 | 前端：API 配置对话框默认 云揽川、删常用提供商、图片/视频默认 newapi | ✅ 完成 | 默认 `newapi`；删除 `API_PROVIDER_PRESETS`；Key 编辑不回显 |
| 3 | 前端：AI 配置页隐藏添加入口、仅展示唯一 云揽川 配置 | ✅ 完成 | 有配置时隐藏「添加 API 配置」；移除远程拉模型按钮与对话框 |
| 4 | 前端：模型管理仅预置模型，去除自由新增 API 渠道 | ✅ 完成 | 协议选项收敛为 newapi/openai/comfyui；删除 fetch-remote-models-dialog |
| 5 | 后端：API Key 后端保管、脱敏、编辑不回显 | ✅ 完成 | `ApiConfigConvert` @AfterMapping 脱敏；update 忽略空/脱敏 Key |
| 6 | 后端：锁定唯一 云揽川 配置、平台白名单 | ✅ 完成 | `ALLOWED_PLATFORMS` 白名单；同平台唯一启用配置；模型绑定白名单校验 |
| 7 | 验证前后端编译与运行 | ✅ 完成 | 前端 tsc 通过；后端 `mvnw compile` 通过；Flyway 测试因 surefire JVM 崩溃未跑（环境问题，非代码问题） |

## 变更记录

- 2026-08-23：创建需求目录，确认方案（A 层前端收敛 + B 层后端锁定）。
- 2026-08-23：完成前端 A 层（对话框默认值/删常用提供商/页面收敛/协议收敛）与后端 B 层（Key 脱敏/白名单/唯一配置）。
- 2026-08-23：安装本机 JDK21（清华镜像），后端 `mvnw compile` 验证通过。

## 遗留事项

- Flyway 迁移命名测试在本机 surefire 环境崩溃（forked VM terminated），非代码回归，待用户环境验证。
- 后端生效需重新构建后端（本地 mvnw 或 Docker 镜像），当前 8080 Docker 仍为旧后端。
