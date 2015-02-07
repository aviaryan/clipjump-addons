;@Plugin-Name HotPaste Helper
;@Plugin-Version 0.1
;@Plugin-Silent 1
;@Plugin-Description Advanced text replacement features - user inputs, calculator, variables, datepicker, etc.
;@Plugin-Author Roland Toth (tpr)
;@Plugin-Tags hotstring text replacement

#Hotstring EndChars `t
#SingleInstance Off
#Persistent
Return

global zActiveId

global zOptionsFile
global zHistoryFile
global zHistoryItemLimit

global zModeGlobal
global zUserSettings

global zGUImodeGlobal
global zNoDefaultGlobal
global zHistoryItemLimitGlobal
global zFontSizeGlobal
global zFontAutoCloseGlobal
global zSortItemsGlobal

global zIsRunning

global zMode
global zModeHistory
global zNoDefault

Global zComboBox
Global zOriginalInput
Global zGuiCaretPos
Global zGuiSelection
Global zDisableGetSelection
Global zAutoComplete

global zGuiHWND
global zGUImode
global zFontSize
global zSortItems
global zAutoClose

SetKeyDelay,-1

#Include *i %A_ScriptDir%\plugins\hotPasteHelper.lib\_index.ahk

plugin_hotPasteHelper(zMode = "", zParam1 = "", zParam2 = "", zParam3 = "") {
	
	IfInString, zMode, !longpress
		If (!LongPress()) {
			Return false
		}
	
	If (!zMode) {
		zModeGlobal := "GENERAL"
	} Else {
		zModeGlobal := zMode
	}
	
	If (zIsRunning != true) {
		zSetOptions()
	}
	
	zUserSettings := zModeGlobal
	
	zSetSettings(zMode)

	; if historySection starts with built-in modes, use that
	If (InStr(zMode, "NAV") == 1) {
		zNav(zParam1, zParam2, zParam3)
		
	} Else If (InStr(zMode, "RUN") == 1) {
		zRun(zParam1, zParam2, zParam3)
		
	} Else If (InStr(zMode, "CALC") == 1) {
		zCalc(zParam1, zParam2, zParam3)
	
	} Else If (InStr(zMode, "SEARCH") == 1) {
		zSearch(zParam1)
	
	} Else {
		zExpand(zParam1, zParam2, zParam3)
	}
	
	EmptyMem()

	Return
}

; open url in user-defined browser or use system default
zNav(zUrl, zBrowser, zUrlEncode) {

	If (zUrl == "") {
		Return
	}

	zUrlEncode := (zUrlEncode == "") ? true : false
	
	zBrowser := (zBrowser == "") ? "Default" : zBrowser
	zBrowser := zGetBrowser(zBrowser)

	zUrl := zExpand(zUrl, zUrlEncode, false)

	IfInString, zUrl, %A_Space% 
	{
		zUrl := """" . zUrl . """"
	}

	If (!ErrorLevel) {
		IfExist, %zBrowser%
			Run %zBrowser% %zUrl%
		Else
			Run %zUrl%
	}

	Return
}

zRun(zPath, zParameters = "", zWindowMode = "") {

	If (zPath == "") {
		Return
	}

	zPath := zConvertToAbsolutePath(zPath)
	
	If (zParameters != "") {
		zExpandedParameters := zExpand(zParameters, false, false)
	}

	If (zParameters != "" && zExpandedParameters == "") {	; user cancelled the combobox
		Return
	}

	IfExist, %zPath%
		If (zParameters != "") {
			Run %zPath% %zExpandedParameters%, , %zWindowMode%
		} else {
			Run %zPath%, , %zWindowMode%
		}

	Return
}


zCalc(zThousandsSeparator = "", zWithInput = 0, zFormat = 0.2, zEchoResult = 1) {

	Static zDefaultValue
	Static zPrevValue

	zUserInput := zComboBoxGUI("Calculate", zDefaultValue)

	If (zUserInput != "-1" && !ErrorLevel) {
	
		zDefaultValue := zUserInput

		zAddToHistory(zOriginalInput)
	
		zUserInput := zClipCalc(zWithInput, zUserInput, 0, zFormat)
		zUserInput := zThousandsSep(zUserInput, zThousandsSeparator)

		zPrevValue := zOriginalInput

		If (zEchoResult != 0) {
			zPaste(zUserInput)
		} Else {
			Return %zUserInput%
		}
	}
	
	Return
}

