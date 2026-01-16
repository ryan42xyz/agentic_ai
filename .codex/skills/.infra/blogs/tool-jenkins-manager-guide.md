# Jenkins Manager 使用指南

## 📋 功能概述

Jenkins Manager 是一个集中化的 Jenkins 任务管理和监控工具，用于简化 CI/CD 流水线的管理和调试。它提供了一个统一的 Web 界面来查看、搜索、触发和监控所有 Jenkins 任务。

### 核心功能

1. **多环境支持**：支持新旧两套 Jenkins 环境的无缝切换
2. **任务分类管理**：按功能分类展示 Jenkins 任务（构建、部署、代码管理等）
3. **实时状态监控**：查看任务最新构建状态和历史记录
4. **参数化构建**：支持使用最新参数或自定义参数触发构建
5. **Git 提交追踪**：自动提取并显示每次构建的 Git commit ID
6. **并发性能优化**：使用线程池并发获取任务信息，30% 性能提升
7. **搜索和过滤**：快速搜索和过滤任务

### 技术架构

- **后端**：Python + FastAPI
- **配置管理**：YAML 配置文件 (`config.yaml`)
- **Jenkins API**：RESTful API 集成
- **并发处理**：ThreadPoolExecutor 线程池
- **前端**：HTML + JavaScript + Bootstrap

---

## 🌐 支持的 Jenkins 环境

### 1. 新环境 (Current)

**URL**: `http://jenkins-mgt.dv-api.com`

**特点**：
- 主要生产环境
- 最新的 Jenkins 版本和插件
- 所有新项目和流水线
- 推荐使用的环境

**配置**：
```yaml
environments:
  current:
    name: "New Environment (jenkins-mgt.dv-api.com)"
    jenkins:
      url: "http://jenkins-mgt.dv-api.com"
      username: "ruishao"
      token: "1112c56ecaeaf23abae6c6f6a86f6d0414"
```

### 2. 旧环境 (Legacy)

**URL**: `http://jenkins-k8s-mgt.datavisor.io/`

**特点**：
- 遗留系统
- 部分历史任务
- 逐步迁移中
- 仅用于特定场景

**配置**：
```yaml
environments:
  legacy:
    name: "Old Environment (jenkins-k8s-mgt.datavisor.io)"
    jenkins:
      url: "http://jenkins-k8s-mgt.datavisor.io/"
      username: "ruishao"
      token: "115983bba78d4ec597f5a086ba17c75ea0"
```

---

## 📂 任务分类体系

### 1. Build Image Pipeline (构建镜像流水线)

**图标**: 🐳 Docker  
**顺序**: 1  
**说明**: 完整的 Docker 镜像构建流水线链

#### 任务列表

| 顺序 | 任务名称 | 说明 |
|------|---------|------|
| 1 | `global-entrypoint` | 全局入口流水线，用于多区域部署 |
| 2 | `production-build-cron` | 定时生产构建流水线，用于自动化构建 |
| 3 | `pre-process-general-build-docker-image` | Docker 镜像构建预处理 |
| 4 | `general-build-docker-image` | 通用 Docker 镜像构建流水线 |
| 5 | `general-build-docker-image-fp` | Feature Platform Docker 镜像构建 |
| 6 | `general-build-docker-image-java17` | Java 17 应用 Docker 镜像构建 |
| 7 | `build-charts` | Helm charts 构建流水线 |

**使用场景**：
- 构建新的 Docker 镜像
- 更新现有镜像版本
- 自动化定时构建
- 多架构镜像构建

---

### 2. Deployment Pipeline (部署流水线)

**图标**: 🚀 Rocket  
**顺序**: 2  
**说明**: 应用部署和管理

#### 任务列表

| 顺序 | 任务名称 | 说明 |
|------|---------|------|
| 1 | `continuous-deployment-mgt` | 管理集群的持续部署 |

**使用场景**：
- 部署新版本到管理集群
- 持续集成/持续部署 (CI/CD)
- 自动化部署流程

