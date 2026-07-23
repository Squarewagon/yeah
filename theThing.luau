local player = game:GetService("Players").LocalPlayer
local Helper = require(player.PlayerGui.LogicHolder.ClientLoader.Modules.SharedHelper)
local TowerDefense = require(player.PlayerGui.LogicHolder.ClientLoader.Modules.SharedTowerDefenseHandler)

local EffectHolder = workspace:WaitForChild("EffectHolder")
print("loading")

-- setclipboard(text: string) | this will copy the text to clipboard, you could also use \n in this to create new line, you don't have to implement it, it just exists.

--Events
local Events = game:GetService("ReplicatedStorage").RemoteFunctions
local SkipWave = Events.SkipWave
local ChangeTickSpeed = Events.ChangeTickSpeed
-- holding tool
function selectedUnit()
	local player = game:GetService("Players").LocalPlayer

	if player.Character then
		-- Find if there is any Tool object parented to the Character
		local tool = player.Character:FindFirstChildWhichIsA("Tool")
		if tool then
			local itemId = tool:GetAttribute("ItemID")
			if type(itemId) == "string" then
				-- Remove the "tl_unitplacer_" prefix (14 characters long)
				return string.sub(itemId, 15)
			end
		end
	end
	return nil
end

-- place unit
-- (Moved to F keybind in recording system)
--[[
local unit = selectedUnit()
local CF = EffectHolder:FindFirstChild(unit):FindFirstChild("RangeDisplay").CFrame
local table = {
	CF = CF,
	Rotation = math.round(math.deg(math.atan2(-CF.LookVector.X, -CF.LookVector.Z))),
	Valid = true,
	Position = CF.Position,
}
local success, id = TowerDefense.PlaceUnit(unit, table)
]]

-- cash
player:GetAttribute("Cash")

-- can place units?
game.Workspace:GetAttribute("CanPlaceUnits")

-- can skip wave?
game.Workspace:GetAttribute("CanSkipWave")

-- can change tick speed?
game.Workspace:GetAttribute("CanChangeTickSpeed")

-- skip wave
-- local skipSuccess = SkipWave:InvokeServer("y")

-- change tick speed
-- local changeSuccess = ChangeTickSpeed:InvokeServer(2)

-- Recording System Toggle
local UserInputService = game:GetService("UserInputService")
local isRecording = false
local gPressTime = 0
local gHeld = false

local recordedQueries = {}
local lastQueryTime = 0

local inputBeganConn
local inputEndedConn

inputBeganConn = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then return end
	if input.KeyCode == Enum.KeyCode.G then
		gHeld = true
		gPressTime = tick()
		
		task.spawn(function()
			while gHeld do
				if tick() - gPressTime >= 2 then
					print("deleted")
					if inputBeganConn then inputBeganConn:Disconnect() end
					if inputEndedConn then inputEndedConn:Disconnect() end
					if script then
						script:Destroy()
					end
					break
				end
				task.wait(0.1)
			end
		end)
	elseif input.KeyCode == Enum.KeyCode.F then
		if isRecording then
			local unit = selectedUnit()
			if unit then
				local effectNode = EffectHolder:FindFirstChild(unit)
				if effectNode then
					local rangeDisplay = effectNode:FindFirstChild("RangeDisplay")
					if rangeDisplay then
						local CF = rangeDisplay.CFrame
						local rot = math.round(math.deg(math.atan2(-CF.LookVector.X, -CF.LookVector.Z)))
						local placementTable = {
							CF = CF,
							Rotation = rot,
							Valid = true,
							Position = CF.Position,
						}
						local success, id = TowerDefense.PlaceUnit(unit, placementTable)
						if success then
							local currentTime = tick()
							local delayTime = 0
							if #recordedQueries > 0 then
								delayTime = currentTime - lastQueryTime
							end
							lastQueryTime = currentTime
							
							table.insert(recordedQueries, {
								unit = unit,
								delay = delayTime,
								position = CF.Position,
								rotation = rot
							})
							print(string.format("Recorded %s | Delay: %.2f", unit, delayTime))
						end
					end
				end
			end
		end
	end
end)

inputEndedConn = UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.G then
		-- Only toggle if it was held for LESS than 2 seconds
		if gHeld and (tick() - gPressTime < 2) then
			isRecording = not isRecording
			if isRecording then
				print("Recording started!")
				recordedQueries = {}
			else
				print("Recording stopped!")
				local output = "local recordedPlacements = {\n"
				for _, query in ipairs(recordedQueries) do
					output = output .. string.format('\t{unit = "%s", delay = %.3f, position = Vector3.new(%.3f, %.3f, %.3f), rotation = %d},\n', query.unit, query.delay, query.position.X, query.position.Y, query.position.Z, query.rotation)
				end
				output = output .. "}"
				
				setclipboard(output)
				print("Copied recording to clipboard!")
			end
		end
		gHeld = false
	end
end)