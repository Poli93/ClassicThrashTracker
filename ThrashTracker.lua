--[[
Idan Dayan (Idanqt-Discord) (Jarjkem-HydraxianWaterlords)

Tracks and displays Thrash procs on creatures.
    - from resting I've done it appears Thrash can only stack up to 2 and can proc off itself.

* Some monsters have a “Thrash” mechanic and can proc multiple attacks against players in a very short duration.
    Note: Most of these monsters can also “store” these procs and unleash them all several seconds later. 
    An example of this is the Princess Theradras encounter in Maraudon. 
    The Princess will store her attacks if kited and can land several attacks instantly when she catches up to her target. This behavior is consistent with the reference client

TODO:
-- Filter off friendly nameplates
-- Don't affect nameplates NOT IN COMBAT UnitAffectingCombat(unit)
--]]
local addon, ThrashTracker = ... 
local IDTHRSH_TEXT = "|cff69CCF0ThrashTracker|r: "
local IDTHRSH_VERSION = "0.9"
print(IDTHRSH_TEXT .."Classic Thrash Tracker, version " ..IDTHRSH_VERSION)
local frame = CreateFrame("Frame")
local thrashCount = {}
local DefaultThrashText = "THRASH USED!"
local spell = "Thrash" -- debugs
local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit

function ThrashTrackerDefaults()
	ThrashTrackerOptions["displayTextShown"] = true
    ThrashTrackerOptions["IconSize"] = 16
    ThrashTrackerOptions["nameplateXpos"] = -15
    ThrashTrackerOptions["nameplateYpos"] = 0
    ThrashTrackerOptions["ThrashText"] = DefaultThrashText -- RAW VALUE HERE OR OUTSIDE?
    ThrashTrackerOptions["ThrashTextScale"] = 1.0
    print(IDTHRSH_TEXT .. " Settings reset to default.")
end

--local db = {} -- option settings
--local unitMap = {}
-- local UnitMap = {UnitGUID, thrashCount} -- ??
-- unitMap[UnitGUID] = thrashCount


SLASH_IDTHRSH1 = "/thrashtracker"
SLASH_IDTHRSH2 = "/thrash"
SlashCmdList["IDTHRSH"] = function(msg)
	print(IDTHRSH_TEXT .."Classic Thrash Tracker, version " ..IDTHRSH_VERSION)
end 

SLASH_ARRAYPRINT1 = "/printarray"
SlashCmdList["ARRAYPRINT"] = function(msg)
    for unitGUID, count in pairs(thrashCount) do
        print("UnitGUID: " .. unitGUID .. " - Count: " .. count)
    end
end 

------------------------------------------------------
-- PANELS
------------------------------------------------------
local panel = CreateFrame("Frame")
panel.name = addon              
InterfaceOptions_AddCategory(panel)  

panel.title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
panel.title:SetPoint("TOPLEFT", 16, -16)
panel.title:SetText(panel.name)

panel.credit = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
panel.credit:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, -8)
panel.credit:SetText("Author: Idan")

panel.version = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
panel.version:SetPoint("TOPLEFT", panel.credit, "BOTTOMLEFT", 0, -5)
panel.version:SetText("Version: " .. IDTHRSH_VERSION)

--[[ -- seems to be no use?
panel.okay = 
		function (self)
			--self.ThrashText = DefaultThrashText;
            print("button okay is okay, how are you?")
		end

panel.cancel =
		function (self)
			--ThrashText = self.originalValue;
            print("button cancel was cancelled, u r not nice")
		end
]]

panel.default = function (self)
    ThrashTrackerDefaults()
    ThrashTrackerPanels()
end     

panel.ShowHideCheckButton = CreateFrame("CheckButton", "ThrashTrackerShowHideCheckButton", panel, "ChatConfigCheckButtonTemplate")
panel.ShowHideCheckButton.tooltipText = "Show/Hide Thrash Used!"
_G["ThrashTrackerShowHideCheckButtonText"]:SetText(" Show 'Thrash Used!' Popup");
panel.ShowHideCheckButton:SetPoint("TOPLEFT", panel.credit, "BOTTOMLEFT", 0, -40)


panel.IconSizeSlider = CreateFrame("Slider", "ThrashTrackerIconSizeSlider", panel, "OptionsSliderTemplate")
panel.IconSizeSlider:SetOrientation('HORIZONTAL')
panel.IconSizeSlider.tooltipText = 'Size of the Thrash icon'
_G["ThrashTrackerIconSizeSliderHigh"]:SetText("40");
_G["ThrashTrackerIconSizeSliderLow"]:SetText("5");
panel.IconSizeSlider:SetPoint("TOPLEFT", panel.ShowHideCheckButton, "BOTTOMLEFT", 0, -20)
panel.IconSizeSlider:SetMinMaxValues(5,40)
panel.IconSizeSlider:SetValueStep(1)
panel.IconSizeSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")

