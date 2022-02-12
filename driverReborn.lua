script_name("Driver")
script_authors("neverlessy")
script_version("1.3")
script_version_number(3)

local enc = require 'encoding'
local imgui = require 'mimgui'
local inicfg = require 'inicfg'
local ev = require 'samp.events'
local eve = require "moonloader".audiostream_state
local vk = require 'vkeys'
local ffi = require 'ffi'
local memory = require 'memory'
local toggle = false
local final = false
local startTrip = false
local work = false
local activatedDriver = true
local textCoords = {x = {-197, -1320, -2132, -1577, 688}, y = {2626, 2663, -2257, -2748, -663}, z = {63, 50, 31, 48, 16}}
local wm = require("windows.message")
enc.default = 'CP1251'
local u8 = enc.UTF8
local new = imgui.new
local tag = "{a33ac3}[Driver] {d6d6d6}"
local scr = thisScript()
local renderWindow = new.bool()
local infoWindow = new.bool()
local sizeX, sizeY = getScreenResolution()
local logoImagePng
local soundPip = loadAudioStream("moonloader/resource/Driver/audio/ignition.mp3")
local str, sizeof = ffi.string, ffi.sizeof
------------------------------------------------ Переменные mimgui
local widgetBool = new.bool()
local autoEatBool = new.bool()
local engineControlBool = new.bool()
local pipBool = new.bool()
local autoBuyBool = new.bool()
local autoTrailerBool = new.bool()
local autoBreakBool = new.bool()
local autoDomkratBool = new.bool()
local autoSlakbaumBool = new.bool()

local currentTruckBool = new.bool()
local weightingBool = new.bool()
local sumBool = new.bool()
local routeBool = new.bool()
local currentTripBool = new.bool()
local tripSessionBool = new.bool()
local boxSessionBool = new.bool()
local sessionTimeInTripBool = new.bool()
local totalTripBool = new.bool()
local totalBoxsBool = new.bool()
local totalTimeInTripBool = new.bool()
local currentExpBool = new.bool()

local settingsActive = false
local mainActive = false
local logTripActive = false
local eatTypeName = u8"Выбор еды"
local autoBuyRepairCount = new.int(5)
local autoBuyFuelCount = new.int(5)
local autoBuyDomkratCount = new.int(5)
local boxCost = new.char[9](" ")
local satiety = 100
local checkBool = false

local widgetPosX = 300
local widgetPosY = 500
local widgetEditingMode = false
local widgetTripY = 100
local widgetTotalY = 135
local widgetY = 265
local widgetTransparent = new.float(1.00)

------------------------------------------------

local totalTrailers = 0
local truckExp = 0
local sessionTrailers = 0
local currentTruck = "Linerunner [1]"
local totalBoxs = 0
local sessionBoxs = 0
local totalTimeInTrip = 0
local sessionTimeInTrip = 0
local weighing = u8"Вне маршрута"
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
local cDomkrat = false
------------------------------------------------

local mainIni = inicfg.load({
  driverStats =
  {
    totalTrailers = 0,
		totalBoxs = 0,
		totalTimeInTrip = 0,
		boxPrice = 0
  },
	settings =
	{
		widgetBool = false,
		autoEatBool = false,
		engineControlBool = false,
		pipBool = false,
		autoBuyBool = false,
		autoTrailerBool = false,
		autoBreakBool = false,
		autoDomkratBool = false,
		autoSlakbaumBool = false,
		autoBuyRepairCount = 5,
		autoBuyFuelCount = 5,
		autoBuyDomkratCount = 5,
		eatType = u8"Выбор еды"
	},
	settingsWidget =
	{
		widgetTransparent = 1.00,
		widgetTripY = 100,
		widgetTotalY = 135,
		widgetY = 265,
		widgetPosX = 300,
		widgetPosY = 500,
		currentTruckBool = true,
		weightingBool = false,
		sumBool = true,
		routeBool = true,
		currentTripBool = false,
		tripSessionBool = false,
		boxSessionBool = false,
		sessionTimeInTripBool = false,
		totalTripBool = true,
		totalBoxsBool = true,
		totalTimeInTripBool = false,
		currentExpBool = true,
	}
})

local iniDirectory = "driverR.ini"
local iniMain = inicfg.load(mainIni, iniDirectory)
local iniState = inicfg.save(iniMain, iniDirectory)

