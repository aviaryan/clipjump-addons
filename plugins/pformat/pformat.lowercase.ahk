;@Plugin-Name lowercase
;@Plugin-Description Paste Text in total lowercase
;@Plugin-Author Avi
;@Plugin-Tags pformat
;@Plugin-Previewable 1

;@Plugin-param1 Text to convert in Lower case

plugin_pformat_lowercase(zin){
	zCS := getClipboardFormat()
	if (zCS== "[" TXT.TIP_text "]")
	{
		StringLower, zout, zin
		STORE.ClipboardChanged := 1
		return zout
	}
	else return zin
}