---

### 3. Code Management (代码管理)

**图标**: 🔀 Code Branch  
**顺序**: 3  
**说明**: 代码集成和管理工具

#### 任务列表

| 顺序 | 任务名称 | 说明 |
|------|---------|------|
| 1 | `cherry-pick-code` | 跨分支 cherry-pick 代码 |
| 2 | `land-code-multiple-repo` | 将代码合并到多个仓库 |

**使用场景**：
- 将特定提交应用到不同分支
- 多仓库代码同步
- 代码合并和集成

---

### 4. Standalone Jobs (独立任务)

**图标**: 🛠️ Tools  
**顺序**: 5  
**说明**: 独立的实用工具任务

#### 任务列表

| 顺序 | 任务名称 | 说明 |
|------|---------|------|
| 1 | `build-jenkins-docker` | Jenkins Docker 镜像构建 |

**使用场景**：
- 构建 Jenkins 自身的 Docker 镜像
- 更新 Jenkins 版本

---

### 5. Review & Release (审核与发布)

**图标**: 📁 Folder  
**顺序**: 6  
**说明**: 审核和发布管理任务

#### 任务列表（19 个任务）

| 顺序 | 任务名称 | 说明 |
|------|---------|------|
| 1 | `feature-platform-deploy` | Feature Platform 部署 |
| 2 | `feature-platform-signoff` | Feature Platform 签核 |
| 3 | `publish-ngsc-docker-image` | 发布 NGSC Docker 镜像 |
| 4 | `publish-ui-api-server-docker-image` | 发布 UI API Server Docker 镜像 |
| 5 | `publish-ui-external-docker-image` | 发布 UI External Docker 镜像 |
| 6 | `release-build-binary` | 发布构建二进制文件 |
| 7 | `release-deploy` | 发布部署 |
| 8 | `release-hotfix-process` | 发布热修复流程 |
| 9 | `release-normal-process` | 发布正常流程 |
| 10 | `release-platform-fast-signoff` | 平台快速签核 |
| 11 | `release-platform-rt-signoff` | 平台实时签核 |
| 12 | `release-platform-rt-signoff-preprocessor` | 平台实时签核预处理器 |
| 13 | `release-platform-signoff` | 平台签核 |
| 14 | `release-platform-signoff-k8s` | 平台 K8s 签核 |
| 15 | `release-platform-signoff-validation` | 平台签核验证 |
| 16 | `release-request-approval` | 发布请求审批 |
| 17 | `release-review-approval` | 发布审核批准 |
| 18 | `release-rollback-process` | 发布回滚流程 |
| 19 | `release-update-info` | 发布更新信息 |

**使用场景**：
- 生产环境发布流程
- 代码审核和签核
- 热修复发布
- 版本回滚

---

## 🚀 使用方法

### Web UI 使用

#### 1. 访问页面

打开浏览器访问：`http://localhost:8000/jenkins`

#### 2. 切换环境

在页面顶部选择环境：
- **New Environment**: 新 Jenkins 环境（推荐）
- **Old Environment**: 旧 Jenkins 环境（遗留）

#### 3. 查看任务列表

任务按分类展示，每个任务卡片显示：
- **任务名称**
- **最新构建状态**（成功/失败/进行中）
- **最新构建时间**
- **Git Commit ID**（短格式）
- **快速操作按钮**

#### 4. 任务操作

**查看详情**：点击任务卡片展开，显示最近 5 次构建记录

**触发构建**：
- **Build with Latest Parameters**: 使用最新一次构建的参数
- **Build with Parameters**: 自定义参数（跳转到 Jenkins）

**查看日志**：
- **Console Output**: 查看构建日志
- **Replay**: 重放构建

#### 5. 搜索任务

在搜索框输入关键词，实时过滤任务列表

#### 6. 刷新数据

点击"Refresh"按钮刷新所有任务状态

---

## 🔧 API 使用

### 1. 获取所有任务

