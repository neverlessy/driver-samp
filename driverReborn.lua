---@diagnostic disable: undefined-global, lowercase-global, redundant-parameter, redundant-value

local e = require 'samp.events'
local m = require 'mimgui'
local enc = require 'encoding'
local wm = require 'windows.message'
local vkeys = require 'vkeys'
local ffi = require 'ffi'
local inicfg = require 'inicfg'

script_name('Driver Reborn')
script_authors('Moon Glance', 'neverlessy')
script_version('1.3.5')
script_version_number(2217)
script_description('All rights reserved. © Moon Glance 2022')

--  Объявление переменных для удобства кода согласно moongl.ru/coderules
local new, v2, v4, cupoX, cupoY, chatMessage, flags = m.new, m.ImVec2, m.ImVec4, m.SetCursorPosX, m.SetCursorPosY, sampAddChatMessage, m.WindowFlags

-- Объявление других переменных
enc.default = 'CP1251'
local u8 = enc.UTF8
local script = thisScript()
local driverTag = '{8bdee4}[Driver]{b7b7b7} '
local str, sizeof = ffi.string, ffi.sizeof
local driverMenu, widgetMenu, settingsAutoTrailerBool, settingsWidgetBool, settingsAutoEatBool, settingsPipBool, settingsEngineControlBool, settingsTimerArendaBool, settingsAutoBuyBool, settingsAutoFillBool, settingsAutoBrakeBool, settingsAutoDomkratBool, settingsAutoSlagboumBool, settingsAutoReportBool, settingsPipFillBool, settingsPipFuelBool, settingsPipBoxBool, settingsOffChatBool = new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool()
local widgetLinks, menuType, eatType, fillType, trailerType, widgetShowType, dPlayers, dPlayerNick, dPlayerId, dPlayerNumber = {new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool()}, {true, false, false, false, false}, {false, true, false}, {true, false, false, false}, {false, true, false}, {true, false, false}, {}, {}, {}, {}
local widgetTransparrent, sendReportText, sliderRepairCount, sliderFillCount, sliderDomkratCount, loadDriverStatus = new.float(1.00), new.char[85](u8"Я попал в воду! Помогите!"), new.int(5), new.int(5), new.int(5), ''
local languageStrings, currentLanguage = nil, nil
local routes, routeTrip, statusWeighing = {"[LV] - [SF]", "[SF] - [LV]", "[LV] - [RCSD]", "[LS] - [SF]", "[SF] - [RCSD]", "[LS] - [LV]"}, u8"Неизвестно", u8'Не пройдено'
local route, editingWidgetMode, widgetPosX, widgetPosY, satietyCheckTimer, satietyLevelSupport, satietyCheck, satietyVar, fillTypeTextdrawId, buttonFill, buttonNextFill, buttonPrevFill, buttonSelectPriceFill, fillTypeName, sliderAutoBarrierWait = new.bool(), new.bool(), new.int(), new.int(), new.int(60), new.int(80), new.bool(), 0, 0, 0, 0, 0, 0, '', new.int(10)
local routesInSession, boxInSession, boxAll, routesAll, timeInRoutesSession, timeInRoutesAll, truckerSkill, earningInSession, currentTruck = 0,0,0,0,0,0,0,0, ''
-- Код

local driverWidgetMenuFrame = m.OnFrame(
    function() return widgetMenu[0] end,
    function(player)
        m.PushStyleColor(m.Col.WindowBg, v4(0.07, 0.07, 0.07, widgetTransparrent[0]))
        m.PushStyleColor(m.Col.Text, v4(1.00, 1.00, 1.00, widgetTransparrent[0]))
        m.PushStyleColor(m.Col.Separator, v4(0.12, 0.12, 0.12, widgetTransparrent[0]))
        m.PushStyleColor(m.Col.Border, v4(0.25, 0.25, 0.26, widgetTransparrent[0]))
        if editingWidgetMode[0] then
            m.SetNextWindowPos(v2(select(1, getCursorPos()) - 125, select(2, getCursorPos())), m.Cond.Always)
            if isKeyJustPressed(32) then
                sampAddChatMessage(driverTag..''..chatStrings["chatMessages.savedWidgetPosition"], -1)
                widgetPosX[0], widgetPosY[0] = select(1, getCursorPos()) - 125, select(2, getCursorPos())
                saveConfig()
                editingWidgetMode[0] = false
                driverMenu[0] = true
            end
        else
            m.SetNextWindowPos(v2(widgetPosX[0], widgetPosY[0]), m.Cond.Always)
        end
        m.SetNextWindowSize(v2(250, checkSizeWidget() + 55), m.Cond.Always)
        m.Begin("widget", widgetMenu, flags.NoResize + flags.NoCollapse + flags.NoScrollbar + flags.NoTitleBar)
            m.CenterText(u8""..getTruck()) m.Separator()
                m.BeginChild('WidgetMenu', v2(240, checkSizeWidget()), false)
                if widgetLinks[1][0] then
                    m.CenterText(u8""..languageStrings["widgetLinks.weighing"]..': '..checkWeighing())
                end
                if widgetLinks[2][0] then
                    m.CenterText(u8""..languageStrings["widgetLinks.earning"]..': '..tostring(earningInSession)..' $')
                end
                if widgetLinks[3][0] then
                    m.CenterText(u8""..languageStrings["widgetLinks.route"]..': '..tostring(getRoute()))
                end
                if widgetLinks[4][0] then
                    m.CenterText(u8""..languageStrings["widgetLinks.routesInSession"]..': '..tostring(routesInSession))
                end
                if widgetLinks[5][0] then
                    m.CenterText(u8""..languageStrings["widgetLinks.boxInSession"]..': '..tostring(boxInSession))
                end
                if widgetLinks[6][0] then
                    m.CenterText(u8""..languageStrings["widgetLinks.boxAll"]..': '..tostring(boxAll))
                end
                if widgetLinks[7][0] then
                    m.CenterText(u8""..languageStrings["widgetLinks.routesAll"]..': '..tostring(routesAll))
                end
                if widgetLinks[8][0] then
                    m.CenterText(u8""..languageStrings["widgetLinks.timeInRoutesSession"]..': '..tostring(timeInRoutesSession))
                end
                if widgetLinks[9][0] then
                    m.CenterText(u8""..languageStrings["widgetLinks.timeInRoutesAll"]..': '..tostring(timeInRoutesAll))
                end
                if widgetLinks[10][0] then
                    m.CenterText(u8""..languageStrings["widgetLinks.truckerSkill"]..': '..tostring(truckerSkill))
                end
                m.EndChild()
            m.Text('', cupoY(checkSizeWidget() + 10))
            m.Separator()
            m.CenterText(u8""..os.date("%X")..' | '..os.date("*t").day..'.'..os.date("*t").month..'.'..os.date("*t").year) 
        m.End()
        m.PopStyleColor(4)
        if editingWidgetMode[0] then
            player.HideCursor = false
        else
            player.HideCursor = true
        end
    end
)

