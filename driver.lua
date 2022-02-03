script_name("Driver")
script_authors("neverlessy")
script_version("1.2")

require "lib.moonloader"
require 'sampfuncs'
require 'vkeys'

local enc = require 'encoding'
enc.default = 'CP1251'
local u8 = enc.UTF8

local ev = require 'samp.events'
local vk = require 'vkeys'
local ffi = require 'ffi'
local imgui = require 'imgui'
local memory = require 'memory'
local inicfg = require 'inicfg'
local toggle = false
local final = false
local startTrip = false
local work = false
local activatedDriver = true
local arr = {}
local tag = "{e6c495}[Driver] {f9ecda}"
local scriptVersion = "1.2"
local main_window_state = imgui.ImBool(false)
local ScreenX, ScreenY = getScreenResolution()
--------------------------------------------------------------
local totalTrailers = 0
local truckExp = 0
local sessionTrailers = 0
local currentTruck = "Linerunner [1]"
local totalBoxs = 0
local sessionBoxs = 0
local totalTimeInTrip = 0
local sessionTimeInTrip = 0
local weighing = "{1b5bc9}Вне маршрута"
local sum = 0
local routes = {"[LV] - [SF]", "[SF] - [LV]", "[LV] - [RCSD]", "[LS] - [SF]", "[SF] - [RCSD]", "[LS] - [LV]"}
local routeTrip = u8"Вне маршрута"
local timeTrip = "00:00"
local boxPrice = 0
local time = 0
local timeTo = 0
local checkTruckExp = false
local weighingCheck = false
local checkRoute = false
--------------------------------------------------------------
local mainIni = inicfg.load({
  driverStats =
  {
    totalTrailers = 0,
		totalBoxs = 0,
		totalTimeInTrip = 0,
		boxPrice = 1500000
  }
})

local iniDirectory = "driver.ini"
local iniMain = inicfg.load(mainIni, iniDirectory)
local iniState = inicfg.save(iniMain, iniDirectory)

--------------------------------------------------------------

function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then
    return
  end
  while not isSampAvailable() do
    wait(0)
  end
	totalTrailers = iniMain.driverStats.totalTrailers
	totalBoxs = iniMain.driverStats.totalBoxs
	totalTimeInTrip = iniMain.driverStats.totalTimeInTrip
	boxPrice = iniMain.driverStats.boxPrice
	sampRegisterChatCommand("driver", driver)
	sampAddChatMessage(tag.."Скрипт запущен. Текущая версия: "..scriptVersion, -1)
	sampRegisterChatCommand('ds', function()
		main_window_state.v = not main_window_state.v
	end)
	autoupdate("https://raw.githubusercontent.com/neverlessy/driver-samp/master/autoupdate.json", '['..string.upper(thisScript().name)..']: ', "https://www.blast.hk/threads/119635/")
	while true do
		if work then
			if activatedDriver then
				memory.setuint8(7634870, 1)
				memory.setuint8(7635034, 1)
				memory.fill(7623723, 144, 8)
				memory.fill(5499528, 144, 6)
				activatedDriver = not activatedDriver
			end
		else
				memory.setuint8(7634870, 0)
				memory.setuint8(7635034, 0)
				memory.hex2bin('5051FF1500838500', 7623723, 8)
				memory.hex2bin('0F847B010000', 5499528, 6)
		end
		wait(0)
		imgui.Process = main_window_state.v
		if toggle then
			local data = samp_create_sync_data('player')
			data.keysData = data.keysData + 1024
			data.send()
		end
	end
	wait(-1)
end

function getTruck()
	if isCharInAnyCar(PLAYER_PED) then
		currentTruck = getCarNamebyModel(getCarModel(storeCarCharIsInNoSave(PLAYER_PED)))
		if currentTruck == nil then
			currentTruck = u8"Неизвестно"
		end
	else
		currentTruck = u8"Отсутствует"
	end
	return currentTruck
end

