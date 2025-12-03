# Documentation for Strapi Daily Work Logs CMS

A Strapi v5.31.2 headless CMS built with TypeScript for managing daily work logs.

## 📋 Project Overview

This Strapi application is a headless CMS designed for tracking daily work activities and productivity. It provides:

- **Intuitive Admin Panel** - User-friendly interface for content creation and management
- **RESTful API** - Auto-generated API endpoints for all content types
- **SQLite Database** - Lightweight database for local development (easily configurable for PostgreSQL/MySQL)
- **Media Library** - Advanced media management with support for images, videos, audio files, and documents
- **Custom Content Types** - Pre-configured Daily Work Log collection with rich text editing
- **User Authentication** - Built-in user management and permissions system

## 📁 Project Structure

```
myStrapi/
├── config/                    # Application configuration
│   ├── admin.ts
│   ├── api.ts
│   ├── database.ts
│   ├── middlewares.ts
│   ├── plugins.ts
│   └── server.ts
├── src/
│   ├── admin/                 # Admin panel customization
│   │   ├── app.example.tsx
│   │   ├── tsconfig.json
│   │   └── vite.config.example.ts
│   ├── api/
│   │   └── daily-work-log/    # Daily Work Logs API
│   │       ├── content-types/
│   │       │   └── daily-work-log/
│   │       │       └── schema.json
│   │       ├── controllers/
│   │       │   └── daily-work-log.ts
│   │       ├── routes/
│   │       │   └── daily-work-log.ts
│   │       └── services/
│   │           └── daily-work-log.ts
│   ├── extensions/            # Strapi extensions
│   └── index.ts
├── .tmp/                      # SQLite database location
│   └── data.db
├── public/                    # Static files & uploads
├── .env.example
├── package.json
└── tsconfig.json
```

## 🚀 Installation & Setup

### 1. Install Dependencies

```bash
npm install
```

Update `.env` with your secrets (generate new keys for production).

### 2. Build the Application

```bash
npm run build
```

## 🎨 Starting the Admin Panel

### Development Mode

```bash
npm run develop
```

Admin panel: **http://localhost:1337/admin**

### Production Mode

```bash
npm run start
```

### First Login

1. Visit `http://localhost:1337/admin`
2. Create your admin account
3. Complete registration

## 📝 Content Type: Daily Work Logs

**API Endpoint:** `/api/daily-work-logs`

**Schema Details:**
- **Collection Type:** `daily_work_logs`
- **Draft & Publish:** Enabled

**Fields:**
- `date` (DateTime) - Date and time of the work log entry
- `tasks_completed` (Blocks/Rich Text) - Detailed description of completed tasks with rich formatting
- `pending_tasks` (Blocks/Rich Text) - List of pending or upcoming tasks
- `mood` (Blocks/Rich Text) - Notes about mood, productivity, or general reflections
- `screenshot` (Media, Multiple) - Upload multiple files (images, videos, audio, documents)

**Creating a Work Log:**

1. Navigate to **Content Manager → Daily Work Logs**
2. Click **"Create new entry"**
3. Select the date and time
4. Add completed and pending tasks using the rich text editor
5. Document your mood or notes
6. Upload relevant screenshots or files
7. Click **Save** (draft) or **Save & Publish** (live)


## ⚙️ Configuration

- **Database:** SQLite (`.tmp/data.db`)
- **Port:** 1337
- **Host:** 0.0.0.0
- **Admin Path:** `/admin`

## 🛠️ NPM Scripts

```bash
npm run develop    # Development with auto-reload
npm run start      # Production mode
npm run build      # Build admin panel
```

## 📦 Push to GitHub

### 1. Verify .gitignore

Ensures these are ignored:
- `node_modules/`
- `.env`
- `.tmp/`
- `build/`, `dist/`, `.cache/`

### 2. Create Repository

On GitHub, create a new repository.

### 3. Push Code

```bash
git init
git add .
git commit -m "Initial commit: Strapi CMS with daily work logs"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git
git push -u origin main
```

