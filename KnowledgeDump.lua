-- Co-authored & architected with the assistance of Google Gemini (AI Collaborator)

local KnowledgeDump = LibStub("AceAddon-3.0"):NewAddon("KnowledgeDump", "AceConsole-3.0", "AceEvent-3.0")
local icon = LibStub:GetLibrary("LibDBIcon-1.0", true)

-- 1. Setup the Localization Table with English Fallbacks
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

-- Hardcoded Max Knowledge targets per expansion tier
local EXPANSIONS = {
    { name = "Midnight",    id = 11, maxes = { [171] = 500, [164] = 500, [185] = 500, [172] = 500, [202] = 500, [182] = 500, [393] = 500, [197] = 500, [165] = 170, [186] = 160, [356] = 180 } },
    { name = "TWW",         id = 10, maxes = { [171] = 510, [164] = 620, [185] = 515, [172] = 460, [202] = 540, [182] = 560, [393] = 515, [197] = 530, [165] = 170, [186] = 160, [356] = 180 } },
    { name = "Dragonflight", id = 9,  maxes = { [171] = 510, [164] = 570, [185] = 475, [172] = 460, [202] = 540, [182] = 560, [393] = 515, [197] = 530, [165] = 170, [186] = 160, [356] = 180 } },
}

function KnowledgeDump:DumpKnowledge()
    self:Print(L["--- Profession Knowledge Dump ---"])
    
    local prof1, prof2 = GetProfessions()
    local profs = { prof1, prof2 }
    local linesPrinted = 0

    for _, profIdx in ipairs(profs) do
        if profIdx then
            local profName, _, _, _, _, _, profID = GetProfessionInfo(profIdx)
            
            for _, exp in ipairs(EXPANSIONS) do
                local specTabInfo = C_ProfSpecs.GetSpecTabInfoForSkillLine(profID)
                if specTabInfo and #specTabInfo > 0 then
                    local currentKnowledge = C_ProfSpecs.GetKnowledgePointsForSkillLine(profID) or 0
                    local maxKnowledge = exp.maxes[profID] or "???"
                    
                    self:Print(string.format("|cff00ffff%s|r (%s): %s/%s", profName, exp.name, tostring(currentKnowledge), tostring(maxKnowledge)))
                    linesPrinted = linesPrinted + 1
                end
            end
        end
    end
    
    if linesPrinted == 0 then
        self:Print(L["No primary professions found on this character."])
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
