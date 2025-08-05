#Requires AutoHotkey v2.0
;#Persistant true
;#Include Lib.ahk
;#NoTrayIcon
#SingleInstance Force ;Force | Ignore | Prompt | Off

;CoordMode ;ToolTip|Pixel|Mouse|Caret|Menu, Screen|Window|Client
CoordMode "Mouse", "Screen"
SetTitleMatchMode 1 ; 1:must start with 2: can contain anywhere 3: must match exactly
DetectHiddenWindows true

DTop := 1
DMiddle := 2
DBottom := 4
DLeft := 8
DCenter := 16
DRight := 32
TL := DTop | DLeft
TC := DTop | DCenter
TR := DTop | DRight
ML := DMiddle | DLeft
MC := DMiddle | DCenter
MR := DMiddle | DRight
BL := DBottom | DLeft
BC := DBottom | DCenter
BR := DBottom | DRight

ScreenX := -6
ScreenY := 0
ScreenW := A_ScreenWidth + 6
ScreenH := A_ScreenHeight - 33

doubleClickDelay := 250
exitEnabled := False

tray := A_TrayMenu
A_IconTip := "Shows the status of CapsLock, Insert, NumLock and ScrollLock.`nTo toggle Caps Lock, use Shift."
prevmenu := A_IsCompiled ? "&Suspend Hotkeys" : "&Window Spy"

tray.Insert("1&", "End Session", TrayIconClicked)
tray.Insert(prevmenu, "+ Notepad", ShiftClicked)
tray.Insert(prevmenu, "^ Calculator", CtrlClicked)
tray.Insert(prevmenu, "! Paint", AltClicked)
tray.Insert(prevmenu, "# Outlook", WinClicked)
tray.Insert(prevmenu)
tray.Insert("&Suspend Hotkeys", "Open Folder", OpenFolder)
tray.Disable("End Session")

tray.Default := "End Session"
tray.ClickCount := 1

SetTimer GetToggleKeys, 2000

+CapsLock::CapsLock
CapsLock::LCtrl
#LButton:: WinDrag(0)
#RButton:: WinDrag(1)
^#Up:: SnapWindow(WinActive("A"), DTop)
^#Down:: SnapWindow(WinActive("A"), DBottom)
^#Left:: SnapWindow(WinActive("A"), DLeft)
^#Right:: SnapWindow(WinActive("A"), DRight)

;================================================================================
TrayIconClicked(*)
{
    global exitEnabled
    s := GetKeyState("Shift", "P")
    c := GetKeyState("Ctrl", "P")
    a := GetKeyState("Alt", "P")
    w := GetKeyState("LWin") || GetKeyState("RWin")
    totalKeys := s + c + a + w
    if (totalKeys > 1)
        return
    if (totalKeys == 0) {
        if (exitEnabled) {
            EndSession()
        } else {
            exitEnabled := True
            SetTimer DisableExit, -doubleClickDelay
        }
    } else {
        if (s)
            ShiftClicked()
        if (c)
            CtrlClicked()
        if (a)
            AltClicked()
        if (w)
            WinClicked()
    }
}

;================================================================================
DisableExit()
{
    global exitEnabled
    exitEnabled := False
}

;================================================================================
GetToggleKeys()
{
    static toggleFilename := ""
    ScanOpenPrograms()
    cKey := GetKeyState("CapsLock", "T")
    iKey := GetKeyState("Insert", "T")
    nKey := GetKeyState("NumLock", "T")
    sKey := GetKeyState("ScrollLock", "T")
    filename := (cKey ? "C" : "x") . (iKey ? "I" : "x") . (nKey ? "N" : "x") . (sKey ? "S" : "x")
    if (filename == toggleFilename) {
        return
    }
    toggleFilename := filename
    TraySetIcon "Icons\" . filename . ".ico"
}

