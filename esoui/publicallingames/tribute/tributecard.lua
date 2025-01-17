local NO_CARD = 0

local TRIBUTE_CARD_ATLAS_FILE_DIMENSIONS = 512
ZO_TRIBUTE_CARD_UI_WIDTH = 284
ZO_TRIBUTE_CARD_UI_HEIGHT = 493
ZO_TRIBUTE_CARD_TOP_COORD = 0
ZO_TRIBUTE_CARD_BOTTOM_COORD = ZO_TRIBUTE_CARD_UI_HEIGHT / TRIBUTE_CARD_ATLAS_FILE_DIMENSIONS
ZO_TRIBUTE_CARD_LEFT_COORD = 0
ZO_TRIBUTE_CARD_RIGHT_COORD = ZO_TRIBUTE_CARD_UI_WIDTH / TRIBUTE_CARD_ATLAS_FILE_DIMENSIONS
local TRIBUTE_CARD_WORLD_WIDTH = 0.1115
ZO_TRIBUTE_CARD_WORLD_SCALE = TRIBUTE_CARD_WORLD_WIDTH / ZO_TRIBUTE_CARD_UI_WIDTH

ZO_TRIBUTE_SUIT_ICON_DIMENSIONS = 64
ZO_TRIBUTE_SUIT_ICON_TOP_COORD = 0
ZO_TRIBUTE_SUIT_ICON_BOTTOM_COORD = ZO_TRIBUTE_SUIT_ICON_DIMENSIONS / TRIBUTE_CARD_ATLAS_FILE_DIMENSIONS
ZO_TRIBUTE_SUIT_ICON_LEFT_COORD = (TRIBUTE_CARD_ATLAS_FILE_DIMENSIONS - ZO_TRIBUTE_SUIT_ICON_DIMENSIONS) / TRIBUTE_CARD_ATLAS_FILE_DIMENSIONS
ZO_TRIBUTE_SUIT_ICON_RIGHT_COORD = 1

local TRIBUTE_CARD_COLOR_DAMAGED = ZO_ColorDef:New(ZO_ColorDef.HexToFloats("fff25454"))
local TRIBUTE_CARD_COLOR_HEALED = ZO_ColorDef:New(ZO_ColorDef.HexToFloats("ff2adc22"))

local MECHANIC_CONTAINER_LARGE_ACTIVATION_HEIGHT = 55
local MECHANIC_CONTAINER_LARGE_COMBO_HEIGHT = 55
local MECHANIC_CONTAINER_SMALL_ACTIVATION_HEIGHT = 41
local MECHANIC_CONTAINER_SMALL_COMBO_HEIGHT = 41

ZO_MECHANIC_TYPE_ICON_LARGE_DIMENSIONS = 32
ZO_MECHANIC_TYPE_ICON_SMALL_DIMENSIONS = 24

local TRIBUTE_CARD_STATE_EFFECT_LAYER_OVERLAY = 1
local TRIBUTE_CARD_STATE_EFFECT_LAYER_UNDERLAY = 2
local TRIBUTE_CARD_STATE_EFFECT_LAYERS =
{
    TRIBUTE_CARD_STATE_EFFECT_LAYER_OVERLAY,
    TRIBUTE_CARD_STATE_EFFECT_LAYER_UNDERLAY,
}

local TRIBUTE_CARD_STATE_EFFECT_CONTROL_TEMPLATES =
{
    [TRIBUTE_CARD_STATE_FLAGS_BUYABLE] =
    {
        [TRIBUTE_CARD_STATE_EFFECT_LAYER_OVERLAY] = "ZO_TributeCard_BuyableOverlay_Template",
        [TRIBUTE_CARD_STATE_EFFECT_LAYER_UNDERLAY] = "ZO_TributeCard_BuyableUnderlay_Template",
    },
    [TRIBUTE_CARD_STATE_FLAGS_DAMAGEABLE] =
    {
        [TRIBUTE_CARD_STATE_EFFECT_LAYER_OVERLAY] = "ZO_TributeCard_DamageableOverlay_Template",
        [TRIBUTE_CARD_STATE_EFFECT_LAYER_UNDERLAY] = "ZO_TributeCard_DamageableUnderlay_Template",
    },
    [TRIBUTE_CARD_STATE_FLAGS_PLAYABLE] =
    {
        [TRIBUTE_CARD_STATE_EFFECT_LAYER_OVERLAY] = "ZO_TributeCard_PlayableOverlay_Template",
        [TRIBUTE_CARD_STATE_EFFECT_LAYER_UNDERLAY] = "ZO_TributeCard_PlayableUnderlay_Template",
    },
    [TRIBUTE_CARD_STATE_FLAGS_TARGETABLE] =
    {
        [TRIBUTE_CARD_STATE_EFFECT_LAYER_OVERLAY] = "ZO_TributeCard_TargetableOverlay_Template",
        [TRIBUTE_CARD_STATE_EFFECT_LAYER_UNDERLAY] = "ZO_TributeCard_TargetableUnderlay_Template",
    },
    [TRIBUTE_CARD_STATE_FLAGS_TARGETED] =
    {
        [TRIBUTE_CARD_STATE_EFFECT_LAYER_OVERLAY] = "ZO_TributeCard_TargetedOverlay_Template",
        [TRIBUTE_CARD_STATE_EFFECT_LAYER_UNDERLAY] = "ZO_TributeCard_TargetedUnderlay_Template",
    },
    [TRIBUTE_CARD_STATE_FLAGS_STACK_PLAYABLE] =
    {
        [TRIBUTE_CARD_STATE_EFFECT_LAYER_OVERLAY] = "ZO_TributeCard_StackPlayableOverlay_Template",
        [TRIBUTE_CARD_STATE_EFFECT_LAYER_UNDERLAY] = "ZO_TributeCard_StackPlayableUnderlay_Template",
    },
    [TRIBUTE_CARD_STATE_FLAGS_STACK_DAMAGEABLE] =
    {
        [TRIBUTE_CARD_STATE_EFFECT_LAYER_OVERLAY] = "ZO_TributeCard_StackDamageableOverlay_Template",
        [TRIBUTE_CARD_STATE_EFFECT_LAYER_UNDERLAY] = "ZO_TributeCard_StackDamageableUnderlay_Template",
    },
    [TRIBUTE_CARD_STATE_FLAGS_CALLOUT] =
    {
        [TRIBUTE_CARD_STATE_EFFECT_LAYER_OVERLAY] = "ZO_TributeCard_CalloutOverlay_Template",
        [TRIBUTE_CARD_STATE_EFFECT_LAYER_UNDERLAY] = "ZO_TributeCard_CalloutUnderlay_Template",
    },
}

