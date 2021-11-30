#SingleInstance, Ignore
; #SingleInstance, Force
#Persistent
#Include .\PaddleOCR\PaddleOCR.ahk
#Include <SogouTranslator>
; #Include .\Lib\SogouTranslator.ahk
#Include <BaiduTranslator>

global Lang, TranslationEngine
Lang := MultiLanguage()

Menu, Tray, Icon, Shell32.dll, 260 
Menu, Tray, NoStandard
Menu, Tray, Tip, % Lang.name
; Menu, Tray, Click, 1
Menu, Tray, Add, % Lang.show, ShowMain
Menu, Tray, Default, % Lang.show
Menu, Tray, Add, % Lang.help, Help
Menu, tray, add ; 创建分隔线.
Menu, TranslationEngineMenu, add, % Lang.baidu_translate, SwitchTranslationEngine
Menu, TranslationEngineMenu, Add, % Lang.sougou_translate, SwitchTranslationEngine
Menu, TranslationEngineMenu, Disable, % Lang.baidu_translate
Menu, tray, add, % Lang.switch_translation_engine, :TranslationEngineMenu
Menu, tray, add ; 创建分隔线.
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
   Gosub, CreatTranslator
   TranslationEngine := Lang.baidu_translate

   ; init 默认先识别一次，以提高正常使用时的速度
   ; MsgBox, % PaddleOCR("init.jpg")
   PaddleOCR([0,0,100,200])
Return

;Hotkey to select area
; ^Lbutton::
#Lbutton::
   ; Gosub, GuiClose

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
   Gui, Font, s12, 微软雅黑
   Gui Add, Edit, x10 y10 w450 h150 vOriginal +Disabled -Wrap
   ; Gui Add, Edit, x16 y10 w450 h150 vTranslate +Disabled
   Gui, Add, Button, x18 y170 w430 h40 vbtnTranslate gTranslate +Disabled, % Lang.translate
Return

CreatTranslator:
   Gui, Translator:+Owner +HwndhTranslator
   Gui, Translator:Font, s12, 微软雅黑
   Gui, Translator:Add, Edit, x0 y0 w482 h150 vTranslatorEdit +Disabled
   Gui, Translator:Show, Hide w482 h150, % Lang.translate
return

SwitchTranslationEngine:
   switch, A_ThisMenuItem
   {
   case Lang.baidu_translate : 
      ; MsgBox, , test, 百度
      TranslationEngine := Lang.baidu_translate
      Menu, TranslationEngineMenu, Enable, % Lang.sougou_translate
      Menu, TranslationEngineMenu, Disable, % Lang.baidu_translate
   case Lang.sougou_translate : 
      ; MsgBox, , test, 搜狗
      TranslationEngine := Lang.sougou_translate
      Menu, TranslationEngineMenu, Enable, % Lang.baidu_translate
      Menu, TranslationEngineMenu, Disable, % Lang.sougou_translate
   }

Return

ShowMain:
   Gui Show, w470 h220, % Lang.name
   GuiControl, Enable, Original
   GuiControl, Enable, btnTranslate
Return

ReloadSub:
   Reload
Return

ExitSub:
ExitApp
Return

; 关闭主窗口时隐藏
GuiEscape:
GuiClose:
   Gui, Hide
   Gui, Translator:Hide
return

Help:
   MsgBox, , % Lang.name, Win+鼠标左键拖动（按住 win 然后按住鼠标左键拖动 框出识别范围 松开即可）
Return

Translate:
   ; MsgBox, , % Lang.name, 开发中...
   GuiControl, Translator:Disabled, TranslatorEdit
   GuiControl, Translator:, TranslatorEdit, 正在处理...`n`n翻译中...

   ; 获取主窗口坐标+宽高
   WinGetPos, X, Y, W, H, % Lang.name
   nwx := X + W
   ; 翻译窗口不存在则显示
   Gui, Translator:Show , x%nwx% y%Y%, % TranslationEngine

   GuiControlGet, OutputVar, , Original
   ; ret := SogouTranslator.translate(OutputVar)

   switch, TranslationEngine
   {
   case Lang.baidu_translate : 
      ; MsgBox, , test, 百度
      ret := BaiduTranslator.translate(OutputVar)
   case Lang.sougou_translate : 
      ; MsgBox, , test, 搜狗
      ret := SogouTranslator.translate(OutputVar)
   }

   GuiControl, Translator:, TranslatorEdit, % ret
   GuiControl, Translator:Enable, TranslatorEdit
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
      ret.switch_translation_engine := "切换翻译引擎"
      ret.baidu_translate := "百度翻译"
      ret.sougou_translate := "搜狗翻译"
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
      ret.switch_translation_engine := "Switching translation engine"
      ret.baidu_translate := "Baidu Translate"
      ret.sougou_translate := "Sougou Translate"
   }

   return, ret
}