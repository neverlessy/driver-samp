function getRoute()
	if isPlayerPlaying(playerHandle) then
			local posX, posY, posZ = getCharCoordinates(playerPed)
			local res, x, y, z = SearchMarker(posX, posY, posZ, 150.0, false)
			if x ~= 1348 or x ~= 1342 then
				if math.floor(x) == 1387 or math.floor(y) == 1181 or math.floor(z) == 9 then
					local a, b = math.modf(x)
					sampAddChatMessage("a: "..a.." b:"..b, -1)
					if b == 0.54833984375 then
						route = routes[3]
					end
					if b == 0.989013671875 then
						route = routes[1]
					else
						routeTrip = u8"1"
					end
				end
				if math.floor(x) == -2249 or math.floor(y) == 304 or math.floor(z) == 33 then
					route = routes[2]
				end
				if math.floor(x) == 2187 or math.floor(y) == -2659 or math.floor(z) == 12 then
					route = routes[4]
				end
				if math.floor(x) == -2254 or math.floor(y) == 233 or math.floor(z) == 33 then
					route = routes[5]
				end
				if math.floor(x) == 2227 or math.floor(y) == -2636 or math.floor(z) == 11 then
					route = routes[6]
				end
			end
	end
	if route == nil then
		route = u8"Неизвестно"
	end
	return route
end

function SearchMarker(posX, posY, posZ, radius, isRace)
    local ret_posX = 0.0
    local ret_posY = 0.0
    local ret_posZ = 0.0
		local radius = 250
    local isFind = false

    for id = 0, 31 do
        local MarkerStruct = 0
        if isRace then MarkerStruct = 0xC7F168 + id * 56
        else MarkerStruct = 0xC7DD88 + id * 160 end
        local MarkerPosX = representIntAsFloat(readMemory(MarkerStruct + 0, 4, false))
        local MarkerPosY = representIntAsFloat(readMemory(MarkerStruct + 4, 4, false))
        local MarkerPosZ = representIntAsFloat(readMemory(MarkerStruct + 8, 4, false))

        if MarkerPosX ~= 0.0 or MarkerPosY ~= 0.0 or MarkerPosZ ~= 0.0 then
            if getDistanceBetweenCoords3d(MarkerPosX, MarkerPosY, MarkerPosZ, posX, posY, posZ) < radius then
                ret_posX = MarkerPosX
                ret_posY = MarkerPosY
                ret_posZ = MarkerPosZ
                isFind = true
                radius = getDistanceBetweenCoords3d(MarkerPosX, MarkerPosY, MarkerPosZ, posX, posY, posZ)
            end
					end
    end

    return isFind, ret_posX, ret_posY, ret_posZ
end
