-- Co-authored & architected with the assistance of Google Gemini (AI Collaborator)

local function DumpTableToChat(t, name, indent)
    name = name or "Table"
    indent = indent or ""
    
    if indent == "" then
        print(string.format("--- DUMPING: %s ---", name))
    end

    for k, v in pairs(t) do
        local keyString = tostring(k)
        if type(v) == "table" then
            print(string.format("%s[%s] => Table {", indent, keyString))
            DumpTableToChat(v, nil, indent .. "  ")
            print(string.format("%s}", indent))
        else
            print(string.format("%s[%s] => %s", indent, keyString, tostring(v)))
        end
    end
    
    if indent == "" then
        print("--- END OF DUMP ---")
    end
end

-- local TextDump = LibStub("LibTextDump-1.0")
-- local debugWindow = TextDump:New(name)

local function DumpTableToTextWindow(t, name, indent)
    name = name or "Table"
    indent = indent or ""
    
    if indent == "" then
        debugWindow:AddLine(string.format("--- DUMPING: %s ---", name))
    end

    for k, v in pairs(t) do
        local keyString = tostring(k)
        if type(v) == "table" then
            debugWindow:AddLine(string.format("%s[%s] => Table {", indent, keyString))
            DumpTableToTextWindow(v, nil, indent .. "  ")
            debugWindow:AddLine(string.format("%s}", indent))
        else
            debugWindow:AddLine(string.format("%s[%s] => %s", indent, keyString, tostring(v)))
        end
    end
    
    if indent == "" then
        debugWindow:AddLine("--- END OF DUMP ---")
    end
end

local function tableToString(tbl, indent)
    indent = indent or ""
    local nextIndent = indent .. "    "
    local result = "{\n"
    
    for k, v in pairs(tbl) do
        -- Format the key
        local keyStr
        if type(k) == "string" then
            if k:match("^[a-zA-Z_][a-zA-Z0-9_]*$") then
                keyStr = k
            else
                keyStr = '["' .. k .. '"]'
            end
        else
            keyStr = "[" .. tostring(k) .. "]"
        end
        
        -- Format the value
        local valStr
        if type(v) == "table" then
            valStr = tableToString(v, nextIndent)
        elseif type(v) == "string" then
            valStr = string.format("%q", v)
        else
            valStr = tostring(v)
        end
        
        result = result .. nextIndent .. keyStr .. " = " .. valStr .. ",\n"
    end
    
    return result .. indent .. "}"
end

-- 1. Register the unique popup window configuration
StaticPopupDialogs["COPY_TEXT_POPUP"] = {
    text = "Press Ctrl+C to copy:",
    button1 = "Done",
    hasEditBox = true,
    editBoxWidth = 350,
    maxLetters = 99999,
    
    OnShow = function(self, data)
        -- 'data' passes the string you want to show
        local editBox = self.GetEditBox and self:GetEditBox() or self.editBox
        editBox:SetText(data or "")
        editBox:SetFocus()
        editBox:HighlightText()
    end,
    
    EditBoxOnEnterPressed = function(self)
        self:GetParent():Hide()
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

--DumpTableToChat(childProfs, "childProfs")            
--self:Print(string.format("profName %s profIdx %s", tostring(profName), tostring(profIdx)))

-- Initialize the AceAddon, mixing in Console and Event handling libraries
local KnowledgeDump = LibStub("AceAddon-3.0"):NewAddon("KnowledgeDump", "AceConsole-3.0", "AceEvent-3.0")
local icon = LibStub:GetLibrary("LibDBIcon-1.0", true)

-- Setup the Localization Table with English Fallbacks
local L = setmetatable({}, { __index = function(t, k) t[k] = k return k end })

--@localization(locale="koKR", format="lua_keyword_table", handle-subnamespaces="concat")@
--@localization(locale="frFR", format="lua_keyword_table", handle-subnamespaces="concat")@
--@localization(locale="deDE", format="lua_keyword_table", handle-subnamespaces="concat")@
--@localization(locale="zhCN", format="lua_keyword_table", handle-subnamespaces="concat")@
--@localization(locale="esES", format="lua_keyword_table", handle-subnamespaces="concat")@
--@localization(locale="esMX", format="lua_keyword_table", handle-subnamespaces="concat")@
--@localization(locale="ptBR", format="lua_keyword_table", handle-subnamespaces="concat")@
--@localization(locale="ruRU", format="lua_keyword_table", handle-subnamespaces="concat")@
--@localization(locale="zhTW", format="lua_keyword_table", handle-subnamespaces="concat")@

function KnowledgeDump:DumpKnowledge()
    if WeeklyKnowledge and WeeklyKnowledge.Data and WeeklyKnowledge.Data.ScanProfessions then
        self:Print(L["--- Profession Knowledge Dump ---"])
        WeeklyKnowledge.Data:ScanProfessions()
        -- DumpTableToChat(WeeklyKnowledge.Data, "WeeklyKnowledge.Data")
        -- CopyToClipboard(tableToString(WeeklyKnowledge.Data, "WeeklyKnowledge.Data"))
        -- StaticPopup_Show("COPY_TEXT_POPUP", nil, nil, tableToString(WeeklyKnowledge.Data, "WeeklyKnowledge.Data"))
        -- DumpTableToTextWindow(WeeklyKnowledge.Data:GetCharacter().professions, "WeeklyKnowledge character professions")
        -- debugWindow:Display()
        if not KnowledgeDumpDB then
            KnowledgeDumpDB = {}
        end
        KnowledgeDumpDB["WeeklyKnowledgeDB"] = WeeklyKnowledge.Data
    end
end

function KnowledgeDump:OnInitialize()
    self:RegisterChatCommand("kd", "SlashCommandHandler")
    self:RegisterChatCommand("knowledgedump", "SlashCommandHandler")

    local defaults = { profile = { minimap = { hide = false } } }
    self.db = LibStub("AceDB-3.0"):New("KnowledgeDumpDB", defaults, true)

    local LDB = LibStub:GetLibrary("LibDataBroker-1.1", true)
    if LDB then
        local dataObject = LDB:NewDataObject("KnowledgeDump", {
            type = "launcher",
            text = L["Knowledge Dump"],
            icon = "Interface\\Icons\\INV_Scroll_03",
            
            OnClick = function() self:DumpKnowledge() end,
            OnTooltipShow = function(tooltip)
                tooltip:AddLine(L["Knowledge Dump"], 1, 1, 1)
                tooltip:AddLine(L["Left-Click to dump expansion profession metrics to chat."], 0.2, 1, 0.2)
                tooltip:AddLine(L["Type /kd toggle to hide this icon."], 0.5, 0.5, 0.5)
            end,
        })

        if icon then
            icon:Register("KnowledgeDump", dataObject, self.db.profile.minimap)
        end
    end
end

function KnowledgeDump:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function KnowledgeDump:PLAYER_ENTERING_WORLD()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function KnowledgeDump:SlashCommandHandler(input)
    local command = string.lower(string.trim(input or ""))
    
    if command == "toggle" then
        if icon then
            self.db.profile.minimap.hide = not self.db.profile.minimap.hide
            if self.db.profile.minimap.hide then
                icon:Hide("KnowledgeDump")
                self:Print(L["Minimap button hidden. Use '/kd toggle' to bring it back."])
            else
                icon:Show("KnowledgeDump")
                self:Print(L["Minimap button shown."])
            end
        end
    else
        self:DumpKnowledge()
    end
end
