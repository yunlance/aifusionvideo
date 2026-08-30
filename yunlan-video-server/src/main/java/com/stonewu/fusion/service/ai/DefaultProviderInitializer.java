package com.stonewu.fusion.service.ai;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.stonewu.fusion.entity.ai.AiModel;
import com.stonewu.fusion.entity.ai.ApiConfig;
import com.stonewu.fusion.mapper.ai.AiModelMapper;
import com.stonewu.fusion.mapper.ai.ApiConfigMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 用户默认渠道/模型预置器。
 * 新用户注册后自动克隆一套全局 newapi 渠道及其关联模型作为该用户私有配置，可直接使用、也可修改。
 * 幂等：用户已有任何私有渠道时跳过，避免重复触发。
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class DefaultProviderInitializer {

    private final ApiConfigMapper apiConfigMapper;
    private final AiModelMapper aiModelMapper;

    @Transactional
    public void initForUser(Long userId) {
        if (userId == null) {
            return;
        }
        Long count = apiConfigMapper.selectCount(new LambdaQueryWrapper<ApiConfig>()
                .eq(ApiConfig::getUserId, userId));
        if (count != null && count > 0) {
            return;
        }
        List<ApiConfig> templates = apiConfigMapper.selectList(new LambdaQueryWrapper<ApiConfig>()
                .isNull(ApiConfig::getUserId)
                .eq(ApiConfig::getStatus, 1)
                .eq(ApiConfig::getPlatform, "newapi"));
        for (ApiConfig template : templates) {
            ApiConfig clone = ApiConfig.builder()
                    .name(template.getName())
                    .platform(template.getPlatform())
                    .textProtocol(template.getTextProtocol())
                    .imageProtocol(template.getImageProtocol())
                    .videoProtocol(template.getVideoProtocol())
                    .apiType(template.getApiType())
                    .apiUrl(template.getApiUrl())
                    .autoAppendV1Path(template.getAutoAppendV1Path())
                    .proxyType(template.getProxyType())
                    .proxyHost(template.getProxyHost())
                    .proxyPort(template.getProxyPort())
                    .proxyUsername(template.getProxyUsername())
                    .proxyPassword(template.getProxyPassword())
                    .apiKey(template.getApiKey())
                    .appId(template.getAppId())
                    .appSecret(template.getAppSecret())
                    .modelId(template.getModelId())
                    .userId(userId)
                    .status(1)
                    .build();
            apiConfigMapper.insert(clone);

            List<AiModel> templateModels = aiModelMapper.selectList(new LambdaQueryWrapper<AiModel>()
                    .isNull(AiModel::getUserId)
                    .eq(AiModel::getApiConfigId, template.getId())
                    .eq(AiModel::getStatus, 1));
            for (AiModel m : templateModels) {
                AiModel modelClone = AiModel.builder()
                        .name(m.getName())
                        .code(m.getCode())
                        .modelProtocol(m.getModelProtocol())
                        .capabilityPresetCode(m.getCapabilityPresetCode())
                        .modelType(m.getModelType())
                        .icon(m.getIcon())
                        .description(m.getDescription())
                        .sort(m.getSort())
                        .status(1)
                        .config(m.getConfig())
                        .maxConcurrency(m.getMaxConcurrency())
                        .defaultModel(m.getDefaultModel())
                        .supportVision(m.getSupportVision())
                        .multimodalInputTypes(m.getMultimodalInputTypes())
                        .multimodalInputTransports(m.getMultimodalInputTransports())
                        .supportReasoning(m.getSupportReasoning())
                        .reasoningEffortLevels(m.getReasoningEffortLevels())
                        .contextWindow(m.getContextWindow())
                        .apiConfigId(clone.getId())
                        .userId(userId)
                        .build();
                aiModelMapper.insert(modelClone);
            }
            log.info("[DefaultProvider] 用户 {} 已预置默认渠道: {}，克隆模型 {} 个",
                    userId, clone.getName(), templateModels.size());
        }
    }
}