local TRIBUTE_PILE_TOOLTIP_BOARD_LOCATIONS =
{
    TRIBUTE_BOARD_LOCATION_OPPONENT_BOARD_ACTION,
    TRIBUTE_BOARD_LOCATION_OPPONENT_BOARD_AGENT,
    TRIBUTE_BOARD_LOCATION_OPPONENT_COOLDOWN,
    TRIBUTE_BOARD_LOCATION_OPPONENT_DECK,
    TRIBUTE_BOARD_LOCATION_PLAYER_BOARD_ACTION,
    TRIBUTE_BOARD_LOCATION_PLAYER_BOARD_AGENT,
    TRIBUTE_BOARD_LOCATION_PLAYER_COOLDOWN,
    TRIBUTE_BOARD_LOCATION_PLAYER_DECK,
}

-- Mechanic Container --

ZO_TributeCard_MechanicContainer = ZO_Tribute_PooledObject:Subclass()

function ZO_TributeCard_MechanicContainer:Initialize(control)
    self.control = control
    control.object = self
    self.frameTexture = control:GetNamedChild("Frame")
    self.typeIconTexture = control:GetNamedChild("TypeIcon")
    self.quantityLabel = control:GetNamedChild("Quantity")
end

do
    internalassert(TRIBUTE_MECHANIC_TRIGGER_ITERATION_END == 1, "A new Tribute mechanic trigger has been added. Please add it to the MECHANIC_TRIGGER_SUFFIX table")
    local MECHANIC_TRIGGER_SUFFIX =
    {
        [TRIBUTE_MECHANIC_TRIGGER_ACTIVATION] = "Activation",
        [TRIBUTE_MECHANIC_TRIGGER_COMBO] = "Combo",
    }

    internalassert(TRIBUTE_MECHANIC_ITERATION_END == 13, "A new Tribute mechanic has been added. Does the MECHANIC_PARAM_MODIFIERS need special modifiers for this mechanic?")
    local MECHANIC_PARAM_MODIFIERS =
    {
        [TRIBUTE_MECHANIC_HEAL_AGENT] =
        {
            quantityDisplayOverride =
            {
                displayParam = 1,
            }
        },
        [TRIBUTE_MECHANIC_ACQUIRE_CARDS] =
        {
            quantityDisplayOverride =
            {
                displayParam = 1,
            }
        },
    }

    local OFFSET_X = 42
    local LARGE_DOUBLE_DIGIT_OFFSET_X = 52
    local FIRST_TOP_OFFSET_Y = 135
    local LARGE_PADDING_Y = 15
    local SMALL_PADDING_Y = 10
    local OVERSIZED_SCALE = 1.2
    local OVERSIZED_PADDING_Y = 6

    function ZO_TributeCard_MechanicContainer:Setup(cardObject, trigger, mechanicIndex)
        local control = self.control
        self.cardDefId = cardObject:GetCardDefId()
        self.trigger = trigger
        self.mechanicIndex = mechanicIndex
        self.tributeMechanicType, self.quantity, self.comboNum, self.param1, self.param2, self.param3 = cardObject:GetMechanicInfo(trigger, mechanicIndex)
        self.numSiblings = cardObject:GetNumMechanics(trigger)
        local isActivationTrigger = trigger == TRIBUTE_MECHANIC_TRIGGER_ACTIVATION
        local isComboTrigger = trigger == TRIBUTE_MECHANIC_TRIGGER_COMBO
        local chooseOneMechanic = isActivationTrigger and cardObject:DoesChooseOneMechanic()
        local isOversized = self.numSiblings <= 2
        local scale = isOversized and OVERSIZED_SCALE or 1
        control:SetScale(scale)
        if chooseOneMechanic then
            -- Quick and dirty workaround. The choice display isn't actually a mechanic, it replaces all of the mechanics on the card as one unified concept
            -- TODO Tribute: If we want to change to let design control which mechanics require choice, or work with combos, this logic will be useless and will need to be reimplemented
            if mechanicIndex == 1 then
                ApplyTemplateToControl(control, "ZO_TributeCard_MechanicContainer_Large_SingleDigit_Activation_Style")
                self.typeIconTexture:SetTexture("EsoUI/Art/Tribute/Mechanics/tributeMechanicCardDisplay_chooseOne.dds")
                self.quantityLabel:SetText(self.numSiblings)
                local offsetY = FIRST_TOP_OFFSET_Y + (MECHANIC_CONTAINER_LARGE_ACTIVATION_HEIGHT / 2 * OVERSIZED_SCALE)
                control:SetAnchor(CENTER, nil, TOPLEFT, OFFSET_X, offsetY)
            else
                control:SetHidden(true)
            end
            return
        end

        local isSmallContainer = self.numSiblings >= 4
        local triggerSuffix = MECHANIC_TRIGGER_SUFFIX[trigger]
        local sizeSuffix = isSmallContainer and "Small" or "Large"
        local quantityDisplayValue = self.quantity
        local paramModifiers = MECHANIC_PARAM_MODIFIERS[self.tributeMechanicType]
        if paramModifiers then
            local paramQuantityDisplayOverride = paramModifiers.quantityDisplayOverride
            if paramQuantityDisplayOverride then
                if paramQuantityDisplayOverride.displayParam == 1 then
                    quantityDisplayValue = self.param1
                elseif paramQuantityDisplayOverride.displayParam == 2 then
                    quantityDisplayValue = self.param2
                elseif paramQuantityDisplayOverride.displayFunction then
                    quantityDisplayValue = paramQuantityDisplayOverride.displayFunction(self.param1, self.param2)
                else
                    quantityDisplayValue = paramQuantityDisplayOverride[self.param1]
                end
            end
        end
        local isDoubleDigitContainer = quantityDisplayValue >= 10
        local digitsSuffix = isDoubleDigitContainer and "Double" or "Single"
        
        ApplyTemplateToControl(control, string.format("ZO_TributeCard_MechanicContainer_%s_%sDigit_%s_Style", sizeSuffix, digitsSuffix, triggerSuffix))
        self.typeIconTexture:SetTexture(GetTributeMechanicIconPath(self.tributeMechanicType, self.param1, self.param2, self.param3))
        local quantityDisplayText = quantityDisplayValue == 0 and GetString(SI_TRIBUTE_MECHANIC_ANY_QUANTITY_SYMBOL) or quantityDisplayValue
        self.quantityLabel:SetText(quantityDisplayText)
        self.frameGlowTextureFileName = string.format("EsoUI/Art/Tribute/Mechanics/tributeMechanicCardFrame_%s_%s_%s_glow.dds", triggerSuffix, sizeSuffix, digitsSuffix)
        
        -- Add pips to combo hexes.
        -- Combo 2 has no pips. Combo 3 has 1 pip. Combo 4 has 2 pips...
        if isComboTrigger and self.comboNum > 2 then
            if not self.pipsLabel then
                self.pipsLabel = CreateControlFromVirtual("$(parent)Pips", control, "ZO_TributeCard_MechanicComboPip_Template")
            end
            local pipSize = isSmallContainer and 14 or 16
            local offsetY = isSmallContainer and 17 or 24
            local pipTextureMarkup = zo_iconFormat("EsoUI/Art/Tribute/Mechanics/tributeMechanicComboPip_full.dds", pipSize, pipSize)

            local numPips = self.comboNum - 2
            self.pipsLabel:SetText(string.rep(pipTextureMarkup, numPips))
            self.pipsLabel:SetAnchor(CENTER, control, CENTER, 0, offsetY)
        end

        local offsetX = OFFSET_X
        local height
        local paddingY
        if isSmallContainer then
            height = isActivationTrigger and MECHANIC_CONTAINER_SMALL_ACTIVATION_HEIGHT or MECHANIC_CONTAINER_SMALL_COMBO_HEIGHT
            paddingY = SMALL_PADDING_Y
        else
            height = isActivationTrigger and MECHANIC_CONTAINER_LARGE_ACTIVATION_HEIGHT or MECHANIC_CONTAINER_LARGE_COMBO_HEIGHT
            height = height * scale
            paddingY = LARGE_PADDING_Y
            if isDoubleDigitContainer then
                offsetX = LARGE_DOUBLE_DIGIT_OFFSET_X
            end
        end
        
        local firstCenterOffsetY = FIRST_TOP_OFFSET_Y + (height / 2)
        local offsetY = firstCenterOffsetY + ((height + paddingY) * (mechanicIndex - 1))
        if isActivationTrigger then
            control:SetAnchor(CENTER, nil, TOPLEFT, offsetX, offsetY)
        else
            control:SetAnchor(CENTER, nil, TOPRIGHT, -offsetX, offsetY)
        end
    end
