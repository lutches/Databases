-- prep work
drop schema public CASCADE;
create Schema public;


------ tables -------

Create TABLE Departments (
    name TEXT PRIMARY KEY NOT NULL
);

Create TABLE Programs (
    name TEXT NOT NULL PRIMARY KEY
);

Create TABLE ProgramIn (
    program TEXT NOT NULL REFERENCES Programs(name),
    department TEXT NOT NULL REFERENCES Departments(name)
);

Create TABLE Courses (
    code CHAR(6) PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    credits Float NOT NULL,
    department TEXT NOT NULL REFERENCES Departments(name)
);

Create TABLE Prerequisites (
    course CHAR(6) REFERENCES Courses(code),
    prerequisite CHAR(6) REFERENCES Courses(code),
    PRIMARY KEY (course, prerequisite)
);

Create TABLE Students(
    idnr CHAR(10) PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    login TEXT NOT NULL UNIQUE,
    program TEXT NOT NULL REFERENCES Programs(name),
    UNIQUE(idnr, program)
);

Create TABLE MandatoryProgram (
    course CHAR(6) NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (course, program),
    FOREIGN KEY (course) REFERENCES Courses(code)
);

Create TABLE Branches (
    name TEXT NOT NULL,
    program TEXT NOT NULL REFERENCES Programs(name),
    PRIMARY KEY (name, program)
);

Create TABLE MandatoryBranch (
    course CHAR(6) NOT NULL,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

Create TABLE LimitedCourses (
    code CHAR(6) PRIMARY KEY NOT NULL, 
    capacity INTEGER NOT NULL,
    FOREIGN KEY (code) REFERENCES Courses(code)
);

Create TABLE StudentBranches (
    student CHAR(10) PRIMARY KEY NOT NULL,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program),
    FOREIGN KEY (student, program) REFERENCES Students(idnr, program)
);

Create TABLE classifications (
    name Text PRIMARY KEY NOT NULL
);

Create TABLE Classified ( 
    course CHAR(6) NOT NULL,
    classification TEXT NOT NULL,
    PRIMARY KEY (course, classification),
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (classification) REFERENCES classifications(name)
);

Create TABLE RecommendedBranch(
    course CHAR(6) NOT NULL,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program),
    FOREIGN KEY (course) REFERENCES Courses(code)
);

Create TABLE Registered (
    student CHAR(10) NOT NULL,
    course CHAR(6) NOT NULL,
    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (course) REFERENCES Courses(code)
);

Create TABLE Taken (
    student VARCHAR(16) REFERENCES Students,
    course CHAR(6) NOT NULL REFERENCES Courses,
    grade CHAR(1) NOT NULL CHECK (grade IN ('U', '3', '4', '5')),
    PRIMARY KEY (student, course)
);

Create TABLE WaitingList (
    student CHAR(10) NOT NULL REFERENCES Students(idnr),
    course CHAR(6) NOT NULL REFERENCES LimitedCourses(code),
    position Serial Not Null,
    PRIMARY KEY (student, course)
);

------ views ------

Create or Replace View BasicInformation AS (
    Select Students.idnr, Students.name, Students.login, Students.program, StudentBranches.branch
    From Students
    Left Join StudentBranches ON StudentBranches.student = Students.idnr

);

Create or Replace View FinishedCourses As (
    Select Student, course, grade, credits
    From Students
    Join Taken On idnr = Taken.Student
    Join Courses ON course = Courses.code
);

Create or Replace View PassedCourses AS ( 
    Select student, course, credits
    From FinishedCourses
    where grade != 'U'
);

Create or Replace View Registrations AS (
    Select Student, Course, 'registered' AS status
    From Registered
    UNION
    Select Student, course, 'waiting' AS status
    From WaitingList
);


