# Ideas/Features

- [ ] Change volume for `$BROWSER` environment variable? Most general media source apart from separate music/video players.
- [ ] Hyprsunset module.

# Stupid idea's from Daivin

- [ ] An on screen pencil to draw on your screen :).
- [ ] Bluetooth device battery view -- Not planned ( Don't have a bluetooth
      receiver )

# Completed features

- [x] Auto hide unless on mouse hover. Also implement bar changes to mute/volume to show notif or show bar for a couple seconds.
- [x] Maybe already possible; have keybinds to show certain menus. I do not want to touch my mouse to see notifications for example. Not everything in the bar needs this, but some would be good to have.
- [x] Pressing ESC or some obvious button to close nc.
- [x] Another branch for development, hold off big changes so that a working bar or if there are big config changes.
- [x] Media showing; what song/media is playing?
- [x] Brightness control for Laptops.
- [x] Battery icon for Laptops. Broken?
- [x] Quick toggle for BT, WiFi (modules in the tray do this too)
- [x] Update module: When there is 1 package it still looks extremely off
- [x] Audio module + cava / audio wave ;) ( Don't make it into minecraft blocks
      but aan actual wave) -- Probably not planned

# Issues in settingsWindow (16-03-2026)

- [ ] Drawing tool falls behind when accelerating with the cursor (slow start -> faster movement). // Unfortunately this is a limitation of either Qt or the math in my methods, you are free to look through and see if you can come up with better and more performant calculations
- [ ] Dock has an invisible border it has a visual that it attaches to; perhaps make it visible when the dock shows? // Yes
- [ ] Dock apps are clickable and navigates to app (good). If two instances are available, this feels arbitrarily chosen on one instance (maybe defaults to workspace closest to 1?) (like a selection or hover to see options). // I intend to add popups on hover that show a preview of the opened windows, so you can select which one to focus
- [ ] Dock cannot be closed with escape, user needs to click to leave Dock (Dock stops user from interacting with other apps like typing). // Intentional. It uses HyprlandFocusGrab for managing shown/hidden states.
- [ ] Global shortcut for opening Dock and perhaps keyboard navigation? (sounds hard to pull of)
- [ ] If nc or osd global shortcut are used, bar is 100% transparent apart from modules, seems to ignore the regular hover state opacity.
- [ ] Should volume/pipewire module be hover as well? No other bar module is hover apart from the Dock (which is a hidden module activated by hover)? // Unsure, probably

- [x] Undo option for Drawing tool? // You can clear on right-click. True undo
      would require me to store pen strokes in an array and is too advanced for a
      simple drawing tool
- [x] Size 1-45 kinda weird numbers (not a real issue = ragebait). // It's just
      the pixel width of the pencil.
- [x] Calendar swipe to other month has no animation -> on purpose? // On
      purpose, QT doesn't allow for animations in their calendar grid. I used to have
      an animation but it was extremely inefficient performance-wise.

## Additional questions

- [x] Can some features be disabled? As in, will they be unloaded from RAM or how is it loaded in memory? Let's say I do not want to use the Dock and Drawing Tool and want to disable them, are they loaded in memory at all? Or all the called upon when the shortcut is hit? // None of the modules that are not shown on start are loaded into memory save for notifications. I will make the options to disable different parts functional at some point, but it wouldn't help memory usage since they are loaded on-demand already
