-- width 1248
ZO_KEYBINDINGS_GAMEPAD_ACTION_NAME_GRID_ENTRY_WIDTH = 380
ZO_KEYBINDINGS_GAMEPAD_KEYBIND_GRID_ENTRY_WIDTH = 210
ZO_KEYBINDINGS_GAMEPAD_GRID_ENTRY_HEIGHT = 70
ZO_KEYBINDINGS_GAMEPAD_DIVIDER_GRID_ENTRY_WIDTH = 1220
ZO_KEYBINDINGS_GAMEPAD_DIVIDER_GRID_ENTRY_HEIGHT = 10

ZO_Keybindings_Gamepad = ZO_Gamepad_ParametricList_Screen:Subclass()

function ZO_Keybindings_Gamepad:Initialize(control)
    local ACTIVATE_ON_SHOW = true
    KEYBINDINGS_SCENE_GAMEPAD = ZO_Scene:New("keybindings_gamepad", SCENE_MANAGER)
    ZO_Gamepad_ParametricList_Screen.Initialize(self, control, ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE, ACTIVATE_ON_SHOW, KEYBINDINGS_SCENE_GAMEPAD)

    GAMEPAD_KEYBINDINGS_FRAGMENT = ZO_FadeSceneFragment:New(control)

    local rightPaneControl = control:GetNamedChild("RightPane")
    GAMEPAD_KEYBINDINGS_RIGHT_PANE_FRAGMENT = ZO_FadeSceneFragment:New(rightPaneControl)

    self.keybindingGridListControl = rightPaneControl:GetNamedChild("KeybindingGridList")

    self.actionLayerList = self:GetMainList()
    self.categoryList = self:AddList("categories")

    local function OnCategoryListTargetChanged(list, targetData, oldTargetData)
        self:UpdateKeybindingGridList()
    end

    self.categoryList:SetOnTargetDataChangedCallback(OnCategoryListTargetChanged)

    self:SetListsUseTriggerKeybinds(true)

    local function RefreshKeybindings()
        if GAMEPAD_KEYBINDINGS_RIGHT_PANE_FRAGMENT:IsShowing() then
            self.keybindingGridList:RefreshGridList()
        end
    end

    KEYBINDINGS_MANAGER:RegisterCallback("OnKeybindingSet", RefreshKeybindings)
    KEYBINDINGS_MANAGER:RegisterCallback("OnKeybindingCleared", RefreshKeybindings)
    KEYBINDINGS_MANAGER:RegisterCallback("OnKeybindingsLoaded", RefreshKeybindings)
    control:RegisterForEvent(EVENT_MOST_RECENT_GAMEPAD_TYPE_CHANGED, RefreshKeybindings)

    self.currentKeyboardFooterData =
    {
        data1HeaderText = GetString(SI_KEYBIND_CURRENT_KEYBOARD_LAYOUT_GAMEPAD_LABEL),
        data1Text = GetKeyboardLayout(),
    }

    local function UpdateCurrentKeyboardLayout(currentKeyboardLayout)
        self.currentKeyboardFooterData.data1Text = currentKeyboardLayout

        if GAMEPAD_KEYBINDINGS_RIGHT_PANE_FRAGMENT:IsShowing() then
            GAMEPAD_GENERIC_FOOTER:Refresh(self.currentKeyboardFooterData)
        end
    end

    KEYBINDINGS_MANAGER:RegisterCallback("OnInputLanguageChanged", UpdateCurrentKeyboardLayout)

    -- add an entry to the settings UI to show this screen
    local entryData = ZO_GamepadEntryData:New(GetString(SI_GAME_MENU_CONTROLS), "EsoUI/Art/Options/Gamepad/gp_options_controls.dds")
    entryData.sortOrder = ZO_GAMEPAD_OPTIONS_CATEGORY_SORT_ORDER[SETTING_PANEL_GAMEPLAY] + 1
    entryData:SetIconTintOnSelection(true)
    entryData.callback = function() SCENE_MANAGER:Push("keybindings_gamepad") end
    GAMEPAD_OPTIONS:RegisterCustomCategory(entryData)
