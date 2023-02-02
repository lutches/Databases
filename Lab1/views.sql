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
    Select PassedCourses.student, Sum(credits) AS totalCredits
    From PassedCourses
    Group by passedCourses.student
);

Create View NumberOfUnread AS (
    Select student, Count(student) AS numberUnread
    From UnreadMandatory
    Group By student
);

Create View mathcredits AS (
    Select Student, Sum(credits) AS mathcredits
    From PassedCourses
    Join Classified ON PassedCourses.course = Classified.course
    where Classified.classifications = 'math'
    Group by Student
);

Create View researchcredits AS (
    Select Student, Sum(credits) AS researchcredits
    From PassedCourses
    Join Classified ON PassedCourses.course = Classified.course
    where Classified.classifications = 'research'
    Group by Student
);

Create View seminarcourses AS (
    Select Student, Count(PassedCourses.course) AS seminarcourses
    From PassedCourses
    Join Classified ON PassedCourses.course = Classified.course
    where Classified.classifications = 'seminar' 
    Group by Student
);

Create View RecommendedCourses as (
    Select PassedCourses.student, PassedCourses.course, PassedCourses.credits
    From PassedCourses
    LEFT JOIN basicinformation ON passedcourses.student=basicinformation.idnr
    JOIN recommendedbranch
    ON recommendedbranch.program=basicinformation.program
    AND recommendedbranch.branch=basicinformation.branch
    AND recommendedbranch.course=passedcourses.course

);

Create View recommendedCredits AS (
    Select Student, Sum(RecommendedCourses.credits) AS total
    From RecommendedCourses
    Group By Student
);

Create View PathToGraduation AS (
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

    
