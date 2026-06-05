/* =====================================================================
   CyberLearn Hub - Database Creation Script
   Target: Microsoft SQL Server / LocalDB (Visual Studio)
   Module: CT050-3-2-WAPP Web Applications

   HOW TO RUN:
   - Open this in SQL Server Object Explorer (or SSMS), connected to your
     CyberLearnHub database, then Execute.
   - Safe to re-run: it drops existing tables first (child tables before
     parent tables so foreign keys don't block the drop).
   ===================================================================== */

/* ---- Drop in reverse-dependency order ---- */
IF OBJECT_ID('dbo.QuizResults', 'U')       IS NOT NULL DROP TABLE dbo.QuizResults;
IF OBJECT_ID('dbo.QuizQuestions', 'U')     IS NOT NULL DROP TABLE dbo.QuizQuestions;
IF OBJECT_ID('dbo.Quizzes', 'U')           IS NOT NULL DROP TABLE dbo.Quizzes;
IF OBJECT_ID('dbo.Progress', 'U')          IS NOT NULL DROP TABLE dbo.Progress;
IF OBJECT_ID('dbo.Enrollments', 'U')       IS NOT NULL DROP TABLE dbo.Enrollments;
IF OBJECT_ID('dbo.LearningMaterials', 'U') IS NOT NULL DROP TABLE dbo.LearningMaterials;
IF OBJECT_ID('dbo.Courses', 'U')           IS NOT NULL DROP TABLE dbo.Courses;
IF OBJECT_ID('dbo.WebsiteContent', 'U')    IS NOT NULL DROP TABLE dbo.WebsiteContent;
IF OBJECT_ID('dbo.Users', 'U')             IS NOT NULL DROP TABLE dbo.Users;
GO

/* =====================================================================
   1. USERS  (Registered Users + Administrators)
   ===================================================================== */
CREATE TABLE dbo.Users (
    UserID        INT IDENTITY(1,1) PRIMARY KEY,
    FullName      NVARCHAR(100)  NOT NULL,
    Email         NVARCHAR(150)  NOT NULL UNIQUE,
    PasswordHash  NVARCHAR(255)  NOT NULL,            -- store a HASH, never plain text
    Role          NVARCHAR(20)   NOT NULL DEFAULT 'Member'
                  CHECK (Role IN ('Member', 'Admin')),
    ProfileImage  NVARCHAR(255)  NULL,
    IsActive      BIT            NOT NULL DEFAULT 1,
    CreatedDate   DATETIME       NOT NULL DEFAULT GETDATE()
);
GO

/* =====================================================================
   2. COURSES  (managed by Admin, browsed by everyone)
   ===================================================================== */
CREATE TABLE dbo.Courses (
    CourseID     INT IDENTITY(1,1) PRIMARY KEY,
    Title        NVARCHAR(150)  NOT NULL,
    Description  NVARCHAR(MAX)  NULL,
    Category     NVARCHAR(50)   NULL,                 -- e.g. Network Security, Cryptography
    Difficulty   NVARCHAR(20)   NULL
                 CHECK (Difficulty IN ('Beginner','Intermediate','Advanced')),
    ImageUrl     NVARCHAR(255)  NULL,
    IsPublished  BIT            NOT NULL DEFAULT 1,
    CreatedBy    INT            NULL,
    CreatedDate  DATETIME       NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Courses_Users FOREIGN KEY (CreatedBy) REFERENCES dbo.Users(UserID)
);
GO

/* =====================================================================
   3. LEARNING MATERIALS  (each belongs to one Course)
   ===================================================================== */