local driverMenuFrame = m.OnFrame(
    function() return driverMenu[0] end,
    function(player)
        m.SetNextWindowPos(v2(400, 550), m.Cond.FirstUseEver, v2(0.5, 0.5))
        m.SetNextWindowSize(v2(750, 400), m.Cond.FirstUseEver)
        m.Begin("Main Window", driverMenu, flags.NoResize + flags.NoCollapse + flags.NoScrollbar + flags.NoTitleBar)
            m.BeginChild('#MenuBar', v2(200, 390), false)
                if m.ButtonActivated(menuType[1], u8""..languageStrings["driverMenu.leftmenu.button1"], v2(200, 50), cupoX(0)) then
                    switchMenu(1)
                end
                if m.ButtonActivated(menuType[2], u8""..languageStrings["driverMenu.leftmenu.button2"], v2(200, 50), cupoX(0)) then
                    switchMenu(2)
                end
                if m.ButtonActivated(menuType[3], u8""..languageStrings["driverMenu.leftmenu.button3"], v2(200, 50), cupoX(0))  then
                    switchMenu(3)
                end
                if m.ButtonActivated(menuType[4], u8""..languageStrings["driverMenu.leftmenu.button4"], v2(200, 50), cupoX(0)) then
                    switchMenu(4)
                end
                if m.ButtonActivated(menuType[5], u8""..languageStrings["driverMenu.leftmenu.button6"], v2(97, 50), cupoX(102), cupoY(340)) then
                    switchMenu(5)
                end
                if m.Button(u8""..languageStrings["driverMenu.leftmenu.button5"], v2(97, 50), cupoX(0), cupoY(340)) then
                    if menuType[4] then
                        switchMenu(1)
                    end
                    driverMenu[0] = false
                end
                
            m.EndChild() m.SameLine()
            m.BeginChild('#Content', v2(535, 390), false)
                if menuType[1] then
                    m.Image(logoDriver, v2(300, 300), cupoX(120))
                    m.CenterText(u8''..languageStrings["menuAbout.author"]..': Moon Glance')
                    m.CenterText(u8''..languageStrings["menuAbout.currentVersion"]..': '..script.this.version)
                    m.CenterText(u8''..languageStrings["menuAbout.currentBuild"]..': '..script.this.version_num)
                    if m.Button(u8""..languageStrings["menuAbout.button.lang"], v2(100,30), cupoX(430), cupoY(355)) then
                        m.OpenPopup('languageSelect')
                    end
                end
                if menuType[2] then
                    m.Checkbox(u8" "..languageStrings["menuSettings.checkbox.showWidget"], settingsWidgetBool)
                        if settingsWidgetBool[0] then
                            if m.Button(u8""..languageStrings["menuSettings.button.settingsWidget"], v2(150,30), cupoX(25)) then
                                m.OpenPopup('widgetSettings')
                            end
                            m.Text(u8""..languageStrings["menuSettings.text.widgetMode"], cupoX(25))
                            if m.ButtonActivated(widgetShowType[1], u8""..languageStrings["menuSettings.button.widgetMode_Always"], v2(150,30), cupoX(25)) then
                                switchShowWidgetType(1)
                            end m.SameLine()
                            if m.ButtonActivated(widgetShowType[2], u8""..languageStrings["menuSettings.button.widgetMode_inTruck"], v2(150,30)) then
                                switchShowWidgetType(2)
                            end m.SameLine()
                            if m.ButtonActivated(widgetShowType[3], u8""..languageStrings["menuSettings.button.widgetMode_inRoute"], v2(150,30)) then
                                switchShowWidgetType(3)
                            end
                        end
                    m.Checkbox(u8" "..languageStrings["menuSettings.checkbox.autoEat"], settingsAutoEatBool)
                        if settingsAutoEatBool[0] then
                            m.SliderInt(u8' '..languageStrings["menuSettings.autoEat.satietyCheckTimer"], satietyCheckTimer, 60, 300, cupoX(25))
                            m.SliderInt(u8' '..languageStrings["menuSettings.autoEat.satietyLevelSupport"], satietyLevelSupport, 50, 100, cupoX(25))
                            if m.ButtonActivated(eatType[1], u8""..languageStrings["menuSettings.button.eatType_Venison"], v2(150,30), cupoX(25)) then
                                switchEatType(1)
                            end m.SameLine()
                            if m.ButtonActivated(eatType[2], u8""..languageStrings["menuSettings.button.eatType_Fish"], v2(150,30)) then
                                switchEatType(2)
                            end
                            --[[if m.ButtonActivated(eatType[3], u8""..languageStrings["menuSettings.button.eatType_Chips"], v2(150,30)) then
                                switchEatType(3)
                            end]]
                        end
                    if m.Checkbox(u8" "..languageStrings["menuSettings.checkbox.controlEngine"], settingsEngineControlBool) then
                        
                    end
                    m.Checkbox(u8" "..languageStrings["menuSettings.checkbox.soundPip"], settingsPipBool)
                        if settingsPipBool[0] then
                            m.Checkbox(u8" "..languageStrings["menuSettings.checkbox.soundPip.ifGas"], settingsPipFillBool, cupoX(25))
                            m.Checkbox(u8" "..languageStrings["menuSettings.checkbox.soundPip.ifFuel"], settingsPipFuelBool, cupoX(25))
                            m.Checkbox(u8" "..languageStrings["menuSettings.checkbox.soundPip.ifBox"], settingsPipBoxBool, cupoX(25))
                        end
                    m.Checkbox(u8" "..languageStrings["menuSettings.checkbox.rentTimer"], settingsTimerArendaBool)
                        if settingsTimerArendaBool[0] then
                            m.Button(u8""..languageStrings["menuSettings.button.rentTimer"], v2(150,30), cupoX(25))
                        end
                    m.Checkbox(u8" "..languageStrings["menuSettings.checkbox.autoBuy"], settingsAutoBuyBool)
                        if settingsAutoBuyBool[0] then
                            m.SliderInt(u8' '..languageStrings["menuSettings.button.autoBuy_repKits"], sliderRepairCount, 1, 15, cupoX(25))
                            m.SliderInt(u8' '..languageStrings["menuSettings.button.autoBuy_can"], sliderFillCount, 1, 15, cupoX(25))
                            m.SliderInt(u8' '..languageStrings["menuSettings.button.autoBuy_jacks"], sliderDomkratCount, 1, 15, cupoX(25))
                        end
                    m.Checkbox(u8" "..languageStrings["menuSettings.checkbox.autoFill"], settingsAutoFillBool)
                    if settingsAutoFillBool[0] then
                        if m.ButtonActivated(fillType[1], u8""..languageStrings["menuSettings.button.autoFill_diesel"], v2(111,30), cupoX(25)) then
                            switchFillType(1)
                        end m.SameLine()
                        if m.ButtonActivated(fillType[2], u8""..languageStrings["menuSettings.button.autoFill_92"], v2(111,30)) then
                            switchFillType(2)
                        end m.SameLine()
                        if m.ButtonActivated(fillType[3], u8""..languageStrings["menuSettings.button.autoFill_95"], v2(111,30)) then
                            switchFillType(3)
                        end m.SameLine()
                        if m.ButtonActivated(fillType[4], u8""..languageStrings["menuSettings.button.autoFill_98"], v2(111,30)) then
                            switchFillType(4)
                        end
                    end
                    m.Checkbox(u8" "..languageStrings["menuSettings.checkbox.autoBrake"], settingsAutoBrakeBool)
                    m.Checkbox(u8" "..languageStrings["menuSettings.checkbox.autoLiftJack"], settingsAutoDomkratBool)
                    m.Checkbox(u8" "..languageStrings["menuSettings.checkbox.autoBarrier"], settingsAutoSlagboumBool)
                    if settingsAutoSlagboumBool[0] then
                        m.SliderInt(u8' '..languageStrings["menuSettings.slider.floodHwait"], sliderAutoBarrierWait, 10, 100, cupoX(25))
                    end
                    m.Checkbox(u8" "..languageStrings["menuSettings.checkbox.autoTrailer"], settingsAutoTrailerBool)
                        if settingsAutoTrailerBool[0] then
                            if m.ButtonActivated(trailerType[1], u8""..languageStrings["menuSettings.button.autoTrailer_Fuel"], v2(150,30), cupoX(25)) then
                                switchTrailerType(1)
                            end m.SameLine()
                            if m.ButtonActivated(trailerType[2], u8""..languageStrings["menuSettings.button.autoTrailer_Guns"], v2(150,30)) then
                                switchTrailerType(2)
                            end m.SameLine()
                            if m.ButtonActivated(trailerType[3], u8""..languageStrings["menuSettings.button.autoTrailer_Products"], v2(150,30)) then
                                switchTrailerType(3)
                            end
                        end
                    m.Checkbox(u8" "..languageStrings["menuSettings.checkbox.autoReportInWater"], settingsAutoReportBool)
                        if settingsAutoReportBool[0] then
                            m.InputText(u8" - "..languageStrings["menuSettings.button.autoReport"], sendReportText, sizeof(sendReportText), cupoX(25))
                        end
                    m.Checkbox(u8' '..languageStrings["menuSettings.checkbox.offChatTruckers"], settingsOffChatBool)
                end
                if menuType[4] then
                    displayRadar(true)
                    if dPlayers[2] == nil then
                        m.PushFont(fonts[25])
                            m.CenterText(u8""..languageStrings["driverListLoad.statusTitle"], cupoY(150))
                        m.PopFont()
                        m.PushFont(fonts[15])
                            m.CenterText(u8''..loadDriverStatus)
                        m.PopFont()
                    else
                        m.BeginChild('#Content', v2(535, 390), false, cupoX(25))
                            m.Columns(3, "driverPlayers", false, cupoY(5))
                            m.SetColumnWidth(0, 50)
                            m.SetColumnWidth(1, 250)
                            m.SetColumnWidth(2, 250)
                            m.Text(u8'ID')
                            m.NextColumn()
                            m.CenterColumnText(u8''..languageStrings["driverList.nickname"])
                            m.NextColumn()
                            m.CenterColumnText(u8''..languageStrings["driverList.number"])
                            for i = 2, #dPlayers do
                                if dPlayerNick[i] ~= nil then
                                    m.NextColumn()
                                    m.Text(""..dPlayerId[i])
                                    m.NextColumn()
                                    m.CenterColumnText(""..dPlayerNick[i])
                                    m.NextColumn()
                                    m.CenterColumnText(""..dPlayerNumber[i])
                                end
                            end
                        m.EndChild()
                    end
                end
                if menuType[5] then
                    m.PushFont(fonts[25])
                        m.CenterText(u8"Обновление 1.3.5", cupoY(5))
                    m.PopFont()
                    m.PushFont(fonts[15])
                        m.Text(u8"- Обновлено что-то там", cupoX(15))
                    m.PopFont()
                end
                if m.BeginPopup('widgetSettings') then
                        m.BeginChild('#Popip', v2(250, 305), false)
                            if m.Button(u8""..languageStrings["widgetSettings.changePos"], v2(250, 30)) then
                                if widgetMenu[0] then
                                    sampAddChatMessage(driverTag..''..chatStrings["chatMessages.startEditMode"], -1)
                                    driverMenu[0] = false
                                    editingWidgetMode[0] = true
                                else
                                    sampAddChatMessage(driverTag..''..chatStrings["chatMessages.turnWidget"], -1)
                                end
                            end
                            m.SliderFloat(u8' '..languageStrings["widgetSettings.transparrent"], widgetTransparrent, 0.00, 1.00)
                            if m.Checkbox(u8" "..languageStrings["widgetSettings.weighing"], widgetLinks[1]) or
                            m.Checkbox(u8" "..languageStrings["widgetSettings.earning"], widgetLinks[2]) or
                            m.Checkbox(u8" "..languageStrings["widgetSettings.route"], widgetLinks[3]) or
                            m.Checkbox(u8" "..languageStrings["widgetSettings.routesInSession"], widgetLinks[4]) or
                            m.Checkbox(u8" "..languageStrings["widgetSettings.boxInSession"], widgetLinks[5]) or
                            m.Checkbox(u8" "..languageStrings["widgetSettings.boxAll"], widgetLinks[6]) or
                            m.Checkbox(u8" "..languageStrings["widgetSettings.routesAll"], widgetLinks[7]) or
                            m.Checkbox(u8" "..languageStrings["widgetSettings.timeInRoutesSession"], widgetLinks[8]) or
                            m.Checkbox(u8" "..languageStrings["widgetSettings.timeInRoutesAll"], widgetLinks[9]) or
                            m.Checkbox(u8" "..languageStrings["widgetSettings.truckerSkill"], widgetLinks[10]) then
                                saveConfig()
                                checkSizeWidget()
                            end
                        m.EndChild()
                    m.EndPopup()
                end
                if m.BeginPopup('languageSelect') then
                    m.BeginChild('#Popip', v2(150, 100), false)
                    if m.Button(u8"Русский", v2(150,30)) then
                        selectLanguage('RU')
                        m.CloseCurrentPopup()
                    end
                    if m.Button(u8"Український", v2(150,30)) then
                        selectLanguage('UA')
                        m.CloseCurrentPopup()
                    end
                    if m.Button(u8"English", v2(150,30)) then
                        selectLanguage('EN')
                        m.CloseCurrentPopup()
                    end
                    m.EndChild()
                m.EndPopup()
            end
            m.EndChild()
        m.End()
        m.GetIO().MouseDrawCursor = 1
        --player.HideCursor = true
    end
)

