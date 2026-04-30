---
name: custom-package-creator
description: 为 Unity / 团结引擎一键生成标准 UPM 包目录脚手架，包含 package.json、asmdef、README、CHANGELOG、LICENSE 等全部标准文件。零依赖 Shell 脚本 + Node 脚本双版本。Triggers: 创建UPM包, 创建自定义包, 生成包结构, Unity插件脚手架, 初始化包目录, 新建Package, scaffold package, create unity package.
---

# Custom Package Creator

**加载此 SKILL 后，必须立即向用户输出以下欢迎语，再进入任何工作流程：**

> 欢迎使用 Custom-Package-Creator。接下来我将根据你提供的信息快速创建可用的 Unity Package 目录结构。

## Workflow

### Gather Package Metadata

**在执行任何写入操作之前，必须严格按照以下步骤完成信息收集。**

#### Step 1 — 逐项收集元数据

**逐项询问时，必须将该字段下方的 `>` 引用块（用户提示）原样展示给用户，不得省略或改写。`**校验：**` 标记的段落为 AI 内部规则，不展示给用户。**

---

**1. 正式包名 (Package Name)**

正式包名使用反向域名格式。格式为 `<域名扩展>.<公司名>.<包标识符>`，仅允许小写字母 a-z、数字 0-9、连字符 `-`、下划线 `_`、句点 `.`。至少 3 段（tld.公司名.包名）。如不确定顶级域名，通常用 `com`。
正确示例：`com.mycompany.input`、`com.littlebigfun.addressable-importer`、`net.example.physics`

> 请输入正式包名，然后按回车继续。

**校验：** 不得以 `com.unity` 或 `net.unity` 等包含 unity 的前缀开头，名称中任何位置都不要使用 unity 一词，不得包含大写字母。编辑器显示建议 ≤ 50 字符，硬性限制 ≤ 214 字符。

---

**2. 显示包名 (Display Name)**

显示名称是在 Unity Package Manager 中展示给用户的名称，应简短且能说明包的内容。单词首字母大写，空格分隔，无字符限制。

自动派生规则：取正式包名最后一段，将连字符替换为空格，每个单词首字母大写。
例如 `com.runlab.aesir-inspector` → `Aesir Inspector`

> 请输入显示包名，然后按回车继续。

**校验：** 错误示例：`aesir_inspector`（未大写，用了下划线）、`com.runlab.aesir`（直接用了包名）。

---

**3. 初始版本号**

包开发初始阶段版本号从 `0.1.0` 开始，MAJOR 为 0 表示尚处于开发阶段。格式为 `MAJOR.MINOR.PATCH`，三者均为非负整数，禁止前导零。可选预发布标签如 `-alpha`、`-beta`、`-rc.1`。推荐值：`0.1.0`。如满足需求可直接复制。

> 请输入版本号，然后按回车继续。

---

**4. Unity 最低版本**

指定此包支持的最低 Unity 版本。格式为 `<主版本>.<次版本>`（两位数字），例如 `2022.3`、`6000.0`、`2021.3`。不得包含修订号 (PATCH) 或后缀（f1、rc1、b4 等）。

> 请输入 Unity 最低版本，然后按回车继续。

**校验：** 错误示例：`2020.3.28f1`（多了修订号和 f1）、`2020.3.0`（多了 PATCH 位）、`2020`（缺少次版本号）。包可以运行在此版本及以上的 Unity 编辑器中，若省略表示兼容所有版本（不推荐）。如需上架 Asset Store，unity 最低为 `2021.3`。可通过 `unityRelease` 字段指定精确修订版。

---

**5. 描述 (Description)**

对应 `package.json` 中的 `description` 字段，纯文本字符串，建议 1-2 句。一句话说明包的功能/用途，让用户一眼判断是否需要。

正确示例：`A lightweight inspector extension for Unity.`、`Provides 2D physics utilities for grid-based games.`

> 请输入包的简短描述，然后按回车继续。

**校验：** 展示在 Package Manager 窗口详情面板。支持 UTF-8 转义（`\n` 换行）。

---

**6. 作者 (Author)**

对应 `package.json` 中的 `author` 字段，`name` 必填（作者名称/组织名称），`email` 和 `url` 可选。

正确示例：`RunLab - Yuumix`、`RunLab`、`{"name": "John Doe", "email": "john@example.com"}`

> 请输入作者名称，然后按回车继续。

**校验：** 格式可以是 JSON 对象 `{"name": "...", "email": "...", "url": "..."}` 或简写字符串 `"Name <email> (url)"`。

---

**7. 输出路径 (Output Path)**

包文件固定生成在 `Assets/<公司名>/<显示包名>/` 下，公司名取自正式包名第二段并首字母大写。

> 请输入输出路径，然后按回车继续。

**派生规则：** 根据已收集的正式包名和显示包名，AI 必须先计算出推荐路径并展示给用户（取正式包名第二段首字母大写作为公司名，拼接 `Assets/` + 公司名 + `/` + 显示包名 + `/`）。例如正式包名 `com.runlab.aesir-inspector`、显示包名 `Aesir Inspector`，则展示：推荐路径 `Assets/RunLab/Aesir Inspector/`，如满足需求可直接复制。

