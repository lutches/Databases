Create View BasicInformation AS (
    Select Students.idnr, Students.name, Students.login, Students.program, StudentBranches.branch
    From Students
    Left Join StudentBranches ON StudentBranches.student = Students.idnr

);

Create View FinishedCourses As (
    Select Student, course, grade, credits
    From Students
    Join Taken On idnr = Taken.Student
    Join Courses ON course = Courses.code
);

Create View PassedCourses AS ( 
    Select student, course, credits
    From FinishedCourses
    where grade != 'U'
);

Create View Registrations AS (
    Select Student, Course, 'registered' AS status
    From Registered
    UNION
    Select Student, course, 'waiting' AS status
    From WaitingList
);

CREATE OR REPLACE VIEW MandatoryCourses AS (
    SELECT idnr, basicinformation.program, basicinformation.branch, course
    FROM basicinformation
    JOIN mandatoryprogram ON mandatoryprogram.program=basicinformation.program
    UNION
    SELECT idnr, basicinformation.program, basicinformation.branch, course
    FROM basicinformation
    JOIN mandatorybranch ON mandatorybranch.program=basicinformation.program AND mandatorybranch.branch=basicinformation.branch
);

Create View UnreadMandatory AS (
    Select idnr AS student, course 
    From MandatoryCourses
    Except
    Select student, course 
    From PassedCourses
);

Create View SumCredits AS (
    Select student, Sum(credits) AS totalCredits
    From FinishedCourses
)

Create View NumberOfUnread AS (
Select student, Count(student) AS numberUnread
From UnreadMandatory
Group By student
);

Create View MathCredits

Create View PathToGraduation AS (
    Select FinishedCourses.student, FinishedCourses.credits AS totalCredits, NumberOfUnread.numberUnread AS mandatoryLeft, 'math' AS mathcredits, 'reasearch' AS researchCredits, 'seminarcourses' AS seminarcourses, True AS qualified
    From FinishedCourses
    outer join NumberOfUnread
    ON FinishedCourses.student = NumberOfUnread.student
    --outer join Classified
    




    -- Classified
);