end

function ZO_Keybindings_Gamepad:RefreshHeader(title)
    self.headerData =
    {
        titleText = title or GetString(SI_GAME_MENU_CONTROLS),
    }

    ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)
end

-- ZO_Gamepad_ParametricList_Screen overrides
function ZO_Keybindings_Gamepad:PerformUpdate()
    self.dirty = false
end

function ZO_Keybindings_Gamepad:InitializeKeybindStripDescriptors()
    local resetKeyboardKeybindsKeybind =
    {
        keybind = "UI_SHORTCUT_TERTIARY",
        name = GetString(SI_KEYBINDINGS_LOAD_KEYBOARD_DEFAULTS),
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        callback = function()
            ZO_Dialogs_ShowGamepadDialog("KEYBINDINGS_RESET_KEYBOARD_TO_DEFAULTS")
        end,
    }
    local resetGamepadKeybindsKeybind =
    {
        keybind = "UI_SHORTCUT_QUATERNARY",
        name = GetString(SI_KEYBINDINGS_LOAD_GAMEPAD_DEFAULTS),
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        callback = function()
            ZO_Dialogs_ShowGamepadDialog("KEYBINDINGS_RESET_GAMEPAD_TO_DEFAULTS")
        end,
    }
    self.keybindStripDescriptor =
    {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            keybind = "UI_SHORTCUT_PRIMARY",
            name = GetString(SI_GAMEPAD_SELECT_OPTION),
            callback = function()
                if self:IsCurrentList(self.categoryList) then
                    self:EnterKeybindingGridList()
                else
                    local actionLayerEntry = self.actionLayerList:GetTargetData()
                    self:ViewActionLayerCategories(actionLayerEntry:GetDataSource())
                end
            end,
            sound = SOUNDS.GAMEPAD_MENU_FORWARD,
        },
        resetKeyboardKeybindsKeybind,
        resetGamepadKeybindsKeybind,
        KEYBIND_STRIP:GenerateGamepadBackButtonDescriptor(function()
            if self:IsCurrentList(self.categoryList) then
                self:SetCurrentList(self.actionLayerList)
                self:RefreshHeader()
                SCENE_MANAGER:RemoveFragmentGroup(self.keybindsFragmentGroup)
                PlaySound(SOUNDS.GAMEPAD_MENU_BACK)
            else
                SCENE_MANAGER:HideCurrentScene()
            end
        end),
    }

    self.keybindingGridKeybindStripDescriptor =
    {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            keybind = "UI_SHORTCUT_PRIMARY",
            name = GetString(SI_GAMEPAD_SELECT_OPTION),
            callback = function()
                local selectedKeybindData = self.keybindingGridList:GetSelectedData()
                local dialogData =
                {
                    layerIndex = selectedKeybindData.layerIndex,
                    categoryIndex = selectedKeybindData.categoryIndex,
                    actionIndex = selectedKeybindData.actionIndex,
                    bindingIndex = selectedKeybindData.bindingIndex,
                    localizedActionName = selectedKeybindData.localizedActionName,
                }
                BIND_KEY_DIALOG_GAMEPAD:Show(dialogData)
            end,
            sound = SOUNDS.GAMEPAD_MENU_FORWARD,
        },
        resetKeyboardKeybindsKeybind,
        resetGamepadKeybindsKeybind,
        KEYBIND_STRIP:GenerateGamepadBackButtonDescriptor(function() self:ExitKeybindingGridList() end),
    }
end

function ZO_Keybindings_Gamepad:OnDeferredInitialize()
    self:RefreshHeader()
    self:BuildActionLayerList()
    self:InitializeKeybindingsGridList()

    -- deferred initialization of the fragment group so the background fragment exists when created
    self.keybindsFragmentGroup =
    {
        GAMEPAD_NAV_QUADRANT_2_3_4_BACKGROUND_FRAGMENT,
        GAMEPAD_KEYBINDINGS_RIGHT_PANE_FRAGMENT,
        GAMEPAD_GENERIC_FOOTER_FRAGMENT,
    }
