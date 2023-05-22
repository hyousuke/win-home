;;; -*- coding: utf-8-dos -*-
;;
;;  key-bind.ahk
;;
;;  - https://qiita.com/asublue/items/0e3fad2667545793466d

#SingleInstance
#SuspendExempt
>^F1::Suspend
>^F2::Reload
#SuspendExempt False

;===================================================================================
;
; Global Vars
;

DEBUG_MODE := 0

; Emacs Emulate Level Settings
EMU_LV_0_PASSTHROUGH   := 0
EMU_LV_2_IME_ONLY      := 2
EMU_LV_5_CTRL_G_QUIT   := 5
EMU_LV_8_MINIMUM_EMACS := 8
EMU_LV_10_EMACS        :=10
EMU_LV_20_FULL_EMACS   :=20

; Emacs Key State
EMU_CTRL_X_PRESSED   := 0
EMU_REGION_ACTIVATED := 0
EMU_ESCAPE_PRESSED   := 0
EMU_IS_SEARCHING     := 0


;===================================================================================
;
; Funcs
;

setup_emulate_level_groups() {

  ; EMU_LV_0_PASSTHROUGH
  GroupAdd "EmuLv0_Passthrough", "ahk_exe msrdc.exe" ; WSLg Apps

  ; EMU_LV_2_IME_ONLY
  GroupAdd "EmuLv2_ImeOnly", "ahk_exe WindowsTerminal.exe" ; WindowsTerminal

  ; EMU_LV_5_CTRL_G_QUIT
  ; GroupAdd "EmuLv5_CtrlGQuit", "ahk_exe notepad2.exe"

  ; EMU_LV_8_MINIMUM_EMACS
  GroupAdd "EmuLv8_MinimumEmacs", "ahk_exe explorer.exe"

  ; EMU_LV_10_EMACS
  ; default

  ; EMU_LV_20_FULL_EMACS
  GroupAdd "EmuLv20_FullEmacs", "ahk_exe notepad.exe"
  GroupAdd "EmuLv20_FullEmacs", "ahk_exe notepad2.exe"
}

get_emulate_level() {

  static prev_exe := ""
  static prev_level := -1

  ;; cache
  cur_exe := WinGetProcessName("A")
  if ( prev_exe == cur_exe )
    return prev_level

  prev_exe := cur_exe
  if WinActive("ahk_group EmuLv0_Passthrough")
    return prev_level:=EMU_LV_0_PASSTHROUGH
  if WinActive("ahk_group EmuLv2_ImeOnly")
    return prev_level:=EMU_LV_2_IME_ONLY
  if WinActive("ahk_group EmuLv5_CtrlGQuit")
    return prev_level:=EMU_LV_5_CTRL_G_QUIT
  if WinActive("ahk_group EmuLv8_MinimumEmacs")
    return prev_level:=EMU_LV_8_MINIMUM_EMACS

  if WinActive("ahk_group EmuLv20_FullEmacs")
    return prev_level:=EMU_LV_20_FULL_EMACS

  ; fallback
  return prev_level:=EMU_LV_10_EMACS
}

main() {

  if (DEBUG_MODE > 0)
    InstallKeybdHook True True
  ListLines DEBUG_MODE

  ;; Disable delay
  SetControlDelay 0
  SetKeyDelay -1 ;; disable key delay
  SetWinDelay 0
  SendMode "Input"

  setup_emulate_level_groups()
}

main()


;===================================================================================
;
; Funcs for Emacs Emulate
;

reset_pre_keys()
{
  global
  EMU_CTRL_X_PRESSED := 0
  EMU_REGION_ACTIVATED := 0
  EMU_ESCAPE_PRESSED := 0
  Return
}

reset_all_status()
{
  reset_pre_keys()
  global EMU_IS_SEARCHING := 0
}

delete_char()
{
  Send "{Del}"
  reset_all_status()
  Return
}

delete_backward_char()
{
  Send "{BS}"
  reset_all_status()
  Return
}

kill_line()
{
  Send "{ShiftDown}{END}{ShiftUp}"
  Sleep 50 ;[ms] this value depends on your environment
  A_Clipboard := "" ; set empty
  Send "^x"
  ClipWait(0.1) ; wait for copy finish
  text := A_Clipboard ; get the copied text

  ;; if start pos is at line end (text is empty)
  if (text = "") {
    Send "{ShiftDown}{Right}{ShiftUp}"
    Sleep 50 ;[ms] this value depends on your environment
    Send "^x"
  }

  reset_all_status()
  Return
}

