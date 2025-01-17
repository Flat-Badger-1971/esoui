-- optionalDockCardUpgradeContext should be a table from ZO_TributePatronData:GetDockCards
function ZO_Tooltip:LayoutTributeCard(cardData, optionalDockCardUpgradeContext)
    local patronData = TRIBUTE_DATA_MANAGER:GetTributePatronData(cardData:GetPatronDefId())
    local isContract = cardData:IsContract()
    local isCurse = cardData:IsCurse()

    -- Header
    local topSection = self:AcquireSection(self:GetStyle("collectionsTopSection"))

    local cardTypeString = GetString("SI_TRIBUTECARDTYPE", cardData:GetCardType())
    if isContract then
        topSection:AddLine(zo_strformat(SI_TRIBUTE_CARD_TYPE_CONTRACT, cardTypeString))
    elseif isCurse then
        topSection:AddLine(zo_strformat(SI_TRIBUTE_CARD_TYPE_CURSE, cardTypeString))
    else
        topSection:AddLine(cardTypeString)
    end

    if not isCurse then
        topSection:AddLine(patronData:GetFormattedNameAndSuitIcon())
    end

    topSection:AddLine(GetString(SI_TRIBUTE_CARD_ITEM_TYPE))
    self:AddSection(topSection)

    -- Title
    local titleSection = self:AcquireSection(self:GetStyle("title"))
    local itemDisplayQuality = cardData:GetRarity()
    local qualityColor = GetItemQualityColor(itemDisplayQuality)
    titleSection:AddLine(cardData:GetFormattedName(), { fontColor = qualityColor })

    local costResourceType, acquireCost = cardData:GetAcquireCost()
    if acquireCost > 0 then
        local acquirePair = titleSection:AcquireStatValuePair(self:GetStyle("statValuePair"))
        acquirePair:SetStat(GetString("SI_TRIBUTERESOURCE_ACQUIRE", costResourceType), self:GetStyle("statValuePairStat"))
        acquirePair:SetValue(acquireCost, self:GetStyle("statValuePairValue"))
        titleSection:AddStatValuePair(acquirePair)
    end

    local defeatResourceType, defeatCost = cardData:GetDefeatCost()
    if defeatCost > 0 then
        local defeatPair = titleSection:AcquireStatValuePair(self:GetStyle("statValuePair"))
        defeatPair:SetStat(GetString("SI_TRIBUTERESOURCE_DEFEAT", defeatResourceType), self:GetStyle("statValuePairStat"))
        defeatPair:SetValue(defeatCost, self:GetStyle("statValuePairValue"))
        titleSection:AddStatValuePair(defeatPair)
    end

    self:AddSection(titleSection)

    -- Activation Mechanics
    -- Even when there are no activation effects, add the header, cause we'll put a line saying there are no activation effects
    local activationSection = self:AcquireSection(self:GetStyle("bodySection"))
    activationSection:AddLine(GetString(SI_TRIBUTE_CARD_PLAY_EFFECT), self:GetStyle("bodyHeader"))
    local ACTIVATION_TRIGGER = TRIBUTE_MECHANIC_TRIGGER_ACTIVATION
    local numMechanics = cardData:GetNumMechanics(ACTIVATION_TRIGGER)
    if numMechanics > 0 then
        if cardData:DoesChooseOneMechanic() then
            activationSection:AddLine(GetString(SI_TRIBUTE_CARD_CHOOSE_ONE_MECHANIC), self:GetStyle("tributeBodyText"), self:GetStyle("tributeChooseOneText"))
        end
        local PREPEND_ICON = true
        for index = 1, numMechanics do
            local mechanicText = cardData:GetMechanicText(ACTIVATION_TRIGGER, index, PREPEND_ICON)
            activationSection:AddLine(mechanicText, self:GetStyle("tributeBodyText"))
        end
    else
        activationSection:AddLine(GetString(SI_TRIBUTE_CARD_NO_PLAY_EFFECT_DESCRIPTION), self:GetStyle("tributeBodyText"))
    end
    self:AddSection(activationSection)

    -- Combo mechanics
    local COMBO_TRIGGER = TRIBUTE_MECHANIC_TRIGGER_COMBO
    local numMechanics = cardData:GetNumMechanics(COMBO_TRIGGER)
    if numMechanics > 0 then
        local comboSection = nil
        -- We technically only support combo 2, combo 3, and combo 4 right now. Any more requires a different visual solution on the card itself.
        -- That said, it makes no real difference to support an arbitrarily higher number here to remain somewhat flexible for future designs
        -- since we'll stop as soon as we've processed every mechanic anyway
        local MIN_COMBO_NUM = 2
        local MAX_COMBO_NUM = 10
        local PREPEND_ICON = true
        local mechanicsProcessed = 0
        for currentComboNum = MIN_COMBO_NUM, MAX_COMBO_NUM do
            local isHeaderShown = false
            for comboMechanicIndex = 1, numMechanics do
                local mechanicComboNum = select(3, cardData:GetMechanicInfo(COMBO_TRIGGER, comboMechanicIndex))
                if currentComboNum == mechanicComboNum then
                    if not isHeaderShown then
                        local headerText = zo_strformat(SI_TRIBUTE_CARD_COMBO_EFFECT, currentComboNum)
                        if comboSection then
                            self:AddSection(comboSection)
                        end
                        comboSection = self:AcquireSection(self:GetStyle("bodySection"))
                        comboSection:AddLine(headerText, self:GetStyle("bodyHeader"))
                        isHeaderShown = true
                    end
                    local mechanicText = cardData:GetMechanicText(COMBO_TRIGGER, comboMechanicIndex, PREPEND_ICON)
                    comboSection:AddLine(mechanicText, self:GetStyle("tributeBodyText"))

                    mechanicsProcessed = mechanicsProcessed + 1
                    if mechanicsProcessed == numMechanics then
                        self:AddSection(comboSection)
                        break
                    end
                end
            end
            if mechanicsProcessed == numMechanics then
                break
            end
        end
    end

    -- Flags
    if cardData:DoesTaunt() then
        local section = self:AcquireSection(self:GetStyle("bodySection"))
        section:AddLine(GetString(SI_TRIBUTE_CARD_TAUNT_TITLE), self:GetStyle("bodyHeader"))
        section:AddLine(GetString(SI_TRIBUTE_CARD_TAUNT_DESCRIPTION), self:GetStyle("tributeBodyText"))
        self:AddSection(section)
    end

    if isContract then
        local section = self:AcquireSection(self:GetStyle("bodySection"))
        section:AddLine(GetString(SI_TRIBUTE_CARD_CONTRACT_DESCRIPTION), self:GetStyle("tributeBodyText"))
        self:AddSection(section)
    elseif isCurse then
        local section = self:AcquireSection(self:GetStyle("bodySection"))
        section:AddLine(GetString(SI_TRIBUTE_CARD_CURSE_DESCRIPTION), self:GetStyle("tributeBodyText"))
        self:AddSection(section)
    end

    -- Flavor Text
    local flavorText = cardData:GetFlavorText()
    if flavorText ~= "" then
        local section = self:AcquireSection(self:GetStyle("bodySection"))
        section:AddLine(zo_strformat(GetString(SI_TRIBUTE_CARD_TEXT_FORMATTER), cardData:GetFlavorText()), self:GetStyle("tributeBodyText"))
        self:AddSection(section)
    end

    -- Upgrade Information
    -- If the context has an upgradesTo, that means it's a base card, it has an upgrade, and we do not currently have the upgrade unlocked
    if optionalDockCardUpgradeContext and optionalDockCardUpgradeContext.upgradesTo then
        local section = self:AcquireSection(self:GetStyle("bodySection"))
        local upgradesToCardData = ZO_TributeCardData:New(cardData:GetPatronDefId(), optionalDockCardUpgradeContext.upgradesTo)
        section:AddLine(GetString(SI_TRIBUTE_PATRON_UPGRADE_TITLE), self:GetStyle("bodyHeader"))
        section:AddLine(zo_strformat(GetString(SI_TRIBUTE_CARD_AVAILABLE_UPGRADE_FORMATTER), cardData:GetColorizedName(), upgradesToCardData:GetColorizedName()), self:GetStyle("tributeBodyText"))
        section:AddLine(GetTributeCardUpgradeHintText(cardData:GetPatronDefId(), optionalDockCardUpgradeContext.cardIndex), self:GetStyle("tributeBodyText"))
        self:AddSection(section)
    end
