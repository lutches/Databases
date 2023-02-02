

Create TABLE Students(
    idnr CHAR(10) PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    login TEXT NOT NULL UNIQUE,
    program TEXT NOT NULL
);

Create TABLE Branches (
    name  TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (name, program) 
);

Create Table Courses (
    code CHAR(6) PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    credits Float NOT NULL,
    department TEXT NOT NULL
);

Create Table LimitedCourses (
    code CHAR(6) PRIMARY KEY NOT NULL, 
    capacity INTEGER NOT NULL,
    FOREIGN KEY (code) REFERENCES Courses(code)
);

Create Table StudentBranches (
    student CHAR(10) PRIMARY KEY NOT NULL,
    branch TEXT, 
    program TEXT NOT NULL,
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

Create Table Classifications (
    name Text PRIMARY KEY NOT NULL -- maybe shouldn't have not null?
);

Create Table Classified ( 
    course CHAR(6) NOT NULL,
    classifications TEXT NOT NULL,
    PRIMARY KEY (course, classifications),
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (classifications) REFERENCES Classifications(name)
);

Create Table MandatoryProgram (
    course CHAR(6) NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (course, program),
    FOREIGN KEY (course) REFERENCES Courses(code)
);

Create Table MandatoryBranch (
    Course CHAR(6) NOT NULL,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

Create Table RecommendedBranch(
    course CHAR(6) NOT NULL,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

Create Table Registered (
    student CHAR(10) NOT NULL,
    course CHAR(6) NOT NULL,
    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (course) REFERENCES Courses(code)
);
Create Type GradeValues AS ENUM ('U', '3', '4', '5');

Create Table Taken (
    student CHAR(10) NOT NULL, 
    course CHAR(6) NOT NULL,
    grade GradeValues NOT NULL,
    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (course) REFERENCES Courses(code)
);

Create Table WaitingList (
    student CHAR(10) NOT NULL,
    course CHAR(6) NOT NULL,
    position Serial Not Null,
    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (course) REFERENCES Courses(code)

);
