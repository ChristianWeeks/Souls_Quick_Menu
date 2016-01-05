Scriptname SQM_ManagerScript extends Quest
{This script constantly updates the widget}

SQM_WidgetScript Property SQM Auto

Event OnInit()
	RegisterForSingleUpdate(0.1)
EndEvent

Event OnUpdate()
	SQM.updateStatus()
	RegisterForSingleUpdate(0.1)
EndEvent