end

function ZO_TributeCard_MechanicContainer:Reset()
    self:SetGlowHidden(true)
    if self.pipsLabel then
        self.pipsLabel:SetText("")
    end
    self.cardDefId = nil
    self.trigger = nil
    self.mechanicIndex = nil
    self.tributeMechanicType = nil
    self.quantity = nil
    self.param1 = nil
    self.param2 = nil
    self.param3 = nil
    self.numSiblings = nil
    self.frameGlowTextureFileName = nil
end

function ZO_TributeCard_MechanicContainer:GetControl()
    return self.control
end

function ZO_TributeCard_MechanicContainer:GetTriggerAndIndex()
    return self.trigger, self.mechanicIndex
end

function ZO_TributeCard_MechanicContainer:GetFrameGlowTextureFileName()
    return self.frameGlowTextureFileName
end

function ZO_TributeCard_MechanicContainer:SetGlowHidden(hidden)
    if hidden then
        if self.frameGlowTexture then
            TRIBUTE_POOL_MANAGER:GetMechanicGlowPool():ReleaseObject(self.frameGlowTexture.key)
            self.frameGlowTexture = nil
        end
    else
        if not self.frameGlowTexture then
            self.frameGlowTexture = TRIBUTE_POOL_MANAGER:GetMechanicGlowPool():AcquireObject(self)
        end
    end
end

-- Card Defeat Cost Adjustment --

ZO_TributeCard_DefeatCostAdjustment = ZO_InitializingObject:Subclass()

function ZO_TributeCard_DefeatCostAdjustment:Initialize(cardObject)
    self.cardObject = cardObject

    local frontControl = self.cardObject:GetFrontControl()
    self.control = CreateControlFromVirtual("$(parent)DefeatCostAdjustment", frontControl, "ZO_TributeCard_DefeatCostAdjustment")
    self.control:SetExcludeFromResizeToFitExtents(true)
    self.bannerTexture = self.control:GetNamedChild("Banner")
    self.baseBannerTexture = frontControl:GetNamedChild("DefeatCostBanner")
    self.anchorToControl = frontControl:GetNamedChild("NameBanner")

    local timeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_TributeCard_DefeatCostAdjustmentTimeline")
    self.timeline = timeline
    timeline.object = self
    timeline:ApplyAllAnimationsToControl(self.control)

    self.queue = {}
    self:Reset()
end

function ZO_TributeCard_DefeatCostAdjustment:Reset()
    ZO_ClearTable(self.queue)
    self:ResetVisuals()
end

function ZO_TributeCard_DefeatCostAdjustment:ResetVisuals()
    local control = self.control
    control:SetHidden(true)
    control:SetAlpha(0)
    control:ClearAnchors()
    control:SetAnchor(TOP, self.anchorToControl, nil, nil, 30)
    control:SetScale(1)

    local bannerTexture = self.bannerTexture
    bannerTexture:SetScale(1)

    -- Order matters
    self.currentEntry = nil
    self.targetOffsetX = nil
    self.targetOffsetY = nil
    self.timeline:PlayInstantlyToStart()
end

do
    local function TryShowNextQueueEntry(self, queueEntry)
        if self.currentEntry then
            if queueEntry then
                -- An animation is already playing; queue this entry.
                table.insert(self.queue, queueEntry)
            end
            return
        end

        local nextQueueEntry = table.remove(self.queue, 1)
        if nextQueueEntry then
            if queueEntry then
                -- The queue is not empty; queue this entry and play the next entry from the queue.
                table.insert(self.queue, queueEntry)
            end
        else
            nextQueueEntry = queueEntry
        end

        if not nextQueueEntry then
            -- The queue is empty and no queue entry was specified.
            return
        end

        -- Order matters
        self.currentEntry = nextQueueEntry
        self:OnTimelineStarted()
        self.timeline:PlayForward()
    end

    function ZO_TributeCard_DefeatCostAdjustment:UpdateDefeatCost(newCost, costDelta)
        -- Queue this animation or, if the queue is empty and no animation is already playing, play it immediately.
        local queueEntry =
        {
            oldCost = newCost - costDelta,
            newCost = newCost,
            costDelta = costDelta,
        }
        TryShowNextQueueEntry(self, queueEntry)
    end

    function ZO_TributeCard_DefeatCostAdjustment:OnTimelineStopped()
        if self.currentEntry then
            -- Order matters
            self:ResetVisuals()
            TryShowNextQueueEntry(self)
        end
    end
end

function ZO_TributeCard_DefeatCostAdjustment:OnTimelineStarted()
    local entry = self.currentEntry
    if not entry then
        -- No animation is currently playing.
        return
    end

    local control = self.control
    control:SetText(string.format("%s%d", entry.costDelta > 0 and "+" or "", entry.costDelta))
    -- Interpolate the font color based upon whether this is a damage or healing event.
    if entry.costDelta < 0 then
        self.startFontColor = TRIBUTE_CARD_COLOR_DAMAGED
    else
        self.startFontColor = TRIBUTE_CARD_COLOR_HEALED
    end
    self.endFontColor = self.startFontColor:GetBright()
    control:SetColor(self.startFontColor:UnpackRGBA())

    local cardBannerTextureFileName = self.cardObject:GetDefeatCostTextureFile()
    self.bannerTexture:SetTexture(cardBannerTextureFileName)

    -- Translate upward and to either the left or right randomly.
    local MIN_OFFSET = 90
    local MAX_OFFSET = 100
    local targetOffset = zo_lerp(MIN_OFFSET, MAX_OFFSET, zo_random())
    if zo_random() < 0.5 then
        self.targetOffsetX = -targetOffset
    else
        self.targetOffsetX = targetOffset
    end
    self.targetOffsetY = 30 - targetOffset * 0.25

    -- Animate over slightly varied durations to reduce repetitiveness.
    local MIN_DURATION_MS = 1900
    local MAX_DURATION_MS = 2100
    local durationMS = zo_lerp(MIN_DURATION_MS, MAX_DURATION_MS, zo_random())
    local animation = self.timeline:GetFirstAnimation()
    animation:SetDuration(durationMS)

    control:SetHidden(false)