imgui.OnInitialize(function()
		styleInit()
		logoImagePng = imgui.CreateTextureFromFile("moonloader/resource/Driver/logo.png")
    imgui.GetIO().IniFilename = nil
end)

local settingsFrame = imgui.OnFrame(
    function() return renderWindow[0] end,
    function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(700, 450), imgui.Cond.FirstUseEver)
        imgui.Begin("Main Window", renderWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar)
				imgui.BeginChild("##navigation", imgui.ImVec2(220, 430), false)
						imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 6)
						if imgui.Button(u8"Главное меню", imgui.ImVec2(220, 50)) then
							if settingsActive then
								settingsActive = not settingsActive
							end
							if logTripActive then
								logTripActive = not logTripActive
							end
							mainActive = not mainActive
						end
						if imgui.Button(u8"Настройки", imgui.ImVec2(220, 50)) then
							if mainActive then
								mainActive = not mainActive
							end
							if logTripActive then
								logTripActive = not logTripActive
							end
							settingsActive = not settingsActive
						end
						if imgui.Button(u8"Лог рейсов", imgui.ImVec2(220, 50)) then
							if settingsActive then
								settingsActive = not settingsActive
							end
							if mainActive then
								mainActive = not mainActive
							end
							logTripActive = not logTripActive
						end
						imgui.Text("") imgui.Text("") imgui.Text("") imgui.Text("") imgui.Text("") imgui.Text("")
						imgui.Text("") imgui.Text("") imgui.Text("") imgui.Text("") imgui.Text("") imgui.Text("")
						if imgui.Button(u8"Закрыть", imgui.ImVec2(220,50)) then
							renderWindow[0] = not renderWindow[0]
						end
						imgui.PopStyleVar(1)
				imgui.EndChild()
				imgui.SameLine()
				imgui.BeginChild("##settings", imgui.ImVec2(455, 430), false)
				if mainActive then
					imgui.Text("           ") imgui.SameLine() imgui.Image(logoImagePng, imgui.ImVec2(350, 350))
					imgui.Text(u8"   Автор скрипта: "..tostring(scr.authors[1]))
					imgui.Text(u8"   Версия: "..tostring(scr.version))
					imgui.Text(u8"   Текущий номер билда: 220"..tostring(scr.version_num))
				end
				if logTripActive then
					imgui.Spacing()
					imgui.Text(u8"  Скоро.")
				end
				if settingsActive then
					imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 6)
							if imgui.Checkbox(u8'Виджет', widgetBool) then
								switchCheckBox(widgetBool[0], "Виджет")
							end
							if widgetBool[0] == true then
								imgui.SameLine()
								if imgui.Button(u8"Изменить") then
									imgui.OpenPopup('widgetSettings')
								end
							end
							imgui.TextQuestion("( ? )", u8"Активирует виджет с различной полезной информацией")
							if imgui.Checkbox(u8'Авто-еда', autoEatBool) then
								switchCheckBox(autoEatBool[0], "Автоматическое пополнение голода")
								if autoEatBool[0] == false then
									eatTypeName = u8"Выбор еды"
									iniMain.settings.eatType = eatTypeName
									inicfg.save(iniMain, iniDirectory)
								end
							end
							if autoEatBool[0] == true then
								imgui.SameLine()
								if imgui.Button(u8""..eatTypeName) then
									imgui.OpenPopup('eatType')
								end
							end
							imgui.TextQuestion("( ? )", u8"Скрипт всегда будет держать ваш уровень голода выше 70")
							if imgui.Checkbox(u8'Контроль двигателя', engineControlBool) then
								switchCheckBox(engineControlBool[0], "Заглушение двигателя при взвешивании")
							end
							imgui.TextQuestion("( ? )", u8"Когда начинается взвешивание - скрипт глушит двигатель, за 2 секунды до окончания взвешивания вновь заводит.")
							if imgui.Checkbox(u8'Сигнал о взвешивании', pipBool) then
								switchCheckBox(pipBool[0], "Звуковой сигнал рядом с точкой взвешивания")
							end
							imgui.TextQuestion("( ? )", u8"При приближении к точке взвешивания менее чем на 150 метров воспроизводит звуковой сигнал и сообщение в чате")
							--[[if imgui.Checkbox(u8'Авто-еда', autoEatBool) then
								switchCheckBox(autoEatBool[0], "Таймер аренды кастомной фуры")
							end]]
							if imgui.Checkbox(u8'Автоматическая закупка', autoBuyBool) then
								switchCheckBox(autoBuyBool[0], "Автоматическая закупка")
							end
							if autoBuyBool[0] == true then
								imgui.SameLine()
								if imgui.Button(u8"Настройки") then
									imgui.OpenPopup('autoBuyPopup')
								end
							end
							imgui.TextQuestion("( ? )", u8"Автоматически закупает домкраты, ремкомплекты и канистры")
							if imgui.Checkbox(u8'Авто-прицеп', autoTrailerBool) then
								switchCheckBox(autoTrailerBool[0], "Автоматическое взятие прицепа")
							end
							imgui.TextQuestion("( ? )", u8"При наезде на пикап скрипт сам выбирает из доступных прицепов согласно их приоритету. Приоритет: Топливо > Оружие > Продукты")
							if imgui.Checkbox(u8'Тормоз', autoBreakBool) then
								switchCheckBox(autoBreakBool[0], "Автоматический тормоз")
							end
							imgui.TextQuestion("( ? )", u8"Если во время рейса точка не береться - скрипт моментально сбавляет скорость грузовика.")
							if imgui.Checkbox(u8'Домкрат', autoDomkratBool) then
								switchCheckBox(autoDomkratBool[0], "Автоматический домкрат")
							end
							imgui.TextQuestion("( ? )", u8"Если фура перевернулась и у вас есть домкрат, скрипт сразу перевернет грузовик.")
							if imgui.Checkbox(u8'Шлагбаум', autoSlakbaumBool) then
								switchCheckBox(autoSlakbaumBool[0], "Автоматический шлагбаум")
							end
							imgui.TextQuestion("( ? )", u8"Около шлагбаума скрипт начинает очень быстро сигналить")
							------Popups
							if imgui.BeginPopup('eatType') then
								if imgui.Button(u8'Чипсы') then
										sampAddChatMessage(tag.."Вы выбрали в качестве еды: {48d993}Чипсы", -1)
										eatTypeName = u8"Чипсы"
										iniMain.settings.eatType = eatTypeName
										inicfg.save(iniMain, iniDirectory)
										imgui.CloseCurrentPopup()
								end
									if imgui.Button(u8'Мясо оленины') then
											sampAddChatMessage(tag.."Вы выбрали в качестве еды: {48d993}Мясо оленины", -1)
											eatTypeName = u8"Мясо оленины"
											iniMain.settings.eatType = eatTypeName
											inicfg.save(iniMain, iniDirectory)
											imgui.CloseCurrentPopup()
									end
									if imgui.Button(u8'Рыба') then
											sampAddChatMessage(tag.."Вы выбрали в качестве еды: {48d993}Рыбу", -1)
											eatTypeName = u8"Рыба"
											iniMain.settings.eatType = eatTypeName
											inicfg.save(iniMain, iniDirectory)
											imgui.CloseCurrentPopup()
									end
									imgui.EndPopup()
							end
							if imgui.BeginPopup('autoBuyPopup') then
								imgui.SliderInt(u8"Набор починки", autoBuyRepairCount, 0, 15)
								imgui.SliderInt(u8"Канистры", autoBuyFuelCount, 0, 15)
								imgui.SliderInt(u8"Домкраты", autoBuyDomkratCount, 0, 15)
									if imgui.Button(u8'Сохранить') then
										iniMain.settings.autoBuyRepairCount = autoBuyRepairCount[0]
										iniMain.settings.autoBuyFuelCount = autoBuyFuelCount[0]
										iniMain.settings.autoBuyDomkratCount = autoBuyDomkratCount[0]
										if inicfg.save(iniMain, iniDirectory) then
											sampAddChatMessage(tag.."{d6d6d6}Вы установили количество предметов для автоматической закупки: ", -1)
											sampAddChatMessage(tag.."> Набор починки {48d993}["..tostring(autoBuyRepairCount[0]).."] {d6d6d6}шт", -1)
											sampAddChatMessage(tag.."> Канистры {48d993}["..tostring(autoBuyFuelCount[0]).."] {d6d6d6}шт", -1)
											sampAddChatMessage(tag.."> Домкраты {48d993}["..tostring(autoBuyDomkratCount[0]).."] {d6d6d6}шт", -1)
											imgui.CloseCurrentPopup()
										else
											sampAddChatMessage(tag.."При сохранении настроек произошла {f5326a}ошибка", -1)
										end
									end
									imgui.EndPopup()
							end
							if imgui.BeginPopup('widgetSettings') then
									if imgui.Button(u8'Изменить положение виджета') then
										sampAddChatMessage(tag.."Передвиньте виджет в удобное для вас место и нажмите кнопку {48d993}[F]", -1)
										widgetEditingMode = not widgetEditingMode
										renderWindow[0] = not renderWindow[0]
									end
									if imgui.Checkbox(u8'Отображение транспорта', currentTruckBool) then
										resizeWidget(currentTruckBool[0], 1)
										switchCheckBox(currentTruckBool[0], "{48d993}<Виджет>{d6d6d6} Отображение транспорта")
									end
									if imgui.Checkbox(u8'Статус взвешивания', weightingBool) then
										resizeWidget(weightingBool[0], 1)
										switchCheckBox(weightingBool[0], "{48d993}<Виджет>{d6d6d6} Отображение статуса взвешивания")
									end
									if imgui.Checkbox(u8'Заработок', sumBool) then
										resizeWidget(sumBool[0], 1)
										switchCheckBox(sumBool[0], "{48d993}<Виджет>{d6d6d6} Отображение заработка за сессию")
									end
									if imgui.Checkbox(u8'Маршрут', routeBool) then
										resizeWidget(routeBool[0], 1)
										switchCheckBox(routeBool[0], "{48d993}<Виджет>{d6d6d6} Отображение маршрута")
									end
									if imgui.Checkbox(u8'Время в рейсе', currentTripBool) then
										resizeWidget(currentTripBool[0], 1)
										switchCheckBox(currentTripBool[0], "{48d993}<Виджет>{d6d6d6} Отображение текущего времени рейса")
									end



									if imgui.Checkbox(u8'Рейсы за сессию', tripSessionBool) then
										resizeWidget(tripSessionBool[0], 2)
										switchCheckBox(tripSessionBool[0], "{48d993}<Виджет>{d6d6d6} Отображение рейсов за сессию")
									end
									if imgui.Checkbox(u8'Ларцы за сессию', boxSessionBool) then
										resizeWidget(boxSessionBool[0], 2)
										switchCheckBox(boxSessionBool[0], "{48d993}<Виджет>{d6d6d6} Отображение ларцов за сессию")
									end
									if imgui.Checkbox(u8'Время за сессию', sessionTimeInTripBool) then
										resizeWidget(sessionTimeInTripBool[0], 2)
										switchCheckBox(sessionTimeInTripBool[0], "{48d993}<Виджет>{d6d6d6} Отображение времени в рейсах за сессию")
									end
									if imgui.Checkbox(u8'Всего рейсов', totalTripBool) then
										resizeWidget(totalTripBool[0], 2)
										switchCheckBox(totalTripBool[0], "{48d993}<Виджет>{d6d6d6} Общее количество рейсов")
									end
									if imgui.Checkbox(u8'Всего ларцов', totalBoxsBool) then
										resizeWidget(totalBoxsBool[0], 2)
										switchCheckBox(totalBoxsBool[0], "{48d993}<Виджет>{d6d6d6} Общее количество ларцов")
									end
									if imgui.Checkbox(u8'Всего в рейсах', totalTimeInTripBool) then
										resizeWidget(totalTimeInTripBool[0], 2)
										switchCheckBox(totalTimeInTripBool[0], "{48d993}<Виджет>{d6d6d6} Общее время в рейсах")
									end
									if imgui.Checkbox(u8'Навык дальнобойщика', currentExpBool) then
										resizeWidget(currentExpBool[0], 2)
										switchCheckBox(currentExpBool[0], "{48d993}<Виджет>{d6d6d6} Отображение навыка дальнобойщика")
									end
									if imgui.SliderFloat(u8"Прозрачность виджета", widgetTransparent, 0.1, 1.0) then
										iniMain.settingsWidget.widgetTransparent = widgetTransparent[0]
										inicfg.save(iniMain, iniDirectory)
									end
									if imgui.InputText(u8"Цена ларца", boxCost, sizeof(boxCost)) then
										if str(boxCost) ~= '' then
											if tonumber(str(boxCost)) then
												iniMain.driverStats.boxPrice = tonumber(str(boxCost))
												print(u8:decode(str(boxCost)))
												inicfg.save(iniMain, iniDirectory)
												boxPrice = iniMain.driverStats.boxPrice
												imgui.StrCopy(boxCost, tostring(boxPrice))
											else
												sampAddChatMessage(tag.."Введите корректное {f5326a}число", -1)
											end
										end
									end
									imgui.EndPopup()
							end
							imgui.PopStyleVar(1)
				end
				imgui.EndChild()
        imgui.End()
				--player.HideCursor = true
    end
)