function m.ButtonActivated(activated, ...)
    if activated then
        m.PushStyleColor(m.Col.Button, m.GetStyle().Colors[m.Col.ButtonHovered])
        m.PushStyleColor(m.Col.ButtonHovered, m.GetStyle().Colors[m.Col.ButtonHovered])
        m.PushStyleColor(m.Col.ButtonActive, m.GetStyle().Colors[m.Col.ButtonHovered])

            m.Button(...)

        m.PopStyleColor()
        m.PopStyleColor()
        m.PopStyleColor()

    else
        return m.Button(...)
    end
end

function m.CenterText(text)
    local width = m.GetWindowWidth()
    local calc = m.CalcTextSize(text)
    m.SetCursorPosX( width / 2 - calc.x / 2 )
    m.Text(text)
end

function m.CenterColumnText(text)
    m.SetCursorPosX((m.GetColumnOffset() + (m.GetColumnWidth() / 2)) - m.CalcTextSize(text).x / 2)
    m.Text(text)
end

function checkSizeWidget()
    temp = 0
    for i = 1, 10 do
        if widgetLinks[i][0] then
            temp = temp + 19
        end
    end
    return temp
end

function switchMenu(newMenu)
    for i = 1, 5 do
        if i ~= newMenu then
            menuType[i] = false
        end
    end
    menuType[newMenu] = true
    saveConfig()