zSearch(zBrowser) {
	
	zUserInput := zComboBoxGUI("Search")
	
	If (zUserInput != "-1") {
			
		;~ get search key and url
		StringSplit, zSearchKeyValue, zUserInput, %A_Space%
		
		If (zSearchKeyValue != "-1") {
			
			;~ get search key
			zSearchKey = %zSearchKeyValue1%
			
			;~ get search url
			StringReplace, zSearchString, zUserInput, %zSearchKey%
			zSearchString := Trim(zSearchString)
			
			;~ add to history (full user input)
			zAddToHistory(zUserInput)
			
			zSearchString := zUriEncode(zSearchString)
			
			;~ lookup target url from options file
			IniRead, zSearchUrl, %zOptionsFile%, Searches, %zSearchKey%, %A_Space%
			
			; search for entire user input if key not found
			If (zSearchUrl == "") {
				IniRead, zSearchUrl, %zOptionsFile%, Searches, default, %A_Space%
			}

			;~ replace %s
			StringReplace, zSearchUrl, zSearchUrl, `%s, %zSearchString%, All
			
			;~ navigate to url
			zNav(zSearchUrl, zBrowser, 0)		
		}
	}

	Return
}

zExpand(zInput = "", zUrlEncode = 0, zEchoResult = 1) {

	Static zPrevValue
	
	zDefaultSeparator := "|"

	; ENVIRONMENT VARIABLES
	If (zInput == ENVVARS) {
		zInput := Substr(A_ThisHotkey, 3)
		zInput := "%" . zInput . "%"
	}

	zInput := zExpandEnvVars(zInput)

	; __SELECTION__
	IfInString, zInput, __SELECTION__
	{
		zSelection := zGetSelectedText()
		
		If (zUrlEncode) {
			zSelection := zUriEncode(zSelection)
		}
	
		StringReplace, zInput, zInput, __SELECTION__, %zSelection%, All
	}

	; __CALC__
	IfInString, zInput, __CALC__
	{
		;While InStr(zInput, "__CALC__") {
			zUserInput := zCalc("", "", "", 0)
			If (zUserInput != "") {
				StringReplace, zInput, zInput, __CALC__, %zUserInput%, All
			}
		;}
	}

	; __CLIPBOARD__
	IfInString, zInput, __CLIPBOARD__
	{
		zCurrentClipboard := API.getClipAt(CN.NG, 1)
		
		If (zUrlEncode) {
			zCurrentClipboard := zUriEncode(zCurrentClipboard)
		}
		
		StringReplace, zInput, zInput, __CLIPBOARD__, %zCurrentClipboard%, All
	}

	; __CURRENTURL__
	IfInString, zInput, __CURRENTURL__
	{
		Send, {F6}

		tmp = %ClipboardAll%
		Clipboard := ""

		Send, ^c
		ClipWait, 1

		StringGetPos, pos, Clipboard, http

		If (ErrorLevel == 0 && Clipboard && pos == 0) {
			zCurrentClipboard = %Clipboard%
			StringReplace, zInput, zInput, __CURRENTURL__, %zCurrentClipboard%, All
		}
		
		Clipboard = %tmp%
	}

	; __DATETIME__
	IfInString, zInput, __DATETIME
	{
		zDateFormat := "yyyy-MM-dd"
		
		While RegExMatch(zInput, "U)__DATETIME(.*)__") {
			
			If (RegExMatch(zInput, "`aU)__DATETIME\|(.*)__", SubPat)) {
				StringReplace, zDateFormat, SubPat, __DATETIME|, , All
				StringReplace, zDateFormat, zDateFormat, __, , All
				zDateFormat := Trim(zDateFormat)
			} Else {
				SubPat := "__DATETIME__"
			}

			FormatTime, zCurrentDateTime, , %zDateFormat%

			StringReplace, zInput, zInput, %SubPat%, %zCurrentDateTime%, All
		}
	}

	; __DATEPICKER__
	IfInString, zInput, __DATEPICKER
	{
		zDateFormat := "yyyy-MM-dd"
		
		While RegExMatch(zInput, "U)__DATEPICKER(.*)__") {

			If (RegExMatch(zInput, "`aU)__DATEPICKER\|(.*)__", SubPat)) {
				
				StringReplace, zDateFormat, SubPat, __DATEPICKER|, , All
				StringReplace, zDateFormat, zDateFormat, __, , All
				zDateFormat := Trim(zDateFormat)
			} Else {
				SubPat := "__DATEPICKER__"
			}

			InputDate := zDatePickerGUI()

			If (InputDate != "-1") {
				StringSplit, InputDate, InputDate, -
						
				FormatTime, InputDate, %InputDate1%, %zDateFormat%
				FormatTime, InputDate2, %InputDate2%, %zDateFormat%

				If (InputDate != InputDate2) {
					InputDate = %InputDate% - %InputDate2%
				}

				StringReplace, zInput, zInput, %SubPat%, %InputDate%, All
			} Else {
				Return
			}
		}
	}

	; USER_INPUT
	IfInString, zInput, __?
	{
		While RegExMatch(zInput, "U)__\?(.*)__") {
			
			If (RegExMatch(zInput, "`aU)__\?(.*)__", SubPat)) {
				StringReplace, zTitle, SubPat, __?, , All
				StringReplace, zTitle, zTitle, __, , All
				zTitle := Trim(zTitle)

				; extract default value
				IfInString, zTitle, %zDefaultSeparator%
				{
					StringSplit, zTitleWithDefaultValue, zTitle, %zDefaultSeparator%
					zTitle := zTitleWithDefaultValue1
					; use user-defined default value only if no item in history
					If (zDefaultValue == "") {
						zDefaultValue := zTitleWithDefaultValue2
					}
				}
				
				If (SubPat == "__?LAST__" && zPrevValue != "") {
					zUserInput := zPrevValue
				} Else {
					zUserInput := zComboboxGUI(zTitle, zDefaultValue)
				}

				If (zUserInput != "-1" && zUserInput != "" && !ErrorLevel) {
		
					zDefaultValue := zUserInput
					
					zAddToHistory(zOriginalInput)

					If (zUrlEncode) {
						zUserInput := zUriEncode(zUserInput)
					}

					StringReplace, zInput, zInput, %SubPat%, %zUserInput%, All

					;~ zPrevValue := zOriginalInput
					zPrevValue := zDefaultValue

				} Else {
					ErrorLevel := 1
					Return
				}
			}
		}
	}

	If (!ErrorLevel) {
		
		;~ ; get the character next to caret position
		;~ If (InStr(zModeGlobal, "!singlechar") > 0) {

			;~ fix 1 offset on last item
			;~ If (StrLen(zInput) > zGuiCaretPos) {
				;~ zGuiCaretPos := zGuiCaretPos + 1
			;~ }
			
			;~ zInput := substr(zInput, zGuiCaretPos, 1)
			;~ zGuiCaretPos := ""
		;~ }
		
		;~ ; paste/return selection only
		;~ If (InStr(zUserSettings, "!selection") > 0) {
			;~ zInput := zGuiSelection
			;~ zGuiSelection := ""
		;~ }

		If (zEchoResult != 0) {
			zPaste(zInput)
			Return
		} Else {
			Return zInput
		}
	}
}

