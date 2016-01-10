Scriptname SQM_MenuScript extends SKI_ConfigBase
{This script adds a MCM for the Quick Menu Widget and handles all
;menu cycling logic}
;-------------------------------------------------------------------------
;NOTE: Many of the methods here were obtained/modified 
;from the source code from the SkyUI team.  
;All credit to them.  Thank you!
;-------------------------------------------------------------------------
;Properties
;-------------------------------------------------------------------------
SQM_WidgetScript Property SQM Auto

Actor Property PlayerRef  Auto  

Form Property Unarmed1H  Auto  
Form Property Unarmed2H  Auto  
Shout[] Property shoutListFull  Auto  
Shout[] _DLCShouts
Spell[] _voiceSpells

;-------------------------------------------------------------------------
;OIDs for each MCM object
;-------------------------------------------------------------------------
;x, y location and scale for the widget 
int xOID
int yOID
int scaleOID
;variables controlling the widget's fadeout property
int fadeOID
int fadeAlphaOID
int fadeOutDurationOID
int fadeInDurationOID
int fadeWaitOID
;toggle visibility box, transparency slider, and refresh button
int visOID
int transOID
int refreshOID
int refreshPotionsOID
;mcm keymap option id's
int keyOID_CSHOUT
int keyOID_CPOTION
int keyOID_CLEFTHAND
int keyOID_CRIGHTHAND
int keyOID_ACTIVATE
int keyOID_ASSIGNLEFT
int keyOID_ASSIGNRIGHT
int keyOID_ASSIGNSHOUT
int assignEquippedOID
int mustBeFavoritedOID
;array of object id's for each item queue (MCM menu)
int[] shoutAssignOID
int[] potionAssignOID
int[] leftAssignOID
int[] rightAssignOID

;keys
int cycleShoutKey = 45			; X
int cyclePotionKey = 21		; Y
int cycleLeftKey = 47		; V
int cycleRightKey = 48		; B
int usePotionKey = 34	; G

int assignLeftKey = -1  ;f1
int assignRightKey = -1 ;f2
int assignShoutKey = -1 ;f3

;-------------------------------------------------------------------------
;Global variables 
;-------------------------------------------------------------------------
bool fadeOut = true
float fadeAlpha = 0.0
float fadeOutDuration = 200.0
float fadeInDuration = 15.0
float fadeWait = 500.0
;Used to control fading out when many buttons are pressed
int waitsQueued
bool ASSIGNMENT_MODE = false 

;If this is toggled, only favorited items will show up in the MCM menu
bool mustBeFavorited = false
;these variables contain the item and item IDs of the different elements in the queues
string[]	 _potionListName
string[]	 _shoutListName

;right and left hand lists are separate because left hand can equip shields and torches, which RH can't
string[]	 _rightHandListName
string[]	 _leftHandListName 

;these contain the objects for the final queues the user decides upon
Form[]		 _potionQueue
Form[]		 _shoutQueue
Form[]		 _rightHandQueue 
Form[]		 _leftHandQueue 

;These contain the full list of items the player can choose from in the MCM menu
Form[]		 _potionList
Form[]		 _shoutsKnown
Form[]		 _rightHandList 
Form[]		 _leftHandList 

;contain indexes of items in their lists
int[]       _potionIndexMap
int[]       _shoutIndexMap
int[]       _rightHandIndexMap
int[]       _leftHandIndexMap

;array of indices for each item dropdown menu
int[] 		shoutListIndex
int[] 		potionListIndex
int[] 		leftListIndex
int[] 		rightListIndex
bool[]      itemDataUpToDate

;initialize values for visibility and transparency
bool visVal = true
float transVal = 50.0

int MAX_QUEUE_SIZE = 7

;_currQIndices contains indices of currently active slots
;0 - LH
;1 - RH
;2 - Power
;3 - Item
int[]		 _currQIndices

;If players have dragonborn and/or dawnguard, load their dragonshouts
Function CheckForDLC()
	_DLCShouts = new Shout[8]
    ;GetFormFromFile must be loaded into a form object before casting to a shout for some reason
    Form[] shoutForms = new Form[8] 
	int ndx = 0;
	;check for Dawnguard

	if(Game.GetFormFromFile(0x00000800, "Dawnguard.esm"))
		;Soul Tear
		shoutForms[ndx] = Game.GetFormFromFile(0x00007CB6, "Dawnguard.esm") As Shout
		;Summon Durnehviir
		shoutForms[ndx+1] = Game.GetFormFromFile(0x000030D2, "Dawnguard.esm") As Shout
        ;Drain Vitality
        shoutForms[ndx+2] = Game.GetFormFromFile(0x00008A62, "Dawnguard.esm") As Shout
        ndx += 3 
	endif

	;check for Dragonborn
	if(Game.GetFormFromFile(0x00018DDD, "Dragonborn.esm"))
		;Battle Fury
		shoutForms[ndx] = Game.GetFormFromFile(0x0002AD09, "Dragonborn.esm") As Shout
		;Bend Will
		shoutForms[ndx+1] = Game.GetFormFromFile(0x000179D8, "Dragonborn.esm") As Shout
		;Cyclone
		shoutForms[ndx+2] = Game.GetFormFromFile(0x000200C0, "Dragonborn.esm") As Shout
		;Dragon Aspect
		shoutForms[ndx+3] = Game.GetFormFromFile(0x0001DF92, "Dragonborn.esm") As Shout
	endif
    int i = 0
    while shoutForms[i]
        _DLCShouts[i] = shoutForms[i] as Shout
        i += 1
    endWhile
endFunction
;-------------------------------------------------------------------------
;Functions for populating the queues with items in the
;inventory 
;-------------------------------------------------------------------------
;This will only populate the potions lists
Function populatePotionsList(ObjectReference akContainer)

	_potionListName[0] = "<Empty>"
	_potionList[0] = None
	Int itemCount = 0
    Int nextPotionIndex = 0
    Int ndx = 0
    int totalItems = akContainer.GetNumItems()
    while ndx < totalItems
		Form kForm = akContainer.GetNthForm(ndx)
        ;if it must be favorited, make sure it is. else proceed 
		if(!mustBeFavorited || (mustBeFavorited && Game.isObjectFavorited(kForm)))
            itemCount = PlayerRef.getItemCount(kForm)
			If kForm.GetType() == 46 ; is a potion
				_potionListName[nextPotionIndex] = kForm.getName() + "  (" + itemCount + ")"
				_potionList[nextPotionIndex] = kForm
				nextPotionIndex += 1
            endIf
        endIf
        ndx +=1
    endWhile
    ;empty the rest of the list
    if ndx < 128
        while ndx < 128
            _potionList[ndx] = None
            _potionListName[ndx] = "" 
            ndx += 1
        endWhile
    endIf        
endFunction

