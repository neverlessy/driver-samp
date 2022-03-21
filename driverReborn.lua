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
script_version('1.3.3')
script_version_number(2211)
script_description('All rights reserved. © Moon Glance 2022')

--  Объявление переменных для удобства кода согласно moongl.ru/coderules
local new, v2, v4, cupoX, cupoY, chatMessage, flags = m.new, m.ImVec2, m.ImVec4, m.SetCursorPosX, m.SetCursorPosY, sampAddChatMessage, m.WindowFlags

-- Объявление других переменных
enc.default = 'CP1251'
local u8 = enc.UTF8
local str, sizeof = ffi.string, ffi.sizeof
local driverMenu, widgetMenu, settingsAutoTrailerBool, settingsWidgetBool, settingsAutoEatBool, settingsPipBool, settingsEngineControlBool, settingsTimerArendaBool, settingsAutoBuyBool, settingsAutoFillBool, settingsAutoBrakeBool, settingsAutoDomkratBool, settingsAutoSlagboumBool, settingsAutoReportBool, settingsPipFillBool, settingsPipFuelBool, settingsPipBoxBool, settingsOffChatBool = new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool()
local widgetLinks, menuType, eatType, fillType, trailerType, widgetShowType, dPlayers, dPlayerNick, dPlayerId, dPlayerNumber = {new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool()}, {true, false, false, false, false}, {false, true, false}, {true, false, false}, {false, true, false}, {true, false, false}, {}, {}, {}, {}
local widgetTransparrent, sendReportText, sliderRepairCount, sliderFillCount, sliderDomkratCount, loadDriverStatus = new.float(1.00), new.char[85](u8"Я попал в воду! Помогите!"), new.int(5), new.int(5), new.int(5), ''
-- Код

local driverWidgetMenuFrame = m.OnFrame(
    function() return widgetMenu[0] end,
    function(player)
        m.PushStyleColor(m.Col.WindowBg, v4(0.07, 0.07, 0.07, widgetTransparrent[0]))
        m.PushStyleColor(m.Col.Text, v4(1.00, 1.00, 1.00, widgetTransparrent[0]))
        m.PushStyleColor(m.Col.Separator, v4(0.12, 0.12, 0.12, widgetTransparrent[0]))
        m.PushStyleColor(m.Col.Border, v4(0.25, 0.25, 0.26, widgetTransparrent[0]))
        m.SetNextWindowPos(v2(200, 550), m.Cond.FirstUseEver, v2(0.5, 0.5))
        m.SetNextWindowSize(v2(250, checkSizeWidget() + 55), m.Cond.Always)
        m.Begin("widget", widgetMenu, flags.NoResize + flags.NoCollapse + flags.NoScrollbar + flags.NoTitleBar)
            m.CenterText(u8"RoadTrain") m.Separator()
                m.BeginChild('WidgetMenu', v2(240, checkSizeWidget()), false)
                if widgetLinks[1][0] then
                    m.CenterText(u8"Взвешивание: Нет маршрута")
                end
                if widgetLinks[2][0] then
                    m.CenterText(u8"Заработок: 0$")
                end
                if widgetLinks[3][0] then
                    m.CenterText(u8"Маршрут: Нет маршрута")
                end
                if widgetLinks[4][0] then
                    m.CenterText(u8"Рейсов за сессию: 0")
                end
                if widgetLinks[5][0] then
                    m.CenterText(u8"Ларцов за сессию: 0")
                end
                if widgetLinks[6][0] then
                    m.CenterText(u8"Всего ларцов: 0")
                end
                if widgetLinks[7][0] then
                    m.CenterText(u8"Всего рейсов: 0")
                end
                if widgetLinks[8][0] then
                    m.CenterText(u8"Времени в рейсах: 00:00:00")
                end
                if widgetLinks[9][0] then
                    m.CenterText(u8"Времени в рейсах всего: 00:00:00")
                end
                if widgetLinks[10][0] then
                    m.CenterText(u8"Навык дальнобойщика: 0")
                end
                m.EndChild()
            m.Text('', cupoY(checkSizeWidget() + 10))
            m.Separator()
            m.CenterText(u8""..os.date("%X")..' | '..os.date("*t").day..'.'..os.date("*t").month..'.'..os.date("*t").year) 
        m.End()
        m.PopStyleColor(4)
        player.HideCursor = true
    end
)

