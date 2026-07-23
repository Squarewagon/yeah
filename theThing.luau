local player = game:GetService("Players").LocalPlayer
local Helper = require(player.PlayerGui.LogicHolder.ClientLoader.Modules.SharedHelper)
local TowerDefense = require(player.PlayerGui.LogicHolder.ClientLoader.Modules.SharedTowerDefenseHandler)
local Entities = workspace.Map.Entities -- .UnitId
local Config = player.PlayerGui.LogicHolder.ClientLoader.SharedConfig.ItemData.Units.Configs -- .UnitId | require this with .UnitId, they're ModuleScript

local SkipWaveButton = player.PlayerGui.GameGuiNoInset.Screen.Top.SkipWave.Button -- image button
local AutoSkipButton = player.PlayerGui.GameGuiNoInset.Screen.Top.WaveControls.AutoSkip -- image button
local Speed1 = player.PlayerGui.GameGuiNoInset.Screen.Top.WaveControls.TickSpeed.Items["1"] -- image button
local Speed2 = player.PlayerGui.GameGuiNoInset.Screen.Top.WaveControls.TickSpeed.Items["2"] -- image button

local EffectHolder = workspace:WaitForChild("EffectHolder")
print("loading")

-- setclipboard(text: string) | this will copy the text to clipboard, you could also use \n in this to create new line, you don't have to implement it, it just exists.

local recordedPlacements = {} -- Paste your recording here!

--Events
local Events = game:GetService("ReplicatedStorage").RemoteFunctions
local SkipWaveEvent = Events.SkipWave
local ChangeTickSpeedEvent = Events.ChangeTickSpeed
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

-- upgrade unit
local success, level = TowerDefense.UpgradeUnit(id)
--]]

-- cash
player:GetAttribute("Cash")

-- can place units?
game.Workspace:GetAttribute("CanPlaceUnits")

-- can skip wave?
game.Workspace:GetAttribute("CanSkipWave")

-- can change tick speed?
game.Workspace:GetAttribute("CanChangeTickSpeed")

-- skip wave
-- local skipSuccess = SkipWaveEvent:InvokeServer("y")

-- change tick speed
-- local changeSuccess = ChangeTickSpeedEvent:InvokeServer(2)

-- UI Setup
local CoreGui = game:GetService("CoreGui")
local guiParent = pcall(function() return CoreGui.Name end) and CoreGui or player:WaitForChild("PlayerGui")
local macroGui = Instance.new("ScreenGui")
macroGui.Name = "MacroStatusUI"
macroGui.ResetOnSpawn = false
macroGui.Parent = guiParent

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 200, 0, 50)
statusLabel.Position = UDim2.new(1, -220, 0.5, -115)
statusLabel.AnchorPoint = Vector2.new(0, 0)
statusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
statusLabel.BackgroundTransparency = 0.5
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Text = "Status: Idle"
statusLabel.Parent = macroGui

local managerFrame = Instance.new("ScrollingFrame")
managerFrame.Size = UDim2.new(0, 200, 0, 175)
managerFrame.Position = UDim2.new(1, -220, 0.5, -60)
managerFrame.AnchorPoint = Vector2.new(0, 0)
managerFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
managerFrame.BackgroundTransparency = 0.3
managerFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
managerFrame.Visible = false
managerFrame.Parent = macroGui

local managerList = Instance.new("UIListLayout")
managerList.SortOrder = Enum.SortOrder.LayoutOrder
managerList.Padding = UDim.new(0, 5)
managerList.Parent = managerFrame

-- Recording System Toggle
local UserInputService = game:GetService("UserInputService")
local isRecording = false
local gPressTime = 0
local gHeld = false

local recordedQueries = {}
local lastQueryTime = 0
local function addRecord(actionType, data)
	if not isRecording then return end
	local currentTime = tick()
	local delayTime = 0
	if #recordedQueries > 0 then
		delayTime = currentTime - lastQueryTime
	end
	lastQueryTime = currentTime
	
	local query = { type = actionType, delay = delayTime }
	if data then
		for k, v in pairs(data) do
			query[k] = v
		end
	end
	table.insert(recordedQueries, query)
	
	statusLabel.Text = "Recorded: " .. actionType
	print(string.format("Recorded %s | Delay: %.2f", actionType, delayTime))
