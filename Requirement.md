# Requirement


## Send mail for doc
1. AHK show window
2. input US
3. get owner from python
3. send mail

## Check US status
1. AHK show window
2. input owner
3. get all Dev us from python
4. send mail

_b0ZewDOZThOpwqO4hbOi278k1JpeAE0tueYqgmzxIeY

## Create US
1. AHK show window
2. input CRM,Description
3. input owner type iteration
4. call python
5. python call rally api
6. create US and tasks
7. update data base
8. return all info
9. put into clipboard

## Update database
1. get US 
2. get Tasks

## Create Excel
1. Create Excel

```
RunWaitOne(command) {
    ; WshShell object: http://msdn.microsoft.com/en-us/library/aew9yb99¬
    shell := ComObjCreate("WScript.Shell")
    ; Execute a single command via cmd.exe
    exec := shell.Exec(ComSpec " /C " command)
    ; Read and return the command's output
    return exec.StdOut.ReadAll()
}```