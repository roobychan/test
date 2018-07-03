import re


USStatus = {1: "Under Analysis/Devlopment", 2: "Waiting for Documentation", 3: "Waiting for testing", 4: "Completed"}

class Task:
    taskID = ""
    # userStory = ""
    # descrption = ""
    taskType = ""
    # CRM = ""
    owner = ""
    status = ""
    def __init__(self, dline = []):
        self.taskID = dline[0]
        self.taskType = dline[1]
        self.status = dline[5]
        self.owner = dline[10][:-1]

class UserStory:
    contactors = []
    tasks = []
    userStory = ""
    CRM = ""
    description = ""
    status = USStatus[4]
    notifier = ""
    def __init__(self, dline=[]):
        match = re.search(r"(?<=US).+?(?=:)",dline[2])
        if match:
            self.userStory = match.group(0)
        match = re.search(r"(?<=:\W).*\S+-?(?=-)",dline[2])
        if match:
            self.description = match.group(0)
        else:
            match = re.search(r"(?<=:\W).*\S+",dline[2])
            if match:
                self.description = match.group(0)
        match = re.search(r"(?<=-)\d+",dline[2])
        if match:
            self.CRM = match.group(0)
        else:
            match = re.search(r"(?<=-CRM\W)\d+",dline[2])
            if match:
                self.CRM = match.group(0)
        self.owner = dline[10][:-1]
        self.addTask(dline)

    def updateStatus(self):
        for t in self.tasks:
            if (re.search(r"Coding",t.taskType) or re.search(r"Analy", t.taskType)) and t.status != "Completed":
                self.status = USStatus[1]
                for c in UserStory.contactors:
                    if c[0] == t.owner:
                        self.notifier = c[1]
                        break
                break
            elif re.search(r"Fucntional test", t.taskType) and t.status != "Completed":
                self.status = USStatus[3]
                for c in UserStory.contactors:
                    if c[0] == t.owner:
                        self.notifier = c[1]
                        break
                break
        if self.status != USStatus[1]:
            for t in self.tasks:
                if t.status != 'Completed':
                    self.status = USStatus[2]
                    for c in UserStory.contactors:
                        if c[0] == t.owner:
                            self.notifier = c[1]
                            break
        
    def addTask(self, dline=[]):
        self.tasks.append(Task(dline))

        
    


def main():
    readData = []
    UStories = []
    with open('Contactor.csv') as f:
        for l in f:
            clist = l.split(',')
            UserStory.contactors.append(clist) 
    with open('export.csv') as f:
        for l in f:
            readData.append(l)
    readData.pop(0)
    readData.replace("\"","")
    readData.sort()
    for r in readData:
        slist = r.split(",")
        match = re.search(r"(?<=US).+?(?=:)", slist[2])
        if match:
            new = True
            for u in UStories:
                if match.group(0) == u.userStory:
                    new = False
                    u.addTask(slist)
                    break
            if new:
                UStories.append(UserStory(slist))
    for u in UStories:
        u.updateStatus()
    # for u in UStories:
    #     print(u.userStory, u.description, u.CRM,u.status,u.owner, u.notifier)
    #     for t in u.tasks:
    #         print(t.taskID,t.taskType,t.status)


main()
            

    