open_line()
{
  Send "{END}{Enter}{Up}"
  reset_all_status()
  Return
}

quit()
{
  Send "{ESC}"
  reset_all_status()
  Return
}

newline()
{
  Send "{Enter}"
  reset_all_status()
  Return
}

indent_for_tab_command()
{
  Send "{Tab}"
  reset_all_status()
  Return
}

newline_and_indent()
{
  Send "{Enter}{Tab}"
  reset_all_status()
  Return
}

isearch_forward()
{
  global
  If EMU_IS_SEARCHING
    Send "{F3}"
  Else
  {
    Send "^f"
    EMU_IS_SEARCHING := 1
  }
  reset_pre_keys()
  Return
}

isearch_backward()
{
  global
  If EMU_IS_SEARCHING
    Send "+{F3}"
  Else
  {
    Send "^f"
    EMU_IS_SEARCHING := 1
  }
  reset_pre_keys()
  Return
}

kill_region()
{
  Send "^x"
  reset_all_status()
  Return
}

kill_ring_save()
{
  Send "^c"
  reset_all_status()
  Return
}

yank()
{
  Send "^v"
  reset_all_status()
  Return
}

undo()
{
  Send "^z"
  reset_all_status()
  Return
}

find_file()
{
  Send "^o"
  reset_all_status()
  Return
}

save_buffer()
{
  Send "^s"
  reset_all_status()
  Return
}

kill_window()
{
  Send "!{F4}"
  reset_all_status()
  Return
}

kill_buffer()
{
  Send "^w"
  reset_all_status()
  Return
}

move_beginning_of_line()
{
  global
  If EMU_REGION_ACTIVATED
    Send "+{HOME}"
  Else
  {
    Send "{HOME}"
    reset_all_status()
  }
  Return
}

move_end_of_line()
{
  global
  If EMU_REGION_ACTIVATED
    Send "+{END}"
  Else
  {
    Send "{END}"
    reset_all_status()
  }
  Return
}

previous_line()
{
  global
  If EMU_REGION_ACTIVATED
    Send "+{Up}"
  Else
  {
    Send "{Up}"
    reset_all_status()
  }
  Return
}

next_line()
{
  global
  If EMU_REGION_ACTIVATED
    Send "+{Down}"
  Else
  {
    Send "{Down}"
    reset_all_status()
  }
  Return
}

forward_char()
{
  global
  If EMU_REGION_ACTIVATED
    Send "+{Right}"
  Else
  {
    Send "{Right}"
    reset_all_status()
  }
  Return
}

backward_char()
{
  global
  If EMU_REGION_ACTIVATED
    Send "+{Left}"
  Else
  {
    Send "{Left}"
    reset_all_status()
  }
  Return
}

scroll_up()
{
  global
  If EMU_REGION_ACTIVATED
    Send "+{PgUp}"
  Else
  {
    Send "{PgUp}"
    reset_all_status()
  }
  Return
}

scroll_down()
{
  global
  If EMU_REGION_ACTIVATED
    Send "+{PgDn}"
  Else
  {
    Send "{PgDn}"
    reset_all_status()
  }
  Return
}

; https://qiita.com/c-nuts/items/20d02e572b6a06d5dce7
ime_switch()
{
  global
  Send "{vkF3sc029}"
  reset_all_status()
  Return
}

pageup_top()
{
  global
  If EMU_REGION_ACTIVATED
    Send "+^{Home}"
  Else
  {
    Send "^{Home}"
    reset_all_status()
  }
  Return
}

pagedown_bottom()
{
  global
  If EMU_REGION_ACTIVATED
    Send "+^{End}"
  Else
  {
    Send "^{End}"
    reset_all_status()
  }
  Return
}


;===================================================================================
;
; Hotkey Settings
;
#UseHook True

; -----------------------------------------------------------------------------
; for every apps

<^#z::
{
  MsgBox("CLASS:[" WinGetClass("A")
         "], EXE:[" WinGetProcessName("A")
         "], TITLE:[" WinGetTitle("A")
         "], Lv:"  get_emulate_level())
  return
}

; -----------------------------------------------------------------------------
; for Level 2 (IME Only)
#HotIf get_emulate_level() >= EMU_LV_2_IME_ONLY