zPaste(zInput = "") {

	If (zInput == "") {
		Return
	}
	
	WinActivate, ahk_id %zActiveId%
	API.blockMonitoring(1)
	Clipboard := zInput
	Send, ^{vk56}
	API.blockMonitoring(0)
	Return
}

;~ global options
zSetOptions() {

	zOptionsFile := A_ScriptDir . "\plugins\hotPasteHelper.ini"
	zHistoryFile := A_ScriptDir . "\plugins\hotPasteHelper_history.ini"
	
	IfNotExist, %zOptionsFile%
	{
		IniWrite, 2, %zOptionsFile%, Options, GUImode
		IniWrite, 10, %zOptionsFile%, Options, fontSize
		IniWrite, 30, %zOptionsFile%, Options, maxHistoryItems
		IniWrite, 0, %zOptionsFile%, Options, noDefault
		IniWrite, 0, %zOptionsFile%, Options, autoClose
		
		IniWrite, Chrome, %zOptionsFile%, Browsers, default
		IniWrite, ..\Chrome\GoogleChromePortable.exe, %zOptionsFile%, Browsers, Chrome
		IniWrite, ..\Firefox\FirefoxPortable.exe, %zOptionsFile%, Browsers, Firefox
		IniWrite, `%A_ProgramFiles`%\Internet Explorer\iexplore.exe, %zOptionsFile%, Browsers, IE
		
		IniWrite, https://duckduckgo.com/?q=`%s, %zOptionsFile%, Searches, default
	}
	
	IniRead, zGUImodeGlobal, %zOptionsFile%, Options, GUImode, %A_Space%
	IniRead, zNoDefaultGlobal, %zOptionsFile%, Options, noDefault, 0
	IniRead, zHistoryItemLimitGlobal, %zOptionsFile%, Options, maxHistoryItems, 30
	IniRead, zFontSizeGlobal, %zOptionsFile%, Options, fontSize, 10
	IniRead, zAutoCloseGlobal, %zOptionsFile%, Options, autoClose, %A_Space%
	IniRead, zSortItemsGlobal, %zOptionsFile%, Options, sortItems, %A_Space%
	
	;~ delete history sections if history is disabled
	;~ except sections containing starting with *
	If (zHistoryItemLimitGlobal <= 0) {
		Loop, Read, %zHistoryFile%
		{
			RegExMatch(A_LoopReadLine, "U)^\[(.+)\]", match)
			If (match1 && SubStr(match1, 1, 1) != "*")
				IniDelete, %zHistoryFile%, %match1%, history
		}
	}

	zIsRunning := true
}

;~ individual settings (overrides globals)
zSetSettings(zMode) {
	
	WinGet, zActiveId, ID, A
	
	zGUImode := zGUImodeGlobal
	zFontSize := zFontSizeGlobal
	zAutoClose := zAutoCloseGlobal
	zSortItems := zSortItemsGlobal
	
	;~ currently only global is used
	zNoDefault := zNoDefaultGlobal
	zHistoryItemLimit := zHistoryItemLimitGlobal
	
	IfInString, zMode, !sort
		zSortItems := 1
	IfInString, zMode, !nosort
		zSortItems := 0
	
	IfInString, zMode, !autoclose
		zAutoClose := 1
	IfInString, zMode, !noautoclose
		zAutoClose := 0
	
	IfInString, zMode, !guimode1
		zGUImode := 1
	IfInString, zMode, !guimode2
		zGUImode := 2
	IfInString, zMode, !guimode3
		zGUImode := 3
	IfInString, zMode, !guimode4
		zGUImode := 4
	
	IfInString, zMode, !fontsize=
	{
		;~ check if the next one or two characters are integer
		StringGetPos, pos, zMode, !fontsize=
		pos := pos + 11
		
		zNewFontSize := substr(zMode, pos, 2)
		
		if zNewFontSize is not integer
			zNewFontSize := substr(zMode, pos, 1)
		
		StringReplace, zModeGlobal, zModeGlobal, !fontsize=%zNewFontSize%, , All
		
		If zNewFontSize is integer
			zFontSize := zNewFontSize
	}
	
	;~ limit font size range
	If zFontSize < 8
		zFontSize = 8
	
	If zFontSize > 20
		zFontSize = 20

	;~ remove settings strings from section name to save clean to ini
	StringReplace, zModeGlobal, zModeGlobal, !longpress, , All
	StringReplace, zModeGlobal, zModeGlobal, !sort, , All
	StringReplace, zModeGlobal, zModeGlobal, !nosort, , All
	StringReplace, zModeGlobal, zModeGlobal, !singlechar, , All
	StringReplace, zModeGlobal, zModeGlobal, !nohistory, , All
	StringReplace, zModeGlobal, zModeGlobal, !noautoclose, , All
	StringReplace, zModeGlobal, zModeGlobal, !autoclose, , All
	StringReplace, zModeGlobal, zModeGlobal, !guimode1, , All
	StringReplace, zModeGlobal, zModeGlobal, !guimode2, , All
	StringReplace, zModeGlobal, zModeGlobal, !guimode3, , All
	StringReplace, zModeGlobal, zModeGlobal, !guimode4, , All
	StringReplace, zModeGlobal, zModeGlobal, %A_Space%%A_Space%, %A_Space%, All
	Trim(zModeGlobal)

	; load previous caret position if !singlechar
	If (InStr(zUserSettings, "!singlechar") > 0 && zSortItems == 0) {
		IniRead, zGuiCaretPos, %zHistoryFile%, %zModeGlobal%, lastIndex, %A_Space%
	}
	
	zModeHistory := "z" . zModeGlobal . "history"

	;~ If (zHistoryItemLimit > 0) {
		IniRead, zModeHistory, %zHistoryFile%, %zModeGlobal%, history, %A_Space%

		StringMid, firstChar, zModeHistory, 1, 1
		
		If (firstChar == "|") {
			StringTrimLeft, zModeHistory, zModeHistory, 1
		}
	;~ }
}