CREATE TABLE dbo.LearningMaterials (
    MaterialID    INT IDENTITY(1,1) PRIMARY KEY,
    CourseID      INT            NOT NULL,
    Title         NVARCHAR(150)  NOT NULL,
    MaterialType  NVARCHAR(20)   NOT NULL DEFAULT 'Article'
                  CHECK (MaterialType IN ('Article','PDF','Video')),
    FilePath      NVARCHAR(255)  NULL,                -- for downloadable PDF/video
    Content       NVARCHAR(MAX)  NULL,                -- for text/article material
    SortOrder     INT            NOT NULL DEFAULT 1,
    UploadedDate  DATETIME       NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Materials_Courses FOREIGN KEY (CourseID)
        REFERENCES dbo.Courses(CourseID) ON DELETE CASCADE
);
GO

/* =====================================================================
   4. ENROLLMENTS  (a User enrolls in a Course)
   ===================================================================== */
CREATE TABLE dbo.Enrollments (
    EnrollmentID  INT IDENTITY(1,1) PRIMARY KEY,
    UserID        INT          NOT NULL,
    CourseID      INT          NOT NULL,
    EnrollDate    DATETIME     NOT NULL DEFAULT GETDATE(),
    Status        NVARCHAR(20) NOT NULL DEFAULT 'In Progress'
                  CHECK (Status IN ('In Progress','Completed')),
    CONSTRAINT FK_Enroll_Users   FOREIGN KEY (UserID)   REFERENCES dbo.Users(UserID),
    CONSTRAINT FK_Enroll_Courses FOREIGN KEY (CourseID) REFERENCES dbo.Courses(CourseID),
    CONSTRAINT UQ_Enroll UNIQUE (UserID, CourseID)     -- can't enroll twice
);
GO

/* =====================================================================
   5. PROGRESS  (tracks which material a user has completed)
   Drives the % complete and dashboard statistics.
   ===================================================================== */
CREATE TABLE dbo.Progress (
    ProgressID    INT IDENTITY(1,1) PRIMARY KEY,
    EnrollmentID  INT       NOT NULL,
    MaterialID    INT       NOT NULL,
    IsCompleted   BIT       NOT NULL DEFAULT 0,
    CompletedDate DATETIME  NULL,
    CONSTRAINT FK_Progress_Enroll   FOREIGN KEY (EnrollmentID)
        REFERENCES dbo.Enrollments(EnrollmentID) ON DELETE CASCADE,
    CONSTRAINT FK_Progress_Material FOREIGN KEY (MaterialID)
        REFERENCES dbo.LearningMaterials(MaterialID),
    CONSTRAINT UQ_Progress UNIQUE (EnrollmentID, MaterialID)
);
GO

/* =====================================================================
   6. QUIZZES  (each belongs to one Course)
   ===================================================================== */
CREATE TABLE dbo.Quizzes (
    QuizID       INT IDENTITY(1,1) PRIMARY KEY,
    CourseID     INT           NOT NULL,
    Title        NVARCHAR(150) NOT NULL,
    Description  NVARCHAR(MAX) NULL,
    PassingScore INT           NOT NULL DEFAULT 50,   -- percent needed to pass
    CreatedDate  DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Quizzes_Courses FOREIGN KEY (CourseID)
        REFERENCES dbo.Courses(CourseID) ON DELETE CASCADE
);
GO

/* =====================================================================
   7. QUIZ QUESTIONS  (multiple-choice, supports auto-marking)
   ===================================================================== */
CREATE TABLE dbo.QuizQuestions (
    QuestionID    INT IDENTITY(1,1) PRIMARY KEY,
    QuizID        INT           NOT NULL,
    QuestionText  NVARCHAR(MAX) NOT NULL,
    OptionA       NVARCHAR(255) NOT NULL,
    OptionB       NVARCHAR(255) NOT NULL,
    OptionC       NVARCHAR(255) NULL,
    OptionD       NVARCHAR(255) NULL,
    CorrectOption CHAR(1)       NOT NULL
                  CHECK (CorrectOption IN ('A','B','C','D')),
    Marks         INT           NOT NULL DEFAULT 1,
    CONSTRAINT FK_Questions_Quizzes FOREIGN KEY (QuizID)
        REFERENCES dbo.Quizzes(QuizID) ON DELETE CASCADE
);
GO