local driverMenuFrame = m.OnFrame(
    function() return driverMenu[0] end,
    function(player)
        m.SetNextWindowPos(v2(400, 550), m.Cond.FirstUseEver, v2(0.5, 0.5))
        m.SetNextWindowSize(v2(750, 400), m.Cond.FirstUseEver)
        m.Begin("Main Window", driverMenu, flags.NoResize + flags.NoCollapse + flags.NoScrollbar + flags.NoTitleBar)
            m.BeginChild('#MenuBar', v2(200, 390), false)
                if m.ButtonActivated(menuType[1], u8"О скрипте", v2(200, 50), cupoX(0)) then
                    switchMenu(1)
                end
                if m.ButtonActivated(menuType[2], u8"Настройки", v2(200, 50), cupoX(0)) then
                    switchMenu(2)
                end
                if m.ButtonActivated(menuType[3], u8"Лог рейсов", v2(200, 50), cupoX(0))  then
                    switchMenu(3)
                end
                if m.ButtonActivated(menuType[4], u8"Дальнобойщики онлайн", v2(200, 50), cupoX(0)) then
                    switchMenu(4)
                end
                if m.ButtonActivated(menuType[5], u8"Патчноут", v2(97, 50), cupoX(102), cupoY(340)) then
                    switchMenu(5)
                end
                if m.Button(u8"Закрыть", v2(97, 50), cupoX(0), cupoY(340)) then
                    if menuType[4] then
                        switchMenu(1)
                    end
                    driverMenu[0] = false
                end
                
            m.EndChild() m.SameLine()
            m.BeginChild('#Content', v2(535, 390), false)
                if menuType[1] then
                    m.Image(logoDriver, v2(300, 300), cupoX(120))
                    m.CenterText(u8'Автор: Moon Glance (neverlessy)')
                    m.CenterText(u8'Текущая версия: 1.3.3')
                    m.CenterText(u8'Текущий билд: 2211')
                end
                if menuType[2] then
                    m.Checkbox(u8" Показ виджета", settingsWidgetBool)
                        if settingsWidgetBool[0] then
                            if m.Button(u8"Настройки виджета", v2(150,30), cupoX(25)) then
                                m.OpenPopup('widgetSettings')
                            end
                            m.Text(u8"Режим работы виджета", cupoX(25))
                            if m.ButtonActivated(widgetShowType[1], u8"Всегда", v2(150,30), cupoX(25)) then
                                switchShowWidgetType(1)
                            end m.SameLine()
                            if m.ButtonActivated(widgetShowType[2], u8"В грузовике", v2(150,30)) then
                                switchShowWidgetType(2)
                            end m.SameLine()
                            if m.ButtonActivated(widgetShowType[3], u8"В рейсе", v2(150,30)) then
                                switchShowWidgetType(3)
                            end
                        end
                    m.Checkbox(u8" Автоматическая еда", settingsAutoEatBool)
                        if settingsAutoEatBool[0] then
                            if m.ButtonActivated(eatType[1], u8"Оленина", v2(150,30), cupoX(25)) then
                                switchEatType(1)
                            end m.SameLine()
                            if m.ButtonActivated(eatType[2], u8"Рыба", v2(150,30)) then
                                switchEatType(2)
                            end m.SameLine()
                            if m.ButtonActivated(eatType[3], u8"Чипсы", v2(150,30)) then
                                switchEatType(3)
                            end
                        end
                    if m.Checkbox(u8" Контроль двигателя", settingsEngineControlBool) then
                        
                    end
                    m.Checkbox(u8" Звуковое сопровождение", settingsPipBool)
                        if settingsPipBool[0] then
                            m.Checkbox(u8" Если рядом есть заправка", settingsPipFillBool, cupoX(25))
                            m.Checkbox(u8" Если мало бензина", settingsPipFuelBool, cupoX(25))
                            m.Checkbox(u8" Если выпал ларец", settingsPipBoxBool, cupoX(25))
                        end
                    m.Checkbox(u8" Таймер аренды", settingsTimerArendaBool)
                        if settingsTimerArendaBool[0] then
                            m.Button(u8"Настройки таймера", v2(150,30), cupoX(25))
                        end
                    m.Checkbox(u8" Закупка", settingsAutoBuyBool)
                        if settingsAutoBuyBool[0] then
                            m.SliderInt(u8' Наборы починки', sliderRepairCount, 1, 15, cupoX(25))
                            m.SliderInt(u8' Канистры', sliderFillCount, 1, 15, cupoX(25))
                            m.SliderInt(u8' Домкраты', sliderDomkratCount, 1, 15, cupoX(25))
                            --sliderRepairCount, sliderFillCount, sliderDomkratCount
                        end
                    m.Checkbox(u8" Заправка", settingsAutoFillBool)
                    if settingsAutoFillBool[0] then
                        if m.ButtonActivated(fillType[1], u8"АИ-92", v2(150,30), cupoX(25)) then
                            switchFillType(1)
                        end m.SameLine()
                        if m.ButtonActivated(fillType[2], u8"АИ-95", v2(150,30)) then
                            switchFillType(2)
                        end m.SameLine()
                        if m.ButtonActivated(fillType[3], u8"АИ-98", v2(150,30)) then
                            switchFillType(3)
                        end
                    end
                    m.Checkbox(u8" Тормоз", settingsAutoBrakeBool)
                    m.Checkbox(u8" Домкрат", settingsAutoDomkratBool)
                    m.Checkbox(u8" Шлагбаум", settingsAutoSlagboumBool)
                    m.Checkbox(u8" Прицеп", settingsAutoTrailerBool)
                        if settingsAutoTrailerBool[0] then
                            if m.ButtonActivated(trailerType[1], u8"Топливо", v2(150,30), cupoX(25)) then
                                switchTrailerType(1)
                            end m.SameLine()
                            if m.ButtonActivated(trailerType[2], u8"Оружие", v2(150,30)) then
                                switchTrailerType(2)
                            end m.SameLine()
                            if m.ButtonActivated(trailerType[3], u8"Продукты", v2(150,30)) then
                                switchTrailerType(3)
                            end
                        end
                    m.Checkbox(u8" Репорт при попадании в воду", settingsAutoReportBool)
                        if settingsAutoReportBool[0] then
                            --m.Button(u8"Изменить текст", v2(150,30), cupoX(25))
                            m.InputText(u8" - Текст при попадании", sendReportText, sizeof(sendReportText), cupoX(25))
                        end
                    m.Checkbox(u8' Отключить чат дальнобойщиков', settingsOffChatBool)
                end
                if menuType[4] then
                    displayRadar(true)
                    if dPlayers[2] == nil then
                        m.PushFont(fonts[25])
                            m.CenterText(u8"Загрузка", cupoY(150))
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
                            m.CenterColumnText(u8'Никнейм')
                            m.NextColumn()
                            m.CenterColumnText(u8'Номер телефона')
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
                        m.CenterText(u8"Обновление 1.3.2", cupoY(5))
                    m.PopFont()
                    m.PushFont(fonts[15])
                        m.Text(u8"- Скрипт переписан с нуля\n- Обновлено что-то там", cupoX(15))
                    m.PopFont()
                end
                if m.BeginPopup('widgetSettings') then
                        m.BeginChild('#Popip', v2(250, 305), false)
                            m.Button(u8"Изменить положение", v2(250, 30))
                            m.SliderFloat(u8' Прозрачность виджета', widgetTransparrent, 0.00, 1.00)
                            if m.Checkbox(u8" Взвешивание", widgetLinks[1]) or
                            m.Checkbox(u8" Заработок", widgetLinks[2]) or
                            m.Checkbox(u8" Маршрут", widgetLinks[3]) or
                            m.Checkbox(u8" Рейсы за сессию", widgetLinks[4]) or
                            m.Checkbox(u8" Ларцы за сессию", widgetLinks[5]) or
                            m.Checkbox(u8" Всего ларцов", widgetLinks[6]) or
                            m.Checkbox(u8" Всего рейсов", widgetLinks[7]) or
                            m.Checkbox(u8" Времени в рейсах", widgetLinks[8]) or
                            m.Checkbox(u8" Времени в рейсах всего", widgetLinks[9]) or
                            m.Checkbox(u8" Навык дальнобойщика", widgetLinks[10]) then
                                saveConfig()
                                checkSizeWidget()
                            end
                        m.EndChild()
                    m.EndPopup()
                end
            m.EndChild()
        m.End()
        player.HideCursor = false
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
    for i = 1, 3 do
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

function moonVec4(numberhex)
    a, r, g, b = tonumber(string.sub(numberhex, 1, 2), 16) / 255, tonumber(string.sub(numberhex, 3, 4), 16) / 255, tonumber(string.sub(numberhex, 5, 6), 16) / 255, tonumber(string.sub(numberhex, 7, 8), 16) / 255
    return v4(tonumber(string.format("%.2f", r)), tonumber(string.format("%.2f", g)), tonumber(string.format("%.2f", b)), tonumber(string.format("%.2f", a)))
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
    sampAddChatMessage('Загружен', -1)
    driverMenu[0] = not driverMenu[0]
    updateReport()
    updateDriverPlayers()
    loadConfig()
    while true do wait(0)
        if settingsWidgetBool[0] then
            widgetMenu[0] = true
        else
            widgetMenu[0] = false
        end
        if testCheat('drv') then driverMenu[0] = not driverMenu[0] end
    end
end

function updateDriverPlayers()
    lua_thread.create(function()
        while true do wait(0)
            if menuType[4] then
                loadDriverStatus = u8'Устанавливаю связь с космосом'
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
end

function e.onShowDialog(id, style, title, button1, button2, text)
    if title:find("{%x+}Рабочие онлайн") and menuType[4] then
        loadDriverStatus = u8'Уже почти...'
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
        loadDriverStatus = u8'Взламываю пентагон'
        return false
    end
    if text:find("<< Дальнобойщики") and menuType[4] then
        sampSendDialogResponse(id, 1 , 28, sampGetListboxItemText(28))
        loadDriverStatus = u8'Открываю базу данных NASA'
        return false
    end
    if title:find("{%x+}{%x+}Репорт") and settingsAutoReportBool[0] then
        sampSendDialogResponse(id, 1 , -1, u8:decode(str(sendReportText)))
        return false
    end
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
        totalTrailers = 0,
        totalBoxs = 0,
        totalTimeInTrip = 0
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
    },
    settingsWidget =
    {
        widgetTransparrent = 1.00,
        widgetShowType = encodeJson({true, false, false}),
        widgetLinks = encodeJson({false, false, false, false, false, false, false, false, false, false})
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