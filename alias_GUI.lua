local period = 0
local guiWidth, guiHeight = 0.6, 0.6
local centerX, centerY = (1 / 2) - (guiWidth / 2), (1 / 2) - (guiHeight / 2)
local gridWidth, gridHeight = 1, 0.6
local gCenterX, gCenterY = (1 / 2) - (gridWidth / 2), (1 / 2) - (gridHeight / 2)
local tabWidth, tabHeight = 0.32, 0.25
local tCenterX, tCenterY = (1 / 2) - (tabWidth / 2), (1 / 2) - (tabHeight / 2)

local window, aliasGrid, row, warnsGrid = nil
-- Columns
local idCol, nameCol, serialCol, IPCol, banCol, adminCol, dateCol, reasonCol = nil
local idCol2, nameCol2, serialCol2, IPCol2, adminCol2, dateCol2, reasonCol2 = nil
local idCol3, nameCol3, serialCol3, adminCol3, dateCol3 = nil
-- EditBoxes
local searchBox = nil
local penaltyBox = {}
-- Buttons
local banBtn, unbanBtn, muteBtn, unmuteBtn, kickBtn, closeBtn, addRowsBtn, defaultBtn = nil
-- Panels
local tabPanel, gridTabPanel, monthsTab, daysTab, hoursTab, minutesTab, permTab = nil
-- Radio buttons
local radio = {}
-- Text
local default_searchBox = "Search for a player's serial, nickname or IP..."
local reason = ""
-- Flags
local vis = false
local afterSearch = false

local iC = 0
local iC2 = 0
local iC3 = 0

local bansDelayFlag = true
local warnsDelayFlag = true
local unbansDelayFlag = true
local searchAliasFlag = true
local searchWarnsFlag = true
local searchUnbansFlag = true

