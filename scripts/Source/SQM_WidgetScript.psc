Scriptname SQM_WidgetScript extends SKI_WidgetBase
{This script adds functionality to the Quick Menu Widget}

Import Input
Import Form

;global variables
Bool visible = False
Int Property mainScale = 100 Auto  

Int _shoutIndex = 0
Int _leftIndex = 0
Int _rightIndex = 0
Int _potionIndex = 0
String upStr
String downStr
String leftStr
String rightStr
Int potionCount
bool ASSIGNMENT_MODE = false 
Int[] shoutIconArgs
Int[] potionIconArgs
Int[] LHIconArgs
Int[] RHIconArgs

Int keyCodeUp = 45 		    ;X
Int keyCodeDown = 21 		;Y
Int keyCodeLeft = 47		;V
Int keyCodeRight = 48		;B
Int keyCodeActivate = 34	;G

function setPotionCount(int count)
	potionCount = count
	UI.invokeInt(HUD_MENU, WidgetRoot + ".setPotionCounter", potionCount)
endFunction

function fadeOut(float a_alpha, float a_duration)
    float[] args = new float[2]
    args[0] = a_alpha
    args[1] = a_duration
    UI.InvokeFloatA(HUD_MENU, WidgetRoot + ".fadeOut", args)
endFunction

function setAssignMode(bool a)
    ASSIGNMENT_MODE = a
endFunction

function setUpStr(String newStr)
	upStr = newStr
endFunction

function setdownStr(String newStr)
	downStr = newStr
endFunction

function setLeftStr(String newStr)
	leftStr = newStr
endFunction

function setRightStr(String newStr)
	rightStr = newStr
endFunction
;properties
Bool Property isVisible
{Set this property true to make the widget visible}
	Bool Function Get()
		Return visible
	EndFunction
	
	Function Set(Bool abVal)
		visible = abVal
		If (Ready)
			UI.InvokeBool(HUD_MENU, WidgetRoot + ".setVisible", visible)
		EndIf
	EndFunction
EndProperty

Int Property shoutIndex
	Int Function Get()
		Return _shoutIndex
	EndFunction

	Function Set(Int abVal)
		If (Ready)
			_shoutIndex = abVal
            Int[] args = new Int[3]
            args[0] = _shoutIndex
            args[1] = 1
            args[2] = ASSIGNMENT_MODE as int
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".colorIcon", 1)
			UI.InvokeIntA(HUD_MENU, WidgetRoot + ".updateQueue", args)
			UI.InvokeIntA(HUD_MENU, WidgetRoot + ".setLHIcon", LHIconArgs)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setLeftName", leftStr)
			Utility.Wait(0.35)
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".resetIcon", 1)
		EndIf
	EndFunction
EndProperty


Int Property leftIndex
	Int Function Get()
		Return _leftIndex
	EndFunction
	
	Function Set(Int abVal)
		If (Ready)
			_leftIndex = abVal
            Int[] args = new Int[3]
            args[0] = _leftIndex
            args[1] = 2
            args[2] = ASSIGNMENT_MODE as int
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".colorIcon", 2)
			UI.InvokeIntA(HUD_MENU, WidgetRoot + ".updateQueue", args)
            UI.InvokeIntA(HUD_MENU, WidgetRoot + ".setShoutIcon", shoutIconArgs)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setUpName", upStr)
			Utility.Wait(0.35)
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".resetIcon", 2)
		EndIf
	EndFunction
EndProperty

Int Property rightIndex
	Int Function Get()
		Return _rightIndex
	EndFunction
	
	Function Set(Int abVal)
		If (Ready)
			_rightIndex = abVal
            Int[] args = new Int[3]
            args[0] = _rightIndex
            args[1] = 3 
            args[2] = ASSIGNMENT_MODE as int
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".colorIcon", 3)
			UI.InvokeIntA(HUD_MENU, WidgetRoot + ".updateQueue", args)
			UI.InvokeIntA(HUD_MENU, WidgetRoot + ".setRHIcon", RHIconArgs)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setRightName", rightStr)
			Utility.Wait(0.35)
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".resetIcon", 3)
		EndIf
	EndFunction
EndProperty

