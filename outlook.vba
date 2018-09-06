Sub test()
    Dim Session As Outlook.NameSpace
    Dim Report As String
    Dim TaskFolder As Outlook.Folder
    Dim currentItem As Object
    Dim currentTask As TaskItem
    Set Session = Application.Session
    Set TaskFolder = Session.GetDefaultFolder(olFolderToDo)
    
    For Each cItem In TaskFolder.Items
        If cItem.Status <> 2 Then
        Report = Report & "|" & cItem.Subject
        Report = Report & "|" & cItem.Status
        Report = Report & "|" & cItem.DueDate
        Report = Report & "|" & cItem.CreationTime
        Report = Report & "|" & cItem.DateCompleted & vbCrLf
        End If
    Next
    Dim objCurrentFolder As Outlook.Folder
    Set objOutlookFile = Outlook.Application.Session.GetFolderFromID("00000000E0CC9AC21E989C428133557EFA93E80282800000")
    Dim i As Long
    Dim objMail As Outlook.MailItem
    Dim objFlaggedMail As Outlook.MailItem
    ' MsgBox objOutlookFile.EntryID
    For i = 1 To objCurrentFolder.Items.Count
        If objCurrentFolder.Items(i).Class = olMail Then
           'Export the information of each flagged email to Excel
           Set objMail = objCurrentFolder.Items(i)
           If objMail.IsMarkedAsTask = True And objMail.FlagStatus <> olFlagComplete Then
                Report = Report & "|" & cItem.Subject
                Report = Report & "|" & cItem.FlagStatus
                Report = Report & "|" & cItem.TaskDueDate
                Report = Report & "|" & cItem.ReceivedTime
                Report = Report & "|" & cItem.TaskCompletedDate & vbCrLf
          End If
        End If
    Next i
    MsgBox Report
End Sub