end

function switchEatType(newEatType)
    for i = 1, 3 do
        if i ~= newEatType then
            eatType[i] = false
        end
    end
    eatType[newEatType] = true
    saveConfig()
end

function switchFillType(newFillType)
    for i = 1, 4 do
        if i ~= newFillType then
            fillType[i] = false
        end
    end
    fillType[newFillType] = true
    saveConfig()
end

function switchTrailerType(newTrailerType)
    for i = 1, 3 do
        if i ~= newTrailerType then
            trailerType[i] = false
        end
    end
    trailerType[newTrailerType] = true
    saveConfig()
end

function switchShowWidgetType(newWidgetType)
    for i = 1, 3 do
        if i ~= newWidgetType then
            widgetShowType[i] = false
        end
    end
    widgetShowType[newWidgetType] = true
    saveConfig()
end 

function selectLanguage(lang)
    currentLanguage = lang
    languageStrings = jsonRead(getWorkingDirectory() .. "/resource/Driver/language/"..currentLanguage..".json")
    chatStrings = jsonRead(getWorkingDirectory() .. "/resource/Driver/language/CHAT_"..currentLanguage..".json")
    saveConfig()
end

function pushTruck()
    lua_thread.create(function()
        lockPlayerControl(true)
        local data = samp_create_sync_data('player')
        data.keysData = data.keysData + 1024
        while true do wait(0)
            if isKeyJustPressed(114) then
                lockPlayerControl(false)
                break
            else
                if not sampIsDialogActive() then
                    data.send()
                else
                    if sampGetDialogCaption():find("{%x+}Выбор грузовика") then
                        if sampGetCurrentDialogType() == 0 then
                            sampSendDialogResponse(sampGetCurrentDialogId(), 1 , -1, -1)
                            sampCloseCurrentDialogWithButton(1)
                            lockPlayerControl(false)
                            break
                        elseif sampGetCurrentDialogType() == 5 then
                            sampSendDialogResponse(sampGetCurrentDialogId(), 1 , 0, -1)
                        end
                    else
                        data.send()
                    end
                end
            end
        end
    end)
end

function samp_create_sync_data(sync_type, copy_from_player)
    local ffi = require 'ffi'
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

function moonVec4(numberhex)
    a, r, g, b = tonumber(string.sub(numberhex, 1, 2), 16) / 255, tonumber(string.sub(numberhex, 3, 4), 16) / 255, tonumber(string.sub(numberhex, 5, 6), 16) / 255, tonumber(string.sub(numberhex, 7, 8), 16) / 255
    return v4(tonumber(string.format("%.2f", r)), tonumber(string.format("%.2f", g)), tonumber(string.format("%.2f", b)), tonumber(string.format("%.2f", a)))
end


function jsonSave(jsonFilePath, t)
    file = io.open(jsonFilePath, "w")
    file:write(encodeJson(t))
    file:flush()
    file:close()
end
    
function jsonRead(jsonFilePath)
    local file = io.open(jsonFilePath, "r+")
    local jsonInString = file:read("*a")
    file:close()
    local jsonTable = decodeJson(jsonInString)
    return jsonTable
end

m.OnInitialize(function()
    m.DarkTheme()
    local config = m.ImFontConfig()
    config.MergeMode = true
    local glyph_ranges = m.GetIO().Fonts:GetGlyphRangesCyrillic()
    m.GetIO().Fonts:AddFontFromFileTTF('trebucbd.ttf', 14.0, nil, glyph_ranges)
    fonts = {
        [15] = m.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/resource/Driver/fonts/SFDR.otf', 15.0, nil, glyph_ranges),
        [13] = m.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/resource/Driver/fonts/RFR.ttf', 15.0, nil, glyph_ranges),
        [25] = m.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/resource/Driver/fonts/RFB.ttf', 18.0, nil, glyph_ranges),
        [50] = m.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/resource/Driver/fonts/SFDR.otf', 50.0, nil, glyph_ranges)
    }
    logoDriver = m.CreateTextureFromFile("moonloader/resource/Driver/driver.png")
    m.GetIO().IniFilename = nil
end)

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(0) end
    loadConfig()
    languageStrings = jsonRead(getWorkingDirectory() .. "/resource/Driver/language/"..currentLanguage..".json")
    chatStrings = jsonRead(getWorkingDirectory() .. "/resource/Driver/language/CHAT_"..currentLanguage..".json")
    updateReport() updateDriverPlayers() updateWidget() updateSatiety()
    sampRegisterChatCommand('drive', pushTruck)
    sampAddChatMessage(driverTag..''..chatStrings["chatMessages.scriptLoad"], -1)
    while true do wait(0)
        if isKeyDown(88) then
            setGameKeyState(18, 64)
            wait(sliderAutoBarrierWait[0])
        end
        if testCheat('dr') then driverMenu[0] = not driverMenu[0] end
    end