end

function ZO_TributeCard_DefeatCostAdjustment:OnTimelineUpdate(progress)
    local entry = self.currentEntry
    if not entry then
        -- No animation is currently playing.
        return
    end

    -- Interpolate the banner texture scale.
    local easeOut = ZO_EaseOutQuadratic(progress)
    self.bannerTexture:SetScale(zo_lerp(1, 1.75, easeOut))

    local control = self.control
    control:ClearAnchors()

    -- Translate the control up and to the left/right.
    local interpolatedOffsetX = zo_lerp(0, self.targetOffsetX, easeOut)
    local interpolatedOffsetY = zo_lerp(30, self.targetOffsetY, ZO_EaseOutQuartic(progress))
    control:SetAnchor(CENTER, self.anchorToControl, nil, interpolatedOffsetX, interpolatedOffsetY)

    -- Interpolate the font color from dim to bright while gradually fading the control away.
    local r, g, b = self.startFontColor:Lerp(self.endFontColor, easeOut):UnpackRGB()
    local a = progress < 0.75 and 1 or (1 - (progress - 0.75) * 4)
    control:SetColor(r, g, b, a)
end

-- Card State Effect --

ZO_TributeCard_StateEffect = ZO_Tribute_PooledObject:Subclass()

function ZO_TributeCard_StateEffect:Initialize(control)
    self.control = control
    control.object = self

    local timeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_TributeCard_StateEffectTimeline")
    self.timeline = timeline
    timeline.object = self
    timeline:ApplyAllAnimationsToControl(self.control)

    self:Reset()
end

do
    -- Used for diversification of animation visuals.
    local nextAnimationOffset = 0
    local nextWaveAngle = math.rad(15)

    local MAX_ANIMATION_OFFSET = 1000
    local MAX_SHADER_PRECISION = 3600
    local WAVE_OFFSET_COEFFICIENT = 10
    local WAVE_ANGLE_INCREMENT = ZO_HALF_PI * 3

    function ZO_TributeCard_StateEffect:Setup(cardObject, cardState, cardLayer)
        self.cardObject = cardObject
        self.cardState = cardState
        self.cardLayer = cardLayer
        internalassert(self:IsValid(), "Tribute card state effect 'cardObject', 'cardState' or 'cardLayer' is invalid.")

        local control = self.control
        local controlTemplate = self:GetControlTemplate()
        ApplyTemplateToControl(control, controlTemplate)

        local alphaAnimation = self.timeline:GetAnimation(1)
        if cardLayer == TRIBUTE_CARD_STATE_EFFECT_LAYER_OVERLAY then
            alphaAnimation:SetEndAlpha(0.75)
        elseif cardLayer == TRIBUTE_CARD_STATE_EFFECT_LAYER_UNDERLAY then
            alphaAnimation:SetEndAlpha(1.0)
        end

        local parentControl = self.cardObject.control
        control:SetParent(parentControl)
        control:ClearAnchors()
        control:SetAnchor(CENTER, parentControl)

        local animationOffset = nextAnimationOffset
        nextAnimationOffset = (nextAnimationOffset + 1) % MAX_ANIMATION_OFFSET

        local waveOffset = (animationOffset * WAVE_OFFSET_COEFFICIENT) % MAX_SHADER_PRECISION
        control:SetWaveOffset(waveOffset)
        local waveAngle = nextWaveAngle
        nextWaveAngle = (nextWaveAngle + WAVE_ANGLE_INCREMENT) % ZO_TWO_PI
        control:SetWaveAngle(waveAngle)

        control:SetHidden(false)
        self:SetActive(true)
    end
end

function ZO_TributeCard_StateEffect:Reset()
    self.control:SetHidden(true)
    self.timeline:Stop()

    self.cardObject = nil
    self.cardState = nil
    self.cardLayer = nil
end

function ZO_TributeCard_StateEffect:GetCardObject()
    return self.cardObject
end

function ZO_TributeCard_StateEffect:GetCardState()
    return self.cardState
end

function ZO_TributeCard_StateEffect:GetCardLayer()
    return self.cardLayer
end

function ZO_TributeCard_StateEffect:GetControlTemplate()
    local stateEffectTemplates = TRIBUTE_CARD_STATE_EFFECT_CONTROL_TEMPLATES[self.cardState]
    if not stateEffectTemplates then
        internalassert(false, string.format("No card state effect template configured for Tribute card state '%s'.", tostring(self.cardState) or "nil"))
    end
    local controlTemplate = stateEffectTemplates[self.cardLayer]
    if not controlTemplate then
        internalassert(false, string.format("Layer '%s' does not exist for card state effect template '%s'.", tostring(self.cardLayer) or "nil", tostring(self.cardState)))
    end
    return controlTemplate
end

function ZO_TributeCard_StateEffect:IsValid()
    return self.cardObject ~= nil and self.cardState ~= nil and self.cardLayer ~= nil
end

function ZO_TributeCard_StateEffect:IsActive()
    return not self.timeline:IsPlayingBackward() and (self.timeline:IsPlaying() or self.timeline:GetProgress() > 0)
end

function ZO_TributeCard_StateEffect:SetActive(active)
    if self:IsValid() and active ~= self:IsActive() then
        if active then
            self.timeline:PlayForward()
        else
            self.timeline:PlayBackward()
        end
    end
end

function ZO_TributeCard_StateEffect:OnStateEffectTimelineStopped(completedPlaying)
    if self:IsValid() then
        self.cardObject:OnStateEffectChanged(self, self:IsActive())
    end
end

-- Card --

ZO_TributeCard = ZO_InitializingObject:MultiSubclass(ZO_Tribute_PooledObject, ZO_TributeCardData)

function ZO_TributeCard:Initialize(control)
    ZO_TributeCardData.Initialize(self)

    self.control = control
    control.object = self

    local frontControl = control:GetNamedChild("Front")
    self.frontControl = frontControl
    self.bgGlowableTexture = frontControl:GetNamedChild("BG")
    self.portraitGlowableTexture = frontControl:GetNamedChild("Portrait")
    self.frameGlowableTexture = frontControl:GetNamedChild("Frame")
    self.suitGlowableTexture = frontControl:GetNamedChild("Suit")
    self.nameLabel = frontControl:GetNamedChild("Name")
    self.contractOrCurseBannerTexture = frontControl:GetNamedChild("ContractOrCurseBanner")
    self.costLabel = frontControl:GetNamedChild("Cost")
    self.costIconTexture = self.costLabel:GetNamedChild("Icon")
    self.defeatCostLabel = frontControl:GetNamedChild("DefeatCost")
    if self.defeatCostLabel then
        self.defeatCostBannerTexture = self.defeatCostLabel:GetNamedChild("Banner")
    end
    self.backGlowableTexture = control:GetNamedChild("Back")

    self.mechanicContainers = {}
    self.numMechanicsByTrigger = {}
    self.stateEffects = {}

    self:Reset()
