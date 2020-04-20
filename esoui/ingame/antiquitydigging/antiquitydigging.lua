-----------------------
-- Antiquity Digging --
-----------------------

local ANTIQUITY_DIGGING_INTERACTION =
{
    type = "Antiquity Digging",
    interactTypes = { INTERACTION_ANTIQUITY_DIG_SPOT },
}

local ONE_BAR_STYLE =
{
    digPowerBarWidth = 168,
}

local TWO_BAR_STYLE =
{
    digPowerBar1Width = 80,
    digPowerBar2Width = 88,
}

local ONE_SPENDER_STYLE =
{
    digPowerIconFrameWidth = 128,
    digPowerIconFrameOffsetX = 42,
}

local TWO_SPENDER_STYLE =
{
    digPowerIconFrameWidth = 256,
    digPowerIconFrameOffsetX = 21,
}

local HAS_ONE_BAR = false
local HAS_TWO_BARS = true

local KEYBOARD_STYLE =
{
    keybindButtonTemplate = "ZO_KeybindButton_Keyboard_Template",
    stabilityBarTemplate = "ZO_AntiquityDiggingStabilityBar_Keyboard_Template",
    digPowerFrameTexture = { [HAS_ONE_BAR] = "EsoUI/Art/Antiquities/Keyboard/Digging_1Bar_Border.dds", [HAS_TWO_BARS] = "EsoUI/Art/Antiquities/Keyboard/Digging_2Bar_Border.dds" },
    digPowerBackgroundTexture = { [HAS_ONE_BAR] = "EsoUI/Art/Antiquities/Keyboard/Digging_1Bar_Border_BG.dds", [HAS_TWO_BARS] = "EsoUI/Art/Antiquities/Keyboard/Digging_2Bar_Border_BG.dds" },
    digPowerSingleBarGlowTexture = "EsoUI/Art/Antiquities/Keyboard/Digging_1Bar_Glow.dds",
    digPowerDoubleBarSingleGlowTexture = "EsoUI/Art/Antiquities/Keyboard/Digging_2Bar_Single_Glow.dds",
    digPowerDoubleBarDoubleGlowTexture = "EsoUI/Art/Antiquities/Keyboard/Digging_2Bar_Glow.dds",
    digPowerIconFrameTexture = { [HAS_ONE_BAR] = "EsoUI/Art/Antiquities/Keyboard/Digging_1Icon_Border.dds", [HAS_TWO_BARS] = "EsoUI/Art/Antiquities/Keyboard/Digging_2Icon_Border.dds" },
}

local GAMEPAD_STYLE =
{
    keybindButtonTemplate = "ZO_KeybindButton_Gamepad_Template",
    stabilityBarTemplate = "ZO_AntiquityDiggingStabilityBar_Gamepad_Template",
    digPowerFrameTexture = { [HAS_ONE_BAR] = "EsoUI/Art/Antiquities/Gamepad/GP_Digging_1Bar_Border.dds", [HAS_TWO_BARS] = "EsoUI/Art/Antiquities/Gamepad/GP_Digging_2Bar_Border.dds" },
    digPowerBackgroundTexture = { [HAS_ONE_BAR] = "EsoUI/Art/Antiquities/Gamepad/GP_Digging_1Bar_Border_BG.dds", [HAS_TWO_BARS] = "EsoUI/Art/Antiquities/Gamepad/GP_Digging_2Bar_Border_BG.dds" },
    digPowerSingleBarGlowTexture = "EsoUI/Art/Antiquities/Gamepad/GP_Digging_1Bar_Glow.dds",
    digPowerDoubleBarSingleGlowTexture = "EsoUI/Art/Antiquities/Gamepad/GP_Digging_2Bar_Single_Glow.dds",
    digPowerDoubleBarDoubleGlowTexture = "EsoUI/Art/Antiquities/Gamepad/GP_Digging_2Bar_Glow.dds",
    digPowerIconFrameTexture = { [HAS_ONE_BAR] = "EsoUI/Art/Antiquities/Gamepad/GP_Digging_1Icon_Border.dds", [HAS_TWO_BARS] = "EsoUI/Art/Antiquities/Gamepad/GP_Digging_2Icon_Border.dds" },
}

