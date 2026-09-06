package com.stonewu.fusion.common;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * 用户 API 密钥加解密（AES-256-GCM）。
 * <p>
 * 加密密钥取自环境变量 {@code APP_ENCRYPT_KEY}（或 JVM 参数 app.encrypt.key）。
 * <b>生产环境必须配置该项，且各环境保持一致</b>，否则换环境后历史密文无法解密。
 * <p>
 * 密文格式：Base64(12字节随机IV + 密文)。
 * 解密失败时原样返回入参，用于兼容未加密的历史明文数据。
 */
public final class ApiKeyCrypto {

    private static final String ALGORITHM = "AES/GCM/NoPadding";
    private static final String KEY_ENV = "APP_ENCRYPT_KEY";
    /** 密钥的属性名，对外暴露以便启动自检做「配置文件 → JVM 属性」的桥接 */
    public static final String KEY_PROPERTY = "app.encrypt.key";
    private static final int IV_LENGTH = 12;
    private static final int TAG_LENGTH_BIT = 128;

    private static volatile SecretKeySpec keySpec;

    private ApiKeyCrypto() {
    }

    private static SecretKeySpec key() {
        if (keySpec == null) {
            synchronized (ApiKeyCrypto.class) {
                if (keySpec == null) {
                    keySpec = buildKeySpec();
                }
            }
        }
        return keySpec;
    }

    /**
     * 是否已配置加密密钥。不抛异常，供保存前预检查与启动自检使用，
     * 避免缺失时抛出的异常被全局处理器兜底成无意义的“系统内部错误”。
     */
    public static boolean isConfigured() {
        String raw = System.getenv(KEY_ENV);
        if (raw == null || raw.isBlank()) {
            raw = System.getProperty(KEY_PROPERTY);
        }
        return raw != null && !raw.isBlank();
    }

    private static SecretKeySpec buildKeySpec() {
        String raw = System.getenv(KEY_ENV);
        if (raw == null || raw.isBlank()) {
            raw = System.getProperty(KEY_PROPERTY);
        }
        if (raw == null || raw.isBlank()) {
            throw new BusinessException(500,
                    "服务端未配置加密密钥，请联系管理员配置（环境变量 APP_ENCRYPT_KEY 或 JVM 参数 -Dapp.encrypt.key）后重试");
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] keyBytes = digest.digest(raw.getBytes(StandardCharsets.UTF_8));
            return new SecretKeySpec(keyBytes, "AES");
        } catch (Exception e) {
            throw new BusinessException(500, "初始化加密密钥失败，请联系管理员检查 APP_ENCRYPT_KEY 配置");
        }
    }

    /** 加密，返回 Base64(IV+密文)；入参为 null 时返回 null */
    public static String encrypt(String plain) {
        if (plain == null) {
            return null;
        }
        try {
            byte[] iv = new byte[IV_LENGTH];
            new SecureRandom().nextBytes(iv);
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.ENCRYPT_MODE, key(), new GCMParameterSpec(TAG_LENGTH_BIT, iv));
            byte[] cipherText = cipher.doFinal(plain.getBytes(StandardCharsets.UTF_8));
            byte[] result = new byte[IV_LENGTH + cipherText.length];
            System.arraycopy(iv, 0, result, 0, IV_LENGTH);
            System.arraycopy(cipherText, 0, result, IV_LENGTH, cipherText.length);
            return Base64.getEncoder().encodeToString(result);
        } catch (BusinessException e) {
            // 配置缺失等已知业务异常，保持原始提示，避免被包装成“系统内部错误”
            throw e;
        } catch (Exception e) {
            throw new BusinessException(500, "API 密钥加密失败，请稍后重试或联系管理员");
        }
    }

    /**
     * 解密。若入参不是本工具产出的密文（如历史明文数据），原样返回，保证兼容。
     */
    public static String decrypt(String encoded) {
        if (encoded == null || encoded.isBlank()) {
            return encoded;
        }
        try {
            byte[] all = Base64.getDecoder().decode(encoded);
            if (all.length <= IV_LENGTH) {
                return encoded;
            }
            byte[] iv = new byte[IV_LENGTH];
            byte[] cipherText = new byte[all.length - IV_LENGTH];
            System.arraycopy(all, 0, iv, 0, IV_LENGTH);
            System.arraycopy(all, IV_LENGTH, cipherText, 0, cipherText.length);
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.DECRYPT_MODE, key(), new GCMParameterSpec(TAG_LENGTH_BIT, iv));
            return new String(cipher.doFinal(cipherText), StandardCharsets.UTF_8);
        } catch (Exception e) {
            return encoded;
        }
    }
}
