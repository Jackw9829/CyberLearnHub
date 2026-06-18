# Enhanced Quiz Features Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add timer, max attempts, randomization, difficulty/topic/explanation on questions, per-question answer tracking, XP/streaks, leaderboards, PDF certificates, and admin analytics to the existing CyberLearnHub quiz system.

**Architecture:** All DB migrations go through `DbHelper.EnsureSchema()` using `IF NOT EXISTS` guards so they are safe to run repeatedly. New features are layered on top of existing `Quiz.aspx` / `QuizResult.aspx` / `Admin/QuizForm.aspx` / `Admin/QuestionForm.aspx`. Generic Handlers (`.ashx`) serve file downloads (PDF cert, CSV exports) to keep page lifecycle overhead out of binary responses.

**Tech Stack:** ASP.NET Web Forms 4.7.2, C# 7, SQL Server LocalDB, iTextSharp 5.5.13 (NuGet), no JS frameworks.

---

## File Map

### New files
| File | Purpose |
|------|---------|
| `App_Code/CertificateHelper.cs` | iTextSharp PDF generation |
| `GetCertificate.ashx` + `.cs` | Stream PDF to browser |
| `ExportResults.ashx` + `.cs` | Stream quiz results CSV |
| `ExportQuestionStats.ashx` + `.cs` | Stream question fail-rate CSV |
| `Leaderboard.aspx` + `.cs` + `.designer.cs` | Global XP leaderboard page |

### Modified files
| File | Change |
|------|--------|
| `App_Code/DbHelper.cs` | Add all 6 schema migrations to `EnsureSchema()` |
| `Admin/QuizForm.aspx` + `.cs` + `.designer.cs` | Timer, max attempts, randomize fields |
| `Admin/QuestionForm.aspx` + `.cs` + `.designer.cs` | Difficulty, topic, explanation fields |
| `Admin/ManageQuestions.aspx` + `.cs` | Difficulty/topic columns |
| `Admin/Reports.aspx` + `.cs` + `.designer.cs` | Fail stats, score distribution, CSV buttons |
| `Quiz.aspx` + `.cs` | Timer UI, max-attempts gate, randomize, save QuizAnswers, award XP/streak |
| `QuizResult.aspx` + `.cs` + `.designer.cs` | Full review restore, per-quiz leaderboard, cert button |
| `Dashboard.aspx` + `.cs` + `.designer.cs` | XP level badge, streak display |
| `Site.Master` | Add Leaderboard nav link |
| `CyberLearnHub.csproj` | Register all new files |

---

## Task 1: DB Schema Migrations

**Files:**
- Modify: `CyberLearnHub/App_Code/DbHelper.cs`

- [ ] **Step 1: Replace `EnsureSchema()` with the full migration set**

Open `App_Code/DbHelper.cs` and replace the entire `EnsureSchema()` method body with:

```csharp
public static void EnsureSchema()
{
    if (_schemaReady) return;
    lock (_lock)
    {
        if (_schemaReady) return;
        using (SqlConnection conn = new SqlConnection(ConnectionString))
        {
            conn.Open();

            // 1. QuizQuestions.QuestionType (already exists — keep guard)
            Execute(conn, @"
                IF NOT EXISTS (SELECT 1 FROM sys.columns
                    WHERE object_id=OBJECT_ID('dbo.QuizQuestions') AND name='QuestionType')
                ALTER TABLE dbo.QuizQuestions
                ADD QuestionType VARCHAR(20) NOT NULL DEFAULT 'MultipleChoice'");

            // 2. QuizQuestions — Difficulty, Topic, Explanation
            Execute(conn, @"
                IF NOT EXISTS (SELECT 1 FROM sys.columns
                    WHERE object_id=OBJECT_ID('dbo.QuizQuestions') AND name='Difficulty')
                ALTER TABLE dbo.QuizQuestions
                ADD Difficulty VARCHAR(10) NOT NULL DEFAULT 'Medium'");

            Execute(conn, @"
                IF NOT EXISTS (SELECT 1 FROM sys.columns
                    WHERE object_id=OBJECT_ID('dbo.QuizQuestions') AND name='Topic')
                ALTER TABLE dbo.QuizQuestions
                ADD Topic VARCHAR(100) NULL");

            Execute(conn, @"
                IF NOT EXISTS (SELECT 1 FROM sys.columns
                    WHERE object_id=OBJECT_ID('dbo.QuizQuestions') AND name='Explanation')
                ALTER TABLE dbo.QuizQuestions
                ADD Explanation NVARCHAR(1000) NULL");

            // 3. Quizzes — TimeLimitMinutes, MaxAttempts, RandomizeQuestions
            Execute(conn, @"
                IF NOT EXISTS (SELECT 1 FROM sys.columns
                    WHERE object_id=OBJECT_ID('dbo.Quizzes') AND name='TimeLimitMinutes')
                ALTER TABLE dbo.Quizzes
                ADD TimeLimitMinutes INT NULL");

            Execute(conn, @"
                IF NOT EXISTS (SELECT 1 FROM sys.columns
                    WHERE object_id=OBJECT_ID('dbo.Quizzes') AND name='MaxAttempts')
                ALTER TABLE dbo.Quizzes
                ADD MaxAttempts INT NULL");

            Execute(conn, @"
                IF NOT EXISTS (SELECT 1 FROM sys.columns
                    WHERE object_id=OBJECT_ID('dbo.Quizzes') AND name='RandomizeQuestions')
                ALTER TABLE dbo.Quizzes
                ADD RandomizeQuestions BIT NOT NULL DEFAULT 0");

            // 4. dbo.QuizAnswers
            Execute(conn, @"
                IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='QuizAnswers')
                CREATE TABLE dbo.QuizAnswers (
                    AnswerID        INT IDENTITY(1,1) PRIMARY KEY,
                    ResultID        INT NOT NULL,
                    QuestionID      INT NOT NULL,
                    SubmittedAnswer VARCHAR(500) NOT NULL DEFAULT '',
                    IsCorrect       BIT NOT NULL
                )");

            // 5. dbo.UserXP
            Execute(conn, @"
                IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='UserXP')
                CREATE TABLE dbo.UserXP (
                    UserID    INT PRIMARY KEY,
                    TotalXP   INT NOT NULL DEFAULT 0,
                    Level     INT NOT NULL DEFAULT 1,
                    UpdatedAt DATETIME NOT NULL DEFAULT GETDATE()
                )");

            // 6. dbo.UserStreaks
            Execute(conn, @"
                IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='UserStreaks')
                CREATE TABLE dbo.UserStreaks (
                    UserID        INT PRIMARY KEY,
                    CurrentStreak INT NOT NULL DEFAULT 0,
                    LongestStreak INT NOT NULL DEFAULT 0,
                    LastPassDate  DATE NULL
                )");

            // 7. dbo.Certificates
            Execute(conn, @"
                IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='Certificates')
                CREATE TABLE dbo.Certificates (
                    CertificateID INT IDENTITY(1,1) PRIMARY KEY,
                    UserID        INT NOT NULL,
                    CourseID      INT NOT NULL,
                    QuizID        INT NOT NULL,
                    ResultID      INT NOT NULL,
                    IssuedDate    DATETIME NOT NULL DEFAULT GETDATE(),
                    FilePath      VARCHAR(500) NOT NULL,
                    CONSTRAINT UQ_Cert_UserCourse UNIQUE (UserID, CourseID)
                )");
        }
        _schemaReady = true;
    }
}
```

- [ ] **Step 2: Verify migrations run**

Run the app (`F5` in Visual Studio). Navigate to any admin page (e.g., `localhost:PORT/Admin/`). This triggers `AdminBasePage.OnInit` → `EnsureSchema()`.

Then open SQL Server Object Explorer and confirm these columns/tables exist:
- `dbo.QuizQuestions`: `Difficulty`, `Topic`, `Explanation` columns visible
- `dbo.Quizzes`: `TimeLimitMinutes`, `MaxAttempts`, `RandomizeQuestions` columns visible
- New tables: `dbo.QuizAnswers`, `dbo.UserXP`, `dbo.UserStreaks`, `dbo.Certificates`

- [ ] **Step 3: Commit**

```bash
git add CyberLearnHub/App_Code/DbHelper.cs
git commit -m "feat: add full schema migrations for enhanced quiz features"
```

---

## Task 2: Quiz Settings — Admin Form

**Files:**
- Modify: `CyberLearnHub/Admin/QuizForm.aspx`
- Modify: `CyberLearnHub/Admin/QuizForm.aspx.cs`
- Modify: `CyberLearnHub/Admin/QuizForm.aspx.designer.cs`

- [ ] **Step 1: Add three new fields to `QuizForm.aspx`**

In `Admin/QuizForm.aspx`, replace the closing `</div>` of the passing score group and the button row with:

```aspx
        <div class="form-group" style="max-width:180px;">
            <label class="form-label">Passing Score (%) *</label>
            <asp:TextBox ID="txtPassingScore" runat="server" CssClass="form-control" Text="70" MaxLength="3" />
            <asp:RequiredFieldValidator ID="rfvScore" runat="server"
                ControlToValidate="txtPassingScore" CssClass="form-error"
                ErrorMessage="&gt; Passing score is required." Display="Dynamic" />
            <asp:RangeValidator ID="rvScore" runat="server"
                ControlToValidate="txtPassingScore" Type="Integer" MinimumValue="1" MaximumValue="100"
                CssClass="form-error" ErrorMessage="&gt; Must be between 1 and 100." Display="Dynamic" />
            <span class="form-hint">Minimum percentage to pass (1&ndash;100)</span>
        </div>

        <div class="form-row">
            <div class="form-group" style="max-width:180px;">
                <label class="form-label">Time Limit (minutes)</label>
                <asp:TextBox ID="txtTimeLimit" runat="server" CssClass="form-control" MaxLength="3" placeholder="e.g. 30" />
                <span class="form-hint">Leave empty for untimed</span>
            </div>
            <div class="form-group" style="max-width:180px;">
                <label class="form-label">Max Attempts</label>
                <asp:TextBox ID="txtMaxAttempts" runat="server" CssClass="form-control" MaxLength="3" placeholder="e.g. 3" />
                <span class="form-hint">Leave empty for unlimited</span>
            </div>
        </div>

        <div class="form-group">
            <label class="form-label" style="display:flex;align-items:center;gap:10px;cursor:pointer;">
                <asp:CheckBox ID="chkRandomize" runat="server" />
                Randomize question order each attempt
            </label>
        </div>

        <div style="display:flex;gap:12px;margin-top:8px;padding-top:16px;border-top:1px solid var(--cyber-border);">
            <asp:Button ID="btnSave" runat="server" Text="Save Quiz"
                CssClass="btn-admin-primary" OnClick="btnSave_Click" />
            <asp:HyperLink ID="hlBack" runat="server" CssClass="btn-secondary">Cancel</asp:HyperLink>
        </div>
```

- [ ] **Step 2: Update `QuizForm.aspx.designer.cs`**

Replace the entire file:

```csharp
namespace CyberLearnHub.Admin
{
    public partial class QuizForm
    {
        protected global::System.Web.UI.WebControls.Literal litPageTitle;
        protected global::System.Web.UI.WebControls.Panel pnlAlert;
        protected global::System.Web.UI.WebControls.Label lblAlert;
        protected global::System.Web.UI.WebControls.TextBox txtTitle;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvTitle;
        protected global::System.Web.UI.WebControls.TextBox txtDescription;
        protected global::System.Web.UI.WebControls.TextBox txtPassingScore;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvScore;
        protected global::System.Web.UI.WebControls.RangeValidator rvScore;
        protected global::System.Web.UI.WebControls.TextBox txtTimeLimit;
        protected global::System.Web.UI.WebControls.TextBox txtMaxAttempts;
        protected global::System.Web.UI.WebControls.CheckBox chkRandomize;
        protected global::System.Web.UI.WebControls.Button btnSave;
        protected global::System.Web.UI.WebControls.HyperLink hlBack;
    }
}
```

- [ ] **Step 3: Update `QuizForm.aspx.cs` — load and save new fields**

Replace the full file:

```csharp
using System;
using System.Data.SqlClient;

namespace CyberLearnHub.Admin
{
    public partial class QuizForm : AdminBasePage
    {
        private int _id, _courseId;

        protected void Page_Load(object sender, EventArgs e)
        {
            int.TryParse(Request.QueryString["id"],       out _id);
            int.TryParse(Request.QueryString["courseId"], out _courseId);

            if (_courseId <= 0) { Response.Redirect("ManageCourses.aspx"); return; }
            hlBack.NavigateUrl = "ManageQuizzes.aspx?courseId=" + _courseId;

            if (!IsPostBack && _id > 0)
            {
                litPageTitle.Text = "Edit Quiz";
                LoadQuiz(_id);
            }
        }

        private void LoadQuiz(int id)
        {
            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT Title, Description, PassingScore, TimeLimitMinutes, MaxAttempts, RandomizeQuestions FROM dbo.Quizzes WHERE QuizID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (!r.Read()) { Response.Redirect("ManageQuizzes.aspx?courseId=" + _courseId); return; }
                    txtTitle.Text        = r["Title"] as string ?? "";
                    txtDescription.Text  = r["Description"] as string ?? "";
                    txtPassingScore.Text = r["PassingScore"]?.ToString() ?? "70";
                    txtTimeLimit.Text    = r["TimeLimitMinutes"] == DBNull.Value ? "" : r["TimeLimitMinutes"].ToString();
                    txtMaxAttempts.Text  = r["MaxAttempts"]      == DBNull.Value ? "" : r["MaxAttempts"].ToString();
                    chkRandomize.Checked = r["RandomizeQuestions"] != DBNull.Value && (bool)r["RandomizeQuestions"];
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            int.TryParse(Request.QueryString["id"],       out _id);
            int.TryParse(Request.QueryString["courseId"], out _courseId);
            int.TryParse(txtPassingScore.Text.Trim(),     out int score);

            string title = txtTitle.Text.Trim();
            string desc  = txtDescription.Text.Trim();
            int?   timeLimit   = string.IsNullOrWhiteSpace(txtTimeLimit.Text)   ? (int?)null : int.Parse(txtTimeLimit.Text.Trim());
            int?   maxAttempts = string.IsNullOrWhiteSpace(txtMaxAttempts.Text) ? (int?)null : int.Parse(txtMaxAttempts.Text.Trim());
            bool   randomize   = chkRandomize.Checked;

            if (_id > 0)
            {
                using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
                using (SqlCommand cmd = new SqlCommand(@"
                    UPDATE dbo.Quizzes
                    SET Title=@t, Description=@d, PassingScore=@s,
                        TimeLimitMinutes=@tl, MaxAttempts=@ma, RandomizeQuestions=@rnd
                    WHERE QuizID=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@t",   title);
                    cmd.Parameters.AddWithValue("@d",   desc);
                    cmd.Parameters.AddWithValue("@s",   score);
                    cmd.Parameters.AddWithValue("@tl",  (object)timeLimit   ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@ma",  (object)maxAttempts ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@rnd", randomize);
                    cmd.Parameters.AddWithValue("@id",  _id);
                    conn.Open(); cmd.ExecuteNonQuery();
                }
            }
            else
            {
                using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
                using (SqlCommand cmd = new SqlCommand(@"
                    INSERT INTO dbo.Quizzes (CourseID,Title,Description,PassingScore,TimeLimitMinutes,MaxAttempts,RandomizeQuestions)
                    VALUES (@cid,@t,@d,@s,@tl,@ma,@rnd)", conn))
                {
                    cmd.Parameters.AddWithValue("@cid", _courseId);
                    cmd.Parameters.AddWithValue("@t",   title);
                    cmd.Parameters.AddWithValue("@d",   desc);
                    cmd.Parameters.AddWithValue("@s",   score);
                    cmd.Parameters.AddWithValue("@tl",  (object)timeLimit   ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@ma",  (object)maxAttempts ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@rnd", randomize);
                    conn.Open(); cmd.ExecuteNonQuery();
                }
            }

            Response.Redirect("ManageQuizzes.aspx?courseId=" + _courseId + "&saved=1");
        }
    }
}
```

- [ ] **Step 4: Verify**

Run app → Admin → edit a quiz → new fields appear → save with a 5-minute time limit, max 2 attempts, randomize checked → re-open edit form → values preserved.

- [ ] **Step 5: Commit**

```bash
git add CyberLearnHub/Admin/QuizForm.aspx CyberLearnHub/Admin/QuizForm.aspx.cs CyberLearnHub/Admin/QuizForm.aspx.designer.cs
git commit -m "feat: add timer, max attempts, randomize fields to quiz admin form"
```

---

## Task 3: Quiz Settings — Student Enforcement

**Files:**
- Modify: `CyberLearnHub/Quiz.aspx`
- Modify: `CyberLearnHub/Quiz.aspx.cs`

- [ ] **Step 1: Update `LoadQuiz` in `Quiz.aspx.cs` to load quiz settings and enforce max attempts**

In `Quiz.aspx.cs`, replace the SQL in the second `using` block (the one that fetches QuizID) and add enforcement logic. Replace the entire `LoadQuiz` method:

```csharp
private void LoadQuiz(int uid)
{
    using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
    {
        conn.Open();

        using (SqlCommand cmd = new SqlCommand(
            "SELECT Title FROM dbo.Courses WHERE CourseID = @id AND IsPublished = 1", conn))
        {
            cmd.Parameters.AddWithValue("@id", _courseId);
            object result = cmd.ExecuteScalar();
            if (result == null) { Response.Redirect("~/Error.aspx"); return; }
            lblCourseName.Text = Server.HtmlEncode(result.ToString());
        }

        int timeLimitMinutes = 0;
        int maxAttempts      = 0;
        bool randomize       = false;

        using (SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 1 QuizID, ISNULL(TimeLimitMinutes,0), ISNULL(MaxAttempts,0), ISNULL(RandomizeQuestions,0)
            FROM dbo.Quizzes WHERE CourseID = @cid", conn))
        {
            cmd.Parameters.AddWithValue("@cid", _courseId);
            using (SqlDataReader r = cmd.ExecuteReader())
            {
                if (!r.Read())
                {
                    pnlQuiz.Visible  = false;
                    pnlAlert.Visible = true;
                    lblAlert.Text    = "&gt; No quiz available for this course yet.";
                    return;
                }
                _quizId          = r.GetInt32(0);
                timeLimitMinutes = r.GetInt32(1);
                maxAttempts      = r.GetInt32(2);
                randomize        = r.GetBoolean(3);
                ViewState["QuizID"] = _quizId;
            }
        }

        // Max attempts check
        if (maxAttempts > 0)
        {
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(*) FROM dbo.QuizResults WHERE UserID=@uid AND QuizID=@qid", conn))
            {
                cmd.Parameters.AddWithValue("@uid", uid);
                cmd.Parameters.AddWithValue("@qid", _quizId);
                int attempts = (int)cmd.ExecuteScalar();
                if (attempts >= maxAttempts)
                {
                    object bestObj;
                    using (SqlCommand bc = new SqlCommand(
                        "SELECT MAX(Percentage) FROM dbo.QuizResults WHERE UserID=@uid AND QuizID=@qid", conn))
                    {
                        bc.Parameters.AddWithValue("@uid", uid);
                        bc.Parameters.AddWithValue("@qid", _quizId);
                        bestObj = bc.ExecuteScalar();
                    }
                    string best = bestObj != DBNull.Value && bestObj != null
                        ? Convert.ToInt32(bestObj) + "%" : "N/A";
                    pnlQuiz.Visible  = false;
                    pnlAlert.Visible = true;
                    lblAlert.Text    = string.Format(
                        "&gt; Maximum attempts reached ({0}/{0}). Your best score: {1}",
                        maxAttempts, best);
                    return;
                }
            }
        }
    }

    // Load questions
    string orderBy = randomize ? "NEWID()" : "QuestionID";
    var dt = new System.Data.DataTable();
    using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
    using (SqlCommand cmd = new SqlCommand(string.Format(@"
        SELECT QuestionID, QuestionText, QuestionType,
               OptionA, OptionB, OptionC, OptionD, CorrectOption, Difficulty
        FROM   dbo.QuizQuestions
        WHERE  QuizID = @qid
        ORDER  BY {0}", orderBy), conn))
    {
        cmd.Parameters.AddWithValue("@qid", _quizId);
        conn.Open();
        using (var da = new System.Data.SqlClient.SqlDataAdapter(cmd))
            da.Fill(dt);
    }

    if (dt.Rows.Count == 0)
    {
        pnlQuiz.Visible  = false;
        pnlAlert.Visible = true;
        lblAlert.Text    = "&gt; No questions available for this quiz yet.";
        return;
    }

    var correctAnswers = new Dictionary<int, string>();
    var questionTypes  = new Dictionary<int, string>();
    var difficulties   = new Dictionary<int, string>();

    foreach (System.Data.DataRow row in dt.Rows)
    {
        int    qid    = (int)row["QuestionID"];
        string qType  = row["QuestionType"] as string ?? "MultipleChoice";
        string correct = row["CorrectOption"] as string ?? "A";
        string diff    = row["Difficulty"]   as string ?? "Medium";

        questionTypes[qid]  = qType;
        difficulties[qid]   = diff;
        correctAnswers[qid] = qType == "FillBlank" ? (row["OptionA"] as string ?? "") : correct;
    }

    ViewState["CorrectAnswers"] = correctAnswers;
    ViewState["QuestionTypes"]  = questionTypes;
    ViewState["Difficulties"]   = difficulties;
    ViewState["CourseID"]       = _courseId;

    // Timer
    if (timeLimitMinutes > 0)
    {
        Session["QuizStartTime_" + _quizId]  = DateTime.Now;
        Session["QuizTimeLimit_"  + _quizId] = timeLimitMinutes;
        ViewState["TimeLimitMinutes"] = timeLimitMinutes;
    }

    dt.Columns.Remove("CorrectOption");
    dt.Columns.Remove("Difficulty");

    rptQuestions.DataSource = dt;
    rptQuestions.DataBind();

    int count = dt.Rows.Count;
    lblProgress.Text = string.Format("{0} question{1}", count, count == 1 ? "" : "s");
}
```

- [ ] **Step 2: Add timer validation to `btnSubmit_Click`**

At the top of `btnSubmit_Click`, after the null-checks, add:

```csharp
// Timer validation
int timeLimitMinutes = ViewState["TimeLimitMinutes"] != null ? (int)ViewState["TimeLimitMinutes"] : 0;
if (timeLimitMinutes > 0)
{
    var startKey = "QuizStartTime_" + quizId;
    if (Session[startKey] is DateTime startTime)
    {
        double elapsed = (DateTime.Now - startTime).TotalSeconds;
        double allowed = timeLimitMinutes * 60 + 30; // 30s grace
        if (elapsed > allowed)
        {
            int resultId = SaveResult(uid, quizId, 0, correctAnswers.Count, 0, false);
            Session.Remove(startKey);
            Response.Redirect("~/QuizResult.aspx?attemptId=" + resultId + "&expired=1");
            return;
        }
    }
    Session.Remove("QuizStartTime_" + quizId);
}
```

- [ ] **Step 3: Add timer countdown UI to `Quiz.aspx`**

In `Quiz.aspx`, add inside `<asp:Content ID="HeadContent">` style block, after the existing `.quiz-alert` style:

```css
.quiz-timer-wrap {
    display: flex; align-items: center; gap: 12px;
    background: rgba(250,199,117,0.06); border: 1px solid rgba(250,199,117,0.25);
    border-radius: 8px; padding: 10px 16px; margin-bottom: 20px;
}
.quiz-timer-icon { color: var(--cyber-amber); font-size: 18px; }
.quiz-timer-label {
    font-family: 'Share Tech Mono', monospace; font-size: 11px;
    color: var(--cyber-muted); letter-spacing: 1px;
}
.quiz-timer-display {
    font-family: 'Share Tech Mono', monospace; font-size: 20px;
    font-weight: 700; color: var(--cyber-amber); letter-spacing: 2px;
    margin-left: auto;
}
.quiz-timer-display.danger { color: var(--cyber-danger); animation: blink 1s step-end infinite; }
@keyframes blink { 50% { opacity: 0.4; } }
.timer-bar-wrap { background: var(--cyber-border); border-radius: 2px; height: 3px; margin-top: 6px; }
.timer-bar { height: 3px; border-radius: 2px; background: var(--cyber-amber); transition: width 1s linear; }
```

