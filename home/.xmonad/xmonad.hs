import XMonad
import XMonad.Config.Desktop (desktopLayoutModifiers)
import XMonad.Config.Gnome
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.Minimize
import XMonad.Layout.BorderResize
import XMonad.Layout.ImageButtonDecoration
import XMonad.Layout.DecorationAddons
import XMonad.Layout.Minimize
import XMonad.Layout.Maximize
import XMonad.Layout.NoBorders
import XMonad.Layout.Named
import XMonad.Layout.SimpleDecoration
import XMonad.Layout.SimplestFloat
import XMonad.Util.EZConfig (additionalKeysP)

myFloat = named "Float" $ floatingDeco $ borderResize $ minimize $ maximize $ noBorders simplestFloat
	where floatingDeco = imageButtonDeco shrinkText defaultThemeWithImageButtons
		{ activeColor = "#000000"
		, inactiveColor = "#3C3B37"
		, fontName = "xft:TakaoPGothic-9:bold" }

myLayout = tiled ||| Mirror tiled ||| Full ||| myFloat 
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio
     -- The default number of windows in the master pane
     nmaster = 1
     -- Default proportion of screen occupied by master pane
     ratio   = 1/2
     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

myManageHook = composeAll
	[ manageHook gnomeConfig
	, isDialog --> doCenterFloat
	, isFullscreen --> doFullFloat
	]

myHandleEventHook = minimizeEventHook

main = do
	xmonad $ gnomeConfig
		{ manageHook = myManageHook
		, layoutHook = desktopLayoutModifiers $ smartBorders $ myLayout
		, handleEventHook = myHandleEventHook <+> handleEventHook gnomeConfig
		, workspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
		, modMask = mod4Mask
		, focusFollowsMouse = False }
		`additionalKeysP`
		[ ("M-S-q", spawn "gnome-session-quit --power-off") ]
