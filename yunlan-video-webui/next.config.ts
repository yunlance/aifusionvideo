import type { NextConfig } from "next";

const developmentBackendUrl = process.env.DEV_BACKEND_URL?.trim().replace(/\/+$/, "");

if (process.env.NODE_ENV === "development" && !developmentBackendUrl) {
  throw new Error(
    "本地开发必须配置 DEV_BACKEND_URL，请检查 yunlan-video-webui/.env.development",
  );
}

const nextConfig: NextConfig = {
  reactStrictMode: true,
  output: "standalone",
  // Disable the client-side Router Cache so a deployment is picked up immediately.
  // By default Next keeps statically generated / fully prefetched routes in browser
  // memory for 5 minutes, which serves stale content after a new build is deployed
  // (the request is never sent, so Cache-Control headers cannot prevent it).
  experimental: {
    staleTimes: {
      dynamic: 0,
      static: 0,
    },
  },
  // Development API rewrites proxy SSE through Next.js. Disable compression
  // there so incremental events are flushed instead of buffered by gzip.
  compress: process.env.NODE_ENV !== "development",
  async rewrites() {
    if (process.env.NODE_ENV !== "development") {
      return [];
    }

    return [
      {
        source: "/api/:path*",
        destination: `${developmentBackendUrl!}/api/:path*`,
      },
      {
        source: "/media/:path*",
        destination: `${developmentBackendUrl!}/media/:path*`,
      },
    ];
  },
      async headers() {
    return [
      {
        source: "/:path*",
        headers: [
          { key: "Cache-Control", value: "no-cache, no-store, must-revalidate" },
        ],
      },
      {
        source: "/_next/:path*",
        headers: [
          { key: "Cache-Control", value: "public, max-age=31536000, immutable" },
        ],
      },
      {
        source: "/runtime-config.js",
        headers: [
          { key: "Cache-Control", value: "no-store, max-age=0" },
        ],
      },
    ];
  },
};

export default nextConfig;

