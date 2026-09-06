package com.stonewu.fusion.entity.ai;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.stonewu.fusion.common.BaseEntity;
import lombok.*;

/**
 * 用户自带模型密钥实体
 * <p>
 * 对应数据库表：afv_user_api_key
 * <p>
 * 与 afv_api_config（渠道配置）物理隔离：
 * 渠道/地址/协议/代理统一由后台全局维护，本表<b>只存用户自己的密钥</b>，
 * 从根本上避免用户密钥与后台密钥混用、或克隆渠道时误复制后台密钥。
 */
@TableName("afv_user_api_key")
@Data
@EqualsAndHashCode(callSuper = true)
@ToString(callSuper = true)
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserApiKey extends BaseEntity {

    /** 主键ID，自增 */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 归属用户ID（非空，永远属于某个具体用户） */
    private Long userId;

    /** 平台标识：newapi / comfyui（与 ApiConfigService.ALLOWED_PLATFORMS 保持一致） */
    private String platform;

    /** 加密后的 API 密钥 */
    private String apiKey;

    /** 应用ID（可选，非敏感信息） */
    private String appId;

    /** 加密后的应用密钥（可选） */
    private String appSecret;

    /** 状态：0-禁用 1-启用 */
    @Builder.Default
    private Integer status = 1;

    /** 备注说明 */
    private String remark;
}
