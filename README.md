# gKeyHelper

Simple and flexible helper for AutoHotKey bindings
Six different modes to experiment with

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
*/

myF1Key := new gKeyHelper(0x0010, "F1 up", ["ASDF", "1234", "XYZ"])
myF2Key := new gKeyHelper(0x0011, "F2", ["action1", "action2", "action3"])