local DIG_POWER_REFUND_INCREMENT_INTERVAL_S = 0.05

ZO_AntiquityDigging = ZO_Object:Subclass()

function ZO_AntiquityDigging:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function ZO_AntiquityDigging:Initialize(control)
    self.control = control
    self.keybindContainer = control:GetNamedChild("KeybindContainer")
    self.meterContainer = control:GetNamedChild("MeterContainer")
    self.moreInfoKeybindButton = self.keybindContainer:GetNamedChild("MoreInfoKeybindButton")
    local NO_DEFAULT_KEYBIND = nil
    local DONT_SHOW_UNBOUND = nil
    self.moreInfoKeybindButton:SetKeybind(NO_DEFAULT_KEYBIND, DONT_SHOW_UNBOUND, "ANTIQUITY_DIGGING_MORE_INFO")
    self.stabilityControl = self.meterContainer:GetNamedChild("Stability")
    self.stabilityBarLeft = self.meterContainer:GetNamedChild("StabilityHealthBarLeft")
    self.stabilityBarRight = self.meterContainer:GetNamedChild("StabilityHealthBarRight")
    self.stabilityText = self.meterContainer:GetNamedChild("StabilityHealthText")
    
    local STABILITY_BAR_GRADIENT = { ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ANTIQUITY_DIGGING, ANTIQUITY_DIGGING_COLORS_STABILITY_START)), ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ANTIQUITY_DIGGING, ANTIQUITY_DIGGING_COLORS_STABILITY_END)) }
    ZO_StatusBar_SetGradientColor(self.stabilityBarLeft, STABILITY_BAR_GRADIENT)
    ZO_StatusBar_SetGradientColor(self.stabilityBarRight, STABILITY_BAR_GRADIENT)

    self.digPowerControl = self.meterContainer:GetNamedChild("DigPower")
    local DIG_POWER_BAR_GRADIENT = { ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ANTIQUITY_DIGGING, ANTIQUITY_DIGGING_COLORS_DIG_POWER_START)), ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ANTIQUITY_DIGGING, ANTIQUITY_DIGGING_COLORS_DIG_POWER_END)) }
    self.digPowerBars = { self.digPowerControl:GetNamedChild("Bar1"), self.digPowerControl:GetNamedChild("Bar2") }
    for _, digPowerBar in ipairs(self.digPowerBars) do
        ZO_StatusBar_SetGradientColor(digPowerBar, DIG_POWER_BAR_GRADIENT) 
    end
    self.digPowerFrameTexture = self.digPowerControl:GetNamedChild("Frame")
    self.digPowerBackgroundTexture = self.digPowerControl:GetNamedChild("Background")
    self.digPowerGlowTexture = self.digPowerControl:GetNamedChild("Glow")
    self.digPowerRefundGlowTexture = self.digPowerControl:GetNamedChild("RefundGlow")
    self.digPowerIconFrameTexture = self.digPowerControl:GetNamedChild("IconFrame")
    self.digPowerIconTextures = { self.digPowerIconFrameTexture:GetNamedChild("Icon1"), self.digPowerIconFrameTexture:GetNamedChild("Icon2") }
    self.digPowerGlowTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_AntiquityDiggingDigPowerGlowLoop", self.digPowerGlowTexture)
    self.digPowerRefundGlowTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_AntiquityDiggingDigPowerRefundGlow", self.digPowerRefundGlowTexture)

    self.keybindContainerTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_AntiquityDiggingHUDFade", self.keybindContainer)
    self.keybindContainerFastTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_AntiquityDiggingHUDFastFade", self.keybindContainer)
    self.meterContainerTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_AntiquityDiggingHUDFade", self.meterContainer)
    self.meterContainerFastPartialTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_AntiquityDiggingHUDFastPartialFade", self.meterContainer)

    ANTIQUITY_DIGGING_SCENE = ZO_RemoteInteractScene:New("antiquityDigging", SCENE_MANAGER, ANTIQUITY_DIGGING_INTERACTION)

    ANTIQUITY_DIGGING_ACTIONS_FRAGMENT = ZO_ActionLayerFragment:New("AntiquityDiggingActions")
    ANTIQUITY_DIGGING_FRAGMENT = ZO_FadeSceneFragment:New(control)
    ANTIQUITY_DIGGING_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_FRAGMENT_SHOWING then
            self.isGameOver = false
            self:RefreshInputModeFragments()
            control:RegisterForEvent(EVENT_ANTIQUITY_DIGGING_READY_TO_PLAY, function() self:OnAntiquityDiggingReadyToPlay() end)
        elseif newState == SCENE_FRAGMENT_HIDING then
            control:SetHandler("OnUpdate", nil)
        elseif newState == SCENE_FRAGMENT_HIDDEN then
            self:HideMoreInfo()
            control:UnregisterForEvent(EVENT_ANTIQUITY_DIGGING_READY_TO_PLAY)
            self.keybindContainerTimeline:PlayInstantlyToStart()
            self.meterContainerTimeline:PlayInstantlyToStart()
            self.durabilityUnitFrame:SetHasTarget(false)
        end
    end)

    ANTIQUITY_DIGGING_SCENE:SetHideSceneConfirmationCallback(function(...) self:OnConfirmHideScene(...) end)
    ANTIQUITY_DIGGING_SCENE:SetHandleGamepadPreferredModeChangedCallback(function(...) return self:HandleGamepadPreferredModeChanged(...) end)

    control:RegisterForEvent(EVENT_ANTIQUITY_DIGGING_GAME_OVER, function()
        self.isGameOver = true
        self:RefreshInputModeFragments()

        -- When the end of game summary fragment comes in, we want to get rid of the keybinds
        -- and tone down the bars so they don't feel like they're part of the summary but can still be referenced
        if ANTIQUITY_DIGGING_FRAGMENT:IsShowing() then
            if newState == SCENE_FRAGMENT_SHOWING then
                self.keybindContainerFastTimeline:PlayFromEnd()
                self.meterContainerFastPartialTimeline:PlayFromEnd()
            end
        end
    end)

    control:RegisterForEvent(EVENT_ANTIQUITY_DIGGING_EXIT_RESPONSE, function(_, accept)
        self:OnAntiquityDiggingExitResponse(accept)
    end)

    control:RegisterForEvent(EVENT_ANTIQUITY_DIG_SPOT_DURABILITY_CHANGED, function()
        self:RefreshDurabilityBar()
    end)

    control:RegisterForEvent(EVENT_ANTIQUITY_DIG_SPOT_STABILITY_CHANGED, function()
        self:RefreshStabilityBar()
    end)

    control:RegisterForEvent(EVENT_ANTIQUITY_DIG_SPOT_DIG_POWER_CHANGED, function()
        self:OnDigSpotDigPowerChanged()
    end)

    control:RegisterForEvent(EVENT_ANTIQUITY_DIGGING_DIG_POWER_REFUND, function()
        self:OnDigPowerRefund()
    end)

    control:RegisterForEvent(EVENT_ANTIQUITY_DIGGING_MOUSE_OVER_ACTIVE_SKILL_CHANGED, function(_, mousedOverSkill)
        -- Only handle mouseover on keyboard
        if not IsInGamepadPreferredMode() then
            if mousedOverSkill then
                self:ShowMoreInfoBySkill(mousedOverSkill)
            else
                self:HideMoreInfo()
            end
        end
    end)

    CALLBACK_MANAGER:RegisterCallback("UnitFramesCreated", function()
        --This anchor does nothing. It's controlled by the keyboard and gamepad XML templates
        local ANCHOR = ZO_Anchor:New(TOP, GuiRoot, TOP, 0, 0)
        self.durabilityUnitFrame = UNIT_FRAMES:CreateFrame("durability", ANCHOR, ZO_UNIT_FRAME_BAR_TEXT_MODE_HIDDEN, "ZO_TargetUnitFrame", "ZO_AntiquityDurabilityFrame")
        self.durabilityUnitFrameControl = self.durabilityUnitFrame:GetPrimaryControl()
        self.durabilityUnitFrameControl:SetParent(self.meterContainer)

        self.durabilityUnitFrame.UpdateName = function(unitFrame)
            if unitFrame.nameLabel then
                local antiquityId = GetDigSpotAntiquityId()
                if antiquityId ~= 0 then
                    local antiquityName = GetAntiquityName(antiquityId)
                    local antiquityQuality = GetAntiquityQuality(antiquityId)
                    local qualityColorDef = GetAntiquityQualityColor(antiquityQuality)
                    unitFrame.nameLabel:SetText(qualityColorDef:Colorize(antiquityName))
                end
            end
        end

        self.durabilityUnitFrame.GetHealth = function(unitFrame)
            return GetDigSpotDurability()
        end

        self.durabilityUnitFrame.healthBar.UpdateText = function(unitFrame, updateBarType, updateValue)
            if unitFrame.resourceNumbersLabel then
                unitFrame.resourceNumbersLabel:SetText(ZO_FormatResourceBarCurrentAndMax(unitFrame.currentValue, unitFrame.maxValue, RESOURCE_NUMBERS_SETTING_NUMBER_ONLY))
            end
        end
    end)

    self.platformStyle = ZO_PlatformStyle:New(function(style) self:ApplyPlatformStyle(style) end, KEYBOARD_STYLE, GAMEPAD_STYLE)
