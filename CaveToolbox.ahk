#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#IfWinActive, ahk_class StarCraft II
#SingleInstance force
#Persistent
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetDefaultMouseSpeed, 0
FileEncoding, UTF-8
DetectHiddenWindows, On
SetTitleMatchMode, 2

; configue this ::
global globalsleep  := 100   ; ping related set Higher if script bugs out cause to fast
    , withOpenInv   := false ; set to not toggle inv and keep it open
    , miniMap       := true  ; if you want to use the Minimap extentions
    , stdRarity     := 3     ; 0 = Norma, Magic, Rare, Epic, Leg, Twilight = 5
    , enableLogging := true  ; shows tooltips bottom left
    , toolTipDelay  := 2     ; seconds how long ToolTips stay up
    , minimapLvl    := 1     ; 1-3: 1 = just Outline, 2 = Bosses, 3 = Full
    , keyArray      := ["010","011","012","013","014","021","022","02C","02D","030"]
    , testingMode   := false ; switches send location for lobbybot to only lobby 
    , sndScreen     := false  ; 
    , sndScreenLoc  := 1     ; 1= above,2=right,3=below,4=left
    , useCapture    := true ; 
/* 
    keyArray has the Scan Codes (SC) for the standard Grid buttons
    if you need more, you will have to lookup how to find them.
    check reference the german key name on the same position and add it to keyArray.
    https://kbdlayout.info/kbdgr/scancodes+virtualkeys
    , keyList       := "q|w|e|r|t|f|g|y|x|b" ;
    correspomds to 
      RU:= "йцукеапячи" 
      FR:= "azertfgwxb" 
      EN:= "qwertfgzxb" 
    AHK needs a leading 0 on most of the keys
    special keys: ^ 29|ß 0c|´ 0d|ü 1a|+ 1b|ö 27|ä 28|# 2b|, 33|. 34|- 35|< 56| 
    
    if you have multiple languages setup you have to alt-tab to other window 
    and back to sc2, if you switch languages while ingame, to update the hotkeys 
    as well as reload the script once or it screws up your typing. 
*/
    
; lobby bot::    
global lvlingLobby  := true  ; true = normal, false = endgame
    , updateArcade  := true ; send lobbylink in general chat every 5 min 
    , updateLobby   := true  ; send starting time to lobby chat 
    , lobbyTitle    := testingMode ? "just testing" : "WoW/D2 like RPG, All Welcome"
    , lobbyTimer    := 25   ; min 
    , quickStartTime:= 1
    , quickStart    := true
    , globalNum     := 1    ; number of Arcade global chat 
    , globalMsg     := globalNum . " /lobbylink " . lobbyTitle
    , globalChat    := testingMode ? "/l " . globalMsg : "/" . globalMsg
    , globUpdateTmr := 5*60000
    , lobbyTimeMsg  := "/l " . "Game Starts in: " 
    , addTime       := 1    ; min  
    , updateInterval:= 60   ; 5 ; seconds 
    , amountPlayers := 7    ; 2-10 : amount after which quickstart kicks in
    , w8TillIngame  := (4 * 60) ; seconds
    , ingameW8Time  := (2 * 60) ; seconds 
    , welcomeArray  := [] 
    , mtSlotColors  := []
    , lobbyArray    := []
    , globalArray   := []
    , lobbyMsging   := true 
    , timeinLobby   := 0 
    , jMsg1 := "Thy will be done, "
    , jMsg2 := "Welcome, "


; Messages for Global chat
gMsg1 := "The Emperor needs new Recruits, signup bonus for first 6 ppl."
gMsg2 := "Join to Defend the Keep or just watch it Burn{!}"
gMsg3 := "Come enter the Cave, the monsters are peacefull i promise."
gMsg4 := "Escort Timmy to another Castle."
; Messages for Lobby chat 
lMsg1 := "The Cave is like WoW, you can hop in for a few quests or spend Hours lvling chars or beating dungeons of various difficulties."
tmp1  := "Quickstart enabled, timer goes to " quickStartTime " min at " amountPlayers " ppl, stay in lobby till it starts."
tmp2  := "Quickstart disabled, w8ing full duration." 
lMsg2 := quickStart? tmp1 : tmp2
lMsg3 := "Bot is automated, impatient 'go' ppl don't influence the timer, instead go /watch?v=dQw4w9WgXcQ and game will start when you get back."   
lMsg4 := "Beware the afk timer, lobby may start without you." 
lMsg5 := "Not enough ppl here at this hour? Join the EU-Discord at /TSeUMvQhgt, and see who is online to lobby instantly."
lMsg6 := "The dev is to lazy to write patchnotes, but he does still update the game regularly."
lMsg7 := "You tried the game once but think the ui was bit too much clicking?, then hop on the EU-discord and get yourself the ahk-Toolbox."
lMsg8 := "Write your lvl or new in chat to tell ppl who to party with."
; Messages for Ingame Welcome
wMsg1 := "Welcome to The Cave, if you're new pick any Char and join a party to start questing."
wMsg2 := "For help(Guides,Locations,...) look at www.thecave.xyz"
wMsg3 := "The game autosaves with backups, so don't worry about your progress" 
wMsg4 := "If you manage to reach lvl 50 and or plan to play actively, join the Discords for Endgame Content at EU:/TSeUMvQhgt and US:/Zsv65yKBKx"
wMsg5 := "Bot is hungry for more ppl, so GL HF and may the loot-rng be forever in your favor."   

globalArray.Push(gMsg1,gMsg2,gMsg3,gMsg4)
lobbyArray.Push(lMsg1,lMsg2,lMsg3,lMsg4,lMsg5,lMsg6,lMsg7,lMsg8)    
welcomeArray.Push(wMsg1,wMsg2,wMsg3,wMsg4,wMsg5)
mtSlotColors.Push("0x040D18" , "0x050D18" , "0x050E18")    
; rest needs no changes, edit at your own risk :D 
     
; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
; variables --------------------------------------------------------------
global itemSize     := 1
	, stop          := false ; flag to halt functions
    , mapOpen       := false ; flag for gui 
    , miniMapOpen   := false  
    , osdOpen       := false 
    , typing        := true 
    , ingame        := false 
    , lobbyBotActive:= false 
    , filtered      := false
    , onMapTime     := 0 
    , mapStartTime  := 0 

; Lobby bot ::
global lobbySelect  := [ 1300 , 212 ] 
    , selectDelta   := 40
    , playersDelta  := 62 
    , maxPlayers    := 10
    , playersSlot   := [  130, 213 ]
    , lobbyPublic   := [  480, 875 ]
    , lobbyQuit     := [  750, 875 ]
    , lobbyStartUI  := [  222, 875 ]
    , playAgainUI   := [  425, 875 ] 
    , nameUI        := [ 1536, 127 ]
    , remainingTime := lobbyTimer 
    ; , startColor    := "0x612A08" 
    , startingColor := "0x130F0D" ; 
    , splashColor   := "0x1B1810" 
    , mtSlotColor   := "0x040D18" ; 
    , nameColor     := "0xFFFFFF"
    , slotNameRect  := [ 160, 200, 400, 226 ] 
    , slotArray := []
    
global dungeonList := "1,2,3,4,5,6,7,8,9,a,b,c"    
; Toggles
global toggleWheelDown := false     

; Resolution relative positions: only 1920-1080 supported atm
global NativeScreenHeight   := 1080
	, NativeScreenWidth     := 1920
	, ScreenResolution      := NativeScreenWidth * NativeScreenHeight
	, centerScreen          := [ NativeScreenWidth / 2 , NativeScreenHeight / 2 ]
    
; Inventory 
global iSlotDelta    :=  50 ; length between inventory slots
	, firstSlot     := [ 1660 , 515 ] 
	, TopLeftInv    := [ 1400 , 560 ] 
	, Columns       :=   5 
	, Rows          :=   4
    , overflow      := [ 1660 , 810 ] 
    