end

function ZO_TributeCard:Setup(cardDefId, patronDefId, overrideSpace)
    ZO_TributeCardData.Setup(self, patronDefId, cardDefId)

    if overrideSpace and overrideSpace ~= self.control:GetParent():GetSpace() then
        self.control:SetSpace(overrideSpace)
    end

    self.popupType = nil

    self.control:SetScale(self:GetDefaultScale())
    if self:IsWorldCard() then
        self.control:SetAnchor(CENTER, GuiRoot)
    end

    local patronData = self:GetPatronData()
    local suitAtlasImage, suitAtlasGlowImage = patronData:GetSuitAtlas(self:GetCardType())
    local portraitImage, portraitGlowImage = self:GetPortrait()
    local isContract = self:IsContract()
    local isCurse = self:IsCurse()

    self.bgGlowableTexture:SetTexture(suitAtlasImage)
    self.bgGlowableTexture.glowTexture:SetTexture(suitAtlasGlowImage)
    if isCurse then
        self.suitGlowableTexture:SetHidden(true)
    else
        self.suitGlowableTexture:SetHidden(false)
        self.suitGlowableTexture:SetTexture(suitAtlasImage)
        self.suitGlowableTexture.glowTexture:SetTexture(suitAtlasGlowImage)
    end
    self.portraitGlowableTexture:SetTexture(portraitImage)
    self.portraitGlowableTexture.glowTexture:SetTexture(portraitGlowImage)
    self.nameLabel:SetText(self:GetFormattedName())

    local contractOrCurseBannerTextureFile = nil
    if isContract then
        contractOrCurseBannerTextureFile = "EsoUI/Art/Tribute/tributeCardContractBanner.dds"
    elseif isCurse then
        contractOrCurseBannerTextureFile = "EsoUI/Art/Tribute/tributeCardCurseBanner.dds"
    end

    if contractOrCurseBannerTextureFile then
        self.contractOrCurseBannerTexture:SetTexture(contractOrCurseBannerTextureFile)
        self.contractOrCurseBannerTexture:SetHidden(false)
    else
        self.contractOrCurseBannerTexture:SetHidden(true)
    end

    local costResourceType, costQuantity = self:GetAcquireCost()
    if costQuantity > 0 then
        self.costLabel:SetHidden(false)
        self.costLabel:SetText(costQuantity)
        local costTextureFile = self:GetAcquireCostTextureFile(isContract)
        self.costIconTexture:SetTexture(costTextureFile)
    else
        self.costLabel:SetHidden(true)
    end

    local defeatCostBannerTextureFile = self:GetDefeatCostTextureFile()
    if defeatCostBannerTextureFile then
        self.defeatCostBannerTexture:SetTexture(defeatCostBannerTextureFile)
    end

    self:RefreshDefeatCost()

    local mechanicContainerPool = TRIBUTE_POOL_MANAGER:GetMechanicContainerPool()
    for trigger = TRIBUTE_MECHANIC_TRIGGER_ITERATION_BEGIN, TRIBUTE_MECHANIC_TRIGGER_ITERATION_END do
        for mechanicIndex = 1, self.numMechanicsByTrigger[trigger] do
            local mechanicContainer = mechanicContainerPool:AcquireObject(self, trigger, mechanicIndex)
            table.insert(self.mechanicContainers, mechanicContainer)
        end
    end
end

function ZO_TributeCard:GetCardInstanceId()
    return self.cardInstanceId
end

function ZO_TributeCard:SetCardInstanceId(cardInstanceId)
    self.cardInstanceId = cardInstanceId
    self:RefreshDefeatCost()
    if self:IsWorldCard() then
        AssignControlToTributeCard(cardInstanceId, self.control)
    end
    self:OnStateFlagsChanged(GetTributeCardStateFlags(cardInstanceId))
end

function ZO_TributeCard:GetMechanicContainer(mechanicTrigger, mechanicIndex)
    for _, mechanicContainer in ipairs(self.mechanicContainers) do
        local trigger, index = mechanicContainer:GetTriggerAndIndex()
        if trigger == mechanicTrigger and index == mechanicIndex then
            return mechanicContainer
        end
    end
    return nil
end

function ZO_TributeCard:GetPopupType()
    return self.popupType
end

function ZO_TributeCard:SetPopupType(popupType)
    self.popupType = popupType
end

function ZO_TributeCard:PlayAlphaAnimation(playForward, animateInstantly)
    if animateInstantly then
        self:ReleaseAlphaAnimation()
        self:SetAlphaProgress(playForward and 1 or 0)
    else
        local timeline = self.alphaTimeline
        if not timeline then
            timeline = TRIBUTE_POOL_MANAGER:GetAlphaAnimationPool():AcquireObject()
            timeline:ApplyAllAnimationsToControl(self.control)
            timeline:PlayInstantlyToStart()
            timeline.cardObject = self
            self.alphaTimeline = timeline
        end

        if playForward then
            timeline:PlayForward()
        else
            timeline:PlayBackward()
        end
    end
end

function ZO_TributeCard:IsRevealed()
    return self.cardInstanceId and not self.frontControl:IsHidden()
end

function ZO_TributeCard:IsInterfaceCard()
    return self.control:GetSpace() == SPACE_INTERFACE
end

function ZO_TributeCard:IsWorldCard()
    return self.control:GetSpace() == SPACE_WORLD
end

function ZO_TributeCard:GetDefaultScale()
    return self:IsWorldCard() and ZO_TRIBUTE_CARD_WORLD_SCALE or 1
end

function ZO_TributeCard:GetScreenAnchor(anchor)
    return self.control:ProjectRectToScreenAndComputeAABBPoint(anchor)
end

function ZO_TributeCard:GetScreenCenter()
    return self.control:ProjectToScreen(0.5, 0.5)
end

function ZO_TributeCard:GetAnchorNearestScreenCenter()
    local anchor = ZO_GetAnchorPointNearestScreenCenter(self:GetScreenCenter())
    local screenX, screenY = self:GetScreenAnchor(anchor)
    return anchor, screenX, screenY
end

--- Override of ZO_TributeCardData ---
-- Returns resourceType, maxQuantity, currentQuantity
function ZO_TributeCard:GetDefeatCost()
    local resourceType, maxQuantity = GetTributeCardDefeatCost(self.cardDefId)
    local currentQuantity = maxQuantity
    if self.cardInstanceId then
        resourceType, currentQuantity = GetTributeCardInstanceDefeatCost(self.cardInstanceId)
    end
    return resourceType, maxQuantity, currentQuantity
