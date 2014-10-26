local D, C, L = unpack(select(2, ...))
--[[Slash Commands]]--
local Split = function(cmd)
	if cmd:find("%s") then
		return strsplit(" ", strlower(cmd))
	else
		return cmd
	end
end

--[[ReloadUI]]--
SLASH_RELOADUI1 = "/rl"
SlashCmdList.RELOADUI = ReloadUI

--[[Disband Party / Raid]]--
local function DisbandRaidGroup()
	if InCombatLockdown() then return end

	if UnitInRaid("player") then
		SendChatMessage(ERR_GROUP_DISBANDED, "RAID")
		for i = 1, GetNumGroupMembers() do
			local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
			if online and name ~= D.MyName then UninviteUnit(name) end
		end
	else
		SendChatMessage(ERR_GROUP_DISBANDED, "PARTY")
		for i = MAX_PARTY_MEMBERS, 1, -1 do
			if GetNumGroupMembers(i) then UninviteUnit(UnitName("party"..i)) end
		end
	end
	LeaveParty()
end

D.CreatePopup["DUFFEDUIDISBAND_RAID"] = {
	question = L["group"]["disband"],
	answer1 = ACCEPT,
	answer2 = CANCEL,
	function1 = DisbandRaidGroup,
}

SlashCmdList["GROUPDISBAND"] = function()
	local instanceType = select(2, IsInInstance())

	if instanceType == "pvp" or instanceType == "arena" then return end
	if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then D.ShowPopup("DUFFEDUIDISBAND_RAID") end
end
SLASH_GROUPDISBAND1 = "/gd"
SLASH_GROUPDISBAND2 = "/rd"

--[[Layout-Switch]]--
local function HideFrame(frame)
	if not frame then return end

	frame:SetAttribute("showSolo", false)
	frame:SetAttribute("showParty", false)
	frame:SetAttribute("showraid", false)
end

local function ShowFrame(frame)
	if not frame then return end

	frame:SetAttribute("showSolo", false)
	frame:SetAttribute("showParty", true)
	frame:SetAttribute("showraid", true)
end

local function RaidLayout(cmd)
	if InCombatLockdown() then return end
	local arg1 = Split(cmd)

	if arg1 == "heal" then
		C["raid"].layout = "heal"
		HideFrame(oUF_DPS)
		ShowFrame(oUF_Heal)
		ReloadUI()
	elseif arg1 == "dps" then
		C["raid"].layout = "dps"
		HideFrame(oUF_Heal)
		ShowFrame(oUF_DPS)
		ReloadUI()
	elseif arg1 == "" then
		print(" ")
		print("/raidlayout heal to switch to Heal-Layout (Grid-Theme)")
		print("/raidlayout dps to switch to DPS-Layout")
	end
end
SLASH_RAIDLAYOUT1 = "/raidlayout"
SlashCmdList["RAIDLAYOUT"] = RaidLayout