end

function updateSatiety()
    lua_thread.create(function()
        while settingsAutoEatBool[0] do wait(satietyCheckTimer[0] * 1000)
            if settingsAutoEatBool[0] then
                satietyCheck[0] = true
                sampSendChat('/satiety')
                while satietyCheck[0] do wait(3100)
                    if satietyVar <= satietyLevelSupport[0] then
                        if eatType[1] then
                            sampSendChat('/jmeat')
                        elseif eatType[2] then
                            sampSendChat('/jfish')
                        end
                    else
                        satietyCheck[0] = false
                        break
                    end
                end
            end
        end
    end)
end

function checkWeighing()
    return statusWeighing
end

function updateWidget()
    lua_thread.create(function()
        while true do wait(0)
            if settingsWidgetBool[0] then
                if widgetShowType[1] then
                    widgetMenu[0] = true
                elseif widgetShowType[2] then
                    if isCharInAnyCar(PLAYER_PED) and (getCarModel(storeCarCharIsInNoSave(PLAYER_PED)) == 403 or getCarModel(storeCarCharIsInNoSave(PLAYER_PED)) == 514 or getCarModel(storeCarCharIsInNoSave(PLAYER_PED)) == 515) then
                        widgetMenu[0] = true
                    else
                        widgetMenu[0] = false
                    end
                elseif widgetShowType[3] then
                    if route[0] then
                        widgetMenu[0] = true
                    else
                        widgetMenu[0] = false
                    end
                end
            else
                widgetMenu[0] = false
            end
        end
    end)
end

function updateDriverPlayers()
    lua_thread.create(function()
        while true do wait(0)
            if menuType[4] then
                loadDriverStatus = u8''..languageStrings["driverListLoad.status.one"]
                sampSendChat("/phone")
                wait(500)
                sampSendChat("/phone")
                wait(4500)
            end
        end
    end)
end

function updateReport()
    lua_thread.create(function()
        while true do wait(0)
            if isCharInWater(PLAYER_PED) and settingsAutoReportBool[0] then
                sampSendChat("/report")
                wait(1000)
            end
        end
    end)
end

function e.onShowTextDraw(id, data)
    textdrawPosX = math.floor(data.position.x)
    textdrawPosY = math.floor(data.position.y)
    if textdrawPosX == 75 and textdrawPosY == 271 and menuType[4] then
        sampSendClickTextdraw(id)
        data.position.y = 100000.0
        return {id, data}
    elseif menuType[4] then
        return false
    end
    -- Отмена затемнения при посадке в фуру
    if data.position.x == -5 and data.position.y == -5 then
        return false
    end
    if textdrawPosX == 375 and textdrawPosY == 243 then
        buttonFill = id
    end
    if textdrawPosX == 320 and textdrawPosY == 199 then
        buttonSelectPriceFill = id
    end
    if textdrawPosX == 390 and textdrawPosY == 215 then
        buttonNextFill = id
    end
    if textdrawPosX == 301 and textdrawPosY == 218 then
        fillTypeName = id
    end
    
    if data.text == 'DIESEL' or data.text == 'A-92' or data.text == 'A-95' or data.text == 'A-98' then
        lua_thread.create(function()
            local filln = ''
            if fillType[1] then
                filln = 'DIESEL'
            elseif fillType[2] then
                filln = 'A-92'
            elseif fillType[3] then
                filln = 'A-95'
            elseif fillType[4] then
                filln = 'A-98'
            end
            for i = 1, 4 do
                if sampTextdrawGetString(fillTypeName) ~= filln then
                    sampSendClickTextdraw(buttonNextFill)
                    sampSendClickTextdraw(buttonSelectPriceFill)
                    wait(100)
                end
            end
            sampSendClickTextdraw(buttonFill)
        end)
    end
end

function e.onPlaySound(soundId, position)
    if soundId == 17803 and menuType[4] then
        return false
    end
end

function e.onServerMessage(color, text)
    if text:find(".+ достал%Xа%X .+ из кармана") and menuType[4] then
        return false
    end
    if text:find("%[Дальнобойщик%] (.+)%[(%d+)%]%: (.+)") then
        if settingsOffChatBool[0] then
            return false
        else
            color = -10270721
            local driverChatName, driverChatId, driverChatText = text:match("%[Дальнобойщик%] (.+)%[(%d+)%]%: (.+)")
            text = text.gsub(text, '%[Дальнобойщик%] (.+)%[(%d+)%]%: (.+)', '{fb116c}[Дальнобой] {ffffff}'..driverChatName..'['..driverChatId..']: {aeaeae}'..driverChatText)
            return {color, text}
        end
    end
    if text:find("взять новый можно на одной из баз дальнобойщиков") then
        endRoute(1)
    end
    if text:find("Ваша зарплата за рейс") then
        local earmoney = text:match("(%d+)")
        earningInSession = earningInSession + tonumber(earmoney)
        endRoute(2)
    end
    if text:find("Сцепка произойдёт автоматически") then
        startRoute()
        return false
    end
    if text:find("подцепите его грузовиком") then
        return false
    end
    if text:find("Вы подцепили груз") then
        return false
    end
    if text:find("{%x+}Во время рейса вам необходимо пройти весовой") then
        return false
    end
    if text:find("Взвешивание началось") then
        statusWeighing = u8'В процессе'
    end
    if text:find("Взвешивание завершено") then
        statusWeighing = u8'Пройдено'
    end
    --Автомобильное топливо успешно доставлено! Ваша зарплата за рейс: $115000.
    --Audio stream: http://music.arizona-rp.com/gps/warning_beep_far_high.mp3
end

function e.onPlayAudioStream(url, pos, rad, userpos)
    if url == 'http://music.arizona-rp.com/gps/warning_beep_far_high.mp3' then
        return false
    end
end

function startRoute()
    route[0] = true
end

function endRoute(reason)
    if reason == 2 then
        routesInSession = routesInSession + 1
        boxInSession = boxInSession + 1
        boxAll = boxAll + 1
        routesAll = routesAll + 1
        timeInRoutesSession = timeInRoutesSession + 1
        timeInRoutesAll = timeInRoutesAll + 1
        saveConfig()
    end
    statusWeighing = u8'Не пройдено'
    route[0] = false
