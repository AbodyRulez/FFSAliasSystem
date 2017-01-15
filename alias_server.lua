--[[ Author: -ffs-AbodyRulez
Check tables folder for more detailed information about the tables.
dbname: aliasdb   dbtables: warns - bans  
bans table columns: id A_I - nickname - userid - serial - ip - dateline - banstatus - reason - admin - adminuserid
warns table columns: id A_I - nickname - userid - serial - ip - dateline - reason - admin - adminuserid
unbans table columns: id A_I - nickname - serial - dateline - admin - adminuserid]]

function connectDB()
	db = dbConnect( "mysql", "dbname=wwdev;host=37.187.165.60","wwdev","aGrTlTYEEZRkCnaTRU")
	--db = dbConnect( "mysql", "dbname=aliasdb;host=localhost","root","")
	
	if (db) then
		outputDebugString("Connection to database successful")
	else
		outputDebugString("Connection to database failed")
	end
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), connectDB)


--[[ --clears all database records
function cleanDatabase(player)
	dbExec( db, "TRUNCATE bans")
	dbExec( db, "TRUNCATE warns")
	dbExec( db, "TRUNCATE unbans")
end
addCommandHandler("truncateall", cleanDatabase)
]]

function getPlayerFromSerial ( serial )
    assert ( type ( serial ) == "string" and #serial == 32, "getPlayerFromSerial - invalid serial" )
    for index, player in ipairs ( getElementsByType ( "player" ) ) do
        if ( getPlayerSerial ( player ) == serial ) then
            return player
        end
    end
    return false
end


function isValidSerial(thePlayer, serial)
	if(type ( serial ) == "string" and #serial == 32) then
		return true
	else
		outputChatBox("Invalid serial entry!", thePlayer, 255, 0, 0, true)
		return false
	end
end

function capturePlayerLogin(isGuest) -- on FFS server
	if not (db) then return outputDebugString("Database Error: Please contact -ffs-AbodyRulez!", 3, 255, 0, 0) end
	local playerName = getPlayerName(source):gsub('#%x%x%x%x%x%x', '')
	local playerSerial = getPlayerSerial(source)
	local playerIP = getPlayerIP(source)
	local infoQuery = dbQuery(db, "SELECT id FROM bans WHERE serial=? and ip=? and LOWER(nickname)=? LIMIT 1", playerSerial, playerIP, string.lower(playerName))
	local infoResult = dbPoll( infoQuery, -1)
	if(#infoResult > 0) then return end
	local userid = tonumber(getElementData(source, "userid")) or 0	
	dbExec( db, "INSERT INTO bans VALUES (?,?,?,?,?,?,?,?,?,?)", nil, playerName, userid, playerSerial, playerIP, nil, "No", nil, nil, nil)
end
addEvent("onPlayerFFSLogin", true)
addEventHandler("onPlayerFFSLogin", root, capturePlayerLogin)

--[[  on a regular server
function capturePlayerJoin()
	if not (db) then return outputDebugString("Database Error: Please contact -ffs-AbodyRulez!", 3, 255, 0, 0) end
	local playerName = getPlayerName(source):gsub('#%x%x%x%x%x%x', '')
	local playerSerial = getPlayerSerial(source)
	local playerIP = getPlayerIP(source)
	local infoQuery = dbQuery(db, "SELECT id FROM bans WHERE serial=? and ip=? and LOWER(nickname)=? LIMIT 1", playerSerial, playerIP, string.lower(playerName))
	local infoResult = dbPoll( infoQuery, -1)
	if(#infoResult > 0) then return end
	local userid = tonumber(getElementData(source, "userid")) or 0
	dbExec( db, "INSERT INTO bans VALUES (?,?,?,?,?,?,?,?,?,?)", nil, playerName, userid, playerSerial, playerIP, nil, "No", nil, nil, nil)
end
addEventHandler("onPlayerJoin", root, capturePlayerJoin)
]]

function toggleVisibility(playerSource)
	if not (hasObjectPermissionTo(playerSource, "function.kickPlayer", false)) then return end
	triggerClientEvent(playerSource, "onAdminToggleVisibility", playerSource)
end
addCommandHandler("alias", toggleVisibility)

function capturePlayerChangeNick(oldNick, newNick)
	if not (db) then return outputDebugString("Database Error: Please contact -ffs-AbodyRulez!", 3, 255, 0, 0) end
	local playerName = newNick:gsub('#%x%x%x%x%x%x', '')
	local playerSerial = getPlayerSerial(source)
	local playerIP = getPlayerIP(source)
	local infoQuery = dbQuery(db, "SELECT id FROM bans WHERE serial=? and ip=? and LOWER(nickname)=? LIMIT 1", playerSerial, playerIP, string.lower(playerName))
	local infoResult = dbPoll( infoQuery, -1)
	if(#infoResult > 0) then return end
	local userid = tonumber(getElementData(source, "userid")) or 0
	dbExec(db, "INSERT INTO bans VALUES (?,?,?,?,?,?,?,?,?,?)", nil, playerName, userid, playerSerial, playerIP, nil, "No", nil, nil, nil)
end
addEventHandler("onPlayerChangeNick", root, capturePlayerChangeNick)



function capturePlayerBan(theBan, admin)
	if not (db) then return outputDebugString("Database Error: Please contact -ffs-AbodyRulez!", 3, 255, 0, 0) end
	local playerSerial = getPlayerSerial(source)
	local adminName = getPlayerName(admin):gsub('#%x%x%x%x%x%x', '')
	local playerName = getPlayerName(source):gsub('#%x%x%x%x%x%x', '')
	local reason = getBanReason(theBan)
	local newReason = split(reason, "(")
	local ip = getPlayerIP(source)
	local userid =  tonumber(getElementData(source, "userid")) or 0
	local adminid = tonumber(getElementData(admin, "userid")) or 0
	local realTime = getRealTime()
	local banDate = string.format("%04d/%02d/%02d", realTime.year + 1900, realTime.month + 1, realTime.monthday)
	dbExec(db, "UPDATE bans SET banstatus=?, dateline=?, admin=?, reason=?, adminuserid=? WHERE serial=?", "Yes", banDate, adminName, newReason[1], adminid, playerSerial)
end
addEventHandler("onPlayerBan", root, capturePlayerBan)



function capturePlayerUnban(theBan, responsibleElement)
	if not (db) then return outputDebugString("Database Error: Please contact -ffs-AbodyRulez!", 3, 255, 0, 0) end
	local serial = getBanSerial(theBan)
	local infoQuery = dbQuery(db, "SELECT id, nickname FROM bans WHERE serial=? ORDER BY id DESC LIMIT 1", serial)
	local infoResult = dbPoll( infoQuery, -1)
	local realTime = getRealTime()
	local unbanDate = string.format("%04d/%02d/%02d", realTime.year + 1900, realTime.month + 1, realTime.monthday)
	local adminName = ""
	local adminid = 0
	local banUsername = ""
	if(responsibleElement) then -- Admin unbanned
		adminid = tonumber(getElementData(responsibleElement, "userid")) or 0
		adminName =  getPlayerName(responsibleElement):gsub('#%x%x%x%x%x%x', '')
	else -- Period done
		adminName = "Penalty period over"
	end
	if(infoResult[1].nickname == false) then -- Serial banned with no nickname
		dbExec(db, "DELETE FROM bans WHERE serial=? and id=?", serial, infoResult[1].id)
		triggerClientEvent(source, "afterSearchEnabled", source)
		searchDB(serial, 1)
	else -- nickname exist
		banUsername = infoResult[1].nickname	
	end
	dbExec(db, "INSERT INTO unbans VALUES (?,?,?,?,?,?)", nil, banUsername, serial, unbanDate, adminName, adminid)
	dbExec(db, "UPDATE bans SET banstatus=?, dateline=?, admin=?, reason=?, adminuserid=? WHERE serial=?", "No", nil, nil, nil,nil, serial)
end
addEventHandler("onUnban", root, capturePlayerUnban)



function updateList(iC)
	if not (db) then return outputDebugString("Database Error: Please contact -ffs-AbodyRulez!", 3, 255, 0, 0) end
	local query = dbQuery( db, "SELECT id, nickname, serial, ip, dateline, banstatus, reason, admin FROM bans LIMIT ?,?", iC, 5)
	local result = dbPoll( query, -1)
	local viewCounter = iC + tonumber(#result) or 0
	triggerClientEvent(source, "onServerListUpdate", source, result, 0, viewCounter, 1)
end
addEvent("onListUpdated", true)
addEventHandler("onListUpdated", root, updateList)



function updateWarns(iC2)
	if not (db) then return outputDebugString("Database Error: Please contact -ffs-AbodyRulez!", 3, 255, 0, 0) end
	local query = dbQuery( db, "SELECT id, nickname, serial, ip, dateline, reason, admin FROM warns LIMIT ?,?", iC2, 5)
	local result = dbPoll( query, -1)
	local viewCounter = iC2 + tonumber(#result) or 0
	triggerClientEvent(source, "onServerListUpdate", source, result, 0, viewCounter, 2)
end
addEvent("onUpdateWarns", true)
addEventHandler("onUpdateWarns", root, updateWarns)



function updateUnbans(iC3)
	if not (db) then return outputDebugString("Database Error: Please contact -ffs-AbodyRulez!", 3, 255, 0, 0) end
	local query = dbQuery( db, "SELECT id, nickname, serial, dateline, admin FROM unbans LIMIT ?,?", iC3, 5)
	local result = dbPoll( query, -1)
	local viewCounter = iC3 + tonumber(#result) or 0
	triggerClientEvent(source, "onServerListUpdate", source, result, 0, viewCounter, 3)
end
addEvent("onUpdateUnbans", true)
addEventHandler("onUpdateUnbans", root, updateUnbans)




function searchDB(text, div)
	if not (db) then return outputDebugString("Database Error: Please contact -ffs-AbodyRulez!", 3, 255, 0, 0) end
	local query = nil
	if(div == 1) then
		query = dbQuery( db, "SELECT id, nickname, serial, ip, dateline, banstatus, reason, admin FROM bans WHERE userid LIKE '??%' or userid LIKE '%??%' or id=? or serial LIKE '??%' or serial LIKE '%??%' or LOWER(nickname) LIKE '??%' or LOWER(nickname) LIKE '%??%' or ip LIKE '??%' or ip LIKE '%??%'", text, text, text, text, text, text, text, text, text)
	elseif(div == 2) then
		query = dbQuery( db, "SELECT id, nickname, serial, ip, dateline, reason, admin FROM warns WHERE userid LIKE '??%' or userid LIKE '%??%' or id=? or serial LIKE '??%' or serial LIKE '%??%' or LOWER(nickname) LIKE '??%' or LOWER(nickname) LIKE '%??%' or ip LIKE '??%' or ip LIKE '%??%'", text, text, text, text, text, text, text, text)
	elseif(div == 3) then
		query = dbQuery( db, "SELECT id, nickname, serial, dateline, admin FROM unbans WHERE id=? or serial LIKE '??%' or serial LIKE '%??%' or LOWER(nickname) LIKE '??%' or LOWER(nickname) LIKE '%??%'", text, text, text, text, text)		
	end	
	local result = dbPoll( query, -1)
	triggerClientEvent(source, "onServerListUpdate", source, result, 1, 0, div)
end
addEvent("onClientSearch", true)
addEventHandler("onClientSearch", root, searchDB)



function secondsToTimeDesc( seconds )
	if seconds then
		local results = {}
		local sec = ( seconds %60 )
		local min = math.floor ( ( seconds % 3600 ) /60 )
		local hou = math.floor ( ( seconds % 86400 ) /3600 )
		local day = math.floor ( seconds /86400 )
 
		if day > 0 then table.insert( results, day .. ( day == 1 and " day" or " days" ) ) end
		if hou > 0 then table.insert( results, hou .. ( hou == 1 and " hour" or " hours" ) ) end
		if min > 0 then table.insert( results, min .. ( min == 1 and " minute" or " minutes" ) ) end
		if sec > 0 then table.insert( results, sec .. ( sec == 1 and " second" or " seconds" ) ) end
 
		return string.reverse ( table.concat ( results, ", " ):reverse():gsub(" ,", " dna ", 1 ) )
	end
	return ""
end



function banSelectedSerial(serial, reason, seconds)
	if(not isValidSerial(source, serial)) then return end
	local thePlayer = getPlayerFromSerial(serial)
	if(thePlayer) then -- player online
		local name = getPlayerName(thePlayer):gsub('#%x%x%x%x%x%x', '')
		local time = tostring(seconds)
		executeCommandHandler("ban",source ,name.." "..time.." "..reason)
	else -- player offline
		local ban = addBan(nil, nil, serial, source, reason, tonumber(seconds))
		if(isBan(ban) == false) then return outputChatBox("Incorrect serial number or player already banned!",source , 255, 0, 0, false) end
		if not (db) then return outputDebugString("Database Error: Please contact -ffs-AbodyRulez!", 3, 255, 0, 0) end
		local infoQuery = dbQuery(db, "SELECT nickname FROM bans WHERE serial=? ORDER BY id DESC LIMIT 1", serial)
		local infoResult = dbPoll( infoQuery, -1)
		local adminid = tonumber(getElementData(source, "userid")) or 0
		local adminName = getPlayerName(source):gsub('#%x%x%x%x%x%x', '')
		local realTime = getRealTime()
		local banDate = string.format("%04d/%02d/%02d", realTime.year + 1900, realTime.month + 1, realTime.monthday)
		local realBanTime = ""
		if(tonumber(seconds) == 0) then 
			realBanTime = "permanent"
		else
			realBanTime = secondsToTimeDesc(seconds)
		end
		if(#infoResult>0)then
			outputChatBox(infoResult[1].nickname.." has been banned by "..adminName..". ("..reason..") ("..realBanTime..")", root, 255, 0, 0, false)
			dbExec(db, "UPDATE bans SET banstatus=?, dateline=? , admin=?, reason=?, adminuserid=? WHERE serial=?", "Yes", banDate, adminName, reason, adminid, serial)
		else
			outputChatBox("Serial: "..serial.." has been banned by "..adminName..". ("..reason..") ("..realBanTime..")", root, 255, 0, 0, false)
			dbExec(db, "INSERT INTO bans VALUES (?,?,?,?,?,?,?,?,?,?)", nil, nil, 0, serial, nil, banDate, "Yes", reason, adminName, adminid)
		end
	end
end
addEvent("onSerialBan", true)
addEventHandler("onSerialBan", root, banSelectedSerial)



function unbanSelectedSerial(serial)
	if(not isValidSerial(source, serial)) then return end
	local unbanned = false
	for index, ban in pairs(getBans()) do
		if (getBanSerial(ban) ~= serial) then
		-- keep counting
		else
			unbanned = removeBan(ban, source)
			if(unbanned) then
				local infoQuery = dbQuery(db, "SELECT nickname FROM bans WHERE serial=? ORDER BY id DESC LIMIT 1", serial)
				local infoResult = dbPoll( infoQuery, -1)
				if(#infoResult>0) then
					outputChatBox(infoResult[1].nickname.." has been unbanned by "..getPlayerName(source):gsub('#%x%x%x%x%x%x', '')..".", root, 0, 255, 0, false)
				else
					outputChatBox("Serial: "..serial.." has been unbanned by "..getPlayerName(source):gsub('#%x%x%x%x%x%x', '')..".", root, 0, 255, 0, false)
				end
				return
			end
		end
	end
	return outputChatBox("Serial not found in ban list", source, 255, 0, 0, false)
end
addEvent("onSerialUnban", true)
addEventHandler("onSerialUnban", root, unbanSelectedSerial)



function muteSelectedSerial(serial, seconds, reason)
	if(not isValidSerial(source, serial)) then return end
	local thePlayer = getPlayerFromSerial(serial)
	if(not thePlayer) then return outputChatBox("Player is offline!", source, 255, 0, 0, true) end
	if(isPlayerMuted(thePlayer)) then return end
	local name = getPlayerName(thePlayer):gsub('#%x%x%x%x%x%x', '')
	local time = tostring(seconds)
	executeCommandHandler("mute",source ,name.." "..time.." "..reason)
end
addEvent("onSerialMute", true)
addEventHandler("onSerialMute", root, muteSelectedSerial)



function unmuteSelectedSerial(serial)
	if(not isValidSerial(source, serial)) then return end
	local thePlayer = getPlayerFromSerial(serial)
	if(not thePlayer) then return outputChatBox("Player is offline!", source, 255, 0, 0, true) end
	if(not isPlayerMuted(thePlayer)) then return outputChatBox("Player is not muted!", source, 255, 0, 0, true) end
	local name = getPlayerName(thePlayer):gsub('#%x%x%x%x%x%x', '')
	executeCommandHandler("mute", source, name)
end
addEvent("onSerialUnmute", true)
addEventHandler("onSerialUnmute", root, unmuteSelectedSerial)



function warnSelectedSerial(serial, reason)
	if(not isValidSerial(source, serial)) then return end
	if not (db) then return outputDebugString("Database Error: Please contact -ffs-AbodyRulez!", 3, 255, 0, 0) end
	local infoQuery = dbQuery(db, "SELECT id FROM warns WHERE serial=?", serial)
	local infoResult = dbPoll( infoQuery, -1)
	local infoQuery2 = dbQuery(db, "SELECT nickname, userid, ip FROM bans WHERE serial=? AND nickname IS NOT NULL ORDER BY id DESC LIMIT 1", serial)
	local infoResult2 = dbPoll( infoQuery2, -1)
	if(#infoResult2 == 0) then return outputChatBox("Serial not found in players database", source, 255, 0, 0, false) end
	local adminName = getPlayerName(source):gsub('#%x%x%x%x%x%x', '')
	local adminid = tonumber(getElementData(source, "userid")) or 0
	local realTime = getRealTime()
	local warnDate = string.format("%04d/%02d/%02d", realTime.year + 1900, realTime.month + 1, realTime.monthday)
	local userid = infoResult2[1].userid
	local playerIP = infoResult2[1].ip
	local playerName = infoResult2[1].nickname
	dbExec(db, "INSERT INTO warns VALUES (?,?,?,?,?,?,?,?,?)", nil, playerName, userid, serial, playerIP, warnDate, reason, adminName, adminid)
	triggerClientEvent(source, "afterSearchEnabled", source)
	searchDB(serial, 2)
	outputChatBox(playerName.." got warned by "..adminName..". (Reason: "..reason..") (Count: "..tostring(#infoResult+1)..")", root, 255, 0, 0, false)
	if(#infoResult == 2) then -- 3 warns
		banSelectedSerial(serial, "Automatic ban for 3rd warning", 259200) -- 3 days
	elseif(#infoResult == 3) then-- 4 warns
		banSelectedSerial(serial, "Automatic ban for 4th warning", 432000) -- 5 days
	elseif(#infoResult == 4) then -- 5 warns
		banSelectedSerial(serial, "Automatic ban for 5th warning", 604800) -- 7 days
	elseif(#infoResult >= 9) then -- 10 warns
		banSelectedSerial(serial, "Automatic ban for 10th warning", 2592000) -- 1 month
	end
end
addEvent("onSerialWarn", true)
addEventHandler("onSerialWarn", root, warnSelectedSerial)



function unwarnSelectedSerial(serial, id)
	if(not isValidSerial(source, serial)) then return end
	if not (db) then return outputDebugString("Database Error: Please contact -ffs-AbodyRulez!", 3, 255, 0, 0) end
	local infoQuery = dbQuery(db, "SELECT id, nickname FROM warns WHERE serial=? and id=?", serial, id)
	local infoResult = dbPoll( infoQuery, -1)
	if(#infoResult == 0) then return outputChatBox("Serial not found in warns database", source, 255, 0, 0, false) end
	dbExec(db, "DELETE FROM warns WHERE serial=? and id=?", serial, id)
	local infoQuery2 = dbQuery(db, "SELECT id FROM warns WHERE serial=?", serial)
	local infoResult2 = dbPoll( infoQuery2, -1)
	outputChatBox(infoResult[1].nickname.." got unwarned by "..getPlayerName(source):gsub('#%x%x%x%x%x%x', '')..". (Count: "..tostring(#infoResult2)..")", root, 0, 255, 0, false)
	triggerClientEvent(source, "afterSearchEnabled", source)
	searchDB(serial, 2)
end
addEvent("onSerialUnwarn", true)
addEventHandler("onSerialUnwarn", root, unwarnSelectedSerial)


function kickSelectedSerial(serial, reason)
	if(not isValidSerial(source, serial)) then return end
	local kicked = false
	local kickedPlayer = getPlayerFromSerial(serial)
	if(not kickedPlayer) then return outputChatBox("Player is offline!", source, 255, 0, 0, true) end
	local name = getPlayerName(kickedPlayer)
	executeCommandHandler("kick",source ,name.." "..reason)
end
addEvent("onSerialKick", true)
addEventHandler("onSerialKick", root, kickSelectedSerial)



function disconnectDB()
	if(destroyElement(db)) then
		outputDebugString("Connection to database closed")
	else
		outputDebugString("Connection to database failed to close")
	end
end
addEventHandler("onResourceStop", getResourceRootElement(getThisResource()), disconnectDB)