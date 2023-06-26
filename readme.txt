 The Cave Toolbox, incl. bonus VLC plugin. V6
 Requires Autohotkey & 1080p screen to run (optional Capture2Text)
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 How to Use: 
    1. Download https://www.autohotkey.com/ 
    2. install it 
    3. Download https://sourceforge.net/projects/capture2text/ optional but recommended 
    4. Download the script archive 
    5. extract the script and capture2text archives 
    6. put capture2text folder inside the toolbox folder
    7. open the .ahk file in any editor and check if keyArray has your hotkeys included (standard is grid layout)
    8. save the file if you made changes and doubleclick the file to run it
    9. it shows an icon in the system tray where you can turn it back off or just press the pause key to terminate it
    10. ... profit 
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 available keys:: backspace; u; ü; ö; ä, alt , numpad mul
 
 de-de :
 esc   |^|1|2|3|4|5|6|7|8|9|0|ß|´|   Backspace
 tab   |q|w|e|r|t|z|u|i|o|p|ü|+|     Enter
 caps  |a|s|d|f|g|h|j|k|l|ö|ä|#|     Enter
 lshift|<|y|x|c|v|b|n|m|||.|-|       rshift
 lctrl |win|alt|space|alt-gr|fn|appskey|rctrl
 
 ru-ru:
 esc   |ё|1|2|3|4|5|6|7|8|9|0|-|=|   Backspace
 tab   |й|ц|у|к|е|н|г|ш|щ|з|х|ъ|     Enter
 caps  |ф|ы|в|а|п|р|о|л|д|ж|э|\|     Enter
 lshift|\|я|ч|с|м|и|т|ь|б|ю|.|       rshift
 lctrl |win|alt|space|alt|fn|appskey|rctrl
 
 en-us :
 esc   |`|1|2|3|4|5|6|7|8|9|0|-|=|   Backspace
 tab   |q|w|e|r|t|y|u|i|o|p|[|]|\|   del
 caps  |a|s|d|f|g|h|j|k|l|;|'|       Enter
 lshift|z|x|c|v|b|n|m|||.|/|         rshift
 lctrl |win|alt|space|alt|fn|appskey|rctrl
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 ----------------------------------
 Features include:
 ----------------------------------
 Mostly set to use Numpad and the key left of the right ctrl aka AppsKey.
 
|-----------|
| General:  |
|-----------|
 END : leave game 
 
|-----------|
| Toggles:  |
|-----------|
 Insert : switches between lobby- and ingame mode 
 Enter  : if ingame switches typing mode on/off
 0 : disable autoattacks
 ß : disable text-tags
 AppsKey+a : toggles anti afk mouse movement every min
 AppsKey+z : toggles sc2 on fst or snd screen (capture breaks if not set right)
 AppsKey+t : toggles useing capture2text or manual input 

|-----------|
| Windows:  |
|-----------|
 Numpad1 or l : open lobby aka stats into statistics 
 Numpad2 or o : open archivments
 Numpad3 or , : set standard Loot filter 
 Numpad4 or h : open help 
 Numpad5 or i : open inventory 
 Numpad6 or p : open party
 Numpad7 or j : open quest 
 Numpad8 or m : open default map 
 Numpad9 or k : open stats 
 space : close NPC-Talk window
 
|-----------|
| Minimap:  |
|-----------| 
 AppsKey+l : switch MiniMap detail lvl 1-3 
 AppsKey+m : toggles MiniMap on/off
 Tab: updates MiniMap to current map location, in dungeon press 1-9 or a-c afterwards to select d1-11,purge
 AppsKey+c : clears the Active Dungeon after you are done with it to reenable selecting new one
 
|-----------|
| Mouse:    |
|-----------|
 . : spam left-Clicks while button pressed
 wheeldown : spam R-Click to move char (Force move)
 wheelup   : stop Force move and inv editing macros (panic button)
 
|-----------|
| EQ-Switch |
|-----------|
 RCtrl+Numpad1 or LCtrl+1 : equip fst Inv Row 
 RCtrl+Numpad2 or LCtrl+2 : equip 2nd Inv Row 
 RCtrl+Numpad3 or LCtrl+3 : equip 3rd Inv Row 
 RCtrl+Numpad4 or LCtrl+4 : equip 4th Inv Row 
 RCtrl+Numpad5 or LCtrl+5 or NumpadAdd : equip 5th Inv Row 
 RCtrl+Numpad6 or LCtrl+6 or NumpadSub : equip 6th Inv Row 
 
|--------------|
| SingleItems: |
|--------------|
 ^ Key : autoclick move button in inv or stash
 + Key : deposit item under Cursor 
 - Key : withdraw item under Cursor 
 < Key : un/equip item under Cursor
 # Key : sell item under Cursor
 ScrollLock : regenerate item at inn 
 NumpadDiv or z : drop item under Cursor 
 NumpadEnter : autoclick topleft greed 
 
|-----------|
| Stash:    |
|-----------|
 PgUp or RShift++ : skip to next StashTab page
 PgDn or RShift+- : skip to previous StashTab page 
 
|-----------------|
| MultipleItems:  |
|-----------------|
 NumpadDot or n : open Map v2
 AppsKey+s or AppsKey+Num0 : sell fist 20 items to Blacksmith 
 AppsKey+w : withdraw 24 items from stash
 AppsKey+Num1 or AppsKey+d: deposit 4 rows into bank
 AppsKey+Num3 or AppsKey+g: drop 4 rows on ground
 
|------------|
| LobbyBot:  |
|------------| 
 Delete: terminates the bot 
 Home  : starts the bot, open a new cave lobby and press home to watch the magic happen
 RShift++ or PageUp   : adds 1 min to the time the bot waits for ppl
 RShift+- or PageDown : subtracts 1 min from the time the bot waits for ppl
 
|-----------------|
| VLC-Interface:  |
|-----------------|
 ctrl+m: mute VLC
 ctrl++: VLC inc volume
 ctrl+-: VLC dec volume 
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 LobbyBot instructions : 
 - start bot in first cave lobby 
 - bot selects right lobbytype 
 - bot opens lobby to public with setup title 
 - bot moves cursor 10 px away and back (anti afk) every min 
 - bot sends time till start in lobby  
 - bot sends lobbylink in general chat (optional)
 - (update cycle can be configured) 
 - waits for set amount of Players or time 
 - if 10 ppl lets game start otherwise starts it itself 
 - if someone leaves clicks start again after 2 sek 
 - waits till ingame 
 - if not ingame after load, bot kills itself 
 - writes welcome in chat 
 - quits game and remakes a new lobby
 - Hotkeys for adding and subtracting remaining lobby-time available
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 TODO-Ideas:
 - arena farm bot tbd
 - purge bot [AppsKey & P]
 - guild buff timer
 