function imgui.OnDrawFrame()
  if main_window_state.v then
		imgui.SetNextWindowSize(imgui.ImVec2(250, 330), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(imgui.ImVec2(300, 500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	  imgui.Begin(u8'', main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar)
		imgui.BeginChild("##tripInfo", imgui.ImVec2(220, 120), false)
			imgui.Spacing()
			imgui.Text("") imgui.SameLine() imgui.Text(u8"Текущий транспорт: "..getTruck())
			imgui.Text("") imgui.SameLine() imgui.TextColoredRGB("Взвешивание: "..weighing)
			imgui.Text("") imgui.SameLine() imgui.Text(u8"Заработок: "..sumFormat(sum).." $")
			imgui.Text("") imgui.SameLine() imgui.Text(u8"Маршрут: "..routeTrip)
			imgui.Text("") imgui.SameLine() imgui.Text(u8"Рейс: "..timeTrip)
		imgui.EndChild()
			imgui.BeginChild("##mainInfo", imgui.ImVec2(220, 165), false)
				imgui.Spacing()
				imgui.Text("") imgui.SameLine() imgui.Text(u8"Рейсов за сессию: "..tostring(sessionTrailers))
				imgui.Text("") imgui.SameLine() imgui.Text(u8"Ларцов за сессию: "..tostring(sessionBoxs))
				imgui.Text("") imgui.SameLine() imgui.Text(u8"За сессию в рейсах: "..tostring(get_timer(sessionTimeInTrip)))
				imgui.Text("") imgui.SameLine() imgui.Text(u8"Всего рейсов: "..tostring(totalTrailers))
				imgui.Text("") imgui.SameLine() imgui.Text(u8"Всего ларцов: "..tostring(totalBoxs))
				imgui.Text("") imgui.SameLine() imgui.Text(u8"В рейсах всего: "..tostring(get_timer(totalTimeInTrip)))
				imgui.Text("") imgui.SameLine() imgui.Text(u8"Навык дальнобойщика: "..tostring(truckExp))
			imgui.EndChild()
		imgui.End()
		imgui.ShowCursor = false
	end
end

function ev.onShowDialog(dialogId, style, title, button1, button2, text)
	if dialogId == 722 and title:find("Игровое меню") and checkTruckExp then
		sampSendDialogResponse(dialogId, 1, 1, -1)
		return false
	end
	if dialogId == 431 and title:find("Навыки") and checkTruckExp then
		sampSendDialogResponse(dialogId, 1, 5, -1)
		return false
	end
	if dialogId == 0 and text:find("%{FFFFFF%}Ваш навык дальнобойщика: %{F5C74B%}(%d+) опыта%{FFFFFF%}") and checkTruckExp then
		truckExp = text:match("%{FFFFFF%}Ваш навык дальнобойщика: %{F5C74B%}(%d+) опыта%{FFFFFF%}")
		checkTruckExp = not checkTruckExp
		return false
	end
end

function ev.onServerMessage(color, text)
				if text:find('Сцепка произойдёт автоматически.') then
					getTruckExp()
					lua_thread.create(function()
						startTrip = not startTrip
						weighing = "{eb255e}Не пройдено"
						time = os.clock() + 1080
							while true do wait(0)
								if startTrip then
									timeTo = time - os.clock()
									timeTo = math.floor(timeTo)
									timeTrip = get_timer(timeTo)
									--printStyledString("~y~~h~"..timeTrip, 500, 5)
								end
							end
					end)
				end
				if text:find("успешно доставлено! Ваша зарплата за рейс:%s+$(%d+).") then
					local sumTrip = text:match("успешно доставлено! Ваша зарплата за рейс: $(%d+).")
					if weighingCheck then
						sum = sum + tonumber(sumTrip)
						weighingCheck = not weighingCheck
					else
					 sum = sum + (sumTrip - ((sumTrip/100)*20))
					end
					weighing = "{1b5bc9}Вне маршрута"
					routeTrip = u8"Вне маршрута"
					totalTrailers = totalTrailers + 1
					sessionTrailers = sessionTrailers + 1
					local timeToReverse = 1080 - math.floor(timeTo)
					totalTimeInTrip = totalTimeInTrip + timeToReverse
					sessionTimeInTrip = sessionTimeInTrip + timeToReverse
					startTrip = not startTrip
					timeTrip = "00:00"
					iniMain.driverStats.totalTrailers = totalTrailers
					iniMain.driverStats.totalTimeInTrip = totalTimeInTrip
					if inicfg.save(iniMain, iniDirectory) then
						getTruckExp()
					end
				end
				if text:find("Вам был добавлен предмет 'Ларец дальнобойщика'. Чтобы открыть инвентарь используйте клавишу 'Y' или /invent") then
					sessionBoxs = sessionBoxs + 1
					totalBoxs = totalBoxs + 1
					sum = sum + boxPrice
					iniMain.driverStats.totalBoxs = totalBoxs
					if inicfg.save(iniMain, iniDirectory) then
						printStyledString("~y~~h~Box++", 2500, 5)
					end
				end
				if text:find("Вы подцепили груз. Теперь езжайте на склад по чекпоинтам соблюдая Правила Дорожного Движения.") then
					checkRoute = not checkRoute
					lua_thread.create(function()
							while true do
								wait(100)
								if checkRoute then
									if routeTrip == nil or routeTrip == u8"Вне маршрута" or routeTrip == u8"Неизвестно" then
										routeTrip = getRoute()
									end
									if routeTrip ~= nil and routeTrip ~= u8"Вне маршрута" and routeTrip ~= u8"Неизвестно" then
										routeTrip = getRoute()
										checkRoute = not checkRoute
									end
								end
							end
					end)
				end
				if text:find("Взвешивание началось..") then
					weighing = "{c9891b}В процессе"
				end
				if text:find("Взвешивание завершено..") then
					weighing = "{1ef8a9}Пройдено"
					weighingCheck = not weighingCheck
				end
				if text:find("взять новый можно на одной из баз дальнобойщиков.") then
					weighing = "{1b5bc9}Вне маршрута"
					routeTrip = u8"Вне маршрута"
					local timeToReverse = 1080 - math.floor(timeTo)
					totalTimeInTrip = totalTimeInTrip + timeToReverse
					sessionTimeInTrip = sessionTimeInTrip + timeToReverse
					startTrip = not startTrip
					timeTrip = "00:00"
					iniMain.driverStats.totalTimeInTrip = totalTimeInTrip
					if inicfg.save(iniMain, iniDirectory) then
						getTruckExp()
					end
				end
				if text:find("(( Через 30 секунд вы сможете сразу отправиться в больницу или подождать врачей ))") then
					weighing = "{1b5bc9}Вне маршрута"
					routeTrip = u8"Вне маршрута"
					local timeToReverse = 1080 - math.floor(timeTo)
					totalTimeInTrip = totalTimeInTrip + timeToReverse
					sessionTimeInTrip = sessionTimeInTrip + timeToReverse
					startTrip = not startTrip
					timeTrip = "00:00"
					iniMain.driverStats.totalTimeInTrip = totalTimeInTrip
					if inicfg.save(iniMain, iniDirectory) then
						getTruckExp()
					end
				end
end

function ev.onShowTextDraw(tdi, data)
	if data.text:find("%$%d+") then
        fillmoney = tdi
    end

    if data.text:find("LD%_BEAT%:chit") and data.lineWidth == 19 then
        fillchange = tdi
    end

    if data.text:find("FILL") then
        fillid = tdi

        sampSendClickTextdraw(fillmoney)
        lua_thread.create(function ()
            wait(100)
            sampSendClickTextdraw(fillid)
        end)
    end
end

function getTruckExp()
	checkTruckExp = not checkTruckExp
	sampSendChat("/mn")
end

function driver(arg)
	sampAddChatMessage(tag.."Начинаю работу...", -1)
	toggle = not toggle
	work = not work
	lockPlayerControl(true)
	function ev.onShowDialog(dialogId, style, title, button1, button2, text)
		if dialogId == 15505 then
			toggle = not toggle
			final = not final
			lua_thread.create(function()
				while true do
					if final then
						wait(10)
						sampSendDialogResponse(15505, 1, tonumber(arg), '')
						wait(20)
						sampSendDialogResponse(15506, 1, 0, '')
						sampCloseCurrentDialogWithButton(0)
						if isCharInAnyCar(PLAYER_PED) then
							final = not final
							work = not work
							activatedDriver = not activatedDriver
							sampAddChatMessage(tag.."Вы успешно арендовали грузовик", -1)
							ShowMessage('Фура успешно взята в аренду! Скорее вернись в игру!', 'Driver', 0x40)
							lockPlayerControl(false)
							break
						end
					end
				end
			end)
		end
	end
end

function samp_create_sync_data(sync_type, copy_from_player)
    local sampfuncs = require 'sampfuncs'
    -- from SAMP.Lua
    local raknet = require 'samp.raknet'
    require 'samp.synchronization'

    copy_from_player = copy_from_player or true
    local sync_traits = {
        player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData},
        vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData},
        passenger = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC, sampStorePlayerPassengerData},
        aim = {'AimSyncData', raknet.PACKET.AIM_SYNC, sampStorePlayerAimData},
        trailer = {'TrailerSyncData', raknet.PACKET.TRAILER_SYNC, sampStorePlayerTrailerData},
        unoccupied = {'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC, nil},
        bullet = {'BulletSyncData', raknet.PACKET.BULLET_SYNC, nil},
        spectator = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC, nil}
    }
    local sync_info = sync_traits[sync_type]
    local data_type = 'struct ' .. sync_info[1]
    local data = ffi.new(data_type, {})
    local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data)))
    -- copy player's sync data to the allocated memory
    if copy_from_player then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id
            if copy_from_player == true then
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            else
                player_id = tonumber(copy_from_player)
            end
            copy_func(player_id, raw_data_ptr)
        end
    end
    -- function to send packet
    local func_send = function()
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, sync_info[2])
        raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data))
        raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1)
        raknetDeleteBitStream(bs)
    end
    -- metatable to access sync data and 'send' function
    local mt = {
        __index = function(t, index)
            return data[index]
        end,
        __newindex = function(t, index, value)
            data[index] = value
        end
    }
    return setmetatable({send = func_send}, mt)
