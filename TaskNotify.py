import re


USStatus = {1:"Under Analysis/Devlopment",2:"Waiting for Documentation",3:"Waiting for testing",4:"Completed"}

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
    task[Task] = []
    userStory = ""
    CRM = ""
    description = ""
    status = "4"
    def __init__(self, dline=[]):
        match = re.match(".+?(?=:)",dline[2])
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

    def updateStatus(self):
        for t in self.task:
            if (re.match("Coding",t.description) or re.match("Analy", t.description)) and t.status != "Completed"
                self.status = USStatus[1]
                break
            elif re.match("Fucntional test", t.description) and t.status != "Completed"
                self.status = USstatus[3]
                break
        if self.status != 1:
            for t in self.task:
                if t.status != 'Completed'
                self.status = USStatus[2]


            

    




