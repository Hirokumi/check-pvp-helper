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

-- Add it to the FRIEND, PLAYER, PARTY, RAID, RAID_PLAYER, and SELF menus
local PopupList = {
   -- UnitPopupSharedMenus 9.2.5
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

-- using mixin as blizzard recommended
local CustomMenuButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin)
function CustomMenuButtonMixin:GetInteractDistance() return nil end;
function CustomMenuButtonMixin:GetText() return "Check PvP" end
function CustomMenuButtonMixin:OnClick()
   -- empty handler
end

-- extends every item in popup list, added custom button
for i,v in ipairs(PopupList) do
   local originButton = v.GetMenuButtons
   function v:GetMenuButtons()
      local buttons = originButton(self)
      table.insert(buttons, 1, CustomMenuButtonMixin)
      return buttons
   end
end


-- Your function to setup your button
function Armory_Link_Setup(level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay)
    tinsert(UISpecialFrames, "CheckPvPFrame") -- Axtaroth edit, makes frame truly closable with ESC
    -- Make sure we have what we need to continue
    if dropDownFrame and level then
		local name, server, active, customaction
		if dropDownFrame.which == "BN_FRIEND" then
			--bnet friend menu
			if dropDownFrame.bnetIDAccount then
				--get the gameaccount id and the game
				local gameaccount = C_BattleNet.GetAccountInfoByID(dropDownFrame.bnetIDAccount).gameAccountInfo.gameAccountID
				local game = C_BattleNet.GetAccountInfoByID(dropDownFrame.bnetIDAccount).gameAccountInfo.clientProgram
				if game == "WoW" then
					local tmp=C_BattleNet.GetGameAccountInfoByID(gameaccount)
					--if they are playing wow then get the character and server
					name=tmp["characterName"] or ""
					server=tmp["realmDisplayName"] or ""
					active = true
				else
					--otherwise, disable. they are playing a different game
					active = false
				end
			end
		else
			--other menu
			if dropDownFrame.name then
				name = dropDownFrame.name
				if(dropDownFrame.server == nil or dropDownFrame.server == "") then
					server = GetRealmName()
				else
					server = dropDownFrame.server
				end
				active = true
			else
				active = false
				if(menuList) then
					if(menuList[2] and menuList[2].arg1) then
						customaction = true
					end
				end
			end
		end
		--format servername
		if server then 
			server = server
			local ii = 0
			while server:find("(%u%l+)(%u%l+)") do
				server = server:gsub("(%u%l+)(%u%l+)", "%1 %2")
				ii = ii + 1
				if ii > 5 then
					break
				end
			end
			server = server:gsub("(%u%l+)(%d+)", "%1 %2")
		end
		-- Just so we don't have to concat strings for each interval
		local buttonPrefix = "DropDownList" .. level .. "Button"
		-- Start at 2 because 1 is always going to be the title (i.e. player name) in our case
		local i = 2
		while (1) do
			-- Get the button at index i in the dropdown
			local button = _G[buttonPrefix..i]
			if not button then break end
			-- If the button is our button...
			if button:GetText() == CustomMenuButtonMixin:GetText() then
				if active == true then
					-- Make it execute function for player that this menu popped up for (button at index 1)
					button.func = function()
						-- Function for the button
						--Set edit box
						edit:SetText(name.."-"..server)
						frame:Show()
					end
				else
					button.func = function()
                        -- Function for the button
                        -- Phattyy edit to check if there's no "-", in which case it adds the Player's realm
						if(customaction == true) then
                            if not string.find(menuList[2].arg1, "-") then
                              menuList[2].arg1 = menuList[2].arg1 .. '-' .. GetRealmName()
                            end
                            edit:SetText(menuList[2].arg1)
                            frame:Show()
                          else
						--player not playing wow
							print("Check-PvP: This player is not logged in to a character on WoW.")
						end
					end
				end
				-- Break the loop; we got what we were looking for.
				break
			end
			i = i + 1
		end
	end
end


-- Hook ToggleDropDownMenu with your function
hooksecurefunc("ToggleDropDownMenu", Armory_Link_Setup);

local LFG_LIST_SEARCH_ENTRY_MENU = {
    {
        text = nil, --Group name goes here
        isTitle = true,
        notCheckable = true,
    },
    {
        text = WHISPER_LEADER,
        func = function(_, name) ChatFrame_SendTell(name); end,
        notCheckable = true,
        arg1 = nil, --Leader name goes here
        disabled = nil, --Disabled if we don't have a leader name yet or you haven't applied
        tooltipWhileDisabled = 1,
        tooltipOnButton = 1,
        tooltipTitle = nil, --The title to display on mouseover
        tooltipText = nil, --The text to display on mouseover
    },
	{
        text = "Check PvP",
		notCheckable = true,
		arg1 = nil, --Player name goes here
		disabled = nil, --Disabled if we don't have a name yet
    },
    {
        text = LFG_LIST_REPORT_GROUP_FOR,
        hasArrow = true,
        notCheckable = true,
        menuList = {
            {
                text = LFG_LIST_BAD_NAME,
                func = function(_, id) C_LFGList.ReportSearchResult(id, "lfglistname"); end,
                arg1 = nil, --Search result ID goes here
                notCheckable = true,
            },
            {
                text = LFG_LIST_BAD_DESCRIPTION,
                func = function(_, id) C_LFGList.ReportSearchResult(id, "lfglistcomment"); end,
                arg1 = nil, --Search reuslt ID goes here
                notCheckable = true,
                disabled = nil, --Disabled if the description is just an empty string
            },
            {
                text = LFG_LIST_BAD_VOICE_CHAT_COMMENT,
                func = function(_, id) C_LFGList.ReportSearchResult(id, "lfglistvoicechat"); end,
                arg1 = nil, --Search reuslt ID goes here
                notCheckable = true,
                disabled = nil, --Disabled if the description is just an empty string
            },
            {
                text = LFG_LIST_BAD_LEADER_NAME,
                func = function(_, id) C_LFGList.ReportSearchResult(id, "badplayername"); end,
                arg1 = nil, --Search reuslt ID goes here
                notCheckable = true,
                disabled = nil, --Disabled if we don't have a name for the leader
            },
        },
    },
    {
        text = CANCEL,
        notCheckable = true,
    },
};
 
