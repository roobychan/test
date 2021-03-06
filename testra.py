from pyral import Rally
import sqlite3


def updateUS(cur, us):
    if us.CRM is None:
        us.CRM = 0
    us.Name = us.Name.replace("'", "''")
    ou = getOwner(us.Owner)
    towner = ''
    towner = getUSStatus(us, towner)
    query = """INSERT OR IGNORE INTO UserStory(USID,DESP,CRM,OWNER,STATUS,ITERA,TOWNER)
        VALUES('{0}','{1}',{2},'{3}','{4}','{5}','{6}')""".format(us.FormattedID, us.Name, us.CRM, ou, us.ScheduleState, getIteration(us), towner)
    # print(query)
    cur.execute(query)
    query = """UPDATE UserStory SET DESP='{1}', CRM={2}, OWNER='{3}', STATUS='{4}', ITERA='{5}', TOWNER='{6}'
        WHERE USID='{0}'""".format(us.FormattedID, us.Name, us.CRM, ou, us.ScheduleState, getIteration(us), towner)
    cur.execute(query)

    for task in us.Tasks:
        updateTask(cur, us, task)


def updateTask(cur, us, task):
    task.Name = task.Name.replace("'", "''")
    ou = getOwner(task.Owner)
    getTaskStatus(task)
    query = """INSERT OR IGNORE INTO TASK(TASKID,DESP,USID,OWNER,STATUS)
        VALUES('{0}','{1}','{2}','{3}','{4}')""".format(task.FormattedID, task.Name, us.FormattedID, ou, task.State)
    # print(query)
    cur.execute(query)
    query = """UPDATE TASK SET DESP='{1}', USID='{2}', OWNER='{3}', STATUS='{4}'
        WHERE TASKID='{0}'""".format(task.FormattedID, task.Name, us.FormattedID, ou, task.State)
    # print(query)
    cur.execute(query)


def getIteration(us):
    if us.Iteration:
        # print(us.Iteration.details())
        return us.Iteration.Name
    else:
        return ''


def getOwner(own):
    if own:
        own.UserName = own.UserName.lower()
        for usr in user:
            if own.UserName == usr[1]:
                return usr[0]
    else:
        return ""
    return ""


def initUser(cur):
    cur.execute('SELECT * FROM OWNER')
    rt = cur.fetchall()
    return rt


def initStatus(cur):
    cur.execute('SELECT * FROM STATUS')
    return cur.fetchall()


def getUSStatus(us, town):
    for t1 in us.Tasks:
        if t1.Name == 'functional test' or t1.Name.lower() == 'functional testing' or t1.Name.lower() == 'function test':
            town = getOwner(t1.Owner)
            print(town)
    for st in status:
        if st[1] == us.ScheduleState and st[0][0] == 'U':
            us.ScheduleState = st[0]
            return town
    for t1 in us.Tasks:
        if (t1.Name == 'functional test' or t1.Name.lower() == 'functional testing' or t1.Name.lower() == 'function test') and t1.State != 'Completed':
            for t2 in us.Tasks:
                if t2.Name == 'KT to tester for code changes' and t2.State == 'Completed':
                    us.ScheduleState = 'U5'
                else:
                    us.ScheduleState = 'U4'
        if t1.State != 'Completed' and (t1.Name == 'Analyze the US' or t1.Name == 'Coding & Unit Testing' or t1.Name == 'Analysis' or t1.Name == 'Coding and unit testing'):
            us.ScheduleState = 'U3'
    if us.ScheduleState[0] != 'U':
        us.ScheduleState = 'U6'
    # print(us.ScheduleState)
    return town


def getTaskStatus(task):
    for st in status:
        if task.State == st[1]:
            task.State = st[0]


conn = sqlite3.connect('myRally.db')
c = conn.cursor()

user = initUser(c)
status = initStatus(c)

rally = Rally('rally1.rallydev.com',
              apikey='_b0ZewDOZThOpwqO4hbOi278k1JpeAE0tueYqgmzxIeY',
              workspace='ES (Employer Services)', project='GV - XSS - APAC')

response = rally.get('UserStory', limit=100)
i = 0
for us in response:
    i = i + 1
    print(i, us.FormattedID)
    if us.FormattedID != 'US923012':
        continue
    updateUS(c, us)
    # print(us.details())
    # for task in us.Tasks:
    #     print(task.details())
    #     break
    # break

conn.commit()
