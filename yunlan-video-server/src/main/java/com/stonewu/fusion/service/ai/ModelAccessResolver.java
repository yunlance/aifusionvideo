package com.stonewu.fusion.service.ai;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.stonewu.fusion.common.BusinessException;
import com.stonewu.fusion.entity.ai.AiModel;
import com.stonewu.fusion.entity.ai.ApiConfig;
import com.stonewu.fusion.mapper.ai.AiModelMapper;
import com.stonewu.fusion.mapper.ai.ApiConfigMapper;
import com.stonewu.fusion.security.SecurityUserDetails;
import com.stonewu.fusion.security.SecurityUtils;
import com.stonewu.fusion.service.system.SystemConfigService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * 模型访问解析器：全局/私有双模式判定、可见模型/渠道解析、归属断言。
 * <p>
 * 全局模式（开关 model_use_global=true）：所有用户统一使用全局渠道/模型；
 * 私有模式（默认）：每个用户使用自己的私有渠道/模型，全局配置对普通用户隐藏。
 */
@Component
@RequiredArgsConstructor
public class ModelAccessResolver {

    public static final String CONFIG_MODEL_USE_GLOBAL = "model_use_global";

    private final SystemConfigService systemConfigService;
    private final ApiConfigMapper apiConfigMapper;
    private final AiModelMapper aiModelMapper;

    /**
     * 是否全局模式：true=所有用户统一使用全局模型；false=每个用户使用自己的私有模型。
     */
    public boolean isGlobalMode() {
        return systemConfigService.getBooleanValue(CONFIG_MODEL_USE_GLOBAL, false);
    }

    /**
     * 解析当前用户可见的渠道。
     * 全局模式：仅全局渠道；私有模式：全局渠道（作为可引用的平台模板）+ 当前用户私有渠道。
     */
    public List<ApiConfig> visibleApiConfigs() {
        if (isGlobalMode()) {
            return apiConfigMapper.selectList(new LambdaQueryWrapper<ApiConfig>()
                    .isNull(ApiConfig::getUserId)
                    .orderByDesc(ApiConfig::getId));
        }
        Long userId = SecurityUtils.getCurrentUserId();
        return apiConfigMapper.selectList(new LambdaQueryWrapper<ApiConfig>()
                .and(w -> w.isNull(ApiConfig::getUserId).or().eq(ApiConfig::getUserId, userId))
                .orderByDesc(ApiConfig::getId));
    }

    /**
     * 解析当前用户可见的启用模型（可按类型过滤）。
     * 全局模式：全局模型；私有模式：仅当前用户私有模型。
     */
    public List<AiModel> visibleModels(Integer modelType) {
        // 模型统一由平台维护：无论「全局模式」还是「用户自带密钥模式」，
        // 所有用户看到的都是同一份全局模型（user_id IS NULL），用户只读、不可增删改。
        LambdaQueryWrapper<AiModel> wrapper = new LambdaQueryWrapper<AiModel>()
                .eq(modelType != null, AiModel::getModelType, modelType)
                .eq(AiModel::getStatus, 1)
                .isNull(AiModel::getUserId);
        wrapper.orderByAsc(AiModel::getSort).orderByDesc(AiModel::getId);
        return aiModelMapper.selectList(wrapper);
    }

    /**
     * 可见性断言：读取/生成链路上，非管理员只能访问当前模式下可见的渠道（防止越权读取他人 Key）。
     * 无登录上下文（后台异步任务）时放行。
     */
    public void assertVisible(ApiConfig config) {
        if (config == null || isAdmin()) {
            return;
        }
        Long currentUserId = SecurityUtils.getCurrentUserId();
        if (currentUserId == null) {
            return;
        }
        if (isGlobalMode()) {
            if (config.getUserId() != null) {
                throw new BusinessException(403, "无权访问该配置");
            }
        } else {
            if (config.getUserId() == null || !config.getUserId().equals(currentUserId)) {
                throw new BusinessException(403, "无权访问该配置");
            }
        }
    }

    /**
     * 可见性断言：读取/生成链路上，非管理员只能访问当前模式下可见的模型。
     */
    public void assertVisible(AiModel model) {
        if (model == null || isAdmin()) {
            return;
        }
        Long currentUserId = SecurityUtils.getCurrentUserId();
        if (currentUserId == null) {
            return;
        }
        if (isGlobalMode()) {
            if (model.getUserId() != null) {
                throw new BusinessException(403, "无权访问该模型");
            }
        } else {
            if (model.getUserId() == null || !model.getUserId().equals(currentUserId)) {
                throw new BusinessException(403, "无权访问该模型");
            }
        }
    }

    /**
     * 归属断言：非管理员只能操作自己的渠道，且不能操作全局配置。
     */
    public void assertOwned(ApiConfig config) {
        if (config == null) {
            return;
        }
        if (isAdmin()) {
            return;
        }
        Long userId = SecurityUtils.requireCurrentUserId();
        if (config.getUserId() == null) {
            throw new BusinessException(403, "无权操作全局配置");
        }
        if (!config.getUserId().equals(userId)) {
            throw new BusinessException(403, "无权操作其他用户的配置");
        }
    }

    /**
     * 归属断言：非管理员只能操作自己的模型，且不能操作全局模型。
     */
    public void assertOwned(AiModel model) {
        if (model == null) {
            return;
        }
        if (isAdmin()) {
            return;
        }
        Long userId = SecurityUtils.requireCurrentUserId();
        if (model.getUserId() == null) {
            throw new BusinessException(403, "无权操作全局模型");
        }
        if (!model.getUserId().equals(userId)) {
            throw new BusinessException(403, "无权操作其他用户的配置");
        }
    }

    /**
     * 写操作统一校验：模型与渠道配置由平台（管理员）维护，普通用户只读。
     * 用户侧的自定义能力收敛为「只填写自己的密钥」（见 UserApiKeyService）。
     */
    public void assertAdminOnly() {
        if (isAdmin()) {
            return;
        }
        throw new BusinessException(403, "模型与渠道配置由平台统一维护，无修改权限");
    }

    public boolean isAdmin() {
        SecurityUserDetails details = SecurityUtils.getCurrentUserDetails();
        if (details == null) {
            return false;
        }
        return details.getAuthorities().stream()
                .anyMatch(a -> "ROLE_ADMIN".equals(a.getAuthority()));
    }
}
