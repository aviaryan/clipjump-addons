; -----------------------------------------------
; WEBSITES
; -----------------------------------------------

:?*:cjx::	; ClipJump website (default browser)
	API.runPlugin("hotPasteHelper.ahk", "NAV", "http://clipjump.sourceforge.net/")
	return

:?*:cjcx::	; ClipJump website (Chrome)
	API.runPlugin("hotPasteHelper.ahk", "NAV", "http://clipjump.sourceforge.net/", "Chrome")
	return

; -----------------------------------------------
; SEARCHES
; -----------------------------------------------

:?*:psx::	; Google Page Speed
	API.runPlugin("hotPasteHelper.ahk", "NAV Google Page Speed", "https://developers.google.com/speed/pagespeed/insights/?url=__?Google Page Speed__")
	return

:?*:wiken::	; Wikipedia
	API.runPlugin("hotPasteHelper.ahk", "NAV Wiki English", "http://wikipedia.org/wiki/__?Wikpedia Search__")
	return

:?*:sox::	; Stack Overflow
	API.runPlugin("hotPasteHelper.ahk", "NAV Stack Overflow", "http://stackoverflow.com/search?q=__?Stack Overflow Search|Find on Stack Overflow...__")
	return

:?*:ahkx::	; AutoHotKey Search
	API.runPlugin("hotPasteHelper.ahk", "NAV AutoHotKey Search", "https://www.google.com/search?q=autohotkey%20__?AutoHotKey Search__")
	return

:?*:ciux::	; Caniuse
	API.runPlugin("hotPasteHelper.ahk", "NAV Can I use...", "http://caniuse.com/#search=__?Can I Use Search__")
	return

$F1::	; Google Translate - selected text to English
	API.runPlugin("hotPasteHelper.ahk", "NAV Google Translate English !longpress", "https://translate.google.com/#auto/en/__SELECTION__")
	return
	
$F3::	; Keyword Search
	API.runPlugin("hotPasteHelper.ahk", "SEARCH !longpress !autoclose")
	Return

$F4::	; Google Translate auto -> EN
	API.runPlugin("hotPasteHelper.ahk", "NAV Google Translate English !longpress", "https://translate.google.com/#auto/en/__?Translate to English__")
	return

$F5::	; Google Translate selected text from autodetect language -> user specified language, eg. "es"
	API.runPlugin("hotPasteHelper.ahk", "NAV Google Translate !longpress", "https://translate.google.com/#auto/__?Google Translate|Target language code...__/__SELECTION__")
	return

$F7::	; W3C Validator
	API.runPlugin("hotPasteHelper.ahk", "NAV W3C Validator !longpress", "http://validator.w3.org/check?uri=__CURRENTURL__&charset=%28detect+automatically%29&doctype=Inline&group=0")
	return

$F8::	; WordPress
	API.runPlugin("hotPasteHelper.ahk", "NAV WordPress !longpress", "https://www.google.com/search?q=wordpress%20__?WordPress Search__")
	return

$F9::	; Processwire
	API.runPlugin("hotPasteHelper.ahk", "NAV Processwire !longpress", "https://www.google.com/search?q=processwire%20__?Processwire Search__")
	return

$F10::	; Google Image
	API.runPlugin("hotPasteHelper.ahk", "NAV Google Image Search !nohistory !longpress", "https://www.google.com/search?site=&tbm=isch&source=hp&biw=1602&bih=791&q=__?Google Image Search|Find images on Google...__")
	return

$F12::	; IconFinder
	API.runPlugin("hotPasteHelper.ahk", "NAV IconFinder !longpress", "https://www.iconfinder.com/search/?q=__?IconFinder Search__&maximum=32&price=free")
	return
