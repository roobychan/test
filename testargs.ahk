
; RunWait, %ComSpec% /c " python C:\MyPF\code\test\test\testargs.ahk test"

RunWaitOne(command) {
    ; WshShell object: http://msdn.microsoft.com/en-us/library/aew9yb99¬
    shell := ComObjCreate("WScript.Shell")
    ; Execute a single command via cmd.exe
    exec := shell.Exec(ComSpec " /C " command)
    ; Read and return the command's output
    return exec.StdOut.ReadAll()
}

rt := RunWaitOne("python C:\MyPF\code\test\test\testargs.py test")
MsgBox %rt%