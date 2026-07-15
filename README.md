# CyberLearnHub 🛡️

**An interactive cybersecurity e-learning platform inspired by TryHackMe, built with ASP.NET Web Forms and SQL Server.**

CyberLearnHub helps beginners and students build cybersecurity knowledge through structured courses, quizzes, hands-on CTF-style labs, a discussion forum, and a browser-based attack box — all wrapped in a dark, cybersecurity-themed interface.

> Group Assignment for **Web Applications**, Asia Pacific University of Technology & Innovation.

---

## 📖 Overview

The platform serves three types of users:

| Role | Capabilities |
|---|---|
| **Guest** | Browse courses, view labs, register an account |
| **Registered Member** | Enroll in courses, complete quizzes, attempt CTF-style labs, join the discussion forum, track learning progress |
| **Administrator** | Manage users, courses, quizzes, labs, learning materials, and forum content via CRUD operations |

---

## ✨ Features

- 🔐 **User Authentication** — Registration, login, session-based auth, and forgot/reset password via email
- 📚 **Course Modules** — Structured cybersecurity learning content with progress tracking
- 📝 **Quizzes** — Auto-marking quiz system with a bank of questions and exportable stats
- 🏅 **Certificates & Leaderboard** — Auto-generated PDF certificates and an XP-based leaderboard
- 🧪 **Hands-On Labs** — TryHackMe-style labs with difficulty badges, VPN access, and SHA-256 flag submission
- 🖥️ **Browser-Based Attack Box** — Remote access to a Kali Linux environment via Apache Guacamole (no local VM setup needed)
- 💬 **Discussion Forum** — Threaded forum with attachments, category tags, and pinning
- 🤖 **AI Chatbot Assistant** — Cybersecurity-focused Q&A powered by Groq (Llama 3.1)
- 🏆 **Admin Dashboard** — Full CRUD management for users, courses, quizzes, labs, materials, and the forum, plus contact messages and reports
- 🎨 **Cybersecurity-Themed UI** — Dark mode design with a custom design system

---

## 🛠️ Tech Stack

**Frontend / Backend**
- ASP.NET Web Forms (.NET Framework 4.7.2)
- C#, HTML5, CSS3, JavaScript
- SQL Server Express

**Infrastructure**
- AWS EC2 (Windows Server 2022 web host, Ubuntu VPN & target machines, Kali Linux attack box)
- OpenVPN — secure access into the lab environment
- Apache Guacamole (Docker) — browser-based remote desktop access
- Resend + Cloudflare DNS — transactional email delivery
- Git LFS — versioning the local SQL Server database and other binary assets

**Integrations**
- Groq API (`llama-3.1-8b-instant`) — AI chatbot

---

## 🏗️ Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌────────────────────┐
│   End Users      │────▶│  EC2: Web Server  │────▶│  SQL Server Express │
│ (Browser/VPN)    │     │  IIS + ASP.NET    │     │   (Local DB)        │
└─────────────────┘     └──────────────────┘     └────────────────────┘
                                │
                ┌───────────────┼───────────────┐
                ▼               ▼               ▼
        ┌───────────────┐ ┌───────────┐ ┌───────────────┐
        │ EC2: VPN       │ │ EC2: Kali │ │ EC2: Target    │
        │ (OpenVPN)      │ │ (Attack)  │ │ (DVWA)         │
        └───────────────┘ └───────────┘ └───────────────┘
                                │
                        ┌───────────────┐
                        │ EC2: Guacamole │
                        │ (Docker)       │
                        └───────────────┘
