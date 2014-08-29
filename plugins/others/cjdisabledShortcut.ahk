;@Plugin-Name CJ Disabled Shortcut
;@Plugin-Description It can be used to create a shortcut that presses another shortcut after disabling Clipjump clipboard capturing feature. 
;@Plugin-Description Use it to wrap shortcuts that use clipboard for data transfer. Example are Evernote, OneNote and CintaNotes clip text features.
;@Plugin-Author Avi
;@Plugin-Version 0.1
;@Plugin-Tags disable clipboard evernote onenote clip

;@Plugin-param1 The shortcut to spam when this plugin runs. eg > "Ctrl+F12"
;@Plugin-param2 The time to wait before re-enabling Clipjump. Default is 1.2 secs.

plugin_cjdisabledShortcut(zShortcut, zSleep=1200){
	API.blockMonitoring(1)
	Send % Hparse(zShortcut, 1, 1, 1)
	sleep % zSleep
	API.blockMonitoring(0)
}