```bash
curl "http://localhost:8000/jenkins/api/jobs"
```

**响应示例**：
```json
{
  "success": true,
  "jobs": [
    {
      "job_name": "global-entrypoint",
      "latest_build_id": 123,
      "latest_success_build_id": 122,
      "latest_build_status": "SUCCESS",
      "latest_build_timestamp": "2025-12-28T10:00:00",
      "jenkins_url": "http://jenkins-mgt.dv-api.com/job/global-entrypoint",
      "console_url": "http://jenkins-mgt.dv-api.com/job/global-entrypoint/123/console",
      "latest_commit_id": "abc123def456",
      "latest_commit_short": "abc123d",
      "category": "Build Image Pipeline",
      "folder_name": "Build Image Pipeline",
      "pipeline_order": 1
    }
  ],
  "environment": "New Environment (jenkins-mgt.dv-api.com)",
  "total": 30
}
```

### 2. 获取单个任务详情

```bash
curl "http://localhost:8000/jenkins/api/jobs/global-entrypoint"
```

### 3. 获取任务最近构建

```bash
curl "http://localhost:8000/jenkins/api/jobs/global-entrypoint/recent-builds?limit=10"
```

**响应示例**：
```json
{
  "success": true,
  "job_name": "global-entrypoint",
  "builds": [
    {
      "build_id": 123,
      "status": "SUCCESS",
      "timestamp": "2025-12-28T10:00:00",
      "duration": "5m 30s",
      "commit_id": "abc123d",
      "parameters": "branch=main, env=prod"
    }
  ],
  "total": 10
}
```

### 4. 触发构建（使用最新参数）

```bash
curl -X POST "http://localhost:8000/jenkins/api/jobs/global-entrypoint/build"
```

### 5. 切换环境

```bash
curl -X POST "http://localhost:8000/jenkins/api/switch-environment" \
  -H "Content-Type: application/json" \
  -d '{"environment": "legacy"}'
```

### 6. 获取可用环境列表

```bash
curl "http://localhost:8000/jenkins/api/environments"
```

**响应示例**：
```json
{
  "success": true,
  "environments": {
    "current": "New Environment (jenkins-mgt.dv-api.com)",
    "legacy": "Old Environment (jenkins-k8s-mgt.datavisor.io)"
  },
  "current_environment": "current"
}
```

---

## ⚙️ 配置说明

### YAML 配置文件结构

配置文件位置：`src/jenkins/config.yaml`

```yaml
# 环境配置
environments:
  current:
    name: "New Environment (jenkins-mgt.dv-api.com)"
    jenkins:
      url: "http://jenkins-mgt.dv-api.com"
      username: "ruishao"
      token: "YOUR_TOKEN"
  legacy:
    name: "Old Environment (jenkins-k8s-mgt.datavisor.io)"
    jenkins:
      url: "http://jenkins-k8s-mgt.datavisor.io/"
      username: "ruishao"
      token: "YOUR_TOKEN"

# 默认环境
default_environment: "current"

# 任务分类
folders:
  - name: "Build Image Pipeline"
    description: "Complete Docker image build pipeline chain"
    icon: "fas fa-docker"
    order: 1
    pipelines:
      - name: "global-entrypoint"
        description: "Global entrypoint pipeline"
        order: 1

# 显示配置
display:
  refresh_interval: 30  # 刷新间隔（秒）
  max_description_length: 100  # 最大描述长度
  show_categories: true  # 显示分类
  default_build_limit: 25  # 默认构建数量
  job_expansion_build_limit: 5  # 任务展开时显示的构建数量
```

### 添加新任务

在 `config.yaml` 中添加新任务：

```yaml
folders:
  - name: "Your Category"
    description: "Category description"
    icon: "fas fa-icon"
    order: 10
    pipelines:
      - name: "your-new-job"
        description: "Job description"
        order: 1
```

### 修改 Jenkins 凭据

更新 `config.yaml` 中的 `username` 和 `token`：

