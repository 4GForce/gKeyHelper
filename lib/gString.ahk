; Wanna be unvariable constants
global _g_JUSTIFYLEFT := "Left"
global _g_JUSTIFYRIGHT := "Right"
global _g_JUSTIFYCENTER := "Center"

; Not a param ... so far =p 
global gDefaultIndentJustify := _g_JUSTIFYLEFT	; Indent ignores justify center
global gDefaultDelimiter := "#"

; Wanna be limited scope accessible variables 0.o ; this should be a structure or something
; default values, overriden by params on each calls, params are method dependent
global gDefaultSize 	:= 50				; sz
global gDefaultJustify := _g_JUSTIFYLEFT	; jl, jc, jr
global gDefaultTrunc 	:= "..."			; tc
global gDefaultWrapper := "(#)"				; wr
global gDefaultPadding := " "				; pd
global gDefaultCashFormat := "$#"			; cf
global gDefaultSeparator := ", "			; sp
global gDefaultIndent := 4					; in
global gDefaultTabs := 1					; tb

gs(obj, params*) {
	commands := {typedCommand: False, arrayCommand: False, stringCommands: []}
	subparams := {}
	
	for i, p in params {
		if(IsFunc("gsr" . p) AND !commands.arrayCommand) {
			commands.arrayCommand := "gsr" . p
		}
		else if(IsFunc("gst" . p) AND !commands.typedCommand) {
			commands.typedCommand := "gst" . p
		}
		else if(IsFunc("gs" . p)) {
			commands.stringCommands.push("gs" . p)
		}
		else {
			attrib := Substr(p, 1, 2)
			value := Substr(p, 3)
			If(attrib) {
				if(value == "") {
					value := True
				}
				subparams[attrib] := value
			}
		}
	}
	isArray := obj.Length()							; not a solid validation =p
	if(isArray) {
		for i, o in obj {
			o := _gRunCommand(commands.typedCommand, o, subparams)
			o := _gRunCommands(commands.stringCommands, o, subparams)
			obj[i] := o
		}
		obj := _gRunCommand(commands.arrayCommand, obj, subparams)
	}
	else {
		obj := _gRunCommand(commands.typedCommand, obj, subparams)
		obj := _gRunCommands(commands.stringCommands, obj, subparams)
	}

	Return obj
}
; those two should only be locally accessed
_gRunCommand(cmd, obj, params) {
	if(cmd) {
		fn := Func(cmd).Bind(obj, params)
		return obj := fn.Call()
	}
	return obj
}
_gRunCommands(cmds, obj, params) {
	for i, cmd in cmds {
		obj := _gRunCommand(cmd, obj, params)
	}
	return obj
}

; ### Typed functions
gstOnOff(bool) {
	return (bool or bool == "1" or bool == "True") ? "On" : "Off"
}
gstTrueFalse(bool) {
	return (bool or bool == "1" or bool == "True") ? "True" : "False"
}
gstCash(value, params) {
	format := params["cf"] ? params["cf"] : gDefaultCashFormat
	value := Round(value, 2)
	return StrReplace(format, gDefaultDelimiter, value)
}
; ### Array functions
gsrJoin(arr, params) {
	separator := params["sp"] ? params["sp"] : gDefaultSeparator
	string := ""
	for i, val in arr {
		if(string) {
			string := string . separator
		}
		string := string . val
	}
	Return string
}
; ### String functions
gsWrap(string, params) {
	wrapper := params["wr"] ? params["wr"] : gDefaultWrapper
	return StrReplace(wrapper, gDefaultDelimiter, string)
}
gsFit(string, params) {
	size := params["sz"] ? params["sz"] : gDefaultSize
	justify := params["jr"] ? _g_JUSTIFYRIGHT : params["jc"] ? _g_JUSTIFYCENTER : params["jl"] ? _g_JUSTIFYLEFT : gDefaultJustify
	trunc := params["tc"] ? params["tc"] : gDefaultTrunc
	padding := params["pd"] ? params["pd"] : gDefaultPadding
	
	len := StrLen(string)
	if (len > size) {
		string := Substr(string, 1, (size-StrLen(trunc))) . trunc
	}
	else if (len < size) {
		miss := size - len		
		if(justify == _g_JUSTIFYCENTER) {
			isOdd := Mod(miss, 2)
			miss := Floor(miss / 2)
		}
		pad := ""
		loop %miss% {
			pad := pad . padding
		}
		if(justify == _g_JUSTIFYCENTER) {
			string := pad . string . pad
			if(isOdd) {
				string := string . padding
			}
		}
		else if(justify == _g_JUSTIFYRIGHT) {
			string := pad . string 
		}
		else {
			string := string . pad
		}
	}
	Return string
}
; gDefaultJustify is predominant over gDefaultIndentJustify
; justify center reverts to gDefaultIndentJustify	(basically this allows Indent and Fit to be called with different justify)
gsIndent(string, params) {
	indents := params["in"] ? params["in"] : gDefaultIndent	
	padding := params["pd"] ? params["pd"] : gDefaultPadding
	justify := params["jr"] ? _g_JUSTIFYRIGHT : params["jl"] ? _g_JUSTIFYLEFT : gDefaultJustify
	if(justify == _g_JUSTIFYCENTER) {	
		justify := gDefaultIndentJustify
	}
	pad := _gsRepeatPtrn(padding, indents)
	if(justify == _g_JUSTIFYLEFT) {
		string := pad . string
	}
	else if(justify == _g_JUSTIFYRIGHT){
		string := string . pad
	}
	
	Return string
}
; inserts tabs using 'tb' param as 'in' for gsIndent with reverse default justify unless specified
; sounds weird, but makes sense and can be very usefull
; ignores justify center
; TODO: check gDefaultIndentJustify
gsTab(string, params) {	
	tabs := params["tb"] ? params["tb"] : gDefaultTabs
	justify := params["jr"] ? _g_JUSTIFYRIGHT : params["jl"] ? _g_JUSTIFYLEFT : False
	if(!justify) {	
		if(gDefaultJustify == _g_JUSTIFYLEFT OR gDefaultJustify == _g_JUSTIFYCENTER) {
			params["jr"] := True
		}
		else {
			params["jl"] := True
		}
	}	
	params["in"] := tabs
	params["pd"] := "`t"
	return string := gsIndent(string, params)
}

; ### Base Utilities
_gsRepeatPtrn(ptrn, times) {
	str := ""
	loop %times% {
		str := str . ptrn
	}
	return str
}


