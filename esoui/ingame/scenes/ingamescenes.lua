-------------------
--Gamma Adjust
-------------------

local gammaAdjustScene = ZO_Scene:New("gammaAdjust", SCENE_MANAGER)
gammaAdjustScene:AddFragment(GAMMA_SCENE_FRAGMENT)

------------------------
-- Screen Adjust Scene
------------------------

local screenAdjustScene = ZO_Scene:New("screenAdjust", SCENE_MANAGER)
screenAdjustScene:AddFragment(SCREEN_ADJUST_SCENE_FRAGMENT)
screenAdjustScene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW) -- TODO: Heron, why is this here?
screenAdjustScene:AddFragment(MINIMIZE_CHAT_FRAGMENT)
screenAdjustScene:AddFragment(SCREEN_ADJUST_ACTION_LAYER_FRAGMENT)

-------------------
--Crown Store Announcement Scene
-------------------

local announcementScene = ZO_RemoteScene:New("marketAnnouncement", SCENE_MANAGER)
announcementScene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW_NO_KEYBIND_STRIP)

-------------------
-- Show Market Scene
-------------------

local showMarketScene = ZO_RemoteScene:New("show_market", SCENE_MANAGER)
showMarketScene:AddFragment(SHOW_MARKET_FRAGMENT)

-------------------
-- Show Eso Plus Scene
-------------------

local showEsoPlusScene = ZO_RemoteScene:New("show_esoPlus", SCENE_MANAGER)
showEsoPlusScene:AddFragment(SHOW_ESO_PLUS_FRAGMENT)

----------------
--Lockpick Scene
----------------

LOCK_PICK_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
LOCK_PICK_SCENE:AddFragment(LOCKPICK_FRAGMENT)
LOCK_PICK_SCENE:AddFragment(UNIFORM_BLUR_FRAGMENT)
LOCK_PICK_SCENE:AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
LOCK_PICK_SCENE:AddFragment(LOCKPICK_TUTORIAL_FRAGMENT)

------------------------
--Lore Reader (From Inventory)
------------------------

LORE_READER_INVENTORY_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
LORE_READER_INVENTORY_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_CENTERED_UNIFORM_BLUR)
LORE_READER_INVENTORY_SCENE:AddFragment(LORE_READER_FRAGMENT)
LORE_READER_INVENTORY_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_INVENTORY)
LORE_READER_INVENTORY_SCENE:AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)

------------------------
--Lore Reader (From Lore Library)
------------------------

LORE_READER_LORE_LIBRARY_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
LORE_READER_LORE_LIBRARY_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
LORE_READER_LORE_LIBRARY_SCENE:AddFragment(LORE_READER_FRAGMENT)
LORE_READER_LORE_LIBRARY_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_JOURNAL)
LORE_READER_LORE_LIBRARY_SCENE:AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)

------------------------
--Lore Reader (From Interaction)
------------------------

LORE_READER_INTERACTION_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
LORE_READER_INTERACTION_SCENE:AddFragment(LORE_READER_FRAGMENT)
LORE_READER_INTERACTION_SCENE:AddFragment(UNIFORM_BLUR_FRAGMENT)
LORE_READER_INTERACTION_SCENE:AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)

------------------------
--Treasure Map (From Inventory)
------------------------

TREASURE_MAP_INVENTORY_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
TREASURE_MAP_INVENTORY_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_CENTERED_UNIFORM_BLUR)
TREASURE_MAP_INVENTORY_SCENE:AddFragment(TREASURE_MAP_FRAGMENT)
TREASURE_MAP_INVENTORY_SCENE:AddFragment(TREASURE_MAP_SOUNDS)
TREASURE_MAP_INVENTORY_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_INVENTORY)
TREASURE_MAP_INVENTORY_SCENE:AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)

------------------------
--Treasure Map (From Quick Slot)
------------------------

TREASURE_MAP_QUICK_SLOT_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
TREASURE_MAP_QUICK_SLOT_SCENE:AddFragment(TREASURE_MAP_FRAGMENT)
TREASURE_MAP_QUICK_SLOT_SCENE:AddFragment(TREASURE_MAP_SOUNDS)
TREASURE_MAP_QUICK_SLOT_SCENE:AddFragment(UNIFORM_BLUR_FRAGMENT)
TREASURE_MAP_QUICK_SLOT_SCENE:AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)

-----------------------
--Game Menu
-----------------------

GAME_MENU_SCENE:AddFragment(MOUSE_UI_MODE_FRAGMENT)
GAME_MENU_SCENE:AddFragment(UI_SHORTCUTS_ACTION_LAYER_FRAGMENT)
GAME_MENU_SCENE:AddFragment(CLEAR_CURSOR_FRAGMENT)
GAME_MENU_SCENE:AddFragment(UI_COMBAT_OVERLAY_FRAGMENT)
GAME_MENU_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_OPTIONS)
GAME_MENU_SCENE:AddFragment(SYSTEM_WINDOW_SOUNDS)
GAME_MENU_SCENE:AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
GAME_MENU_SCENE:AddFragment(PERFORMANCE_METER_FRAGMENT)
GAME_MENU_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)