end

function ZO_AntiquityDigging:RefreshInputModeFragments()
    if ANTIQUITY_DIGGING_ACTIONS_FRAGMENT:IsShowing() then
        if self.isGameOver then
            self.keybindContainerTimeline:PlayFromEnd()
            self.meterContainerTimeline:PlayFromEnd()
        end
        --Remove the digging actions fragment so it can be on top of the gamepad UI mode fragment
        SCENE_MANAGER:RemoveFragment(ANTIQUITY_DIGGING_ACTIONS_FRAGMENT)
    end

    if IsInGamepadPreferredMode() then
        SCENE_MANAGER:AddFragment(GAMEPAD_UI_MODE_FRAGMENT)
        SCENE_MANAGER:AddFragment(HIDE_MOUSE_FRAGMENT)
    else
        SCENE_MANAGER:RemoveFragment(GAMEPAD_UI_MODE_FRAGMENT)
        SCENE_MANAGER:RemoveFragment(HIDE_MOUSE_FRAGMENT)
    end

    if not self.isGameOver then
        -- Re-add the digging actions fragment so it can be on top of the gamepad UI mode fragment
        SCENE_MANAGER:AddFragment(ANTIQUITY_DIGGING_ACTIONS_FRAGMENT)
    end
end

function ZO_AntiquityDigging:ApplyPlatformStyle(style)
    ApplyTemplateToControl(self.moreInfoKeybindButton, style.keybindButtonTemplate)
    ApplyTemplateToControl(self.stabilityControl, style.stabilityBarTemplate)
    --Reset the text here to handle the force uppercase on gamepad
    self.moreInfoKeybindButton:SetText(GetString(SI_ANTIQUITIES_DIGGING_MORE_INFO))
    self.moreInfoKeybindButton:SetHidden(not IsInGamepadPreferredMode())
    self:RefreshDigPowerConfiguration(style)