;populates potion and weapon queues for the dropdown options in the MCM
Function populateLists(ObjectReference akContainer)
    EmptyLists()
	_potionListName[0] = "<Empty>"
	_rightHandListName[0] = "<Empty>"
	_leftHandListName[0] = "<Empty>"
	_potionList[0] = None
	_rightHandList[0] = None
	_leftHandList[0] = None 
    _rightHandListName[1] = Unarmed1H.GetName() 
	_rightHandList[1] = Unarmed1H
    _leftHandListName[1] = Unarmed1H.GetName() 
	_leftHandList[1] = Unarmed1H
    _rightHandListName[2] = Unarmed2H.GetName() 
	_rightHandList[2] = Unarmed2H
    _leftHandListName[2] = Unarmed2H.GetName()
	_leftHandList[2] = Unarmed2H

	Int ndx = 0
	Int nextPotionIndex = 1 
	Int nextRHIndex = 3 
	Int nextLHIndex = 3 
	Int itemCount = 0
    String itemStr 
    int totalItems = akContainer.GetNumItems() 
    SetTextOptionValue(refreshOID, "Updating Items")
	;iterate through all items in player's inventory
	While ndx < totalItems
		Form kForm = akContainer.GetNthForm(ndx)
        if(kForm != Unarmed1H && kForm != Unarmed2H)
            ;if it must be favorited, make sure it is. else proceed 
            if(!mustBeFavorited || (mustBeFavorited && Game.isObjectFavorited(kForm)))
                itemCount = PlayerRef.getItemCount(kForm)
                itemStr = ""
                if(itemCount > 1 && kForm.GetType() == 41)
                    itemStr = " [" + itemCount + "]"   
                endIf
                If kForm.GetType() == 46 ; is a potion
                    _potionListName[nextPotionIndex] = kForm.getName() + "  (" + itemCount + ")"
                    _potionList[nextPotionIndex] = kForm
                    nextPotionIndex += 1
                elseIf kForm.GetType() == 41 ; is a weapon
                    ;only add 2 handers and ranged to RH slot
                    if((kForm as weapon).GetWeapontype() <= 4)
                        ;adding to LH queue
                        _leftHandListName[nextLHIndex] = kForm.getName() + itemStr
                        _leftHandList[nextLHIndex] = kForm
                        nextLHIndex += 1
                    endIf
                    ;1h weapons go in both
                    _rightHandListName[nextRHIndex] = kForm.getName() + itemStr
                    _rightHandList[nextRHIndex] = kForm
                    nextRHIndex += 1
                ;add shields to the lefthand queue
                elseIf (kForm.GetType() == 26 && (kForm as Armor).GetSlotMask() == 512)
                    _leftHandListName[nextLHIndex] = kForm.getName() + itemStr
                    _leftHandList[nextLHIndex] = kForm
                    nextLHIndex += 1
                ;Light (Torch)
                elseIf kForm.GetType() == 31
                    itemCount = PlayerRef.getItemCount(kForm)
                    _leftHandListName[nextLHIndex] = kForm.getName() + "  (" + itemCount + ")"
                    _leftHandList[nextLHIndex] = kForm
                    nextLHIndex += 1	
                endIf
            endIf
        endIf
		ndx += 1
	endWhile

	EquipSlot voiceSlot	= Game.GetFormFromFile(0x00025bee, "Skyrim.esm") as EquipSlot
    ndx = 0
    ;reset voice spells
    int voiceNdx = 0
    SetTextOptionValue(refreshOID, "Updating Spells")
    int i = 0
    while i < 128
        _voiceSpells[i] = None
        i+=1
    endWhile
    ;Player spells are located in different places, so we have to accumulate them first
    Spell[] allSpells = GetAllSpells() 
    int spellCount = PlayerRef.GetActorBase().GetSpellCount() + PlayerRef.GetRace().GetSpellCount() + PlayerRef.GetSpellCount()
    ;Add spells to our lists
	While ndx < spellCount
		Spell currSpell = allSpells[ndx] 
		;make sure it is favorited, remove spells that can't be equipped in the hands
		if(isSpellValid(currSpell) && (!mustBeFavorited || (mustBeFavorited && Game.isObjectFavorited(currSpell))) )
        ;Debug.MessageBox(currSpell.getName() + "   " + currSpell + "   " + currSpell.GetFormID() + "   ")
            if currSpell.GetEquipType() == voiceSlot 
                _voiceSpells[voiceNdx] = currSpell
                voiceNdx += 1
            else
                ;adding to RH queue
                _rightHandListName[nextRHIndex] = currSpell.getName()
                _rightHandList[nextRHIndex] = currSpell 
                nextRHIndex += 1
                ;adding to LH queue
                _leftHandListName[nextLHIndex] = currSpell.getName()
                _leftHandList[nextLHIndex] = currSpell 
                nextLHIndex += 1
            endIf
            int keywordNdx = 0
		endIf
		ndx += 1
	endWhile
    SetTextOptionValue(refreshOID, "Updating Shouts")
	populateShoutList()
endFunction

Spell[] Function GetAllSpells()
    Spell[] allSpells = new Spell[128]
    Spell currSpell
    int ndx = 0
    int spellNdx = 0
    ;Actor base spells
    while ndx < PlayerRef.GetActorBase().GetSpellCount()
        allSpells[spellNdx] = PlayerRef.GetActorBase().GetNthSpell(ndx)
        ndx+=1
        spellNdx+=1
    endWhile
    ndx = 0
    ;Race base spells
    while ndx < PlayerRef.GetRace().GetSpellCount()
        allSpells[spellNdx] = PlayerRef.GetRace().GetNthSpell(ndx)
        ndx+=1
        spellNdx+=1
    endWhile
    ndx = 0
    ;Added spells
    while ndx < PlayerRef.GetSpellCount()
        allSpells[spellNdx] = PlayerRef.GetNthSpell(ndx)
        ndx+=1
        spellNdx+=1
    endWhile
    return allSpells
endFunction
 
;armor set bonuses and passive spellsare returned by getNthSpell.  We do not want these to show up in our menu so we have
;to manually remove them
bool Function isSpellValid(Spell s)
    
    ;----------------------------------------------------------------------
    ;Vanilla
    ;----------------------------------------------------------------------
    ;Shrouded Armor
    if s == Game.GetFormFromFile(0x0001711D, "Skyrim.esm")
        return false
    endIf
    ;Nightingale Armor
    if s == Game.GetFormFromFile(0x0001711F, "Skyrim.esm")
        return false
    endIf
    ;Combat Heal Rate
    if s == Game.GetFormFromFile(0x001031D3, "Skyrim.esm")
        return false
    endIf
    ;Imperial Luck
    if s == Game.GetFormFromFile(0x000EB7EB, "Skyrim.esm")
        return false
    endIf
    ;Argonian Waterbreathing
    if s == Game.GetFormFromFile(0x000AA01B, "Skyrim.esm")
        return false
    endIf
    ;Argonian Resist Disease
    if s == Game.GetFormFromFile(0x00104ACF, "Skyrim.esm")
        return false
    endIf
    ;Wood Elf Resist Disease and Poison
    if s == Game.GetFormFromFile(0x000AA025, "Skyrim.esm")
        return false
    endIf
    ;Breton Resist Magic
    if s == Game.GetFormFromFile(0x000AA01F, "Skyrim.esm")
        return false
    endIf
    ;Dark Elf Resist Fire 
    if s == Game.GetFormFromFile(0x000AA021, "Skyrim.esm")
        return false
    endIf
    ;Khajiit Claws
    if s == Game.GetFormFromFile(0x000AA01E, "Skyrim.esm")
        return false
    endIf
    ;Nord Resist Frost
    if s == Game.GetFormFromFile(0x000AA020, "Skyrim.esm")
        return false
    endIf
    ;Redguard Resist Poison
    if s == Game.GetFormFromFile(0x000AA023, "Skyrim.esm")
        return false
    endIf
    ;----------------------------------------------------------------------
    ;Dawnguard
    ;----------------------------------------------------------------------
    ;Crossbow Bonus
    if s == Game.GetFormFromFile(0x00012CCC, "Dawnguard.esm")
        return false
    endIf

    ;----------------------------------------------------------------------
    ;DragonBorn
    ;----------------------------------------------------------------------
    ;Ahzidal's Genius
    if s == Game.GetFormFromFile(0x00027332, "Dragonborn.esm")
        return false
    endIf
    ;Deathbrand Instinct
    if s == Game.GetFormFromFile(0x0003B563, "Dragonborn.esm")
        return false
    endIf
   return true