-----------------------
--Siege Bar Scene
-----------------------

SIEGE_BAR_SCENE:AddFragmentGroup(FRAGMENT_GROUP.SIEGE_BAR_GROUP)
SIEGE_BAR_UI_SCENE:AddFragmentGroup(FRAGMENT_GROUP.SIEGE_BAR_GROUP)

---------------------------
--Champion Perks Scene
---------------------------

CHAMPION_PERKS_SCENE:AddFragment(CHAMPION_PERKS_CONSTELLATIONS_FRAGMENT)
CHAMPION_PERKS_SCENE:AddFragment(CHAMPION_KEYBIND_STRIP_FADE_FRAGMENT)
CHAMPION_PERKS_SCENE:AddFragment(KEYBIND_STRIP_MUNGE_BACKDROP_FRAGMENT)
CHAMPION_PERKS_SCENE:AddFragment(MOUSE_UI_MODE_FRAGMENT)
CHAMPION_PERKS_SCENE:AddFragment(UI_SHORTCUTS_ACTION_LAYER_FRAGMENT)
CHAMPION_PERKS_SCENE:AddFragment(CLEAR_CURSOR_FRAGMENT)
CHAMPION_PERKS_SCENE:AddFragment(UI_COMBAT_OVERLAY_FRAGMENT)
CHAMPION_PERKS_SCENE:AddFragment(END_IN_WORLD_INTERACTIONS_FRAGMENT)
CHAMPION_PERKS_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)
CHAMPION_PERKS_SCENE:AddFragment(CHAMPION_PERKS_CHOSEN_ATTRIBUTE_TYPE_POINT_COUNTER_FRAGMENT)
CHAMPION_PERKS_SCENE:AddFragment(CHAMPION_PERKS_CHOSEN_ATTRIBUTE_TYPE_EARNED_POINT_COUNTER_FRAGMENT)
CHAMPION_PERKS_SCENE:AddFragment(CHAMPION_WINDOW_SOUNDS)
CHAMPION_PERKS_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_CHAMPION)
CHAMPION_PERKS_SCENE:AddFragment(FRAME_PLAYER_FRAGMENT)
CHAMPION_PERKS_SCENE:AddFragment(CHAMPION_UI_MUSIC_FRAGMENT)

-----------------------
--Housing Editor Scene
-----------------------

HOUSING_EDITOR_HUD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.HOUSING_EDITOR_HUD)
HOUSING_EDITOR_HUD_SCENE:AddFragment(HOUSING_EDITOR_HUD_FRAGMENT)
HOUSING_EDITOR_HUD_SCENE:AddFragment(ZO_TutorialTriggerFragment:New(TUTORIAL_TRIGGER_OPENED_EDITOR))

HOUSING_EDITOR_HUD_UI_SCENE:AddFragmentGroup(FRAGMENT_GROUP.HOUSING_EDITOR_HUD)

----------------------------------------------
-- Battleground Scoreboard End Of Game Scene
----------------------------------------------

BATTLEGROUND_SCOREBOARD_END_OF_GAME_SCENE:AddFragmentGroup(FRAGMENT_GROUP.BATTLEGROUND_SCOREBOARD_GROUP)
BATTLEGROUND_SCOREBOARD_END_OF_GAME_SCENE:AddFragment(BATTLEGROUND_SCOREBOARD_END_OF_GAME_OPTIONS)
BATTLEGROUND_SCOREBOARD_END_OF_GAME_SCENE:AddFragment(BATTLEGROUND_SCOREBOARD_ACTION_LAYER_FRAGMENT)

BATTLEGROUND_SCOREBOARD_IN_GAME_SCENE:AddFragmentGroup(FRAGMENT_GROUP.BATTLEGROUND_SCOREBOARD_GROUP)
BATTLEGROUND_SCOREBOARD_IN_GAME_SCENE:AddFragment(BATTLEGROUND_SCOREBOARD_ACTION_LAYER_FRAGMENT)
BATTLEGROUND_SCOREBOARD_IN_GAME_SCENE:AddFragment(BATTLEGROUND_SCOREBOARD_IN_GAME_TIMER_FRAGMENT)

BATTLEGROUND_SCOREBOARD_IN_GAME_UI_SCENE:AddFragmentGroup(FRAGMENT_GROUP.BATTLEGROUND_SCOREBOARD_GROUP)
BATTLEGROUND_SCOREBOARD_IN_GAME_UI_SCENE:AddFragment(MOUSE_UI_MODE_FRAGMENT)

-------------------
-- Antiquity Digging Minigame Remote Scene
-------------------

ANTIQUITY_DIGGING_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW_NO_KEYBIND_STRIP)
ANTIQUITY_DIGGING_SCENE:AddFragment(ANTIQUITY_DIGGING_FRAGMENT)
ANTIQUITY_DIGGING_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)

-------------------
-- Scrying Minigame Remote Scene
-------------------

SCRYING_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW_NO_KEYBIND_STRIP)
SCRYING_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)
SCRYING_SCENE:AddFragment(SCRYING_UI_MUSIC_FRAGMENT)

