import { http } from "./client";

/**
 * 「我的密钥」—— 普通用户唯一可写的模型相关配置。
 * 与后台渠道（afv_api_config）物理隔离，只存用户自己的密钥，按用户强绑定。
 */

/** 用户自带密钥（列表返回时密钥已脱敏） */
export interface UserApiKey {
  id: number;
  userId: number;
  platform: string;
  apiKey: string;
  appId: string | null;
  appSecret: string | null;
  status: number;
  remark: string | null;
  createTime?: string;
  updateTime?: string;
}

/** 保存我的密钥请求 */
export interface MyApiKeySaveReq {
  platform: string;
  apiKey: string;
  appId?: string;
  appSecret?: string;
}

export const myApiKeyApi = {
  /** 我的密钥列表（密钥已脱敏） */
  list: () => http.get<never, UserApiKey[]>("/api/ai/my-api-key/list"),

  /** 保存我的密钥（按平台覆盖更新） */
  save: (data: MyApiKeySaveReq) =>
    http.post<never, boolean>("/api/ai/my-api-key/save", data),

  /** 删除我的密钥 */
  delete: (id: number) =>
    http.delete<never, boolean>(`/api/ai/my-api-key/delete?id=${id}`),
};
