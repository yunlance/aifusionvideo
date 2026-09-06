package com.stonewu.fusion.service.project;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.stonewu.fusion.common.PageResult;
import com.stonewu.fusion.common.BusinessException;
import com.stonewu.fusion.entity.asset.Asset;
import com.stonewu.fusion.entity.asset.AssetItem;
import com.stonewu.fusion.entity.project.Project;
import com.stonewu.fusion.entity.project.ProjectMember;
import com.stonewu.fusion.entity.script.Script;
import com.stonewu.fusion.entity.script.ScriptEpisode;
import com.stonewu.fusion.entity.script.ScriptSceneItem;
import com.stonewu.fusion.entity.storyboard.Storyboard;
import com.stonewu.fusion.entity.storyboard.StoryboardEpisode;
import com.stonewu.fusion.entity.storyboard.StoryboardItem;
import com.stonewu.fusion.entity.storyboard.StoryboardScene;
import com.stonewu.fusion.mapper.asset.AssetItemMapper;
import com.stonewu.fusion.mapper.asset.AssetMapper;
import com.stonewu.fusion.mapper.project.ProjectMapper;
import com.stonewu.fusion.mapper.project.ProjectMemberMapper;
import com.stonewu.fusion.mapper.script.ScriptEpisodeMapper;
import com.stonewu.fusion.mapper.script.ScriptMapper;
import com.stonewu.fusion.mapper.script.ScriptSceneItemMapper;
import com.stonewu.fusion.mapper.storyboard.StoryboardEpisodeMapper;
import com.stonewu.fusion.mapper.storyboard.StoryboardItemMapper;
import com.stonewu.fusion.mapper.storyboard.StoryboardMapper;
import com.stonewu.fusion.mapper.storyboard.StoryboardSceneMapper;
import com.stonewu.fusion.security.SecurityUtils;
import com.stonewu.fusion.service.project.dto.ProjectWorkspaceOverview;
import com.stonewu.fusion.service.storyboard.dto.StoryboardStatistics;
import com.stonewu.fusion.service.system.SystemConfigService;
import com.stonewu.fusion.service.team.TeamService;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 项目服务
 */
@Service
@RequiredArgsConstructor
public class ProjectService {

    private static final int OWNER_TYPE_PERSONAL = 1;
    private static final int OWNER_TYPE_TEAM = 2;
    private static final String DEMO_PROJECT_CONFIG_KEY = "demo_project_id";

    private final ProjectMapper projectMapper;
    private final ProjectMemberMapper memberMapper;
    private final AssetMapper assetMapper;
    private final AssetItemMapper assetItemMapper;
    private final ScriptMapper scriptMapper;
    private final ScriptEpisodeMapper scriptEpisodeMapper;
    private final ScriptSceneItemMapper scriptSceneItemMapper;
    private final StoryboardMapper storyboardMapper;
    private final StoryboardEpisodeMapper storyboardEpisodeMapper;
    private final StoryboardSceneMapper storyboardSceneMapper;
    private final StoryboardItemMapper storyboardItemMapper;
    private final TeamService teamService;
    private final SystemConfigService systemConfigService;

    @Cacheable(value = "project", key = "#id")
    public Project getById(Long id) {
        Project project = projectMapper.selectById(id);
        if (project == null) throw new BusinessException("项目不存在: " + id);
        return project;
    }

    /**
     * 项目分页。与 {@link #listAccessibleByUser} 使用同一套可见范围条件，
     * 避免接口被直接调用时越权返回所有人的项目（此前查询条件为 null，等于全表）。
     */
    public PageResult<Project> page(int pageNo, int pageSize) {
        LambdaQueryWrapper<Project> wrapper = buildAccessibleWrapper(SecurityUtils.getCurrentUserId());
        wrapper.orderByDesc(Project::getCreateTime);
        return PageResult.of(projectMapper.selectPage(new Page<>(pageNo, pageSize), wrapper));
    }

    @Cacheable(value = "project", key = "'owner:' + #ownerType + ':' + #ownerId")
    public List<Project> listByOwner(Integer ownerType, Long ownerId) {
        return projectMapper.selectList(new LambdaQueryWrapper<Project>()
                .eq(Project::getOwnerType, ownerType)
                .eq(Project::getOwnerId, ownerId)
                .orderByDesc(Project::getCreateTime));
    }

    /**
     * 当前用户可见的项目：系统演示项目 + 自己的个人项目 + 所属团队的项目。
     * <p>
     * 修复：此前会一并返回「团队内其他成员的个人项目」。单团队架构下所有用户
     * 同属一个默认团队，这等同于所有人互相可见彼此的私有项目。
     */
    public List<Project> listAccessibleByUser(Long userId) {
        LambdaQueryWrapper<Project> wrapper = buildAccessibleWrapper(userId);
        wrapper.orderByDesc(Project::getCreateTime);
        return projectMapper.selectList(wrapper);
    }