end

function ZO_Keybindings_Gamepad:OnHide()
    if self.keybindingGridList:IsActive() then
        self.keybindingGridList:Deactivate()
        KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindingGridKeybindStripDescriptor)
    end

    ZO_Gamepad_ParametricList_Screen.OnHide(self)
end

function ZO_Keybindings_Gamepad:OnShowing()
-- Refresh the header when we start opening the menu in case we have a leftover name from a previous subcategory we've viewed
    self:RefreshHeader()

    ZO_Gamepad_ParametricList_Screen.OnShowing(self)
end
-- end ZO_Gamepad_ParametricList_Screen overrides

function ZO_Keybindings_Gamepad:BuildActionLayerList()
    self.actionLayerList:Clear()

    local keybindData = KEYBINDINGS_MANAGER:GetKeybindData()

    for i, layerData in ipairs(keybindData) do
        local entryData = ZO_GamepadEntryData:New(layerData.layerName)
        entryData:SetDataSource(layerData)
        self.actionLayerList:AddEntry("ZO_GamepadMenuEntryTemplate", entryData)
    end

    self.actionLayerList:Commit()
end

function ZO_Keybindings_Gamepad:BuildCategoryList(actionLayerData)
    self.categoryList:Clear()

    for _, categoryData in ipairs(actionLayerData.categories) do
        local entryName = categoryData.categoryName
        if entryName == "" then
            entryName = GetString(SI_KEYBINDINGS_GENERIC_CATEGORY_NAME)
        end
        local entryData = ZO_GamepadEntryData:New(entryName)
        entryData:SetDataSource(categoryData)
        self.categoryList:AddEntry("ZO_GamepadMenuEntryTemplate", entryData)
    end

    self.categoryList:CommitWithoutReselect()
end

function ZO_Keybindings_Gamepad:InitializeKeybindingsGridList()
    self.keybindingGridList = ZO_GridScrollList_Gamepad:New(self.keybindingGridListControl)

    local function SetupActionNameEntry(control, data)
        control.label:SetText(data.displayName)
    end

    local function SetupKeybindEntry(control, data)
        local ICON_SIZE_PERCENT = 150
        local keybindText = ZO_Keybindings_GetBindingStringFromAction(data.actionName, KEYBIND_TEXT_OPTIONS_FULL_NAME, KEYBIND_TEXTURE_OPTIONS_EMBED_MARKUP, data.bindingIndex, ICON_SIZE_PERCENT, ICON_SIZE_PERCENT)
        control.keybindLabel:SetText(keybindText)
    end

    local NO_HIDE_CALLBACK = nil
    local DEFAULT_RESET_ENTRY = nil
    local X_PADDING = 0
    local Y_PADDING = 0
    local DEFAULT_CENTER_ENTRIES = nil
    local NOT_SELECTABLE = false
    self.keybindingGridList:AddEntryTemplate("ZO_Keybindings_Gamepad_ActionName_GridEntry_Template_Gamepad", ZO_KEYBINDINGS_GAMEPAD_ACTION_NAME_GRID_ENTRY_WIDTH, ZO_KEYBINDINGS_GAMEPAD_GRID_ENTRY_HEIGHT, SetupActionNameEntry, NO_HIDE_CALLBACK, DEFAULT_RESET_ENTRY, X_PADDING, Y_PADDING, DEFAULT_CENTER_ENTRIES, NOT_SELECTABLE)
    self.keybindingGridList:AddEntryTemplate("ZO_Keybindings_Gamepad_Keybind_GridEntry_Template_Gamepad", ZO_KEYBINDINGS_GAMEPAD_KEYBIND_GRID_ENTRY_WIDTH, ZO_KEYBINDINGS_GAMEPAD_GRID_ENTRY_HEIGHT, SetupKeybindEntry, NO_HIDE_CALLBACK, DEFAULT_RESET_ENTRY, X_PADDING, Y_PADDING)
    self.keybindingGridList:AddEntryTemplate("ZO_Keybindings_Gamepad_Divider_GridEntry_Template_Gamepad", ZO_KEYBINDINGS_GAMEPAD_DIVIDER_GRID_ENTRY_WIDTH, ZO_KEYBINDINGS_GAMEPAD_DIVIDER_GRID_ENTRY_HEIGHT, nil, NO_HIDE_CALLBACK, DEFAULT_RESET_ENTRY, X_PADDING, Y_PADDING, DEFAULT_CENTER_ENTRIES, NOT_SELECTABLE)
