#!/usr/bin/env bash
# ==============================================================================
# Custom Package Creator - Shell 版
#
# 用法: bash scripts/create-package.sh [options]
#       或者: ./scripts/create-package.sh [options]（需要 chmod +x）
#
# 选项:
#   --project,   -p <path>       Unity 项目根目录 (必填，绝对路径)
#   --output,    -o <path>       输出路径 (必填，相对于 -p 解解)
#   --name,      -n <name>       正式包名 (必填)
#   --displayName, -d <name>     显示包名 (必填)
#   --version,   -v <version>    版本号 (默认 0.1.0)
#   --unity,     -u <version>    Unity 最低版本 (必填)
#   --description, -e <desc>     描述 (必填)
#   --author,    -a <name>       作者名称 (必填)
#   --namespace, -s <ns>         命名空间 (必填)
#
# 示例:
#   bash scripts/create-package.sh \
#     -p "/path/to/YourProject" \
#     -o "Assets/RunLab/Aesir Inspector" \
#     -n "com.runlab.aesir-inspector" \
#     -d "Aesir Inspector" \
#     -v "0.1.0" \
#     -u "2022.3" \
#     -e "A lightweight inspector extension." \
#     -a "RunLab - Yuumix" \
#     -s "RunLab.AesirInspector"
#
# 兼容性: macOS / Linux / WSL / Git Bash，零外部依赖
# ==============================================================================

set -euo pipefail

# ── 参数解析 ──────────────────────────────────────────────

OPT_PROJECT=""
OPT_OUTPUT=""
OPT_NAME=""
OPT_DISPLAY=""
OPT_VERSION="0.1.0"
OPT_UNITY=""
OPT_DESC=""
OPT_AUTHOR=""
OPT_NS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project|-p)     OPT_PROJECT="$2"; shift 2 ;;
    --output|-o)       OPT_OUTPUT="$2";  shift 2 ;;
    --name|-n)         OPT_NAME="$2";    shift 2 ;;
    --displayName|-d)  OPT_DISPLAY="$2"; shift 2 ;;
    --version|-v)      OPT_VERSION="$2"; shift 2 ;;
    --unity|-u)        OPT_UNITY="$2";   shift 2 ;;
    --description|-e)  OPT_DESC="$2";    shift 2 ;;
    --author|-a)       OPT_AUTHOR="$2";  shift 2 ;;
    --namespace|-s)    OPT_NS="$2";      shift 2 ;;
    -h|--help)
      sed -n '2,/^$/{ s/^# \?//; p }' "$0"
      exit 0 ;;
    *)
      echo "未知参数: $1" >&2; exit 1 ;;
  esac
done

# ── 参数校验 ──────────────────────────────────────────────

REQUIRED=("OPT_PROJECT" "OPT_OUTPUT" "OPT_NAME" "OPT_DISPLAY" "OPT_UNITY" "OPT_DESC" "OPT_AUTHOR" "OPT_NS")
MISSING=()
for var in "${REQUIRED[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    MISSING+=("$var")
  fi
done
if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo "缺少必填参数: ${MISSING[*]}" >&2
  exit 1
fi

# ── 辅助函数 ──────────────────────────────────────────────

YEAR=$(date +%Y)
TODAY=$(date +%Y-%m-%d)

mkdir_all() {
  # 从文件路径中提取目录并递归创建
  local dir
  dir=$(dirname "$1")
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
  fi
}

write() {
  mkdir_all "$1"
  printf '%s\n' "$2" > "$1"
}

# 输出相对路径（兼容 macOS / GNU stat）
relpath() {
  local target="$1"
  local base="$2"
  # Python 跨平台回退
  if command -v python3 &>/dev/null; then
    python3 -c "import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))" "$target" "$base"
  elif command -v python &>/dev/null; then
    python -c "import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))" "$target" "$base"
  else
    # 纯 bash 回退：去掉 base 前缀
    echo "${target#"$base"/}"
  fi
}

# ── 文件内容生成 ──────────────────────────────────────────

pkg_json() {
  cat <<JSONEOF
{
  "name": "${OPT_NAME}",
  "displayName": "${OPT_DISPLAY}",
  "version": "${OPT_VERSION}",
  "unity": "${OPT_UNITY}",
  "description": ${OPT_DESC_JSON},
  "keywords": [],
  "category": "Unity",
  "author": {
    "name": "${OPT_AUTHOR}",
    "email": "",
    "url": ""
  },
  "dependencies": {},
  "repository": {
    "type": "git",
    "url": ""
  },
  "license": "MIT",
  "licensesUrl": "",
  "changelogUrl": "",
  "documentationUrl": "",
  "samples": [
    {
      "displayName": "Hello World",
      "description": "A basic example.",
      "path": "Samples~/HelloWorld"
    }
  ]
}
JSONEOF
}

