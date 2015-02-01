::dcx::	; run Double Commander with path on clipboard
	API.runPlugin("hotPasteHelper.ahk", "RUN", "..\Double Commander\doublecmd.exe", "--no-console ""__CLIPBOARD__""")
	return
	
::fwx::	; run Adobe Fireworks
	API.runPlugin("hotPasteHelper.ahk", "RUN", "%programfiles%\Adobe\Adobe Fireworks CS6\Fireworks.exe")
	return

::tmpx::	; open %TEMP% folder
	API.runPlugin("hotPasteHelper.ahk", "RUN", "%temp%")
	return
