ZO_CHAT_MENU_GAMEPAD_LOG_MAX_SIZE = 200
ZO_CHAT_MENU_GAMEPAD_COLOR_MODIFIER = 0.7
ZO_CHAT_MENU_GAMEPAD_DESATURATION_MODIFIER = 0.1

------------------
--Initialization--
------------------

ZO_ChatMenu_Gamepad = ZO_InteractiveChatLog_Gamepad:Subclass()

function ZO_ChatMenu_Gamepad:Initialize(control)
    CHAT_MENU_GAMEPAD_SCENE = ZO_Scene:New("gamepadChatMenu", SCENE_MANAGER)

    ZO_InteractiveChatLog_Gamepad.Initialize(self, control, CHAT_MENU_GAMEPAD_SCENE)

    self.currentLinkIndex = 1

    self:InitializeRefreshGroup()
end

-- ZO_InteractiveChatLog_Gamepad Overrides

function ZO_ChatMenu_Gamepad:InitializeHeader()
    self.headerData =
    {
        titleText = GetString(SI_GAMEPAD_TEXT_CHAT),
    }
    ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)
end

function ZO_ChatMenu_Gamepad:InitializeTextInputSection()
    --For active focus switching between channel and edit box
    self.textInputFocusSwitcher = ZO_GamepadFocus:New(self.textInputControl, nil, MOVEMENT_CONTROLLER_DIRECTION_HORIZONTAL)

    self:InitializeChannelDropdown()

    ZO_InteractiveChatLog_Gamepad.InitializeTextInputSection(self)
end

function ZO_ChatMenu_Gamepad:InitializeTextEdit()
    ZO_InteractiveChatLog_Gamepad.InitializeTextEdit(self)

    local textEditData =
    {
        callback = function()
            if not self.textEdit:HasFocus() then
                self.textEdit:TakeFocus()
            end
        end,
        highlight = self.textControlHighlight,
        control = self.textEdit,
    }
    self.textInputFocusSwitcher:AddEntry(textEditData)
end

function ZO_ChatMenu_Gamepad:RegisterForEvents()
    ZO_InteractiveChatLog_Gamepad.RegisterForEvents(self)

    local function AddMessage(...)
        self:AddMessage(...)
    end

    local function DirtyChannelDropdown()
        self:DirtyChannelDropdown()
    end

    local function DirtyActiveChannel()
        self:DirtyActiveChannel()
    end

    local function OnGroupMemberJoined(eventCode, playerName)
        if playerName == GetRawUnitName("player") then
            self:DirtyChannelDropdown()
        end
    end

    local function OnGroupMemberLeft(eventCode, characterName, reason, isLocalPlayer)
        if isLocalPlayer then
            self:DirtyChannelDropdown()
        end
    end

    local function OnGuildMemberRankChanged(eventCode, guildId, displayName)
        if displayName == GetDisplayName() then
            self:DirtyChannelDropdown()
        end
    end

    CHAT_ROUTER:RegisterCallback("FormattedChatMessage", AddMessage)
    CALLBACK_MANAGER:RegisterCallback("OnChatChannelUpdated", DirtyActiveChannel)
    self.control:RegisterForEvent(EVENT_GROUP_MEMBER_JOINED, OnGroupMemberJoined)
    self.control:RegisterForEvent(EVENT_GROUP_MEMBER_LEFT, OnGroupMemberLeft)
    self.control:RegisterForEvent(EVENT_GUILD_SELF_JOINED_GUILD, DirtyChannelDropdown)
    self.control:RegisterForEvent(EVENT_GUILD_SELF_LEFT_GUILD, DirtyChannelDropdown)
    self.control:RegisterForEvent(EVENT_GUILD_MEMBER_RANK_CHANGED, OnGuildMemberRankChanged)
    self.control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, DirtyChannelDropdown)
    self.control:RegisterForEvent(EVENT_CHAT_CATEGORY_COLOR_CHANGED, DirtyChannelDropdown)
end