end

function ZO_AntiquityDigging:HandleGamepadPreferredModeChanged()
    self:RefreshInputModeFragments()
    -- We don't want to hide the scene.  The internal version will update the styles
    local HANDLED = true
    return HANDLED
end

function ZO_AntiquityDigging:OnConfirmHideScene(scene, nextSceneName, bypassHideSceneConfirmationReason)
    if bypassHideSceneConfirmationReason == nil then
        RequestAntiquityDiggingExit()
        self:HideMoreInfo()
    else
        scene:AcceptHideScene()
    end
end

function ZO_AntiquityDigging:OnAntiquityDiggingReadyToPlay()
    self.keybindContainerTimeline:PlayForward()
    self.meterContainerTimeline:PlayForward()
    self.durabilityUnitFrame:SetHasTarget(true)
    self:RefreshDurabilityBar()
    self:RefreshStabilityBar()
    self:RefreshDigPowerConfiguration()
    self:RefreshDigPowerBars()

    self.control:SetHandler("OnUpdate", function(_, timeS)
        self:OnUpdate(timeS)
    end)
end

function ZO_AntiquityDigging:RefreshDurabilityBar()
    if self.durabilityUnitFrame then
        local current, max = GetDigSpotDurability()
        self.durabilityUnitFrame.healthBar:Update(POWERTYPE_HEALTH, current, max)
    end