end

function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end

    render_text(text)
end

function get_timer(time)
return string.format("%s:%s:%s",string.format("%s%s",((tonumber(os.date("%H",time)) < tonumber(os.date("%H",0)) and (24 + tonumber(os.date("%H",time))) - tonumber(os.date("%H",0)) or tonumber(os.date("%H",time)) - (tonumber(os.date("%H",0)))) < 10 and 0 or ""),(tonumber(os.date("%H",time)) < tonumber(os.date("%H",0)) and (24 + tonumber(os.date("%H",time))) - tonumber(os.date("%H",0)) or tonumber(os.date("%H",time)) - (tonumber(os.date("%H",0))))),os.date("%M",time),os.date("%S",time))
end

function imgui.TextQuestion(label, description)
    imgui.TextDisabled(label)

    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
            imgui.PushTextWrapPos(600)
                imgui.TextUnformatted(description)
            imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function getCarNamebyModel(model)
    local names = {
      [400] = 'Landstalker',
      [401] = 'Bravura',
      [402] = 'Buffalo',
      [403] = 'Linerunner',
      [404] = 'Perennial',
      [405] = 'Sentinel',
      [406] = 'Dumper',
      [407] = 'Firetruck',
      [408] = 'Trashmaster',
      [409] = 'Stretch',
      [410] = 'Manana',
      [411] = 'Infernus',
      [412] = 'Voodoo',
      [413] = 'Pony',
      [414] = 'Mule',
      [415] = 'Cheetah',
      [416] = 'Ambulance',
      [417] = 'Leviathan',
      [418] = 'Moonbeam',
      [419] = 'Esperanto',
      [420] = 'Taxi',
      [421] = 'Washington',
      [422] = 'Bobcat',
      [423] = 'Mr. Whoopee',
      [424] = 'BF Injection',
      [425] = 'Hunter',
      [426] = 'Premier',
      [427] = 'Enforcer',
      [428] = 'Securicar',
      [429] = 'Banshee',
      [430] = 'Predator',
      [431] = 'Bus',
      [432] = 'Rhino',
      [433] = 'Barracks',
      [434] = 'Hotknife',
      [435] = 'Article Trailer',
      [436] = 'Previon',
      [437] = 'Coach',
      [438] = 'Cabbie',
      [439] = 'Stallion',
      [440] = 'Rumpo',
      [441] = 'RC Bandit',
      [442] = 'Romero',
      [443] = 'Packer',
      [444] = 'Monster',
      [445] = 'Admiral',
      [446] = 'Squallo',
      [447] = 'Seaspamrow',
      [448] = 'Pizzaboy',
      [449] = 'Tram',
      [450] = 'Article Trailer 2',
      [451] = 'Turismo',
      [452] = 'Speeder',
      [453] = 'Reefer',
      [454] = 'Tropic',
      [455] = 'Flatbed',
      [456] = 'Yankee',
      [457] = 'Caddy',
      [458] = 'Solair',
      [459] = 'Topfun Van',
      [460] = 'Skimmer',
      [461] = 'PCJ-600',
      [462] = 'Faggio',
      [463] = 'Freeway',
      [464] = 'RC Baron',
      [465] = 'RC Raider',
      [466] = 'Glendale',
      [467] = 'Oceanic',
      [468] = 'Sanchez',
      [469] = 'Spamrow',
      [470] = 'Patriot',
      [471] = 'Quad',
      [472] = 'Coastguard',
      [473] = 'Dinghy',
      [474] = 'Hermes',
      [475] = 'Sabre',
      [476] = 'Rustler',
      [477] = 'ZR-350',
      [478] = 'Walton',
      [479] = 'Regina',
      [480] = 'Comet',
      [481] = 'BMX',
      [482] = 'Burrito',
      [483] = 'Camper',
      [484] = 'Marquis',
      [485] = 'Baggage',
      [486] = 'Dozer',
      [487] = 'Maverick',
      [488] = 'News Maverick',
      [489] = 'Rancher',
      [490] = 'FBI Rancher',
      [491] = 'Virgo',
      [492] = 'Greenwood',
      [493] = 'Jetmax',
      [494] = 'Hotring Racer',
      [495] = 'Sandking',
      [496] = 'Blista Compact',
      [497] = 'Police Maverick',
      [498] = 'Boxville',
      [499] = 'Benson',
      [500] = 'Mesa',
      [501] = 'RC Goblin',
      [502] = 'Hotring Racer A',
      [503] = 'Hotring Racer B',
      [504] = 'Bloodring Banger',
      [505] = 'Rancher',
      [506] = 'Super GT',
      [507] = 'Elegant',
      [508] = 'Journey',
      [509] = 'Bike',
      [510] = 'Mountain Bike',
      [511] = 'Beagle',
      [512] = 'Cropduster',
      [513] = 'Stuntplane',
      [514] = 'Tanker',
      [515] = 'Roadtrain',
      [516] = 'Nebula',
      [517] = 'Majestic',
      [518] = 'Buccaneer',
      [519] = 'Shamal',
      [520] = 'Hydra',
      [521] = 'FCR-900',
      [522] = 'NRG-500',
      [523] = 'HPV1000',
      [524] = 'Cement Truck',
      [525] = 'Towtruck',
      [526] = 'Fortune',
      [527] = 'Cadrona',
      [528] = 'FBI Truck',
      [529] = 'Willard',
      [530] = 'Forklift',
      [531] = 'Tractor',
      [532] = 'Combine',
      [533] = 'Feltzer',
      [534] = 'Remington',
      [535] = 'Slamvan',
      [536] = 'Blade',
      [537] = 'Train',
      [538] = 'Train',
      [539] = 'Vortex',
      [540] = 'Vincent',
      [541] = 'Bullet',
      [542] = 'Clover',
      [543] = 'Sadler',
      [544] = 'Firetruck',
      [545] = 'Hustler',
      [546] = 'Intruder',
      [547] = 'Primo',
      [548] = 'Cargobob',
      [549] = 'Tampa',
      [550] = 'Sunrise',
      [551] = 'Merit',
      [552] = 'Utility Van',
      [553] = 'Nevada',
      [554] = 'Yosemite',
      [555] = 'Windsor',
      [556] = 'Monster A',
      [557] = 'Monster B',
      [558] = 'Uranus',
      [559] = 'Jester',
      [560] = 'Sultan',
      [561] = 'Stratum',
      [562] = 'Elegy',
      [563] = 'Raindance',
      [564] = 'RC Tiger',
      [565] = 'Flash',
      [566] = 'Tahoma',
      [567] = 'Savanna',
      [568] = 'Bandito',
      [569] = 'Train',
      [570] = 'Train',
      [571] = 'Kart',
      [572] = 'Mower',
      [573] = 'Dune',
      [574] = 'Sweeper',
      [575] = 'Broadway',
      [576] = 'Tornado',
      [577] = 'AT400',
      [578] = 'DFT-30',
      [579] = 'Huntley',
      [580] = 'Stafford',
      [581] = 'BF-400',
      [582] = 'Newsvan',
      [583] = 'Tug',
      [584] = 'Petrol Trailer',
      [585] = 'Emperor',
      [586] = 'Wayfarer',
      [587] = 'Euros',
      [588] = 'Hotdog',
      [589] = 'Club',
      [590] = 'Train',
      [591] = 'Article Trailer 3',
      [592] = 'Andromada',
      [593] = 'Dodo',
      [594] = 'RC Cam',
      [595] = 'Launch',
      [596] = 'Police Car LS',
      [597] = 'Police Car SF',
      [598] = 'Police Car LV',
      [599] = 'Police Ranger',
      [600] = 'Picador',
      [601] = 'S.W.A.T.',
      [602] = 'Alpha',
      [603] = 'Phoenix',
      [604] = 'Glendale',
      [605] = 'Sadler',
      [606] = 'Baggage Trailer',
      [607] = 'Baggage Trailer',
      [608] = 'Tug Stairs Trailer',
      [609] = 'Boxville',
      [610] = 'Farm Trailer',
      [611] = 'Utility Traileraw ',
			[12725] = 'Actros',
			[12740] = 'Volvo'
    }
    return names[model]
