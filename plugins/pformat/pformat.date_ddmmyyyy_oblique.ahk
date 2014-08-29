;@Plugin-Name Date in DD/MM/YYYY
;@Plugin-Description Converts date to format DD/MM/YYYY. Requires lib_extras/DateParse.ahk
;@Plugin-Author Avi
;@Plugin-Tags pformat
;@Plugin-version 0.1

plugin_pformat_date_ddmmyyyy_oblique(zin){
	zCS := getClipboardFormat()
	if (zCS== "[" TXT.TIP_text "]")
	{
		zd := DateParse(zin)
		if zd
			return Substr(zd, 7) "/" Substr(zd, 5, 2) "/" Substr(zd, 1, 4) , STORE.ClipboardChanged := 1
		else return zin
	}
	else return zin
}

#include *i %A_ScriptDir%/lib_extras/DateParse.ahk