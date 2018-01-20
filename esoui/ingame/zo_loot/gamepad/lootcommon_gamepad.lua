local STOLEN_ICON_TEXTURE = "EsoUI/Art/Inventory/inventory_stolenItem_icon.dds"

ZO_Loot_Gamepad_Base = ZO_Object:Subclass()

function ZO_Loot_Gamepad_Base:InitializeKeybindStripDescriptorsMixin(areEthereal)
    local lootBackupKeybind = KEYBIND_STRIP:GenerateGamepadBackButtonDescriptor(
            function()
                EndLooting()
            end)

    lootBackupKeybind.ethereal = areEthereal

    self.keybindStripDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        { -- Exit Button
            name = GetString(SI_EXIT_BUTTON),
            keybind = "UI_SHORTCUT_EXIT",
            callback =  function()
                EndLooting()
                SCENE_MANAGER:ShowBaseScene()
            end,
            ethereal = true
        },
        { -- Take Selected
            name = GetString(SI_LOOT_TAKE),
            keybind = "UI_SHORTCUT_PRIMARY",
            callback = function()
                self:LootTargeted()
            end,

            ethereal = areEthereal
        },
        { -- Take All
            name = GetString(SI_LOOT_TAKE_ALL),
            keybind = "UI_SHORTCUT_SECONDARY",
            callback =  function()
                LOOT_SHARED:LootAllItems()
            end,
            ethereal = areEthereal
        },
        lootBackupKeybind
    }
end

function ZO_Loot_Gamepad_Base:OnSelectionChanged(list, selectedData, oldSelectedData)
    KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)

    if selectedData then
        if selectedData.currencyType then 
            self:HideTooltip()
        else
            self:ShowTooltip(selectedData)
        end

        self:UpdateButtonTextOnSelection(selectedData)
    end
end

function ZO_Loot_Gamepad_Base:HideTooltip()
    GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP)
    GAMEPAD_TOOLTIPS:HideBg(GAMEPAD_RIGHT_TOOLTIP)
end

do
    local NOT_EQUIPPED = false
    local NO_CREATOR_NAME = nil
    local FORCE_FULL_DURABILITY = true
    local NO_PREVIEW_VALUE = nil
    function ZO_Loot_Gamepad_Base:ShowTooltip(selectedData)
        GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP)
        GAMEPAD_TOOLTIPS:Reset(GAMEPAD_RIGHT_TOOLTIP)

        if selectedData.isQuest then
            GAMEPAD_TOOLTIPS:LayoutQuestItem(GAMEPAD_RIGHT_TOOLTIP, GetLootQuestItemId(selectedData.lootId))
        else
            local lootLink = GetLootItemLink(selectedData.lootId)
            local lootType = selectedData.itemType
            if lootType == LOOT_TYPE_COLLECTIBLE then
                GAMEPAD_TOOLTIPS:LayoutCollectibleFromLink(GAMEPAD_RIGHT_TOOLTIP, lootLink)
            else
                GAMEPAD_TOOLTIPS:LayoutItemWithStackCount(GAMEPAD_RIGHT_TOOLTIP, lootLink, NOT_EQUIPPED, NO_CREATOR_NAME, FORCE_FULL_DURABILITY, NO_PREVIEW_VALUE, selectedData.stackCount)
            end
        end
        GAMEPAD_TOOLTIPS:ShowBg(GAMEPAD_RIGHT_TOOLTIP)
    end
end

function ZO_Loot_Gamepad_Base:LootTargeted()
    local item = self.itemList:GetTargetData()
    if item then
        if item.currencyType then
            LootCurrency(item.currencyType)
        else
            LootItemById(item.lootId)
        end
    end
end

function ZO_Loot_Gamepad_Base:Show()
    assert(false) -- must override
end

function ZO_Loot_Gamepad_Base:HasLootItems()
    local unownedMoney, ownedMoney = GetLootCurrency(CURT_MONEY)
    local telvarStones = GetLootCurrency(CURT_TELVAR_STONES)
    local writVouchers = GetLootCurrency(CURT_WRIT_VOUCHERS)
    return unownedMoney > 0 or ownedMoney > 0 or telvarStones > 0 or writVouchers > 0 or GetNumLootItems() > 0 
end

do
    local STOLEN = true
    function ZO_Loot_Gamepad_Base:UpdateList()
        self.itemList:Clear()

        self.itemCount = 0
        -- Assume there are no non-stolen items present until proven otherwise.
        self.nonStolenItemsPresent = false

        local numLootItems = GetNumLootItems()
        local currencyInfo = LOOT_SHARED:GetLootCurrencyInformation()

        -- Add non-stolen (unowned) currency and items
        for currencyType, currencyInfo in pairs(currencyInfo) do
            self:UpdateListAddLootCurrency(currencyType, currencyInfo.currencyAmount, not STOLEN)
        end
        self:UpdateListAddLootItems(numLootItems, not STOLEN)

        -- Add stolen (owned) money and items
        for currencyType, currencyInfo in pairs(currencyInfo) do
            self:UpdateListAddLootCurrency(currencyType, currencyInfo.stolenCurrencyAmount, STOLEN)
        end
        self:UpdateListAddLootItems(numLootItems, STOLEN)

        self.itemCount = self.itemCount + numLootItems

        if self.intialLootUpdate then
            self.itemList:CommitWithoutReselect()
        else
            self.itemList:Commit()
        end
    
        -- this text depends on the list itself
        self:UpdateAllControlText()
    end