    /**
     * 构造可见范围查询条件：演示项目 OR 自己的个人项目 OR 所属团队项目。
     * 无登录上下文（userId 为 null）时仅返回演示项目。
     */
    private LambdaQueryWrapper<Project> buildAccessibleWrapper(Long userId) {
        LambdaQueryWrapper<Project> wrapper = new LambdaQueryWrapper<>();
        Long demoProjectId = getDemoProjectId();
        if (userId == null) {
            return demoProjectId == null
                    ? wrapper.eq(Project::getId, -1L)
                    : wrapper.eq(Project::getId, demoProjectId);
        }
        Long currentTeamId = teamService.getCurrentTeamIdByUser(userId);
        wrapper.and(w -> {
            if (demoProjectId != null) {
                w.eq(Project::getId, demoProjectId).or();
            }
            w.eq(Project::getOwnerType, OWNER_TYPE_PERSONAL).eq(Project::getOwnerId, userId);
            if (currentTeamId != null) {
                w.or().eq(Project::getOwnerType, OWNER_TYPE_TEAM).eq(Project::getOwnerId, currentTeamId);
            }
        });
        return wrapper;
    }

    public Long getDemoProjectId() {
        String value = systemConfigService.getValue(DEMO_PROJECT_CONFIG_KEY);
        if (StrUtil.isBlank(value)) {
            return null;
        }
        try {
            return Long.parseLong(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /**
     * 判断指定项目是否为演示项目（系统内置参考数据，不可删除/修改）。
     */
    public boolean isDemoProject(Long projectId) {
        if (projectId == null) {
            return false;
        }
        Long demoProjectId = getDemoProjectId();
        return demoProjectId != null && demoProjectId.equals(projectId);
    }

    public boolean canAccessProject(Long projectId, Long userId) {
        return canAccessProject(getById(projectId), userId);
    }

    /**
     * 判断用户能否访问项目：演示项目（所有人可见） / 自己的个人项目 / 项目成员 / 所属团队项目。
     * <p>
     * 修复：此前末尾会将「同团队其他成员的个人项目」判为可访问。单团队架构下
     * 所有用户同属一个默认团队，这等于所有人可互看彼此的私有项目。
     */
    public boolean canAccessProject(Project project, Long userId) {
        if (project == null || userId == null) {
            return false;
        }
        Long demoProjectId = getDemoProjectId();
        if (demoProjectId != null && demoProjectId.equals(project.getId())) {
            return true;
        }
        if (Integer.valueOf(OWNER_TYPE_PERSONAL).equals(project.getOwnerType())
                && userId.equals(project.getOwnerId())) {
            return true;
        }
        if (isMember(project.getId(), userId)) {
            return true;
        }
        Long currentTeamId = teamService.getCurrentTeamIdByUser(userId);
        return currentTeamId != null
                && Integer.valueOf(OWNER_TYPE_TEAM).equals(project.getOwnerType())
                && currentTeamId.equals(project.getOwnerId());
    }

    /**
     * 归属断言：无访问权限时抛 403，供 Controller 在读写项目前统一校验。
     */
    public void assertAccessible(Long projectId, Long userId) {
        if (!canAccessProject(projectId, userId)) {
            throw new BusinessException(403, "无权访问该项目");
        }
    }

    public ProjectWorkspaceOverview getWorkspaceOverview(Long projectId) {
        getById(projectId);
        Script script = findEffectiveScript(projectId);
        Storyboard storyboard = findEffectiveStoryboard(projectId, script);
        return buildWorkspaceOverview(script, storyboard);
    }

    @CacheEvict(value = { "project", "script", "storyboard" }, allEntries = true)
    @Transactional
    public ProjectWorkspaceOverview initializeWorkspace(Long projectId) {
        Project project = lockProject(projectId);
        Script script = findEffectiveScript(projectId);
        if (script == null) {
            script = createProjectScript(project);
        }

        Storyboard storyboard = findEffectiveStoryboard(projectId, script);
        if (storyboard == null) {
            storyboard = createProjectStoryboard(project, script);
        }
        return buildWorkspaceOverview(script, storyboard);
    }

    private ProjectWorkspaceOverview buildWorkspaceOverview(Script script, Storyboard storyboard) {

        long scriptEpisodeCount = script == null ? 0 : scriptEpisodeMapper.selectCount(
                new LambdaQueryWrapper<ScriptEpisode>().eq(ScriptEpisode::getScriptId, script.getId()));
        long scriptSceneCount = script == null ? 0 : scriptSceneItemMapper.selectCount(
                new LambdaQueryWrapper<ScriptSceneItem>().eq(ScriptSceneItem::getScriptId, script.getId()));
        StoryboardStatistics storyboardStatistics = storyboard == null
                ? new StoryboardStatistics(0, 0, 0)
                : new StoryboardStatistics(
                        storyboardEpisodeMapper.selectCount(new LambdaQueryWrapper<StoryboardEpisode>()
                                .eq(StoryboardEpisode::getStoryboardId, storyboard.getId())),
                        storyboardSceneMapper.selectCount(new LambdaQueryWrapper<StoryboardScene>()
                                .eq(StoryboardScene::getStoryboardId, storyboard.getId())),
                        storyboardItemMapper.selectCount(new LambdaQueryWrapper<StoryboardItem>()
                                .eq(StoryboardItem::getStoryboardId, storyboard.getId())));
        return new ProjectWorkspaceOverview(
                script,
                scriptEpisodeCount,
                scriptSceneCount,
                storyboard,
                storyboardStatistics);
    }

    @CacheEvict(value = { "project", "script", "storyboard" }, allEntries = true)
    @Transactional
    public Project create(Project project) {
        validateProjectMediaUrls(project);
        applyCurrentTeamOwnership(project);
        projectMapper.insert(project);
        Script script = createProjectScript(project);
        createProjectStoryboard(project, script);
        return project;
    }

    @CacheEvict(value = { "project", "script", "storyboard" }, allEntries = true)
    @Transactional
    public Project update(Project project) {
        getById(project.getId());
        validateProjectMediaUrls(project);
        projectMapper.updateById(project);
        if (StrUtil.isNotBlank(project.getName())) {
            scriptMapper.update(null, new LambdaUpdateWrapper<Script>()
                    .eq(Script::getProjectId, project.getId())
                    .set(Script::getTitle, project.getName()));
            storyboardMapper.update(null, new LambdaUpdateWrapper<Storyboard>()
                    .eq(Storyboard::getProjectId, project.getId())
                    .set(Storyboard::getTitle, project.getName()));
        }
        return projectMapper.selectById(project.getId());
    }

    @CacheEvict(
            value = {
                    "project", "projectMember", "asset", "assetItem", "script", "episode", "scene",
                    "storyboard", "storyboardEpisode", "storyboardScene", "storyboardItem", "storyboardStatistics"
            },
            allEntries = true)
    @Transactional
    public void delete(Long id) {
        Long demoProjectId = getDemoProjectId();
        if (demoProjectId != null && demoProjectId.equals(id)) {
            throw new BusinessException("演示项目为系统内置参考数据，不可删除");
        }
        List<Storyboard> storyboards = storyboardMapper.selectList(
                new LambdaQueryWrapper<Storyboard>().eq(Storyboard::getProjectId, id));
        for (Storyboard storyboard : storyboards) {
            storyboardItemMapper.delete(new LambdaQueryWrapper<StoryboardItem>()
                    .eq(StoryboardItem::getStoryboardId, storyboard.getId()));
            storyboardSceneMapper.delete(new LambdaQueryWrapper<StoryboardScene>()
                    .eq(StoryboardScene::getStoryboardId, storyboard.getId()));
            storyboardEpisodeMapper.delete(new LambdaQueryWrapper<StoryboardEpisode>()
                    .eq(StoryboardEpisode::getStoryboardId, storyboard.getId()));
        }
        storyboardMapper.delete(new LambdaQueryWrapper<Storyboard>()
                .eq(Storyboard::getProjectId, id));

        List<Script> scripts = scriptMapper.selectList(
                new LambdaQueryWrapper<Script>().eq(Script::getProjectId, id));
        for (Script script : scripts) {
            scriptSceneItemMapper.delete(new LambdaQueryWrapper<ScriptSceneItem>()
                    .eq(ScriptSceneItem::getScriptId, script.getId()));
            scriptEpisodeMapper.delete(new LambdaQueryWrapper<ScriptEpisode>()
                    .eq(ScriptEpisode::getScriptId, script.getId()));
        }
        scriptMapper.delete(new LambdaQueryWrapper<Script>()
                .eq(Script::getProjectId, id));

        // 级联删除项目下的所有资产及其子项
        List<Asset> assets = assetMapper.selectList(
                new LambdaQueryWrapper<Asset>().eq(Asset::getProjectId, id));
        for (Asset asset : assets) {
            assetItemMapper.delete(
                    new LambdaQueryWrapper<AssetItem>().eq(AssetItem::getAssetId, asset.getId()));
        }
        if (!assets.isEmpty()) {
            assetMapper.delete(new LambdaQueryWrapper<Asset>().eq(Asset::getProjectId, id));
        }
        // 删除项目成员
        memberMapper.delete(new LambdaQueryWrapper<ProjectMember>().eq(ProjectMember::getProjectId, id));
        // 删除项目本身
        projectMapper.deleteById(id);
    }

    // ========== 成员管理 ==========

    public boolean isMember(Long projectId, Long userId) {
        return memberMapper.exists(new LambdaQueryWrapper<ProjectMember>()
                .eq(ProjectMember::getProjectId, projectId)
                .eq(ProjectMember::getUserId, userId));
    }

    @Cacheable(value = "projectMember", key = "#projectId")
    public List<ProjectMember> listMembers(Long projectId) {
        return memberMapper.selectList(
                new LambdaQueryWrapper<ProjectMember>().eq(ProjectMember::getProjectId, projectId));
    }

    @CacheEvict(value = "projectMember", allEntries = true)
    @Transactional
    public ProjectMember addMember(Long projectId, Long userId, Integer role) {
        if (isMember(projectId, userId)) {
            throw new BusinessException("该用户已是项目成员");
        }
        ProjectMember member = ProjectMember.builder()
                .projectId(projectId)
                .userId(userId)
                .role(role)
                .build();
        memberMapper.insert(member);
        return member;
    }

    @CacheEvict(value = "projectMember", allEntries = true)
    @Transactional
    public void removeMember(Long projectId, Long userId) {
        memberMapper.delete(new LambdaQueryWrapper<ProjectMember>()
                .eq(ProjectMember::getProjectId, projectId)
                .eq(ProjectMember::getUserId, userId));
    }

    private void validateProjectMediaUrls(Project project) {
        if (project == null) {
            return;
        }
        rejectDataUrl(project.getCoverUrl(), "coverUrl");
        rejectDataUrl(project.getArtStyleImageUrl(), "artStyleImageUrl");
    }

    /**
     * 项目归属：一律归创建者个人。
     * <p>
     * 修复：此前跟随团队归属（ownerType=团队）。单团队架构下所有用户同属一个默认团队，
     * 导致任何人新建的项目对该团队内所有用户可见。
     */
    private void applyCurrentTeamOwnership(Project project) {
        Long currentUserId = SecurityUtils.getCurrentUserId();
        if (currentUserId == null) {
            return;
        }
        project.setOwnerType(OWNER_TYPE_PERSONAL);
        project.setOwnerId(currentUserId);
    }

    private Project lockProject(Long projectId) {
        Project project = projectMapper.selectOne(new LambdaQueryWrapper<Project>()
                .eq(Project::getId, projectId)
                .last("FOR UPDATE"));
        if (project == null) {
            throw new BusinessException("项目不存在: " + projectId);
        }
        return project;
    }

    private Script findEffectiveScript(Long projectId) {
        return scriptMapper.selectOne(new LambdaQueryWrapper<Script>()
                .eq(Script::getProjectId, projectId)
                .orderByDesc(Script::getCreateTime)
                .orderByDesc(Script::getId)
                .last("LIMIT 1"));
    }

    private Storyboard findEffectiveStoryboard(Long projectId, Script script) {
        if (script == null) {
            return null;
        }
        return storyboardMapper.selectOne(new LambdaQueryWrapper<Storyboard>()
                .eq(Storyboard::getProjectId, projectId)
                .eq(Storyboard::getScriptId, script.getId())
                .orderByDesc(Storyboard::getCreateTime)
                .orderByDesc(Storyboard::getId)
                .last("LIMIT 1"));
    }

    private Script createProjectScript(Project project) {
        Script script = Script.builder()
                .projectId(project.getId())
                .title(project.getName())
                .scope(project.getScope())
                .ownerType(project.getOwnerType())
                .ownerId(project.getOwnerId())
                .build();
        scriptMapper.insert(script);
        return script;
    }

    private Storyboard createProjectStoryboard(Project project, Script script) {
        Storyboard storyboard = Storyboard.builder()
                .projectId(project.getId())
                .scriptId(script.getId())
                .title(project.getName())
                .scope(project.getScope())
                .ownerType(project.getOwnerType())
                .ownerId(project.getOwnerId())
                .build();
        storyboardMapper.insert(storyboard);
        return storyboard;
    }

    private void rejectDataUrl(String rawUrl, String fieldName) {
        if (StrUtil.isNotBlank(rawUrl) && StrUtil.startWithIgnoreCase(rawUrl.trim(), "data:")) {
            throw new BusinessException(fieldName + " 不支持 base64，请先调用 /api/storage/upload 上传二进制文件");
        }
    }
}