end

function ZO_Tooltip:LayoutTributePatronFavorStateInfo(patronData, favorState, useDesaturatedText)
    local requirementsText = patronData:GetRequirementsText(favorState)
    local mechanicsText = patronData:GetMechanicsText(favorState)
    if requirementsText ~= "" and mechanicsText ~= "" then
        local favorSection = self:AcquireSection(self:GetStyle("bodySection"))

        --Layout the title of the favor state
        local favorText = GetString("SI_TRIBUTEPATRONPERSPECTIVEFAVORSTATE", favorState)
        local colorStyle = useDesaturatedText and self:GetStyle("tributeDisabledMechanicText") or nil

        if favorState == TRIBUTE_PATRON_PERSPECTIVE_FAVOR_STATE_FAVORS_PLAYER then
            favorSection:AddLine(favorText, colorStyle or self:GetStyle("succeeded"), self:GetStyle("bodyHeader"))
        elseif favorState == TRIBUTE_PATRON_PERSPECTIVE_FAVOR_STATE_NEUTRAL then
            favorSection:AddLine(favorText, colorStyle, self:GetStyle("bodyHeader"))
        elseif favorState == TRIBUTE_PATRON_PERSPECTIVE_FAVOR_STATE_FAVORS_OPPONENT then
            favorSection:AddLine(favorText, colorStyle or self:GetStyle("failed"), self:GetStyle("bodyHeader"))
        else
            internalassert(false, "Unsupported Favor State")
        end

        local resultText = ""

        --Do not include the result string for neutral patrons
        if not patronData:IsNeutral() then
            local displayFavorState = favorState
            if patronData:DoesSkipNeutralFavorState() and favorState == TRIBUTE_PATRON_PERSPECTIVE_FAVOR_STATE_FAVORS_OPPONENT then
                displayFavorState = TRIBUTE_PATRON_PERSPECTIVE_FAVOR_STATE_NEUTRAL
            end
            resultText = GetString("SI_TRIBUTEPATRONPERSPECTIVEFAVORSTATE_RESULT", displayFavorState)
        end

        local formatterStringId = useDesaturatedText and SI_TRIBUTE_PATRON_TOOLTIP_FAVOR_DESCRIPTION_DISABLED_FORMATTER or SI_TRIBUTE_PATRON_TOOLTIP_FAVOR_DESCRIPTION_FORMATTER
        favorSection:AddLine(zo_strformat(GetString(formatterStringId), requirementsText, mechanicsText, resultText), colorStyle or self:GetStyle("whiteFontColor"), self:GetStyle("bodyDescription"))
        self:AddSection(favorSection)
    end