Create or Replace View UnreadMandatory AS (
    With MandatoryCourses  
    AS (SELECT idnr, basicinformation.program, basicinformation.branch, course
        FROM basicinformation
        JOIN mandatoryprogram ON mandatoryprogram.program=basicinformation.program
        UNION
        SELECT idnr, basicinformation.program, basicinformation.branch, course
        FROM basicinformation
        JOIN mandatorybranch ON mandatorybranch.program=basicinformation.program 
        AND mandatorybranch.branch=basicinformation.branch
        )


    Select idnr AS student, course 
    From MandatoryCourses
    Except
    Select student, course 
    From PassedCourses
);


Create or Replace View PathToGraduation AS (
    With SumCredits AS (
    Select PassedCourses.student, Sum(credits) AS totalCredits
    From PassedCourses
    Group by passedCourses.student),

    NumberOfUnread AS (
    Select student, Count(student) AS numberUnread
    From UnreadMandatory
    Group By student),

    mathcredits AS (
    Select Student, Sum(credits) AS mathcredits
    From PassedCourses
    Join Classified ON PassedCourses.course = Classified.course
    where Classified.classification = 'math'
    Group by Student),

    researchcredits AS (
    Select Student, Sum(credits) AS researchcredits
    From PassedCourses
    Join Classified ON PassedCourses.course = Classified.course
    where Classified.classification = 'research'
    Group by Student),

    seminarcourses AS (
    Select Student, Count(PassedCourses.course) AS seminarcourses
    From PassedCourses
    Join Classified ON PassedCourses.course = Classified.course
    where Classified.classification = 'seminar' 
    Group by Student),

    RecommendedCourses as (
    Select PassedCourses.student, PassedCourses.course, PassedCourses.credits
    From PassedCourses
    LEFT JOIN basicinformation ON passedcourses.student=basicinformation.idnr
    JOIN recommendedbranch
    ON recommendedbranch.program=basicinformation.program
    AND recommendedbranch.branch=basicinformation.branch
    AND recommendedbranch.course=passedcourses.course),
    
    recommendedCredits AS (
    Select Student, Sum(RecommendedCourses.credits) AS total
    From RecommendedCourses
    Group By Student)

    Select 
    BasicInformation.idnr AS student, 
    Coalesce(totalCredits,0) AS totalcredits, 
    Coalesce(numberUnread,0) AS mandatoryleft, 
    Coalesce(mathcredits,0) AS mathcredits, 
    Coalesce(researchcredits,0) AS researchcredits,
    Coalesce(seminarcourses,0) AS seminarcourses,
    basicinformation.branch IS NOT NULL
    AND COALESCE(NumberOfUnread.numberUnread, 0) = 0
    AND COALESCE(recommendedCredits.total, 0) >= 10
    AND COALESCE(mathCredits.mathcredits, 0) >= 20
    AND COALESCE(researchCredits.researchCredits, 0) >= 10
    AND COALESCE(seminarCourses.seminarCourses, 0) > 0
    AS qualified

    FROM basicinformation
    LEFT JOIN sumCredits ON idnr=sumCredits.student
    LEFT JOIN NumberOfUnread ON idnr=NumberOfUnread.student
    LEFT JOIN mathCredits ON idnr=mathCredits.student
    LEFT JOIN researchCredits ON idnr=researchCredits.student
    LEFT JOIN seminarCourses ON idnr=seminarCourses.student
    LEFT JOIN recommendedCredits ON idnr=recommendedCredits.student
);



------ inserts ------


INSERT INTO Departments VALUES ('Dep1');

INSERT INTO Programs VALUES ('Prog1');
INSERT INTO Programs VALUES ('Prog2');

INSERT INTO Branches VALUES ('B1','Prog1');
INSERT INTO Branches VALUES ('B2','Prog1');
INSERT INTO Branches VALUES ('B1','Prog2');

INSERT INTO Students VALUES ('1111111111','N1','ls1','Prog1');
INSERT INTO Students VALUES ('2222222222','N2','ls2','Prog1');
INSERT INTO Students VALUES ('3333333333','N3','ls3','Prog2');
INSERT INTO Students VALUES ('4444444444','N4','ls4','Prog1');
INSERT INTO Students VALUES ('5555555555','Nx','ls5','Prog2');
INSERT INTO Students VALUES ('6666666666','Nx','ls6','Prog2');

