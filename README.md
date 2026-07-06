# CyberLearnHub 🛡️

**An interactive cybersecurity e-learning platform inspired by TryHackMe, built with ASP.NET Web Forms and SQL Server.**

CyberLearnHub helps beginners and students build cybersecurity knowledge through structured courses, quizzes, hands-on CTF-style labs, and a browser-based attack box — all wrapped in a dark, cybersecurity-themed interface.

> Group Assignment for **CT050-3-2-WAPP (Web Applications)**, Asia Pacific University of Technology & Innovation.

---

## 📖 Overview

The platform serves three types of users:

| Role | Capabilities |
|---|---|
| **Guest** | Browse courses, view labs, register an account |
| **Registered Member** | Enroll in courses, complete quizzes, attempt CTF-style labs, track learning progress |
| **Administrator** | Manage users, courses, quizzes, and lab content via CRUD operations |

---

## ✨ Features

- 🔐 **User Authentication** — Registration, login, session-based auth, and forgot/reset password via email
- 📚 **Course Modules** — Structured cybersecurity learning content with progress tracking
- 📝 **Quizzes** — Auto-marking quiz system to test understanding of concepts
- 🧪 **Hands-On Labs** — TryHackMe-style labs with difficulty badges, VPN access, and SHA-256 flag submission
- 🖥️ **Browser-Based Attack Box** — Remote access to a Kali Linux environment via Apache Guacamole (no local VM setup needed)
- 🤖 **AI Chatbot Assistant** — Cybersecurity-focused Q&A powered by Groq (Llama 3.1)
- 🏆 **Admin Dashboard** — Full CRUD management for users, labs, courses, and quizzes
- 🎨 **Cybersecurity-Themed UI** — Dark mode design with a custom design system

---

## 🛠️ Tech Stack

**Frontend / Backend**
- ASP.NET Web Forms (.NET Framework 4.7.2)
- C#, HTML5, CSS3, JavaScript
- SQL Server Express (SSMS)

**Infrastructure**
- AWS EC2 (Windows Server 2022 web host, Ubuntu VPN & target machines, Kali Linux attack box)
- OpenVPN — secure access into the lab environment
- Apache Guacamole (Docker) — browser-based remote desktop access
- Resend + Cloudflare DNS — transactional email delivery

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
- Visual Studio (2022 recommended) with ASP.NET workload
- SQL Server 2025 Express + SQL Server Management Studio (SSMS)
- .NET Framework 4.7.2

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/Jackw9829/CyberLearnHub.git
   ```

2. **Set up the database**
   - Open SSMS and create a new database.
   - Run the provided `.sql` scripts (schema + seed data) from the `database` folder.

3. **Configure `Web.config`**
   - Copy `Web.config.example` to `Web.config`.
   - Fill in your own values:
     ```xml
     <add key="CyberLearnConnection" value="Data Source=.\SQLEXPRESS;Initial Catalog=CyberLearnHub;Integrated Security=True" />
     <add key="GroqApiKey" value="YOUR_GROQ_API_KEY" />
     <add key="ResendApiKey" value="YOUR_RESEND_API_KEY" />
     <add key="ResendFromEmail" value="noreply@yourdomain.com" />
     <add key="SiteBaseUrl" value="http://localhost:PORT" />
     ```
   > ⚠️ Never commit your real `Web.config` — it's excluded via `.gitignore`.

4. **Open in Visual Studio** and run the solution (`CyberLearnHub.sln`) via IIS Express.

---

## 📁 Project Structure

```
CyberLearnHub/
├── Admin/                  # Admin CRUD pages (ManageLabs, ManageUsers, etc.)
├── Chatbot.aspx(.cs)       # AI chatbot page
├── ChatbotHandler.ashx     # Groq API handler
├── Labs.aspx(.cs)          # Student lab listing & flag submission
├── Login.aspx / Register.aspx
├── cyberlearnhub_homepage.aspx
├── Web.config.example      # Template config (no secrets)
└── ...
```

---

## 👥 Team

| Name |
|---|
| Benny Yong Bin 
| Wang Zi Jie 
| Wong Jun Ming 


---

## 📄 License

This project is developed for academic purposes as part of the CT050-3-2-WAPP module at APU. Not intended for production use.
