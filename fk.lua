local sampev = require 'samp.events'
require 'lib.moonloader'
local memory = require 'memory'

local encoding = require 'encoding'
encoding.default = 'CP1251'
local function u8d(s) return encoding.UTF8:decode(s) end
local inicfg = require 'inicfg'
local dlStatus = require('moonloader').download_status
local script_vers = 2
local update_url = "https://raw.githubusercontent.com/GrishaKoliadych/ScriptsRadmir/AntiAfk/update.ini"
local update_path = getWorkingDirectory() .. "/version/FK_update.ini"
local update_state = false
local script_url = "https://raw.githubusercontent.com/GrishaKoliadych/ScriptsRadmir/AntiAfk/fk.lua"
local script_parh = thisScript().path

isFK = false
function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	downloadUrlToFile(update_url, update_path, function(id, status)
		if status == dlStatus.STATUS_ENDDOWNLOADDATA then
			updateini = inicfg.load(nil, update_path)
			if tonumber(updateini.info.vers) > script_vers then
				sampAddChatMessage("[AntiAFK] Найдено обновление, начинается процесс скачивания", -1)
				update_state = true
			end
			os.remove(update_path)
		end
	end)
	sampRegisterChatCommand("fk", start)
	thread_run = lua_thread.create_suspended(runToPos)
	writeMemory(7634870, 1, 0, 0)
    writeMemory(7635034, 1, 0, 0)
    memory.hex2bin('5051FF1500838500', 7623723, 8)
    memory.hex2bin('0F847B010000', 5499528, 6)
	while true do
		wait(0)
		if update_state then
			downloadUrlToFile(script_url, script_parh, function(id, status)
				if status == dlStatus.STATUS_ENDDOWNLOADDATA then
					sampAddChatMessage("[AntiAFK] Обновление успешно загружено", -1)
					thisScript():reload()
				end
			end)
			break
		end
	end
end

function runToPos(posX, posY, sprint)
	local x, y, z = getCharCoordinates(PLAYER_PED)
	local angle = getHeadingFromVector2d(posX - x, posY - y)
	local xAngle = math.random(-50, 50)/100
	setCameraPositionUnfixed(xAngle, math.rad(angle - 90))
	while getDistanceBetweenCoords2d(x, y, posX, posY) > 0.8 do
		setGameKeyState(1, -255)
		if sprint == true then
			setGameKeyState(16, 255)
		end
		wait(1)
		x, y, z = getCharCoordinates(PLAYER_PED)
		angle = getHeadingFromVector2d(posX - x, posY - y)
		setCameraPositionUnfixed(xAngle, math.rad(angle - 90))
		if not isFK then break end
	end
	wait(120000)
	if isFK and typeFK == "1" then
		local x, y, z = getCharCoordinates(PLAYER_PED)
		local XRand = math.random(x-50, x+50);
		local YRand = math.random(y-50, y+50);
		thread_run:run(XRand, YRand, false);
	end
end

function start(typeFK)
	if typeFK == "0" then
		if isFK == false then
			writeMemory(7634870, 1, 1, 1)
			writeMemory(7635034, 1, 1, 1)
			memory.fill(7623723, 144, 8)
			memory.fill(5499528, 144, 6)
			addOneOffSound(0.0, 0.0, 0.0, 1136)
			printString('~g~ FK ON', 2000)
			isFK = true
		else
			writeMemory(7634870, 1, 0, 0)
			writeMemory(7635034, 1, 0, 0)
			memory.hex2bin('5051FF1500838500', 7623723, 8)
			memory.hex2bin('0F847B010000', 5499528, 6)
			addOneOffSound(0.0, 0.0, 0.0, 1136)
			printString('~r~ FK OFF', 2000)
			isFK = false
		end
	end
	if typeFK == "1" then
		if isFK == false then
			writeMemory(7634870, 1, 1, 1)
			writeMemory(7635034, 1, 1, 1)
			memory.fill(7623723, 144, 8)
			memory.fill(5499528, 144, 6)
			addOneOffSound(0.0, 0.0, 0.0, 1136)
			printString('~g~ FK ON', 2000)
			local x, y, z = getCharCoordinates(PLAYER_PED)
			local XRand = math.random(x-50, x+50);
			local YRand = math.random(y-50, y+50);
			thread_run:run(XRand, YRand, false);
			isFK = true
		else
			writeMemory(7634870, 1, 0, 0)
			writeMemory(7635034, 1, 0, 0)
			memory.hex2bin('5051FF1500838500', 7623723, 8)
			memory.hex2bin('0F847B010000', 5499528, 6)
			addOneOffSound(0.0, 0.0, 0.0, 1136)
			printString('~r~ FK OFF', 2000)
			isFK = false
		end
	end
	if typeFK ~= "0" and typeFK ~= "1" then
		sampAddChatMessage("Используйте /fk [0-1]", -1)
	end
end