panel.PlateXSlider = CreateFrame("Slider", "ThrashTrackerPlateXSlider", panel, "OptionsSliderTemplate")
panel.PlateXSlider:SetOrientation('HORIZONTAL')
panel.PlateXSlider.tooltipText = 'Nameplate Icon Horizontal Position'
_G["ThrashTrackerPlateXSliderHigh"]:SetText("50");
_G["ThrashTrackerPlateXSliderLow"]:SetText("-50");
panel.PlateXSlider:SetPoint("TOPLEFT", panel.IconSizeSlider, "BOTTOMLEFT", 0, -26)
panel.PlateXSlider:SetMinMaxValues(-50,50)
panel.PlateXSlider:SetValueStep(1)
panel.PlateXSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")

panel.PlateYSlider = CreateFrame("Slider", "ThrashTrackerPlateYSlider", panel, "OptionsSliderTemplate")
panel.PlateYSlider:SetOrientation('HORIZONTAL')
panel.PlateYSlider.tooltipText = 'Nameplate Icon Vertical Position'
_G["ThrashTrackerPlateYSliderHigh"]:SetText("50");
_G["ThrashTrackerPlateYSliderLow"]:SetText("-50");
panel.PlateYSlider:SetPoint("TOPLEFT", panel.PlateXSlider, "BOTTOMLEFT", 0, -26)
--panel.PlateYSlider:SetHeight(110) 
--panel.PlateYSlider:SetWidth(10) 
panel.PlateYSlider:SetMinMaxValues(-50,50)
panel.PlateYSlider:SetValueStep(1)
panel.PlateYSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")

panel.EditBoxButton = CreateFrame("Button", "ThrashTrackerEditBoxButton", panel, "UIPanelButtonTemplate");
panel.EditBoxButton:SetSize(144,22)
_G["ThrashTrackerEditBoxButtonText"]:SetText("Edit Thrash Used Text");
panel.EditBoxButton:SetPoint("TOPLEFT", panel.credit, "BOTTOMLEFT", 300, -40);

panel.ThrashTextSlider = CreateFrame("Slider", "ThrashTrackerThrashTextSlider", panel, "OptionsSliderTemplate")
panel.ThrashTextSlider:SetOrientation('HORIZONTAL')
panel.ThrashTextSlider.tooltipText = 'Thrash Text Scale %'
_G["ThrashTrackerThrashTextSliderHigh"]:SetText("200");
_G["ThrashTrackerThrashTextSliderLow"]:SetText("50");
panel.ThrashTextSlider:SetPoint("TOPLEFT", panel.EditBoxButton, "BOTTOMLEFT", 0, -26)
panel.ThrashTextSlider:SetMinMaxValues(50,200)
panel.ThrashTextSlider:SetValueStep(1)
panel.ThrashTextSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

-- Event handler for COMBAT_LOG_EVENT_UNFILTERED
function OnCombatLogEventUnfiltered()
    local timestamp, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellId, spellName = CombatLogGetCurrentEventInfo()

    if (subevent == "SPELL_EXTRA_ATTACKS" and spellName == spell) then
        if sourceGUID then
            local unitGUID = sourceGUID    

            if unitGUID then
                if not thrashCount[unitGUID] then 
                    thrashCount[unitGUID] = 1
                elseif thrashCount[unitGUID] < 2 then
                    thrashCount[unitGUID] = thrashCount[unitGUID] + 1 
                end
            end
                    -- in or out?
                    local unit = nil
                    local guid = nil
                    for i, nameplate in ipairs(C_NamePlate.GetNamePlates()) do
                        unit = nameplate.namePlateUnitToken
                        guid = UnitGUID(unit)
                        if guid and guid == unitGUID and unit then 
                            if not thrashCount[unitGUID] then
                                UpdateNameplateIconAndText(unit, thrashCount[unitGUID])
                                print("print first stack on " .. unitGUID)
                            else
                                 --thrashCount[unitGUID] = thrashCount[unitGUID] + 1
                                 UpdateNameplateIconAndText(unit, thrashCount[unitGUID])
                                 print("print adding stack " .. thrashCount[unitGUID] .. " on " .. unitGUID)
                            end
                            break
                        end
                end
            end 
    elseif (subevent == "SWING_DAMAGE" or subevent == "SWING_MISSED" or subevent == "SWING_ABSORBED") then
        if sourceGUID and thrashCount[sourceGUID] then
            local unitGUID = sourceGUID
            thrashCount[sourceGUID] = nil
            -- in or out?
            local unit = nil
            local guid = nil
                for i, nameplate in ipairs(C_NamePlate.GetNamePlates()) do
                    unit = nameplate.namePlateUnitToken
                    guid = UnitGUID(unit)
                    if guid == unitGUID then
                        displayText(nameplate)
                        UpdateNameplateIconAndText(unit, thrashCount[unitGUID])
                    end
            end
    end
    elseif (subevent == "UNIT_DIED") then -- or PARTY_KILL?
        local unitGUID = destGUID
        if unitGUID and thrashCount[unitGUID] then
            thrashCount[unitGUID] = nil
        end
    end