function GUI()

	-- Create window
	window = guiCreateWindow( centerX, centerY, guiWidth, guiHeight, "Alias System", true)
	guiWindowSetSizable (window, false)

	-- Create search box
	searchBox = guiCreateEdit(gCenterX, gCenterY-0.15, 0.88, 0.06, default_searchBox, true, window)
	
	gridTabPanel = guiCreateTabPanel(gCenterX, gCenterY-0.08, gridWidth, gridHeight, true, window)
	aliasTab = guiCreateTab( "Alias", gridTabPanel)
	warnsTab = guiCreateTab( "Warns", gridTabPanel)
	unbansTab = guiCreateTab( "Unbans" ,gridTabPanel)

	-- Create gridlist
	warnsGrid = guiCreateGridList(0, 0, 1, 1, true, warnsTab)
	guiGridListSetSortingEnabled(warnsGrid, false)
	idCol2 = guiGridListAddColumn(warnsGrid, "ID", 0.05)
	nameCol2 = guiGridListAddColumn(warnsGrid, "Player Name", 0.12)
	serialCol2 = guiGridListAddColumn(warnsGrid, "Player Serial", 0.26)
	IPCol2 = guiGridListAddColumn(warnsGrid, "Player IP", 0.11)
	dateCol2 = guiGridListAddColumn(warnsGrid, "Warn Date", 0.08)
	adminCol2 = guiGridListAddColumn(warnsGrid, "Warned By", 0.11)
	reasonCol2 = guiGridListAddColumn(warnsGrid, "Warn Reason", 0.24)

	aliasGrid = guiCreateGridList(0, 0, 1, 1, true, aliasTab)
	guiGridListSetSortingEnabled(aliasGrid, false)
	idCol = guiGridListAddColumn(aliasGrid, "ID", 0.05)
	nameCol = guiGridListAddColumn(aliasGrid, "Player Name", 0.12)
	serialCol = guiGridListAddColumn(aliasGrid, "Player Serial", 0.26)
	IPCol = guiGridListAddColumn(aliasGrid, "Player IP", 0.11)
	banCol = guiGridListAddColumn(aliasGrid, "Ban Status", 0.07)
	dateCol = guiGridListAddColumn(aliasGrid, "Ban Date", 0.08)
	adminCol = guiGridListAddColumn(aliasGrid, "Banned By", 0.11)
	reasonCol = guiGridListAddColumn(aliasGrid, "Ban Reason", 0.17)

	unbansGrid = guiCreateGridList(0, 0, 1, 1, true, unbansTab)
	guiGridListSetSortingEnabled(unbansGrid, false)
	idCol3 = guiGridListAddColumn(unbansGrid, "ID", 0.05)
	nameCol3 = guiGridListAddColumn(unbansGrid, "Player Name", 0.12)
	serialCol3 = guiGridListAddColumn(unbansGrid, "Player Serial", 0.28)
	dateCol3 = guiGridListAddColumn(unbansGrid, "Unban Date", 0.1)
	adminCol3 = guiGridListAddColumn(unbansGrid, "Unbanned By", 0.15)



	-- Create buttons
	banBtn = guiCreateButton( 0, 0.91, 0.1, 0.07, "Ban", true, window)
	unbanBtn = guiCreateButton( 0.12, 0.91, 0.1, 0.07, "Unban", true, window)	
	kickBtn = guiCreateButton( 0.23, 0.91, 0.1, 0.07, "Kick", true, window)	
	unmuteBtn = guiCreateButton( 0.78, 0.91, 0.1, 0.07, "Unmute", true, window)	
	muteBtn = guiCreateButton( 0.67, 0.91, 0.1, 0.07, "Mute", true, window)	
	closeBtn = guiCreateButton( 0.89, 0.91, 0.1, 0.07, "Close", true, window)
	addRowsBtn = guiCreateButton( 0, tCenterY+0.355, 0.1, 0.07, "More results", true, window)
	warnBtn = guiCreateButton( 0, tCenterY+0.443, 0.1, 0.07, "Warn", true, window)
	searchBtn = guiCreateButton( 0.9, gCenterY-0.15, 0.1,0.06, "Search", true, window)
	unwarnBtn = guiCreateButton( 0.89, tCenterY+0.443, 0.1, 0.07, "Unwarn", true, window)
	defaultBtn = guiCreateButton( 0.89, tCenterY+0.355, 0.1,0.07, "Refresh", true, window)

	-- Create tab panel
	tabPanel = guiCreateTabPanel(tCenterX, tCenterY+0.355, tabWidth, tabHeight, true, window)
	monthsTab = guiCreateTab("Month", tabPanel)
	daysTab = guiCreateTab("Day", tabPanel)
	hoursTab = guiCreateTab("Hour", tabPanel)
	minutesTab = guiCreateTab("Minute", tabPanel)
	permTab = guiCreateTab("Perm", tabPanel)

	-- Create radio buttons
	radio[1] = guiCreateRadioButton (0.05, 0.12, 0.4,0.18, "12 Months", true, monthsTab)
	radio[2] = guiCreateRadioButton (0.55, 0.12, 0.4,0.18, "6 Months", true, monthsTab)
	radio[3] = guiCreateRadioButton (0.05, 0.33, 0.4,0.18, "3 Months", true, monthsTab)
	radio[4] = guiCreateRadioButton (0.55, 0.33, 0.4,0.18, "1 Month", true, monthsTab)

	radio[5] = guiCreateRadioButton (0.05, 0.12, 0.4,0.18, "15 Days", true, daysTab)
	radio[6] = guiCreateRadioButton (0.55, 0.12, 0.4,0.18, "7 Days", true, daysTab)
	radio[7] = guiCreateRadioButton (0.05, 0.33, 0.4,0.18, "3 Days", true, daysTab)
	radio[8] = guiCreateRadioButton (0.55, 0.33, 0.4,0.18, "1 Day", true, daysTab)

	radio[9] = guiCreateRadioButton (0.05, 0.12, 0.4,0.18, "12 Hours", true, hoursTab)
	radio[10] = guiCreateRadioButton (0.55, 0.12, 0.4,0.18, "6 Hours", true, hoursTab)
	radio[11] = guiCreateRadioButton (0.05, 0.33, 0.4,0.18, "3 Hours", true, hoursTab)
	radio[12] = guiCreateRadioButton (0.55, 0.33, 0.4,0.18, "1 Hour", true, hoursTab)

	radio[13] = guiCreateRadioButton (0.05, 0.12, 0.4,0.18, "30 Minutes", true, minutesTab)
	radio[14] = guiCreateRadioButton (0.55, 0.12, 0.4,0.18, "15 Minutes", true, minutesTab)
	radio[15] = guiCreateRadioButton (0.05, 0.33, 0.4,0.18, "10 Minutes", true, minutesTab)
	radio[16] = guiCreateRadioButton (0.55, 0.33, 0.4,0.18, "5 Minutes", true, minutesTab)

	radio[17] = guiCreateRadioButton (0.05, 0.12, 0.9,0.18, "I understand this is a permanent punishment", true, permTab)

	-- Penalty text box

	penaltyBox[1] = guiCreateEdit(0.03, 0.67, 0.94, 0.25, "Penalty reason...", true, monthsTab)
	penaltyBox[2] = guiCreateEdit(0.03, 0.67, 0.94, 0.25, "", true, daysTab)
	penaltyBox[3] = guiCreateEdit(0.03, 0.67, 0.94, 0.25, "", true, hoursTab)
	penaltyBox[4] = guiCreateEdit(0.03, 0.67, 0.94, 0.25, "", true, minutesTab)
	penaltyBox[5] = guiCreateEdit(0.03, 0.67, 0.94, 0.25, "Use permanent bans for extreme cases only!", true, permTab)

	-- Start GUI
	guiSetVisible(window, false)