Add timer panel in `Quiz.aspx` markup just before `<asp:Panel ID="pnlQuiz">`:

```aspx
<div id="timerPanel" style="display:none;">
    <div class="quiz-timer-wrap">
        <i class="ti ti-clock quiz-timer-icon"></i>
        <span class="quiz-timer-label">TIME REMAINING</span>
        <span id="timerDisplay" class="quiz-timer-display">--:--</span>
    </div>
    <div class="timer-bar-wrap"><div id="timerBar" class="timer-bar" style="width:100%"></div></div>
</div>
```

Add at the end of the `<script>` block in `Quiz.aspx` (after `confirmSubmit`):

```javascript
(function() {
    var limitSeconds = parseInt('<%= ViewState["TimeLimitMinutes"] ?? 0 %>') * 60;
    if (!limitSeconds) return;
    document.getElementById('timerPanel').style.display = 'block';
    var remaining = limitSeconds;
    var display   = document.getElementById('timerDisplay');
    var bar       = document.getElementById('timerBar');
    var submitBtn = document.getElementById('<%= btnSubmit.ClientID %>');
    function tick() {
        if (remaining <= 0) {
            display.textContent = '00:00';
            submitBtn.click();
            return;
        }
        var m = Math.floor(remaining / 60);
        var s = remaining % 60;
        display.textContent = (m < 10 ? '0' : '') + m + ':' + (s < 10 ? '0' : '') + s;
        bar.style.width = (remaining / limitSeconds * 100) + '%';
        if (remaining <= 60) display.classList.add('danger');
        remaining--;
        setTimeout(tick, 1000);
    }
    tick();
})();
```

- [ ] **Step 4: Add "Time expired" banner to `QuizResult.aspx`**

In `QuizResult.aspx.cs` `LoadResult`, after setting `hlBack.NavigateUrl`, add:

```csharp
if (Request.QueryString["expired"] == "1")
{
    pnlScore.Controls.AddAt(0, new System.Web.UI.LiteralControl(
        "<div style=\"background:rgba(255,59,92,0.1);border:1px solid rgba(255,59,92,0.3);color:var(--cyber-danger);font-family:'Share Tech Mono',monospace;font-size:12px;padding:10px 16px;border-radius:6px;margin-bottom:16px;\">&gt; Time expired — quiz auto-submitted.</div>"));
}
```

- [ ] **Step 5: Verify**

Run app. Edit a quiz, set Time Limit = 1 minute, Max Attempts = 1. Take the quiz:
1. Timer countdown appears and counts down
2. At expiry, form auto-submits, result shows "Time expired" banner, score = 0
3. Try to take quiz again → "Maximum attempts reached" panel appears

- [ ] **Step 6: Commit**

```bash
git add CyberLearnHub/Quiz.aspx CyberLearnHub/Quiz.aspx.cs CyberLearnHub/QuizResult.aspx CyberLearnHub/QuizResult.aspx.cs
git commit -m "feat: add timer countdown, max attempts gate, randomize question order"
```

---

## Task 4: Question Enhancements — Difficulty, Topic, Explanation

**Files:**
- Modify: `CyberLearnHub/Admin/QuestionForm.aspx`
- Modify: `CyberLearnHub/Admin/QuestionForm.aspx.cs`
- Modify: `CyberLearnHub/Admin/QuestionForm.aspx.designer.cs`
- Modify: `CyberLearnHub/Admin/ManageQuestions.aspx`
- Modify: `CyberLearnHub/Admin/ManageQuestions.aspx.cs`

- [ ] **Step 1: Add fields to `QuestionForm.aspx`**

After the closing `</div>` of the question type selector `form-group` (after `</div>` for `.qtype-selector`) and before `<!-- Question Text -->`, add:

```aspx
        <!-- Difficulty -->
        <asp:HiddenField ID="hdnDifficulty" runat="server" Value="Medium" />
        <div class="form-group">
            <label class="form-label">Difficulty</label>
            <div class="qtype-selector">
                <button type="button" class="qtype-btn" id="btnDiffEasy" onclick="setDiff('Easy')">
                    <i class="ti ti-plant"></i>
                    <span class="qtype-label">Easy</span>
                    <span class="qtype-desc">+10 XP correct</span>
                </button>
                <button type="button" class="qtype-btn active" id="btnDiffMedium" onclick="setDiff('Medium')">
                    <i class="ti ti-flame"></i>
                    <span class="qtype-label">Medium</span>
                    <span class="qtype-desc">+20 XP correct</span>
                </button>
                <button type="button" class="qtype-btn" id="btnDiffHard" onclick="setDiff('Hard')">
                    <i class="ti ti-skull"></i>
                    <span class="qtype-label">Hard</span>
                    <span class="qtype-desc">+30 XP correct</span>
                </button>
            </div>
        </div>

        <!-- Topic -->
        <div class="form-group">
            <label class="form-label">Topic <span style="color:var(--cyber-muted);font-weight:400;">(optional)</span></label>
            <asp:TextBox ID="txtTopic" runat="server" CssClass="form-control" MaxLength="100"
                placeholder="e.g. Network Security" list="topicSuggestions" />
            <datalist id="topicSuggestions">
                <%-- populated server-side --%>
                <asp:Literal ID="litTopics" runat="server" />
            </datalist>
        </div>
```

After the FillBlank section closing `</div>`, before the button row, add:

```aspx
        <!-- Explanation -->
        <div class="form-group" style="margin-top:8px;">
            <label class="form-label">Answer Explanation <span style="color:var(--cyber-muted);font-weight:400;">(optional)</span></label>
            <asp:TextBox ID="txtExplanation" runat="server" CssClass="form-control"
                TextMode="MultiLine" Rows="3" MaxLength="1000"
                placeholder="Explain why this answer is correct — shown to students after the quiz" />
            <span class="form-hint">&gt; Students see this in the answer review</span>
        </div>
```

At the end of the `<script>` block, add:

```javascript
function setDiff(diff) {
    document.getElementById('<%= hdnDifficulty.ClientID %>').value = diff;
    var map = { 'Easy': 'btnDiffEasy', 'Medium': 'btnDiffMedium', 'Hard': 'btnDiffHard' };
    document.querySelectorAll('#btnDiffEasy,#btnDiffMedium,#btnDiffHard')
            .forEach(function(b) { b.classList.remove('active'); });
    document.getElementById(map[diff]).classList.add('active');
}
window.addEventListener('DOMContentLoaded', function() {
    setDiff('<%= hdnDifficulty.Value %>');
});
```

- [ ] **Step 2: Update `QuestionForm.aspx.designer.cs`**

Add to the existing declarations:

```csharp
        protected global::System.Web.UI.WebControls.HiddenField hdnDifficulty;
        protected global::System.Web.UI.WebControls.TextBox txtTopic;
        protected global::System.Web.UI.WebControls.Literal litTopics;
        protected global::System.Web.UI.WebControls.TextBox txtExplanation;
```

- [ ] **Step 3: Update `QuestionForm.aspx.cs`**

In `LoadQuestion`, after setting `hdnQuestionType.Value`, add:

```csharp
hdnDifficulty.Value  = r["Difficulty"] as string ?? "Medium";
txtTopic.Text        = r["Topic"] as string ?? "";
txtExplanation.Text  = r["Explanation"] as string ?? "";
```

In `Page_Load`, after setting `hlBack.NavigateUrl`, populate topic suggestions:

```csharp
// Populate topic datalist
var sb = new System.Text.StringBuilder();
using (SqlConnection conn2 = new SqlConnection(DbHelper.ConnectionString))
using (SqlCommand cmd2 = new SqlCommand(
    "SELECT DISTINCT Topic FROM dbo.QuizQuestions WHERE QuizID=@qid AND Topic IS NOT NULL ORDER BY Topic", conn2))
{
    cmd2.Parameters.AddWithValue("@qid", _quizId);
    conn2.Open();
    using (SqlDataReader r2 = cmd2.ExecuteReader())
        while (r2.Read())
            sb.AppendFormat("<option value=\"{0}\">", Server.HtmlEncode(r2.GetString(0)));
}
litTopics.Text = sb.ToString();
```

In `btnSave_Click`, add reading of new fields:

```csharp
string difficulty  = hdnDifficulty.Value;
if (difficulty != "Easy" && difficulty != "Medium" && difficulty != "Hard") difficulty = "Medium";
string topic       = txtTopic.Text.Trim();
string explanation = txtExplanation.Text.Trim();
```

Update the INSERT SQL to include new columns:

```csharp
// Replace existing INSERT with:
"INSERT INTO dbo.QuizQuestions (QuizID,QuestionText,QuestionType,OptionA,OptionB,OptionC,OptionD,CorrectOption,Difficulty,Topic,Explanation) VALUES (@qid,@q,@qt,@a,@b,@c,@d,@ans,@diff,@topic,@expl)"
```

Update the UPDATE SQL:

```csharp
// Replace existing UPDATE with:
"UPDATE dbo.QuizQuestions SET QuestionText=@q,QuestionType=@qt,OptionA=@a,OptionB=@b,OptionC=@c,OptionD=@d,CorrectOption=@ans,Difficulty=@diff,Topic=@topic,Explanation=@expl WHERE QuestionID=@id"
```

Add params in `AddParams` (add three new parameters after `@ans`):

```csharp
cmd.Parameters.AddWithValue("@diff",  difficulty);
cmd.Parameters.AddWithValue("@topic", string.IsNullOrEmpty(topic) ? (object)DBNull.Value : topic);
cmd.Parameters.AddWithValue("@expl",  string.IsNullOrEmpty(explanation) ? (object)DBNull.Value : explanation);
```

Note: update `AddParams` signature to accept `difficulty`, `topic`, `explanation` and pass them through from `btnSave_Click`.

- [ ] **Step 4: Add Difficulty + Topic columns to `ManageQuestions.aspx`**

In `ManageQuestions.aspx`, add two columns to the question list table header and the Repeater ItemTemplate. In the header row add after the Type `<th>`:

```aspx
<th>Difficulty</th>
<th>Topic</th>
```

In the ItemTemplate add after the type badge `<td>`:

```aspx
<td><%# GetDiffBadge(Eval("Difficulty") as string) %></td>
<td style="font-family:'Share Tech Mono',monospace;font-size:10px;color:var(--cyber-muted);">
    <%# Server.HtmlEncode(Eval("Topic") as string ?? "") %>
</td>
```

- [ ] **Step 5: Add helpers in `ManageQuestions.aspx.cs`**

Add the `Difficulty` and `Topic` columns to the SELECT in `LoadQuestions`:

```csharp
// Add Difficulty, Topic to the SELECT
"SELECT QuestionID, QuizID, QuestionText, QuestionType, OptionA, CorrectOption, Difficulty, Topic FROM dbo.QuizQuestions WHERE QuizID=@qid ORDER BY QuestionID"
```

Add helper method:

```csharp
protected string GetDiffBadge(string diff)
{
    switch (diff)
    {
        case "Easy": return "<span class=\"badge\" style=\"background:rgba(0,255,157,0.1);color:var(--cyber-accent2);border:1px solid rgba(0,255,157,0.25);\">EASY</span>";
        case "Hard": return "<span class=\"badge\" style=\"background:rgba(255,59,92,0.1);color:var(--cyber-danger);border:1px solid rgba(255,59,92,0.25);\">HARD</span>";
        default:     return "<span class=\"badge\" style=\"background:rgba(250,199,117,0.1);color:var(--cyber-amber);border:1px solid rgba(250,199,117,0.25);\">MED</span>";
    }
}
```

- [ ] **Step 6: Verify**

Run app → Admin → add a question → difficulty selector shows Easy/Medium/Hard buttons → topic text box with datalist → explanation textarea → save → ManageQuestions list shows Difficulty and Topic columns.

- [ ] **Step 7: Commit**