; filter 
global firstRarity  := [ 1320 , 385 ]
    , fSlotDelta    :=  26 ; 384,410, 436, 466 , 490 , 518
    
; Equipment
global eSlotDeltaV  :=  67 ; 607 674 741
    , eSlotDeltaH   :=  60 ; 42 103 162
	, firstESlot    := [  50 , 600 ] ; 3x3 
    , charmSlot     := [  26 , 554 ]  
; Stash
global sSlotDeltaV  :=  90 ; 315 405 495
    , sSlotDeltaH   := 100 ; 430 530 630
	, firstSSlot    := [  340 , 220 ] ; 6x4 
    
; Inn
global innItemSlot  := [  310 , 550 ] ;

; Menu buttons
global questsUI     := [  350 , 835 ]  
    , mapUI         := [  350 , 880 ] 
    , statsUI       := [  350 , 925 ] 
    , stats2UI      := [  540 , 660 ] 
    , inventoryUI   := [  350 , 970 ] 
    , partyUI       := [  350 ,1015 ] 
    , helpUI        := [  350 ,1060 ] 
    , equipUI       := [ 1410 , 735 ] 
    , moveInvUI     := [ 1410 , 795 ] 
    , dropUI        := [ 1410 , 855 ] 
    , sellUI        := [ 1160 , 590 ] 
    , buyUI         := [  530 , 590 ] 
    , withdrawUI    := [  400 , 805 ] 
    , depositUI     := [  760 , 805 ] 
    , moveStashUI   := [  400 , 612 ] 
    , greedUI       := [  165 ,  60 ] 
    , destroyUI     := [  625 , 515 ] 
    , stashNxtUI    := [  580 , 750 ] 
    , generateUI    := [  310 , 465 ] 
    , attacksUI     := [  745 , 600 ] 
    , tagsUI        := [  745 , 545 ] 
    , achivsUI      := [  760 , 660 ] 
    , filterUI      := [ 1540 , 720 ] 
    
; CLose buttons     
global questsCL     := [  760 , 690 ]  
    , mapCL         := [  520 , 720 ] 
    , statsCL       := [  990 , 660 ] 
    , stats2CL      := [  850 , 490 ] 
    , partyCL       := [  395 ,1050 ] 
    , helpCL        := [  250 , 760 ] 
    , filterCL      := [ 1420 , 660 ] 
    , stashCL       := [  580 , 850 ] 
    , battleCL      := [ 1100 , 700 ] 
    , innCL         := [  750 , 690 ] 
    , trainCL       := [  570 , 660 ] 
    , glyphCL       := [  790 , 610 ] 
    , wonderCL      := [ 1200 , 450 ] 
    , legCL         := [  910 , 740 ]  
    , beastCL       := [ 1200 , 720 ]  
    , beast2CL      := [ 1200 , 720 ]  
    , smithCL       := [  850 , 705 ] 
    , potsCL        := [  790 , 610 ] 
    , arenaCL       := [  615 , 655 ] 
    , talkCL        := [  120 , 530 ]    
    , dungCL        := [  610 , 610 ] 
    , achivsCL      := [ 1400 , 830 ] 
    
; Teleporter
global firstTSlot   := [  315 , 239 ]  
    , tSlotDelta    :=  54 ;239,293,347,402
    
; OSD:
global osdPos := [ 990, 920 ]
    , osdCurrPos := [ 990, 920 ]
    , osdX  := osdPos[1]
    , osdY  := osdPos[2]
; Map    
global mapName := "thecave_map.png"	; map name, put in the same folder as this script
    ,mWidth  := 735-75  ; 825	Width of map.
    ,mHeight := 685-115 ; 730	Height of map.
    
; Minimap 
global  mMTFolder   := "\Minimaps" 
    , mMFolder1     := "\Outline\"
    , mMFolder2     := "\Bosses\"
    , mMFolder3     := "\Full\"
    , mMPath        := A_ScriptDir mMTFolder mMFolder%minimapLvl%
    , mMName        := "World's End Keep"
    , mMExt         := ".png"
    , mMFullPath    := mMPath mMname mMExt
    , newImgName    := mMName
    , mMWidth       := 270
    , mMHeight      := 248
    , mMtLpt        := [  0, 832 ]
    , mMCurrPos     := [  0, 832 ]
    , miniMapRect   := [ 45, 808, 232, 828 ] 
    , tpAreas := ["Dungeon","World's End Keep","Highlands","Cesspool","Mountain Pass","CrossRoads"
        ,"Wayward Tundra","Barren Peak","Sacred Cave"]
    , areaKVMap := {"WK":"World's End Keep","CE":"The Cave - Entrance","CI":"The Cave (Interior)"
        ,"FP":"Farmers Plot","AB":"Abandoned Fields","KF":"Kings Forest","HI":"Highlands","TL":"The Ledge"
        ,"DF":"Dark Forest","AH":"Arid Hills","ML":"Marshlands","CP":"Cesspool","TF":"Trolls Forest"
        ,"OA":"Oasis","CO":"Coast","SW":"Sandy Waste","MP":"Mountain Pass","SL":"Scorched Lands","CR":"CrossRoads"
        ,"AF":"Ancient Forest","WT":"Wayward Tundra","IL":"Icy Lake","FR":"Frozen Pass","GL":"Glacier Melt"
        ,"TF":"Tainted Forest","BP":"Barren Peak","SF":"Static Fields","VR":"Volcanic Ring"
        ,"UO":"Upper Ogre Pass","LO":"Lower Ogre Pass","LF":"Lava Flow","D1":"Dungeon 1"
        ,"D2":"Dungeon 2","D3":"Dungeon 3","D4":"Dungeon 4","D5":"Dungeon 5","D6":"Dungeon 6","D7":"Dungeon 7"
        ,"D8":"Dungeon 8","D9":"Dungeon 9","DA":"Dungeon 10","DB":"Dungeon 11","DP":"Purge","SC":"Sacred Cave"} 
    , shortList     := ""        
    , dungeonActive     := false   
    , currentDungeon    := "ToBeSelected"
; ----------------------------------------------------------------------
osdCurrPos := sndScreen ? convertToSndScreenCords(osdPos) : osdPos
osdX  := osdCurrPos[1]
osdY  := osdCurrPos[2]

mMCurrPos := sndScreen ? convertToSndScreenCords(mMtLpt) : mMtLpt
mMx := mMCurrPos[1]
mMy := mMCurrPos[2]
; init slot Array 
slotArray[1] := true
slotID := 2
while(slotID < maxPlayers+1){
    slotArray[slotID]:= false
    slotID++
}
; init shortList
For short, full in areaKVMap{
    shortList .= short . ","
}
shortList := RTrim(shortList,",") 

; setup Skill Hotkeys
For keyIndex, key in keyArray{
    Hotkey, IfWinActive, ahk_class StarCraft II
    Hotkey, SC%key%, triggerSkillHotkey
}

; setup TP Hotkeys
Loop, 9 ; 9 available TP-Locations
{   
    Hotkey, IfWinActive, ahk_class StarCraft II
    Hotkey, +%A_Index%, triggerTeleportHotkey
}

Orange := "FF8800"

; Creates the Map-overlay
Gui,MapGui: -caption +ToolWindow +AlwaysOnTop +LastFound +Disabled
Gui,MapGui: Margin, 0, 0
Gui,MapGui: add, picture, w%mWidth% h%mHeight%, %mapName% 
Gui,MapGui: Show, hide x75 y115