readme_md() {
  cat <<EOF
# ${OPT_DISPLAY}

[![license](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE.md)

${OPT_DESC}

## Installation

Open the Package Manager window in Unity, click the \`+\` button in the top-left corner, and select \`Add package from git URL...\`. Enter:

\`\`\`
<git-url>
\`\`\`

## Usage

Brief usage instructions or code examples.

## License

This project is licensed under the MIT License — see the [LICENSE.md](LICENSE.md) file for details.
EOF
}

changelog_md() {
  cat <<EOF
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [${OPT_VERSION}] - ${TODAY}

### Added

- Initial release.
EOF
}

license_md() {
  cat <<EOF
The MIT License

Copyright (c) ${YEAR} ${OPT_AUTHOR}

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
EOF
}

third_party_md() {
  cat <<EOF
This package contains third-party software components governed by the license(s) indicated below:

Component Name: Semver

License Type: "MIT"

[SemVer License](https://github.com/myusername/semver/blob/master/License.txt)
EOF
}

help_links_md() {
  cat <<EOF
# Help Links

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
EOF
}

asmdef_runtime() {
  cat <<EOF
{
  "name": "${OPT_NS}",
  "rootNamespace": "${OPT_NS}",
  "references": [],
  "includePlatforms": [],
  "excludePlatforms": [],
  "allowUnsafeCode": false,
  "overrideReferences": false,
  "precompiledReferences": [],
  "autoReferenced": true,
  "defineConstraints": [],
  "versionDefines": [],
  "noEngineReferences": false
}
EOF
}

asmdef_editor() {
  cat <<EOF
{
  "name": "${OPT_NS}.Editor",
  "rootNamespace": "${OPT_NS}.Editor",
  "references": ["${OPT_NS}"],
  "includePlatforms": ["Editor"],
  "excludePlatforms": [],
  "allowUnsafeCode": false,
  "overrideReferences": false,
  "precompiledReferences": [],
  "autoReferenced": true,
  "defineConstraints": [],
  "versionDefines": [],
  "noEngineReferences": false
}
EOF
}

asmdef_runtime_test() {
  cat <<EOF
{
  "name": "${OPT_NS}.Tests",
  "rootNamespace": "${OPT_NS}.Tests",
  "references": ["${OPT_NS}", "UnityEngine.TestRunner"],
  "includePlatforms": [],
  "excludePlatforms": [],
  "allowUnsafeCode": false,
  "overrideReferences": true,
  "precompiledReferences": ["nunit.framework.dll"],
  "autoReferenced": false,
  "defineConstraints": ["UNITY_INCLUDE_TESTS"],
  "versionDefines": [],
  "noEngineReferences": false
}
EOF
}

asmdef_editor_test() {
  cat <<EOF
{
  "name": "${OPT_NS}.Editor.Tests",
  "rootNamespace": "${OPT_NS}.Editor.Tests",
  "references": ["${OPT_NS}.Editor", "${OPT_NS}", "UnityEngine.TestRunner", "UnityEditor.TestRunner"],
  "includePlatforms": ["Editor"],
  "excludePlatforms": [],
  "allowUnsafeCode": false,
  "overrideReferences": true,
  "precompiledReferences": ["nunit.framework.dll"],
  "autoReferenced": false,
  "defineConstraints": ["UNITY_INCLUDE_TESTS"],
  "versionDefines": [],
  "noEngineReferences": false
}
EOF
}

documentation_md() {
  cat <<EOF
# ${OPT_DISPLAY}

${OPT_DESC}
EOF
}

# ── 主流程 ────────────────────────────────────────────────

BASE=$(cd "$(dirname "$0")/.." && pwd)

# -p 必须是绝对路径
if [[ "$OPT_PROJECT" != /* && "$OPT_PROJECT" != [A-Za-z]:* ]]; then
  echo "错误：-p/--project 必须是绝对路径。" >&2
  echo "  收到: $OPT_PROJECT" >&2
  exit 1
fi
PROJECT=$(cd "$OPT_PROJECT" && pwd) 2>/dev/null || { echo "错误：项目目录不存在: $OPT_PROJECT" >&2; exit 1; }

# -o 相对于项目根目录解析；如果已经是绝对路径则直接使用
if [[ "$OPT_OUTPUT" == /* || "$OPT_OUTPUT" == [A-Za-z]:* ]]; then
  OUTPUT="$OPT_OUTPUT"
else
  OUTPUT="${PROJECT}/${OPT_OUTPUT}"
fi

# 转为绝对路径并规范化
mkdir -p "$OUTPUT"
OUTPUT=$(cd "$OUTPUT" && pwd)

# 禁止输出到技能目录内
REAL_BASE=$(cd "$BASE" && pwd)
if [[ "$OUTPUT" == "$REAL_BASE"/* || "$OUTPUT" == "$REAL_BASE" ]]; then
  echo "错误：输出路径不得在技能目录 ($REAL_BASE) 内。" >&2
  echo "请检查 -p 和 -o 参数，确保输出到 Unity 项目目录下。" >&2
  exit 1
fi

# 对 description 做 JSON 转义（处理引号和反斜杠）
OPT_DESC_JSON=$(printf '%s' "$OPT_DESC" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')
OPT_DESC_JSON="\"${OPT_DESC_JSON}\""

CREATED=0

echo "Creating package: ${OPT_DISPLAY} (${OPT_NAME})"

# ── 根目录文件 ──
write "$OUTPUT/package.json"             "$(pkg_json)"           && printf '  %s\n' "$(relpath "$OUTPUT/package.json" "$OUTPUT")" && ((CREATED++)) || true
write "$OUTPUT/README.md"                "$(readme_md)"          && printf '  %s\n' "$(relpath "$OUTPUT/README.md" "$OUTPUT")" && ((CREATED++)) || true
write "$OUTPUT/CHANGELOG.md"             "$(changelog_md)"       && printf '  %s\n' "$(relpath "$OUTPUT/CHANGELOG.md" "$OUTPUT")" && ((CREATED++)) || true
write "$OUTPUT/LICENSE.md"               "$(license_md)"         && printf '  %s\n' "$(relpath "$OUTPUT/LICENSE.md" "$OUTPUT")" && ((CREATED++)) || true
write "$OUTPUT/Third Party Notices.md"   "$(third_party_md)"     && printf '  %s\n' "$(relpath "$OUTPUT/Third Party Notices.md" "$OUTPUT")" && ((CREATED++)) || true
write "$OUTPUT/Help Links.md"            "$(help_links_md)"      && printf '  %s\n' "$(relpath "$OUTPUT/Help Links.md" "$OUTPUT")" && ((CREATED++)) || true

# ── Runtime ──
write "$OUTPUT/Runtime/${OPT_NS}.asmdef"                     "$(asmdef_runtime)"       && printf '  %s\n' "$(relpath "$OUTPUT/Runtime/${OPT_NS}.asmdef" "$OUTPUT")" && ((CREATED++)) || true

# ── Editor ──
write "$OUTPUT/Editor/${OPT_NS}.Editor.asmdef"               "$(asmdef_editor)"        && printf '  %s\n' "$(relpath "$OUTPUT/Editor/${OPT_NS}.Editor.asmdef" "$OUTPUT")" && ((CREATED++)) || true

# ── Tests/Runtime ──
write "$OUTPUT/Tests/Runtime/${OPT_NS}.Tests.asmdef"         "$(asmdef_runtime_test)"  && printf '  %s\n' "$(relpath "$OUTPUT/Tests/Runtime/${OPT_NS}.Tests.asmdef" "$OUTPUT")" && ((CREATED++)) || true

# ── Tests/Editor ──
write "$OUTPUT/Tests/Editor/${OPT_NS}.Editor.Tests.asmdef"   "$(asmdef_editor_test)"   && printf '  %s\n' "$(relpath "$OUTPUT/Tests/Editor/${OPT_NS}.Editor.Tests.asmdef" "$OUTPUT")" && ((CREATED++)) || true

# ── Documentation~ ──
write "$OUTPUT/Documentation~/${OPT_DISPLAY}.md"             "$(documentation_md)"     && printf '  %s\n' "$(relpath "$OUTPUT/Documentation~/${OPT_DISPLAY}.md" "$OUTPUT")" && ((CREATED++)) || true

# ── Samples (空目录) ──
mkdir -p "$OUTPUT/Samples/HelloWorld"
printf '  Samples/HelloWorld/\n'
((CREATED++))

echo ""
echo "Done. ${CREATED} items created under: ${OUTPUT}"
