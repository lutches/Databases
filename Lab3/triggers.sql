CREATE OR REPLACE VIEW CourseQueuePositions AS (
    SELECT course, student, ROW_NUMBER() OVER (PARTITION BY course ORDER BY WaitingList.position) AS place
    FROM WaitingList
);

CREATE OR REPLACE FUNCTION on_register() RETURNS trigger AS $on_register$
     -- Check that a student is allowed to register for the course
      -- [] Fullfills prerequisite courses
      -- [] Not already registered for the course
      -- [] Not on the waiting list
      -- [] Not already passed the course

      -- [] Check if the course is full and put on waiting list
    Declare
        coursecapacity INT;
        coursecount INT;


    BEGIN
        IF (true) THEN
            RAISE EXCEPTION 'lmao du tror';
        END IF;

     coursecapacity := (SELECT capacity FROM limitedcourses WHERE limitedcourses.code=NEW.course);
      coursecount := (SELECT COUNT(*) FROM registrations WHERE course=NEW.course AND status='registered');

      IF coursecapacity IS NOT NULL AND coursecount >= coursecapacity THEN
        INSERT INTO waitinglist VALUES (NEW.student, NEW.course);
      ELSE
        INSERT INTO registered VALUES (NEW.student, NEW.course);
      END IF;

      RETURN NEW;

    END;
$on_register$ LANGUAGE plpgsql;


Create OR REPLACE TRIGGER on_register INSTEAD OF INSERT OR UPDATE ON Registrations
    FOR EACH ROW EXECUTE FUNCTION on_register();

--Create OR REPLACE TRIGGER on_unregister INSTEAD OF DELETE ON Registrations
  --  FOR EACH ROW EXECUTE FUNCTION on_unregister();



