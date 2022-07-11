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
CREATE_LINK_LOADING_SCREEN_GAMEPAD_SCENE:AddFragment(PREGAME_ANIMATED_BACKGROUND_FRAGMENT)

-----------------------
--World Select
-----------------------
WORLD_SELECT_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
WORLD_SELECT_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_BACKDROP_FRAGMENT)
WORLD_SELECT_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
WORLD_SELECT_GAMEPAD_SCENE:AddFragment(PREGAME_ANIMATED_BACKGROUND_FRAGMENT)

-----------------------
--Character Select
-----------------------
GAMEPAD_CHARACTER_SELECT_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
GAMEPAD_CHARACTER_SELECT_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
GAMEPAD_CHARACTER_SELECT_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_BACKDROP_FRAGMENT)

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
GAMEPAD_CREDITS_ROOT_SCENE:AddFragment(GAME_CREDITS_GAMEPAD:GetFragment())
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

-----------------------
--Create Link Account
-----------------------
CREATE_LINK_ACCOUNT_SCREEN_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
CREATE_LINK_ACCOUNT_SCREEN_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_BACKDROP_FRAGMENT)
CREATE_LINK_ACCOUNT_SCREEN_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
CREATE_LINK_ACCOUNT_SCREEN_GAMEPAD_SCENE:AddFragment(PREGAME_ANIMATED_BACKGROUND_FRAGMENT)

-----------------------
--Create Account
-----------------------
CREATE_ACCOUNT_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
CREATE_ACCOUNT_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_BACKDROP_FRAGMENT)
CREATE_ACCOUNT_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
CREATE_ACCOUNT_GAMEPAD_SCENE:AddFragment(PREGAME_ANIMATED_BACKGROUND_FRAGMENT)

-----------------------
--Create Account Final
-----------------------
CREATE_ACCOUNT_FINAL_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
CREATE_ACCOUNT_FINAL_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_BACKDROP_FRAGMENT)
CREATE_ACCOUNT_FINAL_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
CREATE_ACCOUNT_FINAL_GAMEPAD_SCENE:AddFragment(PREGAME_ANIMATED_BACKGROUND_FRAGMENT)

-----------------------
--Link Account
-----------------------
LINK_ACCOUNT_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
LINK_ACCOUNT_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_BACKDROP_FRAGMENT)
LINK_ACCOUNT_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
LINK_ACCOUNT_GAMEPAD_SCENE:AddFragment(PREGAME_ANIMATED_BACKGROUND_FRAGMENT)

-----------------------
--Link Account Final
-----------------------
LINK_ACCOUNT_FINAL_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
LINK_ACCOUNT_FINAL_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_BACKDROP_FRAGMENT)
LINK_ACCOUNT_FINAL_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
LINK_ACCOUNT_FINAL_GAMEPAD_SCENE:AddFragment(PREGAME_ANIMATED_BACKGROUND_FRAGMENT)

-----------------------
--Confirm Link Account
-----------------------
CONFIRM_LINK_ACCOUNT_SCREEN_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
CONFIRM_LINK_ACCOUNT_SCREEN_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_BACKDROP_FRAGMENT)
CONFIRM_LINK_ACCOUNT_SCREEN_GAMEPAD_SCENE:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
CONFIRM_LINK_ACCOUNT_SCREEN_GAMEPAD_SCENE:AddFragment(PREGAME_ANIMATED_BACKGROUND_FRAGMENT)
