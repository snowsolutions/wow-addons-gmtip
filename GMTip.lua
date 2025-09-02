-- =========================
-- Init SavedVariables
-- =========================
GMTipTemplates = GMTipTemplates or {}

-- =========================
-- Tooltip: Show ItemID & SpellID (Retail 11.x)
-- =========================
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
    if data and data.id then
        tooltip:AddLine("ItemID: " .. data.id, 0.5, 0.8, 1)
    end
end)

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, function(tooltip, data)
    if data and data.id then
        tooltip:AddLine("SpellID: " .. data.id, 0.6, 0.8, 1)
    end
end)

-- =========================
-- Create Item Popup
-- =========================
GMTipPopup = CreateFrame("Frame", "GMTipPopup", UIParent, "BackdropTemplate")
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
        entry = strtrim(entry)
        if entry ~= "" then
            -- Case 1: range 1000->1005
            local fromID, toID = string.match(entry, '^(%d+)%-%>(%d+)$')
            if fromID and toID then
                fromID, toID = tonumber(fromID), tonumber(toID)
                if fromID <= toID then
                    for id = fromID, toID do
                        SendChatMessage(".additem " .. id, "SAY")
                    end
                else
                    for id = fromID, toID, -1 do
                        SendChatMessage(".additem " .. id, "SAY")
                    end
                end

            -- Case 2: id with count 1234x5
            else
                local id, count = string.match(entry, '^(%d+)x(%d+)$')
                if not id then id, count = string.match(entry, '^(%d+)$'), "1" end
                if id then
                    for i=1, tonumber(count) do
                        SendChatMessage(".additem " .. id, "SAY")
                    end
                end
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
                local editBox = self.editBox or _G[self:GetName().."EditBox"]
                local name = editBox and editBox:GetText()
                if name and name ~= "" then
                    GMTipTemplates[name] = text
                    print("|cff00ff00GMTip: Saved template '"..name.."' (Save Only)")
                end
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
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
                local editBox = self.editBox or _G[self:GetName().."EditBox"]
                local name = editBox and editBox:GetText()
                if name and name ~= "" then
                    GMTipTemplates[name] = text
                    print("|cff00ff00GMTip: Saved template '"..name.."' (Save & Add)")
                end
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
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

GMTipCreateBtn:Show()

-- =========================
-- Alt+Click item ID (stackable)
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
        GMTipEditBox:SetCursorPosition(string.len(GMTipEditBox:GetText()))
    end
end)
