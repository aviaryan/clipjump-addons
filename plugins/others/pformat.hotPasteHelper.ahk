;@Plugin-Name HotPasteHelper
;@Plugin-Description Paste Text with variable expansion. Requires HotPasteHelper plugin.
;@Plugin-Author tpr
;@Plugin-Tags pformat
;@Plugin-version 0.1
;@Plugin-Previewable 0

;@Plugin-param1 Text with optional expandable variables, eg. "Hello __?Enter something__!"

plugin_pformat_hotpastehelper(zin) {

	If (!zin) {
		return
	}

	If (!zModeGlobal) {	; only use PFORMAT if zMode is not available
		zHistorySection := "PFORMAT"
	} else {
		zHistorySection := "PFORMAT_" . zModeGlobal
	}

	zEchoResult := 1

	If Strlen(zin) > 2000
		return zin

	zOut := plugin_hotPasteHelper(zHistorySection, zin, 0, %zEchoResult%)
	
	STORE.ClipboardChanged := 1
	return zOut
}
