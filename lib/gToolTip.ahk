#include %A_ScriptDir%\lib\gString.ahk

; TODO: implement tooltip bank on base (id: avoid creating tt over an existing one)
;	- a destroy method ?
class gTT {

	static CurrentToolTips := []	

	__New(header := "", posX := 0, posY := 0, id := 1, delay := 0, shownow := False) {
		this.Header := header
		this._x := posX
		this._y := posY
		this._id := id
		this.Delay := delay
		this.Fontmod := ""
		this.Fontname := "Segoe UI"
		this.Fontsize := 10
		this._hideTimerCallback := this._Hide.Bind(this)
		this.base.CurrentToolTips.push(this)
		CoordMode ToolTip, Screen
		this.SetFont()
		if(shownow) {
			this.Show()
		}
	}
	FontSize[]{
		get {
			return this._fontsize
		}
		set {
			this._fontsize := value
			this.UpdateFont()
			return this._fontsize
		}
	}
	Text[] {
		get {
			this._text := ""
			if(this.Header) {
				this._text := this.Header . "`n"
			}
			return this._text := this._text . gs(this.TextLines, "Join", "sp`n")
		}
	}
	Delay[] {
		get {
			return this._delay
		}
		set {
			if(value < 0) {
				value := 0
			}
			return this._delay := value
		}
	}
	SetLine(text := "", line := 1, show := True) {
		if(line <= 0) {
			Return ErrorLevel := -1
		}
		this.TextLines[line] := text
		if(show) {
			this.Show()
		}
	}	
	Show() {
		ToolTip % this.Text, this._x, this._y, this._id
		if(this.Delay) {
			this._StartHideTimer()
		}
	}
	UpdateFont() {
		this._font := this._CreateFont()
		ToolTip % this.Text, this._x, this._y, this._id
		SendMessage, 0x30, % this._font, 1,, ahk_class tooltips_class32
		Return ErrorLevel
	}
	
	_CreateFont() {
		options := "s" . this.Fontsize
		options := options . " " . this.Fontmod		; bold, italic, strike, underline, and norm
		Gui Font, %options%, % this.Fontname
		Gui Add, Text, HwndHidden,
		SendMessage, 0x31,,,, ahk_id %Hidden%
		Return ErrorLevel
	}
	_StartHideTimer() {
		fn := this._hideTimerCallback
		SetTimer %fn%, % this.Delay
	}
	_Hide() {
		fn := this.hideTimerCallback
		SetTimer %fn%, Off
		ToolTip, ,,, this._id
	}
}

GetAhkExeFilename(Default_="AutoHotkey.exe")
{
	AhkExeFilename := Default_
	If (A_AhkPath)
	{
		StringSplit, AhkPathParts, A_AhkPath, \
		Loop, % AhkPathParts0
		{
			IfInString, AhkPathParts%A_Index%, .exe
			{
				AhkExeFilename := AhkPathParts%A_Index%
				Break
			}
		}
	}
	return AhkExeFilename
}
