import re


USStatus = {1: "Under Analysis/Devlopment", 2: "Waiting for Documentation", 3: "Waiting for testing", 4: "Completed"}


class Task:
    taskID = ""
    # userStory = ""
    # descrption = ""
    taskType = ""
    # CRM = ""
    # owner = ""
    status = ""
    def __init__(self, dline = []):
        self.taskID = dline[0]
        self.taskType = dline[1]
        self.status = dline[5]

class UserStory:
    tasks = [Task]
    userStory = ""
    CRM = ""
    description = ""
    status = "4"
    def __init__(self, dline=[]):
        match = re.match("(?<=US).+?(?=:)",dline[2])
        if match:
            self.userStory = match.group(0)
        match = re.match("(?<=:\W).*\S+-?(?=-)",dline[2])
        if match:
            self.description = match.group(0)
        else:
            match = re.match("(?<=:\W).*\S+",dline[2])
            if match:
                self.description = match.group(0)
        match = re.match("(?<=-)\d+",dline[2])
        if match:
            self.CRM = match.group(0)
        else:
            match = re.match("(?<=-CRM\W)\d+",dline[2])
            if match:
                self.CRM = match.group(0)
        self.owner = dline[10]
        self.addTask(dline)

    def updateStatus(self):
        for t in self.tasks:
            if (re.match("Coding",t.taskType) or re.match("Analy", t.taskType)) and t.status != "Completed":
                self.status = USStatus[1]
                break
            elif re.match("Fucntional test", t.taskType) and t.status != "Completed":
                self.status = USStatus[3]
                break
        if self.status != 1:
            for t in self.tasks:
                if t.status != 'Completed':
                    self.status = USStatus[2]
    
    def addTask(self, dline=[]):
        self.tasks.append(Task(dline))
    


def main():
    readData = []
    UStories = [UserStory]
    with open('export.csv') as f:
        for l in f:
            readData.append(l)
    readData.pop(0)

    for r in readData:
        slist = r.split(",")
        match = re.match("(?<=US).+?(?=:)", slist[2])
        if match:
            new = True
            for u in UStories:
                if match.group(0) == u.userStory:
                    new = False
                    u.addTask(u,slist)
                    break
            if new:
                UStories.append(UserStory(slist))

    for u in UStories:
        print(u.userStory, u.description, u.CRM,u.status)
        for t in u.tasks:
            print(t.taskID,t.taskType,t.status)

main()
            

    




