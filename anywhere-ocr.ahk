#SingleInstance, Ignore
; #SingleInstance, Force
#Persistent
#Include .\PaddleOCR\PaddleOCR.ahk

global Lang
Lang := MultiLanguage()

Menu, Tray, Icon, Shell32.dll, 260 
Menu, Tray, NoStandard
Menu, Tray, Tip, % Lang.name
; Menu, Tray, Click, 1
Menu, Tray, Add, % Lang.show, ShowMain
Menu, Tray, Default, % Lang.show
Menu, Tray, Add, % Lang.help, Help
Menu, Tray, Add, % Lang.reboot, ReloadSub
Menu, Tray, Add, % Lang.exit, ExitSub

if not A_IsAdmin									;管理员权限打开
   try
{
   Run *RunAs "%A_ScriptFullPath%"
   ExitApp
}

Init:
   Gosub, CreateMain

   ; init 默认先识别一次，以提高正常使用时的速度
   ; MsgBox, % PaddleOCR("init.jpg")
   PaddleOCR([0,0,100,200])
Return

;Hotkey to select area
; ^Lbutton::
#Lbutton::
   Area := SCW_SelectAreaMod("g" GuiNum " c" SelColor " t" SelTrans)
   Vs := StrSplit(Area, "|")
   ; Loop % Vs.MaxIndex()
   ; {
   ;    this_color := Vs[a_index]
   ;    MsgBox, Color number %a_index% is %this_color%.
   ; }

   if (Vs[3] < 10 and Vs[4] < 10) ; too small area
      Return

   GuiControl, Disabled, Original
   GuiControl, Disabled, btnTranslate
   GuiControl, , Original, 正在处理...`n`n识别中...
   Gui Show, w470 h220, % Lang.name ", 内容已经复制到剪贴板"

   OcrText := PaddleOCR(Vs, {"model":"fast"})

   GuiControl, Enable, Original
   GuiControl, , Original, % Clipboard:=OcrText
   GuiControl, Enable, btnTranslate

   ; MsgBox, 4096, 内容已经复制到剪贴板, % Clipboard:=OcrText
return

F3::
   Gosub, ShowMain
Return

CreateMain:
   Gui Add, Edit, x10 y10 w450 h150 vOriginal +Disabled -Wrap
   ; Gui Add, Edit, x16 y10 w450 h150 vTranslate +Disabled
   Gui, Add, Button, x18 y170 w430 h40 vbtnTranslate gTranslate +Disabled, % Lang.translate
Return

ShowMain:
   Gui Show, w470 h220, % Lang.name
Return

ReloadSub:
   Reload
Return

ExitSub:
ExitApp
Return

Help:
   MsgBox, , % Lang.name, Win+鼠标左键拖动（按住 win 然后按住鼠标左键拖动 框出识别范围 松开即可）
Return

Translate:
   MsgBox, , % Lang.name, 开发中...
Return

SCW_SelectAreaMod(Options="") {
   CoordMode, Mouse, Screen
   MouseGetPos, MX, MY
   loop, parse, Options, %A_Space%
   {
      Field := A_LoopField
      FirstChar := SubStr(Field,1,1)
      if FirstChar contains c,t,g,m
      {
         StringTrimLeft, Field, Field, 1
         %FirstChar% := Field
      }
   }

   c := (c = "") ? "Blue" : c, t := (t = "") ? "50" : t, g := (g = "") ? "99" : g
   Try Gui %g%: Destroy
   Try Gui %g%: +AlwaysOnTop -caption +Border +ToolWindow +LastFound -DPIScale ;provided from rommmcek 10/23/16

   WinSet, Transparent, %t%
   Gui %g%: Color, %c%
   Hotkey := RegExReplace(A_ThisHotkey,"^(\w* & |\W*)")
   While, (GetKeyState(Hotkey, "p"))
   {
      Sleep, 10
      MouseGetPos, MXend, MYend
      w := abs(MX - MXend), h := abs(MY - MYend)
      X := (MX < MXend) ? MX : MXend
      Y := (MY < MYend) ? MY : MYend
      Gui %g%: Show, x%X% y%Y% w%w% h%h% NA
   }
   Try Gui %g%: Destroy
   MouseGetPos, MXend, MYend
   If ( MX > MXend )
      temp := MX, MX := MXend, MXend := temp
   If ( MY > MYend )
      temp := MY, MY := MYend, MYend := temp
Return MX "|" MY "|" w "|" h
}

MultiLanguage()
{
   ret := []

   if (A_Language="0804")
   {
      ret.name := "随处识别"
      ret.show := "显示(F3)"
      ret.help := "帮助"
      ret.reboot := "重启"
      ret.exit := "退出"
      ret.translate := "翻译"
      ret.initing := "正在初始化..."
      ret.init_err := "初始化失败，请重试。"
      ret.inited := "初始化成功。"
      ret.translateing := "翻译中..."
      ret.error := "错误 ： "
   }
   else
   {
      ret.name := "Anywhere OCR"
      ret.show := "Show(F3)"
      ret.help := "Help"
      ret.reboot:= "Reboot"
      ret.exit := "Exit"
      ret.translate:= "Translate"
      ret.initing := "Initializing..."
      ret.init_err := "Initialization failed, please try again."
      ret.inited := "Initialization succeeded."
      ret.translateing := "Translating..."
      ret.error := "ERROR : "
   }

return, ret
}