#!/usr/bin/env node
/**
 * Custom Package Creator - 脚手架脚本
 *
 * 用法: node scripts/create-package.mjs [options]
 *
 * 选项:
 *   --project, -p <path>      Unity 项目根目录 (必填，绝对路径)
 *   --output, -o <path>       输出路径 (必填，相对于 -p 解析)
 *   --name, -n <name>         正式包名 (必填)
 *   --displayName, -d <name>  显示包名 (必填)
 *   --version, -v <version>   版本号 (默认 0.1.0)
 *   --unity, -u <version>     Unity 最低版本 (必填)
 *   --description, -e <desc>  描述 (必填)
 *   --author, -a <name>       作者名称 (必填)
 *   --namespace, -s <ns>      命名空间 (必填)
 *
 * 示例:
 *   node scripts/create-package.mjs \
 *     -p "/path/to/YourProject" \
 *     -o "Assets/RunLab/Aesir Inspector" \
 *     -n "com.runlab.aesir-inspector" \
 *     -d "Aesir Inspector" \
 *     -v "0.1.0" \
 *     -u "2022.3" \
 *     -e "A lightweight inspector extension." \
 *     -a "RunLab - Yuumix" \
 *     -s "RunLab.AesirInspector"
 */

import { mkdirSync, writeFileSync, existsSync, realpathSync } from 'fs';
import { resolve, join, relative, sep } from 'path';

// ── 参数解析 ──────────────────────────────────────────

function parseArgs(argv) {
  const args = {};
  let i = 2;
  while (i < argv.length) {
    const key = argv[i];
    if (key === '--project' || key === '-p') args.project = argv[++i];
    else if (key === '--output' || key === '-o') args.output = argv[++i];
    else if (key === '--name' || key === '-n') args.name = argv[++i];
    else if (key === '--displayName' || key === '-d') args.displayName = argv[++i];
    else if (key === '--version' || key === '-v') args.version = argv[++i];
    else if (key === '--unity' || key === '-u') args.unity = argv[++i];
    else if (key === '--description' || key === '-e') args.description = argv[++i];
    else if (key === '--author' || key === '-a') args.author = argv[++i];
    else if (key === '--namespace' || key === '-s') args.namespace = argv[++i];
    i++;
  }
  return args;
}

function validateArgs(args) {
  const required = ['project', 'output', 'name', 'displayName', 'unity', 'description', 'author', 'namespace'];
  const missing = required.filter(k => !args[k]);
  if (missing.length > 0) {
    console.error('缺少必填参数: ' + missing.join(', '));
    process.exit(1);
  }
  args.version = args.version || '0.1.0';
}

// ── 文件生成器 ─────────────────────────────────────────

function generatePackageJson(a) {
  return JSON.stringify({
    name: a.name,
    displayName: a.displayName,
    version: a.version,
    unity: a.unity,
    description: a.description,
    keywords: [],
    category: "Unity",
    author: { name: a.author, email: "", url: "" },
    dependencies: {},
    repository: { type: "git", url: "" },
    license: "MIT",
    licensesUrl: "",
    changelogUrl: "",
    documentationUrl: "",
    samples: [
      { displayName: "Hello World", description: "A basic example.", path: "Samples~/HelloWorld" }
    ]
  }, null, 2) + '\n';
}

function generateReadme(a) {
  return `# ${a.displayName}

[![license](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE.md)

${a.description}

## Installation

Open the Package Manager window in Unity, click the \`+\` button in the top-left corner, and select \`Add package from git URL...\`. Enter:

\`\`\`
<git-url>
\`\`\`

## Usage

Brief usage instructions or code examples.

## License

This project is licensed under the MIT License — see the [LICENSE.md](LICENSE.md) file for details.
`;
}

function generateChangelog(a) {
  const today = new Date().toISOString().slice(0, 10);
  return `# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [${a.version}] - ${today}

### Added

- Initial release.
`;
}

function generateLicense(a) {
  const year = new Date().getFullYear();
  return `The MIT License

Copyright (c) ${year} ${a.author}

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
`;
}

