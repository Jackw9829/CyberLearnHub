# Enhanced Quiz Features — Design Spec
**Date:** 2026-06-18  
**Project:** CyberLearnHub (ASP.NET Web Forms 4.7.2, SQL Server LocalDB)  
**Status:** Approved

---

## Overview

Full enhancement of the quiz system across six feature areas: quiz settings, question bank enrichment, XP/gamification, leaderboard, certificate generation, and admin analytics. All DB migrations run through the existing `EnsureSchema()` pattern. Architecture choice: dedicated tracking tables (Approach B) for fast reads and clean separation.

---

## 1. Database Schema

### Additions to `dbo.Quizzes`
```sql
TimeLimitMinutes   INT NULL                     -- NULL = no limit
MaxAttempts        INT NULL                     -- NULL = unlimited
RandomizeQuestions BIT NOT NULL DEFAULT 0
```

### Additions to `dbo.QuizQuestions`
```sql
Explanation  NVARCHAR(1000) NULL               -- shown post-submission in review
Difficulty   VARCHAR(10)   NOT NULL DEFAULT 'Medium'  -- Easy / Medium / Hard
Topic        VARCHAR(100)  NULL
```

### New table `dbo.QuizAnswers`
Per-question answer record. Enables analytics and restores "your answer" on the review page.
```sql
AnswerID        INT IDENTITY PRIMARY KEY
ResultID        INT NOT NULL  -- FK dbo.QuizResults
QuestionID      INT NOT NULL  -- FK dbo.QuizQuestions
SubmittedAnswer VARCHAR(500) NOT NULL DEFAULT ''
IsCorrect       BIT NOT NULL
```

### New table `dbo.UserXP`
One row per user, upserted on every quiz submission.
```sql
UserID     INT PRIMARY KEY   -- FK dbo.Users
TotalXP    INT NOT NULL DEFAULT 0
Level      INT NOT NULL DEFAULT 1
UpdatedAt  DATETIME NOT NULL DEFAULT GETDATE()
```
**XP formula:**
- Correct answer XP is driven by `Difficulty` (independent of `Marks`): Easy = +10, Medium = +20, Hard = +30
- `Marks` continues to drive quiz scoring (Score / TotalQuestions) as before
- Passing bonus: +50 XP
- Level = `FLOOR(TotalXP / 500) + 1`

### New table `dbo.UserStreaks`
One row per user.
```sql
UserID         INT PRIMARY KEY  -- FK dbo.Users
CurrentStreak  INT NOT NULL DEFAULT 0
LongestStreak  INT NOT NULL DEFAULT 0
LastPassDate   DATE NULL
```
**Streak rules (evaluated on each quiz pass):**
- `LastPassDate == today` → already counted, no change
- `LastPassDate == yesterday` → `CurrentStreak++`
- anything older → `CurrentStreak = 1`
- `if CurrentStreak > LongestStreak → LongestStreak = CurrentStreak`
- Reset: checked lazily on next login — if `LastPassDate < today - 1`, display streak as 0 (do not write reset until next pass)

### New table `dbo.Certificates`
One row per user+course (unique constraint on `UserID, CourseID`). On a new passing attempt, the existing row is updated via `MERGE` — `FilePath`, `ResultID`, and `IssuedDate` are refreshed.
```sql
CertificateID  INT IDENTITY PRIMARY KEY
UserID         INT NOT NULL  -- FK dbo.Users
CourseID       INT NOT NULL  -- FK dbo.Courses
QuizID         INT NOT NULL  -- FK dbo.Quizzes
ResultID       INT NOT NULL  -- FK dbo.QuizResults
IssuedDate     DATETIME NOT NULL DEFAULT GETDATE()
FilePath       VARCHAR(500) NOT NULL  -- ~/Uploads/Certificates/<guid>.pdf
```

---

## 2. Quiz Settings & Enforcement

### Admin — QuizForm.aspx
Three new fields added to the existing form:
- **Time Limit** — number input (minutes). Empty = no limit. Hint: "Leave empty for untimed"
- **Max Attempts** — number input. Empty = unlimited. Edit mode shows current attempt count
- **Randomize Questions** — checkbox. "Shuffle question order for each attempt"

### Student — Quiz.aspx

**Max attempts enforcement:**  
Before loading, count `dbo.QuizResults WHERE UserID=@uid AND QuizID=@qid`. If count ≥ MaxAttempts (non-null), show a locked panel:
> `> Maximum attempts reached. Your best score: X%`  
> `[Back to Course]`

**Randomize questions:**  
If flag set, use `ORDER BY NEWID()` when loading questions. ViewState stores the question order for consistent grading within the attempt.

**Timer:**  
- `Session["QuizStartTime"]` set when quiz loads
- Client renders countdown bar + `MM:SS` display in quiz header
- JS auto-submits form on expiry
- Server validates: if `DateTime.Now - startTime > TimeLimitMinutes + 30s grace`, discard answers, save score = 0, show "Time expired" message
- 30-second grace handles slow connections

---

## 3. Question Bank Enhancements

### Admin — QuestionForm.aspx
New fields below existing question type selector:

**Difficulty selector** — 3-button UI (matching existing qtype-selector style):  
`[Easy]` `[Medium]` `[Hard]` — Medium pre-selected by default

**Topic** — text input with `<datalist>` populated from `SELECT DISTINCT Topic FROM dbo.QuizQuestions WHERE QuizID=@qid`. No separate management screen needed.

**Explanation** — textarea, optional. Label: "Answer Explanation (shown after quiz)". Hint: `"> Explain why this answer is correct — students see this in the review"`