end

function ZO_AntiquityDigging:RefreshStabilityBar()
    local currentStability, maxStability = GetDigSpotStability()
    local halfCurrentStability, halfMaxStability = currentStability * 0.5, maxStability * 0.5
    self.stabilityBarLeft:SetMinMax(0, halfMaxStability)
    self.stabilityBarLeft:SetValue(halfCurrentStability)
    self.stabilityBarRight:SetMinMax(0, halfMaxStability)
    self.stabilityBarRight:SetValue(halfCurrentStability)
    self.stabilityText:SetText(ZO_FormatResourceBarCurrentAndMax(currentStability, maxStability, RESOURCE_NUMBERS_SETTING_NUMBER_ONLY))
end

do
    local function AddOwnedDigPowerSpenderIcon(icons, skill)
        if IsDiggingActiveSkillUnlocked(skill) then
            local skillType, skillLineIndex, skillIndex = GetDiggingActiveSkillIndices(skill)
            local skillData = SKILLS_DATA_MANAGER:GetSkillDataByIndices(skillType, skillLineIndex, skillIndex)
            if not skillData then
                return
            end

            local skillProgressionData = skillData:GetCurrentProgressionData()
            if not skillProgressionData then
                return
            end

            table.insert(icons, skillProgressionData:GetIcon())
        end
    end

    --Refreshs visuals that only change as a result of things that happen outside of the game (skill purchases) or gamepad mode changing
    function ZO_AntiquityDigging:RefreshDigPowerConfiguration(style)
        local ownedDigPowerSpenderIcons = {}
        AddOwnedDigPowerSpenderIcon(ownedDigPowerSpenderIcons, DIGGING_ACTIVE_SKILL_BASIC_EXCAVATION)
        AddOwnedDigPowerSpenderIcon(ownedDigPowerSpenderIcons, DIGGING_ACTIVE_SKILL_HEAVY_SHOVEL)
        local numOwnedDigPowerSpenders = #ownedDigPowerSpenderIcons

        if numOwnedDigPowerSpenders == 0 then
            self.digPowerControl:SetHidden(true)
            return
        else
            self.digPowerControl:SetHidden(false)
        end

        style = style or self.platformStyle:GetStyle()

        local _, max = GetDigSpotDigPower()
        local minSpendablePower = GetDigSpotMinPowerPerSpender()
        local hasTwoBars = max > minSpendablePower
        local digPowerBar1 = self.digPowerBars[1]
        local digPowerBar2 = self.digPowerBars[2]

        self.digPowerFrameTexture:SetTexture(style.digPowerFrameTexture[hasTwoBars])
        self.digPowerBackgroundTexture:SetTexture(style.digPowerBackgroundTexture[hasTwoBars])
        self.digPowerIconFrameTexture:SetTexture(style.digPowerIconFrameTexture[numOwnedDigPowerSpenders == 2])
        for i, digPowerIconTexture in ipairs(self.digPowerIconTextures) do
            if i <= numOwnedDigPowerSpenders then
                digPowerIconTexture:SetHidden(false)
                digPowerIconTexture:SetTexture(ownedDigPowerSpenderIcons[i])
            else
                digPowerIconTexture:SetHidden(true)
            end
        end

        if hasTwoBars then
            digPowerBar1:SetWidth(TWO_BAR_STYLE.digPowerBar1Width)
            digPowerBar2:SetWidth(TWO_BAR_STYLE.digPowerBar2Width)
            digPowerBar2:SetHidden(false)
        else
            digPowerBar1:SetWidth(ONE_BAR_STYLE.digPowerBarWidth)
            digPowerBar2:SetHidden(true)
        end

        local spenderStyle = numOwnedDigPowerSpenders == 1 and ONE_SPENDER_STYLE or TWO_SPENDER_STYLE
        self.digPowerIconFrameTexture:ClearAnchors()
        self.digPowerIconFrameTexture:SetAnchor(TOPLEFT, nil, TOPLEFT, spenderStyle.digPowerIconFrameOffsetX, 29)
        self.digPowerIconFrameTexture:SetWidth(spenderStyle.digPowerIconFrameWidth)

        for i, digPowerBar in ipairs(self.digPowerBars) do
            digPowerBar:SetMinMax(0, minSpendablePower)
        end
    end