end

function ZO_TributeCard:SetDefeatCost(quantity)
    if self:GetCardType() ~= TRIBUTE_CARD_TYPE_AGENT then
        -- Only Agent cards have a defeat cost.
        return
    end

    local resourceType, maxQuantity, currentQuantity = self:GetDefeatCost()
    if resourceType ~= TRIBUTE_RESOURCE_POWER then
        assert(false, string.format("Card %d using invalid Defeat Cost type. No UI design for any defeat cost that isn't TRIBUTE_RESOURCE_POWER. If another type is desired, please contact a UI designer.", self.cardDefId))
    end

    quantity = quantity or currentQuantity
    self.defeatCostLabel:SetText(quantity)
    local color = quantity < maxQuantity and TRIBUTE_CARD_COLOR_DAMAGED or ZO_WHITE
    self.defeatCostLabel:SetColor(color:UnpackRGBA())
end

function ZO_TributeCard:RefreshDefeatCost()
    local USE_CURRENT_QUANTITY = nil
    self:SetDefeatCost(USE_CURRENT_QUANTITY)
end

function ZO_TributeCard:UpdateDefeatCost(newCost, costDelta)
    -- Reflect the new defeat cost instantly.
    self:SetDefeatCost(newCost)

    if not self.defeatCostAdjustmentObject then
        -- Create and permanently cache a ZO_TributeCard_DefeatCostAdjustment object for this card object.
        self.defeatCostAdjustmentObject = ZO_TributeCard_DefeatCostAdjustment:New(self)
    end

    -- Queue animation of the defeat cost delta.
    self.defeatCostAdjustmentObject:UpdateDefeatCost(newCost, costDelta)

    -- Play the associated audio.
    if costDelta < 0 then
        if newCost > 0 then
            PlaySound(SOUNDS.TRIBUTE_AGENT_DAMAGED)
        else
            PlaySound(SOUNDS.TRIBUTE_AGENT_KNOCKED_OUT)
        end
    elseif costDelta > 0 then
        PlaySound(SOUNDS.TRIBUTE_AGENT_HEALED)
    end
end

-- Evaluates the effective state flags given the specified state flags or, if unspecified, the current state flags of the card.
function ZO_TributeCard:GetEffectiveStateFlags(currentStateFlags)
    local stateFlags = currentStateFlags or self.stateFlags
    local _, _, isStacked, isTopOfStack = self:GetStackInfo()

    if self:IsWorldCard() then
        if (isStacked and not isTopOfStack) or not TRIBUTE:CanInteractWithCards() then
            -- Suppress all flags for World space cards (1) while the pile viewer, target viewer or mechanic
            -- selector is open or (2) that are in a stack that are not the top card in that stack.
            stateFlags = 0
        end
    else
        if self:GetPopupType() == ZO_TRIBUTE_CARD_POPUP_TYPE.MECHANIC then
            -- Suppress all flags for a Mechanic tile's popup card.
            stateFlags = 0
        else
            -- Suppress stack-related flags for non-Mechanic popup cards.
            stateFlags = ZO_ClearMaskFlags(stateFlags, TRIBUTE_CARD_STATE_FLAGS_STACK_DAMAGEABLE, TRIBUTE_CARD_STATE_FLAGS_STACK_PLAYABLE)
        end
    end

    return stateFlags
end

function ZO_TributeCard:RefreshStateFlags()
    self:OnStateFlagsChanged(self.stateFlags)
end

function ZO_TributeCard:OnStateFlagsChanged(stateFlags)
    -- Cache the state flags in order to avoid unnecessary visual effect spawning/releasing.
    -- TODO Tribute: Reevaluate performance at a later point to see if this is still necessary.
    if not stateFlags then
        stateFlags = 0
    end

    self.stateFlags = stateFlags
    local effectiveStateFlags = self:GetEffectiveStateFlags(stateFlags)
    local flagValueChangesTable = ZO_CompareMaskFlags(self.effectiveStateFlags, effectiveStateFlags)
    if not flagValueChangesTable then
        return
    end

    self.effectiveStateFlags = effectiveStateFlags
    for stateFlag, active in pairs(flagValueChangesTable) do
        self:OnStateFlagChanged(stateFlag, active)
    end
end

function ZO_TributeCard:OnStateFlagChanged(stateFlag, active)
    if stateFlag == TRIBUTE_CARD_STATE_FLAGS_HIGHLIGHTED then
        -- Tribute highlight is handled directly via SetHighlighted.
        self:SetHighlighted(active)
        return
    end

    -- All other card states are managed using pooled state effects.
    local stateEffects = self.stateEffects[stateFlag]
    if stateEffects then
        for cardLayer, layerEffect in pairs(stateEffects) do
            -- If activating, reactivate an existing effect that is in the process of deactivating;
            -- if deactivating, effects will be released via the OnStateEffectChanged callback issued from the OnStop animation event.
            layerEffect:SetActive(active)
        end
    else
        if active then
            stateEffects = {}
            self.stateEffects[stateFlag] = stateEffects
            for _, cardLayer in ipairs(TRIBUTE_CARD_STATE_EFFECT_LAYERS) do
                -- Acquire an effect from the pool; effect activation is handled via the acquisition process.
                local layerEffect = TRIBUTE_POOL_MANAGER:GetCardStateEffectPool():AcquireObject(self, stateFlag, cardLayer)
                stateEffects[cardLayer] = layerEffect
            end
        end
    end
end

function ZO_TributeCard:OnStateEffectChanged(stateEffect, active)
    if not active then
        local cardState = stateEffect:GetCardState()
        if cardState then
            local stateEffects = self.stateEffects[cardState]
            if stateEffects then
                local cardLayer = stateEffect:GetCardLayer()
                local layerEffect = stateEffects[cardLayer]
                if layerEffect == stateEffect then
                    -- Release this effect.
                    stateEffects[cardLayer] = nil
                    layerEffect:ReleaseObject()

                    if not next(stateEffects) then
                        -- If no other layer effects exist for this state
                        -- remove the state table from self.stateEffects.
                        self.stateEffects[cardState] = nil
                    end
                end
            end
        end
    end
end

function ZO_TributeCard:Reset()
    self:HideBoardLocationPatronsTooltip()
    self:ReleaseAllObjects()

    if self.defeatCostAdjustmentObject then
        self.defeatCostAdjustmentObject:Reset()
    end

    local control = self.control
    control:SetClampedToScreen(false)
    control:SetClampedToScreenInsets(0, 0, 0, 0)
    control:ClearTransform()
    control:SetSpace(nil)
    control:SetAlpha(1)
    control:SetScale(1)
    self.frontControl:SetHidden(false)
    self.backGlowableTexture:SetHidden(true)
    self:SetMouseEnabled(true)

    self.cardDefId = nil
    self.patronDefId = nil
    self.cardInstanceId = nil
    self.effectiveStateFlags = 0
    self.stateFlags = 0
    self.keyboardTooltipControl = nil
    self.gamepadTooltipControl = nil