end


function ZO_Keybindings_Gamepad:ViewActionLayerCategories(actionLayerData)
    self:BuildCategoryList(actionLayerData)
    self:SetCurrentList(self.categoryList)
    self:RefreshHeader(actionLayerData.layerName)

    SCENE_MANAGER:AddFragmentGroup(self.keybindsFragmentGroup)
    GAMEPAD_GENERIC_FOOTER:Refresh(self.currentKeyboardFooterData)
end

function ZO_Keybindings_Gamepad:UpdateKeybindingGridList()
    self.keybindingGridList:ClearGridList()

    local categoryData = self.categoryList:GetTargetData()
    local actions = categoryData.actions

    for actionLoopIndex, action in ipairs(actions) do
        if actionLoopIndex ~= 1 then
            self.keybindingGridList:AddEntry({}, "ZO_Keybindings_Gamepad_Divider_GridEntry_Template_Gamepad")
        end

        self.keybindingGridList:AddEntry({ displayName = action.localizedActionName }, "ZO_Keybindings_Gamepad_ActionName_GridEntry_Template_Gamepad")

        local actionName = action.actionName
        for bindingIndex = 1, GetMaxBindingsPerAction() do
            local keybindData =
            {
                actionName = actionName,
                localizedActionName = action.localizedActionName,
                layerIndex = action.layerIndex,
                categoryIndex = action.categoryIndex,
                actionIndex = action.actionIndex,
                bindingIndex = bindingIndex,
            }

            self.keybindingGridList:AddEntry(keybindData, "ZO_Keybindings_Gamepad_Keybind_GridEntry_Template_Gamepad")
        end
    end

    self.keybindingGridList:CommitGridList()
end

function ZO_Keybindings_Gamepad:EnterKeybindingGridList()
    self:DeactivateCurrentList()
    self.keybindingGridList:Activate()
    KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
    KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindingGridKeybindStripDescriptor)
end

function ZO_Keybindings_Gamepad:ExitKeybindingGridList()
    self.keybindingGridList:Deactivate()
    self:ActivateCurrentList()
    KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindingGridKeybindStripDescriptor)
    KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
end

----
-- Keybinding Dialog
----

ZO_BindKeyDialog_Gamepad = ZO_InitializingObject:Subclass()