```

All lab instances live in a private subnet and are reachable only via VPN or Guacamole.

---

## 🚀 Getting Started

### Prerequisites
- Visual Studio 2022 (17.13+, for `.slnx` support) with ASP.NET workload
- SQL Server Express + SQL Server Management Studio (SSMS)
- .NET Framework 4.7.2
- [Git LFS](https://git-lfs.com/) — required to pull the database and other binary assets correctly

### Setup

1. **Clone the repository** (make sure Git LFS is installed first, so the `.mdf`/`.ldf` files come down properly)
   ```bash
   git lfs install
   git clone https://github.com/Jackw9829/CyberLearnHub.git
   ```

2. **Attach the database**
   - The local SQL Server database (`Database1.mdf` / `Database1_log.ldf`) is included under `CyberLearnHub/App_Data/` via Git LFS.
   - Attach it in SSMS, or let IIS Express/Visual Studio auto-attach it via the connection string in `Web.config`.

3. **Fill in your secrets in `Web.config`**
   - `Web.config` is committed with placeholder values so the project builds out of the box. Replace the placeholders with your own keys before running features that depend on them:
     ```xml
     <add key="GroqApiKey" value="PUT_YOUR_GROQ_API_KEY_HERE" />
     <add key="ResendApiKey" value="PUT_YOUR_RESEND_API_KEY_HERE" />
     ```
   > ⚠️ Never commit your real keys back over the placeholders — keep them local only.

4. **Open `CyberLearnHub.slnx` in Visual Studio** and run via IIS Express.

---

## 🩹 Disaster Recovery / Local Fallback

If the hosted AWS lab environment (Guacamole/Kali/Target) is ever unreachable, the network-based CTF labs can still be completed locally using a self-contained Docker bundle at [`/kali-fallback`](./kali-fallback). It runs a local Kali attack box against a local DVWA target — no AWS access required — and flags can still be submitted normally on the live platform, since flag checking only validates the hash, not where it was solved.

```bash
cd kali-fallback
docker compose up -d --build
```

See [`kali-fallback/README.md`](./kali-fallback/README.md) for full setup, and the [Disaster Recovery wiki page](../../wiki/Disaster-Recovery-Plan) for the complete backup strategy, including the web server/database fallback tiers.

> Note: this only applies to the network/web-based labs. The file-based challenges (steganography, EXIF metadata, hidden PDF text, password-protected ZIP) need no attack box at all and are unaffected by any infrastructure outage.

---

## 📁 Project Structure

```
CyberLearnHub/
├── CyberLearnHub.slnx          # Visual Studio solution
├── CyberLearnHub/
│   ├── Admin/                  # Admin CRUD pages (ManageUsers, ManageCourses, ManageLabs, ManageForums, Reports, ...)
│   ├── App_Code/                # AuthHelper, DbHelper, CertificateHelper, AdminBasePage
│   ├── App_Data/                 # Local SQL Server database (Git LFS)
│   ├── Forum/                   # Discussion forum (Index, ThreadDetail)
│   ├── LabMaterials/             # Per-lab downloadable files
│   ├── Styles/                   # Per-page CSS (cyberpunk dark theme, --cyber-* variables)
│   ├── Uploads/                  # User-uploaded content (avatars, certificates, forum/course attachments)
│   ├── VPNConfigs/                # .ovpn files issued to students for lab access
│   ├── Site.Master                # Shared site layout (includes the AI chatbot widget)
│   ├── Chatbot.aspx / ChatbotHandler.ashx
│   ├── Login.aspx / Register.aspx / ForgotPassword.aspx / ResetPassword.aspx
│   ├── CourseListing.aspx / CourseDetail.aspx / MyCourses.aspx
│   ├── Quiz.aspx / QuizResult.aspx / Leaderboard.aspx / MyProgress.aspx
│   ├── Labs.aspx / Dashboard.aspx / Profile.aspx / Contact.aspx / About.aspx
│   └── Web.config                # App settings & connection strings (placeholders committed)
├── kali-fallback/                # Local disaster-recovery lab bundle (Kali + DVWA via Docker Compose)
└── docs/                        # Project & planning docs
```

---

## 👥 Team

| Name |
|---|
| Benny Yong Bin |
| Wang Zi Jie |
| Wong Jun Ming |

---

## 📄 License

This project is developed for academic purposes as part of the Web Applications module at APU. Not intended for production use.