end

function getCarNamebyModel(model)
    local names = {
        [403] = 'Linerunner',
        [514] = 'Tanker',
        [515] = 'Roadtrain',
	    [12725] = 'Actros',
        [12740] = 'Volvo'
    }
    return names[model]
end

function getRoute()
    if isPlayerPlaying(PLAYER_HANDLE) then
        local posX, posY, posZ = getCharCoordinates(playerPed)
        local res, x, y, z = SearchMarker(posX, posY, posZ, 150.0, false)
        local routeCur
        if x ~= 1348 or x ~= 1342 then
            if math.floor(x) == 1387 or math.floor(y) == 1181 or math.floor(z) == 9 then
                local a, b = math.modf(x)
                if b == 0.54833984375 then
                    routeCur = routes[3]
                elseif b == 0.989013671875 then
                    routeCur = routes[1]
                else
                    routeTrip = u8"1"
                end
            elseif math.floor(x) == -2249 or math.floor(y) == 304 or math.floor(z) == 33 then
                routeCur = routes[2]
            elseif math.floor(x) == 2187 or math.floor(y) == -2659 or math.floor(z) == 12 then
                routeCur = routes[4]
            elseif math.floor(x) == -2254 or math.floor(y) == 233 or math.floor(z) == 33 then
                routeCur = routes[5]
            elseif math.floor(x) == 2227 or math.floor(y) == -2636 or math.floor(z) == 11 then
                routeCur = routes[6]
            end
        end
    end
	if routeCur == nil then
		routeCur = u8"Неизвестно"
	end
	return routeCur
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

function getTruck()
    if isCharInAnyCar(PLAYER_PED) then
		currentTruck = getCarNamebyModel(getCarModel(storeCarCharIsInNoSave(PLAYER_PED)))
		if currentTruck == nil then
			currentTruck = u8"В машине"
		end
	else
		currentTruck = u8"Нет транспорта"
	end
	return currentTruck
end

function e.onShowDialog(id, style, title, button1, button2, text)
    if title:find("{%x+}Рабочие онлайн") and menuType[4] then
        loadDriverStatus = u8''..languageStrings["driverListLoad.status.four"]
        dPlayers, dPlayerNick, dPlayerId, dPlayerNumber = {}, {}, {}, {}
        separator = '\n'
        for str in string.gmatch(text, "([^"..separator.."]+)") do
                table.insert(dPlayers, str)
        end
        for v = 2, 60 do
            if dPlayers[v] ~= nil then
                dPlayerNick[v], dPlayerId[v], dPlayerNumber[v] = dPlayers[v]:match('{%x+}%d+. {%x+}Дальнобойщик (.+_.+)%X(%d+)%X	{%x+}(%d+)')
            end
        end
        loadDriverStatus = ''
        sampSendDialogResponse(id, 0, -1, -1)
        return false
    end
    if title:find("Меню") and menuType[4] then
        sampSendDialogResponse(id, 1 , 2, sampGetListboxItemText(2))
        loadDriverStatus = u8''..languageStrings["driverListLoad.status.two"]
        return false
    end
    if text:find("<< Дальнобойщики") and menuType[4] then
        sampSendDialogResponse(id, 1 , 28, sampGetListboxItemText(28))
        loadDriverStatus = u8''..languageStrings["driverListLoad.status.three"]
        return false
    end
    if title:find("{%x+}{%x+}Репорт") and settingsAutoReportBool[0] then
        sampSendDialogResponse(id, 1 , -1, u8:decode(str(sendReportText)))
        return false
    end
    if text:find("Ваша сытость: {......}%d+/%d+") and satietyCheck[0] then
        satietyVar = tonumber(text:match("Ваша сытость: {......}(%d+)/%d+"))
        sampSendDialogResponse(id, 0, -1, -1)
        return false
    end
    if title:find("{%x+}Выбор груза") and settingsAutoTrailerBool[0] then
        if pushTrailer() then
            return false
        end
    end
end

function pushTrailer()
    local trailersCount = {}
    for i = 0, 2 do
        if sampGetListboxItemText(i):find("{BEF781}") then
            trailersCount[i+1] = true
        end
    end
    if trailersCount[1] and trailerType[1] then
        sampSendDialogResponse(sampGetCurrentDialogId(), 1, 0, -1)
        sampAddChatMessage(driverTag..''..chatStrings["chatMessages.pickupFuelTrailer"], -1)
    elseif trailersCount[2] and trailerType[2] then
        sampSendDialogResponse(sampGetCurrentDialogId(), 1, 1, -1)
        if trailerType[2] then
            sampAddChatMessage(driverTag..''..chatStrings["chatMessages.pickupGunsTrailer"], -1)
        elseif trailerType[1] then
            sampAddChatMessage(driverTag..''..chatStrings["chatMessages.pickupElseOne"], -1)
        end
    else
        sampSendDialogResponse(sampGetCurrentDialogId(), 1, 2, -1)
        if trailerType[3] then
            sampAddChatMessage(driverTag..''..chatStrings["chatMessages.pickupProductsTrailer"], -1)
        else
            sampAddChatMessage(driverTag..''..chatStrings["chatMessages.pickupElseTwo"], -1)
        end
    end
    return true
end

-- Часть кофига