function LFGListUtil_GetSearchEntryMenu(resultID)

	local results = C_LFGList.GetSearchResultInfo(resultID)
	if not results then
		return
	end
	local activityID = results.activityID
	local leaderName = results.leaderName
	
    local _, appStatus, pendingStatus, appDuration = C_LFGList.GetApplicationInfo(resultID);
    LFG_LIST_SEARCH_ENTRY_MENU[1].text = name;
    LFG_LIST_SEARCH_ENTRY_MENU[2].arg1 = leaderName;
    LFG_LIST_SEARCH_ENTRY_MENU[2].disabled = not leaderName;
    LFG_LIST_SEARCH_ENTRY_MENU[3].arg1 = leaderName;
    LFG_LIST_SEARCH_ENTRY_MENU[3].disabled = not leaderName;
    LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[1].arg1 = resultID;
    LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[2].arg1 = resultID;
    LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[2].disabled = (comment == "");
    LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[3].arg1 = resultID;
    LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[3].disabled = (voiceChat == "");
    LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[4].arg1 = resultID;
    LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[4].disabled = not leaderName;
    return LFG_LIST_SEARCH_ENTRY_MENU;
end

local LFG_LIST_APPLICANT_MEMBER_MENU = {
    {
        text = nil, --Player name goes here
        isTitle = true,
        notCheckable = true,
    },
    {
        text = WHISPER,
        func = function(_, name) ChatFrame_SendTell(name); end,
        notCheckable = true,
        arg1 = nil, --Player name goes here
        disabled = nil, --Disabled if we don't have a name yet
    },
    {
        text = "Check PvP",
		notCheckable = true,
		arg1 = nil, --Player name goes here
		disabled = nil, --Disabled if we don't have a name yet
    },
    {
        text = LFG_LIST_REPORT_FOR,
        hasArrow = true,
        notCheckable = true,
        menuList = {
            {
                text = LFG_LIST_BAD_PLAYER_NAME,
                notCheckable = true,
                func = function(_, id, memberIdx) C_LFGList.ReportApplicant(id, "badplayername", memberIdx); end,
                arg1 = nil, --Applicant ID goes here
                arg2 = nil, --Applicant Member index goes here
            },
            {
                text = LFG_LIST_BAD_DESCRIPTION,
                notCheckable = true,
                func = function(_, id) C_LFGList.ReportApplicant(id, "lfglistappcomment"); end,
                arg1 = nil, --Applicant ID goes here
            },
        },
    },
    {
        text = IGNORE_PLAYER,
        notCheckable = true,
        func = function(_, name, applicantID) AddIgnore(name); C_LFGList.DeclineApplicant(applicantID); end,
        arg1 = nil, --Player name goes here
        arg2 = nil, --Applicant ID goes here
        disabled = nil, --Disabled if we don't have a name yet
    },
    {
        text = CANCEL,
        notCheckable = true,
    },
};
 
function LFGListUtil_GetApplicantMemberMenu(applicantID, memberIdx)
    local name, class, localizedClass, level, itemLevel, tank, healer, damage, assignedRole = C_LFGList.GetApplicantMemberInfo(applicantID, memberIdx);
	
    --local id, status, pendingStatus, numMembers, isNew, comment = C_LFGList.GetApplicantInfo(applicantID);
	
    LFG_LIST_APPLICANT_MEMBER_MENU[1].text = name or " ";
    LFG_LIST_APPLICANT_MEMBER_MENU[2].arg1 = name;
    LFG_LIST_APPLICANT_MEMBER_MENU[2].disabled = not name;
    LFG_LIST_APPLICANT_MEMBER_MENU[3].arg1 = name;
    LFG_LIST_APPLICANT_MEMBER_MENU[3].disabled = not name;
    LFG_LIST_APPLICANT_MEMBER_MENU[4].menuList[1].arg1 = applicantID;
    LFG_LIST_APPLICANT_MEMBER_MENU[4].menuList[1].arg2 = memberIdx;
    LFG_LIST_APPLICANT_MEMBER_MENU[4].menuList[2].arg1 = applicantID;
    LFG_LIST_APPLICANT_MEMBER_MENU[4].menuList[2].disabled = (comment == "");
    LFG_LIST_APPLICANT_MEMBER_MENU[5].arg1 = name;
    LFG_LIST_APPLICANT_MEMBER_MENU[5].arg2 = applicantID;
    LFG_LIST_APPLICANT_MEMBER_MENU[5].disabled = not name;
    return LFG_LIST_APPLICANT_MEMBER_MENU;
end