local infoFrame = imgui.OnFrame(
		function() return infoWindow[0] end,
		function(player)
			--[[local style = imgui.GetStyle()
			local colors = style.Colors
			local clr = imgui.Col]]
			imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.06, 0.05, 0.07, widgetTransparent[0]))
			imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0.07, 0.07, 0.09, widgetTransparent[0]))
			imgui.SetNextWindowSize(imgui.ImVec2(247, widgetY), imgui.Cond.Always)
			imgui.SetNextWindowPos(imgui.ImVec2(widgetPosX, widgetPosY), imgui.Cond.FirstUseEver)
			if widgetEditingMode then
				imgui.Begin("WIDGET", renderWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar)
				player.HideCursor = false
				if isKeyJustPressed(70) then
					widgetEditingMode = not widgetEditingMode
					local pos = imgui.GetWindowPos()
					widgetPosX, widgetPosY = pos.x, pos.y
					iniMain.settingsWidget.widgetPosX = widgetPosX
					iniMain.settingsWidget.widgetPosY = widgetPosY
					if inicfg.save(iniMain, iniDirectory) then
						sampAddChatMessage(tag.."Изменения успешно {48d993}сохранены", -1)
						renderWindow[0] = not renderWindow[0]
					end
				end
			else
				player.HideCursor = true
				imgui.Begin("WIDGET", renderWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove)
			end
			imgui.BeginChild("##tripInfo", imgui.ImVec2(230, widgetTripY), false)
				imgui.Spacing()
				if currentTruckBool[0] then
					imgui.Text("") imgui.SameLine() imgui.Text(u8"Текущий транспорт: "..getTruck())
				end
				if weightingBool[0] then
					imgui.Text("") imgui.SameLine() imgui.Text(u8"Взвешивание: "..weighing)
				end
				if sumBool[0] then
					imgui.Text("") imgui.SameLine() imgui.Text(u8"Заработок: "..sumFormat(sum).." $")
				end
				if routeBool[0] then
					imgui.Text("") imgui.SameLine() imgui.Text(u8"Маршрут: "..routeTrip)
				end
				if currentTripBool[0] then
					imgui.Text("") imgui.SameLine() imgui.Text(u8"Рейс: "..timeTrip)
				end
			imgui.EndChild()
			imgui.Spacing() imgui.Spacing()
				imgui.BeginChild("##mainInfo", imgui.ImVec2(230, widgetTotalY), false)
				imgui.Spacing()
				if tripSessionBool[0] then
					imgui.Text("") imgui.SameLine() imgui.Text(u8"Рейсов за сессию: "..tostring(sessionTrailers))
				end
				if boxSessionBool[0] then
					imgui.Text("") imgui.SameLine() imgui.Text(u8"Ларцов за сессию: "..tostring(sessionBoxs))
				end
				if sessionTimeInTripBool[0] then
					imgui.Text("") imgui.SameLine() imgui.Text(u8"За сессию в рейсах: "..tostring(get_timer(sessionTimeInTrip)))
				end
				if totalTripBool[0] then
					imgui.Text("") imgui.SameLine() imgui.Text(u8"Всего рейсов: "..tostring(totalTrailers))
				end
				if totalBoxsBool[0] then
					imgui.Text("") imgui.SameLine() imgui.Text(u8"Всего ларцов: "..tostring(totalBoxs))
				end
				if totalTimeInTripBool[0] then
					imgui.Text("") imgui.SameLine() imgui.Text(u8"В рейсах всего: "..tostring(get_timer(totalTimeInTrip)))
				end
				if currentExpBool[0] then
					imgui.Text("") imgui.SameLine() imgui.Text(u8"Навык дальнобойщика: "..tostring(truckExp))
				end
				imgui.EndChild()
			imgui.PopStyleColor(2)
			imgui.End()
		end
)

