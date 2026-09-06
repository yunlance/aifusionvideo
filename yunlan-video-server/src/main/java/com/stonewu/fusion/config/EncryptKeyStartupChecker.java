package com.stonewu.fusion.config;

import com.stonewu.fusion.common.ApiKeyCrypto;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

/**
 * 启动自检：检查 API 密钥加密密钥（APP_ENCRYPT_KEY）是否已配置。
 * <p>
 * 「我的密钥」功能依赖该密钥做 AES 加密，缺失时保存必定失败。
 * 这里在启动阶段就打出醒目告警，让运维第一时间发现，
 * 而不是等到用户点保存报错才察觉。
 * <p>
 * 注意：仅告警、不阻断启动——其他不依赖加密的功能仍可正常使用。
 */
@Slf4j
@Component
public class EncryptKeyStartupChecker implements ApplicationRunner {

    private final Environment environment;

    public EncryptKeyStartupChecker(Environment environment) {
        this.environment = environment;
    }

    @Override
    public void run(ApplicationArguments args) {
        // 桥接：ApiKeyCrypto 只认环境变量与 JVM 参数，这里把配置文件里的
        // app.encrypt.key 同步为 JVM 系统属性，方便本地开发直接写在 yml 中生效。
        String fromConfig = environment.getProperty(ApiKeyCrypto.KEY_PROPERTY, "");
        if (!fromConfig.isBlank() && System.getProperty(ApiKeyCrypto.KEY_PROPERTY) == null) {
            System.setProperty(ApiKeyCrypto.KEY_PROPERTY, fromConfig);
        }

        if (ApiKeyCrypto.isConfigured()) {
            return;
        }
        log.error("\n============================================================\n"
                + "【配置缺失】未检测到 API 密钥加密密钥！\n"
                + "影响：「我的密钥」功能将无法保存。\n"
                + "处理：在启动脚本中配置环境变量 APP_ENCRYPT_KEY\n"
                + "      （或 JVM 参数 -Dapp.encrypt.key），然后重启服务。\n"
                + "注意：各环境必须保持一致，且设定后不可更改，否则历史密文无法解密。\n"
                + "============================================================");
    }
}
