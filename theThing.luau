local player = game:GetService("Players").LocalPlayer
local Helper = require(player.PlayerGui.LogicHolder.ClientLoader.Modules.SharedHelper)
local TowerDefense = require(player.PlayerGui.LogicHolder.ClientLoader.Modules.SharedTowerDefenseHandler)
local Entities = workspace.Map.Entities -- .UnitId
local Config = player.PlayerGui.LogicHolder.ClientLoader.SharedConfig.ItemData.Units.Configs -- .UnitId | require this with .UnitId, they're ModuleScript

workspace:GetAttribute("Difficulty")
workspace:GetAttribute("MapId")

local EffectHolder = workspace:WaitForChild("EffectHolder")
print("loading")
workspace:GetAttribute("Round") -- current wave
-- local success, message = ActivateUnitAbility:InvokeServer(id)

--Events
local FunctionEvents = game:GetService("ReplicatedStorage").RemoteFunctions
local RemoteEvents = game:GetService("ReplicatedStorage").RemoteEvents
local ShowGameEnd = RemoteEvents.ShowGameEnd
local ChangeTargetingMode = RemoteEvents:FindFirstChild("Entity_ChangeTargetingMode")
local SkipWave = FunctionEvents.SkipWave
local ChangeTickSpeed = FunctionEvents.ChangeTickSpeed
local RestartGame = FunctionEvents.RestartGame
local PlaceDifficultyVote = FunctionEvents.PlaceDifficultyVote
local ActivateUnitAbility = FunctionEvents.ActivateUnitAbility

if not ChangeTargetingMode then
	ChangeTargetingMode = Instance.new("RemoteEvent")
	ChangeTargetingMode.Name = "Entity_ChangeTargetingMode"
	ChangeTargetingMode.Parent = RemoteEvents
end

-- Anti-Lag: Block spammy server remotes
local spammyRemotes = {
	"ReplicatedStorage.CustomRoutes.FlyingTargeting",
	"ReplicatedStorage.RemoteEvents.Entity_LockOnTarget",
	"ReplicatedStorage.RemoteEvents.Entity_AttackTarget",
	"ReplicatedStorage.RemoteEvents.Entity_UpdateRandomPos",
	"ReplicatedStorage.RemoteEvents.Entity_ServerPosUpdated",
	"ReplicatedStorage.RemoteEvents.CashFloat",
	"ReplicatedStorage.RemoteEvents.Entity_StatMetricUpdated",
	"ReplicatedStorage.RemoteEvents.EnemyHPBatch",
	"ReplicatedStorage.CustomRoutes.BeeSpawned",
	"ReplicatedStorage.CustomRoutes.BeeTargetUpdated",
	"ReplicatedStorage.CustomRoutes.BeeLifeOver",
}

local cakeId = nil
local triggeredBosses = {}
local activeBossIds = {}
local sessionCounter = 0

local randomTargetingUnits = {
	["unit_minions"] = true,
	["unit_poison_vine"] = true,
	["unit_gold_lucky_chomp"] = true,
}

local ceFunc = function(name, data)
	local id = data and data.ID
	if not id then return end
	
	if name == "unit_birthday_cake" then
		cakeId = id
	end
	
	if name == "unit_gold_clover" then
		local mySession = sessionCounter
		task.spawn(function()
			while sessionCounter == mySession do
				task.wait(60)
				if sessionCounter ~= mySession then break end
				local activated = false
				while not activated and sessionCounter == mySession do
					local pcallSuccess, invokeSuccess = pcall(function()
						return ActivateUnitAbility:InvokeServer(id)
					end)
					if pcallSuccess and invokeSuccess then
						activated = true
					else
						task.wait(1)
					end
				end
			end
		end)
	end

	if name == "enemy_boss_magma_cube" or name == "enemy_volcanic_snail" or name == "enemy_boss_fire_drill" then
		if not triggeredBosses[name] then
			triggeredBosses[name] = true
			activeBossIds[id] = name
		end
	end

	if randomTargetingUnits[name] then
		task.spawn(function()
			task.wait(0.2)
			pcall(function()
				ChangeTargetingMode:FireServer(id, 7)
			end)
		end)
	end
end