Int Property potionIndex
	Int Function Get()
		Return _potionIndex
	EndFunction
	
	Function Set(Int abVal)
		If (Ready)
			_potionIndex = abVal
            Int[] args = new Int[3]
            args[0] = _potionIndex
            args[1] = 4
            args[2] = ASSIGNMENT_MODE as int
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".colorIcon", 4)
			UI.InvokeIntA(HUD_MENU, WidgetRoot + ".updateQueue", args)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setDownName", downStr)
			UI.invokeInt(HUD_MENU, WidgetRoot + ".setPotionCounter", potionCount)
			Utility.Wait(0.35)
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".resetIcon", 4)
		EndIf
	EndFunction
EndProperty

Actor Property PlayerRef Auto
{This property contains the player reference}

;functions
Function setX(Float afX)
	If (Ready)
		X = afX
	EndIf
EndFunction

Function setY(Float afY)
	If (Ready)
		Y = afY
	EndIf
EndFunction

Function setUP(Int afY)
	If (Ready)
		keyCodeUp = afY
	EndIf
EndFunction

Function setDOWN(Int afY)
	If (Ready)
		keyCodeDown = afY
	EndIf
EndFunction

Function setLEFT(Int afY)
	If (Ready)
		keyCodeLeft = afY
	EndIf
EndFunction

Function setRIGHT(Int afY)
	If (Ready)
		keyCodeRight = afY
	EndIf
EndFunction

Function setACTIVATE(Int afY)
	If (Ready)
		keyCodeActivate = afY
	EndIf
EndFunction

Int Function getUP()
	Return keyCodeUp
EndFunction

Int Function getDOWN()
	Return keyCodeDown
EndFunction

Int Function getLEFT()
	Return keyCodeLeft
EndFunction

Int Function getRIGHT()
	Return keyCodeRight
EndFunction

Int Function getACTIVATE()
	Return keyCodeActivate
EndFunction


Int Function getUpIndex()
	Return _leftIndex
EndFunction

Int Function getDownIndex()
	Return _potionIndex
EndFunction

Int Function getLeftIndex()
	Return _shoutIndex
EndFunction

Int Function getRightIndex()
	Return _rightIndex
EndFunction

Function activateButton(String s, int newIndex, int[] iconArgs)
    ;iconArgs[0] - formType
    ;iconArgs[1] - equipslot
    ;iconArgs[2] - slotMask
    ;iconArgs[3] - formID
	If (s == "up")
        shoutIconArgs = iconArgs
		leftIndex = newIndex 
	elseIf (s == "down")
        potionIconArgs = iconArgs
		potionIndex = newIndex 
	elseIf (s == "left")
        LHIconArgs = iconArgs
		shoutIndex = newIndex 
	elseIf (s == "right")
        RHIconArgs = iconArgs
		rightIndex = newIndex 
	elseIf (s == "activate")
	endIf
EndFunction

Function setTransparency(Float afAlpha)
	If (Ready)
		Alpha = afAlpha
	EndIf
EndFunction

Function setScale(Float afx)
	If (Ready)
		mainScale = afx as int
		UI.InvokeInt(HUD_MENU, WidgetRoot + ".setRootScale", mainScale)
	EndIf
EndFunction

Function updateStatus()
	If (Ready)
		;RegisterForKey(keyCodeUp)
		;RegisterForKey(keyCodeDown)
		;RegisterForKey(keyCodeLeft)
		;RegisterForKey(keyCodeRight)
		;RegisterForKey(keyCodeActivate)
	endIf
EndFunction

String Function GetWidgetSource()
	Return "soulsQuickMenu/SQMWidget.swf"
EndFunction

String Function GetWidgetType()
	Return "SQM_WidgetScript"
EndFunction

;events
Event OnWidgetReset()
    RequireExtend = false
	parent.OnWidgetReset()
	setX(X)
	setY(Y)
    setScale(mainScale)
	setUP(keyCodeUp)
	setDOWN(keyCodeDown)
	setLEFT(keyCodeLeft)
	setRIGHT(keyCodeRight)
	setACTIVATE(keyCodeActivate)
	shoutIndex = _shoutIndex
	leftIndex = _leftIndex
	rightIndex = _rightIndex
	potionIndex = _potionIndex
	UI.InvokeBool(HUD_MENU, WidgetRoot + ".setVisible", visible)
EndEvent

