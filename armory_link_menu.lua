--Localization Tables
local L = {}
if GetLocale() == "enUS" then
	--@localization(locale="enUS", format="lua_additive_table", handle-unlocalized="english", handle-subnamespaces="concat")@
elseif GetLocale() == "esMX" then
	--@localization(locale="esMX", format="lua_additive_table", handle-unlocalized="english", handle-subnamespaces="concat")@
elseif GetLocale() == "ptBR" then
	--@localization(locale="ptBR", format="lua_additive_table", handle-unlocalized="english", handle-subnamespaces="concat")@
elseif GetLocale() == "enGB" then
	--@localization(locale="enUS", format="lua_additive_table", handle-unlocalized="english", handle-subnamespaces="concat")@
elseif GetLocale() == "frFR" then
	--@localization(locale="frFR", format="lua_additive_table", handle-unlocalized="english", handle-subnamespaces="concat")@
elseif GetLocale() == "deDE" then
	--@localization(locale="deDE", format="lua_additive_table", handle-unlocalized="english", handle-subnamespaces="concat")@
elseif GetLocale() == "itIT" then
	--@localization(locale="itIT", format="lua_additive_table", handle-unlocalized="english", handle-subnamespaces="concat")@
elseif GetLocale() == "esES" then
	--@localization(locale="esES", format="lua_additive_table", handle-unlocalized="english", handle-subnamespaces="concat")@
elseif GetLocale() == "ruRU" then
	--@localization(locale="ruRU", format="lua_additive_table", handle-unlocalized="english", handle-subnamespaces="concat")@
elseif GetLocale() == "koKR" then
	--@localization(locale="koKR", format="lua_additive_table", handle-unlocalized="english", handle-subnamespaces="concat")@
elseif GetLocale() == "zhCN" then
	--@localization(locale="zhCN", format="lua_additive_table", handle-unlocalized="english", handle-subnamespaces="concat")@
elseif GetLocale() == "zhTW" then
	--@localization(locale="zhTW", format="lua_additive_table", handle-unlocalized="english", handle-subnamespaces="concat")@
else
	--No locale or error locale
end
if next(L) == nil then
	--failsafe locale table
	L = {
		["Armory Link"] = "Armory Link",
		["Okay"] = "Okay"
	}
end

-- Create a new button type
UnitPopupButtons["ARMORY_LINK"] = { text = "Armory Link", dist = 0 }

local frame = CreateFrame("Frame", "ArmoryLinkFrame", UIParent, "UIPanelDialogTemplate")
local edit = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")

frame.edit = edit
frame.button = button

local sitestable = {
	--NA Region
	["enUS"] = "https://worldofwarcraft.com/en-us/character/",
	["esMX"] = "https://worldofwarcraft.com/es-mx/character/",
	["ptBR"] = "https://worldofwarcraft.com/pt-br/character/",
	--EU Region
	["enGB"] = "https://worldofwarcraft.com/en-gb/character/",
	["frFR"] = "https://worldofwarcraft.com/fr-fr/character/",
	["deDE"] = "https://worldofwarcraft.com/de-de/character/",
	["itIT"] = "https://worldofwarcraft.com/it-it/character/",
	["esES"] = "https://worldofwarcraft.com/es-es/character/",
	["ruRU"] = "https://worldofwarcraft.com/ru-ru/character/",
	--Asian Regions
	["koKR"] = "https://worldofwarcraft.com/ko-kr/character/",
	["zhCN"] = "https://worldofwarcraft.com/zh-cn/character/", --Wrong site, blame censorship
	["zhTW"] = "https://worldofwarcraft.com/zh-tw/character/",
}
local site = sitestable[GetLocale()] or "Error getting locale"
--All web addresses are in english - not sure if this is how it actually works in other locales (is there a mundodeguerra.com?)