function generateThirdPartyNotices() {
  return `This package contains third-party software components governed by the license(s) indicated below:

Component Name: Semver

License Type: "MIT"

[SemVer License](https://github.com/myusername/semver/blob/master/License.txt)
`;
}

function generateHelpLinks() {
  return `# Help Links

## Unity 国际版 (Unity International)

### 自定义包创建与开发

- [Package development workflow](https://docs.unity3d.com/6000.0/Documentation/Manual/CustomPackages.html) — 包开发工作流总览
- [Name your package](https://docs.unity3d.com/6000.0/Documentation/Manual/cus-naming.html) — 包命名规范
- [Package layout](https://docs.unity3d.com/6000.0/Documentation/Manual/cus-layout.html) — 包目录布局约定
- [Package manifest](https://docs.unity3d.com/6000.0/Documentation/Manual/upm-manifestPkg.html) — package.json 字段参考
- [Versioning (SemVer)](https://docs.unity3d.com/6000.0/Documentation/Manual/upm-semver.html) — 语义化版本控制
- [Assembly definitions and packages](https://docs.unity3d.com/6000.0/Documentation/Manual/cus-asmdef.html) — 程序集定义与包
- [Adding tests to packages](https://docs.unity3d.com/6000.0/Documentation/Manual/cus-tests.html) — 为包添加测试
- [Creating samples](https://docs.unity3d.com/6000.0/Documentation/Manual/cus-samples.html) — 创建示例
- [Meeting legal requirements](https://docs.unity3d.com/6000.0/Documentation/Manual/cus-legal.html) — 许可与第三方声明
- [Documenting your package](https://docs.unity3d.com/6000.0/Documentation/Manual/cus-document.html) — 为包编写文档
- [Sharing your package](https://docs.unity3d.com/6000.0/Documentation/Manual/cus-share.html) — 分享/发布包

### 依赖与包管理

- [Embedded dependencies](https://docs.unity3d.com/6000.0/Documentation/Manual/upm-embed.html) — 嵌入式依赖项
- [Git dependencies](https://docs.unity3d.com/6000.0/Documentation/Manual/upm-git.html) — Git 依赖
- [Local folder or tarball](https://docs.unity3d.com/6000.0/Documentation/Manual/upm-localpath.html) — 本地路径依赖
- [Dependencies and resolution](https://docs.unity3d.com/6000.0/Documentation/Manual/upm-dependencies.html) — 依赖解析
- [Scoped registries](https://docs.unity3d.com/6000.0/Documentation/Manual/upm-scoped.html) — 作用域注册表

### 发布到 Asset Store

- [Publishing Asset Store packages](https://docs.unity3d.com/6000.5/Documentation/Manual/asset-store-publishing.html) — 资源包发布总览
- [Publish a UPM package](https://docs.unity3d.com/6000.3/Documentation/Manual/asset-store-upm.html) — UPM 包发布流程
- [Introduction to publishing](https://docs.unity.cn/6000.3/Documentation/Manual/asset-store-publishing-introduction.html) — 发布入门指南
- [Asset Store Tools (GitHub)](https://github.com/Unity-Technologies/com.unity.asset-store-tools) — 资源商店验证上传工具

---

## 团结引擎 (Tuanjie Engine)

### 自定义包创建与开发

- [创建自定义包](https://docs.unity.cn/cn/tuanjiemanual/Manual/CustomPackages.html) — 包开发工作流总览
- [为包命名](https://docs.unity.cn/cn/tuanjiemanual/Manual/cus-naming.html) — 包命名规范
- [包布局](https://docs.unity.cn/cn/tuanjiemanual/Manual/cus-layout.html) — 包目录布局约定
- [包清单](https://docs.unity.cn/cn/tuanjiemanual/Manual/upm-manifestPkg.html) — package.json 字段参考
- [版本控制](https://docs.unity.cn/cn/tuanjiemanual/Manual/upm-semver.html) — 语义化版本控制
- [程序集定义和包](https://docs.unity.cn/cn/tuanjiemanual/Manual/cus-asmdef.html) — 程序集定义与包
- [向包添加测试](https://docs.unity.cn/cn/tuanjiemanual/Manual/cus-tests.html) — 为包添加测试
- [为资源包创建示例](https://docs.unity.cn/cn/tuanjiemanual/Manual/cus-samples.html) — 创建示例
- [符合法律要求](https://docs.unity.cn/cn/tuanjiemanual/Manual/cus-legal.html) — 许可与第三方声明
- [为您的软件包撰写文档](https://docs.unity.cn/cn/tuanjiemanual/Manual/cus-document.html) — 为包编写文档
- [共享包](https://docs.unity.cn/cn/tuanjiemanual/Manual/cus-share.html) — 分享/发布包

### 依赖与包管理

- [嵌入式依赖项](https://docs.unity.cn/cn/tuanjiemanual/Manual/upm-embed.html) — 嵌入式依赖项
- [Git 依赖关系](https://docs.unity.cn/cn/tuanjiemanual/Manual/upm-git.html) — Git 依赖
- [本地文件夹或 tarball 路径](https://docs.unity.cn/cn/tuanjiemanual/Manual/upm-localpath.html) — 本地路径依赖
- [依赖和解析](https://docs.unity.cn/cn/tuanjiemanual/Manual/upm-dependencies.html) — 依赖解析
- [作用域注册表](https://docs.unity.cn/cn/tuanjiemanual/Manual/upm-scoped.html) — 作用域注册表

### 资源商店

- [Unity 中国资源商店](https://docs.unity.cn/cn/tuanjiemanual/Manual/AssetStore.html) — 资源商店概览
- [商店资源包](https://docs.unity.cn/cn/tuanjiemanual/Manual/AssetStorePackages.html) — 商店资源包管理
`;
}

