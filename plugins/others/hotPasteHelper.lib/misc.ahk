; -----------------------------------------------
; CALCULATE
; -----------------------------------------------
^Numpad0::
::calx::
	API.runPlugin("hotPasteHelper.ahk", "CALC", ",", false, 0.3)My favorite number is __CALC__!
	return

; -----------------------------------------------
; DATE & TIME
; -----------------------------------------------
::date::
	API.runPlugin("hotPasteHelper.ahk", "", "__DATETIME__")
	return

::datecurrent::
	API.runPlugin("hotPasteHelper.ahk", "", "Current date is: __DATETIME|yyyy. MMMM dd.__")
	return

::daterange::
	API.runPlugin("hotPasteHelper.ahk", "", "Selected date: __DATEPICKER|yyyy.MMMM dd.__")
	return

::dateshort::
	API.runPlugin("hotPasteHelper.ahk", "", "Short date is: __DATETIME|ShortDate__")
	return

::time::
	API.runPlugin("hotPasteHelper.ahk", "", "Current time is: __DATETIME|H:mm:ss__")
	return

; -----------------------------------------------
; SPECIAL CHARACTERS
; -----------------------------------------------
!Numpad5::	; some characters require Segoe UI Symbol font to be installed installed
	API.runPlugin("hotPasteHelper.ahk", "*Special Characters !singlechar !nosort !noautoclose !fontsize=12", "__?Special characters__")
	return
	
^!Numpad5::
	API.runPlugin("hotPasteHelper.ahk", "*Special Characters Languages !singlechar !nosort !noautoclose !fontsize=12", "__?Special characters__")
	return

; -----------------------------------------------
; OTHERS
; -----------------------------------------------
::sep::
	API.PasteText("-----------------------------------------------")
	return

::htt::
::http::
	API.PasteText("http://")
	return

::lorem::
	API.PasteText("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
	return

::loremshort::
	API.PasteText("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
	return

#y::	; remove title bar on win+y
	WinSet, Style, ^0xC00000, A
	return

$Escape::	; send ctrl+w on long ESC press
	If LongPress(800) {
		Send, ^w
	}
	return

$^RButton::	; bring Double Commander to front on long ctrl+rightclick
	If LongPress(300) {
		If Not WinActive Double Commander
			WinActivate, Double Commander
	}
	return

^+x::	; Trim selection
	Send, ^x
	Send, +{HOME}
	Send, {DELETE}
	Send, +{END}
	Send, {DELETE}
	Send, ^v
	return
	
; -----------------------------------------------
; ENVIRONMENT VARIABLES
; -----------------------------------------------
::ALLUSERSPROFILE::
::APPDATA::
::COMMONPROGRAMFILES::
::COMMONPROGRAMFILES(X86)::
::COMPUTERNAME::
::COMSPEC::
::HOMEDRIVE::
::HOMEPATH::
::LANG::
::LOCALAPPDATA::
::LOGONSERVER::
::OS::
::PROGRAMDATA::
::PROGRAMFILES::
::PROGRAMFILES(X86)::
::PROGRAMW6432::
::PUBLIC::
::SYSTEMDRIVE::
::SYSTEMROOT::
::TEMP::
::TMP::
::USERDOMAIN::
::USERNAME::
::USERPROFILE::
::WINDIR::
	API.runPlugin("hotPasteHelper.ahk", "ENVVARS")
	return