end

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
					if macroGui then macroGui:Destroy() end
					if script then
						script:Destroy()
					end
					break
				end
				task.wait(0.1)
			end
		end)
	elseif input.KeyCode == Enum.KeyCode.V then
		if not isRecording and #recordedPlacements > 0 then
			statusLabel.Text = "Status: Playing Macro"
			print("Starting macro playback...")
			task.spawn(function()
				-- Force fast forward
				pcall(function() ChangeTickSpeed:InvokeServer(2) end)
				
				local isPlaying = true
				-- Thread to constantly AutoSkip
				task.spawn(function()
					while isPlaying do
						if game.Workspace:GetAttribute("CanSkipWave") then
							pcall(function() SkipWave:InvokeServer("y") end)
						end
						task.wait(0.5)
					end
				end)
				
				local idMap = {}
				for _, action in ipairs(recordedPlacements) do
					if action.type == "PlaceUnit" then
						local cfg = Config:FindFirstChild(action.unit)
						local baseCost = 0
						if cfg then
							local s, c = pcall(require, cfg)
							if s and c and c.UnitConfig then
								baseCost = c.UnitConfig.Cost or 0
							end
						end
						
						-- Wait for conditions
						while true do
							if game.Workspace:GetAttribute("CanPlaceUnits") and player:GetAttribute("Cash") >= baseCost then
								break
							end
							task.wait(0.1)
						end
						
						local placementTable = {
							CF = CFrame.new(action.position) * CFrame.Angles(0, math.rad(action.rotation), 0),
							Rotation = action.rotation,
							Valid = true,
							Position = action.position,
						}
						
						local s, newId = TowerDefense.PlaceUnit(action.unit, placementTable)
						if s and newId then
							idMap[action.id] = newId
							print("Playback: Placed " .. action.unit)
						else
							warn("Playback: Failed to place " .. action.unit)
						end
						
					elseif action.type == "UpgradeUnit" then
						local cfg = Config:FindFirstChild(action.unit)
						local upgCost = 0
						if cfg then
							local s, c = pcall(require, cfg)
							if s and c and c.UnitConfig and c.UnitConfig.Upgrades and c.UnitConfig.Upgrades[action.level] then
								upgCost = c.UnitConfig.Upgrades[action.level].Cost or 0
							end
						end
						
						-- Wait for cash
						while true do
							if player:GetAttribute("Cash") >= upgCost then
								break
							end
							task.wait(0.1)
						end
						
						local targetId = idMap[action.id]
						if targetId then
							local s = TowerDefense.UpgradeUnit(targetId)
							if s then
								print("Playback: Upgraded " .. action.unit .. " to lvl " .. tostring(action.level))
							else
								warn("Playback: Failed to upgrade " .. action.unit)
							end
						else
							warn("Playback: Could not find mapped ID for upgrade " .. tostring(action.id))
						end
					end
				end
				
				isPlaying = false
				statusLabel.Text = "Status: Playback Finished"
				print("Macro playback finished!")
			end)
		end
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
							addRecord("PlaceUnit", {
								unit = unit,
								id = id,
								position = CF.Position,
								rotation = rot
							})
							
							local card = Instance.new("Frame")
							card.Size = UDim2.new(1, 0, 0, 40)
							card.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
							card.Parent = managerFrame
							
							local nameLbl = Instance.new("TextLabel")
							nameLbl.Size = UDim2.new(0.6, 0, 1, 0)
							nameLbl.BackgroundTransparency = 1
							nameLbl.Text = tostring(unit)
							nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
							nameLbl.TextScaled = true
							nameLbl.Parent = card
							
							local upgBtn = Instance.new("TextButton")
							upgBtn.Size = UDim2.new(0.4, -5, 1, -10)
							upgBtn.Position = UDim2.new(0.6, 0, 0, 5)
							upgBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 100)
							upgBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
							upgBtn.TextScaled = true
							upgBtn.Parent = card
							
							local unitLevel = 1
							local function updateUpgText()
								local uConfig = Config:FindFirstChild(unit)
								if uConfig then
									local sCfg, cfgData = pcall(require, uConfig)
									if sCfg and cfgData and cfgData.UnitConfig and cfgData.UnitConfig.Upgrades and cfgData.UnitConfig.Upgrades[unitLevel] then
										upgBtn.Text = tostring(cfgData.UnitConfig.Upgrades[unitLevel].Cost)
									else
										upgBtn.Text = "Max"
									end
								else
									upgBtn.Text = "Max"
								end
							end
							updateUpgText()
							
							local highlight
							card.MouseEnter:Connect(function()
								for _, model in ipairs(Entities:GetChildren()) do
									if model:GetAttribute("ID") == id then
										highlight = Instance.new("Highlight")
										highlight.FillColor = Color3.new(1, 1, 0)
										highlight.Parent = model
										break
									end
								end
							end)
							card.MouseLeave:Connect(function()
								if highlight then
									highlight:Destroy()
									highlight = nil
								end
							end)
							
							upgBtn.Activated:Connect(function()
								local s, level = TowerDefense.UpgradeUnit(id)
								if s then
									unitLevel = level
									updateUpgText()
									addRecord("UpgradeUnit", { id = id, level = level, unit = unit })
								end
							end)
							
							managerFrame.CanvasSize = UDim2.new(0, 0, 0, managerList.AbsoluteContentSize.Y)
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
				statusLabel.Text = "Status: Recording"
				print("Recording started!")
				recordedQueries = {}
				managerFrame.Visible = true
				for _, child in ipairs(managerFrame:GetChildren()) do
					if child:IsA("Frame") then child:Destroy() end
				end
			else
				statusLabel.Text = "Status: Idle (Copied)"
				print("Recording stopped!")
				managerFrame.Visible = false
				local output = "local recordedPlacements = {\n"
				for _, query in ipairs(recordedQueries) do
					if query.type == "PlaceUnit" then
						output = output .. string.format('\t{type = "PlaceUnit", unit = "%s", id = %d, delay = %.3f, position = Vector3.new(%.3f, %.3f, %.3f), rotation = %d},\n', query.unit, query.id, query.delay, query.position.X, query.position.Y, query.position.Z, query.rotation)
					elseif query.type == "UpgradeUnit" then
						output = output .. string.format('\t{type = "UpgradeUnit", unit = "%s", id = %d, level = %d, delay = %.3f},\n', query.unit, query.id, query.level, query.delay)
					end
				end
				output = output .. "}"
				
				setclipboard(output)
				print("Copied recording to clipboard!")
			end
		end
		gHeld = false
	end
end)