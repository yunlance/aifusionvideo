package com.stonewu.fusion.service.system;

import cn.hutool.core.util.StrUtil;
import com.stonewu.fusion.common.BusinessException;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.OutputStream;
import java.io.PrintStream;
import java.util.Properties;

/**
 * 邮件发送服务
 * 动态从数据库系统配置中读取配置，无需重启服务即可使配置生效
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class MailService {

    private final SystemConfigService systemConfigService;

    /**
     * 发送 HTML 邮件
     *
     * @param to      收件人邮箱
     * @param subject 邮件主题
     * @param content 邮件内容
     */
    public void sendHtmlEmail(String to, String subject, String content) {
        final String host = systemConfigService.getValue("mail_smtp_host") == null
                ? null : systemConfigService.getValue("mail_smtp_host").trim();
        String portStr = systemConfigService.getValue("mail_smtp_port");
        final String username = systemConfigService.getValue("mail_username") == null
                ? null : systemConfigService.getValue("mail_username").trim();
        final String password = systemConfigService.getValue("mail_password");
        String sslStr = systemConfigService.getValue("mail_ssl");
        final String from = systemConfigService.getValue("mail_from") == null
                ? null : systemConfigService.getValue("mail_from").trim();

        if (StrUtil.isBlank(host) || StrUtil.isBlank(portStr) || StrUtil.isBlank(username) || StrUtil.isBlank(password)) {
            throw new BusinessException(400, "邮件服务未配置或配置不完整，请联系管理员配置邮箱参数");
        }

        int port;
        try {
            port = Integer.parseInt(portStr.trim());
        } catch (NumberFormatException e) {
            throw new BusinessException(400, "邮件服务端口配置不正确，必须为数字");
        }

        boolean ssl = Boolean.parseBoolean(sslStr);
        String fromAddress = StrUtil.isNotBlank(from) ? from : username;
        log.info("[Mail] 准备发送 from={} to={} host={}:{} ssl={}", fromAddress, to, host, port, ssl);

        Properties props = new Properties();
        props.put("mail.transport.protocol", "smtp");
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", String.valueOf(port));
        props.put("mail.smtp.auth", "true");
        if (ssl) {
            // 465 隐式 SSL：只启用 SSL（不自定义 socketFactory，避免部分服务器/Java 组合不兼容）
            props.put("mail.smtp.ssl.enable", "true");
            props.put("mail.smtp.ssl.trust", "*");
        } else {
            // 25/587 端口：启用 STARTTLS
            props.put("mail.smtp.starttls.enable", "true");
        }
        // 显式指定认证机制，确保 AUTH 正常执行（163 等要求认证后 MAIL FROM 才被接受）
        props.put("mail.smtp.auth.mechanisms", "LOGIN PLAIN");
        // 开启 SMTP 调试日志并重定向到应用日志，便于排查服务器拒绝原因
        props.put("mail.debug", "true");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });
        session.setDebug(true);
        session.setDebugOut(new PrintStream(new OutputStream() {
            private final StringBuilder sb = new StringBuilder();

            @Override
            public void write(int b) {
                if (b == '\n') {
                    log.info("[SMTP] {}", sb.toString());
                    sb.setLength(0);
                } else {
                    sb.append((char) b);
                }
            }
        }));

        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(fromAddress));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject, "UTF-8");
            message.setContent(content, "text/html; charset=UTF-8");

            Transport.send(message);
            log.info("邮件已成功发送至: {}", to);
        } catch (MessagingException e) {
            log.error("邮件发送失败, 收件人: {}", to, e);
            throw new BusinessException(500, "发送邮件失败: " + e.getMessage());
        }
    }
}
