import psycopg2


class PortalConnection:
    def __init__(self):
        self.conn = psycopg2.connect(
            host="localhost",
            user="postgres",
            password="postgres")
        self.conn.autocommit = True

    def getInfo(self,student):
      with self.conn.cursor() as cur:
        # Here's a start of the code for this part
        sql = """
                SELECT jsonb_build_object(
                     'student', s.idnr
                    ,'name', s.name
                ) :: TEXT
                FROM BasicInformation AS s
                WHERE s.idnr = %s;"""
        cur.execute(sql, (student,))
        res = cur.fetchone()
        if res:
            return (str(res[0]))
        else:
            return """{"student":"Not found :("}"""

    def register(self, student, courseCode):
        try:
            #Your code goes here! Remove this comment and the line below it. 
            return """{"success":false, "error":"Registration not implemented"}"""
        except psycopg2.Error as e:
            message = getError(e)
            return '{"success":false, "error": "'+message+'"}'

    def unregister(self, student, courseCode):
        try:
            #Your code goes here! Remove this comment and the line below it. 
            return """{"success":false, "error":"Unregistration not implemented"}"""
        except psycopg2.Error as e:
            message = getError(e)
            return '{"success":false, "error": "'+message+'"}'

def getError(e):
    message = repr(e)
    message = message.replace("\\n"," ")
    message = message.replace("\"","\\\"")
    return message