endFunction

;populates spell queue for the dropdown options in the MCM
Function populateShoutList()

	_shoutListName[0] = "<Empty>"
	_shoutsKnown[0] = None

	Int ndx = 0
	Int nextShoutIndex = 1 
	;Unfortunately, there is no getShouts() method like there is for spells.  So to check if the player
	;knows a shout, we have to check a hardcoded list of each shout in the game and see if the player knows it
	While ndx < shoutListFull.Length
		Shout currShout = shoutListFull[ndx]
		if(PlayerRef.HasSpell(currShout) && (!mustBeFavorited || (mustBeFavorited && Game.isObjectFavorited(currShout))) )
			_shoutListName[nextShoutIndex] = currShout.getName()
			_shoutsKnown[nextShoutIndex] = currShout
			nextShoutIndex += 1
		endIf
		ndx += 1
	endWhile
	
	;Now we check for shouts from Dragonborn and Dawnguard.  They must be checked seperately, as it is possible
	;Dragonborn and Dawnguard aren't installed
    CheckForDLC()
	ndx = 0
	While ndx < _DLCShouts.Length
		Shout currShout = _DLCShouts[ndx]
		if(PlayerRef.HasSpell(currShout) && (!mustBeFavorited || (mustBeFavorited && Game.isObjectFavorited(currShout))) )
			_shoutListName[nextShoutIndex] = currShout.getName()
			_shoutsKnown[nextShoutIndex] = currShout
			nextShoutIndex += 1
		endIf
		ndx += 1
	endWhile

	ndx = 0
	While ndx < _voiceSpells.Length 
        Spell currSpell = _voiceSpells[ndx]
		if(PlayerRef.HasSpell(currSpell) && (!mustBeFavorited || (mustBeFavorited && Game.isObjectFavorited(currSpell))) )
			_shoutListName[nextShoutIndex] = currSpell.getName()
			_shoutsKnown[nextShoutIndex] = currSpell
			nextShoutIndex += 1
		endIf
		ndx += 1
	endWhile 
endFunction

;-----------------------------------------------------------------------------------------------------------------------
;QUEUE FUNCTIONALITY CODE
;-----------------------------------------------------------------------------------------------------------------------
Int[] Function GetItemIconArgs(int queueID)
    Form[] Q
    if(queueID == 1)
        Q = _rightHandQueue
    elseif(queueID == 2)
        Q = _shoutQueue
    elseif(queueID == 3)
        Q = _potionQueue
    else
        Q = _leftHandQueue
    endIf
    Form item = Q[_currQIndices[queueID]]
    int[] args = new Int[4]
    args[0] = queueID 
    args[1] = _currQIndices[queueID] 
    args[2] = item.GetType() 
    args[3] = -1 
    ;if it is a weapon, we want its weapon type
    if(args[2] == 41)
        Weapon W = item as Weapon
        int weaponType = W.GetWeaponType()
            ;2H axes and maces have the same ID for some reason, so we have to differentiate them
            if(weaponType == 7)
                weaponType = 8
            elseif(weaponType == 8)
                weaponType = 10
            endIf
            if(weaponType == 6)
                if(W.IsWarhammer())
                weaponType = 7
                endIf
            endIf
        args[3] = weaponType
    ;Is a spell
    elseIf(args[2] == 22) 
        Spell S = item as Spell
        int sIndex = S.GetCostliestEffectIndex()
        MagicEffect sEffect = S.GetNthEffectMagicEffect(sIndex)
        String school = sEffect.GetAssociatedSkill()
        if(school == "Alteration")
            args[3] = 18 
        elseIf(school == "Conjuration")
            args[3] = 19
        elseIf(school == "Destruction")
            args[3] = 20 
        elseIf(school == "Illusion")
            args[3] = 21 
        elseIf(school == "Restoration")
            args[3] = 22 
        endIf
    ;Is a potion
    elseIf(args[2] == 46)
        Potion P = item as Potion
        if(P.IsPoison())
            args[3] = 15
            return args
        elseIf(P.IsFood())
            args[3] = 13
            return args 
        endIf
        int pIndex = P.GetCostliestEffectIndex()
        MagicEffect pEffect = P.GetNthEffectMagicEffect(pIndex)
        String pStr = pEffect.GetName() 
        if(pStr == "Restore Health" || pStr == "Regenerate Health")
            args[3] = 0
        elseif(pStr == "Restore Magicka" || pStr == "Regenerate Magicka")
            args[3] = 3 
        elseif(pStr == "Restore Stamina" || pStr == "Regenerate Stamina")
            args[3] = 6 
        elseif(pStr == "Resist Fire")
            args[3] = 9 
        elseif(pStr == "Resist Shock")
            args[3] = 10 
        elseif(pStr == "Resist Frost")
            args[3] = 11 
        endIf
        Debug.MessageBox(pStr)
        Debug.MessageBox(args[3])
    endIf       
    return args
endFunction


;Fade in widget after button press 
function fadeInWidget()
    if(fadeOut)
        SQM.FadeOut(SQM.Alpha, fadeInDuration/100.0)
        waitsQueued += 1
    endIf
endFunction

;Fade out the widget after the allotted time
function fadeOutWidget()
    if(fadeOut)
        Utility.wait(fadeWait/100.0)
        if(waitsQueued > 0)
            waitsQueued -=1
        endIf
        ;only fade out if this is the last button pressed
        if(!waitsQueued && fadeOut)
            SQM.FadeOut(fadeAlpha, fadeOutDuration/100.0)
        EndIf
    EndIf
endFunction