end

-- occurances where displayText persists to show after creature has died and another respawns with same nameplate
function displayText(nameplate)
    if ThrashTrackerOptions["displayTextShown"] == false then return end
        if not textFrame then
            local textFrame = CreateFrame("Frame", nil, nameplate)
            textFrame:SetAllPoints(nameplate)
            textFrame:SetPoint("BOTTOM", nameplate, "TOP", 0, -75) 

            local textString = textFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            textString:SetAllPoints(textFrame)
            textString:SetText(ThrashTrackerOptions["ThrashText"])
            textString:SetScale(ThrashTrackerOptions["ThrashTextScale"])

            C_Timer.After(2, function()
                textFrame:Hide()
            end)
        end
    end


function UpdateNameplateIconAndText(unit, count)
    if not unit then return end

    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if nameplate:IsForbidden() then return end

    local unitGUID = UnitGUID(unit)
    if nameplate and thrashCount[unitGUID] and not nameplate.icon then 
        nameplate.icon = nameplate:CreateTexture(nil, "OVERLAY")
        nameplate.icon:SetTexture("Interface\\Icons\\Ability_GhoulFrenzy")
        nameplate.icon:SetPoint("TOPLEFT", nameplate, "TOPLEFT", ThrashTrackerOptions["nameplateXpos"], ThrashTrackerOptions["nameplateYpos"])
        nameplate.icon:SetSize(ThrashTrackerOptions["IconSize"], ThrashTrackerOptions["IconSize"])

        nameplate.text = nameplate:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        nameplate.text:SetPoint("RIGHT", nameplate.icon, "LEFT", 0, 0)
        -- Update the icon and text (outside if or inside?)
    end
    nameplate.icon:Show()
    nameplate.text:SetText(count)
    nameplate.text:Show()

    if nameplate and not thrashCount[unitGUID] and nameplate.icon then
        nameplate.icon:Hide()
        nameplate.text:Hide()
    end

end

-- TODO: add filtering only for enemynameplates
-- Event handler for NAME_PLATE_UNIT_ADDED
function OnNameplateUnitAdded(unit)
    if not unit then return end

    local unitGUID = UnitGUID(unit)
    if not unitGUID then return end

    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if nameplate:IsForbidden() then return end

    -- ADD IF ICON EXISTS BUT NO THRASH THEN REMOVE ICON?
    if nameplate.icon and not thrashCount[unitGUID] then
        nameplate.icon:Hide()
        nameplate.text:Hide()
    end

    if nameplate and thrashCount[unitGUID] then
        if thrashCount[unitGUID] then 
            UpdateNameplateIconAndText(unit, thrashCount[unitGUID])
        end
    end
end

-- Event handler for NAME_PLATE_UNIT_REMOVED
function OnNameplateUnitRemoved(unit)
	if not unit then return end

    local unitGUID = UnitGUID(unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit);
    
    -- ADD ICON REMOVALS ALWAYS AND READ THEM BACK INSIDE THE ADDED FUNC IF NECESSARY?
    if nameplate and thrashCount[unitGUID] then
            if (thrashCount[unitGUID] < 1) then
            thrashCount[unitGUID] = nil
            if nameplate.icon then
                nameplate.icon:Hide()
                nameplate.text:Hide()
            end    
        end
    end
end