function ZO_ChatMenu_Gamepad:InitializeFocusKeybinds()
    local function LinkShouldersEnabled()
        local targetData = self.list:GetTargetData()
        if targetData then
            local links = targetData.data.links
            if links then
                return #links > 1
            end
        end
        return false
    end

    self.chatEntryListKeybindDescriptor =
    {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,

        -- Back to text input
        {
            name = GetString(SI_GAMEPAD_BACK_OPTION),

            keybind = "UI_SHORTCUT_NEGATIVE",

            callback = function()
                self:FocusTextInput()
            end,

            sound = SOUNDS.GAMEPAD_MENU_BACK,
        },

        -- Open Link (super special keybind)
        {
            name = function()
                local targetData = self.list:GetTargetData()
                local currentLink = targetData.data.links[self.currentLinkIndex]
                if currentLink.linkType == GUILD_LINK_TYPE then
                    return GetString(SI_GAMEPAD_GUILD_LINK_KEYBIND)
                elseif currentLink.linkType == HELP_LINK_TYPE then
                    return GetString(SI_GAMEPAD_OPEN_HELP_LINK_KEYBIND)
                end
            end,

            keybind = "UI_SHORTCUT_SECONDARY",

            alignment = KEYBIND_STRIP_ALIGN_RIGHT,

            callback = function()
                local targetData = self.list:GetTargetData()
                local currentLink = targetData.data.links[self.currentLinkIndex]
                if currentLink.linkType == GUILD_LINK_TYPE then
                    local text, color, linkType, guildId = ZO_LinkHandler_ParseLink(currentLink.link)
                    GUILD_BROWSER_GUILD_INFO_GAMEPAD:ShowWithGuild(guildId)
                elseif currentLink.linkType == HELP_LINK_TYPE then
                    local helpCategoryIndex, helpIndex = GetHelpIndicesFromHelpLink(currentLink.link)
                    if helpCategoryIndex and helpIndex then
                        HELP_TUTORIALS_ENTRIES_GAMEPAD:Push(helpCategoryIndex, helpIndex)
                    end
                end
            end,

            visible = function()
                local targetData = self.list:GetTargetData()
                if targetData.data.links then
                    local currentLink = targetData.data.links[self.currentLinkIndex]
                    if currentLink then
                        return currentLink.linkType == GUILD_LINK_TYPE or currentLink.linkType == HELP_LINK_TYPE
                    end
                end
                return false
            end
        },

        -- cycle tooltip
        {
            alignment = KEYBIND_STRIP_ALIGN_RIGHT,

            name = GetString(SI_GAMEPAD_CHAT_MENU_CYCLE_TOOLTIP_BINDING),

            keybind = "UI_SHORTCUT_INPUT_RIGHT",

            callback = function()
                self.currentLinkIndex = self.currentLinkIndex + 1
                local targetData = self.list:GetTargetData()
                if self.currentLinkIndex > #targetData.data.links then
                    self.currentLinkIndex = 1
                end
                self:RefreshTooltip(targetData)
                KEYBIND_STRIP:UpdateKeybindButtonGroup(self.chatEntryListKeybindDescriptor)
            end,

            visible = LinkShouldersEnabled,
        },

        {
            --Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
            name = "Gamepad Chat Previous Link",

            ethereal = true,

            keybind = "UI_SHORTCUT_INPUT_LEFT",

            callback = function()
                self.currentLinkIndex = self.currentLinkIndex - 1
                local targetData = self.list:GetTargetData()
                if self.currentLinkIndex == 0 then
                    self.currentLinkIndex = #targetData.data.links
                end
                self:RefreshTooltip(targetData)
            end,

            enabled = LinkShouldersEnabled,
        }
    }
    ZO_Gamepad_AddListTriggerKeybindDescriptors(self.chatEntryListKeybindDescriptor, self.list)

    local function AreOptionsAvailable()
        local targetData = self.list:GetTargetData()
        if targetData then
            local data = targetData.data
            if data then
                if data.fromDisplayName and data.fromDisplayName ~= "" and self:HasAnyShownOptions() then
                    return true
                end
            end
        end
        return false
    end
    local DEFAULT_CALLBACK, DEFAULT_KEYBIND, DEFAULT_NAME, DEFAULT_SOUND
    self:AddSocialOptionsKeybind(self.chatEntryListKeybindDescriptor, DEFAULT_CALLBACK, DEFAULT_KEYBIND, DEFAULT_NAME, DEFAULT_SOUND, AreOptionsAvailable)
    self.chatEntryPanelFocalArea:SetKeybindDescriptor(self.chatEntryListKeybindDescriptor)

    self.textInputAreaKeybindDescriptor =
    {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,

        {
            name = GetString(SI_GAMEPAD_SELECT_OPTION),

            keybind = "UI_SHORTCUT_PRIMARY",

            callback = function()
                local data = self.textInputFocusSwitcher:GetFocusItem()
                data.callback()
            end,
        },

        {
            name = GetString(SI_GAMEPAD_CHAT_MENU_SEND_KEYBIND),

            keybind = "UI_SHORTCUT_SECONDARY",

            callback = function()
                local CURRENT_CHANNEL, CURRENT_TARGET
                local DONT_SHOW_HUD_WINDOW = true
                AutoSendChatInput(self.textEdit:GetText(), CURRENT_CHANNEL, CURRENT_TARGET, DONT_SHOW_HUD_WINDOW)
                self.textEdit:Clear()
            end,

            enabled = function()
                local text = self.textEdit:GetText()
                return text and text ~= ""
            end,
        }
    }
    ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.textInputAreaKeybindDescriptor, GAME_NAVIGATION_TYPE_BUTTON)
    self.textInputAreaFocalArea:SetKeybindDescriptor(self.textInputAreaKeybindDescriptor)