Event OnKeyUp(Int KeyCode, Float HoldTime)
	GotoState("PROCESSING")
    int[] args
	If KeyCode == cycleShoutKey && !Utility.IsInMenuMode()
        if(ASSIGNMENT_MODE)
            advanceQueue_ASSIGNMENT_MODE(2)
        else
            cyclePower()
        endIf
        ;If the item data is not up to date, set it
        if(!itemDataUpToDate[2*MAX_QUEUE_SIZE + _currQIndices[2]])
            args = GetItemIconArgs(2)
            SQM.setItemData(getCurrQItemName(2), args)
        endIf
        SQM.shoutIndex = _currQIndices[2]

	elseIf KeyCode == cyclePotionKey && !Utility.IsInMenuMode()
		cyclePotion()
        if(!itemDataUpToDate[3*MAX_QUEUE_SIZE + _currQIndices[3]])
            args = GetItemIconArgs(3)
            SQM.setItemData(getCurrQItemName(3), args)
        endIf
        SQM.potionIndex = _currQIndices[3]

	elseIf KeyCode == cycleLeftKey && !Utility.IsInMenuMode()
        if(ASSIGNMENT_MODE)
            advanceQueue_ASSIGNMENT_MODE(0)
        else
            cycleHand(0)
        endIf
        if(!itemDataUpToDate[_currQIndices[0]])
            args = GetItemIconArgs(0)
            SQM.setItemData(getCurrQItemName(0), args)
        endIf
        SQM.leftIndex = _currQIndices[0]

	elseIf KeyCode == cycleRightKey && !Utility.IsInMenuMode()
        if(ASSIGNMENT_MODE)
            advanceQueue_ASSIGNMENT_MODE(1)
        else
            cycleHand(1)
        endIf
        if(!itemDataUpToDate[MAX_QUEUE_SIZE + _currQIndices[1]])
            args = GetItemIconArgs(1)
            SQM.setItemData(getCurrQItemName(1), args)
        endIf
        SQM.rightIndex = _currQIndices[1]

	elseIf KeyCode == usePotionKey && !Utility.IsInMenuMode()
		useEquippedItem()

    elseIf KeyCode == assignLeftKey && !Utility.IsInMenuMode()
        AssignCurrEquippedItem(0)
        args = GetItemIconArgs(0)
		SQM.setItemData(_leftHandQueue[_currQIndices[0]].GetName(), args)
        SQM.leftIndex = _currQIndices[0]

    elseIf KeyCode == assignRightKey && !Utility.IsInMenuMode()
        AssignCurrEquippedItem(1)
        args = GetItemIconArgs(1)
		SQM.setItemData(_rightHandQueue[_currQIndices[1]].GetName(), args)
        SQM.rightIndex = _currQIndices[1]

    elseIf KeyCode == assignShoutKey && !Utility.IsInMenuMode()
        AssignCurrEquippedItem(2)
        args = GetItemIconArgs(2)
		SQM.setItemData(_shoutQueue[_currQIndices[2]].GetName(), args)
        SQM.shoutIndex = _currQIndices[2]
	EndIf
    if(args[0])
        itemDataUpToDate[args[0]*MAX_QUEUE_SIZE + args[1]] = true
    endIf
    SQM.fadeInAndOut(fadeInDuration/100.0, fadeOutDuration/100.0, fadeWait/100.0, fadeAlpha, fadeOut)
	GotoState("")
EndEvent

;Disallow keys and group usage while processing
state PROCESSING	
	event OnKeyDown(int a_keyCode)
	endEvent
endState

function cyclePotion()
	advanceQueue(3, 0)
	int currIndex = _currQIndices[3]
	Form item = _potionQueue[currIndex]
	SQM.setPotionCount(PlayerRef.GetItemCount(item))
endFunction

;uses the equipped item / potion in the bottom slot
function useEquippedItem()
	int currIndex = _currQIndices[3]	
	Form item = _potionQueue[currIndex]
	if( item != None)
		if(ValidateItem(item))
			PlayerRef.EquipItem(item, false, false)
		else
			removeInvalidItem(3, currIndex)
			Debug.Notification("You no longer have " + item.getName())
		endIf
	endIf
	SQM.setPotionCount(PlayerRef.GetItemCount(item))
endFunction

;cycle the upper slot (shouts, powers)
function cyclePower()	
	;if no power is equipped OR a power is equipped that is not the same as the current power in the Queue, equip current queue power
	;else, go to next power in the queue
	int currIndex = _currQIndices[2]
	shout currShout = PlayerRef.GetEquippedShout()
    int type
    ;If the currently equipped power is not a shout but a spell (power), there isn't a way to tell it is equipped,
    ;so we have to advance the queue no matter what
	if(currShout != _shoutQueue[currIndex] && _shoutQueue[currIndex] != None && _shoutQueue[currIndex].GetType() != 22)	
        type = _shoutQueue[currIndex].GetType()
        ;If it is a spell (power)
        if( type == 22)
            PlayerRef.EquipSpell(_shoutQueue[currIndex] as Spell, 2 )
        elseIf(type == 119)
            PlayerRef.EquipShout(_shoutQueue[currIndex] as Shout )
        endIf

	else
		int newIndex = advanceQueue(2, 0);
		;PlayerRef.EquipShout(_shoutQueue[newIndex] as shout)
        type = _shoutQueue[newIndex].GetType()
        if( type == 22)
            PlayerRef.EquipSpell(_shoutQueue[newIndex] as Spell, 2 )
        elseIf(type == 119)
            PlayerRef.EquipShout(_shoutQueue[newIndex] as Shout )
        endIf
	endif
endFunction

;Unequips item in hand
function UnequipHand(int a_hand)
	int a_handEx = 1
	if (a_hand == 0)
		a_handEx = 2 ; unequipspell and *ItemEx need different hand args
	endIf

	Form handItem = PlayerRef.GetEquippedObject(a_hand)
	if (handItem)
		int itemType = handItem.GetType()
		if (itemType == 22)
			PlayerRef.UnequipSpell(handItem as Spell, a_hand)
		else
			PlayerRef.UnequipItemEx(handItem, a_handEx)
		endIf
	endIf
endFunction

bool function cycleHand(int slotID)
	Form[] queue
	int equipSlotId
	int currIndex = _currQIndices[slotID]

	;for some reason, when using Unequip, 0 corresponds to the left hand, but when using equip, 2 corresponds to the left hand,
	;so we have to change the value for the left hand here	
	if(slotID == 0)
		queue = _leftHandQueue
		equipSlotId = 2	
	elseif (slotID == 1)
		queue = _rightHandQueue
		equipSlotId = 1
	endif

	;First, we check to see if the currently equipped item is the same as the current item in the queue.  
	;If it is, advance the queue. Else, equip the current item in the queue	
	Form currEquippedItem = PlayerRef.GetEquippedObject(slotID)
	Form currQItem = queue[currIndex]
	if(currEquippedItem != currQItem && currQItem != None)
        if(currQItem.GetName() == "Fist")
            UnequipHand(slotID)
            return true
        endIf
		if(ValidateItem(currQItem))
			UnequipHand(slotID)
			if(currQItem.getType() == 22)					
				PlayerRef.EquipSpell(currQItem as Spell, slotID)
			else
				PlayerRef.EquipItemEx(currQItem, equipSlotId, false, false)
			endIf
			return true
		else
			removeInvalidItem(slotID, currIndex)
		endIf
		;if item fails validation or curr equipped item check, move to next item in queue
	endIf	
		
	int newIndex = advanceQueue(slotID, 0)
	Form nextQItem = queue[newIndex]
    if(currQItem.GetName() == "Fist")
        UnequipHand(slotID)
        return true
    endIf
	if(ValidateItem(nextQItem))
		UnequipHand(slotID)
		if(nextQItem.getType() == 22)
			PlayerRef.EquipSpell(nextQItem as Spell, slotID)
		else
			PlayerRef.EquipItemEx(nextQItem, equipSlotId, false, false)
		endif
		return true
	else
		removeInvalidItem(slotID, newIndex)
	endIf
	return false
endFunction

;moves the queue to the next slot
int function advanceQueue_ASSIGNMENT_MODE(int queueID)
	int currIndex = _currQIndices[queueID]
	int newIndex
	if (currIndex == MAX_QUEUE_SIZE - 1)
		newIndex = 0	
	else
		newIndex = currIndex + 1	
	endIf
	_currQIndices[queueID] = newIndex
    return newIndex
endFunction