function resizeWidget(bool, typeChild)
	if typeChild == 1 then
		if bool == true then
			widgetTripY = widgetTripY + 19
			widgetY = widgetY + 19
		else
			widgetTripY = widgetTripY - 19
			widgetY = widgetY - 19
		end
	end
	if typeChild == 2 then
		if bool == true then
			widgetTotalY = widgetTotalY + 19
			widgetY = widgetY + 19
		else
			widgetTotalY = widgetTotalY - 19
			widgetY = widgetY - 19
		end
	end
end

function imgui.TextQuestion(label, description)
		imgui.SameLine()
    imgui.TextDisabled(label)

    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
            imgui.PushTextWrapPos(600)
                imgui.TextUnformatted(description)
            imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function get_timer(time)
return string.format("%s:%s:%s",string.format("%s%s",((tonumber(os.date("%H",time)) < tonumber(os.date("%H",0)) and (24 + tonumber(os.date("%H",time))) - tonumber(os.date("%H",0)) or tonumber(os.date("%H",time)) - (tonumber(os.date("%H",0)))) < 10 and 0 or ""),(tonumber(os.date("%H",time)) < tonumber(os.date("%H",0)) and (24 + tonumber(os.date("%H",time))) - tonumber(os.date("%H",0)) or tonumber(os.date("%H",time)) - (tonumber(os.date("%H",0))))),os.date("%M",time),os.date("%S",time))
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