function OnAddonLoaded(...)
    if ... == addon then
        -- initialize options
        if ThrashTrackerOptions == nil or ThrashTrackerOptions["displayTextShown"] == nil or ThrashTrackerOptions["displayTextShown"] == nil or ThrashTrackerOptions["IconSize"] == nil or ThrashTrackerOptions["nameplateXpos"] == nil or ThrashTrackerOptions["nameplateYpos"] == nil or ThrashTrackerOptions["ThrashText"] == nil or ThrashTrackerOptions["ThrashTextScale"] == nil then
            ThrashTrackerOptions = {} 
            ThrashTrackerDefaults()
        end
        panel.ShowHideCheckButton:SetScript("OnClick", function(self)
            local checked = self:GetChecked()
            if checked then
                ThrashTrackerOptions["displayTextShown"] = true
            else
                ThrashTrackerOptions["displayTextShown"] = false
            end
        end)
        panel.IconSizeSlider:SetScript("OnValueChanged", function(self, newvalue)
			newvalue = floor(newvalue+0.5)
			ThrashTrackerOptions["IconSize"] = newvalue
			_G["ThrashTrackerIconSizeSliderText"]:SetText("Icon Size ("..newvalue..")");
			panel.IconSizeSlider:SetValue(newvalue)
		end)
        panel.PlateXSlider:SetScript("OnValueChanged", function(self, newvalue)
			newvalue = floor(newvalue+0.5)
			ThrashTrackerOptions["nameplateXpos"] = newvalue
			_G["ThrashTrackerPlateXSliderText"]:SetText("Horizontal Position ("..newvalue..")");
			panel.PlateXSlider:SetValue(newvalue)
		end)
        panel.PlateYSlider:SetScript("OnValueChanged", function(self, newvalue)
			newvalue = floor(newvalue+0.5)
			ThrashTrackerOptions["nameplateYpos"] = newvalue
			_G["ThrashTrackerPlateYSliderText"]:SetText("Vertical Position ("..newvalue..")");
			panel.PlateYSlider:SetValue(newvalue)
		end)
        panel.ThrashTextSlider:SetScript("OnValueChanged", function(self, newvalue)
			newvalue = floor(newvalue+0.5)
			ThrashTrackerOptions["ThrashTextScale"] = (newvalue/100)
			_G["ThrashTrackerThrashTextSliderText"]:SetText("Thrash Text Scale ("..newvalue..")");
			panel.ThrashTextSlider:SetValue(newvalue)
		end)
        panel.EditBoxButton:SetScript("OnClick",function(self)
            StaticPopup_Show("SetTextPopup")
        end)
        ThrashTrackerPanels()
    end
end

function ThrashTrackerPanels()
    panel.ShowHideCheckButton:SetChecked(ThrashTrackerOptions["displayTextShown"]) 
    panel.IconSizeSlider:SetValue(ThrashTrackerOptions["IconSize"])
    panel.PlateXSlider:SetValue(ThrashTrackerOptions["nameplateXpos"])
    panel.PlateYSlider:SetValue(ThrashTrackerOptions["nameplateYpos"])
    panel.ThrashTextSlider:SetValue((ThrashTrackerOptions["ThrashTextScale"]*100))

    _G["ThrashTrackerIconSizeSliderText"]:SetText("Icon Size ("..ThrashTrackerOptions["IconSize"]..")");
    _G["ThrashTrackerPlateXSliderText"]:SetText("Horizontal Position ("..ThrashTrackerOptions["nameplateXpos"]..")");
    _G["ThrashTrackerPlateYSliderText"]:SetText("Vertical Position ("..ThrashTrackerOptions["nameplateYpos"]..")");
    _G["ThrashTrackerThrashTextSliderText"]:SetText("Thrash Text Scale ("..(ThrashTrackerOptions["ThrashTextScale"]*100)..")");
    _G["ThrashTrackerEditBoxButtonText"]:SetText("Edit Thrash Used Text");
end


StaticPopupDialogs.SetTextPopup = {
    text = "Enter 'Thrash Used!' Text:",
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function(self)
        ThrashTrackerOptions["ThrashText"] = self.editBox:GetText()
        print("Popup-Click Updated Thrash Text to: " .. ThrashTrackerOptions["ThrashText"])
    end,
    OnEnterPressed = function(self)
        ThrashTrackerOptions["ThrashText"] = self.editBox:GetText()
        print("Popup-Enter Updated Thrash Text to: " .. ThrashTrackerOptions["ThrashText"])
    end,
    hasEditBox = 1,
    hideOnEscape = true,
}

-- Register events
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(_, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        OnCombatLogEventUnfiltered(...)
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        OnNameplateUnitAdded(...)
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        OnNameplateUnitRemoved(...)
    elseif event == "ADDON_LOADED" then
        OnAddonLoaded(...)
    end
end)