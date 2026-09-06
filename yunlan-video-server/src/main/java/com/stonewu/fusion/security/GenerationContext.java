package com.stonewu.fusion.security;

/**
 * 生成链路的线程上下文。
 * <p>
 * 用途：异步生成任务（Consumer）执行时没有登录上下文，
 * SecurityUtils.getCurrentUserId() 会返回 null。若不传递用户身份，
 * 「用户自带密钥模式」就无法知道该用谁的密钥，可能导致误用后台密钥（密钥串联）。
 * <p>
 * 因此由 Consumer 在任务开始时写入归属用户ID，同一线程内的 Strategy 读取它；
 * 任务结束必须在 finally 中清理，避免线程池复用造成用户信息泄露到下一个任务。
 */
public final class GenerationContext {

    private static final ThreadLocal<Long> USER_ID = new ThreadLocal<>();

    private GenerationContext() {
    }

    /** 绑定当前线程的归属用户（由异步任务入口调用） */
    public static void setUserId(Long userId) {
        USER_ID.set(userId);
    }

    /** 读取当前线程归属用户，未绑定返回 null */
    public static Long getUserId() {
        return USER_ID.get();
    }

    /** 必须清理：防止线程池复用导致用户身份残留 */
    public static void clear() {
        USER_ID.remove();
    }
}
