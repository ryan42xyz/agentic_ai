# OpenSpec 使用指南

## 一、OpenSpec 是什么？

OpenSpec 是一个**规范驱动的开发系统**，它的核心作用是：

- **把需求/设计/任务/约束从对话里拽出来，落到 Git 的机制**
- **不是代码生成器、IDE 插件或 Agent 框架**
- **是一个规范驱动的文件结构 + 操作协议**

## 二、核心概念

### 1. 四个核心文件/目录

```
openspec/
├── project.md        # 项目"世界观"（长期上下文缓存）
├── AGENTS.md         # 给 AI 的行为边界
├── specs/            # 稳定后的规范（事实源）
├── changes/          # 每一次变更的完整快照
└── CHANGELOG.md      # 变更历史
```

**关键认知**：
- `project.md` ≈ 长期上下文缓存
- `changes/xxx/` ≈ 一次认知决策的"commit log（可读版）"
- `specs/` ≈ 你未来交接、复盘、迁移时最值钱的东西

### 2. 标准工作循环

OpenSpec 的核心工作流程是四个步骤的循环：

```
proposal → review → apply → archive
```

1. **proposal（提案）**：我要做什么？为什么？
2. **review（审查）**：我和 AI 对齐了吗？
3. **apply（应用）**：让 AI 按文档干活
4. **archive（归档）**：把结果固化为规范

## 三、基本命令

### 初始化项目

```bash
# 在仓库根目录运行
openspec init
```

这会创建 `openspec/` 目录结构和初始文件。

### 查看状态

```bash
# 列出所有变更
openspec list

# 列出所有规范
openspec list --specs

# 查看项目状态
openspec status
```

### 创建变更提案

```bash
# 创建新的变更提案
openspec change new <change-name>

# 或者使用交互式方式
openspec new
```

### 查看变更详情

```bash
# 查看特定变更
openspec show <change-name>

# 以 JSON 格式查看
openspec show <change-name> --format json

# 以 Markdown 格式查看
openspec show <change-name> --format markdown
```

### 验证变更

```bash
# 验证变更是否符合规范
openspec validate <change-name>

# 验证所有变更
openspec validate
```

### 归档变更

```bash
# 归档已完成的变更，更新主规范
openspec archive <change-name>

# 归档时自动更新 specs/
openspec archive <change-name> --update-specs
```

### 查看交互式仪表板

```bash
# 打开交互式视图
openspec view
```

## 四、在 Cursor / AI 工具中使用

### 使用命令前缀

在 Cursor 或其他 AI 工具中，可以使用命令前缀：

```
/openspec:proposal    # 创建提案
/openspec:apply       # 应用变更
/openspec:archive     # 归档变更
```

### 工作流程示例

#### 场景 1：添加新功能

1. **Proposal（提案）**
   ```
   /openspec:proposal
   我要添加用户认证功能，包括登录、注册、JWT token 管理
   ```

2. **Review（审查）**
   - AI 会生成变更提案文档
   - 检查是否符合项目架构和约束
   - 确认技术选型

3. **Apply（应用）**
   ```
   /openspec:apply <change-name>
   ```
   - AI 根据提案文档实现代码

4. **Archive（归档）**
   ```
   /openspec:archive <change-name>
   ```
   - 将完成的变更归档到 `specs/`
   - 更新 `project.md` 和 `CHANGELOG.md`

#### 场景 2：重构代码

1. **Proposal**
   ```
   /openspec:proposal
   重构用户服务模块，将单体拆分为微服务
   ```

2. **Review**
   - 检查架构影响
   - 确认模块边界

3. **Apply**
   - 执行重构

4. **Archive**
   - 更新架构文档

## 五、project.md 的使用

`project.md` 是项目的"世界观"文档，包含：

- **项目概述**：这个项目是做什么的
- **技术栈**：使用的语言、框架、工具
- **架构风格**：单体、微服务、分层等
- **模块边界**：代码如何组织
- **约束条件**：编码规范、测试要求等