local function toggleGameConnections(remote, customFunc, state)
	if not remote or not getconnections then return end
	task.spawn(function()
		if state == "Disable" then
			local conns = getconnections(remote.OnClientEvent)
			while true do
				local hasOther = false
				for _, conn in ipairs(conns) do
					if conn.Function ~= customFunc then
						hasOther = true
						break
					end
				end
				if hasOther or not isPlayingMacro then
					break
				end
				task.wait(0.5)
				conns = getconnections(remote.OnClientEvent)
			end
			
			for _, conn in ipairs(getconnections(remote.OnClientEvent)) do
				if conn.Function ~= customFunc then
					pcall(function() conn:Disable() end)
				end
			end
		elseif state == "Enable" then
			for _, conn in ipairs(getconnections(remote.OnClientEvent)) do
				if conn.Function ~= customFunc then
					pcall(function() conn:Enable() end)
				end
			end
		end
	end)
end

local function getTarget(pathString)
	local parts = string.split(pathString, ".")
	local current = game
	for _, part in ipairs(parts) do
		if current == game and part == "ReplicatedStorage" then
			current = game:GetService("ReplicatedStorage")
		else
			local success, nextInst = pcall(function() return current:WaitForChild(part, 1) end)
			if success and nextInst then
				current = nextInst
			else
				return nil
			end
		end
	end
	return current
end

task.spawn(function()
	local ce = getTarget("ReplicatedStorage.RemoteEvents.CreateEntity")
	local hp = getTarget("ReplicatedStorage.RemoteEvents.Entity_HPChanged")
	
	if ce then
		ce.OnClientEvent:Connect(ceFunc)
	end
	
	if hp then
		hp.OnClientEvent:Connect(function(id, currentHealth, maxHealth)
			if isPlayingMacro and activeBossIds[id] then
				if currentHealth < maxHealth then
					local bossName = activeBossIds[id]
					activeBossIds[id] = nil
					
					if cakeId then
						task.spawn(function()
							if bossName == "enemy_boss_magma_cube" then
								task.wait(1)
							end
							pcall(function() ActivateUnitAbility:InvokeServer(cakeId) end)
						end)
					end
				end
			end
		end)
	end
end)

ShowGameEnd.OnClientEvent:Connect(function()
	table.clear(triggeredBosses)
	table.clear(activeBossIds)
	sessionCounter = sessionCounter + 1
end)

-- Global trackers for minions are defined above

local HttpService = game:GetService("HttpService")
local SAVE_FILE = "TomatoMacros.json"
local macroConfigs = {}

local function loadMacros()
	if isfile and isfile(SAVE_FILE) then
		local s, data = pcall(function()
			return HttpService:JSONDecode(readfile(SAVE_FILE))
		end)
		if s and type(data) == "table" then
			macroConfigs = data
		end
	end
end
loadMacros()

local function saveMacros()
	if writefile then
		pcall(function()
			writefile(SAVE_FILE, HttpService:JSONEncode(macroConfigs))
		end)
	end
end

local recordedPlacements = {}

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

-- UI Setup
local CoreGui = game:GetService("CoreGui")
local guiParent = pcall(function()
	return CoreGui.Name
end) and CoreGui or player:WaitForChild("PlayerGui")
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

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(0, 200, 0, 25)
timerLabel.Position = UDim2.new(1, -220, 0.5, -65)
timerLabel.AnchorPoint = Vector2.new(0, 0)
timerLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
timerLabel.BackgroundTransparency = 0.5
timerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
timerLabel.TextScaled = true
timerLabel.Font = Enum.Font.Gotham
timerLabel.Text = "Time: 00:00:00"
timerLabel.Parent = macroGui

local managerFrame = Instance.new("ScrollingFrame")
managerFrame.Size = UDim2.new(0, 200, 0, 150)
managerFrame.Position = UDim2.new(1, -220, 0.5, -40)
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
local rPressTime = 0
local rHeld = false

local recordedQueries = {}
local autoUpgradePool = {}
local autoUpgradeLoopRunning = false

local isPlayingMacro = false

local has3xSpeed = false
task.spawn(function()
	pcall(function()
		has3xSpeed = game:GetService("MarketplaceService"):UserOwnsGamePassAsync(player.UserId, 1252939423)
	end)
end)

local function addRecord(actionType, data)
	if not isRecording then
		return
	end

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

local function getTrueUnitConfig(unitName)
	local cfg = Config:FindFirstChild(unitName)
	if not cfg then
		return nil
	end
	local s, c = pcall(require, cfg)
	if s and c then
		if c.BaseUnit then
			local baseCfg = Config:FindFirstChild(c.BaseUnit)
			if baseCfg then
				local s2, c2 = pcall(require, baseCfg)
				if s2 and c2 then
					return c2.UnitConfig
				end
			end
		end
		return c.UnitConfig
	end
	return nil
