# 开发计划：AI 配置 云揽川 锁定与品牌化

> 需求目录：`dev-docs/2-in-progress/20260823-AI配置NewAPI锁定与品牌化/`
> 创建日期：2026-08-23
> 对照日期：2026-08-27
> 状态：进行中（核心锁定已落地，仍有入口与文案缺口）

命名约定：产品名是 **云揽镜**；聚合网关对外品牌是 **云揽川**，代码平台标识为 `newapi`。

## 一、业务背景与目标

本系统为免费分发产品，核心盈利模式为 **API 流量聚合**：云端模型调用固定走开发者自己的 云揽川 聚合平台，不允许终端用户自行添加 OpenAI、DeepSeek 等第三方云端渠道。

ComfyUI 作为本地工作流生成通道单独保留，不走云揽川流量。

本需求聚焦 **AI 配置页面（/settings/ai-models）**，目标：

1. 添加/编辑 API 配置时，接入类型默认 = **云揽川**（`platform=newapi`）。
2. 删除「常用提供商」快捷区（DeepSeek / 通义 / OpenAI / Agnes / ComfyUI 预设卡片）。
3. 图片、视频默认协议使用 **云揽川 通用协议**（`newapi`）。
4. 平台收敛：只允许 云揽川 与 ComfyUI；API Key 由后端保管，编辑时不回显明文。
5. 同一平台只保留 1 条启用配置；模型只能绑定白名单内的平台。

## 二、当前系统（已对照代码）

### 前端（yunlan-video-webui）

- `lib/api/ai-model.ts`：`PLATFORM_OPTIONS` 仅 `newapi`、`comfyui`；另有 `ALLOWED_PLATFORMS`。
- `api-config-dialog.tsx`：新建默认 `platform=newapi`，图片/视频协议默认 `newapi`；文本协议默认仍是 `openai_compatible`；已无 `API_PROVIDER_PRESETS`；编辑 Key 留空不回显。
- `model-config-support.tsx`：文本协议选项为 `newapi` / `openai_compatible`；图片、视频协议仍含 `newapi`、`openai`、`comfyui`。
- `page.tsx`：无配置时显示「配置 云揽川 接入」；**有任意配置后不再显示新建入口**。云揽川卡片仍保留「获取可用模型列表」，`fetch-remote-models-dialog.tsx` 仍在使用。空状态文案仍写「添加 API 配置」，与按钮文案不一致。

### 后端（yunlan-video-server）

- `ApiConfigService.ALLOWED_PLATFORMS = Set.of("newapi", "comfyui")`。
- 创建时空白平台默认 `newapi`；**同一 platform 仅允许 1 条启用配置**（云揽川 1 条 + ComfyUI 1 条，不是全局只准 1 条）。
- `ApiConfigConvert` 对 `apiKey` / `appSecret` / `proxyPassword` 脱敏；更新时忽略空值和含 `****` 的 Key。
- `AiModelService.validateApiConfig` 校验模型绑定平台必须在白名单内；ComfyUI 图片/视频模型仍可绑定已发布工作流。
- 未跟踪的种子迁移 `V1.1.3.0.0` / `V1.1.3.0.1` 会预置名为「AI大模型」的云揽川网关（`https://gate.xinchyun.com`）及默认文本/图片/视频模型；Key 留空。

## 三、已落地方案

### A 层：前端收敛

| 文件 | 当前实现 |
| --- | --- |
| `lib/api/ai-model.ts` | 平台选项收敛为 `newapi` + `comfyui` |
| `api-config-dialog.tsx` | 默认云揽川；删除常用提供商快捷区；图片/视频默认 `newapi`；Key 不回显 |
| `model-config-support.tsx` | 文本可选 `newapi` / `openai_compatible`；图片/视频保留 `newapi`、`openai`、`comfyui` |
| `page.tsx` | 无配置时引导配置云揽川；云揽川仍可远程拉模型 |

### B 层：后端锁定

| 文件 | 当前实现 |
| --- | --- |
| `ApiConfigService` | 平台白名单；按平台唯一启用配置；新建默认 `newapi` |
| `ApiConfigConvert` | 响应脱敏 |
| `ApiConfigService.updateApiConfig` | 空 Key / 脱敏值不覆盖原值 |
| `AiModelService` | 模型只能绑定白名单平台 |

## 四、关键技术点

1. **平台白名单**：`ALLOWED_PLATFORMS = Set.of("newapi", "comfyui")`。
2. **唯一配置**：按 `platform + status=1` 计数，不是全局只能 1 条 API 配置。
3. **Key 脱敏**：响应 VO 掩码；保存时 `null` / 空 / 含 `****` 不覆盖。
4. **协议默认**：图片/视频默认 `newapi`；文本默认仍是 `openai_compatible`。

## 五、验收标准

- [x] 新建 API 配置时默认选中 云揽川，图片/视频默认协议为 云揽川 通用协议。
- [x] 页面不再展示「常用提供商」快捷区。
- [x] 平台下拉仅 云揽川 与 ComfyUI。
- [x] API Key 编辑时不回显明文；后端响应脱敏。
- [x] 同一平台只能存在 1 条启用配置。
- [ ] 无配置之后，仍能单独新增 ComfyUI（当前有任意配置后新建入口消失）。
- [ ] 空状态文案与实际按钮「配置 云揽川 接入」一致。
- [ ] 文本协议默认是否改为 `newapi`，以及是否保留远程拉模型，需产品确认后收口。

## 六、范围边界

- 不改包名 `com.stonewu.fusion`、不动已执行的 Flyway 迁移历史。
- 品牌名/Logo/README 已在本仓库按「云揽镜」替换，不再属于本需求。
- ComfyUI 工作流能力见 `20260823-ComfyUI工作流支持/`，本期只收敛其接入入口。