end

function ZO_Tooltip:LayoutTributePatron(patronData, optionalArgs)
    local highlightActivePatronState = optionalArgs and optionalArgs.highlightActivePatronState or false
    local suppressNotCollectibleWarning = optionalArgs and optionalArgs.suppressNotCollectibleWarning or false

    -- Header
    local topSection = self:AcquireSection(self:GetStyle("collectionsTopSection"))
    topSection:AddLine(GetString(SI_TRIBUTE_PATRON_TYPE))
    local collectionId = patronData:GetPatronCollectibleId()
    if patronData:IsNeutral() then
        topSection:AddLine(GetString("SI_TRIBUTEPATRONPERSPECTIVEFAVORSTATE", TRIBUTE_PATRON_PERSPECTIVE_FAVOR_STATE_NEUTRAL))
    else
        --Neutral patrons should never be collectible
        if collectionId ~= 0 then
            topSection:AddLine(GetString("SI_COLLECTIBLEUNLOCKSTATE", GetCollectibleUnlockStateById(collectionId)))
        end
    end
    self:AddSection(topSection)

    -- Title
    local titleSection = self:AcquireSection(self:GetStyle("title"))
    local itemDisplayQuality = patronData:GetRarity()
    local qualityColor = GetItemQualityColor(itemDisplayQuality)
    titleSection:AddLine(patronData:GetFormattedName(), { fontColor = qualityColor })
    self:AddSection(titleSection)

    local currentFavorState = nil
    if highlightActivePatronState and TRIBUTE.GetGameFlowState and TRIBUTE:GetGameFlowState() ~= TRIBUTE_GAME_FLOW_STATE_INACTIVE then
        -- Highlight the active Favor state only if requested and if a Tribute game is currently active.
        local patronStall = TRIBUTE:GetPatronStallByPatronId(patronData:GetId())
        if patronStall then
            currentFavorState = patronStall:GetCurrentFavorState()
        end
    end

    do
        local useDesaturatedText

        useDesaturatedText = currentFavorState and currentFavorState ~= TRIBUTE_PATRON_PERSPECTIVE_FAVOR_STATE_FAVORS_PLAYER or false
        self:LayoutTributePatronFavorStateInfo(patronData, TRIBUTE_PATRON_PERSPECTIVE_FAVOR_STATE_FAVORS_PLAYER, useDesaturatedText)

        useDesaturatedText = currentFavorState and currentFavorState ~= TRIBUTE_PATRON_PERSPECTIVE_FAVOR_STATE_NEUTRAL or false
        self:LayoutTributePatronFavorStateInfo(patronData, TRIBUTE_PATRON_PERSPECTIVE_FAVOR_STATE_NEUTRAL, useDesaturatedText)

        useDesaturatedText = currentFavorState and currentFavorState ~= TRIBUTE_PATRON_PERSPECTIVE_FAVOR_STATE_FAVORS_OPPONENT or false
        self:LayoutTributePatronFavorStateInfo(patronData, TRIBUTE_PATRON_PERSPECTIVE_FAVOR_STATE_FAVORS_OPPONENT, useDesaturatedText)
    end

    -- Body
    local bodySection = self:AcquireSection(self:GetStyle("bodySection"))
    bodySection:AddLine(patronData:GetLoreDescription(), self:GetStyle("bodyDescription"))
    self:AddSection(bodySection)

    local infoSection = self:AcquireSection(self:GetStyle("bodySection"))
    if collectionId == 0 and not suppressNotCollectibleWarning then
        infoSection:AddLine(GetString(SI_TRIBUTE_PATRON_TOOLTIP_NO_COLLECTIBLE), self:GetStyle("bodyDescription"), self:GetStyle("failed"))
    end
    self:AddSection(infoSection)