end

function ZO_ChatMenu_Gamepad:OnShow()
    self.channelRefreshGroup:TryClean()
    self.list:RefreshVisible()
    if not self.isFocusSetFromLink then
        self:FocusTextInput()
    else
        local OLD_TARGET_DATA = nil
        local REACHED_TARGET = nil
        local targetData = self.list:GetTargetData()
        local targetSelectedIndex = self.list:GetSelectedIndex()
        self:OnTargetChanged(self.list, targetData, OLD_TARGET_DATA, REACHED_TARGET, targetSelectedIndex)
    end
    self.isFocusSetFromLink = nil
end

function ZO_ChatMenu_Gamepad:FocusTextInput()
    ZO_InteractiveChatLog_Gamepad.FocusTextInput(self)

    if self.scene:IsShowing() then
        self.textInputFocusSwitcher:SetFocusToMatchingEntry(self.textEdit)
    end
end

function ZO_ChatMenu_Gamepad:SetupLogMessage(control, data, selected, reselectingDuringRebuild, enabled, active)
    ZO_SharedGamepadEntry_OnSetup(control, data, selected, reselectingDuringRebuild, enabled, active)
    local entryData = data.data
    local r, g, b = GetChatCategoryColor(entryData.category)
    local useSelectedColor = selected and self.chatEntryPanelFocalArea:IsFocused()
    local colorSelectedModifier = useSelectedColor and 1 or ZO_CHAT_MENU_GAMEPAD_COLOR_MODIFIER
    control.label:SetColor(r * colorSelectedModifier, g * colorSelectedModifier, b * colorSelectedModifier, 1)
    control.label:SetDesaturation(useSelectedColor and 0 or ZO_CHAT_MENU_GAMEPAD_DESATURATION_MODIFIER)
end