end

function ZO_TributeCard:ReleaseAllObjects()
    self:ReleaseAlphaAnimation()
    self:ReleaseGlowAnimation()
    self:ReleaseMechanics()
    self:ReleasePopupAnimation()
    self:ReleaseStateEffects()
end

function ZO_TributeCard:ReleaseAlphaAnimation()
    local timeline = self.alphaTimeline
    if timeline then
        self.alphaTimeline = nil
        TRIBUTE_POOL_MANAGER:GetAlphaAnimationPool():ReleaseObject(timeline.key)
        self:SetAlphaProgress(1)
    end
end

function ZO_TributeCard:ReleaseGlowAnimation()
    local timeline = self.glowTimeline
    if timeline then
        self.glowTimeline = nil
        TRIBUTE_POOL_MANAGER:GetGlowAnimationPool():ReleaseObject(timeline.key)
        self:SetGlowProgress(0)
    end
end

function ZO_TributeCard:ReleaseMechanics()
    ZO_ClearTable(self.numMechanicsByTrigger)
    for _, mechanicContainer in ipairs(self.mechanicContainers) do
        mechanicContainer:ReleaseObject()
    end
    ZO_ClearNumericallyIndexedTable(self.mechanicContainers)
end

function ZO_TributeCard:ReleasePopupAnimation()
    local timeline = self.popupTimeline
    if timeline then
        self.popupTimeline = nil
        TRIBUTE_POOL_MANAGER:GetCardPopupAnimationPool():ReleaseObject(timeline.key)
        self:SetPopupProgress(1)
    end
end

function ZO_TributeCard:ReleaseStateEffects()
    for _, stateEffects in pairs(self.stateEffects) do
        for _, layerEffect in pairs(stateEffects) do
            layerEffect:ReleaseObject()
        end
    end
    ZO_ClearTable(self.stateEffects)
end

function ZO_TributeCard:GetStackInfo()
    if not self.cardInstanceId then
        return
    end
    
    local cardIndexInPile, numCardsInPile, isStacked = GetTributeCardPositionInPile(self.cardInstanceId)
    local isTopOfStack = isStacked and cardIndexInPile == numCardsInPile
    return cardIndexInPile, numCardsInPile, isStacked, isTopOfStack
end

function ZO_TributeCard:IsStacked()
    local _, _, isStacked = self:GetStackInfo()
    return isStacked == true
end

function ZO_TributeCard:GetBoardLocation()
    return self.cardInstanceId and GetTributeCardInstanceBoardLocation(self.cardInstanceId) or nil
end

function ZO_TributeCard:HideBoardLocationPatronsTooltip()
    if self.keyboardTooltipControl then
        ClearTooltipImmediately(self.keyboardTooltipControl)
        self.keyboardTooltipControl = nil
    end

    if self.gamepadTooltipControl then
        ZO_TributeBoardLocationPatronsTooltip_Gamepad_Hide()
        self.gamepadTooltipControl = nil
    end
end

function ZO_TributeCard:ShowBoardLocationPatronsTooltip()
    if not (self.cardInstanceId and self:IsWorldCard()) then
        return false
    end

    self:HideBoardLocationPatronsTooltip()

    local boardLocation = self:GetBoardLocation()
    if not ZO_IsElementInNumericallyIndexedTable(TRIBUTE_PILE_TOOLTIP_BOARD_LOCATIONS, boardLocation) then
        return false
    end

    local anchor, offsetX, offsetY
    local cardCenterX, _ = self:GetScreenCenter()
    local screenCenterX, _ = GuiRoot:GetCenter()

    -- The positioning of the tooltip is based on which half of the screen the card is on
    if cardCenterX > screenCenterX then
        offsetX, offsetY = self:GetScreenAnchor(LEFT)
        anchor = RIGHT
    else
        offsetX, offsetY = self:GetScreenAnchor(RIGHT)
        anchor = LEFT
    end

    if TRIBUTE:IsInputStyleMouse() then
        local control = NarrowTooltip
        InitializeTooltip(control, GuiRoot, anchor, offsetX, offsetY, TOPLEFT)
        control:SetTributeBoardLocationPatrons(boardLocation)
        self.keyboardTooltipControl = control

        return true
    elseif TRIBUTE:IsInputStyleGamepad() then
        local tooltipControl = ZO_TributeBoardLocationPatronsTooltip_Gamepad_GetControl()
        ZO_TributeBoardLocationPatronsTooltip_Gamepad_Show(boardLocation, anchor, GuiRoot, TOPLEFT, offsetX, offsetY)
        self.gamepadTooltipControl = tooltipControl

        return true
    end

    return false
end

function ZO_TributeCard:IsInteractive()
    if not (self.cardInstanceId and TRIBUTE:CanInteractWithCards()) then
        -- Suppress interaction for non-instanced cards or when the pile viewer, target viewer or mechanic selector is open.
        return false
    end

    local _, _, isStacked, isTopOfStack = self:GetStackInfo()
    if isStacked and not isTopOfStack then
        -- Suppress interaction for stacked cards that are not the top card in the stack.
        return false
    end

    return true
end

function ZO_TributeCard:OnCursorEnter()
    if self:IsInteractive() then
        SetHighlightedTributeCard(self.cardInstanceId)
    end
end

function ZO_TributeCard:OnCursorExit()
    self:HideBoardLocationPatronsTooltip()

    if self.cardInstanceId then
        SetHighlightedTributeCard(NO_CARD)
    end
end

function ZO_TributeCard:OnMouseEnter()
    if TRIBUTE:IsInputStyleMouse() and self:IsInteractive() then
        SetHighlightedTributeCard(self.cardInstanceId)
    end
end

function ZO_TributeCard:OnMouseUp(button, upInside)
    if TRIBUTE:IsInputStyleMouse() and upInside and button == MOUSE_BUTTON_INDEX_LEFT and self.cardInstanceId then
        -- Don't allow interaction with cards while the target viewer is up
        if ZO_TRIBUTE_TARGET_VIEWER_MANAGER:IsViewingTargets() then
            return
        end
        InteractWithTributeCard(self.cardInstanceId)
    end
end

function ZO_TributeCard:IsCardStateActive(cardState)
    return ZO_MaskHasFlag(self.stateFlags, cardState)
end

function ZO_TributeCard:IsPlayable()
    return ZO_MaskHasFlag(self.stateFlags, TRIBUTE_CARD_STATE_FLAGS_PLAYABLE)
end

function ZO_TributeCard:IsDamageable()
    return ZO_MaskHasFlag(self.stateFlags, TRIBUTE_CARD_STATE_FLAGS_DAMAGEABLE)
end

