; No warranty, to be upgraded

class gRunner {
	static _runners := []
	static nbrunners := 0
	Runners[]{
		get {
			return this.nbrunners
		}
		set {
			msgbox % "Error: You cannot set gRunner.Runners`nExiting"
			ExitApp
		}
	}
	Init() {
		; should kill all existing runners on init
		this._runners := []
		this.nbrunners := 0
	}
	Async(Function) {
		; WARNING this could let unproperly bound functions thru ( missing arguments )
		; if (!IsFunc(Function)) { ; AND !this._isBoundFunc(obj)) {	; this needs better validation
			; msgbox % "Error: Invalid function passed to gRunner`nFunction: " . Function . "`nExiting"
			; ExitApp
		; }
		; I would need a callback of some sort or hook on the thread to be able to kill it
		this.nbrunners++
		SetTimer %Function%, -1
	}
	RunnerEnded() {
		; meh
	}
	KillRunner() {
		; meh
	}
	__New() {
		msgbox % "Error: You cannot instantiate gRunner`nUse it as a static object`nExiting"
		ExitApp
	}
	_isBoundFunc(obj) {
		static dummy := Func("Abs").Bind(1) ; dummy BoundFunc object
		return NumGet(&obj) == NumGet(&dummy)
	}
}