function switchCheckBox(bool, name)
	iniMain.settings.widgetBool = widgetBool[0]
	iniMain.settings.autoEatBool = autoEatBool[0]
	iniMain.settings.engineControlBool = engineControlBool[0]
	iniMain.settings.pipBool = pipBool[0]
	iniMain.settings.autoBuyBool = autoBuyBool[0]
	iniMain.settings.autoTrailerBool = autoTrailerBool[0]
	iniMain.settings.autoBreakBool = autoBreakBool[0]
	iniMain.settings.autoDomkratBool = autoDomkratBool[0]
	iniMain.settings.autoSlakbaumBool = autoSlakbaumBool[0]

	iniMain.settingsWidget.currentTruckBool = currentTruckBool[0]
	iniMain.settingsWidget.weightingBool = weightingBool[0]
	iniMain.settingsWidget.sumBool = sumBool[0]
	iniMain.settingsWidget.routeBool = routeBool[0]
	iniMain.settingsWidget.currentTripBool = currentTripBool[0]
	iniMain.settingsWidget.tripSessionBool = tripSessionBool[0]
	iniMain.settingsWidget.boxSessionBool = boxSessionBool[0]
	iniMain.settingsWidget.sessionTimeInTripBool = sessionTimeInTripBool[0]
	iniMain.settingsWidget.totalTripBool = totalTripBool[0]
	iniMain.settingsWidget.totalBoxsBool = totalBoxsBool[0]
	iniMain.settingsWidget.totalTimeInTripBool = totalTimeInTripBool[0]
	iniMain.settingsWidget.currentExpBool = currentExpBool[0]
	iniMain.settingsWidget.widgetTripY = widgetTripY
	iniMain.settingsWidget.widgetTotalY = widgetTotalY
	iniMain.settingsWidget.widgetY = widgetY
	if bool == true then
		sampAddChatMessage(tag..""..name..": {48d993}Включено", -1)
	else
		sampAddChatMessage(tag..""..name..": {f5326a}Выключено", -1)
	end
	inicfg.save(iniMain, iniDirectory)
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
						weighing = "Не пройдено"
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
					weighing = "Вне маршрута"
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
					weighing = "В процессе"
					sampSendChat("/engine")
				end
				if text:find("Взвешивание завершено..") then
					weighing = "Пройдено"
					sampSendChat("/engine")
					weighingCheck = not weighingCheck
				end
				if text:find("взять новый можно на одной из баз дальнобойщиков.") then
					weighing = "Вне маршрута"
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
					weighing = "Вне маршрута"
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