end

function ZO_AntiquityDigging:GetVisualDigSpotDigPower()
    local current, max = GetDigSpotDigPower()
    if self.overrideVisualDigPower then
        current = self.overrideVisualDigPower
    end
    return current, max
end

--Refreshes visuals that change when dig power is gained or spent
function ZO_AntiquityDigging:RefreshDigPowerBars()
    local current, max = self:GetVisualDigSpotDigPower()
    local minSpendablePower = GetDigSpotMinPowerPerSpender()
    local hasTwoBars = max > minSpendablePower
    local style = self.platformStyle:GetStyle()
    local digPowerBar1 = self.digPowerBars[1]
    local digPowerBar2 = self.digPowerBars[2]

    digPowerBar1:SetValue(zo_min(current, minSpendablePower))

    local hasLeadingEdgeOnBar1
    local glowWasHidden = self.digPowerGlowTexture:IsControlHidden()
    local glowIsHidden = false
    if hasTwoBars then
        --The first of the two bars has a flat right side. We use the pointed leading edge on the bar when it is half full (1 dig power), but use no leading edge when full (2 dig power).
        hasLeadingEdgeOnBar1 = current <= 1
        digPowerBar2:SetValue(zo_max(current - minSpendablePower, 0))
        if current < minSpendablePower then
            glowIsHidden = true
        elseif current < max then
            self.digPowerGlowTexture:SetTexture(style.digPowerDoubleBarSingleGlowTexture)
        else
            self.digPowerGlowTexture:SetTexture(style.digPowerDoubleBarDoubleGlowTexture)
        end
    else
        hasLeadingEdgeOnBar1 = true
        if current < max then
            glowIsHidden = true
        else
            self.digPowerGlowTexture:SetTexture(style.digPowerSingleBarGlowTexture)
        end
    end
    digPowerBar1:EnableLeadingEdge(hasLeadingEdgeOnBar1)
    digPowerBar1:GetNamedChild("Gloss"):EnableLeadingEdge(hasLeadingEdgeOnBar1)
    if glowWasHidden ~= glowIsHidden then
        self.digPowerGlowTexture:SetHidden(glowIsHidden)
        if glowIsHidden then
            self.digPowerGlowTimeline:Stop()
        else
            self.digPowerGlowTimeline:PlayFromStart()
        end
    end
end

function ZO_AntiquityDigging:OnAntiquityDiggingExitResponse(accept)
    if accept then
        ANTIQUITY_DIGGING_SCENE:AcceptHideScene()
    else
        ANTIQUITY_DIGGING_SCENE:RejectHideScene()
    end
end