end

local inputBeganConn
local inputEndedConn

inputBeganConn = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then
		return
	end
	if input.KeyCode == Enum.KeyCode.R then
		rHeld = true
		rPressTime = tick()

		task.spawn(function()
			while rHeld do
				if tick() - rPressTime >= 2 then
					print("deleted")
					if inputBeganConn then
						inputBeganConn:Disconnect()
					end
					if inputEndedConn then
						inputEndedConn:Disconnect()
					end
					if macroGui then
						macroGui:Destroy()
					end
					if script then
						script:Destroy()
					end
					break
				end
				task.wait(0.1)
			end
		end)
	elseif input.KeyCode == Enum.KeyCode.V then
		if isRecording then
			return
		end

		if isPlayingMacro then
			isPlayingMacro = false
			local ce = getTarget("ReplicatedStorage.RemoteEvents.CreateEntity")
			if ce then toggleGameConnections(ce, ceFunc, "Enable") end
			for _, path in ipairs(spammyRemotes) do
				local remote = getTarget(path)
				if remote then toggleGameConnections(remote, nil, "Enable") end
			end
			statusLabel.Text = "Status: Playback Stopped"
			print("Macro playback stopped!")
			return
		end

		local mapId = workspace:GetAttribute("MapId") or "unknown_map"
		local dif = workspace:GetAttribute("Difficulty") or "dif_normal"
		local key = mapId .. "_" .. dif

		local activeMacro = macroConfigs[key]
		if activeMacro and activeMacro.actions and #activeMacro.actions > 0 then
			isPlayingMacro = true
			local ce = getTarget("ReplicatedStorage.RemoteEvents.CreateEntity")
			if ce then toggleGameConnections(ce, ceFunc, "Disable") end
			for _, path in ipairs(spammyRemotes) do
				local remote = getTarget(path)
				if remote then toggleGameConnections(remote, nil, "Disable") end
			end
			statusLabel.Text = "Status: Playing " .. key
			print("Starting macro playback for " .. key .. "...")

			local sessionStartTime = tick()
			local winCount = 0
			local failCount = 0
			local totalWinTime = 0
			
			task.spawn(function()
				while isPlayingMacro do
					local elapsed = tick() - sessionStartTime
					local hours = math.floor(elapsed / 3600)
					local mins = math.floor((elapsed % 3600) / 60)
					local secs = math.floor(elapsed % 60)
					local avgTime = (winCount > 0) and math.floor(totalWinTime / winCount) or 0
					timerLabel.Text = string.format("Time: %02d:%02d:%02d | V: %d | F: %d | Avg: %ds", hours, mins, secs, winCount, failCount, avgTime)
					task.wait(1)
				end
				timerLabel.Text = "Time: 00:00:00"
			end)

			task.spawn(function()
				while isPlayingMacro do
					print("Starting new macro run...")
					-- Force fast forward
					pcall(function()
						ChangeTickSpeed:InvokeServer(has3xSpeed and 3 or 2)
					end)

					local runActive = true
					local gameEnded = false

					local endConn
					endConn = ShowGameEnd.OnClientEvent:Connect(function(data)
						if gameEnded then return end
						gameEnded = true
						if type(data) == "table" then
							if data.Victory then
								winCount = winCount + 1
								if data.RunTime then
									totalWinTime = totalWinTime + data.RunTime
								end
							else
								failCount = failCount + 1
							end
						else
							failCount = failCount + 1
						end
					end)

					-- Thread to constantly AutoSkip
					task.spawn(function()
						while runActive and isPlayingMacro and not gameEnded do
							if game.Workspace:GetAttribute("CanSkipWave") then
								pcall(function()
									SkipWave:InvokeServer("y")
								end)
							end
							task.wait(0.5)
						end
					end)

					local idMap = {}
					for _, action in ipairs(activeMacro.actions) do
						if not isPlayingMacro or gameEnded then
							break
						end

						if action.type == "PlaceUnit" then
							local trueConfig = getTrueUnitConfig(action.unit)
							local baseCost = 0
							if trueConfig then
								baseCost = trueConfig.Cost or 0
							end

							-- Wait for conditions
							while isPlayingMacro and not gameEnded do
								if player:GetAttribute("Cash") >= baseCost then
									break
								end
								task.wait(0.05)
							end
							if not isPlayingMacro or gameEnded then
								break
							end

							local s, newId
							local attempt = 0
							while not s and isPlayingMacro and not gameEnded do
								local offset = Vector3.new((math.random() * 2 - 1) * 0.3, 0, (math.random() * 2 - 1) * 0.3)

								local testPos = Vector3.new(action.position.X, action.position.Y, action.position.Z)
									+ offset
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
									task.wait(0.1) -- Allow server cash replication to catch up
								else
									attempt = attempt + 1
									task.wait(0.3)
								end
							end
						elseif action.type == "UpgradeUnit" then
							local trueConfig = getTrueUnitConfig(action.unit)
							local upgCost = 0
							if trueConfig and trueConfig.Upgrades and trueConfig.Upgrades[action.level - 1] then
								upgCost = trueConfig.Upgrades[action.level - 1].Cost or 0
							end

							-- Wait for cash
							while isPlayingMacro and not gameEnded do
								if player:GetAttribute("Cash") >= upgCost then
									break
								end
								task.wait(0.05)
							end
							if not isPlayingMacro or gameEnded then
								break
							end

							local targetId = idMap[action.id]
							if targetId then
								local s = false
								while not s and isPlayingMacro and not gameEnded do
									s = TowerDefense.UpgradeUnit(targetId)
									if s then
										print(
											"Playback: Upgraded " .. action.unit .. " to lvl " .. tostring(action.level)
										)
										task.wait(0.1) -- Allow server cash replication to catch up
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
					if endConn then
						endConn:Disconnect()
					end

					if isPlayingMacro then
						print("Game Ended! Voting difficulty to restart...")
						local difRestart = activeMacro.dif or "dif_easy"
						pcall(function()
							RestartGame:InvokeServer()
						end)
						task.wait(0.3) -- after restart is called
						pcall(function()
							PlaceDifficultyVote:InvokeServer(difRestart)
						end)
						task.wait(1) -- after vote
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
							rotation = rot,
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
							active = false,
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
							local trueConfig = getTrueUnitConfig(poolData.unitName)
							if trueConfig and trueConfig.Upgrades and trueConfig.Upgrades[poolData.unitLevel] then
								upgBtn.Text = tostring(trueConfig.Upgrades[poolData.unitLevel].Cost)
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
	if input.KeyCode == Enum.KeyCode.R then
		-- Only toggle if it was held for LESS than 2 seconds
		if rHeld and (tick() - rPressTime < 2) then
			isRecording = not isRecording
			if isRecording then
				statusLabel.Text = "Status: Recording"
				print("Recording started!")
				recordedQueries = {}
				managerFrame.Visible = true
				for _, child in ipairs(managerFrame:GetChildren()) do
					if child:IsA("Frame") then
						child:Destroy()
					end
				end

				autoUpgradePool = {}
				autoUpgradeLoopRunning = true
				task.spawn(function()
					while autoUpgradeLoopRunning and isRecording do
						local bestUnit = nil
						local lowestCost = math.huge

						for _, u in ipairs(autoUpgradePool) do
							if u.active then
								local trueConfig = getTrueUnitConfig(u.unitName)
								if trueConfig and trueConfig.Upgrades and trueConfig.Upgrades[u.unitLevel] then
									local cost = trueConfig.Upgrades[u.unitLevel].Cost
									if cost and cost < lowestCost then
										lowestCost = cost
										bestUnit = u
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

						task.wait(0.1)
					end
				end)
			else
				autoUpgradeLoopRunning = false
				managerFrame.Visible = false

				local mapId = workspace:GetAttribute("MapId") or "unknown_map"
				local dif = workspace:GetAttribute("Difficulty") or "dif_normal"
				local key = mapId .. "_" .. dif

				local saveActions = {}
				for _, query in ipairs(recordedQueries) do
					if query.type == "PlaceUnit" then
						table.insert(saveActions, {
							type = "PlaceUnit",
							unit = query.unit,
							id = query.id,
							position = { X = query.position.X, Y = query.position.Y, Z = query.position.Z },
							rotation = query.rotation,
						})
					elseif query.type == "UpgradeUnit" then
						table.insert(saveActions, {
							type = "UpgradeUnit",
							unit = query.unit,
							id = query.id,
							level = query.level,
						})
					end
				end

				macroConfigs[key] = {
					dif = dif,
					actions = saveActions,
				}
				saveMacros()
				statusLabel.Text = "Status: Saved!"
				print("Saved macro to " .. key .. " in " .. SAVE_FILE)
			end
		end
		rHeld = false
	end
end)
