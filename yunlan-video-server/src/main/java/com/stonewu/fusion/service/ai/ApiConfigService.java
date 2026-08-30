package com.stonewu.fusion.service.ai;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import cn.hutool.core.util.StrUtil;
import com.stonewu.fusion.common.PageResult;
import com.stonewu.fusion.common.BusinessException;
import com.stonewu.fusion.entity.ai.ApiConfig;
import com.stonewu.fusion.mapper.ai.ApiConfigMapper;
import com.stonewu.fusion.service.ai.proxy.AiProxySupport;
import com.stonewu.fusion.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class ApiConfigService {

    private final ApiConfigMapper apiConfigMapper;
    private final ObjectProvider<ChatModelFactory> chatModelFactoryProvider;
    private final ModelAccessResolver modelAccessResolver;

    /** 允许接入的平台白名单（包内可见，供模型绑定校验使用） */
    static final Set<String> ALLOWED_PLATFORMS = Set.of("newapi", "comfyui");

    @Transactional
    public Long createApiConfig(ApiConfig apiConfig) {
        validatePlatform(apiConfig.getPlatform());
        if (StrUtil.isBlank(apiConfig.getPlatform())) {
            apiConfig.setPlatform("newapi");
        }
        // 归属设置：普通用户创建的渠道归属自己；管理员在全局模式下维护全局渠道、私有模式下维护自己的私有渠道
        if (modelAccessResolver.isAdmin()) {
            apiConfig.setUserId(modelAccessResolver.isGlobalMode() ? null : SecurityUtils.requireCurrentUserId());
        } else {
            apiConfig.setUserId(SecurityUtils.requireCurrentUserId());
        }
        // 同一用户（全局为 null）同一平台仅允许存在 1 条启用的配置
        Long currentUserId = apiConfig.getUserId();
        long enabledCount = apiConfigMapper.selectCount(
                new LambdaQueryWrapper<ApiConfig>()
                        .eq(ApiConfig::getStatus, 1)
                        .eq(ApiConfig::getPlatform, apiConfig.getPlatform())
                        .and(w -> {
                            if (currentUserId == null) {
                                w.isNull(ApiConfig::getUserId);
                            } else {
                                w.eq(ApiConfig::getUserId, currentUserId);
                            }
                        }));
        if (enabledCount > 0) {
            throw new BusinessException(400, "已存在该平台的启用配置，无需重复创建");
        }
        applyPlatformDefaults(apiConfig);
        if (apiConfig.getAutoAppendV1Path() == null) {
            apiConfig.setAutoAppendV1Path(true);
        }
        apiConfig.setTextProtocol(normalizeProtocol(apiConfig.getTextProtocol()));
        apiConfig.setImageProtocol(normalizeProtocol(apiConfig.getImageProtocol()));
        apiConfig.setVideoProtocol(normalizeProtocol(apiConfig.getVideoProtocol()));
        apiConfig.setApiUrl(normalizeApiUrl(apiConfig.getPlatform(), apiConfig.getApiUrl()));
        normalizeProxyConfig(apiConfig);
        apiConfigMapper.insert(apiConfig);
        return apiConfig.getId();
    }

    @Transactional
    public void updateApiConfig(Long id, String name, String platform,
                                 String textProtocol, String imageProtocol, String videoProtocol,
                                 String apiUrl,
                                 Boolean autoAppendV1Path,
                                 String proxyType, String proxyHost, Integer proxyPort,
                                 String proxyUsername, String proxyPassword,
                                 String apiKey, String appId, String appSecret,
                                 Long modelId, Integer status, String remark) {
        ApiConfig config = apiConfigMapper.selectById(id);
        if (config == null) throw new BusinessException(404, "API配置不存在");
        modelAccessResolver.assertOwned(config);
        String effectivePlatform = platform != null ? platform : config.getPlatform();
        validatePlatform(effectivePlatform);
        if (name != null) config.setName(name);
        if (platform != null) config.setPlatform(platform);
        if (textProtocol != null) config.setTextProtocol(normalizeProtocol(textProtocol));
        if (imageProtocol != null) config.setImageProtocol(normalizeProtocol(imageProtocol));
        if (videoProtocol != null) config.setVideoProtocol(normalizeProtocol(videoProtocol));
        if (apiUrl != null) config.setApiUrl(normalizeApiUrl(effectivePlatform, apiUrl));
        if (autoAppendV1Path != null) config.setAutoAppendV1Path(autoAppendV1Path);
        if (proxyType != null) config.setProxyType(proxyType);
        if (proxyHost != null) config.setProxyHost(proxyHost);
        if (proxyPort != null) config.setProxyPort(proxyPort);
        if (proxyUsername != null) config.setProxyUsername(proxyUsername);
        if (proxyPassword != null) config.setProxyPassword(proxyPassword);
        // 编辑时前端不回显明文 Key；空串或脱敏值（含 ****）表示不修改，仅创建时可写入新 Key。
        if (apiKey != null && !apiKey.isBlank() && !apiKey.contains("****")) {
            config.setApiKey(apiKey);
        }
        if (appId != null) config.setAppId(appId);
        if (appSecret != null && !appSecret.isBlank() && !appSecret.contains("****")) {
            config.setAppSecret(appSecret);
        }
        if (modelId != null) config.setModelId(modelId);
        if (status != null) config.setStatus(status);
        if (remark != null) config.setRemark(remark);
        applyPlatformDefaults(config);
        normalizeProxyConfig(config);
        apiConfigMapper.updateById(config);
        evictModelCaches();
    }

    @Transactional
    public void deleteApiConfig(Long id) {
        ApiConfig config = apiConfigMapper.selectById(id);
        if (config == null) {
            throw new BusinessException(404, "API配置不存在");
        }
        modelAccessResolver.assertOwned(config);
        apiConfigMapper.deleteById(id);
        evictModelCaches();
    }

    /**
     * 查询指定用户私有渠道列表（供总后台用户设置管理使用）。
     */
    public List<ApiConfig> listByUserId(Long userId) {
        return apiConfigMapper.selectList(new LambdaQueryWrapper<ApiConfig>()
                .eq(ApiConfig::getUserId, userId)
                .orderByDesc(ApiConfig::getId));
    }

    public ApiConfig getById(Long id) {
        ApiConfig config = apiConfigMapper.selectById(id);
        modelAccessResolver.assertVisible(config);
        return config;
    }

    public PageResult<ApiConfig> getPage(String name, String platform, Integer status, int pageNo, int pageSize) {
        LambdaQueryWrapper<ApiConfig> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(name != null, ApiConfig::getName, name)
                .eq(platform != null, ApiConfig::getPlatform, platform)
                .eq(status != null, ApiConfig::getStatus, status);
        applyVisibleScope(wrapper);
        wrapper.orderByDesc(ApiConfig::getId);
        return PageResult.of(apiConfigMapper.selectPage(new Page<>(pageNo, pageSize), wrapper));
    }

    /**
     * 按当前模式/角色限定可见范围（管理分页用）：管理员可见全部；普通用户仅可见当前模式下自己的渠道。
     */
    private void applyVisibleScope(LambdaQueryWrapper<ApiConfig> wrapper) {
        if (modelAccessResolver.isAdmin()) {
            return;
        }
        if (modelAccessResolver.isGlobalMode()) {
            wrapper.isNull(ApiConfig::getUserId);
        } else {
            wrapper.eq(ApiConfig::getUserId, SecurityUtils.getCurrentUserId());
        }
    }

    /**
     * 生成/选择场景的可见范围（管理员也按模式过滤，符合"管理员也是用户"）：
     * 全局模式用全局渠道；私有模式用当前用户私有渠道；无登录上下文（如异步任务）时回退全局渠道。
     */
    private void applyGenerationScope(LambdaQueryWrapper<ApiConfig> wrapper) {
        if (modelAccessResolver.isGlobalMode()) {
            wrapper.isNull(ApiConfig::getUserId);
        } else {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId != null) {
                wrapper.eq(ApiConfig::getUserId, userId);
            } else {
                wrapper.isNull(ApiConfig::getUserId);
            }
        }
    }

    public List<ApiConfig> getEnabledList() {
        LambdaQueryWrapper<ApiConfig> wrapper = new LambdaQueryWrapper<ApiConfig>().eq(ApiConfig::getStatus, 1);
        applyGenerationScope(wrapper);
        return apiConfigMapper.selectList(wrapper);
    }

    /**
     * 按平台标识获取启用的 API 配置列表
     */
    public List<ApiConfig> getListByPlatform(String platform) {
        LambdaQueryWrapper<ApiConfig> wrapper = new LambdaQueryWrapper<ApiConfig>()
                .eq(ApiConfig::getStatus, 1)
                .eq(ApiConfig::getPlatform, platform);
        applyGenerationScope(wrapper);
        return apiConfigMapper.selectList(wrapper);
    }

    /**
     * 按多个平台标识获取启用的 API 配置列表
     */
    public List<ApiConfig> getListByPlatforms(List<String> platforms) {
        LambdaQueryWrapper<ApiConfig> wrapper = new LambdaQueryWrapper<ApiConfig>()
                .eq(ApiConfig::getStatus, 1)
                .in(ApiConfig::getPlatform, platforms);
        applyGenerationScope(wrapper);
        return apiConfigMapper.selectList(wrapper);
    }

    private String normalizeApiUrl(String platform, String apiUrl) {
        if (StrUtil.isBlank(apiUrl)) {
            return null;
        }
        String normalizedApiUrl = apiUrl.trim();
        String defaultApiUrl = getPlatformDefaultApiUrl(platform);
        if (StrUtil.isNotBlank(defaultApiUrl) && isSameApiUrl(normalizedApiUrl, defaultApiUrl)) {
            return null;
        }
        return normalizedApiUrl;
    }

    private String normalizeProtocol(String protocol) {
        if (StrUtil.isBlank(protocol)) {
            return null;
        }
        return protocol.trim().toLowerCase().replace(' ', '_').replace('-', '_');
    }

    private void normalizeProxyConfig(ApiConfig config) {
        String proxyType = AiProxySupport.normalizeProxyType(config.getProxyType());
        if (AiProxySupport.TYPE_NONE.equals(proxyType)) {
            config.setProxyType(null);
            config.setProxyHost(null);
            config.setProxyPort(null);
            config.setProxyUsername(null);
            config.setProxyPassword(null);
            return;
        }
        if (!AiProxySupport.isSupportedProxyType(proxyType)) {
            throw new BusinessException("不支持的代理类型: " + config.getProxyType());
        }
        if (StrUtil.isBlank(config.getProxyHost())) {
            throw new BusinessException("启用代理时代理主机不能为空");
        }
        Integer proxyPort = config.getProxyPort();
        if (proxyPort == null || proxyPort <= 0 || proxyPort > 65535) {
            throw new BusinessException("启用代理时代理端口必须在 1-65535 之间");
        }
        String proxyUsername = StrUtil.trim(config.getProxyUsername());
        if (StrUtil.isBlank(proxyUsername)) {
            if (StrUtil.isNotBlank(config.getProxyPassword())) {
                throw new BusinessException("启用代理认证时代理用户名不能为空");
            }
            config.setProxyUsername(null);
            config.setProxyPassword(null);
        } else {
            config.setProxyUsername(proxyUsername);
        }
        config.setProxyType(proxyType);
        config.setProxyHost(config.getProxyHost().trim());
    }

    private boolean isSameApiUrl(String currentApiUrl, String defaultApiUrl) {
        return normalizeComparableApiUrl(currentApiUrl)
                .equalsIgnoreCase(normalizeComparableApiUrl(defaultApiUrl));
    }

    private String normalizeComparableApiUrl(String apiUrl) {
        if (StrUtil.isBlank(apiUrl)) {
            return "";
        }
        return apiUrl.trim().replaceAll("/+$", "");
    }

    private String getPlatformDefaultApiUrl(String platform) {
        if (StrUtil.isBlank(platform)) {
            return null;
        }
        return switch (platform) {
            case "openai_compatible", "openai" -> "https://api.openai.com";
            case "newapi" -> "https://docs.newapi.ai";
            case "volcengine" -> "https://ark.cn-beijing.volces.com";
            case "vertex_ai" -> "us-central1";
            case "GoogleFlowReverseApi" -> "http://localhost:8000";
            case "dashscope" -> "https://dashscope.aliyuncs.com";
            case "anthropic" -> "https://api.anthropic.com";
            case "ollama" -> "http://localhost:11434";
            case "comfyui" -> "http://localhost:8188";
            default -> null;
        };
    }

    /**
     * 校验平台是否在白名单内。
     */
    private void validatePlatform(String platform) {
        if (StrUtil.isBlank(platform)) {
            return;
        }
        if (!ALLOWED_PLATFORMS.contains(platform)) {
            throw new BusinessException(400, "不支持该接入平台，仅允许 云揽川 与 ComfyUI");
        }
    }

    private void applyPlatformDefaults(ApiConfig config) {
        if (config == null || !"comfyui".equalsIgnoreCase(config.getPlatform())) {
            return;
        }
        config.setTextProtocol(null);
        if (StrUtil.isBlank(config.getImageProtocol())) {
            config.setImageProtocol("comfyui");
        }
        if (StrUtil.isBlank(config.getVideoProtocol())) {
            config.setVideoProtocol("comfyui");
        }
        if (!"comfyui".equalsIgnoreCase(config.getImageProtocol())
                || !"comfyui".equalsIgnoreCase(config.getVideoProtocol())) {
            throw new BusinessException(400, "ComfyUI 图片和视频默认协议必须为 comfyui");
        }
        config.setAutoAppendV1Path(false);
    }

    private void evictModelCaches() {
        ChatModelFactory chatModelFactory = chatModelFactoryProvider.getIfAvailable();
        if (chatModelFactory != null) {
            chatModelFactory.evictAll();
        }
    }
}