function ZO_BindKeyDialog_Gamepad:Initialize(control)
    self.control = control
    ZO_CustomCenteredGamepadDialogTemplate_OnInitialized(control)

    self.instructionsLabel = control:GetNamedChild("Instructions")
    local bindContainer = control:GetNamedChild("BindContainer")
    self.bindBackgroundControl = bindContainer:GetNamedChild("Background")
    self.inputBoxControl = bindContainer:GetNamedChild("InputBox")
    self.currentBindLabel = bindContainer:GetNamedChild("CurrentBind")
    self.overwriteWarning1Label = control:GetNamedChild("OverwriteWarning1")
    self.overwriteWarning2Label = control:GetNamedChild("OverwriteWarning2")

    local keybindsContainer = control:GetNamedChild("Keybinds")
    self.primaryKeybindButton = keybindsContainer:GetNamedChild("PrimaryKeybind")
    self.secondaryKeybindButton = keybindsContainer:GetNamedChild("SecondaryKeybind")
    self.tertiaryKeybindButton = keybindsContainer:GetNamedChild("TertiaryKeybind")
    self.backKeybindButton = keybindsContainer:GetNamedChild("BackKeybind")

    -- Create the keybind descriptors for the dialog
    -- The descriptors are shared between the normal dialog keybinds shown on the keybind strip
    -- and the custom keybind buttons that are displayed in the dialog control
    -- To avoid showing duplicate keybinds all descriptors are ethereal to hide them on
    -- the keybind strip.
    -- Since the custom keybind buttons will still show, they need 'name' set (as opposed to 'text')
    self.primaryKeybindDescriptor =
    {
        keybind = "DIALOG_PRIMARY",
        ethereal = true,
        name = GetString(SI_KEYBINDINGS_CHOOSE_BIND_BUTTON),
        enabled = function()
            return not self:IsBindBoxActive()
        end,
        callback = function()
            self:SetBindBoxEnabled(true)
        end,
    }

    self.primaryKeybindButton:SetKeybindButtonDescriptor(self.primaryKeybindDescriptor)

    self.secondaryKeybindDescriptor =
    {
        keybind = "DIALOG_SECONDARY",
        ethereal = true,
        name = GetString(SI_KEYBINDINGS_BIND_BUTTON),
        enabled = function()
            return self.canBeBound and not self:IsBindBoxActive()
        end,
        callback = function()
            BindKeyToAction(self.layerIndex, self.categoryIndex, self.actionIndex, self.bindingIndex, self:GetCurrentKeys())
            ZO_Dialogs_ReleaseDialogOnButtonPress("GAMEPAD_BIND_KEY")
        end,
    }

    self.secondaryKeybindButton:SetKeybindButtonDescriptor(self.secondaryKeybindDescriptor)

    self.tertiaryKeybindDescriptor =
    {
        keybind = "DIALOG_TERTIARY",
        ethereal = true,
        name = GetString(SI_KEYBINDINGS_UNBIND_BUTTON),
        enabled = function()
            return self.canBeUnbound and not self:IsBindBoxActive()
        end,
        callback = function()
            UnbindKeyFromAction(self.layerIndex, self.categoryIndex, self.actionIndex, self.bindingIndex)
            ZO_Dialogs_ReleaseDialogOnButtonPress("GAMEPAD_BIND_KEY")
        end,
    }

    self.tertiaryKeybindButton:SetKeybindButtonDescriptor(self.tertiaryKeybindDescriptor)

    self.backKeybindDescriptor =
    {
        keybind = "DIALOG_NEGATIVE",
        ethereal = true,
        name = GetString(SI_DIALOG_CANCEL),
        enabled = function()
            return not self:IsBindBoxActive()
        end,
        callback = function(dialog)
            ZO_Dialogs_ReleaseDialogOnButtonPress("GAMEPAD_BIND_KEY")
        end,
    }

    self.backKeybindButton:SetKeybindButtonDescriptor(self.backKeybindDescriptor)


    ZO_Dialogs_RegisterCustomDialog("GAMEPAD_BIND_KEY",
    {
        customControl = control,
        title =
        {
            text = SI_KEYBINDINGS_BINDINGS,
        },
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.CUSTOM,
        },
        canQueue = true,
        blockDialogReleaseOnPress = true,
        setup = function(...) self:SetupDialog(...) end,
        finishedCallback = function() self:OnDialogFinished() end,

        buttons =
        {
            self.primaryKeybindDescriptor,
            self.secondaryKeybindDescriptor,
            self.tertiaryKeybindDescriptor,
            self.backKeybindDescriptor,
        }
    })
end

