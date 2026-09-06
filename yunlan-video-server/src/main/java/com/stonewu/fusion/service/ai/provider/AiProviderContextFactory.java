package com.stonewu.fusion.service.ai.provider;

import cn.hutool.core.util.StrUtil;
import cn.hutool.json.JSONUtil;
import com.stonewu.fusion.common.BusinessException;
import com.stonewu.fusion.entity.ai.AiModel;
import com.stonewu.fusion.entity.ai.ApiConfig;
import com.stonewu.fusion.service.ai.ApiConfigService;
import com.stonewu.fusion.service.ai.model.AiModelMetadata;
import com.stonewu.fusion.service.ai.model.AiModelMetadataResolver;
import com.stonewu.fusion.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * 统一构建提供商上下文，收敛平台、密钥、地址和模型配置解析逻辑。
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class AiProviderContextFactory {

    private final ApiConfigService apiConfigService;
    private final AiModelMetadataResolver aiModelMetadataResolver;

    public AiProviderContext createForModel(AiModel model) {
        return createForModel(model, SecurityUtils.getCurrentUserId());
    }

    /**
     * 按使用方用户构建上下文：该用户在「我的密钥」中配置过密钥则使用他自己的，
     * 否则按开关回退到后台全局渠道（规则见 ApiConfigService#resolveForGeneration）。
     *
     * @param userId 使用方用户ID；为 null（如无登录上下文的异步任务）时沿用模型绑定的渠道
     */
    public AiProviderContext createForModel(AiModel model, Long userId) {
        if (model == null) {
            throw new BusinessException("AI 模型不存在");
        }
        ApiConfig apiConfig = resolveApiConfig(model, userId);
        Map<String, Object> config = parseConfig(model.getConfig(), model.getId());
        AiModelMetadata metadata = aiModelMetadataResolver.resolve(model, apiConfig);
        String requestProtocol = metadata.modelProtocol();
        if (StrUtil.isBlank(requestProtocol)) {
            throw new BusinessException("文本模型未配置请求协议：请在模型中设置覆盖协议，或在 API 配置中设置文本默认协议");
        }
        return AiProviderContext.builder()
                .model(model)
                .apiConfig(apiConfig)
                .config(config)
                .platform(normalizePlatform(requestProtocol))
                .apiKey(apiConfig.getApiKey())
                .baseUrl(apiConfig.getApiUrl())
                .modelName(resolveModelName(model, config))
                .build();
    }

    public AiProviderContext createForApiConfig(Long apiConfigId) {
        ApiConfig apiConfig = apiConfigService.getById(apiConfigId);
        if (apiConfig == null) {
            throw new BusinessException(404, "API 配置不存在");
        }
        return createForApiConfig(apiConfig);
    }

    public AiProviderContext createForApiConfig(ApiConfig apiConfig) {
        if (apiConfig == null || StrUtil.isBlank(apiConfig.getPlatform())) {
            throw new BusinessException("API 配置未设置接入与鉴权类型");
        }
        return AiProviderContext.builder()
                .apiConfig(apiConfig)
                .platform(normalizePlatform(apiConfig.getPlatform()))
                .apiKey(apiConfig.getApiKey())
                .baseUrl(apiConfig.getApiUrl())
                .build();
    }

    /**
     * 解析模型实际生效的渠道。
     * <p>
     * 修复：此前直接读取模型绑定的渠道配置，导致用户在「我的密钥」中配置的密钥
     * 在对话 / AgentScope 链路（AI 生成分镜、AI 剧本等）上完全不生效，一律走全局密钥。
     * 现在优先走 {@link ApiConfigService#resolveForGeneration}（全局模式用后台密钥，
     * 非全局模式用当前用户密钥），解析不到有效密钥时回退模型绑定的原始渠道，保持向后兼容。
     */
    private ApiConfig resolveApiConfig(AiModel model, Long userId) {
        if (model.getApiConfigId() == null) {
            throw new BusinessException("AI 模型未绑定 API 配置");
        }
        if (userId != null) {
            ApiConfig resolved = apiConfigService.resolveForGeneration(model, userId);
            if (resolved != null && StrUtil.isNotBlank(resolved.getApiKey())) {
                return resolved;
            }
        }
        ApiConfig apiConfig = apiConfigService.getById(model.getApiConfigId());
        if (apiConfig == null) {
            throw new BusinessException(404, "API 配置不存在");
        }
        return apiConfig;
    }

    private Map<String, Object> parseConfig(String json, Long modelId) {
        if (StrUtil.isBlank(json)) {
            return Map.of();
        }
        try {
            return JSONUtil.parseObj(json);
        } catch (Exception e) {
            log.warn("[AiProviderContextFactory] 配置 JSON 解析失败: modelId={}", modelId, e);
            return Map.of();
        }
    }

    private String resolveModelName(AiModel model, Map<String, Object> config) {
        Object modelName = config.get("modelName");
        return modelName != null ? modelName.toString() : model.getCode();
    }

    private String normalizePlatform(String platform) {
        return "openai".equalsIgnoreCase(platform) ? "openai_compatible" : platform;
    }
}