```yaml
environments:
  current:
    jenkins:
      username: "your-username"
      token: "your-api-token"
```

**获取 Jenkins API Token**：
1. 登录 Jenkins
2. 点击右上角用户名 → Configure
3. API Token → Add new Token
4. 复制生成的 token

---

## 📊 任务状态说明

### 构建状态

| 状态 | 图标 | 颜色 | 说明 |
|------|------|------|------|
| SUCCESS | ✅ | 绿色 | 构建成功 |
| FAILURE | ❌ | 红色 | 构建失败 |
| UNSTABLE | ⚠️ | 黄色 | 构建不稳定 |
| ABORTED | 🚫 | 灰色 | 构建已中止 |
| IN_PROGRESS | ⏳ | 蓝色 | 构建进行中 |
| NOT_BUILT | ⭕ | 灰色 | 未构建 |

### Git Commit ID

- **完整 ID**: `abc123def456789...` (40 字符)
- **短 ID**: `abc123d` (7 字符)
- **显示**: 鼠标悬停显示完整 ID
- **提取**: 从 Jenkins 构建参数或环境变量中自动提取

---

## 🎓 使用场景示例

### 场景 1：构建新的 Docker 镜像

1. 访问 Jenkins Manager 页面
2. 找到 "Build Image Pipeline" 分类
3. 点击 `general-build-docker-image` 任务
4. 点击 "Build with Parameters"
5. 在 Jenkins 页面填写参数（分支、标签等）
6. 提交构建
7. 返回 Jenkins Manager 查看构建状态

### 场景 2：使用最新参数重新构建

1. 找到需要重新构建的任务
2. 点击 "Build with Latest Parameters"
3. 系统自动使用最新一次构建的参数触发新构建
4. 查看构建进度

### 场景 3：查看构建历史

1. 点击任务卡片展开
2. 查看最近 5 次构建记录
3. 点击 "Console Output" 查看详细日志
4. 点击 "Replay" 重放失败的构建

### 场景 4：切换到旧环境

1. 点击页面顶部环境选择器
2. 选择 "Old Environment"
3. 系统自动刷新并显示旧环境的任务列表
4. 执行需要的操作
5. 切换回新环境

### 场景 5：搜索特定任务

1. 在搜索框输入关键词（如 "build"）
2. 实时过滤显示匹配的任务
3. 点击任务执行操作

---

## 🔍 高级功能

### 1. 并发性能优化

**技术实现**：
- 使用 `ThreadPoolExecutor` 线程池
- 并发获取多个任务的详细信息
- 最大并发数：10 个线程

**性能提升**：
- 串行获取：30 秒
- 并发获取：21 秒
- **性能提升：30%**

**代码示例**：
```python
with ThreadPoolExecutor(max_workers=10) as executor:
    future_to_job = {
        executor.submit(self._get_job_info, job_name): job_name 
        for job_name in job_names
    }
    
    for future in as_completed(future_to_job):
        job_info = future.result()
        if job_info:
            jobs.append(job_info)
```

### 2. Git Commit ID 提取

**提取来源**：
1. Jenkins 构建参数 (`GIT_COMMIT`)
2. Jenkins 环境变量
3. 构建日志解析

**提取逻辑**：
```python
def extract_commit_id(self, build_info: Dict) -> Tuple[str, str]:
    """Extract Git commit ID from build info"""
    commit_id = ""
    
    # Try to get from actions
    for action in build_info.get('actions', []):
        if action.get('_class') == 'hudson.model.ParametersAction':
            for param in action.get('parameters', []):
                if param.get('name') == 'GIT_COMMIT':
                    commit_id = param.get('value', '')
                    break
    
    # Generate short commit ID (first 7 characters)
    commit_short = commit_id[:7] if commit_id else ""
    
    return commit_id, commit_short
```

### 3. 参数化构建

**支持的参数类型**：
- String Parameter
- Boolean Parameter
- Choice Parameter
- File Parameter

