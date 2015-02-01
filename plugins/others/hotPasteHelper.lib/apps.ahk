::dc::	; run Double Commander with path on clipboard
	API.runPlugin("hotPasteHelper.ahk", "RUN", "..\Double Commander\doublecmd.exe", "--no-console ""__CLIPBOARD__""")
	return
	
::fw::	; run Adobe Fireworks
	API.runPlugin("hotPasteHelper.ahk", "RUN", "%programfiles%\Adobe\Adobe Fireworks CS6\Fireworks.exe")
	return

::tmp::	; open %TEMP% folder
	API.runPlugin("hotPasteHelper.ahk", "RUN", "%temp%")
	return
