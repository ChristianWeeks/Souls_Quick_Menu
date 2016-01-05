Scriptname SQM_WidgetScript extends SKI_WidgetBase
{This script adds functionality to the Quick Menu Widget}

Import Input
Import Form

;global variables
Bool visible = False
Int Property mainScale = 100 Auto  

Int c1 = 0
Int c2 = 0
Int c3 = 0
Int c4 = 0
String upStr
String downStr
String leftStr
String rightStr
Int potionCount
Int[] shoutIconArgs
Int[] potionIconArgs
Int[] LHIconArgs
Int[] RHIconArgs

Int keyCodeUp = 45 		    ;X
Int keyCodeDown = 21 		;Y
Int keyCodeLeft = 47		;V
Int keyCodeRight = 48		;B
Int keyCodeActivate = 34	;G

function updateQueueIcon(int activeIndex)

	UI.invokeInt(HUD_MENU, WidgetRoot + ".updateDownQueue", activeIndex)

endFunction

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

Int Property count1
{Set this property true to make the numbers visible}
	Int Function Get()
		Return c1
	EndFunction

	Function Set(Int abVal)
		If (Ready)
			c1 = abVal
            Int[] args = new Int[2]
            args[0] = c1
            args[1] = 1
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".colorIcon", 1)
			UI.InvokeIntA(HUD_MENU, WidgetRoot + ".updateQueue", args)
			UI.InvokeIntA(HUD_MENU, WidgetRoot + ".setLHIcon", LHIconArgs)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setLeftName", leftStr)
			Utility.Wait(0.35)
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".resetIcon", 1)
		EndIf
	EndFunction
EndProperty


Int Property count2
{Set this property true to make the numbers visible}
	Int Function Get()
		Return c2
	EndFunction
	
	Function Set(Int abVal)
		If (Ready)
			c2 = abVal
            Int[] args = new Int[2]
            args[0] = c2
            args[1] = 2
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".colorIcon", 2)
			UI.InvokeIntA(HUD_MENU, WidgetRoot + ".updateQueue", args)
            UI.InvokeIntA(HUD_MENU, WidgetRoot + ".setShoutIcon", shoutIconArgs)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setUpName", upStr)
			Utility.Wait(0.35)
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".resetIcon", 2)
		EndIf
	EndFunction
EndProperty

Int Property count3
{Set this property true to make the numbers visible}
	Int Function Get()
		Return c3
	EndFunction
	
	Function Set(Int abVal)
		If (Ready)
			c3 = abVal
            Int[] args = new Int[2]
            args[0] = c3
            args[1] = 3 
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".colorIcon", 3)
			UI.InvokeIntA(HUD_MENU, WidgetRoot + ".updateQueue", args)
			UI.InvokeIntA(HUD_MENU, WidgetRoot + ".setRHIcon", RHIconArgs)
			UI.InvokeString(HUD_MENU, WidgetRoot + ".setRightName", rightStr)
			Utility.Wait(0.35)
			UI.InvokeInt(HUD_MENU, WidgetRoot + ".resetIcon", 3)
		EndIf
	EndFunction
EndProperty

Int Property count4
{Set this property true to make the numbers visible}
	Int Function Get()
		Return c4
	EndFunction
	
	Function Set(Int abVal)
		If (Ready)
			c4 = abVal
            Int[] args = new Int[2]
            args[0] = c4
            args[1] = 4
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
	Return c2
EndFunction

Int Function getDownIndex()
	Return c4
EndFunction

Int Function getLeftIndex()
	Return c1
EndFunction

Int Function getRightIndex()
	Return c3
EndFunction

Function activateButton(String s, int newIndex, int[] args)
    ;args[0] - formType
    ;args[1] - equipslot
    ;args[2] - slotMask
    ;args[3] - formID
	If (s == "up")
        shoutIconArgs = args
		count2 = newIndex 
	elseIf (s == "down")
        potionIconArgs = args
		count4 = newIndex 
	elseIf (s == "left")
        LHIconArgs = args
		count1 = newIndex 
	elseIf (s == "right")
        RHIconArgs = args
		count3 = newIndex 
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
	count1 = c1
	count2 = c2
	count3 = c3
	count4 = c4
	UI.InvokeBool(HUD_MENU, WidgetRoot + ".setVisible", visible)
EndEvent