function ZO_ChatMenu_Gamepad:AddMessage(message, category, targetChannel, fromDisplayName, rawMessageText)
    if message ~= nil then
        local targetIndex = self.list:GetTargetIndex()
        local selectingMostRecent = targetIndex == #self.messageEntries

        local links
        --Only chat channel messages will have raw text, because they're the only ones that could have links in them
        if rawMessageText then
            links = {}
            ZO_ExtractLinksFromText(rawMessageText, ZO_VALID_LINK_TYPES_CHAT, links)
            links = #links > 0 and links or nil
        end

        local messageEntry = ZO_GamepadEntryData:New(message)
        messageEntry:SetFontScaleOnSelection(false)
        messageEntry.data =
        {
            id = self.nextMessageId,
            fromDisplayName = fromDisplayName,
            category = category,
            targetChannel = targetChannel,
            rawMessageText = rawMessageText,
            links = links,
        }

        self.nextMessageId = self.nextMessageId + 1
        table.insert(self.messageEntries, messageEntry)

        if #self.messageEntries > ZO_CHAT_MENU_GAMEPAD_LOG_MAX_SIZE then
            table.remove(self.messageEntries, 1)
            self:BuildChatList()
        else
            self.list:AddEntry("ZO_InteractiveChatLog_Gamepad_LogLine", messageEntry)
            self.list:Commit()
        end

        if selectingMostRecent then
            self.list:SetSelectedIndex(#self.messageEntries)
        end
    end
end

function ZO_ChatMenu_Gamepad:OnTargetChanged(list, targetData, ...)
    self.currentLinkIndex = 1

    ZO_InteractiveChatLog_Gamepad.OnTargetChanged(self, list, targetData, ...)

    if self.chatEntryPanelFocalArea:IsFocused() then
        self:RefreshTooltip(targetData)
    end
end

function ZO_ChatMenu_Gamepad:SetupOptions(entryData)
    local data = entryData.data

    local socialData =
    {
        displayName = data.fromDisplayName,
        category = data.category,
        targetChannel = data.targetChannel,
    }

    ZO_InteractiveChatLog_Gamepad.SetupOptions(self, socialData)
end

function ZO_ChatMenu_Gamepad:BuildOptionsList()
    local groupId = self:AddOptionTemplateGroup(ZO_SocialOptionsDialogGamepad.GetDefaultHeader)

    self:AddOptionTemplate(groupId, ZO_SocialOptionsDialogGamepad.BuildGamerCardOption, IsConsoleUI)
    self:AddOptionTemplate(groupId, ZO_SocialOptionsDialogGamepad.BuildInviteToGroupOption, ZO_SocialOptionsDialogGamepad.ShouldAddInviteToGroupOption)
    self:AddOptionTemplate(groupId, ZO_SocialOptionsDialogGamepad.BuildWhisperOption)
    self:AddOptionTemplate(groupId, ZO_SocialOptionsDialogGamepad.BuildAddFriendOption, ZO_SocialOptionsDialogGamepad.ShouldAddFriendOption)
    self:AddOptionTemplate(groupId, ZO_SocialOptionsDialogGamepad.BuildSendMailOption, ZO_SocialOptionsDialogGamepad.ShouldAddSendMailOption)
    self:AddOptionTemplate(groupId, ZO_SocialOptionsDialogGamepad.BuildIgnoreOption, ZO_SocialOptionsDialogGamepad.SelectedDataIsNotPlayer)
end

function ZO_ChatMenu_Gamepad:OnScreenResized()
    ZO_InteractiveChatLog_Gamepad.OnScreenResized(self)

    self:DirtyChannelDropdown()
end

function ZO_ChatMenu_Gamepad:OnTextInputAreaActivated()
    self.textInputFocusSwitcher:Activate()

    ZO_InteractiveChatLog_Gamepad.OnTextInputAreaActivated(self)
end

function ZO_ChatMenu_Gamepad:OnTextInputAreaDeactivated()
    self.textInputFocusSwitcher:Deactivate()

    ZO_InteractiveChatLog_Gamepad.OnTextInputAreaDeactivated(self)
end

function ZO_ChatMenu_Gamepad:OnChatEntryPanelActivated()
    ZO_InteractiveChatLog_Gamepad.OnChatEntryPanelActivated(self)

    self.currentLinkIndex = 1
    self:RefreshTooltip()
end

function ZO_ChatMenu_Gamepad:OnChatEntryPanelDeactivated()
    ZO_InteractiveChatLog_Gamepad.OnChatEntryPanelDeactivated(self)

    GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP)
end

-- End ZO_InteractiveChatLog_Gamepad Overrides

