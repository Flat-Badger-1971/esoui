if not IsGamepadUISupported() then
    -- Some scenes will not be initialized if gamepad UI isn't supported, so protect against using missing scenes
    return
end

-----------------------
--Initial Screen
-----------------------
PREGAME_INITIAL_SCREEN_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
PREGAME_INITIAL_SCREEN_GAMEPAD_SCENE:AddFragment(PREGAME_ANIMATED_BACKGROUND_FRAGMENT)

-----------------------
--Game Startup Main Screen
-----------------------
GAME_STARTUP_MAIN_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
GAME_STARTUP_MAIN_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_2_3_BACKGROUND_FRAGMENT)
GAME_STARTUP_MAIN_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_BACKDROP_FRAGMENT)
GAME_STARTUP_MAIN_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
GAME_STARTUP_MAIN_GAMEPAD_SCENE:AddFragment(PREGAME_ANIMATED_BACKGROUND_FRAGMENT)

-----------------------
--Game Startup Initial Screen
-----------------------
GAME_STARTUP_INITIAL_SERVER_SELECT_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
GAME_STARTUP_INITIAL_SERVER_SELECT_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_BACKDROP_FRAGMENT)
GAME_STARTUP_INITIAL_SERVER_SELECT_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
GAME_STARTUP_INITIAL_SERVER_SELECT_GAMEPAD_SCENE:AddFragment(PREGAME_ANIMATED_BACKGROUND_FRAGMENT)

-----------------------
--Create/Link Account Loading
-----------------------
CREATE_LINK_LOADING_SCREEN_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
CREATE_LINK_LOADING_SCREEN_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_BACKDROP_FRAGMENT)
CREATE_LINK_LOADING_SCREEN_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
CREATE_LINK_LOADING_SCREEN_GAMEPAD:SetBackgroundFragment(PREGAME_ANIMATED_BACKGROUND_FRAGMENT)

-----------------------
--World Select
-----------------------
WORLD_SELECT_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
WORLD_SELECT_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_BACKDROP_FRAGMENT)
WORLD_SELECT_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
WORLD_SELECT_GAMEPAD:SetBackgroundFragment(PREGAME_ANIMATED_BACKGROUND_FRAGMENT)

------------------------
--Screen Adjust Scene
------------------------

local screenAdjustScene = SCENE_MANAGER:GetScene("screenAdjust")
screenAdjustScene:AddFragment(GAMEPAD_SCREEN_ADJUST_ACTION_LAYER_FRAGMENT)

-------------------
--Screen Adjust for the Intro Sequence
-------------------

local screenAdjustSceneIntro = SCENE_MANAGER:GetScene("screenAdjustIntro")
screenAdjustSceneIntro:AddFragment(PREGAME_SCREEN_ADJUST_INTRO_ADVANCE_FRAGMENT)
screenAdjustSceneIntro:AddFragment(GAMEPAD_SCREEN_ADJUST_ACTION_LAYER_FRAGMENT)

-----------------------
--Character Select
-----------------------
GAMEPAD_CHARACTER_SELECT_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
GAMEPAD_CHARACTER_SELECT_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)

-----------------------
--Character Create
-----------------------
GAMEPAD_CHARACTER_CREATE_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
GAMEPAD_CHARACTER_CREATE_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_BACKDROP_FRAGMENT)

-----------------------
--Gamepad Options Root Scene
-----------------------

GAMEPAD_OPTIONS:InitializeScenes()
GAMEPAD_OPTIONS_ROOT_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
GAMEPAD_OPTIONS_ROOT_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
GAMEPAD_OPTIONS_ROOT_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_BACKDROP_FRAGMENT)
GAMEPAD_OPTIONS_ROOT_SCENE:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
GAMEPAD_OPTIONS_ROOT_SCENE:AddFragment(GAMEPAD_OPTIONS_FRAGMENT)
GAMEPAD_OPTIONS_ROOT_SCENE:AddFragment(GAMEPAD_OPTIONS:GetHeaderFragment())

-----------------------
--Gamepad Options Panel Scene
-----------------------

GAMEPAD_OPTIONS_PANEL_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
GAMEPAD_OPTIONS_PANEL_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
GAMEPAD_OPTIONS_PANEL_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_BACKDROP_FRAGMENT)
GAMEPAD_OPTIONS_PANEL_SCENE:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
GAMEPAD_OPTIONS_PANEL_SCENE:AddFragment(GAMEPAD_OPTIONS_FRAGMENT)
GAMEPAD_OPTIONS_PANEL_SCENE:AddFragment(GAMEPAD_OPTIONS:GetHeaderFragment())

-----------------------
--Gamepad Credits Root Scene
-----------------------

GAMEPAD_CREDITS_ROOT_SCENE = ZO_Scene:New("gamepad_credits", SCENE_MANAGER)
GAMEPAD_CREDITS_ROOT_SCENE:AddFragment(GAME_CREDITS_GAMEPAD_FRAGMENT)
GAMEPAD_CREDITS_ROOT_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
GAMEPAD_CREDITS_ROOT_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_BACKDROP_FRAGMENT)

-----------------------
-- Chapter Upgrade Scene
-----------------------

local chapterUpgradeScene = SCENE_MANAGER:GetScene("chapterUpgradeGamepad")
chapterUpgradeScene:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
chapterUpgradeScene:AddFragment(KEYBIND_STRIP_GAMEPAD_BACKDROP_FRAGMENT)

-----------------------
--Legal Agreements
-----------------------
LEGAL_AGREEMENTS_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
LEGAL_AGREEMENTS_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_BACKDROP_FRAGMENT)
LEGAL_AGREEMENTS_GAMEPAD_SCENE:AddFragment(PREGAME_ANIMATED_BACKGROUND_FRAGMENT)
