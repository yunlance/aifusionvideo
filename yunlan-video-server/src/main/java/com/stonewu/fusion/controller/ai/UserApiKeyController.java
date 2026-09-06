package com.stonewu.fusion.controller.ai;

import com.stonewu.fusion.common.CommonResult;
import com.stonewu.fusion.controller.ai.vo.MyApiKeySaveReqVO;
import com.stonewu.fusion.entity.ai.UserApiKey;
import com.stonewu.fusion.service.ai.UserApiKeyService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import static com.stonewu.fusion.common.CommonResult.success;

/**
 * 我的密钥：普通用户唯一可写的模型相关配置。
 * <p>
 * 安全约束：所有操作强绑定 SecurityUtils 当前用户，A 用户永远读写不到 B 用户的密钥。
 */
@Tag(name = "我的密钥")
@RestController
@RequestMapping("/api/ai/my-api-key")
@RequiredArgsConstructor
public class UserApiKeyController {

    private final UserApiKeyService userApiKeyService;

    @GetMapping("/list")
    @Operation(summary = "我的密钥列表（密钥已脱敏）")
    public CommonResult<List<UserApiKey>> list() {
        return success(userApiKeyService.listMine());
    }

    @PostMapping("/save")
    @Operation(summary = "保存我的密钥（按平台，覆盖更新）")
    public CommonResult<Boolean> save(@RequestBody MyApiKeySaveReqVO req) {
        userApiKeyService.saveMine(req.getPlatform(), req.getApiKey(), req.getAppId(), req.getAppSecret());
        return success(true);
    }

    @DeleteMapping("/delete")
    @Operation(summary = "删除我的密钥")
    @Parameter(name = "id", description = "密钥ID", required = true)
    public CommonResult<Boolean> delete(@RequestParam("id") Long id) {
        userApiKeyService.deleteMine(id);
        return success(true);
    }
}
