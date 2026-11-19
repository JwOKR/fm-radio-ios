# 波形电台 WaveFM

iOS 原生 FM 网络电台 App，SwiftUI 编写，GitHub Actions 云端编译产出 IPA，无需 Mac。

## 功能

- 内置 18 个经测速可用的公开网络电台（央广、国际在线 CRI、蜻蜓备线）
- 分类筛选：新闻资讯 / 音乐 / 文化 / 国际
- 关键词搜索、收藏（本地持久化）
- AVPlayer 流式播放，支持 HLS(m3u8) 与 MP3
- 后台播放、锁屏/控制中心播放控制、音量调节
- 播放/缓冲状态与声波动画

## 目录结构

```
WaveFM/
├── WaveFMApp.swift          入口
├── Audio/AudioPlayer.swift  播放内核（AVPlayer + 后台/锁屏）
├── Models/                  电台模型与数据仓库
├── Views/                   界面
├── Resources/stations.json  电台音源清单
└── Assets.xcassets/         图标
project.yml                  XcodeGen 工程定义
.github/workflows/
├── build.yml                无签名 IPA（默认，开箱即用）
└── build-signed.yml         签名 IPA（可选，需开发者证书 Secrets）
```

## 自动编译（GitHub Actions）

推送到 `main`/`master` 即自动触发 `Build iOS IPA`，也可在 Actions 页面手动运行。

产物在对应 Run 页面底部的 **Artifacts → WaveFM-IPA** 下载。

### 方式一：无签名 IPA（默认）

`build.yml` 用 `CODE_SIGNING_ALLOWED=NO` 编译并做 ad-hoc 签名，**不需要任何证书**。安装方式：

- **AltStore / SideStore / Sideloadly**：电脑端工具选择该 IPA，登录 Apple ID 签名后安装到手机（免费账号 7 天有效，需定期重签）
- **巨魔（TrollStore）**：若设备已安装，可直接导入永久安装
- 企业内分发：自行用企业证书重签

### 方式二：签名 IPA（可选）

在仓库 **Settings → Secrets and variables → Actions** 添加：

| Secret | 说明 |
|---|---|
| `CERT_P12_BASE64` | 开发者证书 p12 的 base64 |
| `CERT_PASSWORD` | p12 密码 |
| `PROV_PROFILE_BASE64` | mobileprovision 的 base64 |
| `TEAM_ID` | Apple Developer Team ID |
| `PROV_PROFILE_NAME` | 描述文件名（可选） |

然后手动运行 `Build Signed IPA`，产物为 `WaveFM-IPA-signed`。Ad-hoc 签名需先注册设备 UDID。

> base64 生成：`base64 -i cert.p12 -o cert.txt`

## 本地编译（需 Mac + Xcode）

```bash
brew install xcodegen
xcodegen generate
open WaveFM.xcodeproj
```

Xcode 中选择你的 Team 签名后即可真机运行。

## 修改电台音源

编辑 `WaveFM/Resources/stations.json`，字段说明：

```json
{
  "id": "唯一ID",
  "name": "显示名称",
  "desc": "副标题",
  "group": "分组名",
  "category": "音乐|新闻资讯|文化|国际|其他",
  "url": "m3u8 或 mp3 直链（必须 HTTPS）",
  "color": "主题色 HEX，如 E75A9E"
}
```

推送后 Actions 自动重新编译。

## 备注

- 音源为公开直播流，可能随运营商策略变化失效；App 内置多条备线，失效时切换即可
- Bundle ID：`com.jwokr.wavefm`
- 最低系统：iOS 16.0
