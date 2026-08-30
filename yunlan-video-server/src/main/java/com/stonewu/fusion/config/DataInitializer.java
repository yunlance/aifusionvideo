package com.stonewu.fusion.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.Statement;

/**
 * 应用启动时幂等初始化演示数据。
 *
 * <p>后端启动后由 Flyway 完成建表与基础种子（含默认 AI 模型/网关），
 * 本初始化器再确保「管理员账号」与「影视演示项目/分镜/镜头」存在：
 * <ul>
 *   <li>管理员：若不存在则写入；密码取自环境变量 ADMIN_PASSWORD（bcrypt 后入库），
 *       未配置时回退到与二次开发库一致的默认哈希，已存在则不覆盖。</li>
 *   <li>演示项目：复用 Flyway 迁移 V1.1.2.0.0 的 SQL，依赖管理员归属人，
 *       全部以 NOT EXISTS 幂等插入，删除后重启会自动补回。</li>
 * </ul>
 *
 * <p>与原来的 db-init 容器相比：走后端 JDBC（utf8mb4）写入，无中文乱码风险，
 * 且部署时无需额外容器。API 密钥不在初始化中写入，由用户在 WebUI 自行填写。
 */
@Component
public class DataInitializer implements CommandLineRunner {

    /**
     * 与二次开发库一致的默认 admin 密码哈希，仅在未配置 ADMIN_PASSWORD 时使用。
     */
    private static final String DEFAULT_ADMIN_HASH =
            "$2a$10$VfUPbAYQ5qIwezFXAprcVeKaFuiPWX7tqHjk7.cfox.sAXcS/8Xjy";

    private final JdbcTemplate jdbcTemplate;
    private final PasswordEncoder passwordEncoder;
    private final String adminPassword;

    public DataInitializer(DataSource dataSource,
                           PasswordEncoder passwordEncoder,
                           @Value("${ADMIN_PASSWORD:}") String adminPassword) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
        this.passwordEncoder = passwordEncoder;
        this.adminPassword = adminPassword;
    }

    @Override
    public void run(String... args) throws Exception {
        ensureAdmin();
        ensureDemoData();
    }

    private void ensureAdmin() {
        Integer exists = jdbcTemplate.queryForObject(
                "SELECT COUNT(1) FROM sys_user WHERE username = 'admin' AND deleted = 0", Integer.class);
        if (exists != null && exists > 0) {
            return;
        }

        String passwordHash = (adminPassword == null || adminPassword.isBlank())
                ? DEFAULT_ADMIN_HASH
                : passwordEncoder.encode(adminPassword);

        jdbcTemplate.update(
                "INSERT INTO sys_user (username, password, nickname, status, deleted, create_time, update_time) "
                        + "VALUES ('admin', ?, 'admin', 1, 0, NOW(), NOW())",
                passwordHash);

        Long roleId = jdbcTemplate.queryForObject(
                "SELECT id FROM sys_role WHERE code = 'admin' AND deleted = 0 LIMIT 1", Long.class);
        if (roleId != null) {
            Long userId = jdbcTemplate.queryForObject(
                    "SELECT id FROM sys_user WHERE username = 'admin' AND deleted = 0 LIMIT 1", Long.class);
            Integer linked = jdbcTemplate.queryForObject(
                    "SELECT COUNT(1) FROM sys_user_role WHERE user_id = ? AND role_id = ?",
                    Integer.class, userId, roleId);
            if (linked == null || linked == 0) {
                jdbcTemplate.update(
                        "INSERT INTO sys_user_role (user_id, role_id, deleted, create_time, update_time) "
                                + "VALUES (?, ?, 0, NOW(), NOW())",
                        userId, roleId);
            }
        }
    }

    private void ensureDemoData() throws Exception {
        String sql = readSql("db/migration/V1.1.2.0.0__seed_demo_project.sql");
        // 必须在同一个连接上逐条执行，否则 SET @xxx 用户变量无法跨语句传递
        try (Connection conn = jdbcTemplate.getDataSource().getConnection();
             Statement stmt = conn.createStatement()) {
            for (String part : sql.split(";")) {
                String statement = part.trim();
                if (!statement.isEmpty()) {
                    stmt.execute(statement);
                }
            }
        }
    }

    private String readSql(String path) throws Exception {
        try (InputStream in = new ClassPathResource(path).getInputStream()) {
            return new String(in.readAllBytes(), StandardCharsets.UTF_8);
        }
    }
}