```bash
git add CyberLearnHub/Admin/QuestionForm.aspx CyberLearnHub/Admin/QuestionForm.aspx.cs CyberLearnHub/Admin/QuestionForm.aspx.designer.cs CyberLearnHub/Admin/ManageQuestions.aspx CyberLearnHub/Admin/ManageQuestions.aspx.cs
git commit -m "feat: add difficulty, topic, explanation to question admin form"
```

---

## Task 5: Per-Question Answer Tracking + Full Review Page

**Files:**
- Modify: `CyberLearnHub/Quiz.aspx.cs`
- Modify: `CyberLearnHub/QuizResult.aspx`
- Modify: `CyberLearnHub/QuizResult.aspx.cs`
- Modify: `CyberLearnHub/QuizResult.aspx.designer.cs`

- [ ] **Step 1: Save `QuizAnswers` rows in `btnSubmit_Click`**

In `Quiz.aspx.cs`, replace `SaveResult` call and redirect with:

```csharp
int resultId = SaveResult(uid, quizId, correct, total, percentage, passed);
SaveAnswers(resultId, correctAnswers, questionTypes);
Session.Remove("QuizStartTime_" + quizId);
Response.Redirect("~/QuizResult.aspx?attemptId=" + resultId);
```

Add new method:

```csharp
private void SaveAnswers(int resultId, Dictionary<int, string> correctAnswers, Dictionary<int, string> questionTypes)
{
    using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
    {
        conn.Open();
        foreach (var kvp in correctAnswers)
        {
            int    qid    = kvp.Key;
            string answer = kvp.Value;
            string qType  = questionTypes != null && questionTypes.ContainsKey(qid)
                            ? questionTypes[qid] : "MultipleChoice";
            string submitted = qType == "FillBlank"
                ? (Request.Form["fb_" + qid] ?? "")
                : (Request.Form["q_"  + qid] ?? "");
            bool isCorrect = qType == "FillBlank"
                ? string.Equals(submitted.Trim(), answer.Trim(), StringComparison.OrdinalIgnoreCase)
                : string.Equals(submitted, answer, StringComparison.OrdinalIgnoreCase);

            using (SqlCommand cmd = new SqlCommand(@"
                INSERT INTO dbo.QuizAnswers (ResultID, QuestionID, SubmittedAnswer, IsCorrect)
                VALUES (@rid, @qid, @ans, @ok)", conn))
            {
                cmd.Parameters.AddWithValue("@rid", resultId);
                cmd.Parameters.AddWithValue("@qid", qid);
                cmd.Parameters.AddWithValue("@ans", submitted);
                cmd.Parameters.AddWithValue("@ok",  isCorrect);
                cmd.ExecuteNonQuery();
            }
        }
    }
}
```

- [ ] **Step 2: Update `ReviewItem` class in `QuizResult.aspx.cs`**

Replace the `ReviewItem` class and `LoadReview` method:

```csharp
private void LoadReview(int quizId, int resultId)
{
    var items = new List<ReviewItem>();

    using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
    using (SqlCommand cmd = new SqlCommand(@"
        SELECT qq.QuestionID, qq.QuestionText, qq.QuestionType,
               qq.OptionA, qq.OptionB, qq.OptionC, qq.OptionD,
               qq.CorrectOption, qq.Explanation,
               qa.SubmittedAnswer, qa.IsCorrect
        FROM   dbo.QuizQuestions qq
        LEFT JOIN dbo.QuizAnswers qa
               ON qa.QuestionID = qq.QuestionID AND qa.ResultID = @rid
        WHERE  qq.QuizID = @qid
        ORDER  BY qq.QuestionID", conn))
    {
        cmd.Parameters.AddWithValue("@qid", quizId);
        cmd.Parameters.AddWithValue("@rid", resultId);
        conn.Open();
        using (SqlDataReader r = cmd.ExecuteReader())
        {
            while (r.Read())
            {
                string qType   = r["QuestionType"] as string ?? "MultipleChoice";
                string correct = r["CorrectOption"].ToString();

                string correctText;
                if (qType == "FillBlank")       correctText = r["OptionA"].ToString();
                else if (qType == "TrueFalse")  correctText = correct == "A" ? "True" : "False";
                else correctText = correct == "A" ? r["OptionA"].ToString()
                                 : correct == "B" ? r["OptionB"].ToString()
                                 : correct == "C" ? r["OptionC"].ToString()
                                 :                  r["OptionD"].ToString();

                string submitted = r["SubmittedAnswer"] as string ?? "";
                string submittedDisplay = submitted;
                if (qType == "TrueFalse")
                    submittedDisplay = submitted == "A" ? "True" : submitted == "B" ? "False" : "Not answered";
                else if (qType == "MultipleChoice" && submitted.Length == 1)
                {
                    string optCol = submitted == "A" ? "OptionA" : submitted == "B" ? "OptionB"
                                  : submitted == "C" ? "OptionC" : submitted == "D" ? "OptionD" : null;
                    if (optCol != null) submittedDisplay = r[optCol].ToString();
                }
                if (string.IsNullOrEmpty(submitted)) submittedDisplay = "Not answered";

                items.Add(new ReviewItem
                {
                    QuestionText     = r["QuestionText"].ToString(),
                    QuestionType     = qType,
                    CorrectOption    = correct,
                    CorrectText      = correctText,
                    YourAnswer       = submittedDisplay,
                    IsCorrect        = r["IsCorrect"] != DBNull.Value && (bool)r["IsCorrect"],
                    Explanation      = r["Explanation"] as string ?? ""
                });
            }
        }
    }

    rptReview.DataSource = items;
    rptReview.DataBind();
}

private class ReviewItem
{
    public string QuestionText  { get; set; }
    public string QuestionType  { get; set; }
    public string CorrectOption { get; set; }
    public string CorrectText   { get; set; }
    public string YourAnswer    { get; set; }
    public bool   IsCorrect     { get; set; }
    public string Explanation   { get; set; }
}
```

Update `LoadResult` to pass `resultId` to `LoadReview`:

```csharp
LoadReview(quizId, resultId);
```

- [ ] **Step 3: Update `QuizResult.aspx` review Repeater**

Replace the `rptReview` ItemTemplate with:

```aspx
<asp:Repeater ID="rptReview" runat="server">
    <ItemTemplate>
        <div class="review-item <%# (bool)Eval("IsCorrect") ? "correct" : "wrong" %>">
            <div class="review-q-num">
                Q<%# Container.ItemIndex + 1 %> &mdash;
                <%# (bool)Eval("IsCorrect") ? "CORRECT" : "INCORRECT" %>
            </div>
            <div class="review-q-text"><%# Server.HtmlEncode(Eval("QuestionText") as string) %></div>
            <div class="review-answer <%# (bool)Eval("IsCorrect") ? "your-correct" : "your-wrong" %>">
                Your answer: <%# Server.HtmlEncode(Eval("YourAnswer") as string ?? "Not answered") %>
            </div>
            <%# !(bool)Eval("IsCorrect")
                ? "<div class=\"review-answer correct-ans\">Correct answer: " + Server.HtmlEncode(Eval("CorrectText") as string ?? "") + "</div>"
                : "" %>
            <%# !string.IsNullOrEmpty(Eval("Explanation") as string)
                ? "<div class=\"review-explanation\">&gt; " + Server.HtmlEncode(Eval("Explanation") as string) + "</div>"
                : "" %>
        </div>
    </ItemTemplate>
</asp:Repeater>
```

Add CSS for explanation block in `QuizResult.aspx` `<style>`:

```css
.review-explanation {
    margin-top: 8px; padding: 8px 12px;
    background: rgba(250,199,117,0.06);
    border-left: 3px solid var(--cyber-amber);
    font-size: 12px; color: var(--cyber-amber);
    font-family: 'Share Tech Mono', monospace;
    letter-spacing: 0.5px; line-height: 1.6;
}
```

- [ ] **Step 4: Verify**

Take a quiz, submit. On result page:
- Each question shows ✅ CORRECT or ❌ INCORRECT
- "Your answer" shows the text of the selected option (not just "A")
- Wrong questions show "Correct answer"
- Questions with explanation text show the amber explanation block

- [ ] **Step 5: Commit**

```bash
git add CyberLearnHub/Quiz.aspx.cs CyberLearnHub/QuizResult.aspx CyberLearnHub/QuizResult.aspx.cs
git commit -m "feat: save per-question answers, restore full review with explanations"
```

---

## Task 6: XP and Streaks

**Files:**
- Modify: `CyberLearnHub/Quiz.aspx.cs`
- Modify: `CyberLearnHub/Dashboard.aspx`
- Modify: `CyberLearnHub/Dashboard.aspx.cs`
- Modify: `CyberLearnHub/Dashboard.aspx.designer.cs`

- [ ] **Step 1: Add XP + streak update in `Quiz.aspx.cs`**

After `SaveAnswers(...)`, add:

```csharp
AwardXP(uid, quizId, correctAnswers, questionTypes, passed);
if (passed) UpdateStreak(uid);
```

Add methods:

```csharp
private void AwardXP(int uid, int quizId, Dictionary<int, string> correctAnswers,
                     Dictionary<int, string> questionTypes, bool passed)
{
    // Load difficulties for answered questions
    var diffMap = new Dictionary<int, string>();
    var difficulties = ViewState["Difficulties"] as Dictionary<int, string>;
    if (difficulties != null) diffMap = difficulties;

    int xpEarned = 0;
    foreach (var kvp in correctAnswers)
    {
        int    qid   = kvp.Key;
        string qType = questionTypes != null && questionTypes.ContainsKey(qid)
                       ? questionTypes[qid] : "MultipleChoice";
        string submitted = qType == "FillBlank"
            ? (Request.Form["fb_" + qid] ?? "")
            : (Request.Form["q_"  + qid] ?? "");
        bool isCorrect = qType == "FillBlank"
            ? string.Equals(submitted.Trim(), kvp.Value.Trim(), StringComparison.OrdinalIgnoreCase)
            : string.Equals(submitted, kvp.Value, StringComparison.OrdinalIgnoreCase);

        if (isCorrect)
        {
            string diff = diffMap.ContainsKey(qid) ? diffMap[qid] : "Medium";
            xpEarned += diff == "Easy" ? 10 : diff == "Hard" ? 30 : 20;
        }
    }
    if (passed) xpEarned += 50;
    if (xpEarned == 0) return;

    using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
    using (SqlCommand cmd = new SqlCommand(@"
        MERGE dbo.UserXP AS target
        USING (SELECT @uid AS UserID) AS source ON target.UserID = source.UserID
        WHEN MATCHED THEN
            UPDATE SET TotalXP = target.TotalXP + @xp,
                       Level   = (target.TotalXP + @xp) / 500 + 1,
                       UpdatedAt = GETDATE()
        WHEN NOT MATCHED THEN
            INSERT (UserID, TotalXP, Level, UpdatedAt)
            VALUES (@uid, @xp, @xp / 500 + 1, GETDATE());", conn))
    {
        cmd.Parameters.AddWithValue("@uid", uid);
        cmd.Parameters.AddWithValue("@xp",  xpEarned);
        conn.Open();
        cmd.ExecuteNonQuery();
    }
}

private static void UpdateStreak(int uid)
{
    using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
    {
        conn.Open();
        using (SqlCommand cmd = new SqlCommand(@"
            MERGE dbo.UserStreaks AS target
            USING (SELECT @uid AS UserID) AS source ON target.UserID = source.UserID
            WHEN MATCHED THEN UPDATE SET
                CurrentStreak = CASE
                    WHEN target.LastPassDate = CAST(GETDATE() AS DATE) THEN target.CurrentStreak
                    WHEN target.LastPassDate = CAST(DATEADD(day,-1,GETDATE()) AS DATE) THEN target.CurrentStreak + 1
                    ELSE 1 END,
                LongestStreak = CASE
                    WHEN target.LastPassDate = CAST(GETDATE() AS DATE) THEN target.LongestStreak
                    WHEN target.LastPassDate = CAST(DATEADD(day,-1,GETDATE()) AS DATE)
                        THEN CASE WHEN target.CurrentStreak + 1 > target.LongestStreak
                                  THEN target.CurrentStreak + 1 ELSE target.LongestStreak END
                    ELSE CASE WHEN 1 > target.LongestStreak THEN 1 ELSE target.LongestStreak END END,
                LastPassDate = CAST(GETDATE() AS DATE)
            WHEN NOT MATCHED THEN
                INSERT (UserID, CurrentStreak, LongestStreak, LastPassDate)
                VALUES (@uid, 1, 1, CAST(GETDATE() AS DATE));", conn))
        {
            cmd.Parameters.AddWithValue("@uid", uid);
            cmd.ExecuteNonQuery();
        }
    }
}
```

