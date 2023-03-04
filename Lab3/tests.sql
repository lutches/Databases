

--- TEST #1 : Register to an unlimited course
--- EXP. OUTCOME : Pass
INSERT INTO Registrations VALUES ('1111111111', 'CCC111');

--- TEST #2 : Register to a limited course
--- EXP: OUTCOME : Pass
INSERT INTO Registrations VALUES ('2222222222', 'CCC222');

--- TEST #3 : Waiting for a limited course
--- EXP: OUTCOME : pass
INSERT INTO Registrations VALUES ('3333333333','CCC333');

--- TEST #4 : Remove from a waitinglist with additional students in the list 
--- EXP. OUTCOME : pass
DELETE FROM Registrations WHERE student = '4444444444' and course = 'CCC444';
--- TEST #5 : Unregister from an unlimited course
--- EXP. OUTCOME : Pass 
DELETE FROM Registrations WHERE student = '5555555555' and course = 'CCC555';

--- TEST #6 : Unregister from a limited course without a waiting list 
--- EXP. OUTCOME : Pass
DELETE FROM Registrations WHERE student = '6666666666' and course = 'CCC666';

--- TEST #7 : Unregister from a limited course with a waiting list when the student is registered
--- EXP. OUTCOME : Pass
DELETE FROM Registrations WHERE student = '1111111111' and course = 'CCC333';

--- TEST #8 : Unregister from a limited course with a waiting list when the student is in the middle of the waiting list
--- EXP. OUTCOME : Pass
DELETE FROM Registrations WHERE student = '8888888888' and course = 'CCC888';

--- TEST #9 : Unregister from an overfull course with a waiting list
--- EXP. OUTCOME : 
DELETE FROM Registrations WHERE student = '9999999999' and course = 'CCC999';

-- TEST #10: Register an already registered student.
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('0000000010', 'CCC010');

-- TEST #11: Try to register for course already passed.
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('0000000011', 'CCC011');

-- TEST #12: Try to register for a course where the prerequisites haven't been taken.
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('0000000012', 'CCC012');


-- TEST #13: Register to a course where prerequisites are fulfilled
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('0000000013', 'CCC013');


