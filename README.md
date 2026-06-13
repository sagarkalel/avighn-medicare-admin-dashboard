# Avighn Medicare — Admin Dashboard

Flutter Web admin panel for pharmacy catalogue management.  
**Backend:** Google Sheets + Apps Script &nbsp;|&nbsp; **Hosting:** GitHub Pages

---

## 🔑 Default Credentials

| Field    | Value                  |
| -------- | ---------------------- |
| Username | `avighn_admin`         |
| Password | `AvighnMedicare@2026!` |

> **Change before deploying!** → `lib/utils/app_constants.dart`

---

## 🚀 6-Step Setup

### 1 — Change Credentials

`lib/utils/app_constants.dart`:

```dart
static const String adminUsername = 'your_username';
static const String adminPassword = 'YourPassword!';
```

### 2 — Create Google Sheet

- Go to [sheets.google.com](https://sheets.google.com) → New spreadsheet
- Name it `Avighn Medicare`
- Copy the Spreadsheet ID from the URL:
  `https://docs.google.com/spreadsheets/d/**COPY_THIS**/edit`

### 3 — Deploy Apps Script Backend

1. Go to [script.google.com](https://script.google.com) → **New Project**
2. Paste the full contents of `Code.gs` (in this repo root)
3. Replace `YOUR_SPREADSHEET_ID_HERE` with your actual ID
4. **Run → `setupSheets`** (authorize when prompted — grants Sheets + Drive access)
5. **Deploy → New Deployment** → Type: Web app → Execute as: **Me** → Access: **Anyone**
6. Copy the **Web App URL**

### 4 — Connect Flutter

`lib/utils/app_constants.dart`:

```dart
static const String appsScriptUrl =
    'https://script.google.com/macros/s/YOUR_ID/exec';
```

### 5 — Run Locally

```bash
flutter pub get
flutter run -d chrome
```

### 6 — Deploy to GitHub Pages

```bash
git init
git add .
git commit -m "Avighn Medicare Admin — initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/avighn-medicare.git
git push -u origin main
```

Then: **GitHub repo → Settings → Pages → Source: GitHub Actions**

Live at: `https://YOUR_USERNAME.github.io/avighn-medicare/`

---

## ✨ Features

- Hardcoded admin login with session persistence
- Full CRUD — add, edit, delete medicines
- One-tap In Stock / Out of Stock toggle
- Up to 5 images per product, drag-to-reorder
- Real-time search + category/stock filters
- Stats cards (total, in-stock, out-of-stock)
- Responsive grid + list view (mobile → desktop)
- ScreenUtil adaptive sizing
- BLoC/Cubit state management
- GoRouter with auth guards
- flutter_animate transitions + shimmer loading
- Product detail view with image carousel

## 📋 Product Fields

`id · name · description · price · discountPercentage · brand · imageUrls · category · dosage · uses · prescriptionRequired · inStock`

## 🛠 Tech Stack

`Flutter Web · BLoC/Cubit · GoRouter · ScreenUtil · flutter_animate · Google Sheets · Apps Script · GitHub Pages`

## 🐛 Troubleshooting

- **CORS errors** → Re-deploy Apps Script with "Anyone" access
- **Products not loading** → Verify `appsScriptUrl` is correct
- **Build fails in CI** → Check Flutter version in `.github/workflows/deploy.yml`