function main()
	boxPrice = iniMain.driverStats.boxPrice
	widgetBool[0] = iniMain.settings.widgetBool
	autoEatBool[0] = iniMain.settings.autoEatBool
	engineControlBool[0] = iniMain.settings.engineControlBool
	pipBool[0] = iniMain.settings.pipBool
	autoBuyBool[0] = iniMain.settings.autoBuyBool
	autoTrailerBool[0] = iniMain.settings.autoTrailerBool
	autoBreakBool[0] = iniMain.settings.autoBreakBool
	autoDomkratBool[0] = iniMain.settings.autoDomkratBool
	autoSlakbaumBool[0] = iniMain.settings.autoSlakbaumBool
	autoBuyRepairCount[0] = iniMain.settings.autoBuyRepairCount
	autoBuyFuelCount[0] = iniMain.settings.autoBuyFuelCount
	autoBuyDomkratCount[0] = iniMain.settings.autoBuyDomkratCount

	widgetPosX = iniMain.settingsWidget.widgetPosX
	widgetPosY = iniMain.settingsWidget.widgetPosY

	currentTruckBool[0] = iniMain.settingsWidget.currentTruckBool
	weightingBool[0] = iniMain.settingsWidget.weightingBool
	sumBool[0] = iniMain.settingsWidget.sumBool
	routeBool[0] = iniMain.settingsWidget.routeBool
	currentTripBool[0] = iniMain.settingsWidget.currentTripBool
	tripSessionBool[0] = iniMain.settingsWidget.tripSessionBool
	boxSessionBool[0] = iniMain.settingsWidget.boxSessionBool
	sessionTimeInTripBool[0] = iniMain.settingsWidget.totalBoxsBool
	totalTimeInTripBool[0] = iniMain.settingsWidget.totalTimeInTripBool
	totalTripBool[0] = iniMain.settingsWidget.totalTripBool
	totalBoxsBool[0] = iniMain.settingsWidget.totalBoxsBool
	currentExpBool[0] = iniMain.settingsWidget.currentExpBool
	widgetTripY = iniMain.settingsWidget.widgetTripY
	widgetTotalY = iniMain.settingsWidget.widgetTotalY
	widgetY = iniMain.settingsWidget.widgetY
	widgetTransparent[0] = iniMain.settingsWidget.widgetTransparent
	eatTypeName = iniMain.settings.eatType
	infoWindow[0] = widgetBool[0]
	sampRegisterChatCommand("driver", function()
		renderWindow[0] = not renderWindow[0]
	end)
	sampRegisterChatCommand("dset", setPos)
	settingsAway()
	addEventHandler("onWindowMessage", function(msg, wparam, lparam)
		if msg == wm.WM_KEYDOWN or msg == wm.WM_SYSKEYDOWN then
				if wparam == 27 then
						if renderWindow[0] then
								consumeWindowMessage()
								renderWindow[0] = not renderWindow[0]
						end
				end
		end
	end)
	while true do
		infoWindow[0] = widgetBool[0]
		wait(0)
	end
  wait(-1)
