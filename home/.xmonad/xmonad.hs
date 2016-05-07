import Data.Char (toLower)
import Data.Maybe (maybe)
import System.Environment (lookupEnv)
import System.FilePath (takeBaseName)

import XMonad

import XMonad.Config.Desktop
import XMonad.Config.Gnome
import XMonad.Config.Kde
import XMonad.Config.Xfce

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

desktop = conf . map toLower . takeBaseName
  where
    conf "gnome"         = gnomeConfig
    conf "gnome-xmonad"  = gnomeConfig
    conf "kde"           = kde4Config
    conf "plasma"        = kde4Config
    conf "plasma-xmonad" = kde4Config
    conf "xfce"          = xfceConfig
    conf "xfce-xmonad"   = xfceConfig
    conf _               = desktopConfig

myLayouts = tiled ||| Mirror tiled ||| Full ||| floatLayout
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled   = Tall nmaster delta ratio
    -- The default number of windows in the master pane
    nmaster = 1
    -- Default proportion of screen occupied by master pane
    ratio   = 1/2
    -- Percent of screen to increment by when resizing panes
    delta   = 3/100

    floatLayout = named "Float"
                $ floatingDeco
                $ borderResize
                $ minimize
                $ maximize
                $ noBorders simplestFloat

    floatingDeco = imageButtonDeco shrinkText defaultThemeWithImageButtons
        { activeColor = "#000000"
        , inactiveColor = "#3C3B37"
        , fontName = "xft:TakaoPGothic-9:bold" }

myHandleEventHook = minimizeEventHook

keybinding session =
  let
    gnomeKey = [("M-S-q", spawn "gnome-session-quit --power-off")]
  in
    case session of
        "gnome"        -> gnomeKey
        "gnome-xmonad" -> gnomeKey
        _              -> []

main = do
    -- the value of $DESKTOP_SESSION may differ between distributions
    session <- lookupEnv "DESKTOP_SESSION"
    let myConfig = maybe desktopConfig desktop session
    let myManageHook = composeAll
         [ manageHook myConfig
         , isDialog --> doCenterFloat
         , isFullscreen --> doFullFloat
         , className =? "plasmashell" --> doFloat ]
    let myKeybinding = maybe [] keybinding session

    xmonad $ myConfig
        { manageHook = myManageHook
        , layoutHook = desktopLayoutModifiers $ smartBorders $ myLayouts
        , handleEventHook = myHandleEventHook <+> handleEventHook myConfig
        , workspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
        , modMask = mod4Mask
        , focusFollowsMouse = False }
        `additionalKeysP`
        myKeybinding