; Creates the Mini-Map-overlay
Gui,MiniMapGui: -caption +ToolWindow +AlwaysOnTop +LastFound +Disabled HWNDminiMapHwnd
Gui,MiniMapGui: Margin, 0, 0
Gui,MiniMapGui: Add, picture, vMinimap w%mMWidth% h%mMHeight%, %mMFullPath%
Gui,MiniMapGui: Show, hide x%mMx% y%mMy%
WinSet, TransColor, "FFFFFF" 255
CustomColor := "EEAA99"  ; Can be any RGB color (it will be made transparent below).
Gui,OSD: +LastFound +AlwaysOnTop -Caption +ToolWindow +Disabled ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
Gui,OSD: Color, %CustomColor%
Gui,OSD: Margin, 0, 0
Gui,OSD: Font, s10 , Arial
Gui,OSD: Add, Text, vAD c%Orange%,Active Dungeon: %currentDungeon% 
Gui,OSD: Add, Text, vTyping c%Orange%,Typing: YYYYYYYY 
Gui,OSD: Add, Text, vMMArea c%Orange%,MM-Area: World's End Keep  ; Abandoned Fields YYYYYYYYYYYYYYY
Gui,OSD: Add, Text, vMMTimer c%Orange%,On-Map Time: YYYYYYYYYYYY
Gui,OSD: Show, hide x%osdX% y%osdY%
;Make all pixels of this color transparent and make the text itself translucent (150):
WinSet, Transparent, 100
Winset, exstyle, ^0x20
WinSet, TransColor, %CustomColor% 150 ;

UpdateOSD()

Loop{ ; Maps only active if sc2 in focus
	WinWaitActive ahk_class StarCraft II
    if(osdOpen){
        osdCurrPos := sndScreen ? convertToSndScreenCords(osdPos) : osdPos
        osdX  := osdCurrPos[1]
        osdY  := osdCurrPos[2]
        Gui,OSD: Show, NoActivate x%osdX% y%osdY%
    }
	if(mapOpen)
        Gui,MapGui: Show, NoActivate
    if(miniMapOpen){
        mMCurrPos := sndScreen ? convertToSndScreenCords(mMtLpt) : mMtLpt
        mMx := mMCurrPos[1]
        mMy := mMCurrPos[2]
        Gui,MiniMapGui : Show, NoActivate x%mMx% y%mMy%
    }
	WinWaitNotActive ahk_class StarCraft II
    Gui,OSD: Hide
	Gui,MapGui: Hide
    Gui,MiniMapGui: Hide
}
return

updateOSD(){
    global
    typingstatus := typing? "active" : "inactive" 
    GuiControl,OSD:, Typing,% "Typing: " typingstatus 
}


; Hotkeys:----------------------------------------------------------
/*
   Assigns Ctrl-Alt-x as a hotkey to restart the script.
*/
^!SC02D::
backupLogFile()
Reload 

/*
    stops hotkeys from activateing while typing in chat
*/
Enter:: 
    toggleTypingMode(){
        global
        if(ingame){
            typing := !typing   
            toolTipLog("T:" typing)
            updateOSD()
        }
        Send, {Enter}
    }
/*
    Ger: z-Key 
    toggles 2nd monitor mode
*/ 
AppsKey & SC015::
    toggleSndScreen(){
        sndScreen :=!sndScreen
        tooltipLog("sndScreen:" sndScreen)
    }
    
/*
    Ger: t-Key 
    toggles capture2text or manual mode
*/ 
AppsKey & SC014::
    toggleUseCapture(){
        useCapture := !useCapture
        tooltipLog("useCapture:" useCapture)
    }
/*
    Ger: o-Key 
    toggles on screen display 
*/
AppsKey & SC018:: 
    toggleOSD(){
        global
        if(ingame){
            if(osdOpen){ ; close it 
                Gui,OSD: hide
            }else{ ; open it
                osdCurrPos := sndScreen ? convertToSndScreenCords(osdPos) : osdPos
                osdX  := osdCurrPos[1]
                osdY  := osdCurrPos[2]
                Gui,OSD: show, NoActivate x%osdX% y%osdY%
            }
            Sleep, globalsleep
            osdOpen := !osdOpen
            toolTipLog("OSD:" osdOpen)
            centerMousePosition()
        }
    }
/*
    Ger: l-Key 
    iterates over preset Detail lvls of the Minimap 
    by selecting the folder they are in.
*/    
AppsKey & SC026:: 
    switchMMDetailLvl(){
        local mMx,mMy
        if(ingame){
            mMCurrPos := sndScreen ? convertToSndScreenCords(mMtLpt) : mMtLpt
            mMx := mMCurrPos[1]
            mMy := mMCurrPos[2]
            if(miniMapOpen){ ; close it 
                Gui,MiniMapGui: hide
                replaceMiniMapImg(true,false)
                Gui,MiniMapGui: show, NoActivate x%mMx% y%mMy%
            }else{ ; open it
                replaceMiniMapImg(true,false)
                Gui,MiniMapGui: show, NoActivate x%mMx% y%mMy%
                miniMapOpen := !miniMapOpen
            }
        }
    }

/*
    Ger: m-Key
    Toggles the Minimap
*/
AppsKey & SC032:: 
    displayMiniMap(){
        local mMx,mMy
        if(ingame){
            if(miniMapOpen){ ; close it 
                Gui,MiniMapGui: hide
            }else{ ; open it
                mMCurrPos := sndScreen ? convertToSndScreenCords(mMtLpt) : mMtLpt
                mMx := mMCurrPos[1]
                mMy := mMCurrPos[2]
                Gui,MiniMapGui: show, NoActivate x%mMx% y%mMy%
            }
            Sleep, globalsleep
            miniMapOpen := !miniMapOpen
            toolTipLog("MM:" miniMapOpen)
            centerMousePosition()
        }
    } 

/*
    activates the current Minimap by reading the 
    Mapname from ingame
*/
Tab::
    reloadMiniMap(){
        local mMx,mMy
        if(!typing && ingame){
            mapStartTime:= A_TickCount
            SetTimer, updateOnMapTime, 1000
            mMCurrPos := sndScreen ? convertToSndScreenCords(mMtLpt) : mMtLpt
            mMx := mMCurrPos[1]
            mMy := mMCurrPos[2]
            if(miniMapOpen){ ; close it 
                Gui,MiniMapGui: hide
                replaceMiniMapImg()
                Gui,MiniMapGui: show, NoActivate x%mMx% y%mMy%
            }else{ ; open it
                replaceMiniMapImg()
                Gui,MiniMapGui: show, NoActivate x%mMx% y%mMy%
                miniMapOpen := !miniMapOpen
            }
            Sleep, globalsleep 
        }else{
            Send, {%A_ThisHotkey%}
        }
    }  

/*
    Ger: c-Key
    clears the remembered Dungeon 
    so a new one can be selected
*/
AppsKey & SC02E::     
    clearActiveDungeon(){
        if(dungeonActive){
            currentDungeon := ""
            dungeonActive  := false
            GuiControl,OSD:, AD,% "Active Dungeon: cleared"  
            tooltipLog("AD cleared")
        }
    }
        
Insert:: ; in lobby or ingame
    switchGameState()
return 

Delete::
    killBot(){
        global 
        if(lobbyBotActive){
            toggleBot()
        }else{
            Send, {%A_ThisHotkey%}
        }
    } 

Home::
    startLobbyBot(){
        global
        if(!lobbyBotActive){
            toggleBot()
        }else{
            Send, {%A_ThisHotkey%}
        }
    }
    
Space::
    closeTalkWindow(){
        global 
        if(!typing){
            MouseClick, left, talkCL[1], talkCL[2]
            centerMousePosition()
        }else{
            Send, {%A_ThisHotkey%}
        }
    }

/*
    deactivates rightclick spam
*/    
WheelUP::
    deactivateForceMove(){
        global
        if(ingame){
            if(typing){
                Send, {%A_ThisHotkey%}
            }else{
                breakForceMove()
            }
        }else{
            Send, {%A_ThisHotkey%}
        }
    }

/*
    activates rightclick spam to 
    make char movement only require 
    moveing the mouse
*/
WheelDown:: 
    activateForceMoveManualBreak(){
        global
        if(ingame){
            if(typing){
                Send, {%A_ThisHotkey%}
            }else{
                forceMoveAndBreak()
            }
        }else{
            stop := true
            Send, {%A_ThisHotkey%}
        }
    }

