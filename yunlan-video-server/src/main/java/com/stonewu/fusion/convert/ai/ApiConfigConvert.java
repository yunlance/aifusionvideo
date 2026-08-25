package com.stonewu.fusion.convert.ai;

import com.stonewu.fusion.controller.ai.vo.ApiConfigRespVO;
import com.stonewu.fusion.entity.ai.ApiConfig;
import org.mapstruct.AfterMapping;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;
import org.mapstruct.factory.Mappers;

import java.util.List;

/**
 * API配置 Convert
 * <p>
 * 敏感字段（apiKey/appSecret/proxyPassword）统一脱敏后再返回前端，避免明文泄露。
 */
@Mapper
public interface ApiConfigConvert {

    ApiConfigConvert INSTANCE = Mappers.getMapper(ApiConfigConvert.class);

    ApiConfigRespVO convert(ApiConfig config);

    List<ApiConfigRespVO> convertList(List<ApiConfig> configs);

    @AfterMapping
    default void maskSecrets(ApiConfig config, @MappingTarget ApiConfigRespVO respVO) {
        respVO.setApiKey(maskCredential(config.getApiKey()));
        respVO.setAppSecret(maskCredential(config.getAppSecret()));
        respVO.setProxyPassword(config.getProxyPassword() == null || config.getProxyPassword().isBlank()
                ? config.getProxyPassword() : "****");
    }

    private static String maskCredential(String value) {
        if (value == null || value.isBlank()) {
            return value;
        }
        if (value.length() <= 8) {
            return "****";
        }
        return value.substring(0, 4) + "****" + value.substring(value.length() - 4);
    }
}
