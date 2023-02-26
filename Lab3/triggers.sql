CREATE OR REPLACE VIEW CourseQueuePositions AS (
    SELECT course, student, ROW_NUMBER() OVER (PARTITION BY course ORDER BY WaitingList.position) AS place
    FROM WaitingList
);

CREATE OR REPLACE FUNCTION on_register() RETURNS trigger AS $on_register$
     -- Check that a student is allowed to register for the course
      -- [x] Fullfills prerequisite courses
      -- [x] Not already registered for the course
      -- [x] Not on the waiting list
      -- [x] Not already passed the course
      -- [x] Check if the course is full and put on waiting list
    Declare
        coursecapacity INT;
        coursecount INT;
        coursestatus Text;

    BEGIN
    -- first test that always fails to see if the trigger works correctly 
        /*IF (true) THEN
            RAISE EXCEPTION 'lmao du tror';
        END IF;
        */
    coursestatus := (Select status from registrations where student = NEW.student and course = NEW.course);

        IF coursestatus = 'registered' THEN
            RAISE EXCEPTION 'already registered for this course';
        END IF;

        IF coursestatus = 'waiting' THEN
            RAISE EXCEPTION 'already waiting for this course';
        END IF;

        IF (
        SELECT
            COUNT(*)FROM 
            prerequisites
            LEFT JOIN passedcourses ON
            passedcourses.student=NEW.student AND
            passedcourses.course=prerequisite
            WHERE prerequisites.course=NEW.course AND student IS NULL)>0
            THEN
        RAISE EXCEPTION 'Not eligible for course';
      END IF;
            
        IF (select credits from passedCourses WHERE 
        PassedCourses.course = NEW.Course and 
        PassedCourses.student = NEW.student)>0 THEN
            RAISE EXCEPTION 'has already passed this course';
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


CREATE OR REPLACE FUNCTION on_unregister() RETURNS trigger AS $on_unregister$
  DECLARE
    coursecapacity INT;
    coursecount INT;
    firstinqueue VARCHAR(10);
  BEGIN
      DELETE FROM registered WHERE student=OLD.student AND course=OLD.course;
      DELETE FROM waitinglist WHERE student=OLD.student AND course=OLD.course;

      coursecapacity := (SELECT capacity FROM limitedcourses WHERE limitedcourses.code=OLD.course);
      coursecount := (SELECT COUNT(*) FROM registrations WHERE course=OLD.course AND status='registered');

      IF coursecapacity IS NOT NULL AND coursecount < coursecapacity THEN
        firstinqueue := (SELECT student FROM coursequeuepositions WHERE place=1 AND course=OLD.course);

        IF firstinqueue IS NOT NULL THEN
          DELETE FROM waitinglist WHERE student=firstinqueue AND course=OLD.course;
          INSERT INTO registered VALUES (firstinqueue, OLD.course);
        END IF;
      END IF;
    RETURN OLD;
END;
$on_unregister$ LANGUAGE plpgsql;

Create TRIGGER on_register INSTEAD OF INSERT OR UPDATE ON Registrations
    FOR EACH ROW EXECUTE FUNCTION on_register();

Create TRIGGER on_unregister INSTEAD OF DELETE ON Registrations
    FOR EACH ROW EXECUTE FUNCTION on_unregister();