/*
    Ger: .-Key
    while holding down the key 
    it spams leftclicks 
    so you don't have to
*/
SC034:: 
    spamLeftClick(){ 
        global
        if(!typing){
            MouseGetPos, x,y 
            Sleep 50
            MouseClick, left, %x%, %y%
            Sleep 50
        }else{
            Send, {%A_ThisHotkey%}
        }
    }

/*
    Ger: ß-Key
    Oneclick toggle of TextTags 
    for Healers or visibility 
*/    
SC00C:: 
    disableTextTags(){
        global
        if(!typing){
            MouseClick, left, statsUI[1], statsUI[2]
            Sleep, globalsleep*2
            MouseClick, left, tagsUI[1], tagsUI[2]
            Sleep, globalsleep
            MouseClick, left, statsCL[1], statsCL[2]
            centerMousePosition()
        }else{
            Send, {%A_ThisHotkey%}
        }
    }

/*
    Oneclick disables autoattacks
    usefull for tanks, d4 first boss ...
*/    
0:: ; open Statistics & disable attacks
    disableAutoAttacks(){
        if(!typing){
            MouseClick, left, statsUI[1], statsUI[2]
            Sleep, globalsleep*2
            MouseClick, left, attacksUI[1], attacksUI[2]
            Sleep, globalsleep
            MouseClick, left, statsCL[1], statsCL[2]
            centerMousePosition()
        }else{
            Send, {%A_ThisHotkey%}
        }
    }

/*
    Ger: l-Key
    Opens the 2nd stat window, 
    to check other ppl's gear/ progress
*/
SC026::
Numpad1::
    openExtendedStatistics(){
        static OpenExtStat := false
        global
        if(!typing){
            if(OpenExtStat){
                MouseClick, left, stats2CL[1], stats2CL[2]
            }else{
                MouseClick, left, statsUI[1], statsUI[2]
                Sleep, globalsleep*2
                MouseClick, left, stats2UI[1], stats2UI[2]
                Sleep, globalsleep
                MouseClick, left, statsCL[1], statsCL[2]
            }
            Sleep, globalsleep
            OpenExtStat := !OpenExtStat
            centerMousePosition()
        }else{
            Send, {%A_ThisHotkey%}
        }
    }

/*
    Ger: o-Key
    Opens Achivment window via the stats window
*/    
SC018:: 
Numpad2::
    openAchivments(){
        static OpenAchivments := false
        global
        if(!typing){
            if(OpenAchivments){ ; close it 
                MouseClick, left, achivsCL[1], achivsCL[2]
            }else{ ; open it
                MouseClick, left, statsUI[1], statsUI[2]
                Sleep, globalsleep*2
                MouseClick, left, achivsUI[1], achivsUI[2]
                Sleep, globalsleep
                MouseClick, left, statsUI[1], statsUI[2]
            }
            Sleep, globalsleep
            OpenAchivments := !OpenAchivments
            centerMousePosition()
        }else{
            Send, {%A_ThisHotkey%}
        }
    }    

/*
    Ger: ,-Key
    sets the Loot-filter to the preset lvl
*/
SC033:: ;,:: 
Numpad3::
    setStandardFilter(){
        global
        if(!typing){
            if(!withOpenInv){
                openInventory()
            }
            Sleep, globalsleep*2
            MouseClick, left, filterUI[1], filterUI[2]
            Sleep, globalsleep*2
            if(filtered){
                MouseClick, left, firstRarity[1], firstRarity[2]
            }else{
                MouseClick, left, firstRarity[1], firstRarity[2]+(fSlotDelta*stdRarity)
            }
            filtered := !filtered
            Sleep, globalsleep*2.5
            MouseClick, left, filterCL[1], filterCL[2]
            Sleep, globalsleep
            if(!withOpenInv){
                openInventory()
            }
        }else{
            Send, {%A_ThisHotkey%}
        }
    } 

/*
    Ger: h-Key
    toggles the Help window 
*/
SC023::
Numpad4::
    openHelpWindow(){
        static OpenHelp := false
        global
        if(!typing){
            if(OpenHelp){ ; close it 
                MouseClick, left, helpCL[1], helpCL[2]
            }else{ ; open it
                MouseClick, left, helpUI[1], helpUI[2] 
            }
            Sleep, globalsleep
            OpenHelp := !OpenHelp
            centerMousePosition()
        }else{
            Send, {%A_ThisHotkey%}
        }
    }

/*
    Ger: i-Key
    toggles the Inventory 
*/
SC017:: 
Numpad5:: 
    openInv(){
        if(!typing){
            openInventory()
        }else{
            Send, {%A_ThisHotkey%}
        }
    }

/*
    Ger: p-Key
    toggles the Party window
*/
SC019::
Numpad6:: 
    openPartyWindow(){
        static OpenParty := false
        global
        if(!typing){
            if(OpenParty){ ; close it 
                MouseClick, left, partyCL[1], partyCL[2]
            }else{ ; open it
                MouseClick, left, partyUI[1], partyUI[2] 
            }
            Sleep, globalsleep
            OpenParty := !OpenParty
            centerMousePosition()
        }else{
            Send, {%A_ThisHotkey%}
        }
    }

/*
    Ger: j-Key
    toggles the Quests window
*/
SC024::
Numpad7::
    openQuestsWindow(){
        static OpenQuests := false
        global
        if(!typing){
            if(OpenQuests){ ; close it 
                MouseClick, left, questsCL[1], questsCL[2]
            }else{ ; open it
                MouseClick, left, questsUI[1], questsUI[2] 
            }
            Sleep, globalsleep
            OpenQuests := !OpenQuests
            centerMousePosition()
        }else{
            Send, {%A_ThisHotkey%}
        }
    }

/*
    Ger: m-Key
    toggles the standard Map
*/
SC032::
Numpad8:: 
    openMapWindow(){
        static OpenMap := false
        global
        if(!typing){
            if(OpenMap){ ; close it 
                MouseClick, left, mapCL[1], mapCL[2]
            }else{ ; open it
                MouseClick, left, mapUI[1], mapUI[2] 
            }
            Sleep, globalsleep
            OpenMap := !OpenMap
            centerMousePosition()
        }else{
            Send, {%A_ThisHotkey%}
        }
    }

/*
    Ger:k-Key
    toggles the stats window
*/
SC025::
Numpad9:: 
    openStatisticsWindow(){
        static OpenStats := false
        global
        if(!typing){
            if(OpenStats){ ; close it 
                MouseClick, left, statsCL[1], statsCL[2]
            }else{ ; open it
                MouseClick, left, statsUI[1], statsUI[2] 
            }
            Sleep, globalsleep
            OpenStats := !OpenStats
            centerMousePosition()
        }else{
            Send, {%A_ThisHotkey%}
        }
    }

/*
    Ends typing mode started with normal Enter 
    and presses autogreed on topleft item otherwise 
*/
NumpadEnter::
    autoGreedEXE(){ 
        global
        triggeredKey := A_ThisHotkey
        if(!typing && !ingame && (triggeredKey != "alt")){
            typing := !typing   
            toolTipLog("T:" typing)
        }else if(!typing && ingame){
            MouseClick, left, greedUI[1], greedUI[2] 
            centerMousePosition()
        }else if(typing && !ingame){
            Send, {%triggeredKey%}
        }else{
            ; MsgBox, %triggeredKey%
            if((triggeredKey != "alt")){
                typing := !typing   
                toolTipLog("T:" typing)
            }
            Send, {%triggeredKey%}
        }
        updateOSD()
    }

/*
    Ger: z-Key
    drops the current Item under the cursor 
    on the ground, destroying it in the process.
*/
SC015::
NumpadDiv:: 
    dropCurrentItem(){
        global
        if(!typing){
            MouseGetPos, x,y 
            Sleep globalsleep
            MouseClick, left, %x%, %y%
            Sleep globalsleep
            MouseClick, left, dropUI[1], dropUI[2]
            Sleep globalsleep*2 
            MouseClick, left, destroyUI[1], destroyUI[2]
            Sleep globalsleep
            MouseMove %x%, %y%
        }else{
            Send, {%A_ThisHotkey%}
        }
    }