function generateRuntimeAsmdef(ns) {
  return JSON.stringify({
    name: ns,
    rootNamespace: ns,
    references: [],
    includePlatforms: [],
    excludePlatforms: [],
    allowUnsafeCode: false,
    overrideReferences: false,
    precompiledReferences: [],
    autoReferenced: true,
    defineConstraints: [],
    versionDefines: [],
    noEngineReferences: false
  }, null, 2) + '\n';
}

function generateEditorAsmdef(ns) {
  return JSON.stringify({
    name: `${ns}.Editor`,
    rootNamespace: `${ns}.Editor`,
    references: [ns],
    includePlatforms: ["Editor"],
    excludePlatforms: [],
    allowUnsafeCode: false,
    overrideReferences: false,
    precompiledReferences: [],
    autoReferenced: true,
    defineConstraints: [],
    versionDefines: [],
    noEngineReferences: false
  }, null, 2) + '\n';
}

function generateRuntimeTestAsmdef(ns) {
  return JSON.stringify({
    name: `${ns}.Tests`,
    rootNamespace: `${ns}.Tests`,
    references: [ns, "UnityEngine.TestRunner"],
    includePlatforms: [],
    excludePlatforms: [],
    allowUnsafeCode: false,
    overrideReferences: true,
    precompiledReferences: ["nunit.framework.dll"],
    autoReferenced: false,
    defineConstraints: ["UNITY_INCLUDE_TESTS"],
    versionDefines: [],
    noEngineReferences: false
  }, null, 2) + '\n';
}

function generateEditorTestAsmdef(ns) {
  return JSON.stringify({
    name: `${ns}.Editor.Tests`,
    rootNamespace: `${ns}.Editor.Tests`,
    references: [`${ns}.Editor`, ns, "UnityEngine.TestRunner", "UnityEditor.TestRunner"],
    includePlatforms: ["Editor"],
    excludePlatforms: [],
    allowUnsafeCode: false,
    overrideReferences: true,
    precompiledReferences: ["nunit.framework.dll"],
    autoReferenced: false,
    defineConstraints: ["UNITY_INCLUDE_TESTS"],
    versionDefines: [],
    noEngineReferences: false
  }, null, 2) + '\n';
}

