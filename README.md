# codely-library

> Codely AI 技能库 — 为 Unity 中国出品的通用 AI Agent 工具提供即装即用的技能包。

[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## 关于

[codely-library](https://github.com/yuumixcode/codely-library) 是 [Codely AI](https://unity.cn/codely) 的技能仓库，提供可直接调用的技能（Skills），覆盖 Unity UPM 包脚手架生成、工作流自动化等场景。

## 技能列表

| 技能 | 说明 |
|------|------|
| [custom-package-creator](skills/custom-package-creator/SKILL.md) | 一键生成 Unity UPM 标准包目录结构（package.json、asmdef、README、CHANGELOG 等 12 项文件） |

## 使用方式

Codely AI / Gemini CLI 加载本仓库后，技能自动生效。在对话中描述任务（如"创建一个 UPM 包"），AI 会自动匹配技能并执行。

## 开发

添加新技能：

1. 在 `skills/` 下创建技能目录
2. 编写 `SKILL.md` 描述技能触发规则和工作流程
3. 按需添加辅助脚本到 `scripts/`

技能格式参考 [Claude Code Skills 规范](https://docs.claude.com/claude-code/skills/)。

## License

MIT © Unity China
