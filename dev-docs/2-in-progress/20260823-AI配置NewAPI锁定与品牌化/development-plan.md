# 开发计划：AI 配置 云揽川 锁定与品牌化

> 需求目录：`dev-docs/2-in-progress/20260823-AI配置NewAPI锁定与品牌化/`
> 创建日期：2026-08-23
> 状态：进行中

## 一、业务背景与目标

本系统为免费分发产品，核心盈利模式为 **API 流量聚合**：所有模型调用必须固定走开发者自己的 云揽川 聚合平台，不允许终端用户自行添加其他模型/平台/API 渠道。

本需求聚焦 **AI 配置页面（/settings/ai-models）**，目标：

1. 添加/编辑 API 配置时，接入与鉴权类型默认 = **云揽川**。
2. 删除「常用提供商」快捷区（DeepSeek / 通义 / OpenAI / Agnes / ComfyUI 预设）。
3. 图片、视频默认协议直接用 **云揽川 通用协议**（`xinapi`）。
4. 平台收敛：只允许 凶， 与 ComfyUI 两类接入；API Key 由后端保管，编辑时不回显明文。
5. 模型管理仅允许基于「预置能力预设」添加模型，去除自由新增 API 渠道的入口，锁定走唯一 云揽川 配置。

## 二、现状盘点（已核实）

### 前端（yunlan-video-webui）
- `lib/api/ai-model.ts`：`PLATFORM_OPTIONS` 含 10 种平台；`PLATFORM_LABELS` 映射。
- `app/(dashboard)/settings/ai-models/_components/api-config-dialog.tsx`：
  - 新建默认 `platform=openai_compatible`、`textProtocol=openai_compatible`、`imageProtocol=openai`、`videoProtocol=openai`。
  - `API_PROVIDER_PRESETS` = 常用提供商（5 项快捷卡）。
- `app/(dashboard)/settings/ai-models/_components/model-config-support.tsx`：`IMAGE_PROTOCOL_OPTIONS`/`VIDEO_PROTOCOL_OPTIONS` 已含 `newapi` 选项。
- `app/(dashboard)/settings/ai-models/page.tsx`：展示 API 配置卡片列表、支持添加/编辑/删除/导入/导出/远程拉模型。

### 后端（yunlan-video-server）
- `ApiConfigController`：`create/update/delete/remote-models` 均要求 `ADMIN`。
- `ApiConfigService`：`applyPlatformDefaults` 仅处理 `comfyui`；`createApiConfig/updateApiConfig` 无平台白名单与单配置限制。
- `ApiConfigRespVO`：包含 `apiKey`（明文返回，存在泄露风险）。
- `AiModelService`：`createAiModel` 通过 `validateApiConfig` 校验 `apiConfigId`。
- 模型预设：`resources/model-presets/**` 按平台目录组织，`ModelPresetService` 加载。

## 三、目标方案

### A 层：前端收敛
| 文件 | 改动 |
| --- | --- |
| `lib/api/ai-model.ts` | `PLATFORM_OPTIONS` 收敛为仅 `newapi` + `comfyui`；新增 `LOCKED_PLATFORMS` 常量 |
| `api-config-dialog.tsx` | 新建/编辑默认 `platform=newapi`；删除 `API_PROVIDER_PRESETS` 快捷区；图片/视频默认 `newapi`；Key 编辑不回显明文（占位提示） |
| `model-config-support.tsx` | 协议选项收敛为 `newapi` + `openai_compatible`（文本）；图片/视频仅 `newapi`（如 ComfyUI 模型仍支持 comfyui 协议） |
| `page.tsx` | 隐藏「添加 API 配置」入口（仅展示唯一 云揽川 配置，未配置时展示引导）；移除远程拉模型按钮；隐藏编辑 Key 能力 |

### B 层：后端锁定
| 文件 | 改动 |
| --- | --- |
| `ApiConfigService` | `createApiConfig`/`updateApiConfig` 增加平台白名单（仅 newapi/comfyui）；限制仅允许存在 1 条启用配置（锁定唯一）；新建默认 `newapi` |
| `ApiConfigRespVO` | `apiKey`/`appSecret`/`proxyPassword` 脱敏返回（maskSecret） |
| `ApiConfigSaveReqVO` | 编辑时忽略前端回传的 Key（仅创建时允许写入） |
| `AiModelService` | 创建/更新模型强制绑定到唯一的 云揽川 配置；禁止挂载其他平台配置 |

## 四、关键技术点

1. **平台白名单**：后端统一常量 `ALLOWED_PLATFORMS = Set.of("newapi", "comfyui")`，创建/更新时校验。
2. **唯一配置**：`createApiConfig` 前检查启用配置数 ≥1 则拒绝新增（或复用更新）。产品决策：仅保留 1 条 云揽川 配置。
3. **Key 脱敏**：响应 VO 用 `maskSecret()` 处理 `apiKey`；保存请求在 service 层判断 `apiKey` 为 `null`/脱敏值时不覆盖原有值。
4. **协议默认**：新建配置默认 `textProtocol=newapi`、`imageProtocol=newapi`、`videoProtocol=newapi`（云揽川 通用协议）。

## 五、验收标准

- [ ] 新建 API 配置时默认选中 云揽川，图片/视频默认协议为 云揽川 通用协议。
- [ ] 页面不再展示「常用提供商」快捷区。
- [ ] 平台下拉仅 云揽川 与 ComfyUI。
- [ ] API Key 编辑时显示占位、不回显明文；后端响应脱敏。
- [ ] 系统中只能存在 1 条启用的 云揽川 配置（不可新增多条）。
- [ ] 模型添加/编辑只允许选择预置能力预设，API 配置固定绑定唯一 云揽川。
- [ ] 前端 `tsc --noEmit`、后端编译通过，本地 dev 运行验证。

## 六、范围边界（本期不做）

- 不改包名 `com.stonewu.fusion`、不动上游 Flyway 迁移历史。
- 不做品牌名/Logo/README 替换（另有需求）。
- 不改 ComfyUI 工作流能力（本期仅收敛其接入入口）。