end

function settingsAway()
	if autoEatBool[0] == true then
		autoEatFunc()
	end
	if autoBuyBool[0] == true then
		autoBuyFunc()
	end
	if pipBool[0] == true then
		controlEngineAndSound()
	end
end

function ev.onShowTextDraw(tdi, data)
	if tdi == 2092 and data.modelId == 19627 then
		--tdi == 2094 and data.modelId == 1650 and tdi == 2104 and data.modelId == 19900
		sampSendClickTextdraw(2092)
			function ev.onShowDialog(dialogId, style, title, button1, button2, text)
				lua_thread.create(function()
					if dialogId == 3082 then
						if text:find("%{......%}Предмет: %{......%}Набор для починки%{......%}") then
								sampSendDialogResponse(dialogId, 1, -1, tostring(autoBuyRepairCount[0]))
								wait(200)
								sampCloseCurrentDialogWithButton(0)
								sampSendClickTextdraw(2094)
						end
						if text:find("%{......%}Предмет: %{......%}Канистра%{......%}") then
								sampSendDialogResponse(dialogId, 1, -1, tostring(autoBuyFuelCount[0]))
								wait(200)
								sampCloseCurrentDialogWithButton(0)
								cDomkrat = true
								sampSendClickTextdraw(2104)
						end
						if text:find("%{......%}Предмет: %{......%}Домкрат%{......%}")  then
							if cDomkrat == true then
								cDomkrat = false
								for i = 1, autoBuyDomkratCount[0] do
									wait(300)
									sampSendDialogResponse(dialogId, 1, -1, "1")
									wait(300)
									sampCloseCurrentDialogWithButton(0)
									wait(300)
									if i ~= autoBuyDomkratCount[0] then
										sampSendClickTextdraw(2104)
									end
								end
							end
						end
					end
				end)
			end
	end