function ZO_ChatMenu_Gamepad:InitializeChannelDropdown()
    local channelControl = self.textInputControl:GetNamedChild("Channel")
    local channelDropdownControl = channelControl:GetNamedChild("Dropdown")
    local channelDropdown = ZO_ComboBox_ObjectFromContainer(channelDropdownControl)
    channelDropdown:SetSelectedColor(ZO_DISABLED_TEXT)
    channelDropdown:SetSortsItems(false)
    channelDropdown:SetDontSetSelectedTextOnSelection(true)
    self.selectedChannelLabel = channelDropdownControl:GetNamedChild("SelectedItemText")
    self.selectedChannelFakeLabel = channelDropdownControl:GetNamedChild("SelectedItemFakeTextForResizing")

    -- Prepare switches for sorting
    -- These switches are the slash commands used to set the channel (e.g.:/zone)
    -- The channelData holds a table of all the channels and their information,
    -- and the switch lookup provides the mapping of the channel id to the default (e.g.: /zone vs /z) switch needed to go there
    local channelData = ZO_ChatSystem_GetChannelInfo()
    local switchLookup = ZO_ChatSystem_GetChannelSwitchLookupTable()
    local switches = {}
    for channel in pairs(channelData) do
        local switch = switchLookup[channel]
        --Not every channel in the channel data is going to map to a switch
        if switch then
            switches[#switches + 1] = switch
        end
    end

    table.sort(switches)

    local channelFocusData =
    {
        keybindText = GetString(SI_GAMEPAD_SELECT_OPTION),
        callback = function()
            channelDropdown:Activate()
        end,
        highlight = channelControl:GetNamedChild("Highlight"),
        control = channelDropdown,
    }
    self.textInputFocusSwitcher:AddEntry(channelFocusData)

    self.channelDropdown = channelDropdown
    self.channelControl = channelControl
    self.sortedChannelSwitches = switches

    local DONT_RESELECT = false
    self:RefreshChannelDropdown(DONT_RESELECT)
end

function ZO_ChatMenu_Gamepad:RefreshChannelDropdown(reselectDuringRebuild)
    local function OnChannelSelected(_, _, entry, _)
        local data = entry.data
        --Target means we don't yet have enough info to properly change channels
        if data and not data.target then
            GAMEPAD_CHAT_SYSTEM:SetChannel(data.id)
        end
    end

    local switchLookup = ZO_ChatSystem_GetChannelSwitchLookupTable()
    local channelDropdown = self.channelDropdown
    channelDropdown.minimumWidth = 0
    channelDropdown:ClearItems()

    --Add sorted switches
    for i, switch in ipairs(self.sortedChannelSwitches) do
        --The switchLookup also includes a backward lookup to use any switch (not just defaults) to find the associated channel data
        local channelData = switchLookup[switch]
        -- exclude channels that require an explicit target (ie. /tell) and channels that we don't currently meet the requirements for
        if channelData and not channelData.target and (not channelData.requires or channelData.requires(channelData.id)) then
            local r, g, b = ZO_ChatSystem_GetCategoryColorFromChannel(channelData.id)
            local itemColor = ZO_ColorDef:New(r, g, b)
            local coloredSwitchText = itemColor:Colorize(switch)
            local entry = ZO_ComboBox:CreateItemEntry(coloredSwitchText, OnChannelSelected)
            entry.data = channelData
            channelDropdown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
            local stringWidth = (self.selectedChannelFakeLabel:GetStringWidth(zo_strupper(switch)) / GetUIGlobalScale()) + 10 -- 10px of margin to avoid word wrapping
            channelDropdown.minimumWidth = zo_max(stringWidth, channelDropdown.minimumWidth)
        end
    end

    if reselectDuringRebuild then
        self:OnChatChannelChanged()
    end
end

do
    local function IsEntryForCurrentChannel(entry)
        local channelData = GAMEPAD_CHAT_SYSTEM:GetCurrentChannelData()
        return entry.data == channelData
    end

    function ZO_ChatMenu_Gamepad:OnChatChannelChanged()
        --Set the dropdown selection to the appropriate channel
        self.channelDropdown:SetSelectedItemByEval(IsEntryForCurrentChannel, true)

        --Set the selected item text for the dropdown to the appropriate text
        local channelData, channelTarget = CHAT_ROUTER:GetCurrentChannelData()
        local channelText
        if channelTarget then
            --Console can only have display names.  This won't do anything to character names on PC
            channelTarget = ZO_FormatUserFacingDisplayName(channelTarget)
            channelText = zo_strformat(SI_CHAT_ENTRY_TARGET_FORMAT, GetChannelName(channelData.id), channelTarget)
        else
            channelText = zo_strformat(SI_CHAT_ENTRY_GENERAL_FORMAT, GetChannelName(channelData.id))
        end
        self.selectedChannelLabel:SetText(channelText)
        local r, g, b = ZO_ChatSystem_GetCategoryColorFromChannel(channelData.id)
        self.selectedChannelLabel:SetColor(r, g, b, 1)
        self.textEdit:SetColor(r, g, b)

        --Set the dropdown width to be wide enough to fit the text
        local stringWidth = self.selectedChannelFakeLabel:GetStringWidth(zo_strupper(channelText)) / GetUIGlobalScale()
        self.channelControl:SetWidth(zo_max(self.channelDropdown.minimumWidth, stringWidth))
    end
end

function ZO_ChatMenu_Gamepad:RefreshTooltip(targetData)
    local targetData = targetData or self.list:GetTargetData()
    if targetData then
        local links = targetData.data.links
        if links then
            local currentLinkData = links[self.currentLinkIndex]
            local linkType = currentLinkData.linkType
            local link = currentLinkData.link

            --TODO: Implement quest item links and maybe books (if we even care about books)
            if linkType == COLLECTIBLE_LINK_TYPE then
                GAMEPAD_TOOLTIPS:LayoutCollectibleFromLink(GAMEPAD_RIGHT_TOOLTIP, link)
            elseif linkType == ACHIEVEMENT_LINK_TYPE then
                GAMEPAD_TOOLTIPS:LayoutAchievementFromLink(GAMEPAD_RIGHT_TOOLTIP, link)
            elseif linkType == ITEM_LINK_TYPE then
                GAMEPAD_TOOLTIPS:LayoutItem(GAMEPAD_RIGHT_TOOLTIP, link)
            elseif linkType == GUILD_LINK_TYPE then
                GAMEPAD_TOOLTIPS:LayoutGuildLink(GAMEPAD_RIGHT_TOOLTIP, link)
            elseif linkType == HELP_LINK_TYPE then
                GAMEPAD_TOOLTIPS:LayoutHelpLink(GAMEPAD_RIGHT_TOOLTIP, link)
            end

            return
        end
    end
    GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP)