end
addEventHandler("onClientResourceStart", resourceRoot, GUI)



function getPlayerFromPartialName(name)
    local name = name and name:gsub("#%x%x%x%x%x%x", ""):lower() or nil
    if name then
        for _, player in ipairs(getElementsByType("player")) do
            local name_ = getPlayerName(player):gsub("#%x%x%x%x%x%x", ""):lower()
            if name_:find(name, 1, true) then
                return player
            end
        end
    end
end



local function setAfterSearch()
	afterSearch = true
end
addEvent("afterSearchEnabled", true)
addEventHandler("afterSearchEnabled", root, setAfterSearch)



function defaulHelp()
	iC = 0
	iC2 = 0
	iC3 = 0
end


function setDefault(int)
	guiGridListSetColumnWidth(warnsGrid, idCol2, 0.05, true)
	guiGridListSetColumnWidth(warnsGrid, nameCol2, 0.12, true)
	guiGridListSetColumnWidth(warnsGrid, serialCol2, 0.26, true)
	guiGridListSetColumnWidth(warnsGrid, IPCol2, 0.11, true)
	guiGridListSetColumnWidth(warnsGrid, dateCol2, 0.08, true)
	guiGridListSetColumnWidth(warnsGrid, adminCol2, 0.11, true)
	guiGridListSetColumnWidth(warnsGrid, reasonCol2, 0.24, true)

	guiGridListSetColumnWidth(aliasGrid, idCol, 0.05, true)
	guiGridListSetColumnWidth(aliasGrid, nameCol, 0.12, true)
	guiGridListSetColumnWidth(aliasGrid, serialCol, 0.26, true)
	guiGridListSetColumnWidth(aliasGrid, IPCol, 0.11, true)
	guiGridListSetColumnWidth(aliasGrid, banCol, 0.07, true)
	guiGridListSetColumnWidth(aliasGrid, dateCol, 0.08, true)
	guiGridListSetColumnWidth(aliasGrid, adminCol, 0.11, true)
	guiGridListSetColumnWidth(aliasGrid, reasonCol, 0.17, true)

	guiGridListSetColumnWidth(unbansGrid, idCol3, 0.05, true)
	guiGridListSetColumnWidth(unbansGrid, nameCol3, 0.12, true)
	guiGridListSetColumnWidth(unbansGrid, serialCol3, 0.28, true)
	guiGridListSetColumnWidth(unbansGrid, dateCol3, 0.1, true)
	guiGridListSetColumnWidth(unbansGrid, adminCol3, 0.15, true)
	guiSetEnabled (addRowsBtn,true)
	bansDelayFlag = true
	warnsDelayFlag = true
	unbansDelayFlag = true
	searchAliasFlag = true
	searchWarnsFlag = true
	searchUnbansFlag = true
	if(int == 0) then
		guiSetText(penaltyBox[1], "Penalty reason...")
		for i=1,3,1 do
			guiSetText(penaltyBox[i], "")
		end
		guiSetText(penaltyBox[5], "Use permanent bans for extreme cases only!")

		for i=1,17,1 do
			guiRadioButtonSetSelected(radio[i], false)
		end

		guiSetSelectedTab(tabPanel, monthsTab)
	end
	guiSetText(searchBox, default_searchBox)
	guiGridListClear(aliasGrid)
	guiGridListClear(warnsGrid)
	guiGridListClear(unbansGrid)
	defaulHelp()