end

function autoBuyFunc()
end

function controlEngineAndSound()
	local check = true
	while check do
		wait(0)
			for i = 1, 5 do
				if isCharInArea3d(PLAYER_PED, textCoords.x[i] - 150, textCoords.y[i] - 150, textCoords.z[i] - 150, textCoords.x[i] + 150, textCoords.y[i] + 150, textCoords.z[i] + 150, false) then
					local length = getAudioStreamLength(soundPip)
						sampAddChatMessage(tag..'Ты рядом с точкой взвешивания '..length, -1)
						setAudioStreamState(soundPip, eve.PLAY)
						check = false
				end
			end
	end
end

function setPos()
	print(text)
        textCoords.x = -1323
        textCoords.y = 2656
        textCoords.z = 49
end

function ev.onShowDialog(dialogId, style, title, button1, button2, text)
	if dialogId == 0 and text:find("Ваша сытость: %{......%}(%d+)/100.%{......%}") and checkBool == true then
		satiety = text:match("Ваша сытость: %{......%}(%d+)/100.%{......%}")
		return false
	end
	if dialogId == 9965 and title:find("%{......%}%{......%}Кушать") and checkBool == true then
		lua_thread.create(function()
			wait(1000)
			if eatTypeName == u8'Чипсы' then
				sampSendDialogResponse(dialogId, 1, 0, -1)
				return false
			end
			if eatTypeName == u8'Рыба' then
				sampSendDialogResponse(dialogId, 1, 1, -1)
				return false
			end
			if eatTypeName == u8'Мясо оленины' then
				sampSendDialogResponse(dialogId, 1, 2, -1)
				return false
			end
		end)
		return false
	end
end

function autoEatFunc()
	lua_thread.create(function()
		while true do
			wait(60000)
			checkBool = true
			sampSendChat("/satiety")
			wait(2000)
			if tonumber(satiety) < 70 then
				sampAddChatMessage(tag.."Уровень голода ниже 70, пополняю голод. Текущий голод: {f5326a}"..satiety, -1)
				wait(1000)
				sampSendChat("/eat")
				wait(2000)
				checkBool = false
			end
			checkBool = false
		end
	end)
end

function styleInit()
  local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4

	style.Alpha = 1.0
	style.ChildRounding = 3.0
	style.WindowRounding = 8.0
	style.GrabRounding = 4.0
	style.GrabMinSize = 20.0
	style.FrameRounding = 3.0

	colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00);
	colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00);
	colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00);
	colors[clr.ChildBg] = ImVec4(0.07, 0.07, 0.09, 1.00);
	colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00);
	--colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88);
	colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00);
	colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00);
	colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00);
	colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00);
	colors[clr.TitleBg] = ImVec4(0.10, 0.09, 0.12, 1.00);
	colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75);
	colors[clr.TitleBgActive] = ImVec4(0.07, 0.07, 0.09, 1.00);
	colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00);
	colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00);
	colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31);
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00);
	colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00);
	--colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00);
	colors[clr.CheckMark] = ImVec4(0.80, 0.80, 0.83, 0.31);
	colors[clr.SliderGrab] = ImVec4(0.80, 0.80, 0.83, 0.31);
	colors[clr.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00);
	colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00);
	colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00);
	colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00);
	colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00);
	colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00);
	colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00);
	--colors[clr.Column] = ImVec4(0.56, 0.56, 0.58, 1.00);
	--colors[clr.ColumnHovered] = ImVec4(0.24, 0.23, 0.29, 1.00);
	--colors[clr.ColumnActive] = ImVec4(0.56, 0.56, 0.58, 1.00);
	colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00);
	colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00);
	colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00);
	--colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16);
	--colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39);
	--colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00);
	colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63);
	colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00);
	colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63);
	colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00);
	colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43);
	--colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73);
end
