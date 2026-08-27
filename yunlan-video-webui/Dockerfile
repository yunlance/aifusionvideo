# ============================================
# 云揽镜 - 前端 Dockerfile (多阶段构建)
# ============================================

# ---------- 阶段 1: 安装依赖 ----------
FROM node:20-bookworm-slim AS deps

WORKDIR /build
# 仅用于无法验证 npm 官方源证书的内网/代理环境本机构建；公网正式镜像请删除以下两行
ENV NODE_TLS_REJECT_UNAUTHORIZED=0
ENV npm_config_strict_ssl=false

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN corepack enable pnpm
RUN --mount=type=cache,target=/root/.local/share/pnpm/store pnpm install --frozen-lockfile

# ---------- 阶段 2: 构建 ----------
FROM node:20-bookworm-slim AS builder

WORKDIR /build

COPY --from=deps /build/node_modules ./node_modules
COPY . .

ENV NEXT_TELEMETRY_DISABLED=1
# 仅用于无法验证 npm 官方源证书的内网/代理环境本机构建；公网正式镜像请删除此行
ENV NODE_TLS_REJECT_UNAUTHORIZED=0

RUN corepack enable pnpm
RUN --mount=type=cache,target=/build/.next/cache pnpm build

# ---------- 阶段 3: 运行 ----------
FROM node:20-bookworm-slim

LABEL maintainer="yunlance <https://github.com/yunlance>"

WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=5000

# 复制构建产物
COPY --from=builder /build/.next/standalone ./
COPY --from=builder /build/.next/static ./.next/static
COPY --from=builder /build/public ./public
COPY docker ./docker

RUN chmod +x ./docker/docker-entrypoint.sh

EXPOSE 5000

CMD ["./docker/docker-entrypoint.sh"]