function ZO_BindKeyDialog_Gamepad:SetupDialog(dialog, data)
    self.layerIndex = data.layerIndex
    self.categoryIndex = data.categoryIndex
    self.actionIndex = data.actionIndex
    self.bindingIndex = data.bindingIndex

    local pressToBindKeybindText = ZO_Keybindings_GetBindingStringFromAction("DIALOG_PRIMARY", KEYBIND_TEXT_OPTIONS_FULL_NAME, KEYBIND_TEXTURE_OPTIONS_EMBED_MARKUP)
    local bindingSlotText = KEYBINDINGS_MANAGER:GetBindTypeTextFromIndex(self.bindingIndex)
    self.instructionsLabel:SetText(zo_strformat(SI_KEYBINDINGS_PRESS_A_KEY_OR_CLICK_GAMEPAD, ZO_SELECTED_TEXT:Colorize(pressToBindKeybindText), ZO_SELECTED_TEXT:Colorize(bindingSlotText), ZO_SELECTED_TEXT:Colorize(data.localizedActionName)))

    local key, mod1, mod2, mod3, mod4 = GetActionBindingInfo(self.layerIndex, self.categoryIndex, self.actionIndex, self.bindingIndex)

    local ctrl = ZO_Keybindings_DoesKeyMatchAnyModifiers(KEY_CTRL, mod1, mod2, mod3, mod4)
    local alt = ZO_Keybindings_DoesKeyMatchAnyModifiers(KEY_ALT, mod1, mod2, mod3, mod4)
    local shift = ZO_Keybindings_DoesKeyMatchAnyModifiers(KEY_SHIFT, mod1, mod2, mod3, mod4)
    local command = ZO_Keybindings_DoesKeyMatchAnyModifiers(KEY_COMMAND, mod1, mod2, mod3, mod4)
    
    self.allowChording = ctrl or alt or shift or command

    self:SetCurrentKeys(key, ctrl, alt, shift, command)

    self:SetBindBoxEnabled(false)

    self.numMouseButtonsDown = 0
    self.numKeysDown = 0

    self.canBeUnbound = self:HasValidKeyToBind()
    BlockAutomaticInputModeChange(true)
    self:RefreshKeybinds()
end

function ZO_BindKeyDialog_Gamepad:OnDialogFinished()
    BlockAutomaticInputModeChange(false)
    self:SetBindBoxEnabled(false)
end

function ZO_BindKeyDialog_Gamepad:OnMouseDown(button, ctrl, alt, shift, command)
    local mouseButtonAsKeyCode = ConvertMouseButtonToKeyCode(button)

    self.numMouseButtonsDown = self.numMouseButtonsDown + 1

    if mouseButtonAsKeyCode == KEY_MOUSE_LEFTRIGHT then
        self.forcedLmbRmb = true
        self:SetCurrentKeys(KEY_MOUSE_LEFTRIGHT, ctrl, alt, shift, command)
    elseif not self.forcedLmbRmb then
        self:SetCurrentKeys(mouseButtonAsKeyCode, ctrl, alt, shift, command)
    end
end

function ZO_BindKeyDialog_Gamepad:OnMouseUp(button, ctrl, alt, shift, command)
    local mouseButtonAsKeyCode = ConvertMouseButtonToKeyCode(button)
    self.numMouseButtonsDown = self.numMouseButtonsDown - 1

    if self.numMouseButtonsDown == 0 and mouseButtonAsKeyCode ~= KEY_MOUSE_LEFTRIGHT then
        self.forcedLmbRmb = false
        self:SetBindBoxEnabled(false)
    end
end

function ZO_BindKeyDialog_Gamepad:OnMouseWheel(delta, ctrl, alt, shift, command)
    local mouseWheelAsKey = delta < 0 and KEY_MOUSEWHEEL_DOWN or KEY_MOUSEWHEEL_UP
    self:SetCurrentKeys(mouseWheelAsKey, ctrl, alt, shift, command)
    self:SetBindBoxEnabled(false)
end

function ZO_BindKeyDialog_Gamepad:OnKeyDown(key, ctrl, alt, shift, command)
    if KEYBINDINGS_MANAGER:IsBindableKey(key) then
        self.numKeysDown = self.numKeysDown + 1

        if IsKeyCodeChordKey(key) then
            self.forcedComboKey = key
            self:SetCurrentKeys(key, ctrl, alt, shift, command)
        elseif not self.forcedComboKey then
            self:SetCurrentKeys(key, ctrl, alt, shift, command)
        end
    end