function loadConfig()
    menuType = decodeJson(iniMain.settings.menuType)
    eatType = decodeJson(iniMain.settings.eatType)
    fillType = decodeJson(iniMain.settings.fillType)
    trailerType = decodeJson(iniMain.settings.trailerType)
    settingsWidgetBool[0] = iniMain.settings.settingsWidgetBool
    settingsAutoEatBool[0] = iniMain.settings.settingsAutoEatBool
    settingsPipBool[0] = iniMain.settings.settingsPipBool
    settingsEngineControlBool[0] = iniMain.settings.settingsEngineControlBool
    settingsTimerArendaBool[0] = iniMain.settings.settingsTimerArendaBool
    settingsAutoBuyBool[0] = iniMain.settings.settingsAutoBuyBool
    settingsAutoFillBool[0] = iniMain.settings.settingsAutoFillBool
    settingsAutoBrakeBool[0] = iniMain.settings.settingsAutoBrakeBool
    settingsAutoDomkratBool[0] = iniMain.settings.settingsAutoDomkratBool
    settingsAutoSlagboumBool[0] = iniMain.settings.settingsAutoSlagboumBool
    settingsAutoReportBool[0] = iniMain.settings.settingsAutoReportBool
    settingsPipFillBool[0] = iniMain.settings.settingsPipFillBool
    settingsPipFuelBool[0] = iniMain.settings.settingsPipFuelBool
    settingsPipBoxBool[0] = iniMain.settings.settingsPipBoxBool
    settingsOffChatBool[0] = iniMain.settings.settingsOffChatBool
    sliderRepairCount[0] = iniMain.settings.sliderRepairCount
    sliderFillCount[0] = iniMain.settings.sliderFillCount
    settingsAutoTrailerBool[0] = iniMain.settings.settingsAutoTrailerBool
    sliderDomkratCount[0] = iniMain.settings.sliderDomkratCount
    m.StrCopy(sendReportText, iniMain.settings.sendReportText)
    widgetTransparrent[0] = iniMain.settingsWidget.widgetTransparrent
    widgetShowType = decodeJson(iniMain.settingsWidget.widgetShowType)
    currentLanguage = iniMain.settings.lang
    widgetPosX[0] = iniMain.settingsWidget.widgetPosX
    widgetPosY[0] = iniMain.settingsWidget.widgetPosY
    timeInRoutesAll = iniMain.driverStats.timeInRoutesAll
    boxAll = iniMain.driverStats.boxAll
    routesAll = iniMain.driverStats.routesAll
    local widgetLinksLua = decodeJson(iniMain.settingsWidget.widgetLinks)
    for i = 1, 10 do
        widgetLinks[i][0] = widgetLinksLua[i]
    end
end

function saveConfig()
    iniMain.settings.menuType = encodeJson(menuType)
    iniMain.settings.eatType = encodeJson(eatType)
    iniMain.settings.fillType = encodeJson(fillType)
    iniMain.settings.trailerType = encodeJson(trailerType)
    iniMain.settings.settingsWidgetBool = settingsWidgetBool[0]
    iniMain.settings.settingsAutoEatBool = settingsAutoEatBool[0]
    iniMain.settings.settingsPipBool = settingsPipBool[0]
    iniMain.settings.settingsEngineControlBool = settingsEngineControlBool[0]
    iniMain.settings.settingsTimerArendaBool = settingsTimerArendaBool[0]
    iniMain.settings.settingsAutoBuyBool = settingsAutoBuyBool[0]
    iniMain.settings.settingsAutoFillBool = settingsAutoFillBool[0]
    iniMain.settings.settingsAutoBrakeBool = settingsAutoBrakeBool[0]
    iniMain.settings.settingsAutoDomkratBool = settingsAutoDomkratBool[0]
    iniMain.settings.settingsAutoSlagboumBool = settingsAutoSlagboumBool[0]
    iniMain.settings.settingsAutoReportBool = settingsAutoReportBool[0]
    iniMain.settings.settingsPipFillBool = settingsPipFillBool[0]
    iniMain.settings.settingsAutoTrailerBool = settingsAutoTrailerBool[0]
    iniMain.settings.settingsPipFuelBool = settingsPipFuelBool[0]
    iniMain.settings.settingsPipBoxBool = settingsPipBoxBool[0]
    iniMain.settings.settingsOffChatBool = settingsOffChatBool[0]
    iniMain.settings.sliderRepairCount = sliderRepairCount[0]
    iniMain.settings.sliderFillCount = sliderFillCount[0]
    iniMain.settings.sliderDomkratCount = sliderDomkratCount[0]
    iniMain.settings.sendReportText = str(sendReportText)
    iniMain.settingsWidget.widgetTransparrent =widgetTransparrent[0]
    iniMain.settingsWidget.widgetShowType = encodeJson(widgetShowType)
    iniMain.settings.lang = currentLanguage
    iniMain.settingsWidget.widgetPosX = widgetPosX[0]
    iniMain.settingsWidget.widgetPosY = widgetPosY[0]
    iniMain.driverStats.timeInRoutesAll = timeInRoutesAll
    iniMain.driverStats.boxAll = boxAll
    iniMain.driverStats.routesAll = routesAll
    local widgetLinksLuaSave = {}
    for i = 1, 10 do
        widgetLinksLuaSave[i] = widgetLinks[i][0]
        if i == 10 then
            iniMain.settingsWidget.widgetLinks = encodeJson(widgetLinksLuaSave)
        end
    end
    inicfg.save(iniMain, iniDirectory)
end

local mainIni = inicfg.load({
    driverStats =
    {
        timeInRoutesAll = 0,
        boxAll = 0,
        routesAll = 0,
    },
    settings =
    {
        menuType = encodeJson({false, true, false, false, false}),
        eatType = encodeJson({false, true, false}),
        fillType = encodeJson({true, false, false}),
        trailerType = encodeJson({false, true, false}),
        settingsWidgetBool = false,
        settingsAutoEatBool = false,
        settingsPipBool = false,
        settingsEngineControlBool = false,
        settingsTimerArendaBool = false,
        settingsAutoBuyBool = false,
        settingsAutoFillBool = false,
        settingsAutoBrakeBool = false,
        settingsAutoDomkratBool = false,
        settingsAutoSlagboumBool = false, 
        settingsAutoReportBool = false, 
        settingsPipFillBool = false, 
        settingsPipFuelBool = false, 
        settingsPipBoxBool = false, 
        settingsOffChatBool = false,
        settingsAutoTrailerBool = false,
        sliderRepairCount = 5, 
        sliderFillCount = 3, 
        sliderDomkratCount = 1,
        sendReportText = u8'Я попал в воду, помогите',
        lang = 'RU'
    },
    settingsWidget =
    {
        widgetTransparrent = 1.00,
        widgetShowType = encodeJson({true, false, false}),
        widgetLinks = encodeJson({false, false, false, false, false, false, false, false, false, false}),
        widgetPosX = 100,
        widgetPosY = 400
    }
})

iniDirectory = "DriverReborn.ini"
iniMain = inicfg.load(mainIni, iniDirectory)
iniState = inicfg.save(iniMain, iniDirectory)

