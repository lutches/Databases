

Create TABLE Students(
    idnr CHAR(10) PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    login TEXT NOT NULL UNIQUE,
    program TEXT NOT NULL,
    FOREIGN KEY (program) REFERENCES programs(name),
    UNIQUE (idnr, program)
);

Create TABLE programs (
    name TEXT PRIMARY KEY NOT NULL,
);

Create Table MandatoryProgram (
    course CHAR(6) NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (course, program),
    FOREIGN KEY (course) REFERENCES Courses(code)
);

Create TABLE Branches (
    name  TEXT PRIMARY KEY NOT NULL,
);

Create Table MandatoryBranch (
    Course CHAR(6) NOT NULL,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
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
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

Create Table classifications (
    name Text PRIMARY KEY NOT NULL -- maybe shouldn't have not null?
);

Create Table Classified ( 
    course CHAR(6) NOT NULL,
    classification TEXT NOT NULL,
    PRIMARY KEY (course, classification),
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (classification) REFERENCES classifications(name)
);





Create Table RecommendedBranch(
    course CHAR(6) NOT NULL,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program),
    FOREIGN KEY (course) REFERENCES Courses(code)
);

Create Table Registered (
    student CHAR(10) NOT NULL,
    course CHAR(6) NOT NULL,
    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (course) REFERENCES Courses(code)
);

CREATE TABLE Taken (
    student VARCHAR(16) REFERENCES Students,
    course CHAR(6) NOT NULL REFERENCES Courses,
    grade CHAR(1) NOT NULL CHECK (grade IN ('U', '3', '4', '5')),
    PRIMARY KEY (student, course)
);

Create Table WaitingList (
    student CHAR(10) NOT NULL REFERENCES Students(idnr),
    course CHAR(6) NOT NULL REFERENCES LimitedCourses(code),
    position Serial Not Null,
    PRIMARY KEY (student, course)
);
