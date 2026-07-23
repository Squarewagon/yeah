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

local configsUrl = "https://raw.githubusercontent.com/Squarewagon/yeah/refs/heads/main/placements.luau"
local macroConfigs = {}
pcall(function()
	local raw = game:HttpGet(configsUrl)
	if raw then
		local func = loadstring(raw)
		if func then
			macroConfigs = func()
		end
	end
end)

local recordedPlacements = {}

--Events
local FunctionEvents = game:GetService("ReplicatedStorage").RemoteFunctions
local RemoteEvents = game:GetService("ReplicatedStorage").RemoteEvents
local ShowGameEnd = RemoteEvents.ShowGameEnd
local SkipWave = FunctionEvents.SkipWave
local ChangeTickSpeed = FunctionEvents.ChangeTickSpeed
local RestartGame = FunctionEvents.RestartGame
local PlaceDifficultyVote = FunctionEvents.PlaceDifficultyVote

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

-- can skip wave?
game.Workspace:GetAttribute("CanSkipWave")
-- skip wave
-- local skipSuccess = SkipWaveEvent:InvokeServer("y")

-- change tick speed
-- local changeSuccess = ChangeTickSpeedEvent:InvokeServer(2)

-- vote difficulty
-- PlaceDifficultyVote:InvokeServer("dif_easy") -- or dif_normal or dif_hard

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

local dropdownBtn = Instance.new("TextButton")
dropdownBtn.Size = UDim2.new(0, 200, 0, 40)
dropdownBtn.Position = UDim2.new(1, -220, 0.5, -160)
dropdownBtn.AnchorPoint = Vector2.new(0, 0)
dropdownBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
dropdownBtn.BackgroundTransparency = 0.3
dropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dropdownBtn.TextScaled = true
dropdownBtn.Font = Enum.Font.GothamBold
dropdownBtn.Text = "Select Macro..."
dropdownBtn.Parent = macroGui

local dropdownList = Instance.new("ScrollingFrame")
dropdownList.Size = UDim2.new(0, 200, 0, 160)
dropdownList.Position = UDim2.new(1, -430, 0.5, -160)
dropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
dropdownList.BackgroundTransparency = 0.1
dropdownList.Visible = false
dropdownList.ZIndex = 5
dropdownList.Parent = macroGui

local dropdownLayout = Instance.new("UIListLayout")
dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
dropdownLayout.Parent = dropdownList

dropdownLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	dropdownList.CanvasSize = UDim2.new(0, 0, 0, dropdownLayout.AbsoluteContentSize.Y)
end)

for name, data in pairs(macroConfigs) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 40)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextScaled = true
	btn.Font = Enum.Font.Gotham
	btn.Text = tostring(name)
	btn.ZIndex = 6
	btn.Parent = dropdownList
	
	btn.Activated:Connect(function()
		recordedPlacements = data
		dropdownBtn.Text = tostring(name)
		dropdownList.Visible = false
	end)
end

dropdownBtn.Activated:Connect(function()
	dropdownList.Visible = not dropdownList.Visible
end)

-- Recording System Toggle
local UserInputService = game:GetService("UserInputService")
local isRecording = false
local gPressTime = 0
local gHeld = false

local recordedQueries = {}
local autoUpgradePool = {}
local autoUpgradeLoopRunning = false

local isPlayingMacro = false