/*
    Ger: n-Key
    Toggles the Detailed Map
*/
SC031::
NumpadDot::
    openV2Map(){
        static OpenV2Map := false
        global
        if(!typing){
            if(OpenV2Map){ ; close it 
                MouseClick, left, mapCL[1], mapCL[2]
                Sleep, globalsleep
                Gui,MapGui: hide
            }else{ ; open it
                MouseClick, left, mapUI[1], mapUI[2]
                Sleep, globalsleep
                Gui,MapGui: show, NoActivate
            }
            Sleep, globalsleep
            OpenV2Map := !OpenV2Map
            mapOpen := OpenV2Map
            centerMousePosition()
        }else{
            Send, {%A_ThisHotkey%}
        }
    }

/*
   Ger:^-Key
   presses the move button so you only need to 
   select the destination in inventory or stash
*/
SC029:: 
    moveItem(){
        global
        if(!typing){
            MouseGetPos, x,y 
            Sleep globalsleep
            MouseClick, left, %x%, %y%
            Sleep globalsleep
            if(x > 900){
                MouseClick, left, moveInvUI[1], moveInvUI[2]
            }else{
                MouseClick, left, moveStashUI[1], moveStashUI[2]
            }
            Sleep globalsleep*2
            MouseMove, %x%, %y%
        }else{
            Send, {%A_ThisHotkey%}
        }
    }

/*
    Ger: <-Key
    un-/equips the item under the cursor 
*/
SC056:: 
    un_equipItem(){
        global
        if(!typing){
            MouseGetPos, x,y 
            Sleep globalsleep
            MouseClick, left, %x%, %y%
            Sleep globalsleep
            MouseClick, left, equipUI[1], equipUI[2]
            Sleep globalsleep*2
            MouseMove, %x%, %y%
        }else{
            Send, {%A_ThisHotkey%}
        }
    }

/*
    Ger: #-Key
    sells or buys the item under the cursor 
    at the blacksmith
*/
SC02b:: 
    vendorItem(){
        global
        if(!typing){
            MouseGetPos, x,y 
            Sleep globalsleep
            MouseClick, left, %x%, %y%
            Sleep globalsleep
            if(x>900){
                MouseClick, left, sellUI[1], sellUI[2]
            }else{
                MouseClick, left, buyUI[1], buyUI[2]
            }
            Sleep globalsleep*2
            MouseMove, %x%, %y%
        }else{
            Send, {%A_ThisHotkey%}
        }
    }

/*
    Ger: +-Key
    deposits the item under the cursor into stash
*/
SC01b:: 
    depositItem(){
        global
        if(!typing){
            MouseGetPos, x,y 
            Sleep globalsleep
            MouseClick, left, %x%, %y%
            Sleep globalsleep
            MouseClick, left, depositUI[1], depositUI[2]
            Sleep globalsleep*2
            MouseMove, %x%, %y%
        }else{
            Send, {%A_ThisHotkey%}
        }
    }

/*
    Ger:--Key 
    withdraws the item under 
    the cursor from stash into inv
*/
SC035:: ;-:: ; withdraw item under Cursor 
    withdrawItem(){
        global
        if(!typing){
            MouseGetPos, x,y 
            Sleep globalsleep
            MouseClick, left, %x%, %y%
            Sleep globalsleep
            MouseClick, left, withdrawUI[1], withdrawUI[2]
            Sleep globalsleep*2
            MouseMove, %x%, %y%
        }else{
            Send, {%A_ThisHotkey%}
        }
    }

/*
    Ger: +-Key
    switches to the Next tab of the stash 
    or increases the time the bot waits 
    for more ppl by 1
*/
PgUp::
RShift & SC01b:: 
    openNextStashTab_addTime(){
        global
        if(!typing){
            MouseGetPos, x,y 
            Sleep globalsleep
            MouseClick, left, stashNxtUI[1], stashNxtUI[2]
            Sleep globalsleep*2
            MouseMove, %x%, %y%
        }else{
            if(lobbyBotActive){
                remainingTime += addTime
                toolTipLog("-1 min")
            }else{
                Send, +{+}
            }
        } 
    }

/*
    Ger:--Key 
    iterates forwards in stash tabs till the previous one is reached
    decreases the time the bot waits for ppl by 1
*/
PgDn::
RShift & SC035:: ;-::
    openPreviousStashTab_subTime(){
        global
        if(!typing){
            MouseGetPos, x,y 
            Sleep globalsleep
            Loop,8 {
                MouseClick, left, stashNxtUI[1], stashNxtUI[2]
                Sleep globalsleep*2
            }
            MouseMove, %x%, %y%
        }else{
            if(lobbyBotActive){
                remainingTime -= addTime
                toolTipLog("-1 min")
            }else{
                Send, +{-}
            }
        } 
    }

/*
    equip 6th inv row
    switching to ms gear
    if its located in row 6
*/
NumpadAdd::  
LCtrl & 6::
RControl & Numpad6::  
    equip6thInvRow(){
        if(!typing){
            switchEQ(5)
        }else{
            Send, {NumpadAdd}
        } 
    }

/*
    equip 5th inv row
    switching to res gear 
    if its located in row 5
*/
NumpadSub:: ; 
LCtrl & 5::
RControl & Numpad5:: ; 
    equip5thInvRow(){
        if(!typing){
            switchEQ(4)
        }else{
            Send, {NumpadSub}
        } 
    }

/*
    equip 4th inv row
*/
LCtrl & 4::
RControl & Numpad4:: 
    switchEQ(3)
return 

/*
    equip 3rd inv row
*/
LCtrl & 3::
RControl & Numpad3::
    switchEQ(2)
return 

/*
    equip 2nd inv row
*/
LCtrl & 2::
RControl & Numpad2::
    switchEQ(1)
return 

/*
    equip fst inv row
*/
LCtrl & 1::
RControl & Numpad1:: 
    switchEQ(0)
return 

/*
    combines generateing a new item 
    and looking at the result into one hotkey 
    they see me rolling...
*/
ScrollLock:: 
    rerollItem(){
        global 
        Sleep, globalsleep
        MouseClick, left, generateUI[1] , generateUI[2] 
        Sleep, globalsleep
        MouseMove innItemSlot[1] , innItemSlot[2] 
    }

/*
    Ger: w-Key
    Takes 24 items out from current StashTab
*/
AppsKey & SC011:: 
    withdrawItems(){
        global
        KeyWait, AppsKey
        rowS := 0
        stop := false
        while (rowS < 4 && !stop){
            columnS := 0
            while (columnS < 6){
                Sleep globalsleep
                MouseClick, left, firstSSlot[1]+(sSlotDeltaH*columnS), firstSSlot[2]+sSlotDeltaV*rowS
                Sleep globalsleep
                MouseClick, left, withdrawUI[1], withdrawUI[2]
                Sleep globalsleep
                columnS++
            }
            rowS++
        }
        Sleep globalsleep
        centerMousePosition()
    }

/*
    Ger: u-Key
    Unloads Equiped Gear back into Inventory 
*/
AppsKey & SC016:: 
    unequipGear(){
        global
        KeyWait, AppsKey
        if(!withOpenInv){
            openInventory()
        }
        ; unequip charm
        Sleep globalsleep*2
        MouseClick, left, charmSlot[1], charmSlot[2]
        Sleep globalsleep
        MouseClick, left, equipUI[1], equipUI[2]
        ; unequip rest  
        columnE := 0
        stop := false
        while (columnE < 3 && !stop){
            rowE := 0
            while (rowE < 3 && !stop){
                Sleep globalsleep
                MouseClick, left, firstESlot[1]+(eSlotDeltaH*columnE), firstESlot[2]+eSlotDeltaV*rowE
                Sleep globalsleep
                MouseClick, left, equipUI[1], equipUI[2]
                Sleep globalsleep
                rowE++
            }
            columnE++
        }
        Sleep globalsleep
        if(!withOpenInv){
            openInventory()
        }
    }