/* =====================================================================
   8. QUIZ RESULTS  (one row per attempt - the auto-marking output)
   ===================================================================== */
CREATE TABLE dbo.QuizResults (
    ResultID        INT IDENTITY(1,1) PRIMARY KEY,
    UserID          INT          NOT NULL,
    QuizID          INT          NOT NULL,
    Score           INT          NOT NULL,           -- marks obtained
    TotalQuestions  INT          NOT NULL,
    Percentage      DECIMAL(5,2) NOT NULL,
    Passed          BIT          NOT NULL,
    AttemptDate     DATETIME     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Results_Users   FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID),
    CONSTRAINT FK_Results_Quizzes FOREIGN KEY (QuizID) REFERENCES dbo.Quizzes(QuizID)
);
GO

/* =====================================================================
   9. WEBSITE CONTENT  (Admin "Manage Website Content")
   ===================================================================== */
CREATE TABLE dbo.WebsiteContent (
    ContentID    INT IDENTITY(1,1) PRIMARY KEY,
    SectionKey   NVARCHAR(50)  NOT NULL UNIQUE,       -- e.g. 'home_hero', 'about'
    Title        NVARCHAR(200) NULL,
    Body         NVARCHAR(MAX) NULL,
    UpdatedBy    INT           NULL,
    UpdatedDate  DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Content_Users FOREIGN KEY (UpdatedBy) REFERENCES dbo.Users(UserID)
);
GO

/* =====================================================================
   SEED DATA  (for testing - delete or expand as needed)
   Passwords are hashed with SHA2_256 so they match a C# hash of the
   same plain text. Default login below is  Admin@123  /  Member@123.
   ===================================================================== */
INSERT INTO dbo.Users (FullName, Email, PasswordHash, Role) VALUES
('System Administrator', 'admin@cyberlearn.com',
    CONVERT(NVARCHAR(255), HASHBYTES('SHA2_256', 'Admin@123'), 2), 'Admin'),
('Demo Member', 'member@cyberlearn.com',
    CONVERT(NVARCHAR(255), HASHBYTES('SHA2_256', 'Member@123'), 2), 'Member');

INSERT INTO dbo.Courses (Title, Description, Category, Difficulty, CreatedBy) VALUES
('Introduction to Cybersecurity', 'Core concepts, threats and the CIA triad.', 'Fundamentals', 'Beginner', 1),
('Network Security Basics', 'Firewalls, VPNs and securing network traffic.', 'Network Security', 'Intermediate', 1),
('Cryptography Essentials', 'Encryption, hashing and digital signatures.', 'Cryptography', 'Intermediate', 1);

INSERT INTO dbo.LearningMaterials (CourseID, Title, MaterialType, Content, SortOrder) VALUES
(1, 'What is Cybersecurity?', 'Article', 'Cybersecurity protects systems, networks and data from attack...', 1),
(1, 'The CIA Triad', 'Article', 'Confidentiality, Integrity and Availability are the three pillars...', 2);

INSERT INTO dbo.Quizzes (CourseID, Title, Description, PassingScore) VALUES
(1, 'Cybersecurity Basics Quiz', 'Test your understanding of core concepts.', 50);

INSERT INTO dbo.QuizQuestions (QuizID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectOption, Marks) VALUES
(1, 'What does the "C" in the CIA triad stand for?', 'Control', 'Confidentiality', 'Cryptography', 'Compliance', 'B', 1),
(1, 'Which of these is a type of malware?', 'Firewall', 'Router', 'Ransomware', 'Protocol', 'C', 1);

INSERT INTO dbo.WebsiteContent (SectionKey, Title, Body, UpdatedBy) VALUES
('home_hero', 'Learn Cybersecurity the Smart Way',
 'CyberLearn Hub helps you build real cybersecurity skills through courses and quizzes.', 1);
GO

PRINT 'CyberLearn Hub database created successfully.';