end

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

function sumFormat(a)
    local b, e = ('%d'):format(a):gsub('^%-', '')
    local c = b:reverse():gsub('%d%d%d', '%1.')
    local d = c:reverse():gsub('^%.', '')
    return (e == 1 and '-' or '')..d
end

function ShowMessage(text, title, style)
    ffi.cdef [[
        int MessageBoxA(
            void* hWnd,
            const char* lpText,
            const char* lpCaption,
            unsigned int uType
        );
    ]]
    local hwnd = ffi.cast('void*', readMemory(0x00C8CF88, 4, false))
    ffi.C.MessageBoxA(hwnd, text,  title, style and (style + 0x50000) or 0x50000)
end

function autoupdate(json_url, prefix, url)
  local dlstatus = require('moonloader').download_status
  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
  if doesFileExist(json) then os.remove(json) end
  downloadUrlToFile(json_url, json,
    function(id, status, p1, p2)
      if status == dlstatus.STATUSEX_ENDDOWNLOAD then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            local info = decodeJson(f:read('*a'))
            updatelink = info.updateurl
            updateversion = info.latest
            f:close()
            os.remove(json)
            if updateversion ~= thisScript().version then
              lua_thread.create(function(prefix)
                local dlstatus = require('moonloader').download_status
                local color = -1
                sampAddChatMessage((tag..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion), color)
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format('Загружено %d из %d.', p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      print('Загрузка обновления завершена.')
                      sampAddChatMessage((tag..'Обновление завершено!'), color)
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        sampAddChatMessage((tag..'Обновление прошло неудачно. Запускаю устаревшую версию..'), color)
                        update = false
                      end
                    end
                  end
                )
                end, prefix
              )
            else
              update = false
              print('v'..thisScript().version..': Обновление не требуется.')
            end
          end
        else
          print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..url)
          update = false
        end
      end
    end
  )
  while update ~= false do wait(100) end
