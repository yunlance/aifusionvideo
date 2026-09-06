package com.stonewu.fusion.controller.ai.vo;

import lombok.Data;

/**
 * 用户保存「我的密钥」请求体。
 * 用户只能填写自己的密钥，平台/地址/协议等一律由后台统一维护。
 */
@Data
public class MyApiKeySaveReqVO {

    /** 平台标识：newapi / comfyui */
    private String platform;

    /** API 密钥（明文提交，服务端加密存储） */
    private String apiKey;

    /** 应用ID（可选） */
    private String appId;

    /** 应用密钥（可选） */
    private String appSecret;
}