zAddToHistory(zCurrentValue = "", zPrevValue = "", zFullHistory = "") {

	If GetkeyState("Shift")
		Return

	IfInString, zUserSettings, !nohistory
		Return

	If (zHistoryItemLimit <= 0) {
		Return
	}

	If (zFullHistory) {
		GoSub, SaveHistory
		Return
	}

	If InStr(zUserSettings, "!singlechar") > 0
		isSingleChar := 1

	
	
	If (zPrevValue = "" && zModeHistory != "") {	; set previous value from history if not available
		StringSplit, zLastItem, zModeHistory, |
		zPrevValue := zLastItem1
	}

	If (zPrevValue == zCurrentValue && !isSingleChar) {	; current item is the same as previous one
		Return
	}

	StringGetPos, pos, zModeHistory, %zCurrentValue%|	; find current item in history to disable duplicates

	If (pos == -1) {	; no similar item found

		; check if history limit is reached
		StringReplace Str, zModeHistory, |, |, UseErrorLevel	; count occurences of "|"
		
		If (ErrorLevel >= 0) {
			zHistoryItemCount = %ErrorLevel%
			ErrorLevel = 0
		}
		
		While (zHistoryItemCount >= zHistoryItemLimit) {	; history limit reached

			; remove last item and prepend new
			StringGetPos, zLastItemPos, zModeHistory, |, R2
			StringLeft, zModeHistory, zModeHistory, % zLastItemPos + 1

			zHistoryItemCount := zHistoryItemCount - 1
		}
			
	} Else {	; remove similar item(s)
		StringReplace zModeHistory, zModeHistory, |%zCurrentValue%, |, All
	}

	zModeHistory := zCurrentValue . "|" . zModeHistory

	StringReplace zModeHistory, zModeHistory, ||, |, All
	
	SaveHistory:

	If (zSortItems) {
		Sort, zModeHistory, U D|
	} else {
		zListMakeUnique(zModeHistory, "|")
	}
	
	IniWrite, %zModeHistory% , %zHistoryFile%, %zModeGlobal%, history

	If (isSingleChar) {
		IniWrite, %zGuiCaretPos%, %zHistoryFile%, %zModeGlobal%, lastIndex
	}

	Return
}