end



function toggleVisibility()
	vis = not vis
	guiSetVisible(window, vis)
	showCursor(vis)
	if(not vis) then
		setDefault(0)
		guiSetPosition(window, centerX, centerY, true)
	end
end
addEvent("onAdminToggleVisibility", true)
addEventHandler("onAdminToggleVisibility", root, toggleVisibility)

function searchEmpty()
	if(source == searchBox) then
		local text = guiGetText(searchBox)
		if(text == "" or text == default_searchBox) then
			guiSetText(source, "" )
			guiGridListClear(aliasGrid)
			guiGridListClear(warnsGrid)
			guiGridListClear(unbansGrid)
			defaulHelp()
		end
	elseif(source == penaltyBox[1]) then
		guiSetText(penaltyBox[1],"")
	end
end
addEventHandler("onClientGUIFocus", root, searchEmpty)



function buttonHandler(button, state) 		-- Labash hoon 3nd l after search o heek
	if(button == "left" and state =="up") then
		-- More results button action
		if(source == addRowsBtn) then
			if(afterSearch) then 
				setDefault(1)
				afterSearch = false
			elseif(guiGetText(guiGetSelectedTab(gridTabPanel)) == "Alias" and bansDelayFlag == true) then
				bansDelayFlag = false
				guiSetEnabled (addRowsBtn,false)
				triggerServerEvent("onListUpdated", localPlayer, iC)
			elseif(guiGetText(guiGetSelectedTab(gridTabPanel)) == "Warns" and warnsDelayFlag == true) then
				warnsDelayFlag = false
				guiSetEnabled (addRowsBtn,false)
				triggerServerEvent("onUpdateWarns", localPlayer, iC2)
			elseif(guiGetText(guiGetSelectedTab(gridTabPanel)) == "Unbans" and unbansDelayFlag == true) then
				unbansDelayFlag = false
				guiSetEnabled (addRowsBtn,false)
				triggerServerEvent("onUpdateUnbans", localPlayer, iC3)
			end
		-- Search button action
		elseif(source == searchBtn) then
			local text = guiGetText(searchBox)
			if(text == "") then
				return
			end
			if(text ~= default_searchBox and guiGetText(guiGetSelectedTab(gridTabPanel)) == "Alias" and searchAliasFlag == true) then
				searchAliasFlag = false
				guiSetEnabled(searchBtn, searchAliasFlag) -- WTF
				setAfterSearch()
				triggerServerEvent("onClientSearch", localPlayer, text, 1)
			elseif(text ~= default_searchBox and guiGetText(guiGetSelectedTab(gridTabPanel)) == "Warns" and searchWarnsFlag == true) then
				searchWarnsFlag = false
				guiSetEnabled(searchBtn, searchWarnsFlag)
				setAfterSearch()
				triggerServerEvent("onClientSearch", localPlayer, text, 2)
			elseif(text ~= default_searchBox and guiGetText(guiGetSelectedTab(gridTabPanel)) == "Unbans" and searchUnbansFlag == true) then
				searchUnbansFlag = false
				guiSetEnabled(searchBtn, searchUnbansFlag)
				setAfterSearch()
				triggerServerEvent("onClientSearch", localPlayer, text, 3)
			end
		-- Alias grid list action
		elseif(source == aliasGrid) then
			local item = guiGridListGetItemText(aliasGrid, guiGridListGetSelectedItem(aliasGrid), 3)
			if(item == "") then return end
			guiSetText(searchBox, item)
		-- Warns grid list action
		elseif(source == warnsGrid) then 
			local item = guiGridListGetItemText(warnsGrid, guiGridListGetSelectedItem(warnsGrid), 3)
			if(item == "") then return end
			guiSetText(searchBox, item)
		-- Unbans grid list action
		elseif(source == unbansGrid) then 
			local item = guiGridListGetItemText(unbansGrid, guiGridListGetSelectedItem(unbansGrid), 3)
			if(item == "") then return end
			guiSetText(searchBox, item)
		-- Ban button action
		elseif(source == banBtn) then
			local serial = guiGetText(searchBox)
			if(serial == "" or serial == default_searchBox) then return outputChatBox("Enter serial number in search box to ban!", 255, 0, 0, true) end
			reason, seconds = getReasonAndPeriod(0)
			if(not reason or not seconds) then return end
			triggerServerEvent("onSerialBan", localPlayer, serial, reason, seconds)
		-- Unban button action
		elseif(source == unbanBtn) then
			local serial = guiGetText(searchBox)
			if(serial == "" or serial == default_searchBox) then return outputChatBox("Enter serial number in search box to unban!", 255, 0, 0, true) end
			triggerServerEvent("onSerialUnban", localPlayer, serial)
		-- Mute button action
		elseif(source == muteBtn) then
			local serial = guiGetText(searchBox)
			if(serial == "" or serial == default_searchBox) then return outputChatBox("Enter serial number in search box to mute!", 255, 0, 0, true) end
			reason, seconds = getReasonAndPeriod(0)
			if(not reason or not seconds) then return end
			triggerServerEvent("onSerialMute", localPlayer, serial, seconds, reason)
		-- Unmute button action
		elseif(source == unmuteBtn) then
			local serial = guiGetText(searchBox)
			if(serial == "" or serial == default_searchBox) then return outputChatBox("Enter serial number in search box to unmute!", 255, 0, 0, true) end
			triggerServerEvent("onSerialUnmute", localPlayer, serial)
		-- Close button action
		elseif(source == closeBtn) then
			toggleVisibility()
		-- Kick button action
		elseif(source == kickBtn) then
			local serial = guiGetText(searchBox)
			if(serial == "" or serial == default_searchBox) then return outputChatBox("Enter serial number in search box to kick!", 255, 0, 0, true) end
			reason, seconds = getReasonAndPeriod(1)
			if(not reason) then return end
			local adminName = getPlayerName(localPlayer):gsub('#%x%x%x%x%x%x', '')
			triggerServerEvent("onSerialKick", localPlayer, serial, reason)
		-- Refresh button action
		elseif(source == defaultBtn) then
			setDefault(0)
		-- Warn button action
		elseif(source == warnBtn) then
			local serial = guiGetText(searchBox)
			if(serial == "" or serial == default_searchBox) then return outputChatBox("Enter serial number in search box to warn!", 255, 0, 0, true) end
			reason, seconds = getReasonAndPeriod(1)
			if(not reason) then return end
			local adminName = getPlayerName(localPlayer):gsub('#%x%x%x%x%x%x', '')
			triggerServerEvent("onSerialWarn", localPlayer, serial, reason)
		-- Unwarn button action
		elseif(source == unwarnBtn) then
			if(guiGetText(guiGetSelectedTab(gridTabPanel)) ~= "Warns") then return outputChatBox("Choose a row from Warns grid. Hence: the other tab.", 255, 0, 0, true) end
			local serial = guiGetText(searchBox)
			if(serial == "" or serial == default_searchBox) then return outputChatBox("Enter serial number in search box to unwarn!", 255, 0, 0, true) end
			local rowID = guiGridListGetItemText(warnsGrid, guiGridListGetSelectedItem(warnsGrid), 1)
			if(rowID == 0 or rowID == "") then return outputChatBox("Click on a row from the grid list to select a player!", 255, 0, 0, true) end
			triggerServerEvent("onSerialUnwarn", localPlayer, serial, rowID)
		end
	end