/*
    Ger: d-Key
    Deposits First 20 Items from Inventory into Stash 
*/    
AppsKey & SC020::
AppsKey & Numpad1::
    depositItems(){
        KeyWait, AppsKey
        manageInventory("StashItems")
    }

/*
    Ger: g-Key
    Destroys First 20 Items in Inventory 
    by droping them on the ground
*/   
AppsKey & SC022::    
AppsKey & Numpad3::
    dropItems(){
        KeyWait, AppsKey
        manageInventory("DropItems")
    }

/*
    Ger: s-Key
    Sells First 20 Items to Blacksmith
*/    
AppsKey & SC01F::
AppsKey & Numpad0::
    sellInventory(){ 
        global typing
        if(!typing){
            manageInventory("SalvageItems")
            centerMousePosition()
        }else{
            Send, {%A_ThisHotkey%}
        }
    }

/*
    Ger: a-Key
    Toggles mousemovement +-10 pix 
    relative from current position 
    to disable lobby afk kick
*/    
AppsKey & SC01E::
    toggleAntiAfk(){
        global typing
        static afk := false 
        if(afk){
            SetTimer, antiAfkEXE, off
        }else{
            SetTimer, antiAfkEXE, 30000
        }
        afk := !afk
        toolTipLog("Afk" afk)
    }  

/*
    faster hotkey for leaving the game
    aka fishing simulator for better leg-/hcd-mods
*/    
End:: 
    leaveIngame(){
        global typing
        if(!typing){
            exitGame()
        }else{
            Send, {%A_ThisHotkey%}
        }
    }

;Function-Compendium::
exitGame(){
    Send, {F10}q 
    switchGameState()
}

/*
    Switches between beeing ingame 
    and lobbying b4 it
*/
switchGameState(){
    global
    typing := !typing
    ingame := !ingame
    if(minimapOpen){
        SetTimer, updateOnMapTime, off
        Gui,MiniMapGui: hide
    }else{
        mapStartTime := A_TickCount
        updateOnMapTime()
        SetTimer, updateOnMapTime, 1000
        Gui,MiniMapGui : Show, NoActivate
    }
    minimapOpen := !minimapOpen
    if(mapOpen){
        mapOpen := !mapOpen
        Gui,MapGui: hide
    }
    if(osdOpen){
        Gui,OSD: hide
    }else{
        updateOSD()
        Gui,OSD: Show, NoActivate
    }
    osdOpen := !osdOpen
    filtered := false
    toolTipLog("G:" ingame "T:" typing)
}


triggerSkillHotkey(){
    local xPos, yPos 
    keySend := A_ThisHotkey
    Send, {%keySend%} ; send once 
    if(!typing){
        MouseGetPos, xPos, yPos 
        sleep 50
        MouseClick, left, %xPos%, %yPos% 
        sleep 50
        Send, 1 ; refocus hero <--
    }
}

triggerTeleportHotkey(){
    numPressed := SubStr(A_ThisHotkey,0)
    if(!typing){
        tooltipLog("tp:" numPressed)
        newImgName := tpAreas[numPressed]
        replaceMiniMapImg(false,true)
        mapStartTime := A_TickCount
        tpTo(numPressed)
    }else{
        Send, +{%numPressed%}
    }
}

removeToolTip(){
    ToolTip
}

sendWheelDown(){
	if WinActive("ahk_class StarCraft II"){
        MouseGetPos, xPos, yPos
        ControlClick, X%xPos% Y%yPos%, ahk_class StarCraft II,, RIGHT 
    }
}

forceMoveAndBreak(){
    global 
    if(!stop)
        stop:=true
    if(!toggleWheelDown){
        toggleWheelDown := true
        sendWheelDown()
        SetTimer, sendWheelDown, 100
        toolTipLog("WheelDown on")
    }
}

breakForceMove(){
    global 
    if(toggleWheelDown){
        toggleWheelDown := false
        SetTimer, sendWheelDown, Off
        toolTipLog("WheelDown off")
    }
}

openInventory(){
    MouseClick, left, inventoryUI[1], inventoryUI[2] 
    centerMousePosition()
}

switchEQ(row){
    global 
    if(!withOpenInv){
        openInventory()
    }
    Sleep globalsleep
    column := 0
    stop := false
    while (column < 5 && !stop){
        Sleep globalsleep
        if(row < 5){
            MouseClick, left, firstSlot[1]+(iSlotDelta*column), firstSlot[2]+iSlotDelta*row
        }else{
            MouseClick, left, overflow[1]+(iSlotDelta*column), overflow[2]
        }
        Sleep globalsleep
        MouseClick, left, equipUI[1], equipUI[2]
        Sleep globalsleep
        column++
    }
    Sleep globalsleep
    if(!withOpenInv){
        openInventory()
    }
}

tpTo(location){
    global 
    Sleep globalsleep
    MouseClick, left, firstTSlot[1], firstTSlot[2]+tSlotDelta*(location-1)
    Sleep globalsleep
    MouseClick, left, firstTSlot[1], firstTSlot[2]+tSlotDelta*9 ; Tp btn
}

centerMousePosition(){
    MouseMove, centerScreen[1], centerScreen[2]
}

manageInventory(Setting){
    global
	ColumnCount := 0
	RowCount := 0
	Cycles := 0
	MouseGetPos x, y
	If (Setting == "DropItems" && !withOpenInv){
		openInventory()
	}
	stop := false 
	Loop{
		++Cycles
		XClick := firstSlot[1]+iSlotDelta*(ColumnCount)
		YClick := firstSlot[2]+iSlotDelta*(RowCount)
		Sleep globalsleep
		Click, %XClick%, %YClick%
        Sleep globalsleep
		If (Setting == "StashItems"){
            MouseClick, left, depositUI[1], depositUI[2]
        }
		If (Setting == "SalvageItems"){
			MouseClick, left, sellUI[1], sellUI[2]
		}
		If (Setting == "DropItems"){
            MouseClick, left, dropUI[1], dropUI[2]
            Sleep globalsleep*2 
            MouseClick, left, destroyUI[1], destroyUI[2]
		}
		Sleep globalsleep
        ColumnCount++
        ; RowCount < 4 => 20 items 
        If (ColumnCount > 4) && (RowCount < 4){
            ColumnCount := 0
            RowCount++
        }
	}	Until stop || Cycles>=Columns*Rows
	
	If (Setting == "DropItems" && !withOpenInv){
		openInventory()
	}
    MouseMove %x%, %y%
}