int function advanceQueue(int queueID, int depth)

	int newIndex = advanceQueue_ASSIGNMENT_MODE(queueID)
	;Recursively advance until there is an item in the queue or the entire length of the queue has been traversed
	if(!ValidateSlot(queueID) && depth < MAX_QUEUE_SIZE)
		newIndex = advanceQueue(queueID, depth + 1)
	endIf
	return newIndex
endFunction

;makes sure whatever is in the current slot is equippable.
bool function ValidateSlot(int queueID)
	int currIndex = _currQIndices[queueID]
	if queueID == 0
		if _leftHandQueue[currIndex] == None || !ValidateItem(_leftHandQueue[currIndex])
			return false
		endIf
	elseif queueID == 1 
		if _rightHandQueue[currIndex] == None || !ValidateItem(_rightHandQueue[currIndex])
			return false
		endIf
	elseif queueId == 2
		if _shoutQueue[currIndex] == None || !ValidateItem(_shoutQueue[currIndex])
			return false
		endIf
	elseif queueId == 3 
		if _potionQueue[currIndex] == None || !ValidateItem(_potionQueue[currIndex])
			return false	
		endIf
	endIf
	return true
endFunction

;--------------------------------------------------------------------------------------------------------------------
;Method taken directly from SKI_FavoritesManager.psc from the SkyUI team.  All credit to them.  Thank you!
;--------------------------------------------------------------------------------------------------------------------
;make sure the player has the item or spell and it is favorited
bool function ValidateItem(Form a_item)
	int a_itemType = a_item.GetType()
    int itemCount 

	if (a_item == None)
		return false
	endif
	; This is a Spell or Shout and can't be counted like an item
	if (a_itemType == 22 || a_itemType == 119)
		return PlayerRef.HasSpell(a_item)
	; This is an inventory item
	else 
        itemCount = PlayerRef.GetItemCount(a_item)
		if (itemCount < 1)
			Debug.Notification("You no longer have " + a_item.getName())
			return false
		endIf
	endIf
	;This item is already equipped, possibly in the other hand, and there is only 1 of it
	if ((a_item == PlayerRef.GetEquippedObject(0) || a_item == PlayerRef.GetEquippedObject(1)) && itemCount < 2)
		return false
	endif
	return true
endFunction

;if an item fails validation, remove it from the queue
function removeInvalidItem(int queueID, int index)

	if(queueID == 0)
		_leftHandQueue[index] = None
	elseif(queueID == 1)
		_rightHandQueue[index] = None
	elseif(queueID == 2)
		_shoutQueue[index] = None
	elseif(queueID == 3)
		_potionQueue[index] = None
	endIf

endFunction

;Getters for the widget script
String function getCurrQItemName(int queueID)
	int currIndex = _currQIndices[queueID]

	if(queueID == 0)
		return	_leftHandQueue[currIndex].getName()
	elseif(queueID == 1)
		return _rightHandQueue[currIndex].getName()
	elseif(queueID == 2)
		return _shoutQueue[currIndex].getName()
	elseif(queueID == 3)
		return _potionQueue[currIndex].getName()
	endIf
	return ""
endFunction 

function AssignCurrEquippedItem(Int aiSlot)
    Form obj = PlayerRef.GetEquippedObject(aiSlot)
    int ndx = _currQIndices[aiSlot]
    if(aiSlot == 0)
        _leftHandQueue[ndx] = obj 
    elseif(aiSlot == 1)
        _rightHandQueue[ndx] = obj 
    elseif(aiSlot == 2)
        _shoutQueue[ndx] = obj 
    endIf
endFunction
;-----------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------
;MCM events 
;-----------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------

int function GetVersion()
    return 4 ; version 1.20
endFunction

event OnVersionUpdate(int a_version)
    Debug.Notification("Updating SQM V1.20")
    waitsQueued = 0
    int ndx = 0
    ItemDataUpToDate = new bool[28]
    while ndx < 28
        ItemDataUpToDate[ndx] = false
        ndx += 1
    endWhile
endEvent 

function EmptyLists()
    int ndx = 0
    while ndx < 128
        _potionListName[ndx] = ""
        _shoutListName[ndx] = ""
        _rightHandListName[ndx] = ""
        _leftHandListName[ndx] = ""
        _potionList[ndx] = None
        _shoutsKnown[ndx] = None
        _rightHandList[ndx] = None
        _leftHandList[ndx] = None
        ndx +=1
    endWhile
endFunction
;initialize variables and arrays when the MCM is started up
Event OnConfigInit()
	;these are the names of the pages that appear in the MCM
	Pages = new String[5]
	Pages[0] = "General"
	Pages[1] = "Shout Group"
	Pages[2] = "Item Group"
	Pages[3] = "Left Hand Group"
	Pages[4] = "Right Hand Group"
    waitsQueued = 0
    if(!playerRef.getItemCount(Unarmed1H))
        PlayerRef.AddItem(Unarmed1H)
    endIf
    if(!playerRef.getItemCount(Unarmed2H))
        PlayerRef.AddItem(Unarmed2H)
    endIf
	_currQIndices = new int[4]

    _voiceSpells = new Spell[128]
	_potionListName = new string[128]
	_shoutListName = new string[128]
	_rightHandListName = new string[128]
	_leftHandListName = new string[128]

	_potionList = new Form[128]
	_shoutsKnown = new Form[128]
	_rightHandList = new Form[128]
	_leftHandList = new Form[128]

	_potionQueue = new Form[7]
	_shoutQueue = new Form[7]
	_rightHandQueue = new Form[7]
	_leftHandQueue = new Form[7]
 
	;initialize inventory lists for the combo boxes
	populateLists(PlayerRef)

	;initialize the indices of each of the 7 slots for each equipslot
	shoutListIndex = new Int[7]
	potionListIndex = new Int[7]
	leftListIndex = new Int[7]
	rightListIndex = new Int[7]

	;initialize Object ID's for the drop down menus of the 7 slots for each queue 
	shoutAssignOID = new Int[7]
	potionAssignOID = new Int[7]
	leftAssignOID = new Int[7]
	rightAssignOID = new Int[7]

	RegisterForKey(cycleLeftKey)
	RegisterForKey(cycleRightKey)
	RegisterForKey(cycleShoutKey)
	RegisterForKey(cyclePotionKey)
	RegisterForKey(usePotionKey)

EndEvent