end
addEventHandler("onClientGUIClick", root, buttonHandler)


function warnPlayer(cmd, playerPartial, reason)
	if(not reason) then return outputChatBox("Please insert a warn reason", 255, 0, 0, true) end
	local thePlayer = getPlayerFromPartialName(playerPartial)
	local serial = getPlayerSerial(thePlayer)
	if(thePlayer) then
		triggerServerEvent("onSerialWarn", localPlayer, serial, reason)
	else
		outputChatBox("Player not found!", 255, 0, 0, true)
	end
end
addCommandHandler("warn", warnPlayer)



function getReasonAndPeriod(int)

	local selectedTab = guiGetSelectedTab(tabPanel)

	if(selectedTab == monthsTab) then
	
		reason = guiGetText(penaltyBox[1])
		if(reason == "Penalty reason..." or reason == "") then
			outputChatBox("Enter a reason in the penalty reason box below!", 255, 0, 0, true)
			return false,false
		end
		if(int == 1) then return reason, false end
		local m1 = guiRadioButtonGetSelected(radio[1])
		local m2 = guiRadioButtonGetSelected(radio[2])
		local m3 = guiRadioButtonGetSelected(radio[3])
		local m4 = guiRadioButtonGetSelected(radio[4])
		if(not m1 and not m2 and not m3 and not m4) then
			outputChatBox("Choose a penalty period from the panel below!", 255, 0, 0, true)
			return false,false
		end
		if(m1) then return reason, "31104000"		-- 12 months
		elseif(m2) then return reason, "15552000"	-- 6 months
		elseif(m3) then return reason, "7776000"	-- 3 months
		elseif(m4) then return reason, "2592000"	-- 1 month
		end
	elseif(selectedTab == daysTab) then
	
		reason = guiGetText(penaltyBox[2])
		if(reason == "") then
			outputChatBox("Enter a reason in the penalty reason box below!", 255, 0, 0, true)
			return false,false
		end
		if(int == 1) then return reason, false end
		local d1 = guiRadioButtonGetSelected(radio[5]) 
		local d2 = guiRadioButtonGetSelected(radio[6]) 
		local d3 = guiRadioButtonGetSelected(radio[7]) 
		local d4 = guiRadioButtonGetSelected(radio[8]) 
		if(not d1 and not d2 and not d3 and not d4) then
			outputChatBox("Choose a penalty period from the panel below!", 255, 0, 0, true)
			return false,false
		end
		if(d1) then return reason, "1296000"		-- 15 days
		elseif(d2) then return reason, "604800"		-- 7 days
		elseif(d3) then return reason, "259200"		-- 3 days
		elseif(d4) then return reason, "86400"		-- 1 day
		end
	elseif(selectedTab == hoursTab) then

		reason = guiGetText(penaltyBox[3])
		if(reason == "") then
			outputChatBox("Enter a reason in the penalty reason box below!", 255, 0, 0, true)
			return false,false
		end
		if(int == 1) then return reason, false end
		local h1 = guiRadioButtonGetSelected(radio[9]) 
		local h2 = guiRadioButtonGetSelected(radio[10]) 
		local h3 = guiRadioButtonGetSelected(radio[11]) 
		local h4 = guiRadioButtonGetSelected(radio[12]) 
		if(not h1 and not h2 and not h3 and not h4) then
			outputChatBox("Choose a penalty period from the panel below!", 255, 0, 0, true)
			return false,false
		end
		if(h1) then return reason, "43200"			-- 12 hours
		elseif(h2) then return reason, "21600"		-- 6 hours
		elseif(h3) then return reason, "10800"		-- 3 hours
		elseif(h4) then return reason, "3600"		-- 1 hour
		end
	elseif(selectedTab == minutesTab) then

		reason = guiGetText(penaltyBox[4])
		if(reason == "") then
			outputChatBox("Enter a reason in the penalty reason box below!", 255, 0, 0, true)
			return false,false
		end
		if(int == 1) then return reason, false end
		local n1 = guiRadioButtonGetSelected(radio[13]) 
		local n2 = guiRadioButtonGetSelected(radio[14]) 
		local n3 = guiRadioButtonGetSelected(radio[15]) 
		local n4 = guiRadioButtonGetSelected(radio[16]) 
		if(not n1 and not n2 and not n3 and not n4) then
			outputChatBox("Choose a penalty period from the panel below!", 255, 0, 0, true)
			return false,false
		end
		if(n1) then return reason, "1800"			-- 30 minutes
		elseif(n2) then return reason, "900"		-- 15 minutes
		elseif(n3) then return reason, "600"		-- 10 minutes
		elseif(n4) then return reason, "300"		-- 5 minutes
		end
	elseif(selectedTab == permTab) then

		reason = guiGetText(penaltyBox[5])
		if(reason == "" or reason == "Use permanent bans for extreme cases only!") then
			outputChatBox("Enter a wise permanent reason in the penalty reason box below!", 255, 0, 0, true)
			return false,false
		end
		if(int == 1) then return reason, false end
		local n1 = guiRadioButtonGetSelected(radio[17]) 
		if(not n1) then
			outputChatBox("Choose a penalty period from the panel below!", 255, 0, 0, true)
			return false,false
		end
		if(n1) then
			return reason, "0"		-- permanent
		end
	end