end

function ZO_BindKeyDialog_Gamepad:OnKeyUp(key, ctrl, alt, shift, command)
    if KEYBINDINGS_MANAGER:IsBindableKey(key) then
        self.numKeysDown = self.numKeysDown - 1

        if self.numKeysDown == 0 and self.forcedComboKey ~= key then
            self.forcedComboKey = nil
            self:SetBindBoxEnabled(false)
        end
    end
end

local function SetModifier(key, modifier, isSet)
    if isSet then
        if key == modifier then
            return KEY_INVALID
        end
        return modifier
    end
    return KEY_INVALID
end

function ZO_BindKeyDialog_Gamepad:SetCurrentKeys(key, ctrl, alt, shift, command)
    self.currentKey = key

    if self.allowChording then
        self.currentCtrl = SetModifier(key, KEY_CTRL, ctrl)
        self.currentAlt = SetModifier(key, KEY_ALT, alt)
        self.currentShift = SetModifier(key, KEY_SHIFT, shift)
        self.currentCommand = SetModifier(key, KEY_COMMAND, command)
    else
        self.currentCtrl = KEY_INVALID
        self.currentAlt = KEY_INVALID
        self.currentShift = KEY_INVALID
        self.currentCommand = KEY_INVALID
    end

    self:UpdateCurrentKeyLabel()
end

function ZO_BindKeyDialog_Gamepad:ClearCurrentKeys()
    self:SetCurrentKeys(KEY_INVALID, KEY_INVALID, KEY_INVALID, KEY_INVALID, KEY_INVALID)
end

function ZO_BindKeyDialog_Gamepad:GetCurrentKeys()
    return self.currentKey, self.currentCtrl, self.currentAlt, self.currentShift, self.currentCommand
end

function ZO_BindKeyDialog_Gamepad:HasValidKeyToBind()
    return self.currentKey ~= KEY_INVALID
end

function ZO_BindKeyDialog_Gamepad:UpdateCurrentKeyLabel()
    self.canBeBound = true

    -- clear the text so the dialog resizes appropriately
    self.overwriteWarning1Label:SetText("")
    self.overwriteWarning2Label:SetText("")

    if self:HasValidKeyToBind() then
        self.currentBindLabel:SetHidden(false)
        local key, mod1, mod2, mod3, mod4 = self:GetCurrentKeys()
        local bindingString = ZO_Keybindings_GetBindingStringFromKeys(key, mod1, mod2, mod3, mod4, KEYBIND_TEXT_OPTIONS_FULL_NAME, KEYBIND_TEXTURE_OPTIONS_EMBED_MARKUP)
        if ZO_Keybindings_ShouldUseIconKeyMarkup(key) then
            self.currentBindLabel:SetFont("ZoFontGamepadCondensed36")
        else
            self.currentBindLabel:SetFont("ZoFontGamepadCondensed42")
        end
        self.currentBindLabel:SetText(bindingString)

        local categoryIndex, actionIndex, bindingIndex = GetBindingIndicesFromKeys(self.layerIndex, key, mod1, mod2, mod3, mod4)
        -- only checking categoryIndex since all the indices are set if there's a valid binding, otherwise they are all nil
        if categoryIndex and (self.categoryIndex ~= categoryIndex or self.actionIndex ~= actionIndex) then
            self.overwriteWarning1Label:SetHidden(false)

            local actionName, isRebindable, isHidden = GetActionInfo(self.layerIndex, categoryIndex, actionIndex)
            local localizedActionName = GetString(_G["SI_BINDING_NAME_"..actionName])

            if isRebindable then
                local bindingSlotText = KEYBINDINGS_MANAGER:GetBindTypeTextFromIndex(bindingIndex)
                self.overwriteWarning1Label:SetText(zo_strformat(SI_KEYBINDINGS_ALREADY_BOUND, ZO_SELECTED_TEXT:Colorize(bindingSlotText), ZO_SELECTED_TEXT:Colorize(localizedActionName)))
                self.overwriteWarning2Label:SetText(zo_strformat(SI_KEYBINDINGS_WOULD_UNBIND, ZO_SELECTED_TEXT:Colorize(localizedActionName)))
                self.overwriteWarning2Label:SetHidden(false)
            else
                self.overwriteWarning1Label:SetText(zo_strformat(SI_KEYBINDINGS_CANNOT_BIND_TO, ZO_SELECTED_TEXT:Colorize(localizedActionName)))
                self.overwriteWarning2Label:SetHidden(true)
                self.canBeBound = false
            end
        else
            self.overwriteWarning1Label:SetHidden(true)
            self.overwriteWarning2Label:SetHidden(true)
        end
    else
        self.currentBindLabel:SetHidden(true)
        self.overwriteWarning1Label:SetHidden(true)
        self.overwriteWarning2Label:SetHidden(true)
        self.canBeBound = false
    end