;called every time a page is initialized
event OnPageReset(string page)
    SetCursorFillMode(TOP_TO_BOTTOM)

	;first page
    If (page == "General")
	    AddHeaderOption("HUD Settings")
	    visOID = AddToggleOption("Visibility On/Off", visVal)
	    transOID = AddSliderOption("Opacity", SQM.Alpha, "{0}%")
        mustBeFavoritedOID = AddToggleOption("Only Favorite Items", mustBeFavorited)
        
        ;x, y position and scale widget options
	    xOID = AddSliderOption("X", SQM.X, "{0}")
	    yOID = AddSliderOption("Y", SQM.Y, "{0}")
        scaleOID = AddSliderOption("Scale", SQM.mainScale, "{0}%")

        ;widget fade variable sliders
        int flags = 0
        ;grey out variables if fadeout isn't checked
        if(!fadeOut)
            flags = OPTION_FLAG_DISABLED
        endIf
        AddEmptyOption()
        AddHeaderOption("Fade Out")
        fadeOID = AddToggleOption("Fade Out On/Off", fadeOut)
        fadeAlphaOID = AddSliderOption("Fade Out Alpha", fadeAlpha, "{0}%", flags)
        fadeOutDurationOID = AddSliderOption("Fade Out Duration", fadeOutDuration, "{0}", flags)
        fadeInDurationOID = AddSliderOption("Fade In Duration", fadeInDuration, "{0}", flags)
        fadeWaitOID = AddSliderOption("Fade Wait Duration", fadeWait, "{0}", flags)
		;move cursor to top right position
	    SetCursorPosition(1)

	    AddHeaderOption("Key Bindings")
	    keyOID_CSHOUT = AddKeyMapOption("Cycle Shout Slot", cycleShoutKey, OPTION_FLAG_WITH_UNMAP)
	    keyOID_CPOTION = AddKeyMapOption("Cycle Potion Slot", cyclePotionKey, OPTION_FLAG_WITH_UNMAP)
	    keyOID_CLEFTHAND = AddKeyMapOption("Cycle Left Hand Slot", cycleLeftKey, OPTION_FLAG_WITH_UNMAP)
	    keyOID_CRIGHTHAND = AddKeyMapOption("Cycle Right Hand Slot", cycleRightKey, OPTION_FLAG_WITH_UNMAP)
	    keyOID_ACTIVATE = AddKeyMapOption("Consume Item/Potion", usePotionKey, OPTION_FLAG_WITH_UNMAP)
  
        AddEmptyOption()
        flags = OPTION_FLAG_WITH_UNMAP
        if(!ASSIGNMENT_MODE)
            flags = OPTION_FLAG_DISABLED
        endIf
        AddHeaderOption("Assign Equipped Mode")
        assignEquippedOID = AddToggleOption("Assignment Mode On/Off", ASSIGNMENT_MODE)
        keyOID_ASSIGNLEFT = AddKeyMapOption("Assign Left Hand Object", assignLeftKey, flags)
        keyOID_ASSIGNRIGHT = AddKeyMapOption("Assign Right Hand Object", assignRightKey, flags)
        keyOID_ASSIGNSHOUT = AddKeyMapOption("Assign Shout Object", assignShoutKey, flags)
    ;Shout page
    elseIf (page == pages[1])
        AddHeaderOption(pages[1])
		int ndx = 0
        ;Add an option for each of the 7 slots
		while ndx < MAX_QUEUE_SIZE 
			shoutAssignOID[ndx] = AddMenuOption("Slot " + (ndx + 1), _shoutQueue[ndx].getName())
			ndx += 1
		endWhile
		refreshOID = AddTextOption("Refresh Inventory Items", "") 
	;Potion page
    elseIf (page == pages[2])
        AddHeaderOption(pages[2])
		int ndx = 0
		while ndx < MAX_QUEUE_SIZE
			potionAssignOID[ndx] = AddMenuOption("Slot " + (ndx + 1), _potionQueue[ndx].getName())
			ndx += 1
		endWhile
		refreshOID = AddTextOption("Refresh Inventory Items", "") 
		refreshPotionsOID = AddTextOption("Refresh Potions List Only", "")
	;Left Hand page
    elseIf (page == pages[3])
        AddHeaderOption(pages[3])
		int ndx = 0
		while ndx < MAX_QUEUE_SIZE
			leftAssignOID[ndx] = AddMenuOption("Slot " + (ndx + 1), _leftHandQueue[ndx].getName())
			ndx += 1
		endWhile
		refreshOID = AddTextOption("Refresh Inventory Items", "")
	;Right Hand page
    elseIf (page == pages[4])
        AddHeaderOption(pages[4])
		int ndx = 0
		while ndx < MAX_QUEUE_SIZE
			rightAssignOID[ndx] = AddMenuOption("Slot " + (ndx + 1), _rightHandQueue[ndx].getName())
			ndx += 1
		endWhile
		refreshOID = AddTextOption("Refresh Inventory Items", "")
    endIf
endEvent
;function mapOnlyFavorites
;endFunction
;called when checkbox option is selected
event OnOptionSelect(int option)
    if (option == visOID)
        visVal = !visVal
		SQM.isVisible = !SQM.isVisible
		SetToggleOptionValue(visOID, SQM.isVisible)
    elseIf(option == mustBeFavoritedOID)
        mustBeFavorited = !mustBeFavorited
        SetToggleOptionValue(mustBeFavoritedOID, mustBeFavorited)
    elseIf (option == refreshOID)
        SetTextOptionValue(refreshOID, "Updating...")
        populateLists(PlayerRef)
        SetTextOptionValue(refreshOID, "")
    elseIf (option == refreshPotionsOID)
        SetTextOptionValue(refreshOID, "Updating...")
        populatePotionsList(PlayerRef)
        SetTextOptionValue(refreshOID, "") 
    elseIf (option == fadeOID)
        fadeOut = !fadeOut
        SetToggleOptionValue(fadeOID, fadeOut)
        int flags = 0
        if(!fadeOut)
            SQM.setTransparency(SQM.Alpha)
            flags = OPTION_FLAG_DISABLED
        else
            SQM.FadeOut(fadeAlpha, fadeOutDuration/100.0)
        endIf
        SetOptionFlags(fadeAlphaOID, flags)
        SetOptionFlags(fadeOutDurationOID, flags)
        SetOptionFlags(fadeInDurationOID, flags)
        SetOptionFlags(fadeWaitOID, flags)
    elseIf(option == assignEquippedOID)
        ASSIGNMENT_MODE = !ASSIGNMENT_MODE
        SetToggleOptionValue(assignEquippedOID, ASSIGNMENT_MODE)
        int flags 
        SQM.setAssignMode(ASSIGNMENT_MODE) 
        if(ASSIGNMENT_MODE)
            flags = OPTION_FLAG_WITH_UNMAP
            ;Change gem colors
            SQM.leftIndex = _currQIndices[0]
            SQM.rightIndex = _currQIndices[1]
            SQM.shoutIndex = _currQIndices[2]
            ;Register keys
            RegisterForKey(assignLeftKey)
            RegisterForKey(assignRightKey)
            RegisterForKey(assignShoutKey)
        else
            flags = OPTION_FLAG_DISABLED
            SQM.leftIndex = _currQIndices[0]
            SQM.rightIndex = _currQIndices[1]
            SQM.shoutIndex = _currQIndices[2]
            UnregisterForKey(assignLeftKey)
            UnregisterForKey(assignRightKey)
            UnregisterForKey(assignShoutKey)
        endIf
        SetOptionFlags(keyOID_ASSIGNLEFT, flags)
        SetOptionFlags(keyOID_ASSIGNRIGHT, flags)
        SetOptionFlags(keyOID_ASSIGNSHOUT, flags)   
    endIf
endEvent

