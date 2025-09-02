-- =========================
-- Items Template Manager
-- =========================
GMTipTemplates = GMTipTemplates or {}

-- Popup danh sách template
local templatePopup = CreateFrame("Frame", "GMTipTemplatePopup", UIParent, "BackdropTemplate")
templatePopup:SetSize(400, 300)
templatePopup:SetPoint("CENTER")
templatePopup:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
templatePopup:SetBackdropColor(0,0,0,1)
templatePopup:Hide()

-- ScrollFrame
local scrollFrame = CreateFrame("ScrollFrame", "GMTipTemplateScrollFrame", templatePopup, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 10, -10)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 40) -- chừa chỗ cho nút Close

-- Nội dung trong scroll
local content = CreateFrame("Frame", "GMTipTemplateContent", scrollFrame)
content:SetSize(1,1) -- sẽ được nới ra khi add item
scrollFrame:SetScrollChild(content)

-- Hàm render danh sách template
local function UpdateTemplateList()
    for _,child in ipairs({content:GetChildren()}) do child:Hide() end

    local offset = -10
    for name, list in pairs(GMTipTemplates) do
        local f = CreateFrame("Frame", nil, content)
        f:SetSize(340, 25)
        f:SetPoint("TOPLEFT", 0, offset)
        offset = offset - 30

        local txt = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        txt:SetPoint("LEFT")
        txt:SetText(name)

        -- Nút Get
        local getBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        getBtn:SetSize(60, 20)
        getBtn:SetText("Get")
        getBtn:SetPoint("RIGHT", -65, 0)
        getBtn:SetScript("OnClick", function()
            for entry in string.gmatch(list, '([^,]+)') do
                local id, count = string.match(entry, '^(%d+)x(%d+)$')
                if not id then id, count = string.match(entry, '^(%d+)$'), "1" end
                if id then
                    for i=1, tonumber(count) do
                        SendChatMessage(".additem " .. id, "SAY")
                    end
                end
            end
        end)

        -- Nút Del
        local delBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        delBtn:SetSize(50, 20)
        delBtn:SetText("Del")
        delBtn:SetPoint("RIGHT", -5, 0)
        delBtn:SetScript("OnClick", function()
            GMTipTemplates[name] = nil
            print("|cffff0000GMTip: Deleted template '"..name.."'")
            UpdateTemplateList()
        end)
    end
    content:SetHeight(math.abs(offset))
end

-- Nút Close
local closeBtn = CreateFrame("Button", nil, templatePopup, "UIPanelButtonTemplate")
closeBtn:SetSize(80, 22)
closeBtn:SetText("Close")
closeBtn:SetPoint("BOTTOM", 0, 10)
closeBtn:SetScript("OnClick", function() templatePopup:Hide() end)

-- Nút Items Template (draggable)
GMTipTemplateBtn = CreateFrame("Button", "GMTipTemplateBtn", UIParent, "UIPanelButtonTemplate")
GMTipTemplateBtn:SetSize(120, 25)
GMTipTemplateBtn:SetText("Items Template")
GMTipTemplateBtn:SetPoint("CENTER", UIParent, "CENTER", 200, 200)

GMTipTemplateBtn:SetMovable(true)
GMTipTemplateBtn:EnableMouse(true)
GMTipTemplateBtn:RegisterForDrag("LeftButton")
GMTipTemplateBtn:SetScript("OnDragStart", function(self) self:StartMoving() end)
GMTipTemplateBtn:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

GMTipTemplateBtn:SetScript("OnClick", function()
    if templatePopup:IsShown() then
        templatePopup:Hide()
    else
        templatePopup:Show()
        UpdateTemplateList()
    end
end)
