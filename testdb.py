import sqlite3
from openpyxl import Workbook


def getUserStory(cur):
    query = 'SELECT * from UserStory'
    cur.execute(query)
    return cur.fetchall()


def getInfo(us, cur):
    query = 'SELECT DESP FROM STATUS WHERE STATUS="{0}"'.format(us[10])
    cur.execute(query)
    rt = cur.fetchall()
    if rt is not None:
        us[10] = rt[0][0]


wb = Workbook()
filename = 'test.xlsx'
ws1 = wb.active

conn = sqlite3.connect('myRally.db')
cur = conn.cursor()

ustory = [list(i) for i in getUserStory(cur)]
for us in ustory:
    getInfo(us, cur)

for us in ustory:
    ws1.append(us)
wb.save(filename=filename)
