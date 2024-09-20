local frame = CreateFrame("Frame", "CheckPvPFrame", UIParent, "UIPanelDialogTemplate")
local edit = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
frame.edit = edit


--Frame Setup
frame:Hide()
frame:SetHeight(80)
frame:SetWidth(300)
frame:SetPoint("CENTER", UIParent, "TOP", 0, -1 * GetScreenHeight() / 4)
frame:EnableKeyboard(false)
frame.Title:SetText("Check PvP")
frame:SetMovable(true)
frame:SetScript("OnShow", function(self) self.edit:SetFocus() end)
frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
frame:RegisterForDrag("LeftButton")
frame:EnableMouse(true)
frame:SetToplevel(true)

--Editbox Setup
edit:SetPoint("TOPLEFT", frame, "LEFT", 30, 0)
edit:SetPoint("BOTTOMRIGHT", frame, "RIGHT", -30, -16)
edit:SetScript("OnEnterPressed", function(self) self:GetParent():Hide() end)
edit:SetScript("OnEscapePressed", function(self) self:GetParent():Hide() end)
edit:SetScript("OnSpacePressed", function(self) self:GetParent():Hide() end)
edit:SetScript("OnEditFocusLost", function(self) self:GetParent():Hide() end) -- Axtaroth edit, hides frame when Focus lost to avoid the frame from being active but text not automatically selecting
edit:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
edit:SetScript("OnUpdate", function(self) self:HighlightText() end)
edit:SetJustifyH("CENTER")
edit:SetAutoFocus(false)

local CustomCheckPvPButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin)

function CustomCheckPvPButtonMixin:GetText()
    return "Check PvP"
end

function CustomCheckPvPButtonMixin:OnClick(button)
    local name, realm = nil, nil
    local clubID = CommunitiesFrame:GetSelectedClubId()
    if button.bnetIDAccount then
        -- Gestion des amis Battle.net
        local accountInfo = C_BattleNet.GetAccountInfoByID(button.bnetIDAccount)
        if accountInfo and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.clientProgram == "WoW" then
            name = accountInfo.gameAccountInfo.characterName
            realm = accountInfo.gameAccountInfo.realmName or GetRealmName()
        end
    elseif button.unit or UnitIsPlayer("mouseover") then
        -- Gestion des joueurs WoW en jeu et en guilde
        local unitId = button.unit or "mouseover"
        name, realm = UnitName(unitId)
        realm = realm or GetRealmName()
    elseif button.name then
        name = GetNameFromCommunity(clubID, button.name) or button.name
        realm = GetRealmName()
    end

    if name then
        local displayName = name .. "-" .. realm
        if NameHasRealm(name) then
            edit:SetText(name)
        else 
            edit:SetText(displayName)
        end
    else
        edit:SetText("No valid player targeted")
    end
    frame:Show()
end

function GetNameFromCommunity(clubID, name)
    if clubID then
        local members = C_Club.GetClubMembers(clubID)
        for _, member in ipairs(members) do
            local info = C_Club.GetMemberInfo(clubID, member)
            local characterName, realm = strsplit("-", info.name)
            if name == characterName then
                if NameHasRealm(info.name) then
                    return info.name
                else
                    return name
                end
            end
        end
    end
end

function NameHasRealm(name)
    return string.find(name, "-") ~= nil
end

local function AddCheckPvPButtonToMenu(popupMenu)
    local OriginalGetEntries = popupMenu.GetEntries

    function popupMenu:GetEntries()
        local entries = OriginalGetEntries(self)

        table.insert(entries, CustomCheckPvPButtonMixin)

        return entries
    end
end

local popupMenus = {
    UnitPopupMenuFriend,
    UnitPopupMenuPlayer,
    UnitPopupMenuEnemyPlayer,
    UnitPopupMenuParty,
    UnitPopupMenuRaid,
    UnitPopupMenuRaidPlayer,
    UnitPopupMenuSelf,
    UnitPopupMenuBnFriend,
    UnitPopupMenuGuild,
    UnitPopupMenuGuildOffline,
    UnitPopupMenuChatRoster,
    UnitPopupMenuTarget,
    UnitPopupMenuArenaEnemy,
    UnitPopupMenuFocus,
    UnitPopupMenuWorldStateScore,
    UnitPopupMenuCommunitiesGuildMember,
    UnitPopupMenuCommunitiesWowMember,
}

for _, popupMenu in ipairs(popupMenus) do
    AddCheckPvPButtonToMenu(popupMenu)
end