- [ ] **Step 2: Add XP and streak display to `Dashboard.aspx.cs`**

In `LoadDashboard`, after `LoadStats`, add call:

```csharp
LoadXPStreak(uid);
```

Add method:

```csharp
private void LoadXPStreak(int uid)
{
    using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
    using (SqlCommand cmd = new SqlCommand(@"
        SELECT x.TotalXP, x.Level,
               ISNULL(s.CurrentStreak, 0),
               CASE WHEN s.LastPassDate IS NULL THEN 0
                    WHEN s.LastPassDate >= CAST(DATEADD(day,-1,GETDATE()) AS DATE) THEN ISNULL(s.CurrentStreak,0)
                    ELSE 0 END AS DisplayStreak
        FROM   (SELECT @uid AS UserID) base
        LEFT JOIN dbo.UserXP      x ON x.UserID = @uid
        LEFT JOIN dbo.UserStreaks  s ON s.UserID = @uid", conn))
    {
        cmd.Parameters.AddWithValue("@uid", uid);
        conn.Open();
        using (SqlDataReader r = cmd.ExecuteReader())
        {
            if (r.Read())
            {
                int xp      = r.IsDBNull(0) ? 0 : r.GetInt32(0);
                int level   = r.IsDBNull(1) ? 1 : r.GetInt32(1);
                int streak  = r.IsDBNull(3) ? 0 : r.GetInt32(3);
                lblXP.Text     = xp + " XP";
                lblLevel.Text  = "LVL " + level;
                lblStreak.Text = streak > 0 ? streak + "-day streak" : "No active streak";
            }
        }
    }
}
```

- [ ] **Step 3: Add XP/streak labels to `Dashboard.aspx`**

Add a new stats row below the existing stats grid:

```aspx
<div class="stats-grid" style="margin-bottom:28px;">
    <div class="stat-card">
        <div class="stat-icon" style="background:rgba(250,199,117,0.1);color:var(--cyber-amber);">
            <i class="ti ti-star"></i>
        </div>
        <div>
            <div class="stat-value"><asp:Label ID="lblXP" runat="server" Text="0 XP" /></div>
            <div class="stat-label">Total XP</div>
        </div>
    </div>
    <div class="stat-card">
        <div class="stat-icon" style="background:rgba(0,212,255,0.1);color:var(--cyber-accent);">
            <i class="ti ti-shield-star"></i>
        </div>
        <div>
            <div class="stat-value"><asp:Label ID="lblLevel" runat="server" Text="LVL 1" /></div>
            <div class="stat-label">Level</div>
        </div>
    </div>
    <div class="stat-card">
        <div class="stat-icon" style="background:rgba(255,59,92,0.1);color:var(--cyber-danger);">
            <i class="ti ti-flame"></i>
        </div>
        <div>
            <div class="stat-value"><asp:Label ID="lblStreak" runat="server" Text="No streak" /></div>
            <div class="stat-label">Pass Streak</div>
        </div>
    </div>
</div>
```

- [ ] **Step 4: Add to `Dashboard.aspx.designer.cs`**

```csharp
protected global::System.Web.UI.WebControls.Label lblXP;
protected global::System.Web.UI.WebControls.Label lblLevel;
protected global::System.Web.UI.WebControls.Label lblStreak;
```

- [ ] **Step 5: Verify**

Pass a quiz. Dashboard shows XP earned and LVL badge. Pass another quiz the next day → streak increments. After 2+ days gap → streak resets to 0.

- [ ] **Step 6: Commit**

```bash
git add CyberLearnHub/Quiz.aspx.cs CyberLearnHub/Dashboard.aspx CyberLearnHub/Dashboard.aspx.cs CyberLearnHub/Dashboard.aspx.designer.cs
git commit -m "feat: award XP per correct answer by difficulty, track pass streaks"
```

---

## Task 7: Leaderboards

**Files:**
- Create: `CyberLearnHub/Leaderboard.aspx` + `.cs` + `.designer.cs`
- Modify: `CyberLearnHub/QuizResult.aspx` + `.cs` + `.designer.cs`
- Modify: `CyberLearnHub/Site.Master`
- Modify: `CyberLearnHub/CyberLearnHub.csproj`

- [ ] **Step 1: Create `Leaderboard.aspx`**

```aspx
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Leaderboard.aspx.cs"
         Inherits="CyberLearnHub.Leaderboard" MasterPageFile="~/Site.Master" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <title>Leaderboard — CyberLearn Hub</title>
    <style>
        .lb-wrap { max-width: 860px; margin: 0 auto; padding: 40px 24px 60px; }
        .lb-header { margin-bottom: 28px; }
        .lb-tag { font-family:'Share Tech Mono',monospace; font-size:11px; color:var(--cyber-accent); letter-spacing:3px; margin-bottom:6px; }
        .lb-title { font-family:'Rajdhani',sans-serif; font-size:32px; font-weight:700; color:var(--cyber-heading); }
        .lb-table { width:100%; border-collapse:collapse; }
        .lb-table th { font-family:'Share Tech Mono',monospace; font-size:10px; color:var(--cyber-muted); letter-spacing:1.5px; text-transform:uppercase; padding:0 16px 10px; text-align:left; border-bottom:1px solid var(--cyber-border); }
        .lb-table td { padding:12px 16px; font-size:13px; color:var(--cyber-text); border-bottom:1px solid rgba(26,48,80,0.5); }
        .lb-table tr:hover td { background:rgba(0,212,255,0.03); }
        .lb-table tr.me td { background:rgba(0,212,255,0.06); }
        .rank-1 td:first-child { color:#ffd700; font-weight:700; }
        .rank-2 td:first-child { color:#c0c0c0; font-weight:700; }
        .rank-3 td:first-child { color:#cd7f32; font-weight:700; }
        .level-badge { font-family:'Share Tech Mono',monospace; font-size:9px; padding:2px 8px; border-radius:20px; background:rgba(0,212,255,0.1); color:var(--cyber-accent); border:1px solid rgba(0,212,255,0.2); }
        .xp-val { font-family:'Rajdhani',sans-serif; font-size:15px; font-weight:700; color:var(--cyber-amber); }
        .streak-val { color:var(--cyber-danger); font-family:'Share Tech Mono',monospace; font-size:11px; }
        .lb-divider { border:none; border-top:1px dashed var(--cyber-border); margin:4px 0; }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="lb-wrap">
        <div class="lb-header">
            <div class="lb-tag">// global</div>
            <div class="lb-title">XP Leaderboard</div>
        </div>
        <table class="lb-table">
            <thead>
                <tr><th>#</th><th>Student</th><th>Level</th><th>XP</th><th>Streak</th></tr>
            </thead>
            <tbody>
                <asp:Literal ID="litRows" runat="server" />
            </tbody>
        </table>
    </div>
</asp:Content>
```

- [ ] **Step 2: Create `Leaderboard.aspx.cs`**

```csharp
using System;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;

namespace CyberLearnHub
{
    public partial class Leaderboard : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) LoadLeaderboard();
        }

        private void LoadLeaderboard()
        {
            int currentUid = Session["UserID"] != null ? (int)Session["UserID"] : -1;
            var sb = new StringBuilder();

            using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT TOP 20
                    ROW_NUMBER() OVER (ORDER BY x.TotalXP DESC) AS Rank,
                    u.UserID, u.FullName, x.TotalXP, x.Level,
                    CASE WHEN s.LastPassDate >= CAST(DATEADD(day,-1,GETDATE()) AS DATE)
                         THEN ISNULL(s.CurrentStreak,0) ELSE 0 END AS DisplayStreak
                FROM dbo.UserXP x
                JOIN dbo.Users u ON u.UserID = x.UserID
                LEFT JOIN dbo.UserStreaks s ON s.UserID = x.UserID
                WHERE u.IsActive = 1
                ORDER BY x.TotalXP DESC", conn))
            {
                conn.Open();
                bool currentShown = false;
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        int    uid    = r.GetInt32(1);
                        int    rank   = (int)r.GetInt64(0);
                        string name   = Server.HtmlEncode(r.GetString(2));
                        int    xp     = r.GetInt32(3);
                        int    level  = r.GetInt32(4);
                        int    streak = r.GetInt32(5);
                        bool   isMe   = uid == currentUid;
                        if (isMe) currentShown = true;

                        string rankClass = rank == 1 ? "rank-1" : rank == 2 ? "rank-2" : rank == 3 ? "rank-3" : "";
                        string meClass   = isMe ? " me" : "";
                        string streakStr = streak > 0 ? "&#128293; " + streak + " days" : "&#8212;";

                        sb.AppendFormat(
                            "<tr class=\"{0}{1}\"><td>{2}</td><td>{3}{4}</td>" +
                            "<td><span class=\"level-badge\">LVL {5}</span></td>" +
                            "<td><span class=\"xp-val\">{6}</span></td>" +
                            "<td class=\"streak-val\">{7}</td></tr>",
                            rankClass, meClass,
                            rank, name,
                            isMe ? " <span style=\"font-family:'Share Tech Mono',monospace;font-size:9px;color:var(--cyber-accent);\">YOU</span>" : "",
                            level, xp, streakStr);
                    }
                }

                // If current user not in top 20, append their row
                if (currentUid > 0 && !currentShown)
                {
                    using (SqlCommand cmd2 = new SqlCommand(@"
                        SELECT x.TotalXP, x.Level,
                               CASE WHEN s.LastPassDate >= CAST(DATEADD(day,-1,GETDATE()) AS DATE)
                                    THEN ISNULL(s.CurrentStreak,0) ELSE 0 END,
                               (SELECT COUNT(*)+1 FROM dbo.UserXP WHERE TotalXP > x.TotalXP) AS Rank
                        FROM dbo.UserXP x
                        LEFT JOIN dbo.UserStreaks s ON s.UserID = x.UserID
                        WHERE x.UserID = @uid", conn))
                    {
                        cmd2.Parameters.AddWithValue("@uid", currentUid);
                        using (SqlDataReader r2 = cmd2.ExecuteReader())
                        {
                            if (r2.Read())
                            {
                                string name = Server.HtmlEncode(Session["Username"] as string ?? "You");
                                sb.Append("<tr><td colspan=\"5\" style=\"padding:2px;\"><hr class=\"lb-divider\"></td></tr>");
                                sb.AppendFormat(
                                    "<tr class=\"me\"><td>{0}</td><td>{1} <span style=\"font-family:'Share Tech Mono',monospace;font-size:9px;color:var(--cyber-accent);\">YOU</span></td>" +
                                    "<td><span class=\"level-badge\">LVL {2}</span></td>" +
                                    "<td><span class=\"xp-val\">{3}</span></td><td class=\"streak-val\">{4}</td></tr>",
                                    r2.GetInt32(3), name, r2.GetInt32(1), r2.GetInt32(0),
                                    r2.GetInt32(2) > 0 ? "&#128293; " + r2.GetInt32(2) + " days" : "&#8212;");
                            }
                        }
                    }
                }
            }

            litRows.Text = sb.ToString();
        }
    }
}
```

- [ ] **Step 3: Create `Leaderboard.aspx.designer.cs`**

```csharp
namespace CyberLearnHub
{
    public partial class Leaderboard
    {
        protected global::System.Web.UI.WebControls.Literal litRows;
    }
}
```

- [ ] **Step 4: Add per-quiz leaderboard to `QuizResult.aspx`**

In `QuizResult.aspx`, add after the `result-actions` div:

```aspx
<asp:Panel ID="pnlLeaderboard" runat="server" Visible="false">
    <div class="review-title" style="margin-top:8px;">// Quiz Leaderboard — Top 5</div>
    <asp:Literal ID="litLeaderboard" runat="server" />
</asp:Panel>
```

- [ ] **Step 5: Add to `QuizResult.aspx.designer.cs`**