--Frame Setup
frame:Hide()
frame:SetHeight(100)
frame:SetWidth(450)
frame:SetPoint("CENTER", UIParent, "TOP", 0, -1 * GetScreenHeight() / 4)
frame:EnableKeyboard(false)
frame.Title:SetText(L["Armory Link"])
frame:SetMovable(true)
frame:SetScript("OnShow", function(self) self.edit:SetFocus() end)
frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
frame:RegisterForDrag("LeftButton")
frame:EnableMouse(true)

--Editbox Setup
edit:SetPoint("TOPLEFT", frame, "LEFT", 30, 8)
edit:SetPoint("BOTTOMRIGHT", frame, "RIGHT", -30, -8)
edit:SetScript("OnEnterPressed", function(self) ArmoryLinkFrameClose:Click() end)
edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
edit:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
edit:SetAutoFocus(false)

--Button Setup
button:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
button:SetHeight(20)
button:SetWidth(50)
button:SetText(L["Okay"])
button:SetScript("OnClick", function() ArmoryLinkFrameClose:Click() end)

-- Add it to the FRIEND, PLAYER, PARTY, RAID, RAID_PLAYER, and SELF menus as the 2nd to last option (before Cancel)
-- place it as 3rd to last on self so that its before 'leave party'
table.insert(UnitPopupMenus["FRIEND"], #UnitPopupMenus["FRIEND"], "ARMORY_LINK")
table.insert(UnitPopupMenus["PLAYER"], #UnitPopupMenus["PLAYER"], "ARMORY_LINK")
table.insert(UnitPopupMenus["PARTY"], #UnitPopupMenus["PARTY"], "ARMORY_LINK")
table.insert(UnitPopupMenus["RAID"], #UnitPopupMenus["RAID"], "ARMORY_LINK")
table.insert(UnitPopupMenus["RAID_PLAYER"], #UnitPopupMenus["RAID_PLAYER"], "ARMORY_LINK")
table.insert(UnitPopupMenus["SELF"], #UnitPopupMenus["SELF"] - 2, "ARMORY_LINK")
--Bnet friend menu handle is "BN_FRIEND"
table.insert(UnitPopupMenus["BN_FRIEND"], #UnitPopupMenus["BN_FRIEND"], "ARMORY_LINK")

-- Your function to setup your button
function Armory_Link_Setup(level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay)
    -- Make sure we have what we need to continue
    if dropDownFrame and level then
		local name, server, active
		if dropDownFrame.which == "BN_FRIEND" then
			--bnet friend menu
			if dropDownFrame.bnetIDAccount then
				--get the gameaccount id and the game
				local friendinfo = C_BattleNet.GetAccountInfoByID(dropDownFrame.bnetIDAccount);
				local gameaccount = friendinfo.gameAccountInfo;
				if gameaccount.clientProgram == BNET_CLIENT_WOW then
					--if they are playing wow then get the character and server
					name = gameaccount.characterName;
					server = gameaccount.realmName;
					active = true
				else
					--otherwise, disable. they are playing a different game
					active = false
				end
			end
		else
			--other menu
			if dropDownFrame.name then
				name = dropDownFrame.name:lower()
				server = dropDownFrame.server or GetRealmName()
				active = true
			else
				active = false
			end
		end
		--format servername
		if server then 
			server = server:gsub("'", "")
			local ii = 0
			while server:find("(%u%l+)(%u%l+)") do
				server = server:gsub("(%u%l+)(%u%l+)", "%1 %2")
				ii = ii + 1
				if ii > 5 then
					break
				end
			end
			server = server:gsub("(%u%l+)(%d+)", "%1 %2"):gsub(" ", "-"):lower()
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
			if button:GetText() == UnitPopupButtons["ARMORY_LINK"].text then
				if active == true then
					-- Make it execute function for player that this menu popped up for (button at index 1)
					button.func = function()
						-- Function for the button
						--Set edit box
						edit:SetText(site..server.."/"..name)
						frame:Show()
					end
				else
					button.func = function()
						-- Function for the button
						--player not playing wow
						print("Armory Link Menu: This player is not logged in to a character on WoW.")
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

--Remove interact distance requirement
UnitPopupButtons["ARMORY_LINK"].dist = nil
