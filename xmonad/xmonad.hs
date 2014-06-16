{-# LANGUAGE NoMonomorphismRestriction #-} -- allow binding of GSConfig at top level
{-# LANGUAGE TypeSynonymInstances #-} -- allow funky coloring thing
{-# LANGUAGE FlexibleInstances #-}
import XMonad
import qualified XMonad.StackSet as W

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ICCCMFocus

import XMonad.Util.Run(spawnPipe,safeSpawn)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.Scratchpad

import XMonad.Actions.Volume
import XMonad.Actions.TopicSpace
import XMonad.Actions.GridSelect

import XMonad.Layout.PerWorkspace
import XMonad.Layout.NoBorders

-- Non-XMonad
import System.IO
import Control.Monad
import Data.Monoid(Endo)
import qualified Data.Map as M

-- own libs
import XMonad.Layout.TopicExtra
import XMonad.Layout.WorkspaceDirAlt

main :: IO ()
main = do
    checkTopicConfig myWorkSpaces myTopicConfig
    xmonad $ defaultConfig
        { modMask = modm
        , borderWidth = 1
        , normalBorderColor  = "#111111"
        , focusedBorderColor = "#000000"
        , manageHook = myManageHook <+> scratchpadManageHook (W.RationalRect 0.2 0.2 0.6 0.6) <+> manageHook defaultConfig
        , layoutHook = setWorkspaceDirs $ avoidStruts $ smartBorders myLayoutHook
        , workspaces = myWorkSpaces
        , focusFollowsMouse = False
        } `additionalKeys`
        [ ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
        , ((0, xK_Print), spawn "scrot")
        , ((0, xK_F8), void $ lowerVolume 5)
        , ((0, xK_F9), void $ raiseVolume 5)
        , ((modm, xK_l), spawn "i3lock -n -c 000000")
        , ((modm, xK_b), sendMessage ToggleStruts)
        , ((modm, xK_z), goToSelectedWS myTopicConfig True myGSConfig)
        , ((modm, xK_F10), spawn touchpadToggle)
        , ((modm, xK_space), scratchpadSpawnActionCustom "gnome-terminal --disable-factory --name scratchpad")
        ]

touchpad = "\"SynPS/2 Synaptics TouchPad\""
touchpadToggle = "bash -c 'a=$(xinput --list-props " ++ touchpad ++
                 " | grep Enabled);xinput --set-prop " ++ touchpad ++
                 " \"Device Enabled\" $(((${a:(-1)} + 1) % 2));'"

myBrowser = "google-chrome"

myGSConfig = defaultGSConfig {gs_navigate = navNSearch}

myWorkSpaces :: [String]
myWorkSpaces = ["web"
               ,"shell1"
               ,"shell2"
               ,"shell3"
               ,"im"
               ,"gmail"
               ,"calendar"
               ,"procrastination"
               ,"pdf"
               ,"webdev"
               ,"ping"
               ,"read"
               ]

setWorkspaceDirs layout =
--    add "nanowrimo"   "~/Dropbox/writing/NaNoWriMo"            $
    workspaceDir "~" layout
  where add ws dir = onWorkspace ws (workspaceDir dir layout)

myLayoutHook :: Choose Full (Choose Tall (Mirror Tall)) a
myLayoutHook = Full ||| tiled ||| Mirror tiled
    where
     tiled = Tall nmaster delta ratio
     nmaster = 1
     ratio = 1/2
     delta = 3/100

myTopicConfig :: TopicConfig
myTopicConfig = TopicConfig
  { topicDirs = M.fromList []
  , topicActions = M.fromList
      [ ("gmail", appBrowser ["https://gmail.com"])
--      , ("web", browser)
      , ("read", appBrowser ["https://read.amazon.com"])
      , ("calendar", appBrowser ["https://calendar.google.com"])
      , ("im", spawn "pidgin")
      , ("im", spawn "xchat")
      , ("procrastination", newBrowser ["https://cloud.feedly.com"
                                       ,"http://www.reddit.com"])
      , ("webdev", spawn "gnome-terminal -e 'ssh -p 2222 tayacan@tayacan.dk'")
      , ("ping", spawn "gnome-terminal -e 'ping 8.8.8.8'")
      ]
  , defaultTopicAction = const $ return ()
  , defaultTopic = "web"
  , maxTopicHistory = 10
  }

myManageHook :: Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
    [ className =? "Pidgin" --> doShift "im"
    , className =? "Skype" --> doShift "im"
    , className =? "Xchat" --> doShift "im"
    , className =? "Evince" --> doShift "pdf"
    , manageDocks
    ]

modm ::  KeyMask
modm = mod4Mask

instance HasColorizer WindowSpace where
  defaultColorizer ws isFg =
    if nonEmptyWS ws || isFg
    then stringColorizer (W.tag ws) isFg
         -- Empty workspaces get a dusty-sandy-ish colour
    else return ("#CAC3BA", "white")

browser, incogBrowser, newBrowser, appBrowser :: [String] -> X ()
browser         = safeSpawn myBrowser
incogBrowser s  = safeSpawn myBrowser ("--new-window" : "--incognito" : s)
newBrowser s    = safeSpawn myBrowser ("--new-window" : s)
appBrowser      = mapM_ (\s -> safeSpawn myBrowser ["--app=" ++ s])