```csharp
protected global::System.Web.UI.WebControls.Panel pnlLeaderboard;
protected global::System.Web.UI.WebControls.Literal litLeaderboard;
```

- [ ] **Step 6: Load per-quiz leaderboard in `QuizResult.aspx.cs`**

Add method and call it from `LoadResult` (after `LoadReview`):

```csharp
LoadQuizLeaderboard(quizId, uid);
```

```csharp
private void LoadQuizLeaderboard(int quizId, int currentUid)
{
    var sb = new StringBuilder();
    sb.Append("<table style=\"width:100%;border-collapse:collapse;\">");
    sb.Append("<thead><tr>");
    sb.Append("<th style=\"font-family:'Share Tech Mono',monospace;font-size:10px;color:var(--cyber-muted);letter-spacing:1.5px;text-transform:uppercase;padding:0 12px 8px;text-align:left;border-bottom:1px solid var(--cyber-border);\">#</th>");
    sb.Append("<th style=\"font-family:'Share Tech Mono',monospace;font-size:10px;color:var(--cyber-muted);letter-spacing:1.5px;text-transform:uppercase;padding:0 12px 8px;text-align:left;border-bottom:1px solid var(--cyber-border);\">Student</th>");
    sb.Append("<th style=\"font-family:'Share Tech Mono',monospace;font-size:10px;color:var(--cyber-muted);letter-spacing:1.5px;text-transform:uppercase;padding:0 12px 8px;text-align:left;border-bottom:1px solid var(--cyber-border);\">Best Score</th>");
    sb.Append("<th style=\"font-family:'Share Tech Mono',monospace;font-size:10px;color:var(--cyber-muted);letter-spacing:1.5px;text-transform:uppercase;padding:0 12px 8px;text-align:left;border-bottom:1px solid var(--cyber-border);\">Attempts</th>");
    sb.Append("</tr></thead><tbody>");

    bool hasRows = false;
    using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
    using (SqlCommand cmd = new SqlCommand(@"
        SELECT TOP 5
            ROW_NUMBER() OVER (ORDER BY MAX(qr.Percentage) DESC) AS Rank,
            u.UserID, u.FullName,
            MAX(qr.Percentage) AS BestPct,
            COUNT(*) AS Attempts
        FROM dbo.QuizResults qr
        JOIN dbo.Users u ON u.UserID = qr.UserID
        WHERE qr.QuizID = @qid
        GROUP BY u.UserID, u.FullName
        ORDER BY BestPct DESC", conn))
    {
        cmd.Parameters.AddWithValue("@qid", quizId);
        conn.Open();
        using (SqlDataReader r = cmd.ExecuteReader())
        {
            while (r.Read())
            {
                hasRows = true;
                int    uid      = r.GetInt32(1);
                int    rank     = (int)r.GetInt64(0);
                string name     = Server.HtmlEncode(r.GetString(2));
                int    bestPct  = Convert.ToInt32(r["BestPct"]);
                int    attempts = r.GetInt32(4);
                bool   isMe     = uid == currentUid;
                string rowStyle = isMe ? "background:rgba(0,212,255,0.06);" : "";

                sb.AppendFormat(
                    "<tr style=\"{0}\"><td style=\"padding:10px 12px;font-size:13px;color:var(--cyber-text);border-bottom:1px solid rgba(26,48,80,0.4);\">{1}</td>" +
                    "<td style=\"padding:10px 12px;font-size:13px;color:var(--cyber-text);border-bottom:1px solid rgba(26,48,80,0.4);\">{2}{3}</td>" +
                    "<td style=\"padding:10px 12px;font-family:'Rajdhani',sans-serif;font-size:15px;font-weight:700;color:var(--cyber-accent2);border-bottom:1px solid rgba(26,48,80,0.4);\">{4}%</td>" +
                    "<td style=\"padding:10px 12px;font-size:13px;color:var(--cyber-muted);border-bottom:1px solid rgba(26,48,80,0.4);\">{5}</td></tr>",
                    rowStyle, rank, name,
                    isMe ? " <span style=\"font-family:'Share Tech Mono',monospace;font-size:9px;color:var(--cyber-accent);\">YOU</span>" : "",
                    bestPct, attempts);
            }
        }
    }

    sb.Append("</tbody></table>");

    if (hasRows)
    {
        litLeaderboard.Text  = sb.ToString();
        pnlLeaderboard.Visible = true;
    }
}
```

- [ ] **Step 7: Add Leaderboard link to `Site.Master`**

Find the nav `<ul>` that contains "MY COURSES" and "PROGRESS". Add after the PROGRESS `<li>`:

```aspx
<li><a href="~/Leaderboard.aspx" runat="server">Leaderboard</a></li>
```

- [ ] **Step 8: Register in `CyberLearnHub.csproj`**

In the `<Content>` group, add:
```xml
<Content Include="Leaderboard.aspx" />
```

In the `<Compile>` group, add:
```xml
<Compile Include="Leaderboard.aspx.cs">
  <DependentUpon>Leaderboard.aspx</DependentUpon>
  <SubType>ASPXCodeBehind</SubType>
</Compile>
<Compile Include="Leaderboard.aspx.designer.cs">
  <DependentUpon>Leaderboard.aspx</DependentUpon>
</Compile>
```

- [ ] **Step 9: Verify**

Take a quiz. QuizResult page shows Top 5 leaderboard with your row highlighted. Navigate to `/Leaderboard.aspx` → global XP table with level badges and streak.

- [ ] **Step 10: Commit**

```bash
git add CyberLearnHub/Leaderboard.aspx CyberLearnHub/Leaderboard.aspx.cs CyberLearnHub/Leaderboard.aspx.designer.cs CyberLearnHub/QuizResult.aspx CyberLearnHub/QuizResult.aspx.cs CyberLearnHub/QuizResult.aspx.designer.cs CyberLearnHub/Site.Master CyberLearnHub/CyberLearnHub.csproj
git commit -m "feat: add global XP leaderboard page and per-quiz top-5 on result page"
```

---

## Task 8: PDF Certificate Generation

**Files:**
- Create: `CyberLearnHub/App_Code/CertificateHelper.cs`
- Create: `CyberLearnHub/GetCertificate.ashx` + `.cs`
- Modify: `CyberLearnHub/QuizResult.aspx` + `.cs` + `.designer.cs`
- Modify: `CyberLearnHub/CyberLearnHub.csproj`

- [ ] **Step 1: Install iTextSharp**

In Visual Studio: Tools → NuGet Package Manager → Package Manager Console:

```
Install-Package iTextSharp -Version 5.5.13.3
```

Confirm `packages.config` now contains `<package id="iTextSharp" ...>` and a reference appears in the `.csproj`.

- [ ] **Step 2: Create `Uploads/Certificates` folder**

In Visual Studio Solution Explorer, right-click `Uploads` folder → Add → New Folder → name it `Certificates`.

Or in code (added to `CertificateHelper`): `Directory.CreateDirectory(outputDir)` before writing.

- [ ] **Step 3: Create `App_Code/CertificateHelper.cs`**

```csharp
using System;
using System.IO;
using iTextSharp.text;
using iTextSharp.text.pdf;

public static class CertificateHelper
{
    /// <summary>
    /// Generates a PDF certificate and saves it. Returns the app-relative path ~/Uploads/Certificates/xxx.pdf
    /// </summary>
    public static string Generate(string userName, string courseName,
                                   int percentage, DateTime issuedDate,
                                   string certificatesPhysicalDir)
    {
        Directory.CreateDirectory(certificatesPhysicalDir);

        string guid     = Guid.NewGuid().ToString("N").Substring(0, 12).ToUpper();
        string fileName = guid + ".pdf";
        string fullPath = Path.Combine(certificatesPhysicalDir, fileName);

        var pageSize = PageSize.A4.Rotate(); // landscape
        using (var doc = new Document(pageSize, 50, 50, 50, 50))
        using (var fs  = new FileStream(fullPath, FileMode.Create, FileAccess.Write))
        {
            var writer = PdfWriter.GetInstance(doc, fs);
            doc.Open();

            var cb = writer.DirectContent;

            // Dark background
            cb.SetColorFill(new BaseColor(8, 13, 20));
            cb.Rectangle(0, 0, pageSize.Width, pageSize.Height);
            cb.Fill();

            // Cyan border (outer)
            cb.SetColorStroke(new BaseColor(0, 212, 255));
            cb.SetLineWidth(2.5f);
            cb.Rectangle(20, 20, pageSize.Width - 40, pageSize.Height - 40);
            cb.Stroke();

            // Inner border (dimmed)
            cb.SetColorStroke(new BaseColor(0, 100, 130));
            cb.SetLineWidth(0.5f);
            cb.Rectangle(28, 28, pageSize.Width - 56, pageSize.Height - 56);
            cb.Stroke();

            // Corner accents
            DrawCornerAccent(cb, 20, 20, true,  true);
            DrawCornerAccent(cb, pageSize.Width - 20, 20, false, true);
            DrawCornerAccent(cb, 20, pageSize.Height - 20, true,  false);
            DrawCornerAccent(cb, pageSize.Width - 20, pageSize.Height - 20, false, false);

            float centerX = pageSize.Width / 2;

            // Header tag
            var monoSmall = FontFactory.GetFont(FontFactory.COURIER, 9,
                new BaseColor(0, 212, 255));
            AddCenteredText(doc, writer, "// CYBERLEARN HUB", monoSmall, pageSize.Height - 80);

            // Title
            var titleFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 36,
                new BaseColor(232, 244, 255));
            AddCenteredText(doc, writer, "Certificate of Achievement", titleFont, pageSize.Height - 120);

            // Divider line
            cb.SetColorStroke(new BaseColor(0, 212, 255));
            cb.SetLineWidth(1f);
            cb.MoveTo(centerX - 160, pageSize.Height - 142);
            cb.LineTo(centerX + 160, pageSize.Height - 142);
            cb.Stroke();

            // "This certifies that"
            var bodySmall = FontFactory.GetFont(FontFactory.HELVETICA, 12,
                new BaseColor(90, 122, 153));
            AddCenteredText(doc, writer, "This certifies that", bodySmall, pageSize.Height - 175);

            // Student name
            var nameFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 28,
                new BaseColor(0, 212, 255));
            AddCenteredText(doc, writer, userName, nameFont, pageSize.Height - 215);

            // "has successfully completed"
            AddCenteredText(doc, writer, "has successfully completed", bodySmall, pageSize.Height - 250);

            // Course name
            var courseFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 18,
                new BaseColor(0, 255, 157));
            AddCenteredText(doc, writer, courseName, courseFont, pageSize.Height - 285);

            // Score
            var scoreFont = FontFactory.GetFont(FontFactory.HELVETICA, 13,
                new BaseColor(200, 223, 240));
            AddCenteredText(doc, writer,
                string.Format("with a score of {0}%   |   Issued {1}",
                    percentage, issuedDate.ToString("dd MMMM yyyy")),
                scoreFont, pageSize.Height - 322);

            // Footer cert ID
            var footerFont = FontFactory.GetFont(FontFactory.COURIER, 8,
                new BaseColor(26, 48, 80));
            AddCenteredText(doc, writer, "Certificate ID: " + guid, footerFont, 42);

            doc.Close();
        }
        return "~/Uploads/Certificates/" + fileName;
    }

    private static void AddCenteredText(Document doc, PdfWriter writer,
        string text, Font font, float y)
    {
        var cb    = writer.DirectContent;
        var bf    = font.BaseFont ?? BaseFont.CreateFont(BaseFont.HELVETICA, BaseFont.CP1252, false);
        float size = font.Size > 0 ? font.Size : 12;
        cb.BeginText();
        cb.SetFontAndSize(bf, size);
        cb.SetColorFill(font.Color ?? BaseColor.WHITE);
        float w = bf.GetWidthPoint(text, size);
        cb.SetTextMatrix((doc.PageSize.Width - w) / 2, y);
        cb.ShowText(text);
        cb.EndText();
    }

    private static void DrawCornerAccent(PdfContentByte cb, float x, float y,
        bool left, bool bottom)
    {
        float len = 20f;
        cb.SetColorStroke(new BaseColor(0, 212, 255));
        cb.SetLineWidth(2f);
        float dx = left ? 1 : -1;
        float dy = bottom ? 1 : -1;
        cb.MoveTo(x, y + dy * len);
        cb.LineTo(x, y);
        cb.LineTo(x + dx * len, y);
        cb.Stroke();
    }
}
```