function ZO_AntiquityDigging:OnDigSpotDigPowerChanged()
    local current, max = GetDigSpotDigPower()
    if self.overrideVisualDigPower and current <= self.overrideVisualDigPower then
        self.overrideVisualDigPower = nil
        self.nextOverrideVisualDigPowerIncrementS = nil
    end
    self:RefreshDigPowerBars()
end

function ZO_AntiquityDigging:OnDigPowerRefund()
    self.overrideVisualDigPower = 0
    self.nextOverrideVisualDigPowerIncrementS = GetGameTimeSeconds() + DIG_POWER_REFUND_INCREMENT_INTERVAL_S
    self:RefreshDigPowerBars()
    PlaySound(SOUNDS.ANTIQUITIES_DIGGING_DIG_POWER_REFUND)
    self.digPowerRefundGlowTimeline:PlayFromStart()
end

function ZO_AntiquityDigging:OnUpdate(timeS)
    local digPowerOffsetX, digPowerOffsetY = GetDigPowerBarUIPosition()
    self.digPowerControl:ClearAnchors()
    self.digPowerControl:SetAnchor(CENTER, GuiRoot, TOPLEFT, digPowerOffsetX, digPowerOffsetY)
    if self.nextOverrideVisualDigPowerIncrementS and timeS > self.nextOverrideVisualDigPowerIncrementS then
        local current, max = GetDigSpotDigPower()
        if self.overrideVisualDigPower < current then 
            self.overrideVisualDigPower = self.overrideVisualDigPower + 1
            self.nextOverrideVisualDigPowerIncrementS = timeS + DIG_POWER_REFUND_INCREMENT_INTERVAL_S
        else
            self.overrideVisualDigPower = nil
            self.nextOverrideVisualDigPowerIncrementS = nil
        end
        self:RefreshDigPowerBars()
    end
end

function ZO_AntiquityDigging:OnShowMoreInfoKeybindPressed()
    if self.moreInfoKeybindButton:GetKeybind() then
        local selectedActiveSkill = GetSelectedDiggingActiveSkill()
        self:ShowMoreInfoBySkill(selectedActiveSkill)
    end
end

function ZO_AntiquityDigging:ShowMoreInfoBySkill(skill)
    if not skill then
        return
    end

    local skillType, skillLineIndex, skillIndex = GetDiggingActiveSkillIndices(skill)
    if skillType == SKILL_TYPE_NONE then
        return
    end

    local skillData = SKILLS_DATA_MANAGER:GetSkillDataByIndices(skillType, skillLineIndex, skillIndex)
    if not skillData then
        return
    end

    local skillProgressionData = skillData:GetCurrentProgressionData()
    if not skillProgressionData then
        return
    end

    if IsInGamepadPreferredMode() then
        GAMEPAD_TOOLTIPS:LayoutSkillProgression(GAMEPAD_RIGHT_TOOLTIP, skillProgressionData)
    else
        local TOOLTIP_HORIZONTAL_OFFSET = 50
        local offsetX, offsetY = GetDigToolUIKeybindPosition(skill)
        local point
        if offsetX < GuiRoot:GetWidth() * 0.5 then
            point = TOPLEFT
            offsetX = offsetX + TOOLTIP_HORIZONTAL_OFFSET
        else
            point = TOPRIGHT
            offsetX = offsetX - TOOLTIP_HORIZONTAL_OFFSET
        end

        InitializeTooltip(InformationTooltip, GuiRoot, point, offsetX, offsetY, TOPLEFT)
        local DONT_SHOW_SKILL_POINT_COST = false
        skillProgressionData:SetKeyboardTooltip(InformationTooltip, DONT_SHOW_SKILL_POINT_COST)
    end
end

function ZO_AntiquityDigging:OnShowMoreInfoKeybindReleased()
    GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP)
end

function ZO_AntiquityDigging:HideMoreInfo()
    ClearTooltip(InformationTooltip)
    GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP)
end

-- Global XML --

function ZO_AntiquityDigging_OnInitialized(control)
    ANTIQUITY_DIGGING = ZO_AntiquityDigging:New(control)
end
