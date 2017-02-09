#include %A_ScriptDir%\lib\gToolTip.ahk
#include %A_ScriptDir%\lib\gRunner.ahk

/*
;
;	gKeyHelper(mode, boundkey, actions [, repeatdelay := 200, showtooltip := True ])
;
;
;			
;			 ┌────── CycleMode
;			 │┌───── RepeatMode
;		 	 ││┌──── ActionMode
;       	 │││
; Mode :  0x0000
;
; CycleMode	0: Action1 On / Action1 Off / Action2 On ...
; CycleMode 1: Action1 On / Action2 On ...
;
; RepeatMode 0:	Disabled
; RepeatMode 1: Repeat actions at specified repeatdelay
;
; ActionMode 0:	SendMode <send % action>
; ActionMode 1:	GosubMode <gosub % action>
;
;
;	accesssible values of interest:		( could be used as a stopwatch )
;		nbKeyEvents
;		nbPerformedActions
;		nbCurrentRunners
;		Key
;
;		SetMode		; untested dynamically
;
;
;
;	TODO: 	Suspend key
;			Suspend all
;			Make monitor/tooltip stand alone ... kind off
*/

class gKeyHelper {

	static BoundKeys := []
	static ShowToolTip := False
	static _Tooltip :=
	
	__New(mode, boundkey, actions, repeatdelay := 200, showtooltip := True) {
		this.SetMode(mode)
		this.Key := boundkey
		this.Actions := actions
		this.RepeatDelay := repeatdelay
		this._init()
		this.base.BoundKeys.push(this)
		this.base.ShowToolTip := showtooltip
		gRunner.Init()
	}
	_init() {
		this.State := False
		this.CurrentActionIndex := 1
		this.nbKeyEvent := 0
		this.nbPerformedActions := 0
		this.nbCurrentRunners := 0
	}
	Key[]{
		get {
			return this._key
		}
		set {	; need key validation here
			this._key := value
			fn := this.KeyEvent.Bind(this)
			Hotkey %value%, %fn%
		}
	}
	State[]{
		get {
			return this._state
		}
		set {
			this._state := value
			this.Updated()
			return this._state
		}
	}
	nbCurrentRunners[]{
		get {
			return this._nbCurrentRunners
		}
		set {
			this._nbCurrentRunners := value
			this.Updated()
			return this._nbCurrentRunners
		}
	}
	; I know, I could use binary but this way new settings for each modes can be created
	SetMode(mode) {
		this.CycleMode := False
		this.ActionMode := False
		this.RepeatMode := False
		if((mode & 0x0001) > 0) {
			this.ActionMode := True
		}
		if((mode & 0x0010) > 0) {
			this.RepeatMode := True
		}
		if((mode & 0x0100) > 0) {
			this.CycleMode := True
		}
	}
	CycleActionIndex() {
		this.CurrentActionIndex := Mod(this.CurrentActionIndex, this.Actions.Length()) + 1	
	}
	KeyEvent() {
		this.nbKeyEvent++
		this.CurrentAction := this.Actions[this.CurrentActionIndex]
		; bad logic here, could improve
		if(!this.CycleMode AND this.State) {			; turn off
			this.ToggleState()
			this.CycleActionIndex()
			Return
		}
		else if(!this.CycleMode AND !this.State) {		; turn on
			this.ToggleState()
			this.StartAction(this.CurrentAction)
			Return
		}
		else if(this.CycleMode){						; turn off, turn next on
			this.State := True			  	; for 1st run
			this.ToggleState()
			this.CycleActionIndex()
			if(this.RepeatMode) {			; safety for repeat mode
				sleep this.RepeatDelay + 10	; toggling the state too early would lock last action in the loop
			}
			this.ToggleState()
			this.StartAction(this.CurrentAction)
			Return
		}
		; cant reach this line
		Return
	}
	; TODO: send event
	Updated() {
		this.base.RefreshTooltip()
	}
	; called from base to update all
	RefreshTooltip() {
		if(this.ShowToolTip) {
			if(!this._Tooltip) {
				this._ToolTip := new gTT(this.__class . " #" . &this)
			}
			this._ToolTip.SetLine(gs("BoundKeys", "Tab") . "> " . this.BoundKeys.Length(), 10)
			this._ToolTip.SetLine(gs("Running Threads", "Tab") . "> " . gRunner.Runners, 11)
			for i, boundkey in this.BoundKeys {
				state := (boundkey.State) ? "(ON)" : "(OFF)"
				this._ToolTip.SetLine(gs(boundkey.Key, "Tab")  . gs(state, "Tab") . gs(boundkey.CurrentAction, "Indent", "jr") , (20 + i))
			}
		}
	}
	StartAction(action) {
		if(this.RepeatMode) {
			fn := this.LoopAction.Bind(this, action)
			gRunner.Async(fn)
		}
		else {
			this.PerformAction(action)
		}
	}
	LoopAction(action) {
		this.nbCurrentRunners++
		while (this.State) {
			this.PerformAction(action)
			sleep this.RepeatDelay
		}
		gRunner.nbrunners--
		this.nbCurrentRunners--
	}
	PerformAction(action) {
		this.nbPerformedActions++
		if(this.ActionMode) {
			gosub % action
		}
		else {
			send % action
		}
	}
	ToggleState() {
		Return this.State := !this.State
	}
}