;set the default options when the 'R' key is pressed
;this is not implemented for the inventory items
event OnOptionDefault(int option)
    If (option == visOID)
        visVal = true ; default value
        SetToggleOptionValue(visOID, visVal)
    elseIf (option == transOID)
        transVal = 100.0 ; default value
        SetSliderOptionValue(transOID, transVal, "{0}%")
    elseIf (option == keyOID_CSHOUT)
        cycleShoutKey = 45 ; default value
        SetKeyMapOptionValue(keyOID_CSHOUT, cycleShoutKey)
    elseIf (option == keyOID_CPOTION)
        cyclePotionKey = 21 ; default value
        SetKeyMapOptionValue(keyOID_CPOTION, cyclePotionKey)
    elseIf (option == keyOID_CLEFTHAND)
        cycleLeftKey = 47 ; default value
        SetKeyMapOptionValue(keyOID_CLEFTHAND, cycleLeftKey)
    elseIf (option == keyOID_CRIGHTHAND)
        cycleRightKey = 48 ; default value
        SetKeyMapOptionValue(keyOID_CRIGHTHAND, cycleRightKey)
    elseIf (option == keyOID_ACTIVATE)
        usePotionKey = 34 ; default value
        SetKeyMapOptionValue(keyOID_ACTIVATE, usePotionKey)
    elseIf (option == xOID)
        SQM.setX(10.0)
        SetSliderOptionValue(option, SQM.X, "{0}")
    elseIf (option == yOID)
        SQM.setY(300.0)
        SetSliderOptionValue(option, SQM.Y, "{0}")
    elseIf (option == scaleOID)
        SQM.setScale(100.0)
        SetSliderOptionValue(option, SQM.mainScale, "{0}")
    endIf
endEvent

;called when the slider menus appear
event OnOptionSliderOpen(int option)
	;transparency slider
	If (option == transOID)
		SetSliderDialogStartValue(SQM.Alpha)
		SetSliderDialogDefaultValue(100.0)
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(1.00)
    ;x position slider
	elseIf (option == xOID)
		SetSliderDialogStartValue(SQM.X)
		SetSliderDialogRange(0.00, 1280.00)
		SetSliderDialogInterval(1.00)
		SetSliderDialogDefaultValue(10.00)
	;y position slider
	elseIf (option == yOID)
		SetSliderDialogStartValue(SQM.Y)
		SetSliderDialogRange(0.00, 720.00)
		SetSliderDialogInterval(1.00)
		SetSliderDialogDefaultValue(300.00)
    elseIf (option == scaleOID)
        SetSliderDialogStartValue(SQM.mainScale)
		SetSliderDialogRange(0.00, 120.00)
		SetSliderDialogInterval(1.00)
		SetSliderDialogDefaultValue(100.00)
    elseIf (option == fadeAlphaOID)
        SetSliderDialogStartValue(fadeAlpha)
		SetSliderDialogRange(0.00, 100.00)
		SetSliderDialogInterval(1.00)
		SetSliderDialogDefaultValue(0.00)
    elseIf (option == fadeOutDurationOID)
        SetSliderDialogStartValue(fadeOutDuration)
		SetSliderDialogRange(0.00, 500.00)
		SetSliderDialogInterval(5)
		SetSliderDialogDefaultValue(200.00)
    elseIf (option == fadeInDurationOID)
        SetSliderDialogStartValue(fadeInDuration)
		SetSliderDialogRange(1.00, 100.00)
		SetSliderDialogInterval(1)
		SetSliderDialogDefaultValue(30) 
    elseIf (option == fadeWaitOID)
        SetSliderDialogStartValue(fadeWait)
		SetSliderDialogRange(0.00, 3000.00)
		SetSliderDialogInterval(50)
		SetSliderDialogDefaultValue(500) 
	endIf
endEvent

;called when the slider menu is accepted
event OnOptionSliderAccept(int option, float value)
	;transparency slider
    if (option == transOID)
        SQM.setTransparency(value)
		SetSliderOptionValue(transOID, SQM.Alpha, "{0}%")
	;x position slider
    elseIf (option == xOID)
		SQM.setX(value)
		SetSliderOptionValue(option, SQM.X, "{0}")
	;y position slider
    elseIf (option == yOID)
		SQM.setY(value)
		SetSliderOptionValue(option, SQM.Y, "{0}")
    elseIf (option == scaleOID)
		SQM.setScale(value)
		SetSliderOptionValue(option, SQM.mainScale, "{0}%")
    elseIf (option == fadeAlphaOID)
        fadeAlpha =  value
        SetSliderOptionValue(option,fadeAlpha, "{0}%")
    elseIf (option == fadeOutDurationOID)
        fadeOutDuration = value
        SetSliderOptionValue(option,fadeOutDuration, "{0}")
    elseIf (option == fadeInDurationOID)
        fadeInDuration = value
        SetSliderOptionValue(option,fadeInDuration, "{0}")
    elseIf (option == fadeWaitOID)
        fadeWait = value
        SetSliderOptionValue(option,fadeWait, "{0}")

    endIf
endEvent

;called when an MCM menu item is highlighted
event OnOptionHighlight(int option)
	;visibility
    If (option == visOID)
        SetInfoText("Check this option to toggle the visibility of the HUD\nDefault: true")

    elseIf (option == refreshOID)
        SetInfoText("Refreshes lists to show recently acquired items.  This will refresh all lists, so you don't need to do it for each queue.")
    ;transparency
    elseIf (option == transOID)
        SetInfoText("Click this option to adjust the HUD transparency\nDefault: 100.0")
    ;keyUp
    elseIf (option == keyOID_CSHOUT)
        SetInfoText("Select to bind key to cycle the shout slot\nDefault: X")

    ;keyDown
    elseIf (option == keyOID_CPOTION)
        SetInfoText("Select to bind key to cycle the potion slot\nDefault: Y\nSuggested: F, but you should first unassign F from 'Toggle POV' in the Controls Menu")

    ;keyLeft
    elseIf (option == keyOID_CLEFTHAND)
        SetInfoText("Select to bind key to left hand slot\nDefault: V\nSuggested: C, but you should first unassign C from 'Auto-move' in the Controls Menu")

    ;keyRight
    elseIf (option == keyOID_CRIGHTHAND)
        SetInfoText("Select to bind key to right hand slot\nDefault: B\nSuggested: V")

    ;keyActivate
    elseIf (option == keyOID_ACTIVATE)
        SetInfoText("Select to bind key to the consume item function\nDefault: G\nSuggested: L-SHIFT, but you should first unassign L-SHIFT from 'Run' in the Controls Menu")
    ;x position slider
    elseIf (option == xOID)
        SetInfoText("Change x location\nDefault: 0.0")
    ;y position slider
    elseIf (option == yOID)
        SetInfoText("Change y location\nDefault: 300.0")
    elseIf (option == mustBeFavoritedOID)
        SetInfoText("Only favorited items and spells will show up in the item group menus.  You may want to select this if you have a very large inventory. You will need to refresh your inventory items for the changes to take effect.")
    elseIf(option == fadeOID)
        SetInfoText("The widget will fade out of view when not in use")
    elseIf(option == fadeAlphaOID)
        SetInfoText("The alpha value to which the widget will fade after the allotted time.")
    elseIf(option == fadeOutDurationOID)
        SetInfoText("The amount of time (in centiseconds) it will take the widget to fade from visible to its faded alpha value.")
    elseIf(option == fadeInDurationOID)
        SetInfoText("The amount of time (in centiseconds) it will take the widget to fade into view after a key is pressed.")
    elseIf(option == fadeWaitOID)
        SetInfoText("The amount of time (in centiseconds) the widget will wait after the last key is pressed to begin fading.")
    elseIf(option == assignEquippedOID)
        SetInfoText("In assignment mode, you can assign currently equipped items and spells to your queues.  Cycling through the queue will not skip empty slots and weapons / spells will not actually equip.  Disable when done.  Assignment keys will only work when this is on.")
    elseIf(option == keyOID_ASSIGNLEFT)
        SetInfoText("Pressing this key will assign the weapon, spell, or item in your left hand to the current slot in the left hand queue.")
    elseIf(option == keyOID_ASSIGNRIGHT)
        SetInfoText("Pressing this key will assign the weapon, spell, or item in your right hand to the current slot in the left hand queue.")
    elseIf(option == keyOID_ASSIGNSHOUT)
        SetInfoText("Pressing this key will assign the shout or ability in your power slot to the current slot in the left hand queue.")
    elseIf(option == refreshPotionsOID)
        SetInfoText("Refreshes your potion list (and only your potion list).  This is just slightly quicker than updating everything.")
    endIf

