# Hello World 网页实施计划

> **供智能体执行者使用：** 必须使用 `subagent-driven-development`（推荐）或 `executing-plans` 技能逐项实施本计划。所有步骤均使用复选框跟踪。

**目标：** 创建并发布一个无第三方依赖、响应式的静态网页，页面居中显示 `Hello World`。

**架构：** 使用单个 `index.html` 文件承载语义化 HTML 和少量内嵌 CSS。PowerShell 验证脚本负责检查本地文件契约，浏览器负责验证电脑与手机尺寸下的实际渲染；部署阶段使用 Cloudflare Pages 免费提供的 `pages.dev` HTTPS 地址。

**技术栈：** HTML5、CSS、PowerShell、Git、静态 HTTPS 托管

---

### 任务一：定义本地页面契约

**文件：**
- 新建：`tests/verify-page.ps1`
- 测试：`tests/verify-page.ps1`

- [x] **步骤 1：编写预期失败的验证脚本**

```powershell
$pagePath = Join-Path $PSScriptRoot '..\index.html'
if (-not (Test-Path -LiteralPath $pagePath)) {
    throw 'index.html 不存在'
}

$html = Get-Content -Raw -LiteralPath $pagePath
$checks = @{
    doctype = $html -match '(?i)<!doctype html>'
    viewport = $html -match 'name="viewport"'
    heading = $html -match '<h1>Hello World</h1>'
    flexCentering = $html -match 'display:\s*flex' -and $html -match 'align-items:\s*center' -and $html -match 'justify-content:\s*center'
    noHorizontalOverflow = $html -match 'margin:\s*0'
    noExternalResources = $html -notmatch '(?i)<script|<img|<link[^>]+stylesheet|https?://'
}

$failed = @($checks.GetEnumerator() | Where-Object { -not $_.Value } | ForEach-Object Key)
if ($failed.Count -gt 0) {
    throw "页面验证失败：$($failed -join ', ')"
}

Write-Output '页面验证通过。'
```

- [x] **步骤 2：运行脚本，确认页面缺失时测试失败**

运行：`pwsh -NoProfile -File tests/verify-page.ps1`

预期：测试失败并提示 `index.html 不存在`。

### 任务二：实现静态页面

**文件：**
- 新建：`index.html`
- 测试：`tests/verify-page.ps1`

- [x] **步骤 1：创建最小可用页面**

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Hello World</title>
  <style>
    * { box-sizing: border-box; }
    body {
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      min-height: 100dvh;
      margin: 0;
      padding: 1rem;
      font-family: system-ui, sans-serif;
    }
    h1 { margin: 0; text-align: center; }
  </style>
</head>
<body>
  <h1>Hello World</h1>
</body>
</html>
```

- [x] **步骤 2：运行页面契约验证**

运行：`pwsh -NoProfile -File tests/verify-page.ps1`

预期：测试通过并输出 `页面验证通过。`。

- [x] **步骤 3：在浏览器中检查电脑和手机视口**

分别以电脑和手机尺寸打开 `index.html`，确认标题居中、完整可见且页面没有横向滚动条。

### 任务三：部署到 Cloudflare Pages 并验证 HTTPS 访问

**文件：**
- 仅在托管服务确有要求时修改：仓库根目录中的部署元数据

- [x] **步骤 1：检查 Cloudflare 登录状态且不输出秘密信息**

通过 Wrangler 检查当前 Cloudflare 登录状态；若尚未登录，仅请求完成 Cloudflare OAuth 授权。

- [x] **步骤 2：在不修改页面代码的前提下部署**

创建只包含 `index.html` 的临时发布目录，通过 Wrangler Direct Upload 发布到 Cloudflare Pages，并保持页面文件不变。

- [x] **步骤 3：验证公网地址**

运行：`Invoke-WebRequest -UseBasicParsing '<HTTPS 地址>'`

预期：返回 HTTP 成功状态，且响应正文包含 `Hello World`。

- [x] **步骤 4：报告网址或唯一必要的授权步骤**

若当前没有可用凭据，保留所有已经完成的本地文件，并只请求所选托管平台必需的授权。
