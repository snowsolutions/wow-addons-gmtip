-- =========================
-- Init SavedVariables
-- =========================
GMTipTemplates = GMTipTemplates or {}

-- =========================
-- Tooltip: Show ItemID
-- =========================
local function AddItemID(tooltip)
    local _, link = tooltip:GetItem()
    if link then
        local itemId = tonumber(string.match(link, "item:(%d+)"))
        if itemId then
            tooltip:AddLine("ItemID: " .. itemId, 0.5, 0.8, 1)
        end
    end
end
GameTooltip:HookScript("OnTooltipSetItem", AddItemID)
ItemRefTooltip:HookScript("OnTooltipSetItem", AddItemID)

-- Add SpellID to tooltip in 3.3.5
GameTooltip:HookScript("OnTooltipSetSpell", function(self)
    local name, rank, spellID = self:GetSpell()
    if spellID then
        self:AddLine("Spell ID: "..spellID, 0.6, 0.8, 1)
        self:Show()
    end
end)



-- =========================
-- Create Item Popup
-- =========================
GMTipPopup = CreateFrame("Frame", "GMTipPopup", UIParent)
GMTipPopup:SetSize(430, 140)
GMTipPopup:SetPoint("CENTER")
GMTipPopup:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
GMTipPopup:SetBackdropColor(0, 0, 0, 1)
GMTipPopup:Hide()

GMTipEditBox = CreateFrame("EditBox", "GMTipEditBox", GMTipPopup, "InputBoxTemplate")
GMTipEditBox:SetSize(350, 30)
GMTipEditBox:SetPoint("TOP", 0, -20)
GMTipEditBox:SetAutoFocus(false)

-- =========================
-- Helper: Add items
-- =========================
local function AddItemsFromText(text)
    for entry in string.gmatch(text, '([^,]+)') do
        local id, count = string.match(entry, '^(%d+)x(%d+)$')
        if not id then id, count = string.match(entry, '^(%d+)$'), "1" end
        if id then
            for i=1, tonumber(count) do
                SendChatMessage(".additem " .. id, "SAY")
            end
        end
    end
end

-- =========================
-- Buttons in popup
-- =========================
local addBtn = CreateFrame("Button", nil, GMTipPopup, "UIPanelButtonTemplate")
addBtn:SetSize(80, 25)
addBtn:SetText("Add")
addBtn:SetPoint("BOTTOMLEFT", GMTipPopup, "BOTTOMLEFT", 15, 15)
addBtn:SetScript("OnClick", function()
    local text = GMTipEditBox:GetText()
    if text and text ~= "" then
        AddItemsFromText(text)
    end
    GMTipPopup:Hide()
end)

-- Save Only
local saveOnlyBtn = CreateFrame("Button", nil, GMTipPopup, "UIPanelButtonTemplate")
saveOnlyBtn:SetSize(100, 25)
saveOnlyBtn:SetText("Save Only")
saveOnlyBtn:SetPoint("LEFT", addBtn, "RIGHT", 10, 0)
saveOnlyBtn:SetScript("OnClick", function()
    local text = GMTipEditBox:GetText()
    if text and text ~= "" then
        StaticPopupDialogs["GMTIP_ENTER_TEMPLATE_NAME"] = {
            text = "Enter template name:",
            button1 = "Save",
            button2 = "Cancel",
            hasEditBox = true,
            OnAccept = function(self)
                local name = self.editBox:GetText()
                if name and name ~= "" then
                    GMTipTemplates[name] = text
                    print("|cff00ff00GMTip: Saved template '"..name.."' (Save Only)")
                end
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true
        }
        StaticPopup_Show("GMTIP_ENTER_TEMPLATE_NAME")
    end
    GMTipPopup:Hide()
end)

-- Save & Add
local saveAddBtn = CreateFrame("Button", nil, GMTipPopup, "UIPanelButtonTemplate")
saveAddBtn:SetSize(100, 25)
saveAddBtn:SetText("Save & Add")
saveAddBtn:SetPoint("LEFT", saveOnlyBtn, "RIGHT", 10, 0)
saveAddBtn:SetScript("OnClick", function()
    local text = GMTipEditBox:GetText()
    if text and text ~= "" then
        AddItemsFromText(text)
        StaticPopupDialogs["GMTIP_ENTER_TEMPLATE_NAME"] = {
            text = "Enter template name:",
            button1 = "Save",
            button2 = "Cancel",
            hasEditBox = true,
            OnAccept = function(self)
                local name = self.editBox:GetText()
                if name and name ~= "" then
                    GMTipTemplates[name] = text
                    print("|cff00ff00GMTip: Saved template '"..name.."' (Save & Add)")
                end
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true
        }
        StaticPopup_Show("GMTIP_ENTER_TEMPLATE_NAME")
    end
    GMTipPopup:Hide()
end)

-- Close
local closeBtn = CreateFrame("Button", nil, GMTipPopup, "UIPanelButtonTemplate")
closeBtn:SetSize(80, 25)
closeBtn:SetText("Close")
closeBtn:SetPoint("LEFT", saveAddBtn, "RIGHT", 10, 0)
closeBtn:SetScript("OnClick", function() GMTipPopup:Hide() end)

-- =========================
-- Create Item button (draggable)
-- =========================
GMTipCreateBtn = CreateFrame("Button", "GMTipCreateBtn", UIParent, "UIPanelButtonTemplate")
GMTipCreateBtn:SetSize(100, 25)
GMTipCreateBtn:SetText("Create Item")
GMTipCreateBtn:SetPoint("CENTER", UIParent, "CENTER", 0, 200)

GMTipCreateBtn:SetMovable(true)
GMTipCreateBtn:EnableMouse(true)
GMTipCreateBtn:RegisterForDrag("LeftButton")
GMTipCreateBtn:SetScript("OnDragStart", function(self) self:StartMoving() end)
GMTipCreateBtn:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

GMTipCreateBtn:SetScript("OnClick", function()
    GMTipPopup:Show()
    GMTipEditBox:SetFocus()
end)

-- =========================
-- Alt+Click item ID
-- =========================
hooksecurefunc("HandleModifiedItemClick", function(link)
    if IsAltKeyDown() and link and GMTipEditBox and GMTipPopup:IsShown() then
        local itemId = tonumber(string.match(link, "item:(%d+)"))
        if not itemId then return end

        local current = GMTipEditBox:GetText() or ""
        current = strtrim(current)

        local entries, found = {}, false
        for entry in string.gmatch(current, '([^,]+)') do
            entry = strtrim(entry)
            if entry ~= "" then
                local id, count = string.match(entry, '^(%d+)x(%d+)$')
                if not id then id, count = string.match(entry, '^(%d+)$'), "1" end
                if tonumber(id) == itemId then
                    count = tostring(tonumber(count) + 1)
                    found = true
                end
                table.insert(entries, id .. (tonumber(count) > 1 and ("x"..count) or ""))
            end
        end
        if not found then table.insert(entries, tostring(itemId)) end
        GMTipEditBox:SetText(table.concat(entries, ","))
        GMTipEditBox:SetFocus()
        GMTipEditBox:SetCursorPosition(strlen(GMTipEditBox:GetText()))
    end
end)