;================================================================================
WinDrag(winDragMode)
{
    MouseGetPos &initMouseX, &initMouseY, &winDragWinId
    if (!winDragWinId)
        return
    if (WinGetMinMax("ahk_id " winDragWinId))
        return
    WinGetPos &initWinX, &initWinY, &initWinW, &initWinH, "ahk_id " winDragWinId

    Loop
    {
        if (!GetKeyState("LWin") && !GetKeyState("RWin"))
            break

        MouseGetPos &mouseX, &mouseY
        dx := mouseX - initMouseX
        dy := mouseY - initMouseY
        if (winDragMode == 0)
        {
            WinMove initWinX + dx, initWinY + dy, , , "ahk_id " winDragWinId, ""
        }
        else
        {
            winW3rd := initWinW // 3
            winH3rd := initWinH // 3
            nonantX := (initMouseX < initWinX + winW3rd) ? DLeft : (initMouseX > initWinX + 2 * winW3rd) ? DRight : DCenter
            nonantY := (initMouseY < initWinY + winH3rd) ? DTop : (initMouseY > initWinY + 2 * winH3rd) ? DBottom : DMiddle
            WinGetPos &newX, &newY, &newW, &newH, "ahk_id " winDragWinId
            if nonantX == DLeft
            {
                newX := initWinX + dx
                newW := initWinW - dx
            }
            else if nonantX == DRight
            {
                newW := initWinW + dx
            }
            if nonantY == DTop
            {
                newY := initWinY + dy
                newH := initWinH - dy
            }
            else if nonantY == DBottom
            {
                newH := initWinH + dy
            }
            WinMove newX, newY, newW, newH, "ahk_id " winDragWinId, ""
        }
    }
}

;================================================================================
SnapWindow(winId, direction)
{
    if !WinExist("ahk_id " winId)
        return

    WinGetPos &x, &y, &w, &h, "ahk_id " winId

    if (direction == DLeft)
    {
        WinMove ScreenX, y, w, h, "ahk_id " winId
    }
    else if (direction == DRight)
    {
        WinMove ScreenW - w, y, w, h, "ahk_id " winId
    }
    else if (direction == DTop)
    {
        WinMove x, ScreenY, w, h, "ahk_id " winId
    }
    else if (direction == DBottom)
    {
        WinMove x, ScreenH - h, w, h, "ahk_id " winId
    }
}

;================================================================================
ScanOpenPrograms()
{
    if WinExist("Help Promote OGCS")
        WinClose
}

;================================================================================
ShiftClicked(*)
{
    Run "Notepad"
}

;================================================================================
CtrlClicked(*)
{
    Run "Calc"
}

;================================================================================
AltClicked(*)
{
    Run "mspaint.exe"
}

;================================================================================
WinClicked(*)
{
    Run "outlook.exe"
}

;================================================================================
OpenFolder(*)
{
    Run A_ScriptDir
}

;================================================================================
EndSession()
{
    ExitApp
}

;================================================================================
NextWorkDay()
{
    timestamp := A_NOW // 1000000
    timestamp := DateAdd(timestamp, 19, "Hours")
    if (A_WDay = 6) { ;Friday
        timestamp := DateAdd(timestamp, 3, "Days")
    } else if (A_WDay = 7) { ;Saturday
        timestamp := DateAdd(timestamp, 2, "Days")
    } else {
        timestamp := DateAdd(timestamp, 1, "Days")
    }
    return timestamp
}

;================================================================================
CreateOnScreenRectangle(x, y, w, h)
{
    global rect
    borderSize := 6
    rect := Gui()
    rect.Opt("+AlwaysOnTop -Caption +Disabled -Resize -SysMenu")
    rect.MarginX := borderSize
    rect.MarginY := borderSize
    wm := w - borderSize * 2
    wh := h - borderSize * 2
    rect.BackColor := "Yellow"
    rect.Add("Picture", "XM YM w" wm " h" wh " BackgroundRed", "")
    WinSetTransColor("Red", rect)
    rect.Show("x" . x . " y" . y . " w" . w . " h" . h)
    Sleep 5000
    rect.Destroy()
}