end

function apply_custom_style()
imgui.SwitchContext()
local style = imgui.GetStyle()
local colors = style.Colors
local clr = imgui.Col
local ImVec4 = imgui.ImVec4
local ImVec2 = imgui.ImVec2

 style.WindowPadding = ImVec2(15, 15)
 style.WindowRounding = 15.0
 style.FramePadding = ImVec2(5, 5)
 style.ItemSpacing = ImVec2(12, 8)
 style.ItemInnerSpacing = ImVec2(8, 6)
 style.IndentSpacing = 25.0
 style.ScrollbarSize = 15.0
 style.ScrollbarRounding = 15.0
 style.GrabMinSize = 15.0
 style.GrabRounding = 7.0
 style.ChildWindowRounding = 8.0
 style.FrameRounding = 6.0


	 colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
	 colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
	 colors[clr.WindowBg] = ImVec4(0.11, 0.15, 0.17, 0.75)
	 colors[clr.ChildWindowBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
	 colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
	 colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
	 colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
	 colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
	 colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
	 colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
	 colors[clr.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
	 colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
	 colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
	 colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
	 colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
	 colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
	 colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
	 colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
	 colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
	 colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
	 colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
	 colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
	 colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
	 colors[clr.ButtonHovered] = ImVec4(0.18, 0.16, 0.40, 1.00)
	 colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
	 colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
	 colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
	 colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
	 colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
	 colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
	 colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	 colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
	 colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
	 colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
	 colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
	 colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
	 colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
	 colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
	 colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
	 colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end
apply_custom_style()
