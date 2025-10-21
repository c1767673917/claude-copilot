# Claude Code Plugin System

本项目已支持Claude Code插件系统，可以将命令和代理打包成可安装的插件包。

## 插件配置

插件配置文件位于 `.claude-plugin/marketplace.json`，定义了所有可用的插件包。

## 可用插件

### 1. Requirements-Driven Development
- **描述**: 需求驱动的开发工作流，包含90%质量门控
- **命令**: `/requirements-pilot`
- **代理**: requirements-generate, requirements-code, requirements-testing, requirements-review

### 2. BMAD Agile Workflow
- **描述**: 完整的BMAD敏捷工作流（产品负责人→架构师→SM→开发→QA）
- **命令**: `/bmad-pilot`
- **代理**: bmad-po, bmad-architect, bmad-sm, bmad-dev, bmad-qa, bmad-orchestrator

### 3. Development Essentials
- **描述**: 核心开发命令套件
- **命令**: `/code`, `/debug`, `/test`, `/optimize`, `/review`, `/bugfix`, `/refactor`, `/docs`, `/ask`, `/think`
- **代理**: code, bugfix, bugfix-verify, code-optimize, debug, develop

### 4. Advanced AI Agents
- **描述**: 高级AI代理，集成GPT-5进行深度分析
- **代理**: gpt5

## 使用插件命令

### 列出所有可用插件
```bash
/plugin list
```

### 查看插件详情
```bash
/plugin info <plugin-name>
```
例如：`/plugin info requirements-driven-development`

### 安装插件
```bash
/plugin install <plugin-name>
```
例如：`/plugin install bmad-agile-workflow`

### 移除插件
```bash
/plugin remove <plugin-name>
```

## 创建自定义插件

要创建自己的插件：

1. 在 `.claude-plugin/marketplace.json` 中添加新的插件定义
2. 指定插件包含的命令和代理文件路径
3. 设置适当的元数据（版本、作者、关键词等）

示例插件结构：
```json
{
  "name": "my-custom-plugin",
  "source": "./",
  "description": "自定义插件描述",
  "version": "1.0.0",
  "commands": [
    "./commands/my-command.md"
  ],
  "agents": [
    "./agents/my-agent.md"
  ]
}
```

## 分享插件

要分享插件给其他项目：
1. 复制整个 `.claude-plugin` 目录到目标项目
2. 确保相关的命令和代理文件存在
3. 在新项目中使用 `/plugin` 命令管理插件

## 注意事项

- 插件系统遵循Claude Code的插件规范
- 所有命令和代理文件必须是有效的Markdown格式
- 插件配置支持版本管理和依赖关系
- 插件可以包含多个命令、代理和输出样式

## 相关文档

- [Claude Code插件文档](https://docs.claude.com/en/docs/claude-code/plugins)
- [示例插件仓库](https://github.com/wshobson/agents)