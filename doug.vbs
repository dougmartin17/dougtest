
Dim WshShell, oExec, ProKey

Set WshShell = CreateObject("WScript.Shell")

ProKey = InputBox("In the box below,type your 25-character Product Key (no spaces or dashes). You will find this number on the sticker on the back of the CD case or on your Certificate of Authenticity.      Product Key: ","Microsoft Office 2003 sp2 Installation Wizard")

If Len(ProKey) = 25 Then

msgbox "doug doug"

Else

MsgBox "Product Key ERROR ",vbCritical

wscript.quit 'this kills the script

End If

MsgBox "     Installation Finish    "