end

function ZO_BindKeyDialog_Gamepad:SetBindBoxEnabled(enabled)
    self.bindBoxEnabled = enabled
    self.inputBoxControl:SetHidden(not enabled)
    local alpha = enabled and 0.25 or 0.10
    self.bindBackgroundControl:SetAlpha(alpha)
    self:RefreshKeybinds()
end

function ZO_BindKeyDialog_Gamepad:RefreshKeybinds()
    ZO_GenericGamepadDialog_RefreshKeybinds(self.control)

    self.primaryKeybindButton:SetEnabled(self.primaryKeybindDescriptor.enabled())
    self.secondaryKeybindButton:SetEnabled(self.secondaryKeybindDescriptor.enabled())
    self.tertiaryKeybindButton:SetEnabled(self.tertiaryKeybindDescriptor.enabled())
    self.backKeybindButton:SetEnabled(self.backKeybindDescriptor.enabled())
end

function ZO_BindKeyDialog_Gamepad:IsBindBoxActive()
    return self.bindBoxEnabled
end

function ZO_BindKeyDialog_Gamepad:Show(dialogData)
    ZO_Dialogs_ShowGamepadDialog("GAMEPAD_BIND_KEY", dialogData)
end

----
-- Global XML functions
----

function ZO_Keybindings_Gamepad_OnInitialize(control)
    if ZO_IsPCUI() then
        KEYBINDINGS_GAMEPAD = ZO_Keybindings_Gamepad:New(control)
    end
end

function ZO_BindKeyDialog_Gamepad_OnInitialize(control)
    if ZO_IsPCUI() then
        BIND_KEY_DIALOG_GAMEPAD = ZO_BindKeyDialog_Gamepad:New(control)
    end
end

function ZO_BindKeyDialog_Gamepad_OnMouseDown(button, ctrl, alt, shift, command)
    if ZO_IsPCUI() then
        BIND_KEY_DIALOG_GAMEPAD:OnMouseDown(button, ctrl, alt, shift, command)
    end
end

function ZO_BindKeyDialog_Gamepad_OnMouseUp(button, ctrl, alt, shift, command)
    if ZO_IsPCUI() then
        BIND_KEY_DIALOG_GAMEPAD:OnMouseUp(button, ctrl, alt, shift, command)
    end
end

function ZO_BindKeyDialog_Gamepad_OnMouseWheel(delta, ctrl, alt, shift, command)
    if ZO_IsPCUI() then
        BIND_KEY_DIALOG_GAMEPAD:OnMouseWheel(delta, ctrl, alt, shift, command)
    end
end

function ZO_BindKeyDialog_Gamepad_OnKeyDown(key, ctrl, alt, shift, command)
    if ZO_IsPCUI() then
        BIND_KEY_DIALOG_GAMEPAD:OnKeyDown(key, ctrl, alt, shift, command)
    end
end

function ZO_BindKeyDialog_Gamepad_OnKeyUp(key, ctrl, alt, shift, command)
    if ZO_IsPCUI() then
        BIND_KEY_DIALOG_GAMEPAD:OnKeyUp(key, ctrl, alt, shift, command)
    end
end
