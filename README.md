# 小猫私教 macOS App

这是一个原生 SwiftUI MVP，适合度假、旅行、拍照、重要日期或日常塑形准备。

## 运行

```bash
cd work/PersonalTrainer
swift run
```

## 生成可双击 App

```bash
cd work/PersonalTrainer
chmod +x Scripts/package_app.sh
Scripts/package_app.sh
```

生成后可以双击：

```text
outputs/小猫私教.app
```

体重、目标体重、围度、清单等数据会保存到本机：

```text
~/Library/Application Support/PersonalTrainer/app-state.json
```

## 文件结构

- `Package.swift` - macOS 可执行应用的 Swift Package 定义。
- `Sources/PersonalTrainerApp/PersonalTrainerApp.swift` - 应用入口。
- `Sources/PersonalTrainerApp/Models` - 可编码的数据模型。
- `Sources/PersonalTrainerApp/Data` - 本地 AppStore 与 mock 种子数据。
- `Sources/PersonalTrainerApp/Views` - 仪表盘、身体目标、训练、饮食、进度、每周复盘、设定、首次引导和教练页面。
- `Sources/PersonalTrainerApp/Coach` - 离线安全教练逻辑。
- `Sources/PersonalTrainerApp/Design` - 共享颜色与 SwiftUI 组件。

## MVP 说明

- 数据目前通过 `AppStore` 和 mock 数据本地保存；之后可以在相同方法后面替换成 SQLite。
- MVP 不包含登录或云同步。
- App 避免极端节食、不安全减重、局部减脂承诺和重要日期前速成建议。
- 教练功能目前是规则驱动的离线 MVP；之后可以接入 AI API，并沿用相同安全策略与本地用户上下文。

## 新增功能

- 首次打开会出现快速引导，集中设置日期、身高、体重、目标和重点部位。
- 长期设定统一在「设定」页，不再散落在多个页面。
- 可选择中文或 English，主要界面、训练、餐食和教练会随语言切换。
- 可选择背景颜色：温柔粉、奶油杏、淡紫梦、薄荷绿。
- 背景颜色会切换整套主题色，包括卡片、按钮、标题、猫猫贴图和高亮色。
- Finder/Dock app 图标已换成小猫。
- 围度记录加入真实个人列表；没有记录时保持空状态。
- 进度记录加入每日体重表，体重和围度都支持单条删除。
- 饮食页加入每日热量表、单条删除和食物照片上传缩略图。
- 训练计划会根据身高、体重和重点部位调整，并支持插入/删除自选活动。
- 设定页支持一键清空记录历史，但保留目标和主题。
- 训练动作支持自定义视频参考链接，可放 YouTube 或哔哩哔哩链接，并可在 App 内预览。
- 已加入 `.gitignore`，方便之后放到 GitHub。
