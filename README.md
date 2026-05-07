# POLICY ARCADE

> 用有趣有效的方式 ・ 推動嚴肅的政策
> 公共行政暨政策學系 ・ 2026.05.07 ・ 講師：何佳勳

8-bit 像素風課程輔助站。學員掃 QR 進入，互動瀏覽 + 報到 + Octalysis 設計器 + 小組任務提交。

## 結構

```
policy-arcade/
├── index.html             # 主站（單檔 6 tab）
├── admin.html             # 後台（密碼 angle301）
├── og.png                 # 1200×630 像素風 OG 圖
├── make-og.py             # OG 生成腳本（需 Pillow）
├── supabase-migration.sql # DB schema（pa_ 前綴）
├── vercel.json            # Vercel headers + clean URLs
└── README.md
```

## 部署到 Vercel

### 1. 跑 Supabase migration（必做）

到 [Supabase SQL Editor](https://supabase.com/dashboard/project/dpglkagtzdwiovzbtase/sql) 執行 `supabase-migration.sql`。會建：
- `pa_attendees` / `pa_questions` 兩張表
- 5 個 RPC：`pa_attendee_count` / `pa_public_quests` / `pa_update_attendee` / `pa_admin_stats`

### 2. 部署到 Vercel（兩種方式）

**A. CLI 部署（最快）**
```bash
npm i -g vercel
cd c:/myclaude/policy-arcade
vercel --prod
```
第一次會問專案名稱，輸入 `policy-arcade` 即可。完成後會給你 `https://policy-arcade.vercel.app`。

**B. GitHub 連動部署**
1. 把 `policy-arcade/` push 到 GitHub repo
2. 到 [vercel.com/new](https://vercel.com/new) 連結 repo
3. 選 "Other" framework，根目錄不變，按 Deploy
4. 完成後設定 custom domain（如要用自己網域）

### 3. 更新 OG 網址

預設 OG 寫的是 `https://policy-arcade.vercel.app/og.png`。如果你最後用其他網域，記得改 [index.html](index.html) 的 `<meta property="og:image">` 和 `<meta property="og:url">`。

## 課程當天使用

1. **講師端**：
   - 開幕前打開 `https://你的網域/admin.html`，輸入密碼 `angle301`
   - 投影機切到 admin 後台 → 學員報到、提問、小組進度即時看
2. **學員端**：
   - 投影 QR code 給學員掃 → 進入主站
   - 流程：報到 → 看 Stage 1-3 → 完成 Stage 4 小組任務 → 累積 EXP

## EXP 規則

- 報到 +5
- 看每個案例 +1（共 8 個 = 最多 +8）
- 完成 Octalysis 設計器 +10
- 提交小組任務 +15
- 提問 +3

總分 60 分。每完成一個事件 +2 coins。

## 後台密碼

`angle301`（在 `pa_admin_stats` SQL function 裡），如要改去 SQL Editor 改函式。

## 外部資源連結（已內建）

| 國家 | 主要連結 |
|---|---|
| 🇸🇪 瑞典 | [The Speed Camera Lottery 影片](https://www.youtube.com/watch?v=iynzHWwJXaA) ・ [Fun Theory 維基](https://en.wikipedia.org/wiki/The_Fun_Theory) |
| 🇸🇬 新加坡 | [Healthy 365](https://www.healthhub.sg/programmes/nsc) ・ [HPB NSC](https://hpb.gov.sg/healthy-living/national-steps-challenge) |
| 🇰🇷 韓國 | [首爾 Eco Mileage](https://ecomileage.seoul.go.kr/) ・ [CNPS](https://www.cpoint.or.kr/) |
| 🇪🇪 愛沙尼亞 | [Bürokratt](https://www.kratid.ee/en) ・ [GitHub](https://github.com/buerokratt) ・ [e-Estonia](https://e-estonia.com/) |
| 🇺🇸 美國 | [Foldit](https://fold.it/) ・ [M-PMV 論文](https://www.nature.com/articles/nsmb.2119) |
| 🇹🇼 台灣 | [vTaiwan](https://www.vtaiwan.tw/) ・ [Pol.is](https://pol.is/home) ・ [g0v](https://g0v.tw/) |
| 🇬🇧 英國 | [BIT](https://www.bi.team/) |
| Bonus | [Duolingo](https://www.duolingo.com/) |
| 理論 | [Octalysis](https://yukaichou.com/gamification-examples/octalysis-complete-gamification-framework/) ・ [SDT](https://selfdeterminationtheory.org/) ・ [Deterding 2011](https://dl.acm.org/doi/10.1145/2181037.2181040) |