end

function ZO_ChatMenu_Gamepad:InitializeRefreshGroup()
    self.channelRefreshGroup = ZO_OrderedRefreshGroup:New(ZO_ORDERED_REFRESH_GROUP_AUTO_CLEAN_PER_FRAME)
    self.channelRefreshGroup:AddDirtyState("Dropdown", function()
        local RESELECT = true
        self:RefreshChannelDropdown(RESELECT)
    end)
    self.channelRefreshGroup:AddDirtyState("ActiveChannel", function()
        self:OnChatChannelChanged()
    end)
end

function ZO_ChatMenu_Gamepad:DirtyChannelDropdown()
    self.channelRefreshGroup:MarkDirty("Dropdown")
end

function ZO_ChatMenu_Gamepad:DirtyActiveChannel()
    self.channelRefreshGroup:MarkDirty("ActiveChannel")
end

function ZO_ChatMenu_Gamepad:SelectMessageEntryByLink(link)
    self:ActivateFocusArea(self.chatEntryPanelFocalArea)

    for messageIndex = 1, #self.messageEntries do
        local entry = self.messageEntries[messageIndex]
        if entry.data.links then
            for linkIndex, currentLink in ipairs(entry.data.links) do
                if currentLink.link == link then
                    self.list:SetSelectedIndex(messageIndex)
                    if self.scene:GetState() ~= SCENE_SHOWN then
                        self.isFocusSetFromLink = true
                    end
                    return
                end
            end
        end
    end
end

--------------
--Global XML--
--------------

function ZO_ChatMenu_Gamepad_OnInitialized(control)
    CHAT_MENU_GAMEPAD = ZO_ChatMenu_Gamepad:New(control)
end