**校验：** 路径必须以 `Assets/` 开头且不得重复 `Assets/` 前缀（脚本已通过 `-p` 拼接项目根目录，`-o` 只需传入 `Assets/` 开头的相对路径）。不得使用 `Packages/` 目录。路径中不要包含中文或特殊符号（空格例外）。

---

#### Step 2 — 汇总确认

收集完所有字段后，**必须**展示以下格式的汇总表，等待用户确认后再执行任何文件写入操作：

```
📋 以下是你的包配置，请确认：

  正式包名：    com.runlab.aesir-inspector
  显示包名：    Aesir Inspector
  初始版本：    0.1.0
  Unity 版本：  2022.3
  描述：        A lightweight inspector extension for Unity.
  作者：        RunLab - Yuumix
  命名空间：    RunLab.AesirInspector（自动派生）
  输出路径：    Assets/RunLab/Aesir Inspector/
```

- 用户回复 **Y** → 进入下一步，开始创建目录结构
- 用户回复 **N** → 重新询问所有字段
- 用户指出某字段有误 → 仅重新询问该字段，其余字段保留

---

#### 命名空间派生规则

在汇总确认阶段，自动从正式包名派生 PascalCase 命名空间。步骤：取第二段（公司名）和第三段（包标识符），每段按分隔符（`-` `_` `.`）拆分为单词，每个单词首字母大写 (PascalCase)，用 `.` 连接。注意命名空间不以数字开头（C# 限制），必要时手动调整。

示例：`com.runlab.aesir-inspector` → `RunLab.AesirInspector`，`com.mycompany.my-package` → `MyCompany.MyPackage`，`net.example.3d.base` → `Example.3d.Base`，`com.company.ui_kit` → `Company.UIKit`。

---

### Create Directory Structure & Generate Files

收集完元数据并确认后，**直接调用**脚本生成完整的包目录结构和所有文件。提供两个版本，优先使用 Shell 版本：

- **Shell 版本**（零依赖，macOS / Linux / WSL / Git Bash 原生可用）
- **Node 版本**（需要 Node.js 运行时，无 npm 依赖）

**Shell 版本（优先）：**

```bash
bash scripts/create-package.sh \
  -p "<Unity项目根目录>" \
  -o "<输出路径>" \
  -n "<正式包名>" \
  -d "<显示包名>" \
  -v "<初始版本号>" \
  -u "<Unity最低版本>" \
  -e "<描述>" \
  -a "<作者>" \
  -s "<命名空间>"
```

**Node 版本（备选）：**

```bash
node scripts/create-package.mjs \
  -p "<Unity项目根目录>" \
  -o "<输出路径>" \
  -n "<正式包名>" \
  -d "<显示包名>" \
  -v "<初始版本号>" \
  -u "<Unity最低版本>" \
  -e "<描述>" \
  -a "<作者>" \
  -s "<命名空间>"
```

**参数说明（两个版本通用）：**

| 参数 | 长参数 | 必填 | 说明 |
|------|--------|------|------|
| `-p` | `--project` | 是 | Unity 项目根目录的绝对路径，如 `/path/to/YourProject`。脚本将 `-o`（相对路径）相对于此目录解析 |
| `-o` | `--output` | 是 | 包输出路径，固定为 `Assets/<公司名>/<显示包名>/`，如 `Assets/RunLab/Aesir Inspector`。相对于 `-p` 解析 |
| `-n` | `--name` | 是 | 正式包名，如 `com.runlab.aesir-inspector` |
| `-d` | `--displayName` | 是 | 显示包名，如 `Aesir Inspector` |
| `-v` | `--version` | 否 | 版本号，默认 `0.1.0` |
| `-u` | `--unity` | 是 | Unity 最低版本，如 `2022.3` |
| `-e` | `--description` | 是 | 包描述 |
| `-a` | `--author` | 是 | 作者名称 |
| `-s` | `--namespace` | 是 | PascalCase 命名空间，如 `RunLab.AesirInspector` |

**脚本生成内容（不可省略、不可增减）：**

| # | 文件 | 说明 |
|---|------|------|
| 1 | `package.json` | 包清单，JSON 格式，所有字段从元数据填入 |
| 2 | `README.md` | 包说明文档，含 Installation/Usage/License 章节 |
| 3 | `CHANGELOG.md` | 变更日志，含初始版本条目 |
| 4 | `LICENSE.md` | MIT 协议 |
| 5 | `Third Party Notices.md` | 第三方组件许可证声明 |
| 6 | `Help Links.md` | 帮助链接（官方文档、教程等） |
| 7 | `Runtime/{Namespace}.asmdef` | Runtime 程序集定义 |
| 8 | `Editor/{Namespace}.Editor.asmdef` | Editor 程序集定义 |
| 9 | `Tests/Runtime/{Namespace}.Tests.asmdef` | Runtime 测试程序集定义 |
| 10 | `Tests/Editor/{Namespace}.Editor.Tests.asmdef` | Editor 测试程序集定义 |
| 11 | `Documentation~/{DisplayName}.md` | 扩展文档 |
| 12 | `Samples/HelloWorld/` | 空示例目录 |