zConvertToAbsolutePath(Path) {

	OriginalWorkingFolder := A_WorkingDir ; remember original working folder

	Path := zExpandEnvVars(Path)

	; Set working folder to base path if specified
	If(Base) {
		SetWorkingDir, %Base%
		If(ErrorLevel) { ; if base path invalid
			SetWorkingDir, %OriginalWorkingFolder%
			Return False
		}
	}

	; Get folder and filename if specified
	If(Path != "") {
		Attributes := FileExist(Path) ; get attributes of file/folder
		If(!Attributes) { ; if file/folder does not exist
			SetWorkingDir, %OriginalWorkingFolder%
			Return False
		}

		If(InStr(Attributes, "D")) ; if path is folder
			Folder := Path
		Else
			SplitPath, Path, Filename, Folder ; get folder and filename separately
	}

	; Set working folder to folder if specified
	If(Folder) {
		SetWorkingDir, %Folder%
		If(ErrorLevel) { ; if path invalid
			SetWorkingDir, %OriginalWorkingFolder%
			Return False
		}
	}

	; Get absolute path
	Path := A_WorkingDir . (SubStr(A_WorkingDir, StrLen(A_WorkingDir), 1) = "\" ? "" : "\") . (Filename ? Filename : "")
	StringReplace, Path, Path, /, \, 1
	
	SetWorkingDir, %OriginalWorkingFolder%
	
	Return %Path%
}

zGetBrowser(zBrowser) {
	
	If (zBrowser == "Default") {
		IniRead, zBrowser, %zOptionsFile%, Browsers, Default, %A_Space%
	}
	
	IniRead, zBrowser, %zOptionsFile%, Browsers, %zBrowser%, %A_Space%

	If (zBrowser != "") {
		zBrowser := zConvertToAbsolutePath(zBrowser)
	}
	
	Return %zBrowser%
}

zThousandsSep(x, sep) {
	If (sep == "space") {
		sep := A_Space
	}
	Return, RegExReplace(x, "(?<=[0-9])(?=(?:[0-9]{3})+(?![0-9]))", sep)
}

zExpandEnvVars(ppath) {
	VarSetCapacity(dest, 2000) 
	DllCall("ExpandEnvironmentStrings", "str", ppath, "str", dest, int, 1999, "Cdecl int") 
	Return dest
}

zUriEncode(Uri, Enc = "UTF-8") {
	zStrPutVar(Uri, Var, Enc)
	f := A_FormatInteger
	SetFormat, IntegerFast, H
	Loop
	{
		Code := NumGet(Var, A_Index - 1, "UChar")
		If (!Code)
			Break
		If (Code >= 0x30 && Code <= 0x39 ; 0-9
			|| Code >= 0x41 && Code <= 0x5A ; A-Z
			|| Code >= 0x61 && Code <= 0x7A) ; a-z
			Res .= Chr(Code)
		Else
			Res .= "%" . SubStr(Code + 0x100, -1)
	}
	SetFormat, IntegerFast, %f%
	Return, Res
}

zUriDecode(Uri, Enc = "UTF-8") {
	Pos := 1
	Loop
	{
		Pos := RegExMatch(Uri, "i)(?:%[\da-f]{2})+", Code, Pos++)
		If (Pos = 0)
			Break
		VarSetCapacity(Var, StrLen(Code) // 3, 0)
		StringTrimLeft, Code, Code, 1
		Loop, Parse, Code, `%
			NumPut("0x" . A_LoopField, Var, A_Index - 1, "UChar")
		StringReplace, Uri, Uri, `%%Code%, % StrGet(&Var, Enc), All
	}
	Return, Uri
}

zStrPutVar(Str, ByRef Var, Enc = "") {
	Len := StrPut(Str, Enc) * (Enc = "UTF-16" || Enc = "CP1200" ? 2 : 1)
	VarSetCapacity(Var, Len, 0)
	Return, StrPut(Str, &Var, Enc)
}


zDatePickerGUI()  {

	Global zDatePicker

	Gui, Font, s%zFontSize%, Segoe UI
	Gui, Add, MonthCal, W-2 R-1 Multi 4 8 vzDatePicker
	Gui, Add, Button, Default w120, &Insert Date
	Gui, +AlwaysOnTop -MinimizeBox -MaximizeBox
	Gui, Margin, 16 16
	Gui, Show, xCenter yCenter AutoSize, Pick a date

	Gui, +LastFound
	zGuiHWND := WinExist()

	WinWaitClose, ahk_id %zGuiHWND%

	Return ReturnCode

	ButtonInsertDate:
	 	GuiControlGet, ReturnCode, , zDatePicker
		Gui, Destroy
		Return ReturnCode

	GuiEscape:
	GuiClose:
		ReturnCode = -1
		Gui, Destroy
		Return
}

zComboBoxGUI(zTitle = "", zDefaultValue = "") {

	Global zComboBox

	ReturnCode := "-1"

	SetControlDelay, -1

	isListHidden := true

	IfWinExist ahk_id %zGuiHWND%
	{
		Return
	}
	
	If zGUImode in 3,4
		zOKButtonVisibility := "Hidden"

	If zGUImode in 1,3,4
		zActionButtonsVisibility := "Hidden"

	If zGUImode in 2,4	; set height of the list
	{
		zComboBoxHeight := "r10 Simple"

		StringReplace Str, zModeHistory, |, |, UseErrorLevel	; count occurences of "|"

		If ErrorLevel between 0 and 5
			zComboBoxHeight := "r5 Simple"
		Else If ErrorLevel > 20
			zComboBoxHeight := "r20 Simple"
		Else
			zComboBoxHeight := "r" . ErrorLevel . " Simple"
		ErrorLevel = 0
	}

	If (zTitle == "") {
		zTitle := "Enter value"
	}

	If (zModeHistory != "z" . zModeGlobal . "history")
		zDefaults := zModeHistory

	If (zNoDefault != 1) {	; enable first value pre-filled
		zChoose := "Choose1"
	}

	Gui, 4: Default
	
	zWidth := zFontSize * 30
	zButtonWidth := zFontSize * 5
	zButtonHeight := zFontSize * 2.66
	zXOffset := zWidth * 1.08
	zYOffset := zFontSize * 2.75
	
	If (zSortItems = 1) {
		zSortItems := "Sort"
	}

	Gui, Font, s%zFontSize%, Segoe UI
	Gui, Add, ComboBox, vzComboBox w%zWidth% xm-4 ym+1 %zChoose% %zComboBoxHeight% section %zSortItems% gzAutoComplete, %zDefaults%
	Gui, Add, Button, Default w%zButtonWidth% h%zButtonHeight% x%zXOffset% ym %zOkButtonVisibility% section, OK
	Gui, Font, s%zFontSize%, github-octicons
	Gui, Add, Button, section w%zButtonWidth% h%zButtonHeight% x%zXOffset% ys+%zYOffset% gAddItemButton %zActionButtonsVisibility%, % chrhex("f05d")
	Gui, Add, Button, section w%zButtonWidth% h%zButtonHeight% x%zXOffset% ys+%zYOffset% gRemoveItemButton %zActionButtonsVisibility%, % chrhex("f0ca")
	Gui, +AlwaysOnTop -MinimizeBox -MaximizeBox
	;~ Gui, Margin, 8, 6
	Gui, +ToolWindow

	If zGUImode in 3,4
	{
		Gui, Color, EEAA99
		Gui, -Caption
		Gui +LastFound
		WinSet, TransColor, EEAA99
	}
	
	Gui, Show, xCenter yCenter AutoSize, %zTitle% - ClipJump

	Gui, +LastFound
	zGuiHWND := WinExist()
	
	If (zAutoClose == 1) {
		SetTimer, GuiTimer
	}

	WinWaitActive, ahk_id %zGuiHWND%

	WinActivate, ahk_id %zGuiHWND%

	; set default value if exists
	If (zModeHistory == "") {
		ControlSetText, Edit1, %zDefaultValue%, ahk_id %zGuiHWND%
		ControlSend, Edit1, ^a, ahk_id %zGuiHWND%
	}

	; restore caret position if !singlechar
	If (InStr(zUserSettings, "!singlechar") > 0 && zGuiCaretPos > 0) {
		SetKeyDelay, -1, 0
		ControlSend, Edit1, {HOME}{Right %zGuiCaretPos%}, ahk_id %zGuiHWND%
	}
	zGuiCaretPos := ""
	
	If zGUImode in 1,3
	{
		Hotkey, ~Down, DownKey, On
	}

	Hotkey, ~Enter, EnterKey, On
	Hotkey, ^NumpadSub ,RemoveItemKey, On
	Hotkey, ^Del, RemoveItemKey, On
	Hotkey, ^NumpadAdd, AddItemKey, On
	Hotkey, ~Left, LeftKey, On
	Hotkey, ~Right, RightKey, On
	Hotkey, ~+Left Up, GetSelection, On
	Hotkey, ~+Right Up, GetSelection, On
	Hotkey, ~LButton, LButtonClick, On
	Hotkey, ^Insert, AddItemKey, On
	Hotkey, ^a, SelectAllKey, On
	
	WinWaitClose, ahk_id %zGuiHWND%

	isListHidden := true

	Hotkey, Down, DownKey, Off
	Hotkey, Esc, EscKey, Off
	Hotkey, Enter, EnterKey, Off
	Hotkey, ^NumpadSub, RemoveItemKey, Off
	Hotkey, ^NumpadAdd, AddItemKey, Off
	Hotkey, Left, LeftKey, Off
	Hotkey, Right, RightKey, Off
	Hotkey, +Left Up, GetSelection, Off
	Hotkey, +Right Up, GetSelection, Off
	Hotkey, LButton, LButtonClick, Off
	Hotkey, ^Del, RemoveItemKey, Off
	Hotkey, ^Insert, AddItemKey, Off
	Hotkey, ^a, SelectAllKey, Off

	Return ReturnCode
	
	GuiTimer:
	  IfWinNotActive ahk_id %zGuiHWND%
	  {
		WinClose, ahk_id %zGuiHWND%
		SetTimer, GuiTimer, Off
	  }
	  Return
	  
	GetCaretPos:
		IfWinActive, ahk_id %zGuiHWND%
		{
			zGuiCaretPos := % _Edit_CaretGetPos("Edit1", ahk_id %zGuiHWND%)
			
		}
		return

	GetSelection:
		zDisableGetSelection := false
		IfWinActive, ahk_id %zGuiHWND%
		{
			ControlGet, zGuiSelection, Selected, , Edit1
		}
		Return

	LButtonClick:
		GoSub, GetCaretPos
		Sleep, 100	; wait to capture proper caret position
		;GoSub, GetSelection
		Return

	RightKey:
		IfWinActive, ahk_id %zGuiHWND%
		{
			SendInput {Right}
			GoSub GetCaretPos
		}
		Return
	
	LeftKey:
		IfWinActive, ahk_id %zGuiHWND%
		{
			SendInput {Left}
			GoSub GetCaretPos
		}
		Return

	DownKey:
		IfWinActive, ahk_id %zGuiHWND%
		{
			If (isListHidden) {
				SendInput !{Down}
				isListHidden := false
			} Else {
				SendInput {Down}
				Hotkey, Esc, EscKey, On
			}
		} Else {
			IfWinExist, ahk_id %zGuiHWND%
			SendInput {Down}
		}
		Return

	AddItemKey:
		IfWinActive, ahk_id %zGuiHWND%
		{
			ControlClick, Button2, ahk_id %zGuiHWND%
			ControlFocus, Edit1, ahk_id %zGuiHWND%
		}
		Return
	
	RemoveItemKey:
		IfWinActive, ahk_id %zGuiHWND%
		{
			ControlClick, Button3, ahk_id %zGuiHWND%
		}
		Return
		
	SelectAllKey:
		IfWinActive, ahk_id %zGuiHWND%
		{
			ControlSend, Edit1, {HOME}+{END}, ahk_id %zGuiHWND%
		}
		else
		{
			Hotkey, ^a, SelectAllKey, Off
			Send, {ctrl down}a{ctrl up}
			Hotkey, ^a,SelectAllKey, On
		}
		Return

	EscKey:
		IfWinActive, ahk_id %zGuiHWND%
		{
			If (!isListHidden) {
				isListHidden := true
				Hotkey, Esc, EscKey, Off
			}
		} Else {
			IfWinExist, ahk_id %zGuiHWND%
			SendInput, {Esc}
		}
		Return
	
	EnterKey:
		;Sleep, 50
		;IfWinActive, ahk_id %zGuiHWND%
		;{

			GoSub GetCaretPos
		
			If (!zDisableGetSelection) {
				GoSub, GetSelection
			}
			If (!isListHidden) {
				SendInput {Enter}
			}
		;}
		Return

	zAutoComplete:
		If A_GuiControlEvent = DoubleClick
		{
			GoSub 4ButtonOK
		}
		AutoComplete(A_GuiControl)
		Return

	AddItemButton:
		Gui, Submit, NoHide
		ControlGetText, currentItem, Edit1, ahk_id %zGuiHWND%

		If !currentItem
			Return

		; check if last item is the same as current
		StringGetPos, pos, zModeHistory, %currentItem%|

		If pos == 0
			Return
		
		zAddToHistory(currentItem)
		GuiControl,, zComboBox, |%zModeHistory%	; add to list combobox
		ControlSetText, Edit1, %currentItem%, ahk_id %zGuiHWND%
		ControlSend, Edit1, +{HOME}, ahk_id %zGuiHWND%
		
		Return

	RemoveItemButton:
		Gui, Submit, NoHide

		ControlGetText, currentItem, Edit1, ahk_id %zGuiHWND%

		Temp =
		Loop, Parse, zModeHistory, |
		{
			If !A_LoopField Or (A_LoopField == currentItem)
				Continue

			Temp .= "|" . A_LoopField
		}

		If (InStr(Temp, "|") = 1)
			Temp := SubStr(Temp, 2)

		zModeHistory := Temp . "|"
		
		GuiControl,, zComboBox, |%zModeHistory%	; update combobox
		ControlSend, Edit1, {Down}, ahk_id %zGuiHWND%
		ControlFocus, Edit1, ahk_id %zGuiHWND%
		Sleep, 100
		GoSub zAutoComplete

		zAddToHistory(, , zModeHistory)

		Return

	4ButtonOK:
	
		GuiControlGet, ReturnCode, , zComboBox
		
		;~ save original to add to history instead of filtered one
		zOriginalInput := ReturnCode
		
		;If (zGuiSelection == "") {
		;	zGuiSelection := ReturnCode
		;}
		
		; get the character next to caret position
		If (InStr(zUserSettings, "!singlechar") > 0) {

			;~ fix 1 offset on last item
			;If (StrLen(ReturnCode) > zGuiCaretPos) {
			;	zGuiCaretPos := zGuiCaretPos + 1
			;}
			
			ReturnCode := substr(ReturnCode, zGuiCaretPos + 1, 1)

			; get last character if nothing is selected
			If (ReturnCode == "") {
				zGuiCaretPos := StrLen(zOriginalInput)
				StringRight, ReturnCode, zOriginalInput, 1
			}
			;test!
			;zGuiCaretPos := ""
		}
		
		; paste/return selection only
		;If (InStr(zUserSettings, "!selection") > 0) {
		;If (InStr(zUserSettings, "!singlechar") == 0) {
			;ReturnCode := zGuiSelection
			;zGuiSelection := ""
		;}
		
		Gui, Destroy
		Return ReturnCode

	4GuiEscape:
	4GuiClose:
		ReturnCode = -1
		Gui, Destroy
		Return
}

; daorc @ http://www.autohotkey.com/board/topic/19165-smart-comboboxes/
AutoComplete(ctrl) { 

   static lf = "`n"

  	 If GetKeyState("Delete") or GetKeyState("Backspace") or GetKeyState("Down") or GetKeyState("Up")
      	Return

    zDisableGetSelection := true

	SendMode, Input
	SetControlDelay, -1, 0
	SetKeyDelay, -1, 0
	
	GuiControlGet, h, Hwnd, %ctrl%
	ControlGet, haystack, List, , , ahk_id %h% 
	GuiControlGet, needle, , %ctrl%
	StringMid, text, haystack, pos := InStr(lf . haystack, lf . needle) 
	  , InStr(haystack . lf, lf, false, pos) - pos 
	If text !=
	{
      if pos > 0
      { 
		GuiControl, ChooseString, zComboBox, %text%
         ControlSetText, , %text%, ahk_id %h%
         If (StrLen(needle) == StrLen(text)) {
			ControlSend, , % "{End}", ahk_id %h%
         } Else {
			ControlSend, , % "{END}+{Left " . StrLen(text) - StrLen(needle) . "}", ahk_id %h%
         }
      }
   }
   Return
} 

zGetSelectedText() {

	tmp = %ClipboardAll%
	Clipboard := ""
	;Send, ^c
	Send, {ctrl down}c{ctrl up}
	ClipWait, 1
	If (ErrorLevel == 0) {
		selection = %Clipboard%
	}
	Clipboard = %tmp%
	selection := (selection = "") ? "" : selection
	
	Return %selection%
}

zListMakeUnique( byref List, Delimiter="`n", Case_Sensitive=0 ) {
; By [VxE], removes duplicate entries from a list. Special thanks to SKAN.
; The return value is true if the list was changed by this function, false otherwise.
	VarSetCapacity( New_List, StrLen( List ) )
	New_List .= Delimiter
	Loop, parse, List, % Delimiter
		If !InStr( New_List, Delimiter . A_LoopField . Delimiter, !!Case_Sensitive )
			New_List .= A_LoopField . Delimiter
	Return (List . "") != List := SubStr( New_List, 2, -1 )
}

; Gets the current caret position (zero-based) of an edit control having input focus
_Edit_CaretGetPos(editNNHavingFocus, wintitle)
{
    ControlGetFocus, focusedControl, %wintitle%
    if (focusedControl = editNNHavingFocus)
    {
        ControlGet, hEdit, hwnd, , %editNNHavingFocus%, %wintitle%
        ControlGetPos, editX, editY, editW, editH, %editNNHavingFocus%, %wintitle%
        CoordMode, Caret, Window
        _EM_CHARFROMPOS(hEdit, A_CaretX - editX, A_CaretY - editY, charPos, line)
    }
    else
        charPos := ""
    return charPos
}

; Gets information about the character closest to a specified point in the client area of an edit control.
; http://ahkscript.org/boards/viewtopic.php?f=5&t=4826&p=27883#p27857 by user "just me"
_EM_CHARFROMPOS(HWND, X, Y, ByRef CharPos, ByRef Line) {
   ; _EM_CHARFROMPOS = 0x00D7 -> msdn.microsoft.com/en-us/library/bb761566(v=vs.85).aspx
   CharPos := Line := 0
   CharLine := DllCall("User32.dll\SendMessage", "Ptr", HWND, "UInt", 0x00D7, "Ptr", 0, "UInt", (Y << 16) | X, "Ptr")
   CharPos := (CharLine & 0xFFFF)
   Line := (CharLine >> 16)
   Return True
}

zClipCalc(zWithInput = false, zInput = "", zEchoResult = true, zFormat = 0.2) {

	SetFormat, float, %zFormat%

	text = % (zInput == "") ? zGetSelectedText() : zInput

	zExpression := ""

	If (SubStr(zInput, 0) == "=") {
		StringTrimRight, text, text, 1
		zWithInput = true
	}
	
	If (zWithInput) {
		zExpression = % text . " = "
	}

	zResult = % zExpression . zEval(text)
	
	If (zEchoResult) {
		SendInput {Raw}%zResult%
		return
	}

	return zResult
}

; AHK 1.0.46+
; evaluate arithmetic expressions containing
; unary +,- (-2*3; +3)
; +,-,*,/,\(or % = mod); **(or @ = power)
; (..); var (pi, e); abs(),sqrt(),floor()
; http://bit.ly/1ymisFN

; MsgBox % zEval("-floor(abs(sqrt(1))) * (+pi -((3%5))) +pi+ 2-1-1 + e-abs(sqrt(floor(2)))**2-e") ; 1

zEval(x) {                              ; expression preprocessing
   Static pi = 3.141592653589793, e = 2.718281828459045

   StringReplace x, x,`%, \, All       ; % -> \ for MOD
   x := RegExReplace(x,"\s*")          ; remove whitespace
   x := RegExReplace(x,"([a-zA-Z]\w*)([^\w\(]|$)","%$1%$2") ; var -> %var%
   Transform x, Deref, %x%             ; dereference all %var%

   StringReplace x, x, -, #, All       ; # = subtraction
   StringReplace x, x, (#, (0#, All    ; (-x -> (0-x
   If (Asc(x) = Asc("#"))
      x = 0%x%                         ; leading -x -> 0-x
   StringReplace x, x, (+, (, All      ; (+x -> (x
   If (Asc(x) = Asc("+"))
      StringTrimLeft x, x, 1           ; leading +x -> x
   StringReplace x, x, **, @, All      ; ** -> @ for easier process

   Loop {                              ; find innermost (..)
      If !RegExMatch(x, "(.*)\(([^\(\)]*)\)(.*)", y)
         Break
      x := y1 . zEval@(y2) . y3         ; replace "(x)" with value of x
   }
   Return zEval@(x)                     ; no more (..)
}

zEval@(x) {
   RegExMatch(x, "(.*)(\+|\#)(.*)", y) ; execute rightmost +- operator
   IfEqual y2,+,  Return zEval@(y1) + zEval@(y3)
   IfEqual y2,#,  Return zEval@(y1) - zEval@(y3)
                                       ; execute rightmost */% operator
   RegExMatch(x, "(.*)(\*|\/|\\)(.*)", y)
   IfEqual y2,*,  Return zEval@(y1) * zEval@(y3)
   IfEqual y2,/,  Return zEval@(y1) / zEval@(y3)
   IfEqual y2,\,  Return Mod(zEval@(y1),zEval@(y3))
                                       ; execute rightmost power
   StringGetPos i, x, @, R
   IfGreaterOrEqual i,0, Return zEval@(SubStr(x,1,i)) ** zEval@(SubStr(x,2+i))
                                       ; execute rightmost function
   If !RegExMatch(x,".*(abs|floor|sqrt)(.*)", y)
      Return x                         ; no more function
   IfEqual y1,abs,  Return abs(zEval@(y2))
   IfEqual y1,floor,Return floor(zEval@(y2))
   IfEqual y1,sqrt, Return sqrt(zEval@(y2))
}

LongPress(timeout = 500) {
	
	
	
	key = %A_ThisLabel%
	StringReplace, zCurrentKey, key, $, , All
	StringReplace, zCurrentKey, zCurrentKey, ^, , All
	StringReplace, zCurrentKey, zCurrentKey, ~, , All
	StringReplace, zCurrentKey, zCurrentKey, +, , All
	StringReplace, zCurrentKey, zCurrentKey, !, , All
	StringReplace, zCurrentKey, zCurrentKey, #, , All
	
	If timeout < 500
		timeout = 500
	
	If timeout > 3000
		timeout = 3000
	
	SetKeyDelay, %timeout%
	
	zKeyWaitTimeout := "T" . timeout / 1000
	
	Keywait, %zCurrentKey%, %zKeyWaitTimeout%
	
	If (GetKeyState(zCurrentKey, "P")) {
		Return true
	} Else {
		Send, {%zCurrentKey%}
	}
	
	Return false
}