local function addRecord(actionType, data)
	if not isRecording then return end
	
	local query = { type = actionType }
	if data then
		for k, v in pairs(data) do
			query[k] = v
		end
	end
	table.insert(recordedQueries, query)
	
	statusLabel.Text = "Recorded: " .. actionType
	print(string.format("Recorded %s", actionType))
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
		if isRecording then return end
		
		if isPlayingMacro then
			isPlayingMacro = false
			statusLabel.Text = "Status: Playback Stopped"
			print("Macro playback stopped!")
			return
		end
		
		if #recordedPlacements > 0 then
			isPlayingMacro = true
			statusLabel.Text = "Status: Playing Macro"
			print("Starting macro playback...")
			task.spawn(function()
				while isPlayingMacro do
					print("Starting new macro run...")
					-- Force fast forward
					pcall(function() ChangeTickSpeed:InvokeServer(2) end)
					
					local runActive = true
					local gameEnded = false
					
					local endConn = ShowGameEnd.OnClientEvent:Connect(function()
						gameEnded = true
					end)
					
					-- Thread to constantly AutoSkip
					task.spawn(function()
						while runActive and isPlayingMacro and not gameEnded do
							if game.Workspace:GetAttribute("CanSkipWave") then
								pcall(function() SkipWave:InvokeServer("y") end)
							end
							task.wait(0.5)
						end
					end)
					
					local idMap = {}
					for _, action in ipairs(recordedPlacements) do
						if not isPlayingMacro or gameEnded then break end
						
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
							while isPlayingMacro and not gameEnded do
								if player:GetAttribute("Cash") >= baseCost then
									break
								end
								task.wait(0.1)
							end
							if not isPlayingMacro or gameEnded then break end
							
							local s, newId
							local attempt = 0
							while not s and isPlayingMacro and not gameEnded do
								local offset = Vector3.new(
									(math.random() * 2 - 1) * 1,
									0,
									(math.random() * 2 - 1) * 1
								)
								
								local testPos = action.position + offset
								local placementTable = {
									CF = CFrame.new(testPos) * CFrame.Angles(0, math.rad(action.rotation), 0),
									Rotation = action.rotation,
									Valid = true,
									Position = testPos,
								}
								
								s, newId = TowerDefense.PlaceUnit(action.unit, placementTable)
								if s and newId then
									idMap[action.id] = newId
									if attempt == 0 then
										print("Playback: Placed " .. action.unit)
									else
										print("Playback: Placed " .. action.unit .. " after " .. attempt .. " retries")
									end
									task.wait(0.2) -- Allow server cash replication to catch up
								else
									attempt = attempt + 1
									task.wait(0.3)
								end
							end
							
						elseif action.type == "UpgradeUnit" then
							local cfg = Config:FindFirstChild(action.unit)
							local upgCost = 0
							if cfg then
								local s, c = pcall(require, cfg)
								if s and c and c.UnitConfig and c.UnitConfig.Upgrades and c.UnitConfig.Upgrades[action.level - 1] then
									upgCost = c.UnitConfig.Upgrades[action.level - 1].Cost or 0
								end
							end
							
							-- Wait for cash
							while isPlayingMacro and not gameEnded do
								if player:GetAttribute("Cash") >= upgCost then
									break
								end
								task.wait(0.1)
							end
							if not isPlayingMacro or gameEnded then break end
							
							local targetId = idMap[action.id]
							if targetId then
								local s = false
								while not s and isPlayingMacro and not gameEnded do
									s = TowerDefense.UpgradeUnit(targetId)
									if s then
										print("Playback: Upgraded " .. action.unit .. " to lvl " .. tostring(action.level))
										task.wait(0.2) -- Allow server cash replication to catch up
									else
										task.wait(0.3)
									end
								end
							else
								warn("Playback: Could not find mapped ID for upgrade " .. tostring(action.id))
							end
						end
					end
					
					-- Wait for the game to actually end
					while isPlayingMacro and not gameEnded do
						task.wait(0.5)
					end
					
					runActive = false
					if endConn then endConn:Disconnect() end
					
					if isPlayingMacro then
						print("Game Ended! Voting difficulty to restart...")
						local dif = recordedPlacements.dif or "dif_easy"
						pcall(function() RestartGame:InvokeServer() end)
						task.wait(1)
						pcall(function() PlaceDifficultyVote:InvokeServer(dif) end)
						task.wait(15) -- Give the server time to process restart before hitting the loop again
					end
				end
			end)
		end
	elseif input.KeyCode == Enum.KeyCode.F then
		if isRecording then
			local unit = selectedUnit()
			if unit then
				local effectNode = EffectHolder:FindFirstChild(unit)
				if effectNode then
					local CF = effectNode:GetPivot()
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
							
							local dispName = tostring(unit)
							local uConfig = Config:FindFirstChild(unit)
							if uConfig then
								local s, c = pcall(require, uConfig)
								if s and c and c.Name then
									dispName = c.Name
								end
							end
							
							local nameLbl = Instance.new("TextLabel")
							nameLbl.Size = UDim2.new(0.5, 0, 1, 0)
							nameLbl.BackgroundTransparency = 1
							nameLbl.Text = dispName
							nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
							nameLbl.TextScaled = true
							nameLbl.Parent = card
							
							local autoBtn = Instance.new("TextButton")
							autoBtn.Size = UDim2.new(0.2, 0, 1, -10)
							autoBtn.Position = UDim2.new(0.5, 0, 0, 5)
							autoBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
							autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
							autoBtn.Text = "Auto"
							autoBtn.TextScaled = true
							autoBtn.Parent = card
							
							local upgBtn = Instance.new("TextButton")
							upgBtn.Size = UDim2.new(0.3, -5, 1, -10)
							upgBtn.Position = UDim2.new(0.7, 0, 0, 5)
							upgBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 100)
							upgBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
							upgBtn.TextScaled = true
							upgBtn.Parent = card
							
							local poolData = {
								id = id,
								unitName = unit,
								unitLevel = 1,
								active = false
							}
							table.insert(autoUpgradePool, poolData)
							
							autoBtn.Activated:Connect(function()
								poolData.active = not poolData.active
								if poolData.active then
									autoBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
								else
									autoBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
								end
							end)
							
							local function updateUpgText()
								if uConfig then
									local sCfg, cfgData = pcall(require, uConfig)
									if sCfg and cfgData and cfgData.UnitConfig and cfgData.UnitConfig.Upgrades and cfgData.UnitConfig.Upgrades[poolData.unitLevel] then
										upgBtn.Text = tostring(cfgData.UnitConfig.Upgrades[poolData.unitLevel].Cost)
									else
										upgBtn.Text = "Max"
									end
								else
									upgBtn.Text = "Max"
								end
							end
							poolData.updateUpgText = updateUpgText
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
									poolData.unitLevel = level
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
				
				autoUpgradePool = {}
				autoUpgradeLoopRunning = true
				task.spawn(function()
					while autoUpgradeLoopRunning and isRecording do
						local bestUnit = nil
						local lowestCost = math.huge
						
						for _, u in ipairs(autoUpgradePool) do
							if u.active then
								local cfg = Config:FindFirstChild(u.unitName)
								if cfg then
									local s, c = pcall(require, cfg)
									if s and c and c.UnitConfig and c.UnitConfig.Upgrades and c.UnitConfig.Upgrades[u.unitLevel] then
										local cost = c.UnitConfig.Upgrades[u.unitLevel].Cost
										if cost and cost < lowestCost then
											lowestCost = cost
											bestUnit = u
										end
									end
								end
							end
						end
						
						if bestUnit and player:GetAttribute("Cash") >= lowestCost then
							local s, level = TowerDefense.UpgradeUnit(bestUnit.id)
							if s then
								bestUnit.unitLevel = level
								bestUnit.updateUpgText()
								addRecord("UpgradeUnit", { id = bestUnit.id, level = level, unit = bestUnit.unitName })
								task.wait(0.2)
							end
						end
						
						task.wait(0.5)
					end
				end)
			else
				autoUpgradeLoopRunning = false
				statusLabel.Text = "Status: Idle (Copied)"
				print("Recording stopped!")
				managerFrame.Visible = false
				local output = "{\n"
				output = output .. '\tdif = "FILL",\n'
				for _, query in ipairs(recordedQueries) do
					if query.type == "PlaceUnit" then
						output = output .. string.format('\t{type = "PlaceUnit", unit = "%s", id = %d, position = Vector3.new(%.3f, %.3f, %.3f), rotation = %d},\n', query.unit, query.id, query.position.X, query.position.Y, query.position.Z, query.rotation)
					elseif query.type == "UpgradeUnit" then
						output = output .. string.format('\t{type = "UpgradeUnit", unit = "%s", id = %d, level = %d},\n', query.unit, query.id, query.level)
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