activateBot(){
    greetJoiningPPL(1)
    MouseClick, left, 10, 10
    toolTipLog("setup Lobby")
    setupLobby()
    While(lobbyBotActive){
        if(waitForBotInterrupt()){
            return
        }
        remainingTime := lobbyTimer
        
        toolTipLog("make Public")
        Sleep, globalsleep*2
        MouseClick, left, lobbyPublic[1], lobbyPublic[2]
        Sleep, globalsleep*2
        Send, %lobbyTitle%
        Sleep, globalsleep
        Send, {Enter} 
        Sleep, globalsleep
        updateLobbyChat()
        if(updateArcade){
            updateGlobalChat()
            SetTimer, updateGlobalChat, %globUpdateTmr%
        }
        Sleep, globalsleep
        ; lobbyStarted := false
        startTime := A_TickCount
        toolTipLog("awaiting Players")
        ; snapshot slotarray
        tmpSlotArray := []
        For sid, bool in slotArray{
            tmpSlotArray.Push(slotArray[sid])
        }
        Loop{
            if(waitForBotInterrupt(updateInterval)){
                return
            }
            if(countPlayerAmount()>1){
                For sltID, bool in tmpSlotArray{
                    if(!tmpSlotArray[sltID]&&slotArray[sltID]){
                        greetJoiningPPL(sltID)
                        tmpSlotArray[sltID]:=true
                    }
                    if(tmpSlotArray[sltID]&&!slotArray[sltID]){
                        tmpSlotArray[sltID]:=false
                    }
                }
            }
            if((A_TickCount - startTime) >= (updateInterval * 1000)){
                currentPPLCount := countPlayerAmount()
                if (currentPPLCount >= amountPlayers && remainingTime > 1){
                    remainingTime := quickStartTime
                }else if (currentPPLCount = 10){
                    ; lobbyStarted := true
                    remainingTime := 0
                }else if (currentPPLCount = 1){
                    remainingTime := lobbyTimer
                }else{
                    remainingTime -= (updateInterval /60)
                }
                updateLobbyChat()  
                startTime := A_TickCount
                timeinLobby ++
                toolTipLog("inLobbyFor:" timeinLobby "min")
            }
        }until (remainingTime = 0)
        if(updateArcade){
            SetTimer, updateGlobalChat, off
        }
        Sleep, globalsleep
        if(waitForBotInterrupt()){
            return
        }
        ; if(!lobbyStarted){
        toolTipLog("starting Lobby")
        startLobby()
        ; }
        switchGameState()
        toolTipLog("w8ing 4 Game-load")
        if(waitForBotInterrupt(w8TillIngame)){
            return
        }
        failsafeBotKill()
        toolTipLog("print Welcome")
        if(printWelcomeMsg()){
            return
        }
        toolTipLog("w8ing Ingame")
        if(waitForBotInterrupt(ingameW8Time)){
            return
        }
        exitGame()
        toolTipLog("w8ing 4 Game End")
        if(waitForBotInterrupt(30)){
            return
        }
        toolTipLog("remakeing Lobby")
        MouseClick, left, playAgainUI[1], playAgainUI[2]
        if(waitForBotInterrupt(30)){
            return
        }
    }
}

antiAfkEXE(){
    MouseMove, 10, 0,, R
    Sleep, globalsleep
    MouseMove, -10, 0,, R
}

/*
    Sends the preset Messages to the global chat 
    combined with the amount of missing players
*/
updateGlobalChat(){
    static gIndex := 1
    ; currentTimer := Round(remainingTime,1)
    Sleep, globalsleep
    if(updateArcade){ ;&& (Mod(currentTimer,5) = 0)){
        Send, {Enter}
        Sleep, globalsleep
        availableSlots := (10-countPlayerAmount())
        msgtmp := globalchat " [{+}" availableSlots "] " globalArray[gIndex] 
        Send,% msgtmp
        Send, {Enter}
        Sleep, globalsleep
        if(gIndex = globalArray.Length()){
            gIndex := 1
        }else{
            gIndex ++
        }
         
    }
}