**参数提取**：
```python
def get_latest_build_parameters(self, job_name: str) -> str:
    """Get parameters from latest build"""
    build_info = self._get_latest_build_info(job_name)
    
    params = []
    for action in build_info.get('actions', []):
        if action.get('_class') == 'hudson.model.ParametersAction':
            for param in action.get('parameters', []):
                name = param.get('name')
                value = param.get('value')
                params.append(f"{name}={value}")
    
    return ", ".join(params)
```

### 4. 任务分类和排序

**分类逻辑**：
- 按 `folder` 分组
- 按 `order` 排序
- 支持自定义图标

**排序规则**：
1. Folder order（文件夹顺序）
2. Pipeline order（流水线顺序）
3. Job name（任务名称）

---

## 🐛 故障排查

### 问题 1：无法连接到 Jenkins

**症状**：API 返回连接错误

**可能原因**：
- Jenkins 服务不可用
- 网络连接问题
- URL 配置错误

**解决方案**：
1. 检查 Jenkins 服务状态
2. 验证 `config.yaml` 中的 URL
3. 测试网络连接：`curl http://jenkins-mgt.dv-api.com`

### 问题 2：认证失败

**症状**：401 Unauthorized 错误

**可能原因**：
- API Token 过期或无效
- 用户名错误

**解决方案**：
1. 重新生成 Jenkins API Token
2. 更新 `config.yaml` 中的凭据
3. 验证用户名拼写

### 问题 3：任务列表为空

**症状**：页面显示"No jobs found"

**可能原因**：
- `config.yaml` 配置错误
- Jenkins 中没有匹配的任务
- 权限不足

**解决方案**：
1. 检查 `config.yaml` 中的任务名称
2. 验证 Jenkins 中任务是否存在
3. 确认用户权限

### 问题 4：构建参数提取失败

**症状**：Latest Parameters 显示为空

**可能原因**：
- 任务从未构建过
- 构建没有参数
- API 响应格式变化

**解决方案**：
1. 手动触发一次构建
2. 检查任务是否配置了参数
3. 查看 Jenkins API 响应格式

---

## 📈 性能优化建议

1. **启用缓存**：缓存任务列表和构建信息（5 分钟）
2. **限制并发数**：根据 Jenkins 服务器性能调整线程池大小
3. **减少 API 调用**：批量获取任务信息
4. **异步刷新**：使用 WebSocket 实时更新状态
5. **分页加载**：大量任务时使用分页

---

## 🔗 相关链接

- **Jenkins 新环境**：http://jenkins-mgt.dv-api.com
- **Jenkins 旧环境**：http://jenkins-k8s-mgt.datavisor.io/
- **Jenkins Manager Web UI**：http://localhost:8000/jenkins
- **Jenkins Manager API Docs**：http://localhost:8000/luigi_job/docs

---

## 📝 更新日志

### v1.0.0 (2025-12-28)
- ✅ 初始版本发布
- ✅ 支持新旧两套 Jenkins 环境
- ✅ 任务分类管理（5 大类，30+ 任务）
- ✅ 实时状态监控
- ✅ Git Commit ID 提取
- ✅ 参数化构建支持
- ✅ 并发性能优化（30% 提升）
- ✅ Web UI 和 REST API
- ✅ 搜索和过滤功能
- ✅ 任务展开查看最近构建

---

## 💡 最佳实践

1. **定期更新配置**：及时添加新任务到 `config.yaml`
2. **使用新环境**：优先使用新 Jenkins 环境，旧环境仅用于特殊情况
3. **参数复用**：使用"Build with Latest Parameters"快速重新构建
4. **监控构建状态**：定期检查失败的构建并及时处理
5. **保持凭据安全**：不要将 API Token 提交到代码仓库
6. **合理分类**：新任务按功能分类，便于查找和管理
7. **文档同步**：任务配置变更时同步更新文档

---

*最后更新：2025-12-28*  
*作者：Infra Oncall Team*

