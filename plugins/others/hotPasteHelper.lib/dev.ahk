; -----------------------------------------------
; HTML
; -----------------------------------------------
^Tab::	; surround selection with html tag on ctrl+TAB
	API.runPlugin("hotPasteHelper.ahk", "", "<__?Enter tag__>__SELECTION__</__?LAST__>")
	return

; -----------------------------------------------
; PHP
; -----------------------------------------------
:*?:hdoc::
	API.runPlugin("hotPasteHelper.ahk", "PHP Heredoc", "<<< __?Heredoc tag__`r`r__?LAST__;")
	SendInput {Up}
	SendInput {Tab}
	return

::pp::
:*:ppp::
	API.PasteText("<?php  ?>")
	SendInput {LEFT 3}
	return

:*:ppb::
	API.PasteText("<?php?>")
	SendInput {Left 2}
	SendInput {ENTER 2}
	SendInput {UP}
	return

:*:pps::
	API.PasteText("<?php ")
	return

:*:ppe::
	API.PasteText(" ?>")
	return

::phe::
	API.PasteText("<?php echo ''; ?>")
	SendInput {LEFT 5}
	return

:*:ppr::
	API.PasteText("print_r();")
	SendInput {LEFT 2}
	return

::pprr::
	API.PasteText("<?php print_r(); ?>")
	SendInput {LEFT 4}
	return

::qt::
	API.runPlugin("hotPasteHelper.ahk", "qTrans", "[:hu][:en][:de]")
	SendInput {LEFT 10}
	return

::qtt::
	API.runPlugin("hotPasteHelper.ahk", "qTrans", "[:hu]__?Hungarian__[:en]__?English__[:de]__?German__")
	return

::qtx::
	API.PasteText("<!--:hu--><!--:--><!--:en--><!--:--><!--:de--><!--:-->")
	SendInput {LEFT 44}
	return

::vard::
	API.PasteText("echo '<pre>'; var_dump(); echo '</pre>';")
	SendInput {LEFT 17}
	return

; -----------------------------------------------
; WORDPRESS
; -----------------------------------------------
::wpbi::
	API.PasteText("<?php bloginfo(''); ?>")
	SendInput {LEFT 6}
	return

:*:wpif::
	API.PasteText("<?php if () { ?>")
	SendInput {LEFT 6}
	return

:*:wpe::
	API.PasteText("<?php } ?>")
	return

; -----------------------------------------------
; PUREBASIC
; -----------------------------------------------
::msb::
::mbox::
	API.PasteText("MessageBox_(0, , BaseName, 0)")
	SendInput {LEFT 14}
	return	

; -----------------------------------------------
; JAVASCRIPT
; -----------------------------------------------
::cl::
	API.PasteText("console.log();")
	SendInput {LEFT 2}
	return	

; -----------------------------------------------
; AUTOHOTKEY
; -----------------------------------------------
:*:mbb::
	API.PasteText("MsgBox, % ")
	return

; -----------------------------------------------
; CSS
; -----------------------------------------------
::rb::
::rgbab::
	API.PasteText("rgba(0, 0, 0, 0.5);")
	return

::rw::
::rgbaw::
	API.PasteText("rgba(255, 255, 255, 0.8);")
	return

:*:pdd::
	API.PasteText("Paqart Design Kft.")
	return

::brad::
	API.runPlugin("hotPasteHelper.ahk", "CSS border-radius", "border-radius: __?Border-radius|4__px;")
	return

::transi::
	API.runPlugin("hotPasteHelper.ahk", "CSS transition !guimode4", "-webkit-transition: __?Transition|all 0.2s__;`rtransition: __?LAST__;")
	return

::transf::
	API.runPlugin("hotPasteHelper.ahk", "CSS transform", "-webkit-transform: __?Transition|scale(1.1)__;`rtransform: __?LAST__;")
	return