<^#2:: MsgBox "* Lv2 Bind * " WinGetProcessName("A") ", Lv:" get_emulate_level()

; Ctrl-\ (Backslash) vkE2sc073 SC02B
;^\::
;^vkE2sc073::
>^vkE2::ime_switch()

 ;
; 以下は Emacs とは無関係だがこの Level で設定しておく
;

>^.::Send "^{Tab}"
>^,::Send "^+{Tab}"

>^r::Send "{F2}"

>^!g::Send "!{F4}"

; -----------------------------------------------------------------------------
; for Level 5 (CtrlG)
#HotIf get_emulate_level() >= EMU_LV_5_CTRL_G_QUIT

<^#5:: MsgBox "* Lv5 Bind * " WinGetProcessName("A") ", Lv:" get_emulate_level()

>^g::quit()

; -----------------------------------------------------------------------------
; for Level 8 (Minimum Emacs)
#HotIf get_emulate_level() >= EMU_LV_8_MINIMUM_EMACS

<^#8:: MsgBox "* Lv8 Bind * " WinGetProcessName("A") ", Lv:" get_emulate_level()

#SuspendExempt
>^q::Suspend
#SuspendExempt False

>^f::
{
  global
  If EMU_CTRL_X_PRESSED
    find_file()
  Else
    forward_char()
  Return
}
>^b::backward_char()
>^n::next_line()
>^p::previous_line()
>^a::move_beginning_of_line()
>^e::move_end_of_line()

>^d::delete_char()
>^h::delete_backward_char()
>^k::kill_line()

; -----------------------------------------------------------------------------
; for Level 10 (Emacs(default))
#HotIf get_emulate_level() >= EMU_LV_10_EMACS

<^#a:: MsgBox "* Lv10 Bind * " WinGetProcessName("A") ", Lv:" get_emulate_level()

>^s::
{
  global
  If EMU_CTRL_X_PRESSED
    save_buffer()
  Else
    isearch_forward()
  Return
}
>^r::isearch_backward()
>^w::kill_region()
!w::kill_ring_save()
w::
{
  global
  If EMU_ESCAPE_PRESSED
    kill_ring_save()
  Else
    Send A_ThisHotkey
  Return
}
>^y::yank()
>^/::undo()
;; ^{Space}::
;; ^vk20sc039::
>^vk20::
{
  global
  If EMU_REGION_ACTIVATED
    EMU_REGION_ACTIVATED := 0
  Else
    EMU_REGION_ACTIVATED := 1
  Return
}

>^v::scroll_down()
!v::scroll_up()
v::
{
  global
  If EMU_ESCAPE_PRESSED
    scroll_up()
  Else
    Send A_ThisHotkey
  Return
}

!<::pageup_top()
<::
{
  global
  If EMU_ESCAPE_PRESSED
    pageup_top()
  Else
    Send A_ThisHotkey
  Return
}

!>::pagedown_bottom()
>::
{
  global
  If EMU_ESCAPE_PRESSED
    pagedown_bottom()
  Else
    Send A_ThisHotkey
  Return
}

; not emacs
!n::scroll_down()
!p::scroll_up()

; -----------------------------------------------------------------------------
; for Level 20 (Full Emacs)
#HotIf get_emulate_level() >= EMU_LV_20_FULL_EMACS

<^#b:: MsgBox "* Lv20 Bind * " WinGetProcessName("A") ", Lv:" get_emulate_level()

>^x::global EMU_CTRL_X_PRESSED := 1
Esc::
{
  global
  If EMU_ESCAPE_PRESSED
  {
    Send "{Esc}"
    EMU_ESCAPE_PRESSED := 0
  }
  Else
    EMU_ESCAPE_PRESSED := 1
  Return
}
>^c::
{
  global
  If EMU_CTRL_X_PRESSED
    kill_window()
  Else
    Send A_ThisHotkey
  Return
}
k::
{
  global
  If EMU_CTRL_X_PRESSED
    kill_buffer()
  Else
    Send A_ThisHotkey
  Return
}
;;^o::open_line()
;;^o::ime_switch()
>^j::newline_and_indent()
>^m::newline()
>^i::indent_for_tab_command()

; -----------------------------------------------------------------------------
#HotIf ; context-sensitive hotkey-settings ends

#UseHook False