- [ ] **Step 4: Create `GetCertificate.ashx.cs`**

```csharp
using System.IO;
using System.Web;
using System.Web.SessionState;
using System.Data.SqlClient;

namespace CyberLearnHub
{
    public class GetCertificate : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext ctx)
        {
            if (ctx.Session["UserID"] == null)
            { ctx.Response.Redirect("~/Login.aspx"); return; }

            int uid = (int)ctx.Session["UserID"];
            if (!int.TryParse(ctx.Request.QueryString["id"], out int certId) || certId <= 0)
            { ctx.Response.StatusCode = 400; return; }

            string filePath;
            using (var conn = new SqlConnection(DbHelper.ConnectionString))
            using (var cmd  = new SqlCommand(
                "SELECT FilePath FROM dbo.Certificates WHERE CertificateID=@id AND UserID=@uid", conn))
            {
                cmd.Parameters.AddWithValue("@id",  certId);
                cmd.Parameters.AddWithValue("@uid", uid);
                conn.Open();
                object result = cmd.ExecuteScalar();
                if (result == null) { ctx.Response.StatusCode = 403; return; }
                filePath = result.ToString();
            }

            string physical = ctx.Server.MapPath(filePath);
            if (!File.Exists(physical)) { ctx.Response.StatusCode = 404; return; }

            ctx.Response.ContentType = "application/pdf";
            ctx.Response.AddHeader("Content-Disposition", "attachment; filename=\"CyberLearnHub-Certificate.pdf\"");
            ctx.Response.TransmitFile(physical);
        }

        public bool IsReusable => false;
    }
}
```

- [ ] **Step 5: Create `GetCertificate.ashx`**

```aspx
<%@ WebHandler Language="C#" CodeBehind="GetCertificate.ashx.cs" Class="CyberLearnHub.GetCertificate" %>
```

- [ ] **Step 6: Generate cert and show download button in `QuizResult.aspx.cs`**

In `LoadResult`, after `LoadQuizLeaderboard(...)`, add:

```csharp
if (passed)
{
    int certId = IssueCertificate(uid, courseId, quizId, resultId, score, total, courseName);
    if (certId > 0)
        pnlCertBtn.Visible = true;
    // store certId for the download link
    hlCert.NavigateUrl = "~/GetCertificate.ashx?id=" + certId;
}
```

Add method:

```csharp
private int IssueCertificate(int uid, int courseId, int quizId, int resultId,
                              int score, int total, string courseName)
{
    try
    {
        string userName = Session["Username"] as string
                       ?? Session["FullName"] as string
                       ?? "Student";
        string dir      = Server.MapPath("~/Uploads/Certificates/");
        string appPath  = CertificateHelper.Generate(
            userName, courseName,
            total > 0 ? score * 100 / total : 0,
            DateTime.Now, dir);

        using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
        using (SqlCommand cmd = new SqlCommand(@"
            MERGE dbo.Certificates AS target
            USING (SELECT @uid AS UserID, @cid AS CourseID) AS source
                ON target.UserID=source.UserID AND target.CourseID=source.CourseID
            WHEN MATCHED THEN
                UPDATE SET QuizID=@qid, ResultID=@rid, FilePath=@fp, IssuedDate=GETDATE()
            WHEN NOT MATCHED THEN
                INSERT (UserID,CourseID,QuizID,ResultID,FilePath)
                VALUES (@uid,@cid,@qid,@rid,@fp);
            SELECT CertificateID FROM dbo.Certificates WHERE UserID=@uid AND CourseID=@cid;", conn))
        {
            cmd.Parameters.AddWithValue("@uid", uid);
            cmd.Parameters.AddWithValue("@cid", courseId);
            cmd.Parameters.AddWithValue("@qid", quizId);
            cmd.Parameters.AddWithValue("@rid", resultId);
            cmd.Parameters.AddWithValue("@fp",  appPath);
            conn.Open();
            return Convert.ToInt32(cmd.ExecuteScalar());
        }
    }
    catch { return 0; } // cert generation failure is non-fatal
}
```

- [ ] **Step 7: Add cert download button to `QuizResult.aspx`**

After the `result-actions` div, add:

```aspx
<asp:Panel ID="pnlCertBtn" runat="server" Visible="false">
    <div style="text-align:center;margin-bottom:28px;">
        <asp:HyperLink ID="hlCert" runat="server"
            style="display:inline-flex;align-items:center;gap:8px;padding:10px 24px;background:rgba(0,255,157,0.1);border:1px solid rgba(0,255,157,0.4);color:var(--cyber-accent2);font-family:'Rajdhani',sans-serif;font-size:13px;font-weight:700;letter-spacing:1px;border-radius:6px;text-transform:uppercase;text-decoration:none;">
            <i class="ti ti-certificate"></i> Download Certificate
        </asp:HyperLink>
    </div>
</asp:Panel>
```

- [ ] **Step 8: Update `QuizResult.aspx.designer.cs`**

Add:
```csharp
protected global::System.Web.UI.WebControls.Panel pnlCertBtn;
protected global::System.Web.UI.WebControls.HyperLink hlCert;
```

- [ ] **Step 9: Register in `CyberLearnHub.csproj`**

In `<Content>` group:
```xml
<Content Include="GetCertificate.ashx" />
```
In `<Compile>` group:
```xml
<Compile Include="GetCertificate.ashx.cs">
  <DependentUpon>GetCertificate.ashx</DependentUpon>
</Compile>
```

- [ ] **Step 10: Verify**

Pass a quiz. Result page shows green "Download Certificate" button. Click it → PDF downloads. Open PDF → dark background, cyan border, student name, course name, score, date, cert ID in footer.

- [ ] **Step 11: Commit**

```bash
git add CyberLearnHub/App_Code/CertificateHelper.cs CyberLearnHub/GetCertificate.ashx CyberLearnHub/GetCertificate.ashx.cs CyberLearnHub/QuizResult.aspx CyberLearnHub/QuizResult.aspx.cs CyberLearnHub/QuizResult.aspx.designer.cs CyberLearnHub/CyberLearnHub.csproj
git commit -m "feat: generate and download PDF certificate on quiz pass"
```

---

## Task 9: Admin Analytics — Fail Stats, Score Distribution, CSV Export

**Files:**
- Modify: `CyberLearnHub/Admin/Reports.aspx`
- Modify: `CyberLearnHub/Admin/Reports.aspx.cs`
- Modify: `CyberLearnHub/Admin/Reports.aspx.designer.cs`
- Create: `CyberLearnHub/ExportResults.ashx` + `.cs`
- Create: `CyberLearnHub/ExportQuestionStats.ashx` + `.cs`
- Modify: `CyberLearnHub/CyberLearnHub.csproj`

- [ ] **Step 1: Add worst-questions section to `Reports.aspx`**

At the bottom of `Reports.aspx` `<asp:Content ID="MainContent">`, before the closing `</asp:Content>`, add:

```aspx
    <!-- CSV Export buttons -->
    <div style="display:flex;gap:12px;margin-bottom:28px;flex-wrap:wrap;">
        <a href="../ExportResults.ashx" class="btn-admin-primary" style="text-decoration:none;display:inline-flex;align-items:center;gap:6px;">
            <i class="ti ti-download"></i> Export Results CSV
        </a>
        <a href="../ExportQuestionStats.ashx" class="btn-secondary" style="text-decoration:none;display:inline-flex;align-items:center;gap:6px;">
            <i class="ti ti-download"></i> Export Question Stats CSV
        </a>
    </div>

    <!-- Worst performing questions -->
    <div class="admin-section-title" style="font-family:'Rajdhani',sans-serif;font-size:18px;font-weight:700;color:var(--cyber-heading);margin-bottom:14px;">
        // Worst Performing Questions
        <span style="font-family:'Share Tech Mono',monospace;font-size:10px;color:var(--cyber-muted);font-weight:400;margin-left:10px;">(min. 5 attempts)</span>
    </div>
    <asp:Panel ID="pnlNoFailStats" runat="server" Visible="false">
        <p style="font-family:'Share Tech Mono',monospace;font-size:11px;color:var(--cyber-muted);">&gt; Not enough data yet (need 5+ attempts per question).</p>
    </asp:Panel>
    <asp:Panel ID="pnlFailStats" runat="server" Visible="false">
        <div style="overflow-x:auto;margin-bottom:32px;">
        <table class="admin-table">
            <thead><tr>
                <th>Question</th><th>Quiz</th><th>Type</th><th>Difficulty</th><th>Fail Rate</th><th>Attempts</th><th></th>
            </tr></thead>
            <tbody>
                <asp:Repeater ID="rptFailStats" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td style="max-width:300px;"><%# Server.HtmlEncode(((string)Eval("QuestionText")).Length > 60 ? ((string)Eval("QuestionText")).Substring(0,60)+"…" : (string)Eval("QuestionText")) %></td>
                            <td><%# Server.HtmlEncode(Eval("QuizTitle") as string) %></td>
                            <td><%# Eval("QuestionType") %></td>
                            <td><%# Eval("Difficulty") %></td>
                            <td style="color:var(--cyber-danger);font-weight:700;"><%# Eval("FailRate") %>%</td>
                            <td style="color:var(--cyber-muted);"><%# Eval("Attempts") %></td>
                            <td><a href="QuestionForm.aspx?id=<%# Eval("QuestionID") %>&courseId=<%# Eval("CourseID") %>" style="color:var(--cyber-accent);font-family:'Share Tech Mono',monospace;font-size:10px;">Edit</a></td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
        </div>
    </asp:Panel>

    <!-- Score distribution -->
    <div class="admin-section-title" style="font-family:'Rajdhani',sans-serif;font-size:18px;font-weight:700;color:var(--cyber-heading);margin-bottom:14px;">
        // Score Distribution
    </div>
    <asp:Repeater ID="rptDistribution" runat="server">
        <ItemTemplate>
            <div style="margin-bottom:20px;">
                <div style="font-family:'Rajdhani',sans-serif;font-size:14px;font-weight:700;color:var(--cyber-heading);margin-bottom:8px;">
                    <%# Server.HtmlEncode(Eval("QuizTitle") as string) %>
                    <span style="font-family:'Share Tech Mono',monospace;font-size:10px;color:var(--cyber-muted);font-weight:400;margin-left:8px;"><%# Eval("TotalAttempts") %> attempts</span>
                </div>
                <%# Eval("BarsHtml") %>
            </div>
        </ItemTemplate>
    </asp:Repeater>
```

- [ ] **Step 2: Add to `Reports.aspx.designer.cs`**

Add:
```csharp
protected global::System.Web.UI.WebControls.Panel pnlNoFailStats;
protected global::System.Web.UI.WebControls.Panel pnlFailStats;
protected global::System.Web.UI.WebControls.Repeater rptFailStats;
protected global::System.Web.UI.WebControls.Repeater rptDistribution;
```

- [ ] **Step 3: Add analytics methods to `Reports.aspx.cs`**

In `Page_Load`, add two calls:

```csharp
LoadFailStats();
LoadScoreDistribution();
```

Add methods:

```csharp
private void LoadFailStats()
{
    System.Data.DataTable dt = new System.Data.DataTable();
    using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
    using (SqlCommand cmd = new SqlCommand(@"
        SELECT qq.QuestionID, qq.QuestionText, qq.QuestionType, qq.Difficulty,
               qz.Title AS QuizTitle, c.CourseID,
               COUNT(*)                                                      AS Attempts,
               SUM(CASE WHEN qa.IsCorrect=0 THEN 1 ELSE 0 END) * 100 / COUNT(*) AS FailRate
        FROM dbo.QuizAnswers qa
        JOIN dbo.QuizQuestions qq ON qq.QuestionID = qa.QuestionID
        JOIN dbo.Quizzes qz       ON qz.QuizID = qq.QuizID
        JOIN dbo.Courses c        ON c.CourseID = qz.CourseID
        GROUP BY qq.QuestionID, qq.QuestionText, qq.QuestionType, qq.Difficulty,
                 qz.Title, c.CourseID
        HAVING COUNT(*) >= 5
        ORDER BY FailRate DESC", conn))
    {
        conn.Open();
        using (var da = new System.Data.SqlClient.SqlDataAdapter(cmd))
            da.Fill(dt);
    }

    if (dt.Rows.Count == 0) { pnlNoFailStats.Visible = true; return; }
    pnlFailStats.Visible   = true;
    rptFailStats.DataSource = dt;
    rptFailStats.DataBind();
}

private void LoadScoreDistribution()
{
    var rows = new System.Collections.Generic.List<DistRow>();
    using (SqlConnection conn = new SqlConnection(DbHelper.ConnectionString))
    using (SqlCommand cmd = new SqlCommand(@"
        SELECT qz.QuizID, qz.Title,
               SUM(CASE WHEN qr.Percentage <  50 THEN 1 ELSE 0 END) AS B0,
               SUM(CASE WHEN qr.Percentage >= 50 AND qr.Percentage < 70 THEN 1 ELSE 0 END) AS B50,
               SUM(CASE WHEN qr.Percentage >= 70 AND qr.Percentage < 90 THEN 1 ELSE 0 END) AS B70,
               SUM(CASE WHEN qr.Percentage >= 90 THEN 1 ELSE 0 END) AS B90,
               COUNT(*) AS Total
        FROM dbo.QuizResults qr
        JOIN dbo.Quizzes qz ON qz.QuizID = qr.QuizID
        GROUP BY qz.QuizID, qz.Title
        HAVING COUNT(*) > 0
        ORDER BY qz.Title", conn))
    {
        conn.Open();
        using (SqlDataReader r = cmd.ExecuteReader())
        {
            while (r.Read())
            {
                int total = r.GetInt32(6);
                rows.Add(new DistRow
                {
                    QuizTitle    = r.GetString(1),
                    TotalAttempts = total,
                    BarsHtml     = BuildBars(
                        r.GetInt32(2), r.GetInt32(3), r.GetInt32(4), r.GetInt32(5), total)
                });
            }
        }
    }
    rptDistribution.DataSource = rows;
    rptDistribution.DataBind();
}

private static string BuildBars(int b0, int b50, int b70, int b90, int total)
{
    var sb = new System.Text.StringBuilder();
    sb.Append("<div style=\"display:flex;flex-direction:column;gap:6px;\">");
    AppendBar(sb, "0–49%",   b0,  total, "var(--cyber-danger)");
    AppendBar(sb, "50–69%",  b50, total, "var(--cyber-amber)");
    AppendBar(sb, "70–89%",  b70, total, "var(--cyber-accent)");
    AppendBar(sb, "90–100%", b90, total, "var(--cyber-accent2)");
    sb.Append("</div>");
    return sb.ToString();
}

private static void AppendBar(System.Text.StringBuilder sb,
    string label, int count, int total, string color)
{
    int pct = total > 0 ? count * 100 / total : 0;
    sb.AppendFormat(
        "<div style=\"display:flex;align-items:center;gap:10px;\">" +
        "<span style=\"font-family:'Share Tech Mono',monospace;font-size:9px;color:var(--cyber-muted);width:48px;text-align:right;\">{0}</span>" +
        "<div style=\"flex:1;background:var(--cyber-border);border-radius:2px;height:16px;overflow:hidden;\">" +
        "<div style=\"width:{1}%;background:{2};height:100%;border-radius:2px;transition:width 0.3s;\"></div></div>" +
        "<span style=\"font-family:'Share Tech Mono',monospace;font-size:10px;color:var(--cyber-muted);width:24px;\">{3}</span>" +
        "</div>",
        label, pct, color, count);
}

private class DistRow
{
    public string QuizTitle    { get; set; }
    public int    TotalAttempts { get; set; }
    public string BarsHtml     { get; set; }
}
```

- [ ] **Step 4: Create `ExportResults.ashx.cs`**

```csharp
using System;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.SessionState;

namespace CyberLearnHub
{
    public class ExportResults : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext ctx)
        {
            if (ctx.Session["Role"] as string != "Admin")
            { ctx.Response.Redirect("~/AccessDenied.aspx"); return; }

            ctx.Response.ContentType = "text/csv";
            ctx.Response.AddHeader("Content-Disposition",
                "attachment; filename=\"results-" + DateTime.Now.ToString("yyyy-MM-dd") + ".csv\"");

            var sb = new StringBuilder();
            sb.AppendLine("Username,Email,Course,Quiz,Score,TotalQuestions,Percentage,Passed,AttemptDate");

            using (var conn = new SqlConnection(DbHelper.ConnectionString))
            using (var cmd  = new SqlCommand(@"
                SELECT u.FullName, u.Email, c.Title, qz.Title,
                       qr.Score, qr.TotalQuestions, qr.Percentage, qr.Passed, qr.AttemptDate
                FROM dbo.QuizResults qr
                JOIN dbo.Users   u  ON u.UserID  = qr.UserID
                JOIN dbo.Quizzes qz ON qz.QuizID = qr.QuizID
                JOIN dbo.Courses c  ON c.CourseID = qz.CourseID
                ORDER BY qr.AttemptDate DESC", conn))
            {
                conn.Open();
                using (var r = cmd.ExecuteReader())
                    while (r.Read())
                        sb.AppendLine(string.Format("{0},{1},{2},{3},{4},{5},{6},{7},{8}",
                            Csv(r.GetString(0)), Csv(r.GetString(1)),
                            Csv(r.GetString(2)), Csv(r.GetString(3)),
                            r.GetInt32(4), r.GetInt32(5), Convert.ToInt32(r[6]),
                            r.GetBoolean(7) ? "Yes" : "No",
                            Convert.ToDateTime(r[8]).ToString("yyyy-MM-dd HH:mm")));
            }
            ctx.Response.Write(sb.ToString());
        }

        private static string Csv(string v) =>
            v != null && (v.Contains(",") || v.Contains("\"") || v.Contains("\n"))
                ? "\"" + v.Replace("\"", "\"\"") + "\""
                : v ?? "";

        public bool IsReusable => false;
    }
}
```

- [ ] **Step 5: Create `ExportResults.ashx`**

```aspx
<%@ WebHandler Language="C#" CodeBehind="ExportResults.ashx.cs" Class="CyberLearnHub.ExportResults" %>
```

- [ ] **Step 6: Create `ExportQuestionStats.ashx.cs`**

```csharp
using System;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.SessionState;

namespace CyberLearnHub
{
    public class ExportQuestionStats : IHttpHandler, IRequiresSessionState
    {
        public void ProcessRequest(HttpContext ctx)
        {
            if (ctx.Session["Role"] as string != "Admin")
            { ctx.Response.Redirect("~/AccessDenied.aspx"); return; }

            ctx.Response.ContentType = "text/csv";
            ctx.Response.AddHeader("Content-Disposition",
                "attachment; filename=\"question-stats-" + DateTime.Now.ToString("yyyy-MM-dd") + ".csv\"");

            var sb = new StringBuilder();
            sb.AppendLine("QuestionID,QuestionText,Quiz,Course,Difficulty,Topic,TotalAttempts,CorrectCount,IncorrectCount,FailRate%");

            using (var conn = new SqlConnection(DbHelper.ConnectionString))
            using (var cmd  = new SqlCommand(@"
                SELECT qq.QuestionID, qq.QuestionText, qz.Title, c.Title,
                       qq.Difficulty, ISNULL(qq.Topic,''),
                       COUNT(*) AS Total,
                       SUM(CASE WHEN qa.IsCorrect=1 THEN 1 ELSE 0 END) AS Correct,
                       SUM(CASE WHEN qa.IsCorrect=0 THEN 1 ELSE 0 END) AS Incorrect
                FROM dbo.QuizAnswers qa
                JOIN dbo.QuizQuestions qq ON qq.QuestionID = qa.QuestionID
                JOIN dbo.Quizzes qz       ON qz.QuizID    = qq.QuizID
                JOIN dbo.Courses c        ON c.CourseID   = qz.CourseID
                GROUP BY qq.QuestionID, qq.QuestionText, qz.Title, c.Title,
                         qq.Difficulty, qq.Topic
                ORDER BY qq.QuestionID", conn))
            {
                conn.Open();
                using (var r = cmd.ExecuteReader())
                    while (r.Read())
                    {
                        int total   = r.GetInt32(6);
                        int wrong   = r.GetInt32(8);
                        int failPct = total > 0 ? wrong * 100 / total : 0;
                        sb.AppendLine(string.Format("{0},{1},{2},{3},{4},{5},{6},{7},{8},{9}",
                            r.GetInt32(0), Csv(r.GetString(1)),
                            Csv(r.GetString(2)), Csv(r.GetString(3)),
                            r.GetString(4), Csv(r.GetString(5)),
                            total, r.GetInt32(7), wrong, failPct));
                    }
            }
            ctx.Response.Write(sb.ToString());
        }

        private static string Csv(string v) =>
            v != null && (v.Contains(",") || v.Contains("\"") || v.Contains("\n"))
                ? "\"" + v.Replace("\"", "\"\"") + "\""
                : v ?? "";

        public bool IsReusable => false;
    }
}
```

- [ ] **Step 7: Create `ExportQuestionStats.ashx`**

```aspx
<%@ WebHandler Language="C#" CodeBehind="ExportQuestionStats.ashx.cs" Class="CyberLearnHub.ExportQuestionStats" %>
```

- [ ] **Step 8: Register in `CyberLearnHub.csproj`**

In `<Content>` group:
```xml
<Content Include="ExportResults.ashx" />
<Content Include="ExportQuestionStats.ashx" />
```
In `<Compile>` group:
```xml
<Compile Include="ExportResults.ashx.cs">
  <DependentUpon>ExportResults.ashx</DependentUpon>
</Compile>
<Compile Include="ExportQuestionStats.ashx.cs">
  <DependentUpon>ExportQuestionStats.ashx</DependentUpon>
</Compile>
```

- [ ] **Step 9: Verify**

Admin → Reports:
1. CSV export buttons appear at top → click "Export Results CSV" → `.csv` file downloads with correct columns
2. Click "Export Question Stats CSV" → downloads with per-question fail rates
3. After taking quizzes with ≥5 attempts on a question → "Worst Performing Questions" table appears with fail % and Edit links
4. Score distribution bars render with correct colors per bucket

- [ ] **Step 10: Commit**

```bash
git add CyberLearnHub/Admin/Reports.aspx CyberLearnHub/Admin/Reports.aspx.cs CyberLearnHub/Admin/Reports.aspx.designer.cs CyberLearnHub/ExportResults.ashx CyberLearnHub/ExportResults.ashx.cs CyberLearnHub/ExportQuestionStats.ashx CyberLearnHub/ExportQuestionStats.ashx.cs CyberLearnHub/CyberLearnHub.csproj
git commit -m "feat: add question fail stats, score distribution bars, and CSV exports to admin reports"
```

---

## Self-Review Checklist

- ✅ DB schema: all 6 migrations covered in Task 1
- ✅ Quiz settings admin form: Task 2
- ✅ Timer / max attempts / randomize enforcement: Task 3
- ✅ Difficulty / topic / explanation on questions: Task 4
- ✅ QuizAnswers saved per submission: Task 5 Step 1
- ✅ Full review (your answer, explanation): Task 5 Steps 2–3
- ✅ XP awarded per correct answer by difficulty: Task 6
- ✅ Streak updated on pass: Task 6
- ✅ XP/level/streak on Dashboard: Task 6 Steps 2–4
- ✅ Global leaderboard page: Task 7 Steps 1–3
- ✅ Per-quiz top-5 on result page: Task 7 Steps 4–6
- ✅ Leaderboard nav link: Task 7 Step 7
- ✅ iTextSharp PDF certificate: Task 8
- ✅ GetCertificate.ashx secure download: Task 8
- ✅ Cert download button on pass: Task 8 Steps 6–8
- ✅ Worst-performing questions table: Task 9 Steps 1–3
- ✅ Score distribution CSS bars: Task 9 Step 3
- ✅ CSV export handlers (results + question stats): Task 9 Steps 4–7
- ✅ All new files registered in .csproj: Tasks 7, 8, 9
