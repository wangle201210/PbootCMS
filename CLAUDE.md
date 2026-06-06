# CLAUDE.md

本仓库是 PbootCMS 站点，模板在 `template/default/`。

## 部署 / 上传到服务器

当用户说"上传"、"部署"、"发布到服务器"时，把本次改动的文件用 `scp` 同步到生产服务器，**保持相对目录结构一致**。

- 服务器：`root@47.108.251.244`（已配置 SSH 免密，可直接连接）
- 站点根目录（对应本地仓库根目录 `/Users/wanna/mine/github/wangle201210/PbootCMS`）：
  `/opt/1panel/apps/openresty/openresty/www/sites/yxcq.scyytc.com/index`

### 操作流程

1. 用 `git status --short` 找出本次改动的文件（只传改动的，不要全量同步）。
2. 对每个改动文件，本地路径 `<repo>/<相对路径>` 对应远程 `<站点根>/<相对路径>`。
   例如 `template/default/css/yx.css` →
   `/opt/1panel/apps/openresty/openresty/www/sites/yxcq.scyytc.com/index/template/default/css/yx.css`
3. `scp` 上传后，用 `md5`（本地）/ `md5sum`（远程）核对校验和一致，确认上传成功。

### 示例（上传 css 改动）

```bash
cd /Users/wanna/mine/github/wangle201210/PbootCMS/template/default/css
REMOTE=/opt/1panel/apps/openresty/openresty/www/sites/yxcq.scyytc.com/index/template/default/css
scp yx.css yx-page.css root@47.108.251.244:$REMOTE/
ssh root@47.108.251.244 "md5sum $REMOTE/yx.css"   # 与本地 md5 比对
```

### 静态资源缓存（重要）

页面引用 css/js **不会自动带版本号**，浏览器会死缓存，导致改了文件用户也看不到。
所以**每次改了 css/js，必须同时把引用处的版本号 `?v=YYYYMMDD` 改成当天日期**，否则白改。

- `yx.css` 的引用在 `template/default/html/comm/head.html`
- `yx-page.css` 的引用在各内页：`about.html` `news.html` `newslist.html` `message.html` `search.html`
- 例：`href="{pboot:sitetplpath}/css/yx.css?v=20260606"` → 改 CSS 后改成新日期，并把这些 html 一起上传。

### 改了 .html 模板后必须清缓存

PbootCMS 会缓存编译后的模板，改了任何 `.html`（含 head.html / 内页 / foot.html）上传后，
必须清服务器运行时缓存才生效：

```bash
SITE=/opt/1panel/apps/openresty/openresty/www/sites/yxcq.scyytc.com/index
ssh root@47.108.251.244 "rm -rf $SITE/runtime/compile/* $SITE/runtime/complile/* $SITE/runtime/cache/*"
```

（只清 compile / complile / cache，不要动 runtime 下的 config/data/session/archive。）

### 注意

- 仅同步改动文件，不要覆盖服务器上的整个目录。
- 上传前确认改动已在本地验证无误。
- 只改了 css/js 内容、又同步 bump 了 `?v=` 版本号 → 用户正常刷新即可看到；没带版本号才需要强刷。
