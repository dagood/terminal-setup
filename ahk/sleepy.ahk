; https://gist.github.com/davejamesmiller/1965854

; I use this to fix a problem where my monitor won't wake from sleep/standby
; mode, remaining dark, even though I see my desktop on other monitors. Forcing
; the monitor to sleep then reactivating it seems to retrigger the wake-up and
; fix it pretty reliably. Before this fix, I would have to manually power cycle
; the monitor.
;
; I think the problem occurs when I wake up my monitors too soon after they go
; to sleep, e.g. when I take a too-exact 5-minute break and they're on the cusp
; of standby. Using this hotkey to lock my computer when I step away ensures my
; monitors go to sleep as soon as I leave, so I don't have to worry about
; running into this problem in the first place, once I get back.

; Win+Shift+L
#+L::
    Run rundll32.exe user32.dll`,LockWorkStation     ; Lock PC
    Sleep 1000
    SendMessage 0x112, 0xF170, 2, , Program Manager  ; Monitor off
    Return