endEvent

;Method taken from MCM API reference
bool function checkKeyConflict(string conflictControl, string conflictName)
    bool continue = true
    if (conflictControl != "")
        string msg
        if (conflictName != "")
            msg = "This key is already mapped to:\n\"" + conflictControl + "\"\n(" + conflictName + ")\n\nAre you sure you want to continue?"
        else
            msg = "This key is already mapped to:\n\"" + conflictControl + "\"\n\nAre you sure you want to continue?"
        endIf
        continue = ShowMessage(msg, true, "$Yes", "$No")
    endIf
    return continue
endFunction

Int function switchKeyMaps(int oldKey, int newKey)
    UnregisterForKey(oldKey)
    RegisterForKey(newKey)
    return newKey
endFunction

;called when a key map box is changed
event OnOptionKeyMapChange(int option, int keyCode, string conflictControl, string conflictName)
    If (option == keyOID_CSHOUT)
        if(checkKeyConflict(conflictControl, conflictName))
            ;Unregister old key, register new key
            cycleShoutKey = switchKeyMaps(cycleShoutKey, keyCode) 
            ;Change the displayed key in MCM
            SetKeyMapOptionValue(keyOID_CSHOUT, cycleShoutKey)
        endIf
    elseIf (option == keyOID_CPOTION)
        if(checkKeyConflict(conflictControl, conflictName))
            cyclePotionKey = switchKeyMaps(cyclePotionKey, keyCode) 
            SetKeyMapOptionValue(keyOID_CPOTION, cyclePotionKey)
        endIf
    elseIf (option == keyOID_CLEFTHAND)
        if(checkKeyConflict(conflictControl, conflictName))
            cycleLeftKey = switchKeyMaps(cycleLeftKey, keyCode)
            SetKeyMapOptionValue(keyOID_CLEFTHAND, cycleLeftKey)
        endIf
    elseIf (option == keyOID_CRIGHTHAND)
        if(checkKeyConflict(conflictControl, conflictName))
            cycleRightKey = switchKeyMaps(cycleRightKey, keyCode)
            SetKeyMapOptionValue(keyOID_CRIGHTHAND, cycleRightKey)
        endIf
    elseIf (option == keyOID_ACTIVATE)
        if(checkKeyConflict(conflictControl, conflictName))
            usePotionKey = switchKeyMaps(usePotionKey, keyCode)
            SetKeyMapOptionValue(keyOID_ACTIVATE, usePotionKey)
        endIf
    elseIf(option == keyOID_ASSIGNLEFT)
        if(checkKeyConflict(conflictControl, conflictName))
            assignLeftKey = switchKeyMaps(assignLeftKey, keyCode)
            SetKeyMapOptionValue(keyOID_ASSIGNLEFT, assignLeftKey)
        endIf
    elseIf(option == keyOID_ASSIGNRIGHT)
        if(checkKeyConflict(conflictControl, conflictName))
            assignRightKey = switchKeyMaps(assignRightKey, keyCode)
            SetKeyMapOptionValue(keyOID_ASSIGNRIGHT, assignRightKey)
        endIf
    elseIf(option == keyOID_ASSIGNSHOUT)
        if(checkKeyConflict(conflictControl, conflictName))
            assignShoutKey = switchKeyMaps(assignShoutKey, keyCode)
            SetKeyMapOptionValue(keyOID_ASSIGNSHOUT, assignShoutKey)
        endIf 
    endIf
endEvent

;called when the drop down menu is opened for selecting queue items
event OnOptionMenuOpen(int option)
	Int iElement = 0
	While iElement < shoutAssignOID.Length
		If (option == shoutAssignOID[iElement])
	      		SetMenuDialogOptions(_shoutListName)
          		SetMenuDialogStartIndex(shoutListIndex[iElement])
        		SetMenuDialogDefaultIndex(0)
		endIf
		iElement += 1
	endWhile

	iElement = 0
	While iElement < potionAssignOID.Length
		If (option == potionAssignOID[iElement])
	      		SetMenuDialogOptions(_potionListName)
          		SetMenuDialogStartIndex(potionListIndex[iElement])
        		SetMenuDialogDefaultIndex(0)
		endIf
		iElement += 1
	endWhile

	iElement = 0
	While iElement < leftAssignOID.Length
		If (option == leftAssignOID[iElement])
	      		SetMenuDialogOptions(_leftHandListName)
          		SetMenuDialogStartIndex(leftListIndex[iElement])
        		SetMenuDialogDefaultIndex(0)
		endIf
		iElement += 1
	endWhile

	iElement = 0
	While iElement < rightAssignOID.Length
		If (option == rightAssignOID[iElement])
	      		SetMenuDialogOptions(_rightHandListName)
          		SetMenuDialogStartIndex(rightListIndex[iElement])
        		SetMenuDialogDefaultIndex(0)
		endIf
		iElement += 1
	endWhile

endEvent

;called when a combo box option is selected
event OnOptionMenuAccept(int option, int index)

	Int iElement = 0
	While iElement < shoutAssignOID.Length
		If (option == shoutAssignOID[iElement])
			_shoutQueue[iElement] = _shoutsKnown[index]
            shoutListIndex[iElement] = index
            ItemDataUpToDate[2*MAX_QUEUE_SIZE + iElement] = false
            SetMenuOptionValue(shoutAssignOID[iElement], _shoutQueue[iElement].getName())
		endIf
		iElement += 1
	endWhile

	iElement = 0
	While iElement < potionAssignOID.Length
		If (option == potionAssignOID[iElement])
			_potionQueue[iElement] = _potionList[index]
            ItemDataUpToDate[3*MAX_QUEUE_SIZE + iElement] = false
            potionListIndex[iElement] = index
            SetMenuOptionValue(potionAssignOID[iElement], _potionQueue[iElement].getName())
		endIf
		iElement += 1
	endWhile

	iElement = 0
	While iElement < leftAssignOID.Length
		If (option == leftAssignOID[iElement])
			_leftHandQueue[iElement] = _leftHandList[index]
            ItemDataUpToDate[iElement] = false
            leftListIndex[iElement] = index
            SetMenuOptionValue(leftAssignOID[iElement], _leftHandQueue[iElement].getName())
		endIf
		iElement += 1
	endWhile

	iElement = 0
	While iElement < rightAssignOID.Length
		If (option == rightAssignOID[iElement])
			_rightHandQueue[iElement] = _rightHandList[index]
            ItemDataUpToDate[MAX_QUEUE_SIZE + iElement] = false
            rightListIndex[iElement] = index
            SetMenuOptionValue(rightAssignOID[iElement], _rightHandQueue[iElement].getName())
		endIf
		iElement += 1
	endWhile
endEvent
;-----------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------
;END MENU WIDGET CODE
;-----------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------


