# OpenSpec 快速参考

## 🎯 核心概念

```
proposal → review → apply → archive
```

## 📁 目录结构

```
openspec/
├── project.md        # 项目世界观
├── AGENTS.md         # AI 行为边界
├── specs/            # 稳定规范
├── changes/          # 变更快照
└── CHANGELOG.md      # 变更历史
```

## 🚀 常用命令

### 初始化
```bash
openspec init                    # 初始化 OpenSpec
```

### 查看
```bash
openspec list                    # 列出所有变更
openspec list --specs            # 列出所有规范
openspec show <name>             # 查看变更详情
openspec view                    # 交互式仪表板
openspec status                  # 项目状态
```

### 变更管理
```bash
openspec new                     # 创建新变更（交互式）
openspec change new <name>       # 创建新变更
openspec validate <name>         # 验证变更
openspec archive <name>          # 归档变更
```

### 配置
```bash
openspec config                  # 查看配置
openspec config set <key> <val>  # 设置配置
```

## 💡 在 AI 工具中使用

### Cursor / Claude Code
```
/openspec:proposal    # 创建提案
/openspec:apply      # 应用变更
/openspec:archive    # 归档变更
```

## 📝 工作流程示例

### 添加功能
1. **提案**：`/openspec:proposal` → 描述要做什么
2. **审查**：检查提案是否符合架构
3. **应用**：`/openspec:apply <name>` → AI 实现
4. **归档**：`/openspec:archive <name>` → 更新规范

### 重构代码
1. **提案**：说明重构目标和范围
2. **审查**：确认影响范围
3. **应用**：执行重构
4. **归档**：更新架构文档

## 🔑 关键文件

### project.md
- **作用**：项目世界观，长期上下文
- **包含**：技术栈、架构、模块边界、约束
- **更新时机**：重大变更、上下文丢失时

### AGENTS.md
- **作用**：定义 AI 代理行为
- **包含**：角色、职责、约束、工作流
- **更新时机**：角色变化、流程调整时

## ⚠️ 重要原则

1. **先规范，后代码**：proposal → apply
2. **及时归档**：完成即归档到 specs/
3. **保持更新**：project.md 反映当前状态
4. **明确未知**：用 UNKNOWN 标记缺失信息
5. **小步快跑**：大变更拆成小变更

## 🆘 常见问题

**Q: 必须用 CLI 吗？**  
A: 不是。核心是文件结构，CLI 只是工具。

**Q: 如何集成现有项目？**  
A: 运行 `openspec init`，不修改现有代码。

**Q: 变更太复杂？**  
A: 拆分成多个小变更，逐个处理。

## 📚 相关文档

- [USAGE.md](./USAGE.md) - 详细使用指南
- [project.md](./project.md) - 项目规范
- [AGENTS.md](./AGENTS.md) - AI 代理规范