end

function ZO_Loot_Gamepad_Base:UpdateListAddLootCurrency(currencyType, currencyAmount, isCurrencyStolen)
    if currencyAmount > 0 then
        local currencyIcon = GetCurrencyLootGamepadIcon(currencyType)
        local IS_UPPER = false
        local currencyEntry = ZO_GamepadEntryData:New(GetCurrencyName(currencyType, IsCountSingularForm(currencyAmount), IS_UPPER), currencyIcon)
        currencyEntry.currencyType = currencyType
        currencyEntry.currencyAmount = currencyAmount
        currencyEntry:InitializeLootVisualData(nil, currencyAmount, nil, nil, nil, isCurrencyStolen)
        if isCurrencyStolen then
            currencyEntry:AddIcon(STOLEN_ICON_TEXTURE)
        end
        self.itemList:AddEntry("ZO_GamepadItemSubEntryTemplate", currencyEntry)
        self.itemCount = self.itemCount + 1

        if not isCurrencyStolen then
            self.nonStolenItemsPresent = true
        end
    end
end

function ZO_Loot_Gamepad_Base:UpdateListAddLootItems(numLootItems, addStolenItems)
    for i = 1, numLootItems do
        local lootId, name, icon, count, quality, value, isQuest, isStolen, itemType = GetLootItemInfo(i)
            
        -- only add stolen items or non stolen items
        if addStolenItems == isStolen then
            name = zo_strformat(SI_TOOLTIP_ITEM_NAME, name)
            local lootEntry = ZO_GamepadEntryData:New(name, icon)
            lootEntry:InitializeLootVisualData(lootId, count, quality, value, isQuest, isStolen, itemType)
            if isStolen then
                lootEntry:AddIcon(STOLEN_ICON_TEXTURE)
            end
            self.itemList:AddEntry("ZO_GamepadItemSubEntryTemplate", lootEntry)

            if not isStolen then
                self.nonStolenItemsPresent = true
            end
        end
    end
end

function ZO_Loot_Gamepad_Base:UpdateLootWindow(name, actionName, isOwned)
    if not self.isInitialized then
        self:DeferredInitialize()
    end

    self.numUsedBagSlots = GetNumBagUsedSlots(BAG_BACKPACK)
    self.numTotalBagSlots = GetBagSize(BAG_BACKPACK)
    self.bagFull = self.numUsedBagSlots == self.numTotalBagSlots

    self:SetTitle(name)
    self.intialLootUpdate = self.control:IsControlHidden()
    self:Update(isOwned)

    if self.intialLootUpdate then
        self:Show()
    elseif not self:HasLootItems() then
        self:Hide()
    end
end

function  ZO_Loot_Gamepad_Base:EnoughRoomToTakeAll()
    local itemCount = self.itemCount or 0
    return not (self.numUsedBagSlots + itemCount > self.numTotalBagSlots)
end

-- Overridden in LootPickup

function ZO_Loot_Gamepad_Base:UpdateButtonTextOnSelection(selectedData)
end

function ZO_Loot_Gamepad_Base:UpdateAllControlText()
end

--------------------------
-- ZO_Loot_Common_Gamepad
--------------------------

local ZO_Loot_Common_Gamepad = ZO_Object:Subclass()

function ZO_Loot_Common_Gamepad:UpdateLootWindow(name, actionName, isOwned)
    if SCENE_MANAGER:IsShowing("gamepad_inventory_root") or SCENE_MANAGER:IsSceneOnStack("gamepad_inventory_root") then
        LOOT_INVENTORY_WINDOW_GAMEPAD:UpdateLootWindow(name, actionName, isOwned)
    else
        if SCENE_MANAGER:IsShowing("lootGamepad") or SCENE_MANAGER:IsShowingBaseScene() then
            --The update will show the window if we're on the base scene
            LOOT_WINDOW_GAMEPAD:UpdateLootWindow(name, actionName, isOwned)
        else
            EndInteraction(INTERACTION_LOOT)
        end
    end
end

function ZO_Loot_Common_Gamepad:Hide()
    LOOT_WINDOW_GAMEPAD:Hide()
    LOOT_INVENTORY_WINDOW_GAMEPAD:Hide()
end

function ZO_Loot_Common_Gamepad:AreNonStolenItemsPresent()
    return (LOOT_WINDOW_GAMEPAD.nonStolenItemsPresent == true)
end

--[[ Globals ]]--
LOOT_COMMON_GAMEPAD = ZO_Loot_Common_Gamepad:New()
SYSTEMS:RegisterGamepadObject("loot", LOOT_COMMON_GAMEPAD)