### 何时更新 project.md

- 项目初始化时
- 技术栈发生重大变化时
- 架构模式改变时
- 上下文丢失需要重建时

### 更新方法

```bash
# 使用 openspec-setup 技能自动更新
# 或者手动编辑 openspec/project.md
```

## 六、AGENTS.md 的使用

`AGENTS.md` 定义 AI 代理的行为边界：

- **角色定义**：不同 AI 代理的职责
- **工作流程**：代理如何协作
- **约束条件**：什么能做，什么不能做
- **交互模式**：代理之间的通信方式

### 示例结构

```markdown
## Agent Roles

### Frontend Developer
- 负责前端代码
- 遵循 React 最佳实践
- 不修改后端代码

### Backend Developer
- 负责 API 和数据库
- 遵循 RESTful 设计
- 不修改前端代码
```

## 七、变更提案结构

每个变更提案（在 `changes/` 目录下）通常包含：

```
changes/<change-name>/
├── proposal.md      # 变更提案
├── review.md        # 审查意见
├── implementation/  # 实现代码
└── archive.md       # 归档说明
```

## 八、最佳实践

### 1. 始终从 Proposal 开始

不要直接写代码，先创建提案：
- 明确目标
- 说明原因
- 定义范围

### 2. Review 阶段很重要

在 Apply 之前，确保：
- 提案符合项目架构
- 技术选型合理
- 影响范围清晰

### 3. 及时 Archive

完成变更后立即归档：
- 保持 `specs/` 最新
- 更新文档
- 便于后续参考

### 4. 保持 project.md 更新

定期更新 `project.md`：
- 反映项目当前状态
- 帮助新成员理解项目
- 作为 AI 的上下文

### 5. 使用 UNKNOWN 标记

如果信息缺失，使用 `UNKNOWN` 标记：
- 不要猜测
- 明确标注不确定性
- 后续补充

## 九、常见问题

### Q: OpenSpec 和 Git 有什么区别？

A: OpenSpec 是 Git 的补充：
- Git 管理代码版本
- OpenSpec 管理需求和规范
- 两者结合，实现"需求即代码"

### Q: 必须使用 CLI 吗？

A: 不是必须的。OpenSpec 的核心是文件结构：
- CLI 提供便利操作
- 也可以手动编辑文件
- AI 工具可以直接读取文件

### Q: 如何与现有项目集成？

A: 在现有项目中运行 `openspec init`：
- 不会修改现有代码
- 只创建 `openspec/` 目录
- 可以逐步迁移到 OpenSpec 工作流

### Q: 变更提案太复杂怎么办？

A: 拆分成多个小变更：
- 每个变更聚焦一个目标
- 小变更更容易审查和应用
- 可以按顺序执行

## 十、进阶用法

### 使用模板

```bash
# 查看可用模板
openspec templates

# 使用特定模板创建变更
openspec new --template <template-name>
```

### 使用工作流模式

```bash
# 查看可用模式
openspec schemas

# 使用特定模式
openspec new --schema <schema-name>
```

### 验证规范

```bash
# 验证所有规范
openspec validate --specs

# 验证特定规范
openspec validate <spec-name>
```

## 十一、与 AI 工具集成

### Cursor

在 Cursor 中，OpenSpec 文件会自动被 AI 读取：
- `project.md` 提供项目上下文
- `AGENTS.md` 定义 AI 行为
- `changes/` 记录变更历史

### CLI 工具

在命令行中使用 OpenSpec：
- 创建变更提案
- 查看项目状态
- 验证规范

### 其他工具

OpenSpec 的文件格式是标准的 Markdown：
- 任何工具都可以读取
- 不依赖特定 IDE
- 版本控制友好

---

**记住**：OpenSpec 的核心是**规范驱动**，不是代码驱动。先有规范，再有代码。
