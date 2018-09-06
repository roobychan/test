#NoEnv
SetWorkingDir, %A_ScriptDir%
#Include Class_SQLiteDB.ahk
dbCon := New SQLiteDB
dbStr := A_ScriptDir . "\TestDB.sqlite"
if !dbCon.OpenDB(dbstr){
	MsgBox %dbStr%
	; MsgBox %dbCon.ErrorMsg%
}

tb := ""
rs := ""
tl := ""
if dbCon.GetTable("SELECT * FROM Test", tb, 0){
	While tb.Next(rs){
		for key,val in rs{
			tl := tl . "|" . val
		}
		Break
	}
}Else{
	; MsgBox %tb.ErrorMsg%
}
MsgBox %tl%
Return