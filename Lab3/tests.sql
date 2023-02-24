--- TEST 1 : Register to an unlimited course
--- EXP. OUTCOME : Pass
INSERT INTO Registrations VALUES ('2222222222', 'CCC444');
/*
--- TEST 2 : Register to a limited course
--- EXP: OUTCOME : Pass
INSERT INTO Registrations VALUES ('1111111111', 'AAA111')

--- TEST 3 : Waiting for a limited course
--- EXP: OUTCOME : 


--- TEST 4 : Remove from a waitinglist with additional students in the list 
--- EXP. OUTCOME : 

--- TEST 5 : Unregister from an unlimited course
--- EXP. OUTCOME : Pass
DELETE FROM  Registrations WHERE student = '1111111111'  AND course = 'AAA111'

--- TEST 6 : Unregister from a limited course without a waiting list 
--- EXP. OUTCOME : 
INSERT INTO Registrations VALUES ()

--- TEST 7 : Unregister from a limited course with a waiting list when the student is registered
--- EXP. OUTCOME : 
INSERT INTO Registrations VALUES ()

--- TEST 8 : Unregister from a limited course with a waiting list when the student is in the middle of the waiting list
--- EXP. OUTCOME : 
INSERT INTO Registrations VALUES ()

--- TEST 9 : Unregister from an overfull course with a waiting list
--- EXP. OUTCOME : 
INSERT INTO Registrations VALUES ()


*/