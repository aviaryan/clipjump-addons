;@Plugin-Name Copy to Channel
;@Plugin-Description Use this plugin to copy the selected item to a particular channel instead of the current active one
;@Plugin-Author Avi
;@Plugin-Tags channel copy

;@Plugin-param1 The Channel name/number to copy into
;@Plugin-param2 What is to be done, 0 = copy, 1 = cut

plugin_copy2channel(zChannel, zWhat){
	if !zWhat
		zSend := "^{vk43}"
	else zSend := "^{vk58}"
	zoc := CN.NG
	znc := channel_find(zChannel)
	changeChannel(znc)
	ONCLIPBOARD := 3 ; any other positive number other than 1
	Send, % zSend

	while ( ONCLIPBOARD != 1 )
		sleep 100
		
	sleep 500
	changeChannel(zoc)
}