end

function ZO_Tooltip:LayoutTributeBoardLocationPatrons(boardLocationData)
    if boardLocationData:GetNumCards() == 0 then
        return
    end

    do
        local titleSection = self:AcquireSection(self:GetStyle("title"))
        local displayName = boardLocationData:GetName()
        titleSection:AddLine(displayName)
        self:AddSection(titleSection)
    end

    do
        local patronsSection = self:AcquireSection(self:GetStyle("bodySection"))
        local patronCardCountList = boardLocationData:GetPatronCardCountList()
        for _, patronCardCountData in ipairs(patronCardCountList) do
            local numCards = patronCardCountData.numCards
            local patronSuitIcon = patronCardCountData.patronData:GetPatronSuitIcon()
            local patronName = patronCardCountData.patronData:GetFormattedName()
            patronsSection:AddLine(zo_strformat(GetString(SI_TRIBUTE_PATRON_NAME_WITH_COUNT_AND_SUIT_ICON_FORMATTER), numCards, patronSuitIcon, patronName), self:GetStyle("whiteFontColor"), self:GetStyle("bodyDescription"))
        end
        self:AddSection(patronsSection)
    end
end

function ZO_Tooltip:LayoutTributeResource(resource)
    local titleSection = self:AcquireSection(self:GetStyle("title"))
    titleSection:AddLine(zo_strformat(SI_TRIBUTE_RESOURCE_NAME_FORMATTER, GetString("SI_TRIBUTERESOURCE", resource)))
    self:AddSection(titleSection)

    local bodySection = self:AcquireSection(self:GetStyle("bodySection"))
    bodySection:AddLine(GetString("SI_TRIBUTERESOURCE_TOOLTIP", resource), self:GetStyle("bodyDescription"))
    self:AddSection(bodySection)
end

function ZO_Tooltip:LayoutTributeDiscardCounter()
    local titleSection = self:AcquireSection(self:GetStyle("title"))
    titleSection:AddLine(GetString(SI_TRIBUTE_DISCARD_COUNTER_TOOLTIP_TITLE))
    self:AddSection(titleSection)

    local bodySection = self:AcquireSection(self:GetStyle("bodySection"))
    bodySection:AddLine(GetString(SI_TRIBUTE_DISCARD_COUNTER_TOOLTIP_DESCRIPTION), self:GetStyle("bodyDescription"))
    self:AddSection(bodySection)
end