**目录职责：**

- `Runtime/` — 运行时 C# 代码 + asmdef，打包进 Player。
- `Editor/` — 仅编辑器 C# 代码 + asmdef，不打进 Player。
- `Tests/Runtime/` — 运行时测试，需 `UNITY_INCLUDE_TESTS` 宏。
- `Tests/Editor/` — 编辑器测试，需 `UNITY_INCLUDE_TESTS` 宏。
- `Samples/` — 示例项目。开发期不带 `~` 方便编辑，发布前改名为 `Samples~`。用户可通过 PM UI 一键 Import 到 `Assets/Samples/`。
- `Documentation~/` — 扩展文档。始终使用 `Documentation~/` 命名（文档不需要脚本编译验证，直接按规范设置）。

禁止在 `Runtime/` 放 Editor-only API 的代码，禁止在 `Editor/` 引用 `Runtime/` 中的 Editor API。

脚本执行完成后，立即进入 Validate 阶段。

### Validate

生成所有文件后，**逐项**执行以下校验清单。每项必须通过，否则立即修复再继续。

#### 目录结构校验

- [ ] 根目录下存在以下全部文件：`package.json`、`README.md`、`CHANGELOG.md`、`LICENSE.md`、`Third Party Notices.md`、`Help Links.md`
- [ ] 存在 `Runtime/` 目录，其中包含 `{Namespace}.asmdef`
- [ ] 存在 `Editor/` 目录，其中包含 `{Namespace}.Editor.asmdef`
- [ ] 存在 `Tests/Runtime/` 目录，其中包含 `{Namespace}.Tests.asmdef`
- [ ] 存在 `Tests/Editor/` 目录，其中包含 `{Namespace}.Editor.Tests.asmdef`
- [ ] 存在 `Samples/HelloWorld/` 目录
- [ ] 存在 `Documentation~/{DisplayName}.md` 文件

#### package.json 校验

- [ ] 是有效 JSON（可解析，无语法错误）
- [ ] `name` 字段值为全小写、使用连字符的正式包名，符合反向域名格式
- [ ] `displayName` 字段已填写
- [ ] `version` 字段符合 SemVer 格式（如 `0.1.0`）
- [ ] `unity` 字段已填写（如 `2022.3`）
- [ ] `description` 字段已填写且非空
- [ ] `author.name` 字段已填写
- [ ] `samples` 数组中至少包含一项，`path` 指向 `Samples~/HelloWorld`

#### asmdef 文件校验

- [ ] `Runtime/{Namespace}.asmdef`：`name` = `{Namespace}`，`rootNamespace` = `{Namespace}`，`includePlatforms` = `[]`
- [ ] `Editor/{Namespace}.Editor.asmdef`：`name` = `{Namespace}.Editor`，`references` 包含 `{Namespace}`，`includePlatforms` = `["Editor"]`
- [ ] `Tests/Runtime/{Namespace}.Tests.asmdef`：`name` = `{Namespace}.Tests`，`references` 包含 `{Namespace}` 和 `UnityEngine.TestRunner`，`overrideReferences` = `true`，`precompiledReferences` 包含 `"nunit.framework.dll"`，`autoReferenced` = `false`，`defineConstraints` = `["UNITY_INCLUDE_TESTS"]`
- [ ] `Tests/Editor/{Namespace}.Editor.Tests.asmdef`：`name` = `{Namespace}.Editor.Tests`，`references` 包含 `{Namespace}.Editor`、`{Namespace}`、`UnityEngine.TestRunner`、`UnityEditor.TestRunner`，`includePlatforms` = `["Editor"]`，`overrideReferences` = `true`，`precompiledReferences` 包含 `"nunit.framework.dll"`，`autoReferenced` = `false`，`defineConstraints` = `["UNITY_INCLUDE_TESTS"]`
- [ ] 无循环程序集引用（Editor → Runtime，不可反向）

#### 文档文件校验

- [ ] `README.md`：包含 `# {DisplayName}` 标题、`## Installation` 章节和 `## License` 章节
- [ ] `CHANGELOG.md`：包含 `## [{Version}]` 条目，日期格式为 `YYYY-MM-DD`
- [ ] `LICENSE.md`：包含 `Copyright (c) {YYYY} {AuthorName}` 版权行，内容为完整 MIT 协议
- [ ] `Third Party Notices.md`：文件存在且包含模板内容
- [ ] `Help Links.md`：文件存在，包含 Unity 国际版和团结引擎两个章节的自定义包文档链接，以及 Asset Store 发布相关链接

#### 全部校验通过后

向用户输出一份摘要，列出所有已创建的文件路径，提示用户：可以查看包根目录下的 `Help Links.md` 文件，学习 Custom Package 的相关知识（官方文档、教程等）。