function generateDocumentation(displayName, description) {
  return `# ${displayName}

${description}
`;
}

// ── 主流程 ────────────────────────────────────────────

function main() {
  const args = parseArgs(process.argv);
  validateArgs(args);

  const { name: pkgName, displayName, version, unity, description, author, namespace: ns, project: projectArg } = args;

  // -p 必须是绝对路径
  const isAbsolute = import.meta.dirname || __dirname;
  if (!resolve(projectArg).startsWith(sep) && !/^[A-Za-z]:/.test(projectArg)) {
    console.error('错误：-p/--project 必须是绝对路径。');
    console.error('  收到: ' + projectArg);
    process.exit(1);
  }
  const projectDir = resolve(projectArg);
  if (!existsSync(projectDir)) {
    console.error('错误：项目目录不存在: ' + projectDir);
    process.exit(1);
  }

  // -o 相对于项目根目录解析；如果已经是绝对路径则直接使用
  let base;
  const outputResolved = resolve(args.output);
  if (args.output.startsWith(sep) || args.output.startsWith('/') || /^[A-Za-z]:/.test(args.output)) {
    base = outputResolved;
  } else {
    base = resolve(projectDir, args.output);
  }

  // 禁止输出到技能目录内
  const skillDir = resolve(import.meta.dirname || __dirname, '..');
  if (base === skillDir || base.startsWith(skillDir + sep) || base.startsWith(skillDir + '/')) {
    console.error(`错误：输出路径不得在技能目录 (${skillDir}) 内。`);
    console.error('请指定 Unity 项目的绝对路径，例如：');
    console.error('  -o "/path/to/YourProject/Assets/Company/Package/"');
    process.exit(1);
  }

  const files = [
    // 根目录文件
    [join(base, 'package.json'), generatePackageJson(args)],
    [join(base, 'README.md'), generateReadme(args)],
    [join(base, 'CHANGELOG.md'), generateChangelog(args)],
    [join(base, 'LICENSE.md'), generateLicense(args)],
    [join(base, 'Third Party Notices.md'), generateThirdPartyNotices()],
    [join(base, 'Help Links.md'), generateHelpLinks()],

    // Runtime
    [join(base, 'Runtime', `${ns}.asmdef`), generateRuntimeAsmdef(ns)],

    // Editor
    [join(base, 'Editor', `${ns}.Editor.asmdef`), generateEditorAsmdef(ns)],

    // Tests/Runtime
    [join(base, 'Tests', 'Runtime', `${ns}.Tests.asmdef`), generateRuntimeTestAsmdef(ns)],

    // Tests/Editor
    [join(base, 'Tests', 'Editor', `${ns}.Editor.Tests.asmdef`), generateEditorTestAsmdef(ns)],

    // Documentation~
    [join(base, 'Documentation~', `${displayName}.md`), generateDocumentation(displayName, description)],
  ];

  // 需要创建的空目录
  const emptyDirs = [
    join(base, 'Samples', 'HelloWorld'),
  ];

  // 先清理并创建根目录
  mkdirSync(base, { recursive: true });

  // 收集所有需要创建的子目录
  const dirs = new Set();
  for (const [filePath] of files) {
    dirs.add(filePath.substring(0, filePath.lastIndexOf(sep)));
  }
  for (const dir of emptyDirs) {
    dirs.add(dir);
  }

  // 创建所有目录
  for (const dir of dirs) {
    mkdirSync(dir, { recursive: true });
  }

  // 写入文件
  let created = 0;
  for (const [filePath, content] of files) {
    writeFileSync(filePath, content, 'utf-8');
    console.log(`  ${relative(base, filePath)}`);
    created++;
  }

  // 创建空目录
  for (const dir of emptyDirs) {
    mkdirSync(dir, { recursive: true });
    console.log(`  ${relative(base, dir)}${sep}`);
    created++;
  }

  console.log(`\nDone. ${created} items created under: ${base}`);
}

main();
