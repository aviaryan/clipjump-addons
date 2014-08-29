;@Plugin-Name Export Channel
;@Plugin-Description Exports a channel to text file or binary format, you choose
;@Plugin-Author Avi
;@Plugin-Tags export channel
;@Plugin-Silent 1

;@Plugin-param3 Export type = 1 for text , 0 for binary

plugin_exportchannel(zChosenChannel="", zFolder="", zExportType=""){
	zChosenChannel := zChosenChannel="" ? choosechannelgui() : zChosenChannel
	if (zChosenChannel=="")
		return
	if zFolder=
		FileSelectFolder, zFolder, % A_ScriptDir,, The folder will contain clip files
	if !zFolder
		return
	; get export type
	if zExportType=
		MsgBox, 35, Choose Export type, Do you want to export channel as text files ?`nYes = Text files`nNo = Binary format
	IfMsgBox, Yes
		zExportType := 1
	IfMsgBox, No
		zExportType := 0

	zChInfo := API.getchInfo(zChosenChannel)
	; export
	If zExportType=1
	{
		loop % zChInfo.realCURSAVE
		{
			if CDS[zChosenChannel].hasKey(A_index)
				FileAppend, % CDS[zChosenChannel][A_index], % zFolder "\" zChInfo.realCURSAVE-A_index+1 ".txt"
		}
	}
	else if zExportType=0
	{
		loop % zChInfo.realCURSAVE
			FileCopy, % "cache\clips" zChInfo.p "\" A_index ".avc" , % zFolder "\" zChInfo.realCURSAVE-A_index+1 ".avc", 1
	}
	else MsgBox, 64, Exported, Channel %zChosenChannel% NOT exported.
}