end



function enableEnter(button, press)
	if(button == "enter" and press) then
		local text = guiGetText(searchBox)
		if(text == "" or text == default_searchBox) then
			return
		end
		if(guiGetText(guiGetSelectedTab(gridTabPanel)) == "Alias" and searchAliasFlag == true) then
			searchAliasFlag = false
			guiSetEnabled(searchBtn,searchAliasFlag)
			setAfterSearch()
			triggerServerEvent("onClientSearch", localPlayer, text, 1)
		elseif(guiGetText(guiGetSelectedTab(gridTabPanel)) == "Warns"  and searchWarnsFlag == true) then
			searchWarnsFlag = false
			guiSetEnabled(searchBtn,searchWarnsFlag)
			setAfterSearch()
			triggerServerEvent("onClientSearch", localPlayer, text, 2)
		elseif(guiGetText(guiGetSelectedTab(gridTabPanel)) == "Unbans"  and searchUnbansFlag == true) then
			searchUnbansFlag = false
			guiSetEnabled(searchBtn,searchUnbansFlag)
			setAfterSearch()
			triggerServerEvent("onClientSearch", localPlayer, text, 3)
		end
	end
end 
addEventHandler("onClientKey", root, enableEnter)



function updateList(list, int, c, divergent) 
	if(int == 1) then 
		guiGridListClear(aliasGrid)
		guiGridListClear(warnsGrid)
		guiGridListClear(unbansGrid)
	end
	if(divergent == 1) then
		iC = c
		if(idCol and nameCol and serialCol and IPCol and banCol and adminCol and dateCol and reasonCol) then
			bansDelayFlag = true
			guiSetEnabled (addRowsBtn,bansDelayFlag)
			searchAliasFlag = true
			guiSetEnabled (searchBtn,searchAliasFlag)
			for k, v in pairs(list) do 
				row = guiGridListAddRow(aliasGrid)
				guiGridListSetItemText(aliasGrid, row, idCol, v.id, false, false)
		    	guiGridListSetItemText(aliasGrid, row, nameCol, v.nickname or "", false, false)
		    	guiGridListSetItemText(aliasGrid, row, serialCol, v.serial, false, false)
		    	guiGridListSetItemText(aliasGrid, row, IPCol, v.ip or "", false, false)
		    	guiGridListSetItemText(aliasGrid, row, banCol, v.banstatus, false, false)
		    	guiGridListSetItemText(aliasGrid, row, dateCol, v.dateline or "", false, false)
		    	guiGridListSetItemText(aliasGrid, row, adminCol, v.admin or "", false, false)
		    	guiGridListSetItemText(aliasGrid, row, reasonCol, v.reason or "", false, false)
			end
		else
			outputDebugString("Syncing Error: Try restarting Alias System resource.", 3, 255, 0, 0)
		end
	elseif(divergent == 2) then
		iC2 = c
		if(idCol2 and nameCol2 and serialCol2 and IPCol2 and adminCol2 and dateCol2 and reasonCol2) then
			warnsDelayFlag = true
			guiSetEnabled (addRowsBtn,warnsDelayFlag)
			searchWarnsFlag = true
			guiSetEnabled (searchBtn,searchWarnsFlag)
			for r, i in pairs(list) do 
				row = guiGridListAddRow(warnsGrid)
				guiGridListSetItemText(warnsGrid, row, idCol2, i.id, false, false)
		    	guiGridListSetItemText(warnsGrid, row, nameCol2, i.nickname or "", false, false)
		    	guiGridListSetItemText(warnsGrid, row, serialCol2, i.serial, false, false)
		    	guiGridListSetItemText(warnsGrid, row, IPCol2, i.ip or "", false, false)
		    	guiGridListSetItemText(warnsGrid, row, dateCol2, i.dateline or "", false, false)
		    	guiGridListSetItemText(warnsGrid, row, adminCol2, i.admin or "", false, false)
		    	guiGridListSetItemText(warnsGrid, row, reasonCol2, i.reason or "", false, false)
			end
		else
			outputDebugString("Syncing Error: Try restarting Alias System resource.", 3, 255, 0, 0)
		end
	elseif(divergent == 3) then
		iC3 = c
		if(idCol3 and nameCol3 and serialCol3 and adminCol3 and dateCol3) then
			unbansDelayFlag = true
			guiSetEnabled (addRowsBtn,unbansDelayFlag)
			searchUnbansFlag = true
			guiSetEnabled (searchBtn,searchUnbansFlag)
			for m, n in pairs(list) do 
				row = guiGridListAddRow(unbansGrid)
				guiGridListSetItemText(unbansGrid, row, idCol3, n.id, false, false)
		    	guiGridListSetItemText(unbansGrid, row, nameCol3, n.nickname or "", false, false)
		    	guiGridListSetItemText(unbansGrid, row, serialCol3, n.serial, false, false)
		    	guiGridListSetItemText(unbansGrid, row, dateCol3, n.dateline or "", false, false)
		    	guiGridListSetItemText(unbansGrid, row, adminCol3, n.admin or "", false, false)
			end
		else
			outputDebugString("Syncing Error: Try restarting Alias System resource.", 3, 255, 0, 0)
		end
	end
end
addEvent("onServerListUpdate", true)
addEventHandler("onServerListUpdate", root, updateList)