### Admin — ManageQuestions.aspx
Two new columns in question list:
- **Difficulty** badge: green=Easy, amber=Medium, red=Hard
- **Topic** tag (shown if set)

### Student — QuizResult.aspx
With `dbo.QuizAnswers` recording per-question submissions, the review section is fully restored. Each question card shows:
- ✅/❌ + "CORRECT" / "INCORRECT"
- **Your answer** — from `dbo.QuizAnswers.SubmittedAnswer`
- **Correct answer** — resolved text (as before)
- **Explanation** — if set, displayed in an amber highlight block

---

## 4. XP, Streaks & Leaderboard

### XP (computed in `btnSubmit_Click`)
```
XP = Σ(correct questions × difficulty_multiplier) + (passed ? 50 : 0)
```
`MERGE dbo.UserXP` — atomic upsert. Level badge shown on Dashboard and Profile.

### Streak (on pass only)
Logic described in schema section. Displayed on Dashboard as `🔥 N-day streak` (flame icon). Zero displayed if `LastPassDate < yesterday` (lazy reset).

### Per-Quiz Leaderboard
Shown on `QuizResult.aspx` below score card — Top 5 table:

| Rank | Student | Best Score | Attempts |
|------|---------|-----------|---------|

SQL: `SELECT TOP 5 ... MAX(Percentage) AS Best ... GROUP BY UserID ORDER BY Best DESC`  
Current user row highlighted even if outside top 5.

### Global XP Leaderboard — `Leaderboard.aspx`
New page, public (no auth required). Linked from Site.Master nav. Shows top 20 by TotalXP:

| Rank | Student | Level | XP | Streak |
|------|---------|-------|----|--------|

Current user's row always shown with their rank (even if > 20).

---

## 5. Certificate Generation

### Library
`iTextSharp 5.5.13.3` — install via NuGet Package Manager Console:  
`Install-Package iTextSharp`

### `App_Code/CertificateHelper.cs`
Static class with one public method:
```csharp
public static string Generate(
    string userName, string courseName,
    int score, int percentage, DateTime date,
    string outputDirectory)
// Returns saved file path: ~/Uploads/Certificates/<guid>.pdf
```

**PDF layout** (A4 landscape):
- Background: `#080d14` (matches site theme)
- Cyan border frame
- "CyberLearn Hub" header — large Rajdhani-style font
- "Certificate of Achievement" subtitle
- Body: "This certifies that **[Name]** has successfully completed **[Course]** with a score of **[Percentage]%** on **[Date]**"
- Footer: unique cert ID (first 8 chars of GUID) for reference
- No digital signature — cosmetic only

### Download flow
1. On `QuizResult.aspx` — if user just passed: generate/overwrite cert, insert/update `dbo.Certificates`
2. `[Download Certificate]` button appears in score card
3. Button links to `~/GetCertificate.ashx?id=<certId>`
4. `GetCertificate.ashx` (Generic Handler): verifies `Session["UserID"]` owns the cert, streams PDF with `Content-Disposition: attachment; filename="certificate.pdf"`

---

## 6. Admin Analytics

### Reports.aspx — Worst-Performing Questions
Table ranked by failure rate (descending). Only shows questions with ≥ 5 attempts.

| Question | Quiz | Type | Difficulty | Fail Rate | Attempts |
|---|---|---|---|---|---|

Question text links to edit form. SQL joins `dbo.QuizAnswers` + `dbo.QuizQuestions`.

### Reports.aspx — Score Distribution
Per-quiz CSS bar chart (no JS library) showing buckets:
- 0–49%, 50–69%, 70–89%, 90–100%
- Bar width = `(count / total) * 100%`

### CSV Exports
Two Generic Handlers, both admin-only (redirect to AccessDenied if role ≠ Admin):

**`ExportResults.ashx`**  
Columns: Username, Email, Course, Quiz, Score, TotalQuestions, Percentage, Passed, AttemptDate  
Filename: `results-YYYY-MM-DD.csv`

**`ExportQuestionStats.ashx`**  
Columns: QuestionID, QuestionText, Quiz, Course, Difficulty, Topic, TotalAttempts, CorrectCount, IncorrectCount, FailRate%  
Filename: `question-stats-YYYY-MM-DD.csv`

---

## Files Changed / Created

### New Files
| File | Purpose |
|------|---------|
| `App_Code/CertificateHelper.cs` | PDF generation |
| `GetCertificate.ashx` + `.cs` | PDF download handler |
| `ExportResults.ashx` + `.cs` | CSV export handler |
| `ExportQuestionStats.ashx` + `.cs` | CSV question stats handler |
| `Leaderboard.aspx` + `.cs` + `.designer.cs` | Global XP leaderboard page |

### Modified Files
| File | Change |
|------|--------|
| `App_Code/DbHelper.cs` | Add all schema migrations to `EnsureSchema()` |
| `Admin/QuizForm.aspx` + `.cs` | Timer, max attempts, randomize fields |
| `Admin/QuestionForm.aspx` + `.cs` | Difficulty, topic, explanation fields |
| `Admin/ManageQuestions.aspx` + `.cs` | Difficulty/topic columns in list |
| `Admin/Reports.aspx` + `.cs` | Question fail stats, score distribution, CSV export buttons |
| `Quiz.aspx` + `.cs` | Timer UI, max-attempts check, randomize support, save QuizAnswers |
| `QuizResult.aspx` + `.cs` | Restored review (your answer), explanation block, per-quiz leaderboard, cert download button |
| `Dashboard.aspx` + `.cs` | XP level badge, streak display |
| `Site.Master` | Add Leaderboard nav link |

---

## Out of Scope
- Real digital certificate signing / verification service
- Email delivery of certificates
- Push notifications for streak reminders
- Mobile app