INSERT INTO Courses VALUES ('CCC111','C1',22.5,'Dep1');
INSERT INTO Courses VALUES ('CCC222','C2',20,'Dep1');
INSERT INTO Courses VALUES ('CCC333','C3',30,'Dep1');
INSERT INTO Courses VALUES ('CCC444','C4',60,'Dep1');
INSERT INTO Courses VALUES ('CCC555','C5',50,'Dep1');
INSERT INTO Courses VALUES ('CCC666','C6',5,'Dep1');
INSERT INTO Courses VALUES ('CCC777','C7',10,'Dep1');

INSERT INTO prerequisites VALUES ('CCC111','CCC222');
INSERT INTO prerequisites VALUES ('CCC111','CCC333');

INSERT INTO LimitedCourses VALUES ('CCC222',1);
INSERT INTO LimitedCourses VALUES ('CCC333',1);
INSERT INTO LimitedCourses VALUES ('CCC666',1);
INSERT INTO LimitedCourses VALUES ('CCC777',1);

INSERT INTO Classifications VALUES ('math');
INSERT INTO Classifications VALUES ('research');
INSERT INTO Classifications VALUES ('seminar');

INSERT INTO Classified VALUES ('CCC333','math');
INSERT INTO Classified VALUES ('CCC444','math');
INSERT INTO Classified VALUES ('CCC444','research');
INSERT INTO Classified VALUES ('CCC444','seminar');


INSERT INTO StudentBranches VALUES ('2222222222','B1','Prog1');
INSERT INTO StudentBranches VALUES ('3333333333','B1','Prog2');
INSERT INTO StudentBranches VALUES ('4444444444','B1','Prog1');
INSERT INTO StudentBranches VALUES ('5555555555','B1','Prog2');

INSERT INTO MandatoryProgram VALUES ('CCC111','Prog1');

INSERT INTO MandatoryBranch VALUES ('CCC333', 'B1', 'Prog1');
INSERT INTO MandatoryBranch VALUES ('CCC444', 'B1', 'Prog2');

INSERT INTO RecommendedBranch VALUES ('CCC222', 'B1', 'Prog1');
INSERT INTO RecommendedBranch VALUES ('CCC333', 'B1', 'Prog2');

INSERT INTO Registered VALUES ('1111111111','CCC111');
INSERT INTO Registered VALUES ('1111111111','CCC222');
INSERT INTO Registered VALUES ('1111111111','CCC333');
INSERT INTO Registered VALUES ('2222222222','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC333');
INSERT INTO Registered VALUES ('2222222222','CCC777');
INSERT INTO Registered VALUES ('1111111111','CCC666');
INSERT INTO REGISTERED VALUES ('5555555555','CCC666');

INSERT INTO Taken VALUES('4444444444','CCC111','5');
INSERT INTO Taken VALUES('4444444444','CCC222','5');
INSERT INTO Taken VALUES('4444444444','CCC333','5');
INSERT INTO Taken VALUES('4444444444','CCC444','5');

INSERT INTO Taken VALUES('5555555555','CCC111','5');
INSERT INTO Taken VALUES('5555555555','CCC222','4');
INSERT INTO Taken VALUES('5555555555','CCC444','3');

INSERT INTO Taken VALUES('2222222222','CCC111','U');
INSERT INTO Taken VALUES('2222222222','CCC222','U');
INSERT INTO Taken VALUES('2222222222','CCC444','U');

INSERT INTO WaitingList VALUES('3333333333','CCC222',1);
INSERT INTO WaitingList VALUES('2222222222','CCC333',2);
INSERT INTO WaitingList VALUES('2222222222','CCC666',1);
INSERT INTO WaitingList VALUES('3333333333','CCC666',2);
INSERT INTO WaitingList VALUES('4444444444','CCC666',3);
