package com.stonewu.fusion.service.ai;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.stonewu.fusion.common.ApiKeyCrypto;
import com.stonewu.fusion.common.BusinessException;
import com.stonewu.fusion.entity.ai.UserApiKey;
import com.stonewu.fusion.mapper.ai.UserApiKeyMapper;
import com.stonewu.fusion.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 用户自带密钥服务
 * <p>
 * 安全约束（核心）：
 * 1. 密钥独立表存储，与后台渠道表 afv_api_config 物理隔离，绝不混用；
 * 2. 入库前 AES 加密，列表查询一律脱敏，明文只在生成链路内存中短暂存在；
 * 3. 所有操作强制绑定 SecurityUtils 当前用户，A 用户永远读写不到 B 用户的密钥。
 */
@Service
@RequiredArgsConstructor
public class UserApiKeyService {

    private final UserApiKeyMapper userApiKeyMapper;

    /**
     * 当前登录用户的密钥列表。密钥一律脱敏为 ****，不返回任何明文或密文片段。
     */
    public List<UserApiKey> listMine() {
        Long userId = SecurityUtils.requireCurrentUserId();
        List<UserApiKey> list = userApiKeyMapper.selectList(new LambdaQueryWrapper<UserApiKey>()
                .eq(UserApiKey::getUserId, userId)
                .orderByAsc(UserApiKey::getPlatform));
        list.forEach(item -> {
            item.setApiKey(mask(item.getApiKey()));
            item.setAppSecret(mask(item.getAppSecret()));
        });
        return list;
    }

    /**
     * 新增或更新当前用户在指定平台的密钥。
     */
    @Transactional
    public void saveMine(String platform, String apiKey, String appId, String appSecret) {
        // 服务端配置自检：加密密钥缺失时直接给出明确提示，
        // 避免异常冒泡到全局兜底处理器后只显示“系统内部错误”
        if (!ApiKeyCrypto.isConfigured()) {
            throw new BusinessException(500,
                    "服务端未配置加密密钥，请联系管理员配置（环境变量 APP_ENCRYPT_KEY）后重试");
        }
        validatePlatform(platform);
        if (apiKey == null || apiKey.isBlank()) {
            throw new BusinessException(400, "API 密钥不能为空");
        }
        if (apiKey.contains("****")) {
            throw new BusinessException(400, "请填写完整的密钥，不支持保存脱敏值");
        }
        Long userId = SecurityUtils.requireCurrentUserId();

        UserApiKey existing = userApiKeyMapper.selectOne(new LambdaQueryWrapper<UserApiKey>()
                .eq(UserApiKey::getUserId, userId)
                .eq(UserApiKey::getPlatform, platform));

        if (existing != null) {
            existing.setApiKey(ApiKeyCrypto.encrypt(apiKey.trim()));
            existing.setAppId(appId);
            existing.setAppSecret(shouldUpdateSecret(appSecret) ? ApiKeyCrypto.encrypt(appSecret.trim())
                    : existing.getAppSecret());
            existing.setStatus(1);
            userApiKeyMapper.updateById(existing);
            return;
        }

        UserApiKey entity = UserApiKey.builder()
                .userId(userId)
                .platform(platform)
                .apiKey(ApiKeyCrypto.encrypt(apiKey.trim()))
                .appId(appId)
                .appSecret(appSecret == null || appSecret.isBlank() ? null : ApiKeyCrypto.encrypt(appSecret.trim()))
                .status(1)
                .build();
        userApiKeyMapper.insert(entity);
    }

    /**
     * 删除当前用户的密钥（严格校验归属）。
     */
    @Transactional
    public void deleteMine(Long id) {
        Long userId = SecurityUtils.requireCurrentUserId();
        UserApiKey entity = userApiKeyMapper.selectById(id);
        if (entity == null) {
            return;
        }
        if (!userId.equals(entity.getUserId())) {
            throw new BusinessException(403, "无权删除其他用户的密钥");
        }
        userApiKeyMapper.deleteById(id);
    }

    /**
     * 取指定用户在指定平台、已解密的密钥实体。
     * <b>仅供生成链路内部调用</b>，禁止直接返回给前端。未配置返回 null。
     */
    public UserApiKey findDecrypted(Long userId, String platform) {
        if (userId == null || platform == null) {
            return null;
        }
        UserApiKey entity = userApiKeyMapper.selectOne(new LambdaQueryWrapper<UserApiKey>()
                .eq(UserApiKey::getUserId, userId)
                .eq(UserApiKey::getPlatform, platform)
                .eq(UserApiKey::getStatus, 1));
        if (entity == null) {
            return null;
        }
        entity.setApiKey(ApiKeyCrypto.decrypt(entity.getApiKey()));
        entity.setAppSecret(ApiKeyCrypto.decrypt(entity.getAppSecret()));
        return entity;
    }

    private boolean shouldUpdateSecret(String appSecret) {
        return appSecret != null && !appSecret.isBlank() && !appSecret.contains("****");
    }

    private void validatePlatform(String platform) {
        if (platform == null || !ApiConfigService.ALLOWED_PLATFORMS.contains(platform)) {
            throw new BusinessException(400, "不支持该平台，仅允许："
                    + String.join("、", ApiConfigService.ALLOWED_PLATFORMS));
        }
    }

    /** 脱敏：只表示“已配置”，不泄露任何字符 */
    private String mask(String secret) {
        return secret == null || secret.isBlank() ? secret : "****";
    }
}
