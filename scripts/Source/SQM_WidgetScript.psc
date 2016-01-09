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
Int fadeWaitsQueued = 0
Int potionCount
bool ASSIGNMENT_MODE = false 

function resetWaits()
    fadeWaitsQueued = 0
endFunction

function fadeInAndOut(float fadeInDuration, float fadeOutDuration, float fadeWait, float fadeAlpha, bool fadeFlag)
    fadeOut(Alpha, fadeInDuration)
    fadeWaitsQueued += 1
    Utility.wait(fadeWait)
    if(fadeWaitsQueued > 0)
        fadeWaitsQueued -= 1
    endIf
    if(!fadeWaitsQueued && fadeFlag)
        fadeOut(fadeAlpha, fadeOutDuration)
    endIf
endFunction

function fadeOut(float a_alpha, float a_duration)
    float[] args = new float[2]
    args[0] = a_alpha
    args[1] = a_duration
    UI.InvokeFloatA(HUD_MENU, WidgetRoot + ".fadeOut", args)
endFunction

function setPotionCount(int count)
	potionCount = count
	UI.invokeInt(HUD_MENU, WidgetRoot + ".setPotionCounter", potionCount)
endFunction

function setAssignMode(bool a)
    ASSIGNMENT_MODE = a
endFunction

function setItemData(string itemName, int[] itemArgs)
    UI.InvokeIntA(HUD_MENU, WidgetRoot + ".setItemData", itemArgs)
    UI.InvokeString(HUD_MENU, WidgetRoot + ".setItemName", itemName)
endfunction
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

Int Property leftIndex
	Int Function Get()
		Return _leftIndex
	EndFunction
	
	Function Set(Int abVal)
		If (Ready)
			_leftIndex = abVal
            Int[] args = new Int[2]
            args[0] = _leftIndex
            args[1] = ASSIGNMENT_MODE as int
            UI.InvokeIntA(HUD_MENU, WidgetRoot + ".cycleLeftHand", args)
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
            Int[] args = new Int[2]
            args[0] = _rightIndex
            args[1] = ASSIGNMENT_MODE as int
            UI.InvokeIntA(HUD_MENU, WidgetRoot + ".cycleRightHand", args)
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
            Int[] args = new Int[2]
            args[0] = _shoutIndex
            args[1] = ASSIGNMENT_MODE as int
            UI.InvokeIntA(HUD_MENU, WidgetRoot + ".cycleShout", args)
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
            Int[] args = new Int[2]
            args[0] = _potionIndex
            args[1] = ASSIGNMENT_MODE as int
            UI.InvokeIntA(HUD_MENU, WidgetRoot + ".cyclePotion", args)
			UI.invokeInt(HUD_MENU, WidgetRoot + ".setPotionCounter", potionCount)
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
	UI.InvokeBool(HUD_MENU, WidgetRoot + ".setVisible", visible)
EndEvent