-- Dark Theme для скрипта. Автор: chapo (https://www.blast.hk/members/112329/)
function m.DarkTheme()
    m.SwitchContext()
    --==[ STYLE ]==--
    m.GetStyle().WindowPadding = m.ImVec2(5, 5)
    m.GetStyle().FramePadding = m.ImVec2(3, 3)
    m.GetStyle().ItemSpacing = m.ImVec2(5, 5)
    m.GetStyle().ItemInnerSpacing = m.ImVec2(2, 2)
    m.GetStyle().TouchExtraPadding = m.ImVec2(0, 0)
    m.GetStyle().IndentSpacing = 0
    m.GetStyle().ScrollbarSize = 10
    m.GetStyle().GrabMinSize = 10
    m.GetStyle().ColumnsMinSpacing = 25

    --==[ BORDER ]==--
    m.GetStyle().WindowBorderSize = 2
    m.GetStyle().ChildBorderSize = 2
    m.GetStyle().PopupBorderSize = 1
    m.GetStyle().FrameBorderSize = 0
    m.GetStyle().TabBorderSize = 1

    --==[ ROUNDING ]==--
    m.GetStyle().WindowRounding = 5
    m.GetStyle().ChildRounding = 5
    m.GetStyle().FrameRounding = 5
    m.GetStyle().PopupRounding = 5
    m.GetStyle().ScrollbarRounding = 5
    m.GetStyle().GrabRounding = 5
    m.GetStyle().TabRounding = 5

    --==[ ALIGN ]==--
    m.GetStyle().WindowTitleAlign = m.ImVec2(0.5, 0.5)
    m.GetStyle().ButtonTextAlign = m.ImVec2(0.5, 0.5)
    m.GetStyle().SelectableTextAlign = m.ImVec2(0.5, 0.5)
    
    --==[ COLORS ]==--
    m.GetStyle().Colors[m.Col.Text]                   = m.ImVec4(1.00, 1.00, 1.00, 1.00)
    m.GetStyle().Colors[m.Col.TextDisabled]           = m.ImVec4(0.50, 0.50, 0.50, 1.00)
    m.GetStyle().Colors[m.Col.WindowBg]               = m.ImVec4(0.07, 0.07, 0.07, 1.00)
    m.GetStyle().Colors[m.Col.ChildBg]                = m.ImVec4(0.07, 0.07, 0.07, 0.00)
    m.GetStyle().Colors[m.Col.PopupBg]                = m.ImVec4(0.07, 0.07, 0.07, 1.00)
    m.GetStyle().Colors[m.Col.Border]                 = m.ImVec4(0.25, 0.25, 0.26, 1.00)
    m.GetStyle().Colors[m.Col.BorderShadow]           = m.ImVec4(0.00, 0.00, 0.00, 0.00)
    m.GetStyle().Colors[m.Col.FrameBg]                = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.FrameBgHovered]         = m.ImVec4(0.25, 0.25, 0.26, 1.00)
    m.GetStyle().Colors[m.Col.FrameBgActive]          = m.ImVec4(0.25, 0.25, 0.26, 1.00)
    m.GetStyle().Colors[m.Col.TitleBg]                = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.TitleBgActive]          = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.TitleBgCollapsed]       = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.MenuBarBg]              = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.ScrollbarBg]            = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.ScrollbarGrab]          = m.ImVec4(0.00, 0.00, 0.00, 1.00)
    m.GetStyle().Colors[m.Col.ScrollbarGrabHovered]   = m.ImVec4(0.41, 0.41, 0.41, 1.00)
    m.GetStyle().Colors[m.Col.ScrollbarGrabActive]    = m.ImVec4(0.51, 0.51, 0.51, 1.00)
    m.GetStyle().Colors[m.Col.CheckMark]              = m.ImVec4(1.00, 1.00, 1.00, 1.00)
    m.GetStyle().Colors[m.Col.SliderGrab]             = m.ImVec4(0.21, 0.20, 0.20, 1.00)
    m.GetStyle().Colors[m.Col.SliderGrabActive]       = m.ImVec4(0.21, 0.20, 0.20, 1.00)
    m.GetStyle().Colors[m.Col.Button]                 = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.ButtonHovered]          = m.ImVec4(0.21, 0.23, 0.20, 1.00)
    m.GetStyle().Colors[m.Col.ButtonActive]           = m.ImVec4(0.41, 0.41, 0.41, 1.00)
    m.GetStyle().Colors[m.Col.Header]                 = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.HeaderHovered]          = m.ImVec4(0.20, 0.20, 0.20, 1.00)
    m.GetStyle().Colors[m.Col.HeaderActive]           = m.ImVec4(0.47, 0.47, 0.47, 1.00)
    m.GetStyle().Colors[m.Col.Separator]              = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.SeparatorHovered]       = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.SeparatorActive]        = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.ResizeGrip]             = m.ImVec4(1.00, 1.00, 1.00, 0.25)
    m.GetStyle().Colors[m.Col.ResizeGripHovered]      = m.ImVec4(1.00, 1.00, 1.00, 0.67)
    m.GetStyle().Colors[m.Col.ResizeGripActive]       = m.ImVec4(1.00, 1.00, 1.00, 0.95)
    m.GetStyle().Colors[m.Col.Tab]                    = m.ImVec4(0.12, 0.12, 0.12, 1.00)
    m.GetStyle().Colors[m.Col.TabHovered]             = m.ImVec4(0.28, 0.28, 0.28, 1.00)
    m.GetStyle().Colors[m.Col.TabActive]              = m.ImVec4(0.30, 0.30, 0.30, 1.00)
    m.GetStyle().Colors[m.Col.TabUnfocused]           = m.ImVec4(0.07, 0.10, 0.15, 0.97)
    m.GetStyle().Colors[m.Col.TabUnfocusedActive]     = m.ImVec4(0.14, 0.26, 0.42, 1.00)
    m.GetStyle().Colors[m.Col.PlotLines]              = m.ImVec4(0.61, 0.61, 0.61, 1.00)
    m.GetStyle().Colors[m.Col.PlotLinesHovered]       = m.ImVec4(1.00, 0.43, 0.35, 1.00)
    m.GetStyle().Colors[m.Col.PlotHistogram]          = m.ImVec4(0.90, 0.70, 0.00, 1.00)
    m.GetStyle().Colors[m.Col.PlotHistogramHovered]   = m.ImVec4(1.00, 0.60, 0.00, 1.00)
    m.GetStyle().Colors[m.Col.TextSelectedBg]         = m.ImVec4(1.00, 0.00, 0.00, 0.35)
    m.GetStyle().Colors[m.Col.DragDropTarget]         = m.ImVec4(1.00, 1.00, 0.00, 0.90)
    m.GetStyle().Colors[m.Col.NavHighlight]           = m.ImVec4(0.26, 0.59, 0.98, 1.00)
    m.GetStyle().Colors[m.Col.NavWindowingHighlight]  = m.ImVec4(1.00, 1.00, 1.00, 0.70)
    m.GetStyle().Colors[m.Col.NavWindowingDimBg]      = m.ImVec4(0.80, 0.80, 0.80, 0.20)
    m.GetStyle().Colors[m.Col.ModalWindowDimBg]       = m.ImVec4(0.00, 0.00, 0.00, 1.00)
end