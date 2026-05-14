---
name: custom-package-creator
description: 为 Unity / 团结引擎一键生成标准 UPM 包目录脚手架，包含 package.json、asmdef、README、CHANGELOG、LICENSE 等全部标准文件。零依赖 Shell 脚本 + Node 脚本双版本。Triggers: 创建UPM包, 创建自定义包, 生成包结构, Unity插件脚手架, 初始化包目录, 新建Package, scaffold package, create unity package.
---

# Custom Package Creator

## 总览

一次交互完成。用户提供关键信息 → AI 自动派生剩余字段 → 展示汇总 → 确认后执行脚本。

用户需要提供 **4 个必填字段**，其余均可自动派生。

## 信息收集

向用户索要以下信息，并展示参考模板：

---

**必填字段（4 个）：**

| # | 字段 | 说明 | 格式示例 |
|---|------|------|----------|
| 1 | 正式包名 | 反向域名格式，小写+连字符，至少 3 段 | `com.runlab.aesir-inspector` |
| 2 | Unity 项目路径 | 项目根目录的**绝对路径** | `/path/to/YourProject` |
| 3 | 描述 | 1-2 句功能说明 | `A lightweight inspector extension for Unity.` |
| 4 | 作者 | 作者/组织名称 | `RunLab - Yuumix` |

**自动派生字段（用户不需要输入）：**

| 字段 | 派生规则 | 示例 |
|------|----------|------|
| 显示包名 | 取正式包名最后一段，连字符→空格，单词首字母大写 | `com.runlab.aesir-inspector` → `Aesir Inspector` |
| 版本号 | 固定 `0.1.0` | — |
| Unity 最低版本 | 固定 `2022.3` | — |
| 命名空间 | 取正式包名第 2、3 段，PascalCase + `.` 连接 | `RunLab.AesirInspector` |
| 输出路径 | `Assets/<公司名(首字母大写)>/<显示包名>/` | `Assets/RunLab/Aesir Inspector/` |

> **请一次性提供以上 4 项信息：**
>
> ```
> 正式包名: com.runlab.aesir-inspector
> Unity 项目路径: /Users/you/Projects/MyUnityProject
> 描述: A lightweight inspector extension for Unity.
> 作者: RunLab - Yuumix
> ```
>
> 可直接按上方模板填写。

**校验规则（AI 内部）：**
- 正式包名不得以 `com.unity` 或 `net.unity` 开头，不能包含大写字母
- Unity 项目路径必须是存在的目录
- 描述至少 10 个字符

## 汇总确认

收到后立即展示汇总并等待确认：

```
📋 包配置确认：

  正式包名：    com.runlab.aesir-inspector
  显示包名：    Aesir Inspector（自动派生）
  版本：        0.1.0（默认）
  Unity 版本：  2022.3（默认）
  描述：        A lightweight inspector extension for Unity.
  作者：        RunLab - Yuumix
  命名空间：    RunLab.AesirInspector（自动派生）
  输出路径：    Assets/RunLab/Aesir Inspector/（自动派生）
  项目路径：    /path/to/YourProject

Y = 确认，执行创建
N = 取消，重新填写
直接指出某字段 → 仅修改该字段
```

## 执行创建

确认后，直接运行脚本：

**Shell 版（优先）：**
```bash
bash /path/to/skills/custom-package-creator/scripts/create-package.sh \
  -p "<项目路径>" \
  -o "Assets/<公司名>/<显示包名>" \
  -n "<正式包名>" \
  -d "<显示包名>" \
  -v "0.1.0" \
  -u "2022.3" \
  -e "<描述>" \
  -a "<作者>" \
  -s "<命名空间>"
```

**Node 版（备选）：**
```bash
node /path/to/skills/custom-package-creator/scripts/create-package.mjs \
  <同上参数>
```

## 生成内容

脚本自动创建以下 12 项：

| 路径 | 说明 |
|------|------|
| `package.json` | 包清单 |
| `README.md` | 说明文档（Installation/Usage/License） |
| `CHANGELOG.md` | 变更日志 |
| `LICENSE.md` | MIT 协议 |
| `Third Party Notices.md` | 第三方声明 |
| `Help Links.md` | Unity/团结官方文档链接 |
| `Runtime/{NS}.asmdef` | Runtime 程序集 |
| `Editor/{NS}.Editor.asmdef` | Editor 程序集 |
| `Tests/Runtime/{NS}.Tests.asmdef` | 运行时测试程序集 |
| `Tests/Editor/{NS}.Editor.Tests.asmdef` | 编辑器测试程序集 |
| `Documentation~/{DisplayName}.md` | 扩展文档 |
| `Samples/HelloWorld/` | 示例目录（空） |

## 完成

无需额外校验。脚本成功输出即为完成。告知用户：
- 文件已创建到输出路径
- 可查看 `Help Links.md` 获取 Custom Package 相关官方文档
- 开发期间 `Samples/` 不带 `~`，发布前改为 `Samples~`