/*
    sets up the command arguments and runs Capture2Text with them
*/ 
runCaptureToText(rectArray){
    readArray := sndScreen? convertToSndScreenCords(rectArray):rectArray
    
    charWhitelist := "" ;AtoZ atoz symbols ;"--whitelist ""ABCDEFGHIJKLMNOPQRSTUVWXYZ'-()"""
	c2TPath := A_ScriptDir . "\Capture2Text\Capture2Text_CLI.exe "
    c2Tlocation:= " --screen-rect """ . readArray[1] . " " . readArray[2] . " " . readArray[3] . " " . readArray[4] . """"
    c2Targs := "-o output-ocr.txt --output-file-append " . charWhitelist . c2Tlocation
    outputOCR := c2TPath . c2Targs
    
	RunWait, %outputOCR%,%A_ScriptDir%, Hide, outputOCRPID
	Process, WaitClose, %outputOCRPID%
    return getCaptureOutput()
}

getSlotName(Slot:=1){
    tmpArray:= []
    ; values := ""
    For index, value in slotNameRect{
        tmpArray[index] := !(Mod(Index,2)=0)
        ? slotNameRect[index]
        : value + (playersDelta * (Slot-1))
        ; values .= tmpArray[index] ","
    }
    ; MsgBox,% values
    return runCaptureToText(tmpArray)
} 

greetJoiningPPL(Slot:=1){
    local tmpJMsg
    if(useCapture){
        name := getSlotName(Slot)
        tooltipLog(name "joined")
        tmpJMsg := Slot = 1 ? jMsg1 : jMsg2
        tmpJMsg := "/l " . tmpJMsg
        Sleep, globalsleep
        Send, {Enter}
        Sleep, globalsleep
        Send,% tmpJMsg name
        Send, {Enter}
    }
} 

/*
    Sends the preset Messages to the Lobby chat 
    combined with a timer
*/
updateLobbyChat(){
    global 
    static lMsgIndex := 1
    currentTimer := Round(remainingTime,1)
    Sleep, globalsleep
    if(currentTimer > 1){
        if(updateLobby){
            Send, {Enter}
            Sleep, globalsleep
            Send, %lobbyTimeMsg% %currentTimer% min{Enter}
            Sleep, globalsleep
            if(lobbyMsging){
                Send, {Enter}
                Sleep, globalsleep
                tempMsg := lobbyArray[lMsgIndex]
                Send, %tempMsg%{Enter}
                Sleep, globalsleep
                if(lMsgIndex > lobbyArray.Length()-1){
                    lMsgIndex := 1
                }else{
                    lMsgIndex ++ 
                }
            }
        }
    }else{
        if(updateLobby){
            Send, {Enter}
            Sleep, globalsleep
            if(currentTimer = 0){
                Send, Game Starting {Enter}
            }else{
                timeInSeconds := Floor(currentTimer*60)
                Send, %lobbyTimeMsg% %timeInSeconds% sec{Enter}
            }
            Sleep, globalsleep
        }
    }
}

/*
    iterates over all preset welcome messages 
    and prints them ingame chat
*/
printWelcomeMsg(){
    For i, wString in welcomeArray{
        Send, {Enter}
        Sleep, globalsleep 
        Send, %wString%
        Sleep, globalsleep
        Send, {Enter}
        if(waitForBotInterrupt(12)){
            return true
        }
    }
}

toggleBot(){
    global
    if(lobbyBotActive){
        stop := true
        SetTimer, antiAfkEXE, off
        SetTimer, updateGlobalChat, off
        lobbyBotActive := !stop 
        toolTipLog("Bot active")
    }else{
        stop := false
        lobbyBotActive := !stop
        SetTimer, antiAfkEXE, 60000
        activateBot()
        toolTipLog("Bot terminated")
    }
    lobbyBotActive := !lobbyBotActive
    
}    

setupLobby(){
    ; select lobby type 
    Sleep, globalsleep
    MouseClick, left, lobbySelect[1], lobbySelect[2]
    Sleep, globalsleep*2
    if(lvlingLobby){ ; open lvlingLobby lobby
        MouseClick, left, lobbySelect[1], lobbySelect[2]+(selectDelta)
    }else{ ; open Endgame lobby 
        MouseClick, left, lobbySelect[1], lobbySelect[2]+(2*selectDelta)
    }
    Sleep, globalsleep
}

waitForBotInterrupt(timeout:=5){
    local startTime := A_TickCount
    while(A_TickCount - startTime <= timeout*1000){
        if(stop){
            toggleBot()
            return true
        }
        Sleep, globalsleep*5
    }
    return false
}

startLobby(){
    MouseClick, left, lobbyStartUI[1], lobbyStartUI[2]
    Sleep globalsleep
    while(!ingame && !stop){
        Sleep, globalsleep
        PixelGetColor, l_OutputColor, lobbyStartUI[1], lobbyStartUI[2] , RGB
        Sleep, 2000
        if(l_OutputColor = splashColor || l_OutputColor = "0x000000"){
            ingame := true
            return
        }else{
            MouseClick, left, lobbyStartUI[1], lobbyStartUI[2]
        }
    }
}

failsafeBotKill(){
    PixelGetColor, l_OutputColor, nameUI[1], nameUI[2]
    if(l_OutputColor != nameColor){
        toolTipLog("Start Failed")
        toggleBot()
    }
}

/*
    Counts amount of Players in lobby by the switched Pixel they create 
    with their Profile Pic
*/
countPlayerAmount(){
    global maxPlayers,slotArray,playersSlot,playersDelta
    index := 0 
    countPlayers := 0
    while (index < maxPlayers){
        PixelGetColor, l_OutputColor, playersSlot[1], playersSlot[2]+(playersDelta*index) , RGB
            
        if(!containsElem(mtSlotColors, l_OutputColor)){
            countPlayers ++ 
            slotArray[index+1]:= true
        }else{
            slotArray[index+1]:= false
        }
        index ++ 
    }
    return countPlayers
}

containsElem(arr,elem){
    for, k ,v in arr {
        if (v = elem){
            return true 
        }
    }
    return false 
}

toolTipLog(p_Msg:="nothing", p_X:= 110){
    if(enableLogging){
        ToolTip, %p_Msg% , %p_X% , 1065
        removeDelay := (-toolTipDelay*1000)
        SetTimer, removeToolTip, %removeDelay%
    }
}

/*
    Input [1-9,a-c]
    Output corresponding Dungeon String
*/
selectCurrentDungeon(){
    global 
    Suspend, on 
    Input, userIn, L2 T3,{Escape}, %dungeonList% 
    Suspend, off
    if (ErrorLevel = "Max"){
        MsgBox, don't spam, only 1 keys required, tipped:"%userIn%" 
        return
    }
    if (ErrorLevel = "Timeout"){
        MsgBox, faster next time =D, tipped:"%userIn%"
        return
    }
    if (ErrorLevel = "NewInput")
        return
    If InStr(ErrorLevel, "EndKey:"){
        return
    }
    toolTipLog("In: " userIn)
    if(userIn = "a"){
        return "Dungeon 10"
    }else if(userIn = "b"){
        return "Dungeon 11"
    }else if(userIn = "c"){
        return "Purge"
    }else{
        tooltipLog("D:" userIn " selected")
        return "Dungeon " userIn
    }
}        

selectCurrentMinimap(){
    global     
    Suspend, on 
    Input, userIn, L3 T3,{Escape}, %shortList% 
    Suspend, off
    if (ErrorLevel = "Max"){
        MsgBox, don't spam, only 2 keys required, tipped:"%userIn%" 
        return
    }
    if (ErrorLevel = "Timeout"){
        MsgBox, faster next time =D, tipped:"%userIn%"
        return
    }
    if (ErrorLevel = "NewInput")
        return
    If InStr(ErrorLevel, "EndKey:"){
        return
    }
    toolTipLog("In: " userIn)
    For short, full in areaKVMap{
        if( userIn = short ){
            return full
        }
    }
}

/*
    combines the right Path and switches Minimap to correct Img
    remembers the active dungeon 
    Minimap presets to desination when teleporting
*/    
replaceMiniMapImg(switchLoD:=false,teleported:=false){
    global
    if(!switchLoD){
        if(!teleported){
            if(useCapture){
                newImgName := runCaptureToText(miniMapRect)
                if(checkIsMapDungeon(newImgName)||!containsElem(areaKVMap,newImgName)){
                    toolTipLog("unknown map!, " newImgName " not available")
                    return
                }
            }else{
                newImgName := selectCurrentMinimap()
                if(SubStr(newImgName,1,4)="Dung"){
                     currentDungeon := newImgName
                     dungeonActive := true
                     GuiControl,OSD:, AD,% "Active Dungeon: " currentDungeon 
                }
            }
        }else{
            if(checkIsMapDungeon(newImgName)||!containsElem(areaKVMap,newImgName)){
                toolTipLog("unknown map!, " newImgName " not available")
                return
            }
        }
    }else{
        minimapLvl += 1
        if(minimapLvl > 3){
            minimapLvl := 1
        }
        tooltipLog("MML:"minimapLvl)
        mMPath := A_ScriptDir mMTFolder mMFolder%minimapLvl%
    }
    if(newImgName != ""){
        fullPath := mMPath newImgName mMExt
        switchMiniMap(fullPath)
    }
    GuiControl,OSD:, MMArea,% "MM-Area: " newImgName 
}

checkIsMapDungeon(mapName){
    global
    if(mapName = "Dungeon"){
        if(!dungeonActive){
            newImgName := selectCurrentDungeon()
            if(!newImgName){
                return false
            }
            currentDungeon := newImgName
            dungeonActive := true
        }else{
            newImgName := currentDungeon
        }
        GuiControl,OSD:, AD,% "Active Dungeon: " currentDungeon 
    } 
}

switchMiniMap(fullPath){
    if(FileExist(fullPath)){
        GuiControl,MiniMapGui:,Minimap,%fullPath% 
    }else{
        MsgBox,% "could not find img at:" fullPath
    }
}

backupLogFile(){
	FileDelete, output-ocr.1.txt
	FileMove, output-ocr.txt, output-ocr.1.txt
}

getCaptureOutput(){
	Loop, read, output-ocr.txt
	{ 
		output := A_LoopReadLine
	}
    
    ; invis char at front for some reason
    output := !isALetter(Substr(output,1,1)) 
        ? Substr(output,2,StrLen(output)-1)
        : output
	return %output%
}   

isALetter(pChar){
    atoz := "abcdefghijklmnopqrstuvwxyz"
    StringUpper, vAtoZ, atoz 
    symbols := "|_-"
    validChars := atoz . vAtoZ 
    loop, PARSE, validChars
    {
        if(A_LoopField = pChar){
            return true
        }
    }
    return false
}  

convertToSndScreenCords(pArray){
    if(sndScreen){
        convArray:=[]
        ; values:=""
        For cordID, cord in pArray{
            if(sndScreenLoc=1){
                convArray.Push(!(Mod(cordID,2)=0)? cord : - NativeScreenHeight + cord )
            }else if(sndScreenLoc=2){
                convArray.Push(!(Mod(cordID,2)=0)? cord + NativeScreenWidth : cord )
            }else if(sndScreenLoc=3){
                convArray.Push(!(Mod(cordID,2)=0)? cord : NativeScreenHeight + cord )
            }else {
                convArray.Push(!(Mod(cordID,2)=0)? cord - NativeScreenWidth : cord )
            }
            ; values .= convArray[cordID] ","
        }
        ; MsgBox,% "reading at:" values
        return convArray
    }
    return pArray
}

updateOnMapTime(){
    global 
    onMapTime := Round((A_TickCount - mapStartTime) / 1000)
    ; mMsek:= Mod(onMapTime,60)
    ; mMmin:= Mod(Floor(onMapTime / 60),60)
    ; mMhours:= Floor(onMapTime / 360)
    ; format to min , sek 
    ; put on minimap gui
    ; GuiControl,OSD:, MMTimer,% "On-Map Time: "  mMhours "h : " mMmin "m : " mMsek "s"
    GuiControl,OSD:, MMTimer,% "On-Map Time: "  FormatSeconds(onMapTime)
}

/*
    Convert the specified number of seconds to hh:mm:ss format.
*/
FormatSeconds(NumberOfSeconds)
{
    time := 19990101  ; *Midnight* of an arbitrary date.
    time += NumberOfSeconds, seconds
    FormatTime, mmss, %time%, mm:ss
    return NumberOfSeconds//3600 ":" mmss
}

;   VLC-control Interface inside SC2
^SC032:: ;^m::
    toggleVLCmute(){
        ControlSend,,m , ahk_exe vlc.exe
    }
 
^SC01b:: ;+::
    vlcVolumeUp(){
        ControlSend,,^{up}, ahk_exe vlc.exe
    }

^SC035:: ;-::
    vlcVolumeDown(){
        ControlSend,,^{down}, ahk_exe vlc.exe
    }

; Terminate 
#IfWinActive
Pause::
backupLogFile()
ExitApp