function ZO_TributeCard:IsTargeted()
    return ZO_MaskHasFlag(self.stateFlags, TRIBUTE_CARD_STATE_FLAGS_TARGETED)
end

function ZO_TributeCard:IsHidden()
    return self.control:IsHidden()
end

function ZO_TributeCard:SetHidden(hidden)
    self.control:SetHidden(hidden)
end

function ZO_TributeCard:IsHighlighted()
    return ZO_MaskHasFlag(self.stateFlags, TRIBUTE_CARD_STATE_FLAGS_HIGHLIGHTED)
end

function ZO_TributeCard:SetHighlighted(isHighlighted)
    local timeline = self.glowTimeline
    if isHighlighted then
        if not timeline then
            timeline = TRIBUTE_POOL_MANAGER:GetGlowAnimationPool():AcquireObject()
            timeline:ApplyAllAnimationsToControl(self.control)
            timeline:PlayInstantlyToStart()
            timeline.cardObject = self
            self.glowTimeline = timeline
        end
        timeline:PlayForward()
        if not self:IsWorldCard() then
            -- If a world card is being highlighted, that means we'll get a popup interface card, also highlighted.
            -- We'll let that play the sound so we don't play it twice.
            PlaySound(SOUNDS.TRIBUTE_CARD_HIGHLIGHTED)
        end
    else
        if timeline then
            timeline:PlayBackward()
        end
    end
end

function ZO_TributeCard:SetMechanicGlowHidden(mechanicTrigger, mechanicIndex, hidden)
    local mechanicContainer = self:GetMechanicContainer(mechanicTrigger, mechanicIndex)
    if mechanicContainer then
        mechanicContainer:SetGlowHidden(hidden)
    end
end

function ZO_TributeCard:SetMouseEnabled(enabled)
    self.control:SetMouseEnabled(enabled)
end

function ZO_TributeCard:ShowAsPopup(screenX, screenY, popupType)
    local control = self.control

    self:SetPopupType(popupType)
    if popupType == ZO_TRIBUTE_CARD_POPUP_TYPE.CARD then
        control:SetAnchor(CENTER, GuiRoot, TOPLEFT, screenX, screenY)

        local timeline = self.popupTimeline
        if not timeline then
            timeline = TRIBUTE_POOL_MANAGER:GetCardPopupAnimationPool():AcquireObject()
            timeline:ApplyAllAnimationsToControl(control)
            timeline:PlayInstantlyToStart()
            timeline.cardObject = self
            self.popupTimeline = timeline
        end
        timeline:PlayForward()
    elseif popupType == ZO_TRIBUTE_CARD_POPUP_TYPE.MECHANIC then
        control:SetAnchor(LEFT, GuiRoot, TOPLEFT, screenX, screenY)
    end

    if ZO_TRIBUTE_TARGET_VIEWER_MANAGER:IsViewingTargets() then
        local bottom = IsInGamepadPreferredMode() and ZO_KEYBIND_STRIP_GAMEPAD_VISUAL_HEIGHT or ZO_KEYBIND_STRIP_KEYBOARD_VISUAL_HEIGHT
        control:SetClampedToScreenInsets(0, 0, 0, bottom)
    end
    control:SetClampedToScreen(true)
    control:SetHidden(false)
    self:SetMouseEnabled(false)
end

function ZO_TributeCard:OnAlphaTimelineStopped(timeline)
    if timeline == self.alphaTimeline and timeline:IsPlayingBackward() then
        self:ReleaseAlphaAnimation()
    end
end

function ZO_TributeCard:OnGlowTimelineStopped(timeline)
    if timeline == self.glowTimeline and timeline:IsPlayingBackward() then
        self:ReleaseGlowAnimation()
    end
end

function ZO_TributeCard:SetAlphaProgress(alpha)
    self.control:SetAlpha(alpha)
    if self.cardInstanceId then
        SetTributeCardHidden(self.cardInstanceId, alpha < 1)
    end
end

function ZO_TributeCard:SetGlowProgress(progress)
    self.bgGlowableTexture.glowTexture:SetAlpha(progress)
    self.portraitGlowableTexture.glowTexture:SetAlpha(progress)
    self.frameGlowableTexture.glowTexture:SetAlpha(progress)
    self.suitGlowableTexture.glowTexture:SetAlpha(progress)
    self.backGlowableTexture.glowTexture:SetAlpha(progress)
end

function ZO_TributeCard:SetPopupProgress(progress)
    local maxScale = self:GetDefaultScale()
    local minScale = maxScale * 0.5
    self.control:SetScale(zo_lerp(minScale, maxScale, progress))
end

function ZO_TributeCard:GetControl()
    return self.control
end

function ZO_TributeCard:GetFrontControl()
    return self.frontControl
end

function ZO_TributeCard:GetScreenAnchorPosition(anchor)
    local screenX, screenY = self.control:ProjectRectToScreenAndComputeAABBPoint(anchor)
    return screenX, screenY
end

-- Global Functions --

function ZO_TributeCard_OnInitialized(...)
    ZO_TributeCard:New(...)
end

function ZO_TributeCard_AlphaTimeline_OnStop(timeline, completedPlaying)
    if timeline.cardObject then
        timeline.cardObject:OnAlphaTimelineStopped(timeline)
    end
end

function ZO_TributeCard_AlphaTimeline_SetProgress(animation, progress)
    local timeline = animation:GetTimeline()
    if timeline.cardObject then
        timeline.cardObject:SetAlphaProgress(progress)
    end
end

function ZO_TributeCard_DefeatCostAdjustmentTimeline_OnStop(timeline, completedPlaying)
    if timeline.object then
        timeline.object:OnTimelineStopped(completedPlaying)
    end
end

function ZO_TributeCard_DefeatCostAdjustmentTimeline_SetProgress(animation, progress)
    local timeline = animation:GetTimeline()
    if timeline.object then
        timeline.object:OnTimelineUpdate(progress)
    end
end

function ZO_TributeCard_GlowTimeline_OnStop(timeline, completedPlaying)
    if timeline.cardObject then
        timeline.cardObject:OnGlowTimelineStopped(timeline)
    end
end

function ZO_TributeCard_GlowTimeline_SetProgress(animation, progress)
    local timeline = animation:GetTimeline()
    if timeline.cardObject then
        timeline.cardObject:SetGlowProgress(progress)
    end
end

function ZO_TributeCard_MechanicContainer_OnInitialized(...)
    ZO_TributeCard_MechanicContainer:New(...)
end

function ZO_TributeCard_PopupTimeline_SetProgress(animation, progress)
    local timeline = animation:GetTimeline()
    if timeline.cardObject then
        timeline.cardObject:SetPopupProgress(progress)
    end
end

function ZO_TributeCard_StateEffect_OnInitialized(...)
    ZO_TributeCard_StateEffect:New(...)
end

function ZO_TributeCard_StateEffectTimeline_OnStop(timeline, completedPlaying)
    if timeline.object then
        timeline.object:OnStateEffectTimelineStopped(completedPlaying)
    end
end