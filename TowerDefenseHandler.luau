local TowerDefense = { CustomMapModelBehaviours = {} }
local playersService = game:GetService("Players")
local replicatedStorageService = game:GetService("ReplicatedStorage")
local ClientLoader = nil
local SharedHelper = nil
local GameConfig = nil
local collectionService = game:GetService("CollectionService")
local _ = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Others"):WaitForChild("CrateRotator"))
local httpService = game:GetService("HttpService")
local timeEffectsModule = require(replicatedStorageService.Others.UnitCallbacks.TimeEffects)
local IsPlayerReady = false
local _ = {}
local GameState = {}
TowerDefense.GameModes = GameState
local v11 = nil

function GetChristmasGiftRewardFromSeeds(p0, p1) --[[ line: 27 ]]
	-- upvalues: ClientLoader (write), SharedHelper (write)
	return math.max(SharedHelper.RoundTo(ClientLoader.Modules.ServerPlayerHandler.MultiplyByPlayerProperty(p0, p1, "ChristmasGiftsMult") * 0.5, 25), 25)
end

local tickSpeed = game.Workspace:GetAttribute("TickSpeed") or 1
local IsGamePaused = false

function TowerDefense.GetTS() --[[ line: 39 ]]
	-- upvalues: IsGamePaused (write), tickSpeed (write)
	return if IsGamePaused then 0 else tickSpeed
end

function TowerDefense.GetTSSafe() --[[ line: 43 ]]
	-- upvalues: TowerDefense (ref)
	return if TowerDefense.GetTS() == 0 then 1 else TowerDefense.GetTS()
end

game.Workspace:GetAttributeChangedSignal("TickSpeed"):Connect(function() --[[ line: 48 ]]
	-- upvalues: tickSpeed (write)
	tickSpeed = game.Workspace:GetAttribute("TickSpeed")
end)
game.Workspace:GetAttributeChangedSignal("GamePaused"):Connect(function() --[[ line: 51 ]]
	-- upvalues: IsGamePaused (write)
	IsGamePaused = game.Workspace:GetAttribute("GamePaused")
end)

function TowerDefense.Wait(p2) --[[ line: 55 ]]
	-- upvalues: SharedHelper (write), TowerDefense (ref)
	if not p2 then
		return
	end
	local v16 = 0
	while p2 > 0 do
		local v17 = SharedHelper.RSWait() * TowerDefense.GetTS()
		p2 = p2 - v17
		v16 = v16 + v17
	end
	return v16
end

function TowerDefense.Delay(p3, p4) --[[ line: 67 ]]
	-- upvalues: TowerDefense (ref)
	return task.spawn(function() --[[ line: 68 ]]
		-- upvalues: TowerDefense (copy), p3 (ref), p4 (ref)
		TowerDefense.Wait(p3)
		p4()
	end)
end

function TowerDefense.GetBaseHealthForPlayer(p5) --[[ line: 74 ]]
	local teamIndex = p5:GetAttribute("TeamIndex") or 1
	
	return game.Workspace:GetAttribute("BaseHP_" .. teamIndex), game.Workspace:GetAttribute("MaxBaseHP_" .. teamIndex)
end

function TowerDefense.GetBaseHealthForTeam(p6) --[[ line: 80 ]]
	return game.Workspace:GetAttribute("BaseHP_" .. p6), game.Workspace:GetAttribute("MaxBaseHP_" .. p6)
end

local function GetUnitPurchaseDiscount(p7) --[[ line: 85 ]]
	local v19 = 0
	
	for i, v in if p7.Data.Status and p7.Data.Status.status_purchase_discount then p7.Data.Status.status_purchase_discount else {} do
		v19 = math.max(v19, math.clamp(if v.Params and v.Params.Discount then v.Params.Discount else 0, 0, 1))
	end
	return v19
end

function TowerDefense.GetUpgradeCost(p8) --[[ line: 96 ]]
	-- upvalues: GetUnitPurchaseDiscount (ref)
	local level = p8.Data.Upgrades[p8.Data.Level]
	
	if not level then
		return
	end
	return math.round(level.Cost * (1 - GetUnitPurchaseDiscount(p8)))
end

function TowerDefense.GetAbilityCost(p9, p10) --[[ line: 103 ]]
	-- upvalues: GetUnitPurchaseDiscount (ref)
	local playerTriggeredAbility = p10.Config.PlayerTriggeredAbility
	
	if not playerTriggeredAbility then
		return
	end
	local v20 = type(playerTriggeredAbility.Cost) == "function" and (playerTriggeredAbility.Cost(p9, p10) or playerTriggeredAbility.Cost)
	
	if v20 == nil then
		return
	end
	return math.round(v20 * (1 - GetUnitPurchaseDiscount(p10)))
end

function TowerDefense.CalculateUnitValue(p11, p12) --[[ line: 113 ]]
	-- upvalues: ClientLoader (write), SharedHelper (write)
	local _ = 0
	local item = ClientLoader.Modules.SharedItemData.GetItem(p12.UnitId)
	local cost = item.Params.UnitConfig.Cost
	local v22 = nil
	local v23 = 0.5
	local v24 = cost * v23
	
	for i = 1, p12.Data.Level - 1 do
		v24 = v24 + item.Params.UnitConfig.Upgrades[i].Cost * v23
	end
	if p12.Data.Health and p12.Data.MaxHealth then
		v24 = math.ceil(v24 * p12.Data.Health / p12.Data.MaxHealth)
		v22 = true
	end
	local uses = item.Params.UnitConfig.Uses
	
	if uses and uses > 0 then
		v24 = math.ceil(v24 * p12.Data.Uses / uses)
	end
	v24 = math.ceil(v24)
	
	if p11:GetAttribute("UnitsPlaced") == 1 then
		local minUnitCost = p11:GetAttribute("MinUnitCost") or 150
		local v26 = if ClientLoader.IsServer then ClientLoader.Modules.ServerDataHandler.GetValue(p11, "Cash") else p11:GetAttribute("Cash")
		
		if v24 + v26 < minUnitCost then
			return minUnitCost - v26, true
		end
	end
	if table.find({
		"unit_lawnmower",
		"unit_log_roller",
		"unit_silly_mushroom",
		"unit_grave_crawler",
		"unit_snow_shovel"
	}, p12.BaseUnit or p12.UnitId) then
		v24 = 0
	end
	if SharedHelper.IsDungeonAsync() then
		return 0, true
	end
	return v24, v22
end

local v15 = nil

function TowerDefense.GetPreviousByHealth(p13) --[[ line: 178 ]]
	-- upvalues: v15 (write), ClientLoader (write)
	if not v15 then
		v15 = {}
		
		for i, v in pairs(ClientLoader.Modules.SharedItemData.GetCategory("Units")) do
			if not (v.Params.System or v.Params.UnitType ~= "enemy" or v.ID == "enemy_dps_dummy") then
				table.insert(v15, {
					Id = v.ID,
					Health = v.Params.UnitConfig.MaxHealth,
					IsBoss = v.Params.UnitConfig.IsBoss
				})
			end
		end
		table.sort(v15, function(p14, p15) --[[ line: 187 ]]
			return p14.Health < p15.Health
		end)
	end
	for i, v in pairs(v15) do
		if v.Id == p13 then
			local v27 = i - 1
			while v15[v27] and v15[v27].IsBoss do
				v27 = v27 - 1
			end
			return v15[math.max(v27, 1)].Id
		end
	end
end

function TowerDefense.ApplyModifier(p16, p17, ...) --[[ line: 204 ]]
	-- upvalues: ClientLoader (write)
	local item = ClientLoader.Modules.SharedItemData.GetItem(p16)
	
	for i, v in pairs(item.Params.Mods) do
		if v.Type == p17 then
			local ok, status = pcall(function(...) --[[ line: 208 ]]
				-- upvalues: ClientLoader (copy), v (ref), item (ref)
				ClientLoader.SharedLogic.ApplyModifier(v, item, ...)
			end, ...)
			
			if not ok then
				warn("Could not apply modifier: " .. tostring(status))
			end
		end
	end
end

function ServerLoad() --[[ line: 218 ]]
	-- upvalues: TowerDefense (ref), ClientLoader (write), SharedHelper (write), v11 (write), GameConfig (write), httpService (ref), collectionService (ref), IsPlayerReady (write), timeEffectsModule (ref), replicatedStorageService (ref), playersService (ref)
	TowerDefense.LightingSerializer = require(script:WaitForChild("lightingSerializer"))
	TowerDefense.Postgres = require(script:WaitForChild("PostgresGameplayStats"))
	TowerDefense.Postgres.Load(ClientLoader, TowerDefense, SharedHelper)
	local GameState = {
		Loaded = false,
		MapData = nil,
		MaxPlayers = 1,
		TotalUpgrades = 0,
		EnemySumCoverage = 0,
		EnemyCountCoverage = 0,
		GameNumber = 1,
		UseMaxReplays = false,
		AdjustedPlayTime = 0,
		RoundsActive = false,
		PlayerData = {},
		Analytics = {},
		UsedUnits = {},
		UserIds = {},
		Votes = {},
		EnemySendQueue = { [1] = {}, [2] = {} },
		TimeUntilNextEnemyFromQueueSent = { [1] = 2, [2] = 2 },
		MaxReplays = math.random(10, 15),
		ActiveModifiers = {}
	}
	task.spawn(function() --[[ line: 254 ]]
		-- upvalues: TowerDefense (copy), GameState (ref)
		while true do
			local _ = tick()
			if not GameState.RoundsActive or GameState.GameEnded then
				continue
			end
			local v61 = GameState
			v61.AdjustedPlayTime = v61.AdjustedPlayTime + TowerDefense.Wait(1)
		end
	end)
	
	function TowerDefense.GetGameState() --[[ line: 264 ]]
		-- upvalues: GameState (ref)
		return GameState
	end
	
	function TowerDefense.ApplyModifiers(p18, ...) --[[ line: 268 ]]
		-- upvalues: GameState (ref), TowerDefense (copy)
		if not GameState.ActiveModifiers then
			return
		end
		if #GameState.ActiveModifiers == 0 then
			return
		end
		for i, v in pairs(GameState.ActiveModifiers) do
			TowerDefense.ApplyModifier(v, p18, ...)
		end
	end
	
	function TowerDefense.GetModifierValue(p19, p20) --[[ line: 277 ]]
		-- upvalues: TowerDefense (copy)
		local GameState = { [p20] = 1 }
		TowerDefense.ApplyModifiers(p19, GameState)
		
		return GameState[p20]
	end
	
	local v30 = 0
	
	function TowerDefense.SetModifierActive(value, p21) --[[ line: 285 ]]
		-- upvalues: GameState (ref), v30 (write), ClientLoader (copy), TowerDefense (copy)
		if not p21 then
			local v63 = table.find(GameState.ActiveModifiers, value)
			
			if v63 then
				table.remove(GameState.ActiveModifiers, v63)
			end
		elseif not table.find(GameState.ActiveModifiers, value) then
			table.insert(GameState.ActiveModifiers, value)
		end
		game.Workspace:SetAttribute("ActiveModifiers", table.concat(GameState.ActiveModifiers), ";")
		v30 = v30 + 1
		local v64 = v30
		task.delay(0.1, function() --[[ line: 301 ]]
			-- upvalues: v64 (ref), v30 (copy), ClientLoader (copy)
			if v64 ~= v30 then
				return
			end
			ClientLoader.Modules.ServerPlayerHandler.RefreshPlayerBoosts()
		end)
		TowerDefense.ApplyModifiers("itemdata")
	end
	
	local function _(value) --[[ line: 309 | named "ResetVote" ]]
		-- upvalues: GameState (ref), SharedHelper (copy)
		GameState.Votes[value] = nil
		SharedHelper.FireAllClients("UpdateTDVotes", value)
	end
	
	local _ = function(p22) --[[ line: 314 | named "GetVoteWinner" ]]
		-- upvalues: GameState (ref)
		if not GameState.Votes[p22] then
			return
		end
		return GameState.Votes[p22].Winner
	end
	
	local _ = function(p23) --[[ line: 319 | named "GetVotes" ]]
		-- upvalues: GameState (ref)
		return if not GameState.Votes[p23] then GameState.Votes[p23].Votes else {}
	end
	
	local _ = function(p24) --[[ line: 324 | named "UpdatePlayerHealth" ]]
		-- upvalues: TowerDefense (copy), ClientLoader (copy)
		local character = p24.Character
		
		if not character then
			return
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		
		if not humanoid then
			return
		end
		TowerDefense.ChangePlayerData(p24, function(p25) --[[ line: 329 ]]
			-- upvalues: humanoid (ref), character (ref), ClientLoader (copy), p24 (ref)
			humanoid.Health = p25.Health
			character:SetAttribute("Downed", p25.Downed)
			
			if p25.Downed then
				ClientLoader.BindToLoadedModules(function() --[[ line: 334 ]]
					-- upvalues: ClientLoader (copy), p24 (copy)
					ClientLoader.Modules.ServerPlayerHandler.AddPlayerCharacterProperty(p24, "WalkSpeed", "downed", -20)
				end)
				
				return
			end
			ClientLoader.BindToLoadedModules(function() --[[ line: 338 ]]
				-- upvalues: ClientLoader (copy), p24 (copy)
				ClientLoader.Modules.ServerPlayerHandler.RemovePlayerCharacterProperty(p24, "WalkSpeed", "downed")
			end)
		end)
	end
	
	function TowerDefense.IsAlive(p26) --[[ line: 345 ]]
		-- upvalues: TowerDefense (copy)
		local v66 = false
		TowerDefense.ChangePlayerData(p26, function(p27) --[[ line: 347 ]]
			-- upvalues: v66 (write)
			if p27.Health > 0 then
				v66 = true
			end
		end)
		
		return v66
	end
	
	function TowerDefense.AnyoneAlive() --[[ line: 355 ]]
		-- upvalues: TowerDefense (copy)
		local GameState = {}
		
		for i, v in pairs(game.Players:GetPlayers()) do
			local v68 = false
			TowerDefense.ChangePlayerData(v, function(p28) --[[ line: 361 ]]
				-- upvalues: v68 (write)
				v68 = not p28.Ghost and not p28.Downed
			end)
		end
		return #GameState > 0, GameState
	end
	
	function TowerDefense.SetBaseHealthForPlayer(value, p29) --[[ line: 372 ]]
		local teamIndex = value:GetAttribute("TeamIndex") or 1
		game.Workspace:SetAttribute("BaseHP_" .. teamIndex, p29)
		
		if teamIndex == 1 then
			game.Workspace:SetAttribute("BaseHP", p29)
		end
	end
	
	function TowerDefense.SetBaseHealthForTeam(value, p30) --[[ line: 382 ]]
		game.Workspace:SetAttribute("BaseHP_" .. value, p30)
		
		if value == 1 then
			game.Workspace:SetAttribute("BaseHP", p30)
		end
	end
	
	function TowerDefense.PotentiallyGameOver() --[[ line: 391 ]]
		-- upvalues: TowerDefense (copy), SharedHelper (copy), ClientLoader (copy)
		if TowerDefense.AnyoneAlive() then
			return
		end
		if not SharedHelper.IsDungeonAsync() then
			return
		end
		local v70 = false
		
		for i, v in pairs(ClientLoader.Modules.Units.base.GetActiveEntities()) do
			if v.Config.OnBaseDeath then
				v70 = v.Config.OnBaseDeath(ClientLoader, SharedHelper, v)
				break
			end
		end
		if not v70 then
			ClientLoader.Modules.SharedTowerDefenseHandler.GameEnded(false)
			
			return
		end
		for i, v_1 in game.Players:GetPlayers() do
			TowerDefense.HealPlayer(v_1)
		end
	end
	
	function TowerDefense.RevivePlayer(p31, p32) --[[ line: 414 ]]
		-- upvalues: TowerDefense (copy), ClientLoader (copy)
		if not TowerDefense.IsAlive(p31) then
			return
		end
		TowerDefense.ChangePlayerData(p31, function(p33) --[[ line: 417 ]]
			-- upvalues: p32 (ref), p31 (ref), TowerDefense (copy), ClientLoader (copy)
			if not p33.Downed then
				return
			end
			p33.Health = p33.Health + p32
			p33.Downed = false
			p33.RevivedDeb = true
			task.delay(3, function() --[[ line: 423 ]]
				-- upvalues: p33 (ref)
				p33.RevivedDeb = false
			end)
			local character = p31.Character
			
			if not character then
				return
			end
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			
			if not humanoid then
				return
			end
			TowerDefense.ChangePlayerData(p31, function(p34) --[[ line: 329 ]]
				-- upvalues: humanoid (ref), character (ref), ClientLoader (copy), p31 (ref)
				humanoid.Health = p34.Health
				character:SetAttribute("Downed", p34.Downed)
				
				if p34.Downed then
					ClientLoader.BindToLoadedModules(function() --[[ line: 334 ]]
						-- upvalues: ClientLoader (copy), p31 (copy)
						ClientLoader.Modules.ServerPlayerHandler.AddPlayerCharacterProperty(p31, "WalkSpeed", "downed", -20)
					end)
					
					return
				end
				ClientLoader.BindToLoadedModules(function() --[[ line: 338 ]]
					-- upvalues: ClientLoader (copy), p31 (copy)
					ClientLoader.Modules.ServerPlayerHandler.RemovePlayerCharacterProperty(p31, "WalkSpeed", "downed")
				end)
			end)
		end)
	end
	
	local _ = function(value) --[[ line: 431 | named "TakeReviveRound" ]]
		-- upvalues: TowerDefense (copy), ClientLoader (copy)
		TowerDefense.ChangePlayerData(value, function(p35) --[[ line: 432 ]]
			-- upvalues: value (ref), TowerDefense (copy), ClientLoader (copy)
			if not p35.ReviveRoundsLeft then
				return
			end
			p35.ReviveRoundsLeft = p35.ReviveRoundsLeft - 1
			value:SetAttribute("ReviveRoundsLeft", p35.ReviveRoundsLeft)
			
			if p35.ReviveRoundsLeft <= 0 then
				p35.ReviveRoundsLeft = nil
				TowerDefense.HealPlayer(value)
				
				return
			end
			if p35.ReviveRoundsLeft == 1 then
				ClientLoader.Modules.SharedHelper.FireRemoteEvent("ShowMessage", value, "You will respawn next round!", "warn")
				
				return
			end
			ClientLoader.Modules.SharedHelper.FireRemoteEvent("ShowMessage", value, "You will respawn in " .. tostring(p35.ReviveRoundsLeft) .. " rounds!", "warn")
		end)
	end
	
	local _ = function(p36) --[[ line: 450 | named "GhostPlayer" ]]
		-- upvalues: TowerDefense (copy), GameState (ref), ClientLoader (copy)
		TowerDefense.ChangePlayerData(p36, function(p37) --[[ line: 451 ]]
			-- upvalues: GameState (copy), p36 (ref), TowerDefense (copy), ClientLoader (copy)
			p37.Ghost = true
			
			if GameState.WaveCount and GameState.CurrentRound then
				p37.ReviveRoundsLeft = math.min(5, GameState.WaveCount + 1 - GameState.CurrentRound)
			else
				p37.ReviveRoundsLeft = 5
			end
			p36:SetAttribute("ReviveRoundsLeft", p37.ReviveRoundsLeft)
			p36:SetAttribute("Ghost", true)
			
			if TowerDefense.AnyoneAlive() then
				if p37.ReviveRoundsLeft == 1 then
					ClientLoader.Modules.SharedHelper.FireRemoteEvent("ShowMessage", p36, "You have died! You will respawn next round!", "warn")
				else
					ClientLoader.Modules.SharedHelper.FireRemoteEvent("ShowMessage", p36, "You have died! You will respawn in " .. tostring(p37.ReviveRoundsLeft) .. " rounds!", "warn")
				end
				for i, v in pairs(game.Players:GetPlayers()) do
					if v ~= p36 then
						ClientLoader.Modules.SharedHelper.FireRemoteEvent("ShowMessage", v, p36.DisplayName .. " has died!", "warn")
					end
				end
			end
		end)
	end
	
	function TowerDefense.DealSurvivalBaseDamage(p38, p39) --[[ line: 479 ]]
		-- upvalues: SharedHelper (copy)
		return SharedHelper.InvokeBindableFunction(p38, "DealDamage", p39)
	end
	
	function TowerDefense.DealPlayerDamage(p40, p41, p42) --[[ line: 483 ]]
		-- upvalues: TowerDefense (copy), SharedHelper (copy), ClientLoader (copy), GameState (ref)
		if not TowerDefense.IsAlive(p40) then
			return
		end
		TowerDefense.ChangePlayerData(p40, function(p43) --[[ line: 486 ]]
			-- upvalues: p41 (write), p42 (ref), SharedHelper (copy), p40 (ref), ClientLoader (copy), TowerDefense (copy), GameState (copy)
			if not p41 then
				p41 = p43.Health
			end
			p41 = math.min(p41, p43.Health)
			
			if p43.Downed and not p42 then
				return
			end
			if p41 > 0 then
				SharedHelper.FireSignal("PlayerDamaged", p40, p41)
			end
			local v72 = p43.Health - p41
			
			if v72 <= 0 and not p43.Downed then
				v72 = 1
				p43.Downed = true
				p43.DownedTimeLeft = ClientLoader.Modules.SharedDownedSystem.Config.BleedoutTime
				local v73, _ = TowerDefense.AnyoneAlive()
				
				if v73 then
					ClientLoader.Modules.SharedHelper.FireRemoteEvent("ShowMessage", p40, "You are downed! Someone needs to revive you!", "warn")
					local inMinigameAttribute = p40:GetAttribute("InMinigame")
					
					for i, v in pairs(game.Players:GetPlayers()) do
						if not (v == p40 or v:GetAttribute("InMinigame") ~= inMinigameAttribute) then
							ClientLoader.Modules.SharedHelper.FireRemoteEvent("ShowMessage", v, p40.DisplayName .. " needs a revive!", "warn")
						end
					end
				end
				SharedHelper.FireSignal("PlayerDowned", p40)
			end
			if v72 <= 0 and p40.Character then
				local getCarriedAttribute = p40.Character:GetAttribute("GetCarried")
				
				if getCarriedAttribute then
					local v76 = game.Players:FindFirstChild(getCarriedAttribute)
					
					if v76 then
						ClientLoader.Modules.SharedDownedSystem.StopCarry(v76)
					end
				end
			end
			p43.Health = v72
			task.wait(0.1)
			local character = p40.Character
			
			if character then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				
				if humanoid then
					TowerDefense.ChangePlayerData(p40, function(p44) --[[ line: 329 ]]
						-- upvalues: humanoid (ref), character (ref), ClientLoader (copy), p40 (ref)
						humanoid.Health = p44.Health
						character:SetAttribute("Downed", p44.Downed)
						
						if p44.Downed then
							ClientLoader.BindToLoadedModules(function() --[[ line: 334 ]]
								-- upvalues: ClientLoader (copy), p40 (copy)
								ClientLoader.Modules.ServerPlayerHandler.AddPlayerCharacterProperty(p40, "WalkSpeed", "downed", -20)
							end)
							
							return
						end
						ClientLoader.BindToLoadedModules(function() --[[ line: 338 ]]
							-- upvalues: ClientLoader (copy), p40 (copy)
							ClientLoader.Modules.ServerPlayerHandler.RemovePlayerCharacterProperty(p40, "WalkSpeed", "downed")
						end)
					end)
				end
			end
			if p43.Health <= 0 and not SharedHelper.IsAdminArenaAsync() then
				local v78 = p40
				TowerDefense.ChangePlayerData(v78, function(p45) --[[ line: 451 ]]
					-- upvalues: GameState (copy), v78 (ref), TowerDefense (copy), ClientLoader (copy)
					p45.Ghost = true
					
					if GameState.WaveCount and GameState.CurrentRound then
						p45.ReviveRoundsLeft = math.min(5, GameState.WaveCount + 1 - GameState.CurrentRound)
					else
						p45.ReviveRoundsLeft = 5
					end
					v78:SetAttribute("ReviveRoundsLeft", p45.ReviveRoundsLeft)
					v78:SetAttribute("Ghost", true)
					
					if TowerDefense.AnyoneAlive() then
						if p45.ReviveRoundsLeft == 1 then
							ClientLoader.Modules.SharedHelper.FireRemoteEvent("ShowMessage", v78, "You have died! You will respawn next round!", "warn")
						else
							ClientLoader.Modules.SharedHelper.FireRemoteEvent("ShowMessage", v78, "You have died! You will respawn in " .. tostring(p45.ReviveRoundsLeft) .. " rounds!", "warn")
						end
						for i, v in pairs(game.Players:GetPlayers()) do
							if v ~= v78 then
								ClientLoader.Modules.SharedHelper.FireRemoteEvent("ShowMessage", v, v78.DisplayName .. " has died!", "warn")
							end
						end
					end
				end)
			end
			if p43.Health <= 1 then
				task.delay(1, function() --[[ line: 547 ]]
					-- upvalues: TowerDefense (copy)
					TowerDefense.PotentiallyGameOver()
				end)
			end
		end)
		
		return true
	end
	
	function TowerDefense.HealPlayer(p46, p47) --[[ line: 556 ]]
		-- upvalues: TowerDefense (copy), ClientLoader (copy)
		if not TowerDefense.IsAlive(p46) and p47 then
			return
		end
		if not p47 then
			TowerDefense.ChangePlayerData(p46, function(p48) --[[ line: 559 ]]
				-- upvalues: p46 (ref), ClientLoader (copy)
				local ghost = p48.Ghost
				p48.Downed = false
				p48.Ghost = false
				p48.ReviveRoundsLeft = nil
				p46:SetAttribute("ReviveRoundsLeft", p48.ReviveRoundsLeft)
				
				if p46.Character then
					p46.Character:SetAttribute("Carry")
				end
				if ghost then
					ClientLoader.Modules.SharedHelper.FireRemoteEvent("ShowMessage", p46, "You are now alive again!", "success")
				end
			end)
			p46:SetAttribute("Ghost")
		end
		if not p47 then
			p47 = 100
		end
		TowerDefense.ChangePlayerData(p46, function(p49) --[[ line: 579 ]]
			-- upvalues: p47 (write), p46 (ref), TowerDefense (copy), ClientLoader (copy)
			p47 = math.min(p47, 100 - p49.Health)
			p49.Health = p49.Health + p47
			local character = p46.Character
			
			if not character then
				return
			end
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			
			if not humanoid then
				return
			end
			TowerDefense.ChangePlayerData(p46, function(p50) --[[ line: 329 ]]
				-- upvalues: humanoid (ref), character (ref), ClientLoader (copy), p46 (ref)
				humanoid.Health = p50.Health
				character:SetAttribute("Downed", p50.Downed)
				
				if p50.Downed then
					ClientLoader.BindToLoadedModules(function() --[[ line: 334 ]]
						-- upvalues: ClientLoader (copy), p46 (copy)
						ClientLoader.Modules.ServerPlayerHandler.AddPlayerCharacterProperty(p46, "WalkSpeed", "downed", -20)
					end)
					
					return
				end
				ClientLoader.BindToLoadedModules(function() --[[ line: 338 ]]
					-- upvalues: ClientLoader (copy), p46 (copy)
					ClientLoader.Modules.ServerPlayerHandler.RemovePlayerCharacterProperty(p46, "WalkSpeed", "downed")
				end)
			end)
		end)
		
		return true
	end
	
	function TowerDefense.ChangePlayerData(p51, p52) --[[ line: 588 ]]
		-- upvalues: GameState (ref)
		local name = p51.Name
		
		if not GameState.PlayerData[name] then
			GameState.PlayerData[name] = {
				Kills = 0,
				DamageDealt = 0,
				Health = 100,
				SpaceGemsFromKills = 0
			}
		end
		p52(GameState.PlayerData[name])
	end
	
	local _ = function(p53, _) --[[ line: 603 | named "BossWarning" ]]
		-- upvalues: ClientLoader (copy)
		local item = ClientLoader.Modules.SharedItemData.GetItem(p53)
		local unitConfig = item.Params.UnitConfig
		
		if not (item and unitConfig) then
			return
		end
		if not unitConfig.IsBoss then
			return
		end
	end
	
	function TowerDefense.SpawnEnemy(p54, p55) --[[ line: 610 ]]
		-- upvalues: SharedHelper (copy), v11 (copy), ClientLoader (copy)
		p55 = if not p55 then {} else SharedHelper.DeepCopy(p55)
		v11 = CallGameModeFunction("GetEnemyMutateHandler")
		CallGameModeFunction("MutateSpawnEnemyParams", p55)
		v11 = nil
		local v81 = ClientLoader.Modules.Units.base.CreateEntity(p54, p55)
		CallGameModeFunction("EnemyCreated", v81)
		
		return true, v81.ID
	end
	
	function TowerDefense.GiveSeedsToPlayer(p56, p57, p58) --[[ line: 628 ]]
		-- upvalues: SharedHelper (copy), ClientLoader (copy)
		for i, v in pairs({
			{ AwardType = "aw_add", DataName = "Seeds", Amount = p57 },
			{
				AwardType = "aw_message",
				MessageType = "item",
				MessageImage = "127868571094153",
				Message = "You got " .. tostring(p57) .. " Seeds!"
			}
		}) do
			local v82 = SharedHelper.DeepCopy(v)
			v82.TransactionType = "towerdefense"
			v82.TransactionItemId = p58
			ClientLoader.Modules.ServerDataHandler.ServerAwardHandler.Award(p56, v.AwardType, v82)
		end
	end
	
	function TowerDefense.GiveSeedsToAllPlayers(p59, p60) --[[ line: 643 ]]
		-- upvalues: SharedHelper (copy), GameState (ref), ClientLoader (copy), TowerDefense (copy)
		if SharedHelper.IsSandboxAsync() then
			return
		end
		for i, v in pairs(game.Players:GetPlayers()) do
			local name = GameState.PlayerData[v.Name]
			
			if name and name.DamageDealt > 10 then
				local v83 = math.ceil(TowerDefense.ApplySeedsBoostsFromUnits(ClientLoader.Modules.ServerPlayerHandler.MultiplyByPlayerProperty(p59, v, "SeedsMult"), v))
				local list = {
					{ AwardType = "aw_add", DataName = "Seeds", Amount = v83 },
					{
						AwardType = "aw_message",
						MessageType = "item",
						MessageImage = "127868571094153",
						Message = "You got " .. tostring(v83) .. " Seeds!"
					}
				}
				
				if GameState.MapData.Params.RewardCurrency then
					local v85 = math.ceil(ClientLoader.Modules.ServerPlayerHandler.MultiplyByPlayerProperty(p59, v, GameState.MapData.Params.RewardCurrency .. "Mult"))
					local rewardCurrency = ClientLoader.Config.ExtraCurrencies[GameState.MapData.Params.RewardCurrency]
					list = {
						{
							AwardType = "aw_add",
							DataName = GameState.MapData.Params.RewardCurrency,
							Amount = v85
						},
						{
							AwardType = "aw_message",
							MessageType = "item",
							Message = "You got " .. tostring(v85) .. " " .. rewardCurrency.AutoGenerate.Name .. "!",
							MessageImage = rewardCurrency.AutoGenerate.Image.Small
						}
					}
				end
				for i_1, v_1 in pairs(list) do
					local v86 = SharedHelper.DeepCopy(v_1)
					v86.TransactionType = "towerdefense"
					v86.TransactionItemId = p60
					ClientLoader.Modules.ServerDataHandler.ServerAwardHandler.Award(v, v_1.AwardType, v86)
				end
			end
		end
	end
	
	local function PlayerMapProgress(p61, p62, p63) --[[ line: 700 ]]
		-- upvalues: ClientLoader (copy)
		local playerData = ClientLoader.Modules.ServerDataHandler.GetPlayerData(p61)
		
		if not playerData then
			return
		end
		if not playerData.MapProgress[p62] then
			playerData.MapProgress[p62] = {}
		end
		p63(playerData.MapProgress[p62])
		ClientLoader.Modules.ServerDataHandler.SendUpdatePlayerData(p61, "MapProgress", playerData.MapProgress)
	end
	
	local function ApplyLossSeedsRewardCurve(p64) --[[ line: 710 ]]
		-- upvalues: GameConfig (copy)
		local lossSeedsRewardCurve = GameConfig.LossSeedsRewardCurve
		
		if not (lossSeedsRewardCurve and lossSeedsRewardCurve.Enabled) then
			return p64
		end
		local minInput = lossSeedsRewardCurve.MinInput or 75
		local maxInput = lossSeedsRewardCurve.MaxInput or 5000
		local maxOutput = lossSeedsRewardCurve.MaxOutput or 2500
		
		return if p64 <= minInput then p64 elseif maxInput <= p64 then maxOutput else math.min(p64 - (maxInput - maxOutput) * math.clamp((p64 - minInput) / math.max(1, maxInput - minInput), 0, 1) ^ (lossSeedsRewardCurve.Exponent or 3), maxOutput)
	end
	
	function TowerDefense.GiveGameEndRewad(p65, p66) --[[ line: 733 ]]
		-- upvalues: SharedHelper (copy), GameState (ref), TowerDefense (copy), ApplyLossSeedsRewardCurve (ref), ClientLoader (copy), PlayerMapProgress (ref)
		if SharedHelper.IsPvpAsync() then
			return
		end
		if SharedHelper.IsSandboxAsync() then
			return
		end
		local name = GameState.PlayerData[p65.Name]
		
		if not name then
			return
		end
		if name.DamageDealt <= 10 then
			return
		end
		local wavesCleared = TowerDefense.GetWavesCleared()
		local v92 = 0
		local v93 = 0
		
		if GameState.ForceDifficulty ~= "dif_endless" then
			v92 = if SharedHelper.IsDungeonAsync() then GameState.MapData.Params.Rewards[GameState.DifId][GameState.CurrentLevel] else GameState.MapData.Params.Rewards[GameState.DifId]
			
			if not p66 then
				v92 = ApplyLossSeedsRewardCurve(v92 * 0.5) * math.max(1, wavesCleared) / math.max(1, GameState.MaxRound)
				local v94 = 5
				
				if GameState.DifId == "dif_apocalypse" or GameState.DifId == "dif_hell" then
					v94 = 20
				elseif GameState.DifId == "dif_impossible" then
					v94 = 15
				elseif GameState.DifId == "dif_insane" then
					v94 = 10
				elseif GameState.DifId == "dif_hard" then
					v94 = 7
				elseif GameState.DifId == "dif_normal" or GameState.DifId == "dif_easy" then
					v94 = 5
				end
				if GameState.ActiveModifiers and #GameState.ActiveModifiers > 0 then
					v94 = if GameState.DifId == "dif_easy" then 10 else 15
				end
				v94 = math.min(v94, GameState.MaxRound)
				
				if wavesCleared < v94 and ClientLoader.Modules.ServerDataHandler.CheckAfford(p65, "GamesPlayed", 10) then
					ClientLoader.Modules.SharedHelper.FireRemoteEvent("ShowMessage", p65, "You need to clear at least " .. tostring(v94) .. " waves to get Seeds on defeat!", "warn")
					v92 = 0
				end
			end
			local additionalRewards = GameState.MapData.Params.AdditionalRewards
			
			if p66 and additionalRewards and additionalRewards[GameState.DifId] then
				for i, v in additionalRewards[GameState.DifId] do
					local v95, v96 = unpack(v)
					
					if SharedHelper.RandomChance(v95) then
						local v97 = SharedHelper.DeepCopy(v96)
						ClientLoader.Modules.ServerDataHandler.ServerAwardHandler.Award(p65, v97.AwardType, v97)
					end
				end
			end
			v93 = v92
			v92 = SharedHelper.RoundTo(TowerDefense.ApplySeedsBoostsFromUnits(ClientLoader.Modules.ServerPlayerHandler.MultiplyByPlayerProperty(v92, p65, "SeedsMult"), p65), 5)
		end
		local list = {
			{ AwardType = "aw_add", DataName = "Seeds", Amount = v92 },
			{
				AwardType = "aw_message",
				MessageType = "item",
				MessageImage = "127868571094153",
				Message = "You got " .. tostring(v92) .. " Seeds!"
			}
		}
		
		if GameState.MapData.Params.RewardCurrency then
			local v99 = math.ceil(ClientLoader.Modules.ServerPlayerHandler.MultiplyByPlayerProperty(v93, p65, GameState.MapData.Params.RewardCurrency .. "Mult"))
			local rewardCurrency = ClientLoader.Config.ExtraCurrencies[GameState.MapData.Params.RewardCurrency]
			list = {
				{
					AwardType = "aw_add",
					DataName = GameState.MapData.Params.RewardCurrency,
					Amount = v99
				},
				{
					AwardType = "aw_message",
					MessageType = "item",
					Message = "You got " .. tostring(v99) .. " " .. rewardCurrency.AutoGenerate.Name .. "!",
					MessageImage = rewardCurrency.AutoGenerate.Image.Small
				}
			}
		end
		if v92 <= 0 then
			list = {}
		end
		local v100 = if not p66 then "defeat" else "victory"
		
		if p66 then
			table.insert(list, { AwardType = "aw_add", DataName = "GamesWon", Amount = 1 })
			
			if GameState.MapData.Params.IsTutorial then
				ClientLoader.Modules.ServerDataHandler.SetFlag(p65, "geraldtutorial_completed")
			end
		end
		for i, v in pairs(list) do
			local v101 = SharedHelper.DeepCopy(v)
			v101.TransactionType = "towerdefense"
			v101.TransactionItemId = "game_end_" .. v100
			ClientLoader.Modules.ServerDataHandler.ServerAwardHandler.Award(p65, v.AwardType, v101)
		end
		if p66 then
			PlayerMapProgress(p65, game.Workspace:GetAttribute("MapId"), function(p67) --[[ line: 850 ]]
				-- upvalues: SharedHelper (copy), GameState (copy)
				if SharedHelper.IsSandboxAsync() then
					return
				end
				p67.GamesWon = (p67.GamesWon or 0) + 1
				local text = "GamesWon_" .. GameState.DifId or "unknown"
				p67[text] = (p67[text] or 0) + 1
				print("NEW GAMES WON", p67.GamesWon, p67[text])
			end)
		end
		GameState.Victory = p66
		GameState.TrackGameBhv = if 0 >= v92 then ClientLoader.IsStudio else true
		ClientLoader.Modules.ServerDataHandler.TrackPlayerAction(p65, "Game", "GameEnded", GameState)
		print("Gave", p65, "game end reward")
	end
	
	function TowerDefense.ApplySeedsBoostsFromUnits(p68, p69) --[[ line: 870 ]]
		-- upvalues: ClientLoader (copy)
		local v103 = 0
		
		for i, v in ClientLoader.Modules.Units.base.GetActiveAllies(p69:GetAttribute("TeamIndex") or 1) do
			if v.Data.SeedsBoostComplete then
				v103 = v103 + v.Data.SeedsBoostComplete
			end
		end
		local v104 = v103 / 100 + 1
		print("applying extra mult", v104)
		
		return p68 * v104
	end
	
	function TowerDefense.PlayerCelebrate(p70, p71) --[[ line: 885 ]]
		local character = p70.Character
		
		if character ~= nil and character:IsDescendantOf(workspace) then
			character:AddTag("CelebrationCharacter")
			character:SetAttribute("CelebrationCharacter_Seed", math.random(1, 999999))
			character:SetAttribute("CelebrationCharacter_Type", if p71 then "Victory" else "Failure")
			character:SetAttribute("CelebrationCharacter_Expiry", workspace:GetServerTimeNow() + 10)
		end
	end
	
	game:BindToClose(function() --[[ line: 895 ]]
		-- upvalues: SharedHelper (copy), ClientLoader (copy), TowerDefense (copy), GameState (ref)
		if not SharedHelper.IsTdGameAsync() then
			return
		end
		if SharedHelper.IsSandboxAsync() or SharedHelper.IsDungeonAsync() or (SharedHelper.IsPvpAsync() or SharedHelper.IsAdminArenaAsync()) then
			return
		end
		for i, v in pairs(ClientLoader.Modules.Units.base.GetActiveEntities()) do
			if v.UnitType ~= "enemy" then
				pcall(function() --[[ line: 902 ]]
					-- upvalues: v (ref)
					v.RecordFinalAnalytics()
				end)
			end
		end
		local uTC = SharedHelper.GetUTC()
		local _pcall = pcall
		local onEnded = TowerDefense.Postgres.OnEnded
		_pcall, onEnded = _pcall(onEnded, {
			Disconnected = true,
			Victory = false,
			STDH = TowerDefense,
			GameState = GameState,
			GameVersion = if SharedHelper.IsTestingServer() or game:GetService("RunService"):IsStudio() then "testing" else "live",
			StartTime = GameState.StartTime,
			EndTime = uTC,
			IsPrivateServer = SharedHelper.IsPrivateServer(),
			MapId = GameState.MapData.ID,
			Difficulty = GameState.DifId
		})
		
		if not _pcall then
			warn(onEnded)
		end
	end)
	SharedHelper.CreateRemoteEvent("ShowGameEnd")
	local v33 = nil
	
	function TowerDefense.GameEnded(p72, p73) --[[ line: 931 ]]
		-- upvalues: GameState (ref), v33 (write), SharedHelper (copy), ClientLoader (copy), TowerDefense (copy), GameConfig (copy)
		local p73 = p73 or {}
		
		if GameState.GameEnded then
			return
		end
		GameState.GameEnded = true
		task.spawn(function() --[[ line: 936 ]]
			-- upvalues: v33 (copy), GameState (copy)
			v33(GameState.CurrentRound, true)
		end)
		local uTC = SharedHelper.GetUTC()
		
		if not GameState.StartTime then
			GameState.StartTime = uTC
		end
		GameState.RunTime = uTC - GameState.StartTime
		game.Workspace:SetAttribute("GameEndTime", uTC)
		
		if not SharedHelper.IsPvpAsync() then
			task.spawn(function() --[[ line: 951 ]]
				-- upvalues: p72 (write), ClientLoader (copy), uTC (ref), GameState (copy)
				local v116 = if p72 then "victory" else "loss"
				ClientLoader.Modules.ServerDataHandler.AnalyticsDesignEvent(game.Players:GetPlayers()[1], uTC - GameState.StartTime, "tdgame_" .. tostring(GameState.MapData.ID), tostring(GameState.DifId) .. "_" .. v116, "round_" .. tostring(GameState.CurrentRound))
				
				if GameState.AdjustedPlayTime then
					ClientLoader.Modules.ServerDataHandler.AnalyticsDesignEvent(game.Players:GetPlayers()[1], GameState.AdjustedPlayTime, "tdgame_" .. tostring(GameState.MapData.ID), tostring(GameState.DifId) .. "_" .. v116 .. "_apt", "round_" .. tostring(GameState.CurrentRound))
				end
			end)
			
			for i, v in game.Players:GetPlayers() do
				for i_1, v_1 in pairs(ClientLoader.Modules.Units.base.GetEntitiesOwnedBy(v)) do
					local ok, status = pcall(function() --[[ line: 965 ]]
						-- upvalues: v_1 (ref)
						v_1.RecordFinalAnalytics()
					end)
					
					if not ok then
						warn("RecordFinalAnalytics: " .. tostring(status))
					end
				end
			end
			if not (SharedHelper.IsDungeonAsync() or SharedHelper.IsSandboxAsync() or SharedHelper.IsAdminArenaAsync()) then
				local _pcall = pcall
				local onEnded = TowerDefense.Postgres.OnEnded
				_pcall, onEnded = _pcall(onEnded, {
					STDH = TowerDefense,
					GameState = GameState,
					GameVersion = if SharedHelper.IsTestingServer() or game:GetService("RunService"):IsStudio() then "testing" else "live",
					StartTime = GameState.StartTime,
					EndTime = uTC,
					IsPrivateServer = SharedHelper.IsPrivateServer(),
					Victory = p72,
					MapId = GameState.MapData.ID,
					Difficulty = GameState.DifId
				})
				
				if not _pcall then
					warn("Error pushing gameplay stats:", onEnded)
				end
			end
		elseif not ClientLoader.IsStudio then
			GameState.MaxReplays = 0
			GameState.UseMaxReplays = true
		end
		local v110 = if GameState.GameNumber > GameState.MaxReplays then not GameState.UseMaxReplays else true
		
		if game.Workspace:GetAttribute("CheckpointWave") and p72 then
			v110 = false
		end
		if GameState.MapData.ID == "map_tutorial" or p73.OpponentLeft then
			v110 = false
		end
		GameState.WavesCleared = TowerDefense.GetWavesCleared()
		local v111 = nil
		
		for i, v in pairs(game.Players:GetPlayers()) do
			SharedHelper.FireRemoteEvent("PlayerPickUnits", v)
			
			if SharedHelper.IsPvpAsync() then
				p72 = v:GetAttribute("TeamIndex") == p73.WinningTeam
				
				if p72 then
					if not game.Workspace:GetAttribute("ServerCreatedThroughMatchmaking") then
					else
						v111 = v
					end
					local round = game.Workspace:GetAttribute("Round") or 1
					local v113 = 0
					
					if round >= 3 and round < 10 then
						v113 = 150
					elseif round >= 10 and round < 20 then
						v113 = 300
					elseif round >= 20 and round < 30 then
						v113 = 750
					elseif round >= 30 and round < 40 then
						v113 = 1250
					elseif round >= 40 then
						v113 = 2500
					end
					if v113 > 0 then
						local v114 = math.ceil(TowerDefense.ApplySeedsBoostsFromUnits(ClientLoader.Modules.ServerPlayerHandler.MultiplyByPlayerProperty(v113, v, "SeedsMult"), v))
						
						for i_1, v_1 in pairs({
							{ AwardType = "aw_add", DataName = "Seeds", Amount = v114 },
							{
								AwardType = "aw_message",
								MessageType = "item",
								MessageImage = "127868571094153",
								Message = "You got " .. tostring(v114) .. " Seeds!"
							}
						}) do
							local v115 = SharedHelper.DeepCopy(v_1)
							v115.TransactionType = "towerdefense"
							v115.TransactionItemId = "pvp"
							ClientLoader.Modules.ServerDataHandler.ServerAwardHandler.Award(v, v_1.AwardType, v115)
						end
					else
						SharedHelper.FireRemoteEvent("ShowMessage", v, "At least 3 rounds needed for Seeds reward.", "warn")
					end
					for i_1, v_1 in pairs(GameConfig.PVP.WinDrops) do
						if SharedHelper.RandomChance(v_1.chance / 100) then
							SharedHelper.FireRemoteEvent("ShowMessage", v, "You got a special drop!", "success")
							ClientLoader.Modules.SharedTowerDefenseHandler.UnitInventoryManager.AddUnitToInventory(v, v_1.ID, { DelayedDiscovery = true, Notification = true })
						end
					end
				end
			end
			v111 = v
			TowerDefense.PlayerCelebrate(v, p72)
			SharedHelper.FireRemoteEvent("ShowGameEnd", v, {
				Victory = p72,
				Tie = p73.Tie,
				RunTime = uTC - GameState.StartTime,
				PlayerData = GameState.PlayerData,
				CanReplay = v110,
				WavesCleared = GameState.WavesCleared,
				CustomMessage = p73.OpponentLeft and "Opponent disconnected!"
			})
			TowerDefense.GiveGameEndRewad(v, p72)
			SharedHelper.FireSignal("game_end", v, p72, GameState, p73)
			continue
		end
		if SharedHelper.IsRankedPvpAsync() then
			TowerDefense.RankedPlay.UpdateELO(v111, p73.Tie, p73.LeavingPlayer)
		end
		GameState.GameFinishedEnding = true
	end
	
	local function GetLeader() --[[ line: 1110 ]]
		-- upvalues: GameState (ref)
		for i, v in pairs(GameState.PlayerOrder) do
			local v117 = game.Players:FindFirstChild(v)
			
			if v117 then
				return v117
			end
		end
		return game.Players:GetPlayers()[1]
	end
	
	SharedHelper.CreateRemoteEvent("SendEnemyQueueUpdated")
	SharedHelper.OnRemoteFunction("PVPSummonEnemy", function(p74, p75) --[[ line: 1121 ]]
		-- upvalues: SharedHelper (copy), ClientLoader (copy), GameState (ref), httpService (copy)
		if not SharedHelper.IsPvpAsync() then
			return
		end
		local item = ClientLoader.Modules.SharedItemData.GetItem(p75)
		local unitConfig = item.Params.UnitConfig
		
		if not (item and unitConfig) then
			return
		end
		if item.Params.UnitType ~= "enemy" then
			return
		end
		if not unitConfig.Cost then
			return
		end
		if (game.Workspace:GetAttribute("Round") or 0) < (unitConfig.UnlockWave or 1) then
			return false, "You can summon this enemy on wave " .. tostring(unitConfig.UnlockWave or 1) .. " or higher!"
		end
		local teamIndex = p74:GetAttribute("TeamIndex") or 1
		local v120 = GameState.EnemySendQueue[teamIndex] or {}
		
		if #v120 >= 10 then
			return false, "Max 10 enemies in queue!"
		end
		if not ClientLoader.Modules.ServerDataHandler.CheckAfford(p74, "Cash", unitConfig.Cost) then
			return false, "You don'TowerDefense have enough Cash!"
		end
		if not ClientLoader.Modules.ServerDataHandler.AddToData(p74, "Cash", -unitConfig.Cost, nil, { transactionType = "gameplay", transactionItemId = p75 }) then
			return
		end
		local TowerDefense = {}
		
		if p74:GetAttribute("TeamIndex") == 2 then
			TowerDefense.PathIndex = 1
			TowerDefense.TeamIndex = 2
		else
			TowerDefense.PathIndex = 2
			TowerDefense.TeamIndex = 1
		end
		if unitConfig.PVPOverride then
			TowerDefense.ForceHealth = unitConfig.PVPOverride.Health
			TowerDefense.ForceSpeed = unitConfig.PVPOverride.Speed
		end
		table.insert(v120, {
			p75,
			TowerDefense,
			p74,
			httpService:GenerateGUID(false),
			unitConfig.SummonAmount or 1
		})
		
		if #v120 == 1 then
			GameState.TimeUntilNextEnemyFromQueueSent[teamIndex] = unitConfig.PVPWaitAfterSummon or 2
		end
		SharedHelper.FireRemoteEvent("SendEnemyQueueUpdated", p74, v120, GameState.TimeUntilNextEnemyFromQueueSent[teamIndex])
		
		return true
	end)
	SharedHelper.CreateRemoteFunction("DeleteFromSendQueue")
	SharedHelper.OnRemoteFunction("DeleteFromSendQueue", function(p76, p77) --[[ line: 1175 ]]
		-- upvalues: SharedHelper (copy), GameState (ref), ClientLoader (copy)
		if not (SharedHelper.IsPvpAsync() or SharedHelper.IsSandboxAsync()) then
			return
		end
		local teamIndex = p76:GetAttribute("TeamIndex") or 1
		local v123 = GameState.EnemySendQueue[teamIndex] or {}
		
		for i, v in v123 do
			local v124, _, v125, v126, v127 = unpack(v)
			
			if v126 == p77 then
				local unitConfig = ClientLoader.Modules.SharedItemData.GetItem(v124).Params.UnitConfig
				
				if SharedHelper.IsPvpAsync() then
					ClientLoader.Modules.ServerDataHandler.AddToData(v125, "Cash", math.round(0.5 * unitConfig.Cost * (v127 / (unitConfig.SummonAmount or 1))), nil, { transactionType = "gameplay", transactionItemId = v124 })
				end
				table.remove(v123, i)
				
				if i == 1 and #v123 > 0 then
					GameState.TimeUntilNextEnemyFromQueueSent[teamIndex] = ClientLoader.Modules.SharedItemData.GetItem(v123[1][1]).Params.UnitConfig.PVPWaitAfterSummon or 2
				end
				SharedHelper.FireRemoteEvent("SendEnemyQueueUpdated", v125, v123, GameState.TimeUntilNextEnemyFromQueueSent[teamIndex])
				
				return true
			end
		end
	end)
	SharedHelper.InstantThread(function() --[[ line: 1216 ]]
		-- upvalues: SharedHelper (copy), TowerDefense (copy), GameState (ref), ClientLoader (copy)
		while true do
			local v128 = SharedHelper.RSWait() * TowerDefense.GetTS()
			if GameState.GameEnded then
				continue
			end
			for i, v in GameState.EnemySendQueue do
				local timeUntilNextEnemyFromQueueSent = GameState.TimeUntilNextEnemyFromQueueSent
				timeUntilNextEnemyFromQueueSent[i] = timeUntilNextEnemyFromQueueSent[i] - v128
				
				if GameState.TimeUntilNextEnemyFromQueueSent[i] <= 0 then
					local v129 = table.remove(v, 1)
					
					if v129 then
						local v130, v131, v132, v133, v134, v135 = unpack(v129)
						local teamIndex = v132:GetAttribute("TeamIndex") or 1
						local v137 = GameState.EnemySendQueue[teamIndex] or {}
						local v138 = v134 - 1
						
						if v138 > 0 then
							table.insert(GameState.EnemySendQueue[teamIndex], 1, {
								v130,
								v131,
								v132,
								v133,
								v138,
								v135
							})
						end
						if v138 > 0 then
							GameState.TimeUntilNextEnemyFromQueueSent[teamIndex] = v135 or (ClientLoader.Modules.SharedItemData.GetItem(v130).Params.UnitConfig.PVPWaitAfterSummon or 2)
						elseif #GameState.EnemySendQueue[teamIndex] > 0 then
							GameState.TimeUntilNextEnemyFromQueueSent[teamIndex] = v135 or (ClientLoader.Modules.SharedItemData.GetItem(GameState.EnemySendQueue[teamIndex][1][1]).Params.UnitConfig.PVPWaitAfterSummon or 2)
						end
						SharedHelper.FireRemoteEvent("SendEnemyQueueUpdated", v132, v137, GameState.TimeUntilNextEnemyFromQueueSent[teamIndex])
						local v139 = SharedHelper.DeepCopy(v131)
						v139.SentByPVPOpponent = true
						TowerDefense.SpawnEnemy(v130, v139)
						
						if SharedHelper.IsPvpAsync() then
							SharedHelper.FireSignal("PVPEnemySent", v132, v130)
						end
					end
				end
			end
		end
	end)
	SharedHelper.OnRemoteFunction("PauseGameplay", function(p78, p79) --[[ line: 1270 ]]
		-- upvalues: GetLeader (ref), SharedHelper (copy), GameState (ref)
		local v140 = GetLeader()
		
		if p78 ~= v140 then
			if p79 then
				SharedHelper.FireRemoteEvent("ShowMessage", p78, "Only " .. v140.DisplayName .. " can pause the game!", "warn", { SideForPhone = true })
			elseif game.Workspace:GetAttribute("GamePaused") then
				SharedHelper.FireRemoteEvent("ShowMessage", p78, "Only " .. v140.DisplayName .. " can resume the game!", "warn", { SideForPhone = true })
			elseif game.Workspace:GetAttribute("GamePauseScheduled") then
				SharedHelper.FireRemoteEvent("ShowMessage", p78, "Only " .. v140.DisplayName .. " can cancel the pause!", "warn", { SideForPhone = true })
			end
			return false
		end
		if SharedHelper.GetSubTable(GameState.MapData.Params, "CanPause") == false then
			return
		end
		if game.Workspace:GetAttribute("CanPause") == false then
			return
		end
		if p79 then
			game.Workspace:SetAttribute("GamePauseScheduled", true)
			game.Workspace:SetAttribute("CanSkipWave")
			SharedHelper.FireAllClients("ShowMessage", "Game will be paused at the start of the next wave!", "success")
		else
			if game.Workspace:GetAttribute("GamePaused") then
				SharedHelper.FireAllClients("ShowMessage", "Game will now resume!", "success")
				game.Workspace:SetAttribute("GamePaused")
			else
				SharedHelper.FireAllClients("ShowMessage", "The game pause has been canceled!", "success")
			end
			game.Workspace:SetAttribute("GamePauseScheduled")
		end
		return true
	end)
	SharedHelper.OnRemoteFunction("ChangeTickSpeed", function(p80, p81) --[[ line: 1304 ]]
		-- upvalues: GetLeader (ref), SharedHelper (copy), GameState (ref), ClientLoader (copy)
		local v141 = GetLeader()
		
		if p80 ~= v141 then
			SharedHelper.FireRemoteEvent("ShowMessage", p80, "Only " .. v141.DisplayName .. " can change this!", "warn", { SideForPhone = true })
			
			return false
		end
		if SharedHelper.IsDungeonAsync() then
			return
		end
		if SharedHelper.IsPvpAsync() then
			return
		end
		if SharedHelper.GetSubTable(GameState.MapData.Params, "CanChangeTickSpeed") == false then
			return
		end
		if not table.find({ 1, 2, 3 }, p81) then
			return
		end
		if p81 == 3 and not ClientLoader.Modules.ServerDataHandler.GetFlag(p80, "gamespeed_3") then
			ClientLoader.Modules.ServerDataHandler.ServerProductHandler.PromptGamePass(p80, "gp_gamespeed_3", "menu")
			
			return false
		end
		game.Workspace:SetAttribute("TickSpeed", p81)
		SharedHelper.FireAllClients("ShowMessage", `{p80.DisplayName} changed the speed to x{p81}`, "success")
		
		return true
	end)
	SharedHelper.OnRemoteEvent("BackToMainLobby", function(p82) --[[ line: 1330 ]]
		-- upvalues: ClientLoader (copy)
		return if game.PlaceId == 123663235715246 or game.PlaceId == 122134373786043 or game.PlaceId == 136472363167780 then ClientLoader.Modules.ServerTeleportHandler.Teleport({ p82 }, 123663235715246) else ClientLoader.Modules.ServerTeleportHandler.Teleport({ p82 }, 108533757090220)
	end)
	SharedHelper.InstantThread(function() --[[ line: 1340 ]]
		-- upvalues: SharedHelper (copy), TowerDefense (copy), collectionService (copy)
		while true do
			local v142 = SharedHelper.RSWait() * TowerDefense.GetTS()
			for i, v in collectionService:GetTagged("ContainsPlacementCooldowns") do
				for i_1, v_1 in v:GetChildren() do
					v_1.Value = v_1.Value - v142
					
					if v_1.Value <= 0 then
						v_1:Destroy()
					end
				end
			end
		end
	end)
	SharedHelper.OnRemoteFunction("PlaceUnit", function(p83, p84, p85) --[[ line: 1354 ]]
		-- upvalues: ClientLoader (copy), GameState (ref), SharedHelper (copy), TowerDefense (copy)
		local v143 = game.Workspace:GetAttribute("MapId") == "map_tutorial" and p85.NPCPlaced
		
		if not (v143 or ClientLoader.Modules.ServerToolHandler.HasTool(p83, "tl_unitplacer_" .. tostring(p84))) then
			return
		end
		local item = ClientLoader.Modules.SharedItemData.GetItem(p84)
		local unitConfig = item.Params.UnitConfig
		
		if not (item and unitConfig) then
			return
		end
		if item.Params.Internal then
			return false, "This unit can not be placed on its own."
		end
		local v145 = game.ReplicatedStorage.Models.Units[p84]
		local cF = p85.CF
		local teamIndex = p83:GetAttribute("TeamIndex") or 1
		local t_2 = {
			Owner = p83,
			TeamIndex = teamIndex,
			WasFastPlaced = p85.WasFastPlaced,
			NPCPlaced = p85.NPCPlaced
		}
		
		if unitConfig.ApplySpecialConfig then
			unitConfig.ApplySpecialConfig(t_2)
		end
		if not ClientLoader.Modules.ServerDataHandler.GetFlag(p83, "tut_item_placed") then
			ClientLoader.Modules.ServerDataHandler.SetFlag(p83, "tut_item_placed")
		end
		local activeUnits = ClientLoader.Modules.Units.base.GetActiveUnits()
		local v149 = 0
		local v150 = 0
		local baseUnit = item.Params.BaseUnit or p84
		
		for i, v in activeUnits do
			if v.Data.TeamIndex == teamIndex and not v.Data.DontCountTowardsUnitLimit and (v.BaseUnit or v.UnitId) == baseUnit then
				v150 = v150 + 1
				
				if v.Data.Owner == p83 then
					v149 = v149 + 1
				end
			end
		end
		if GameState.MapData.Params.DisabledUnits and table.find(GameState.MapData.Params.DisabledUnits, p84) then
			return false, "This unit can not be used on this map."
		end
		if p83:GetAttribute("Ghost") or p83.Character and p83.Character:GetAttribute("Downed") or not (GameState.CurrentRound or p83:GetAttribute("PlacementEnabled")) then
			return false, "You can'TowerDefense place units right now!"
		end
		if game.Workspace:GetAttribute("GamePaused") then
			return false, "You can'TowerDefense place units while the game is paused!"
		end
		if GameState.CurrentRound and GameState.CurrentRound > 5 and (GameState.PlayerData[p83.Name] and GameState.CurrentRound <= (GameState.PlayerData[p83.Name].ReconnectWave or 0)) then
			return false, "You can'TowerDefense place units this round!"
		end
		if unitConfig.MaxPlaced and not SharedHelper.IsSandboxAsync() then
			if unitConfig.SharedMax and unitConfig.MaxPlaced <= v150 then
				return false, `Max {unitConfig.MaxPlaced} units of {item.Params.Name} per team`
			end
			if unitConfig.MaxPlaced <= v149 then
				return false, `Max {unitConfig.MaxPlaced} units of {item.Params.Name} per player`
			end
		end
		if item.Params.UnitType == "unit_trap" and not SharedHelper.IsPlaceTrapsFreelyAsync() then
			local pathIndex = p85.PathIndex
			local activePath = ClientLoader.Modules.SharedTowerDefenseHandler.PathHandler.GetActivePath(pathIndex)
			local distance = activePath.GetDistance(p85.Position)
			cF = CFrame.new(activePath.GetPosition(distance), activePath.GetPosition(distance - 0.001))
			t_2.DistanceAlongPath = distance
			t_2.PathIndex = pathIndex
		else
			local v152, v153 = ClientLoader.Modules.SharedModelPlacement.IsPlacementValid(cF, v145.PrimaryPart.Size, nil, SharedHelper.GetPlayerCharacterPosition(p83), nil, p83:GetAttribute("TeamIndex"))
			
			if not v152 then
				print("No placing:", v153)
				
				return false, "You can'TowerDefense place there!"
			end
		end
		for i_1, v_1 in activeUnits do
			if not (v_1.UnitType == "enemy" or not v_1.Data.Position or SharedHelper.FlatDistance(v_1.Data.Position, cF.p) >= 1) then
				return false, "You can'TowerDefense place there!"
			end
		end
		t_2.CF = cF
		local v156 = math.min(p83:GetAttribute("PropertyTotalValue_MaxUnitsPlaced") or 20, game.Workspace:GetAttribute("ForceMaxPlacedUnits") or 9999)
		
		if p84 == "unit_timekeeper" and game.Workspace:GetAttribute("AlreadyRewind") then
			return false, `You can only use one {item.Params.Name} per game!`
		end
		if v156 <= p83:GetAttribute("UnitsPlaced") then
			return false, "You have too many units!"
		end
		if not (v143 or ClientLoader.Modules.ServerDataHandler.CheckAfford(p83, "Cash", unitConfig.Cost)) then
			return false, "You don'TowerDefense have enough Cash!"
		end
		if unitConfig.PlacementCooldown and not SharedHelper.IsSandboxAsync() then
			local workspace
			if unitConfig.IsGlobalPlacementCooldown then
				workspace = game.Workspace
				
				if workspace then
				else
					workspace = nil
				end
			else
				workspace = nil
			end
			if not workspace:FindFirstChild("PlacementCooldowns") then
				local placementCooldowns = Instance.new("Folder")
				placementCooldowns.Name = "PlacementCooldowns"
				placementCooldowns.Parent = workspace
				placementCooldowns:AddTag("ContainsPlacementCooldowns")
			end
			local text = baseUnit .. "/" .. teamIndex
			local placementCooldowns_1 = workspace:FindFirstChild("PlacementCooldowns")
			
			if placementCooldowns_1:FindFirstChild(text) then
				return false, `You can only place {item.Params.Name} every {unitConfig.PlacementCooldown} seconds`
			end
			local numberValue = Instance.new("NumberValue")
			numberValue.Name = text
			numberValue.Parent = placementCooldowns_1
			numberValue.Value = unitConfig.PlacementCooldown
		end
		if not (v143 or ClientLoader.Modules.ServerDataHandler.AddToData(p83, "Cash", -unitConfig.Cost, nil, { transactionType = "gameplay", transactionItemId = p84 })) then
			return
		end
		if not table.find(GameState.UsedUnits, p84) then
			print("New unit used!", p84)
			table.insert(GameState.UsedUnits, p84)
		end
		local v161 = ClientLoader.Modules.Units.base.CreateEntity(p84, SharedHelper.DeepCopy(t_2))
		local count = #ClientLoader.Modules.Units.base.GetEntitiesOwnedBy(p83)
		TowerDefense.ChangePlayerData(p83, function(p86) --[[ line: 1510 ]]
			-- upvalues: count (ref), cF (write)
			p86.MaxUnitsPlacedAtOnceThisGame = math.max(p86.MaxUnitsPlacedAtOnceThisGame or 0, count)
			p86.UnitPlacementPositionsThisGame = p86.UnitPlacementPositionsThisGame or {}
			table.insert(p86.UnitPlacementPositionsThisGame, cF.p)
		end)
		local currentRound = GameState.CurrentRound or 0
		
		function v161.RecordFinalAnalytics() --[[ line: 1516 ]]
			-- upvalues: GameState (copy), p83 (ref), SharedHelper (copy), v161 (ref), currentRound (ref), p84 (ref)
			local userId = GameState.Analytics[tostring(p83.UserId)]
			
			if userId then
				local v164 = SharedHelper.DeepCopy(v161.Data.StatMetrics or {})
				v164.FirstPlacedWave = currentRound
				v164.LastActiveWave = GameState.CurrentRound or 0
				v164.HighestLevel = v161.Data.Level or 1
				
				if not userId.Units[p84] then
					userId.Units[p84] = {}
				end
				table.insert(userId.Units[p84], v164)
			end
		end
		
		v161.AddToCleanup(v161.RecordFinalAnalytics)
		SharedHelper.FireSignal("UnitPlaced", p83, p84, v161.ID)
		
		if item.Params.DisplayUnitType == "Support" then
			SharedHelper.FireSignal("SupportUnitPlaced", p83, p84)
		end
		return true, v161.ID
	end)
	
	function TowerDefense.SellAllUnits(p87) --[[ line: 1553 ]]
		-- upvalues: ClientLoader (copy), TowerDefense (copy)
		for i, v in pairs(ClientLoader.Modules.Units.base.GetEntitiesOwnedBy(p87)) do
			local v165 = TowerDefense.CalculateUnitValue(p87, v)
			local unitId = v.UnitId
			v.Destroy()
			
			if v165 > 0 then
				local _ = ClientLoader.Modules.ServerDataHandler.AddToData(p87, "Cash", v165, nil, { transactionType = "gameplay", transactionItemId = unitId })
			end
		end
	end
	
	local function SellUnit(p88, p89, p90) --[[ line: 1571 ]]
		-- upvalues: ClientLoader (copy), TowerDefense (copy), SharedHelper (copy)
		local v166 = ClientLoader.Modules.Units.base.FindEntityById(p89)
		
		if not v166 then
			return
		end
		if v166.Data.Owner ~= p88 then
			return
		end
		if v166.Destroyed then
			return
		end
		if v166.Data.CanBeSold == false then
			return
		end
		if v166.Data.IsLocked and not p90 then
			return false, "You can'TowerDefense sell a locked unit!"
		end
		if p88:GetAttribute("Ghost") or p88.Character and p88.Character:GetAttribute("Downed") then
			return false, "You can'TowerDefense sell units right now!"
		end
		if game.Workspace:GetAttribute("GamePaused") then
			return false, "You can'TowerDefense sell units while the game is paused!"
		end
		local v167 = TowerDefense.CalculateUnitValue(p88, v166)
		local unitId = v166.UnitId
		v166.Destroy()
		
		if v167 > 0 then
			local _ = ClientLoader.Modules.ServerDataHandler.AddToData(p88, "Cash", v167, nil, { transactionType = "gameplay", transactionItemId = unitId })
		end
		TowerDefense.ChangePlayerData(p88, function(p91) --[[ line: 1600 ]]
			p91.UnitsSoldThisGame = (p91.UnitsSoldThisGame or 0) + 1
		end)
		SharedHelper.FireSignal("UnitSold", p88, unitId, v167)
		
		return true
	end
	
	TowerDefense.SellUnit = SellUnit
	SharedHelper.OnRemoteFunction("SellUnit", SellUnit)
	
	local function UpgradeUnit(p92, p93) --[[ line: 1612 ]]
		-- upvalues: ClientLoader (copy), TowerDefense (copy), SharedHelper (copy), GameState (ref)
		local v168 = ClientLoader.Modules.Units.base.FindEntityById(p93)
		
		if not v168 then
			return
		end
		local v169 = game.Workspace:GetAttribute("MapId") == "map_tutorial" and v168.Data.NPCPlaced
		
		if v168.Data.Owner ~= p92 then
			return
		end
		if v168.Destroyed then
			return
		end
		if v168.Data.CanBeUpgraded == false then
			return
		end
		local unitId = v168.UnitId
		local v170 = v168.Data.Level + 1
		local upgradeCost = TowerDefense.GetUpgradeCost(v168)
		
		if not v168.Data.Upgrades[v168.Data.Level] then
			return
		end
		if not v169 then
			if p92:GetAttribute("Ghost") or p92.Character and p92.Character:GetAttribute("Downed") then
				return false, "You can'TowerDefense upgrade units right now!"
			end
			if game.Workspace:GetAttribute("GamePaused") then
				return false, "You can'TowerDefense upgrade units while the game is paused!"
			end
			if not ClientLoader.Modules.ServerDataHandler.CheckAfford(p92, "Cash", upgradeCost) then
				return false, "You don'TowerDefense have enough Cash!"
			end
			if not ClientLoader.Modules.ServerDataHandler.AddToData(p92, "Cash", -upgradeCost, nil, {
				transactionType = "gameplay",
				transactionItemId = unitId .. "_upg_" .. tostring(v170)
			}) then
				return
			end
		end
		v168.AddToStatMetric("TotalSpent", upgradeCost)
		v168.SetLevel(v170)
		v168.CallIfExists("OnUpgrade", ClientLoader, SharedHelper, v168)
		
		if GameState then
			local v172 = GameState
			v172.TotalUpgrades = v172.TotalUpgrades + 1
		end
		return true, v170
	end
	
	SharedHelper.OnRemoteFunction("UpgradeUnit", UpgradeUnit)
	game:GetService("RunService").Heartbeat:Connect(function() --[[ line: 1663 ]]
		-- upvalues: ClientLoader (copy), TowerDefense (copy), UpgradeUnit (ref)
		debug.profilebegin("TD/Heartbeat/AutoUpgrade")
		
		for i, v in game.Players:GetPlayers() do
			local GameState = {}
			
			for i_1, v_1 in ClientLoader.Modules.Units.base.GetEntitiesOwnedBy(v) or {} do
				if v_1.Data.IsAutoUpgrading and v_1.Data.Level <= #v_1.Data.Upgrades then
					table.insert(GameState, { v_1.ID, v_1.Data.AutoUpgradingPriority })
				end
			end
			table.sort(GameState, function(p94, p95) --[[ line: 1673 ]]
				return p94[2] < p95[2]
			end)
			
			for i_1, v_2 in GameState do
				local v174 = ClientLoader.Modules.Units.base.FindEntityById(v_2[1])
				local _ = v174.Data.Level + 1
				
				if v174.Data.Upgrades[v174.Data.Level] and ClientLoader.Modules.ServerDataHandler.CheckAfford(v, "Cash", TowerDefense.GetUpgradeCost(v174)) then
					UpgradeUnit(v, v_2[1])
				end
			end
		end
		debug.profileend()
	end)
	SharedHelper.OnRemoteFunction("UpgradeAll", function(p96) --[[ line: 1692 ]]
		-- upvalues: ClientLoader (copy), TowerDefense (copy), UpgradeUnit (ref)
		for i, v in ClientLoader.Modules.Units.base.GetEntitiesOwnedBy(p96) or {} do
			local _ = v.Data.Level + 1
			
			if v.Data.Upgrades[v.Data.Level] and ClientLoader.Modules.ServerDataHandler.CheckAfford(p96, "Cash", TowerDefense.GetUpgradeCost(v)) then
				UpgradeUnit(p96, v.ID)
			end
		end
		return true
	end)
	SharedHelper.OnRemoteFunction("SellAll", function(p97) --[[ line: 1708 ]]
		-- upvalues: ClientLoader (copy), SellUnit (ref)
		for i, v in ClientLoader.Modules.Units.base.GetEntitiesOwnedBy(p97) or {} do
			SellUnit(p97, v.ID)
		end
		return true
	end)
	SharedHelper.OnRemoteFunction("LockUnit", function(p98, p99) --[[ line: 1717 ]]
		-- upvalues: ClientLoader (copy)
		local v175 = ClientLoader.Modules.Units.base.FindEntityById(p99)
		
		if not v175 then
			return
		end
		if v175.Data.Owner ~= p98 then
			return
		end
		if v175.Destroyed then
			return
		end
		local v176 = not (v175.Data.IsLocked or false)
		v175.Data.IsLocked = v176
		
		return true, v176
	end)
	SharedHelper.OnRemoteFunction("ToggleAutoUpgrade", function(p100, p101) --[[ line: 1731 ]]
		-- upvalues: ClientLoader (copy)
		local v177 = ClientLoader.Modules.Units.base.FindEntityById(p101)
		
		if not v177 then
			return
		end
		if v177.Data.Owner ~= p100 then
			return
		end
		if v177.Destroyed then
			return
		end
		if v177.Data.CanBeUpgraded == false then
			return
		end
		local v178 = not (v177.Data.IsAutoUpgrading or false)
		v177.Data.AutoUpgradingPriority = 1
		v177.Data.IsAutoUpgrading = v178
		
		return true, v178
	end)
	SharedHelper.OnRemoteFunction("ToggleAutoUpgradePriority", function(p102, p103) --[[ line: 1747 ]]
		-- upvalues: ClientLoader (copy)
		local v179 = ClientLoader.Modules.Units.base.FindEntityById(p103)
		
		if not v179 then
			return
		end
		if v179.Data.Owner ~= p102 then
			return
		end
		if v179.Destroyed then
			return
		end
		if v179.Data.CanBeUpgraded == false then
			return
		end
		local v180 = (v179.Data.AutoUpgradingPriority or 1) + 1
		
		if v180 > 6 then
			v180 = 1
		end
		v179.Data.AutoUpgradingPriority = v180
		
		return true, v180
	end)
	SharedHelper.OnRemoteFunction("ActivateUnitAbility", function(p104, p105) --[[ line: 1766 ]]
		-- upvalues: ClientLoader (copy), TowerDefense (copy), SharedHelper (copy)
		local v181 = ClientLoader.Modules.Units.base.FindEntityById(p105)
		
		if not v181 then
			return
		end
		if v181.Data.Owner ~= p104 then
			return
		end
		if v181.Destroyed then
			return
		end
		local playerTriggeredAbility = v181.Config.PlayerTriggeredAbility
		
		if not playerTriggeredAbility then
			return false
		end
		if not v181.Data.PTAReady then
			return false, "Ability not ready!"
		end
		local unitId = v181.UnitId
		
		if p104:GetAttribute("Ghost") or p104.Character and p104.Character:GetAttribute("Downed") then
			return false, "You can'TowerDefense use this right now!"
		end
		local abilityCost = TowerDefense.GetAbilityCost(p104, v181)
		
		if not SharedHelper.IsSandboxAsync() then
			if not ClientLoader.Modules.ServerDataHandler.CheckAfford(p104, "Cash", abilityCost) then
				return false, "You don'TowerDefense have enough Cash!"
			end
			if not ClientLoader.Modules.ServerDataHandler.AddToData(p104, "Cash", -abilityCost, nil, {
				transactionType = "gameplay",
				transactionItemId = unitId .. "_ability"
			}) then
				return
			end
		end
		local v183 = playerTriggeredAbility.ServerCall(ClientLoader, SharedHelper, v181)
		v181.AddToStatMetric("TotalSpent", abilityCost)
		v181.AddToStatMetric("AbilityUsed", 1)
		v181.Data.AbilityUsedCount = (v181.Data.AbilityUsedCount or 0) + 1
		SharedHelper.FireSignal("UnitAbilityUsed", p104, unitId)
		v181.ResetPTA()
		
		return true, v183
	end)
	local v37 = false
	SharedHelper.OnRemoteFunction("TDTutorialStep", function(p106, p107, p108) --[[ line: 1810 ]]
		-- upvalues: ClientLoader (copy), v37 (write), GameState (ref)
		if type(p107) ~= "number" then
			return
		end
		if p107 < 0 or p107 > 20 then
			return
		end
		local v184 = math.floor(p107)
		game.Workspace:SetAttribute("TutorialStep", v184)
		ClientLoader.Modules.ServerDataHandler.AnalyticsOnboardingStep(p106, 2 + v184, "tutorialstep_" .. tostring(v184))
		
		if p108 then
			ClientLoader.Modules.ServerDataHandler.SetFlag(p106, "geraldtutorial_show_lobby2")
			
			if v184 == 4 and not v37 and (GameState.MapData.ID == "map_tutorial" and GameState.WaveCount <= GameState.CurrentRound) then
				v37 = true
				ClientLoader.Modules.SharedTowerDefenseHandler.UnitInventoryManager.AddUnitToInventory(p106, "unit_palm_tree", { DelayedDiscovery = true, Notification = true })
			end
		end
		if v184 >= 7 then
			ClientLoader.Modules.ServerDataHandler.SetFlag(p106, "geraldtutorial_completed_lobby2")
		end
	end)
	
	function TowerDefense.GiveStarterCash(p109) --[[ line: 1830 ]]
		-- upvalues: GameState (ref), ClientLoader (copy), SharedHelper (copy), TowerDefense (copy), httpService (copy)
		if not GameState.WavesStarted then
			return
		end
		if GameState.MapData.Params.IsTutorial then
			ClientLoader.Modules.ServerDataHandler.AnalyticsOnboardingStep(p109, 2, "started_tutorial_game")
		else
			ClientLoader.Modules.ServerDataHandler.AnalyticsOnboardingStep(p109, 12, "started_td_game")
			ClientLoader.Modules.ServerDataHandler.SetFlag(p109, "geraldtutorial_completed_lobby2")
		end
		local difId = GameState.MapData.Params.StartingCash and GameState.MapData.Params.StartingCash[GameState.DifId]
		local cash = nil
		
		if not (SharedHelper.IsDungeonAsync() or GameState.MapId == "map_halloween_event") then
			if GameState.PlayerData[p109.Name] and GameState.PlayerData[p109.Name].Cash then
				cash = GameState.PlayerData[p109.Name].Cash
				TowerDefense.ChangePlayerData(p109, function(p110) --[[ line: 1845 ]]
					-- upvalues: GameState (copy)
					p110.ReconnectWave = GameState.CurrentRound
				end)
			else
				TowerDefense.ChangePlayerData(p109, function(p111) --[[ line: 1849 ]]
					p111.ReconnectWave = nil
				end)
			end
		end
		if cash then
			difId = cash
		end
		if not difId then
			local difEasy
			warn("No starting cash set for " .. GameState.DifId .. "! GameState MapData Params blob: " .. httpService:JSONEncode(GameState.MapData.Params))
			
			if GameState.MapData.Params.StartingCash then
				difEasy = GameState.MapData.Params.StartingCash.dif_easy
				
				if not difEasy then
				end
				difId = difEasy
			end
			difEasy = 500
		end
		if not GameState.MapData.Params.IsTutorial and ClientLoader.FORCE_START_CASH then
			difId = ClientLoader.FORCE_START_CASH
		end
		difId = math.floor(difId * TowerDefense.GetModifierValue("gameplay", "StartingCashMult"))
		task.spawn(function() --[[ line: 1868 ]]
			-- upvalues: ClientLoader (copy), p109 (ref), difId (write), SharedHelper (copy), GameState (copy)
			ClientLoader.Modules.ServerDataHandler.WaitPlayerData(p109)
			ClientLoader.Modules.ServerDataHandler.ChangeData(p109, "Cash", difId)
			ClientLoader.Modules.ServerDataHandler.AddToData(p109, "GamesPlayed", 1)
			SharedHelper.FireSignal("game_start", p109, GameState)
		end)
	end
	
	local WaveCounter = 0
	
	local function SetWaveDescription(value, p112) --[[ line: 1878 ]]
		-- upvalues: WaveCounter (write), SetWaveDescription (ref)
		WaveCounter = WaveCounter + 1
		local v186 = WaveCounter
		
		if p112 == 0 then
			return SetWaveDescription()
		end
		game.Workspace:SetAttribute("WaveDescription", value)
		game.Workspace:SetAttribute("WaveDescriptionData")
		
		if p112 then
			task.delay(p112, function() --[[ line: 1889 ]]
				-- upvalues: v186 (ref), WaveCounter (copy), SetWaveDescription (copy)
				if v186 ~= WaveCounter then
					return
				end
				SetWaveDescription()
			end)
		end
	end
	
	TowerDefense.SetWaveDescription = SetWaveDescription
	
	function TowerDefense.SetWaveDescriptionData(value) --[[ line: 1897 ]]
		-- upvalues: WaveCounter (write), SetWaveDescription (ref), SharedHelper (copy)
		WaveCounter = WaveCounter + 1
		local _ = WaveCounter
		SetWaveDescription()
		
		if value.Countdown then
			value.CountUntil = SharedHelper.GetUTC() + value.Countdown
		end
		game.Workspace:SetAttribute("WaveDescriptionData", game:GetService("HttpService"):JSONEncode(value))
	end
	
	local function SendWarningMessage(p113) --[[ line: 1911 ]]
		-- upvalues: ClientLoader (copy), SharedHelper (copy)
		ClientLoader.Modules.ServerChatHandler.CreateChatMessage(p113, {
			SpeakerName = "Endless",
			ExtraData = {
				NameColor = Color3.fromRGB(193, 129, 0),
				ChatColor = Color3.fromRGB(255, 170, 0)
			}
		})
		SharedHelper.FireAllClients("ShowMessage", p113, "warn")
	end
	
	local v41 = false
	local v42 = true
	
	local _ = function() --[[ line: 1925 | named "InitEndlessLeaderboard" ]]
		-- upvalues: v41 (write), ClientLoader (copy), SharedHelper (copy), v42 (write), SendWarningMessage (ref), GameState (ref)
		if v41 then
			return
		end
		v41 = true
		ClientLoader.BindToLoadedModules(function() --[[ line: 1928 ]]
			-- upvalues: SharedHelper (copy), ClientLoader (copy), v42 (copy), SendWarningMessage (copy)
			task.spawn(function() --[[ line: 1929 ]]
				-- upvalues: SharedHelper (copy), ClientLoader (copy), v42 (copy), SendWarningMessage (copy)
				if SharedHelper.IsTestingServer() then
					return
				end
				while #game.Players:GetPlayers() < 1 do
					task.wait(1)
				end
				task.wait(10)
				local weekly = ClientLoader.Modules.ServerDataHandler.ServerLeaderboardsHandler.LeaderboardManager.TimeUntilLeaderboardReset("Weekly")
				
				if weekly > 601200 then
					v42 = false
					game.Workspace:SetAttribute("EndlessLDBDisabled", "fast")
					SendWarningMessage("This week's endless leaderboard has not opened yet! Progress will NOT be saved for this run!")
					
					return
				end
				SharedHelper.Countdown(weekly - 300, nil, function(p114) --[[ line: 1941 ]]
					-- upvalues: v42 (copy), SendWarningMessage (copy), SharedHelper (copy)
					if p114 <= 0 then
						v42 = false
						game.Workspace:SetAttribute("EndlessLDBDisabled", "end")
						SendWarningMessage("This week's endless leaderboard has closed! Further progress will NOT be saved!")
						
						return
					end
					SendWarningMessage("This week's endless leaderboard will close in " .. SharedHelper.CurrencyTextFormat(p114, "hours", { desp = " and " }) .. "! Hurry!")
				end)
			end)
		end, "EndlessLeaderboard - " .. GameState.MapId)
	end
	
	local endlessRewards = TowerDefense.EndlessRewards
	local v43 = -1
	local v44 = -1
	
	local function SetNewEndlessRecord(value, p115) --[[ line: 1966 ]]
		-- upvalues: GameState (ref), SharedHelper (copy), v43 (write), v42 (write), v44 (write), TowerDefense (copy), ClientLoader (copy), endlessRewards (ref)
		if not GameState.DifficultyData then
			return
		end
		if not GameState.DifficultyData.Params.IsEndless then
			return
		end
		if SharedHelper.IsSandboxAsync() then
			return
		end
		v43 = math.max(value, v43)
		local text = "MWE_" .. GameState.MapId
		
		if v42 and (v44 < value or p115) then
			v44 = math.max(v44, value)
			local t_2 = {}
			
			for i in pairs(GameState.UserIds) do
				table.insert(t_2, tostring(i))
			end
			task.spawn(function() --[[ line: 1980 ]]
				-- upvalues: TowerDefense (copy), GameState (copy), value (ref), t_2 (ref)
				TowerDefense.Postgres.SubmitEndlessScore(GameState.MapId, value, t_2)
			end)
		end
		local uTC = SharedHelper.GetUTC()
		
		for i, v in pairs(GameState.UserIds) do
			local i = tonumber(i)
			task.spawn(function() --[[ line: 1988 ]]
				-- upvalues: i (write), v42 (copy), ClientLoader (copy), text (ref), value (ref), uTC (ref), GameState (copy)
				local v191 = game.Players:GetPlayerByUserId(i)
				
				if v191 then
					if v42 then
						ClientLoader.Modules.ServerDataHandler.ChangeData(v191, text, value)
					end
					ClientLoader.Modules.ServerDataHandler.AnalyticsDesignEvent(v191, uTC - GameState.StartTime, "tdgame_" .. GameState.MapData.ID, GameState.DifId .. "_wave_reached", "round_" .. tostring(value))
				end
			end)
		end
		return endlessRewards.Give(TowerDefense, GameState, value)
	end
	
	local function PreloadWaveEnemyAnimations(p116) --[[ line: 2009 ]]
		-- upvalues: ClientLoader (copy), SharedHelper (copy)
		if not p116 then
			return
		end
		for i, v in pairs(p116) do
			local item = ClientLoader.Modules.SharedItemData.GetItem(v[1])
			pcall(function() --[[ line: 2015 ]]
				-- upvalues: item (ref), SharedHelper (copy), ClientLoader (copy)
				for i, v in pairs(item.Params.UnitConfig.Animations) do
					if i ~= "Attack" or SharedHelper.IsDungeonAsync() then
						ClientLoader.Modules.SharedContentProvider.AddToPreload("animation", v)
					end
				end
			end)
		end
	end
	
	local function getWaveInfo(p117, p118) --[[ line: 2026 ]]
		-- upvalues: GameState (ref)
		return if not p117[p118] and GameState.DifficultyData.Params.IsEndless then p117[p118] else GameState.MapData.Params.GenerateEndlessWave(p118)
	end
	
	function TowerDefense.SumWavesHP(p119) --[[ line: 2035 ]]
		-- upvalues: ClientLoader (copy)
		local function _(p120) --[[ line: 2036 | named "getEnemyHP" ]]
			-- upvalues: ClientLoader (copy)
			local item = ClientLoader.Modules.SharedItemData.GetItem(p120)
			
			return tonumber(item and (item.Params and (item.Params.UnitConfig and (item.Params.UnitConfig.MaxHealth or 0)))) or 0
		end
		
		local v193 = 0
		local v194 = 0
		local TowerDefense = {}
		
		for i, v in ipairs(if p119 then nil else {}) do
			local v196 = 0
			
			for i_1, v_1 in ipairs(v or {}) do
				local v197 = tonumber(v_1[2]) or 0
				local v198 = v_1[3]
				local v199 = tonumber(v198 and v198.Health)
				
				if v199 then
					v194 = v194 + v197
					
					if v199 > 0 and v197 > 0 then
						v196 = v196 + v199 * v197
					end
				end
				local maxHealth
				local item = ClientLoader.Modules.SharedItemData.GetItem(v_1[1])
				
				if item and item.Params and item.Params.UnitConfig then
					maxHealth = item.Params.UnitConfig.MaxHealth
					
					if not maxHealth then
					end
					v199 = tonumber(maxHealth) or 0
				end
				maxHealth = 0
			end
			TowerDefense[i] = v196
			v193 = v193 + v196
		end
		return v193, v193 / v194
	end
	
	local function StartWaves(p121) --[[ line: 2068 ]]
		-- upvalues: GameState (ref), IsPlayerReady (copy), SharedHelper (copy), ClientLoader (copy), TowerDefense (copy), PreloadWaveEnemyAnimations (ref), getWaveInfo (ref), SetNewEndlessRecord (write), endlessRewards (ref), WaveCounter (write), SetWaveDescription (ref), timeEffectsModule (copy), replicatedStorageService (copy)
		if GameState.WavesStarted then
			return
		end
		while not IsPlayerReady do
			wait()
		end
		GameState.WavesStarted = true
		GameState.TotalEnemiesScheduled = 0
		local gameNumber = GameState.GameNumber
		local skipEnableTime = GameState.MapData.Params.SkipEnableTime or 20
		local t_2 = {}
		
		for i = 1, game.Workspace:WaitForChild("Map"):GetAttribute("Paths") or 1 do
			table.insert(t_2, i)
		end
		local forceDifficulty = GameState.ForceDifficulty or if not GameState.Votes.Difficulty then nil else GameState.Votes.Difficulty.Winner
		GameState.DifId = forceDifficulty
		print("Starting game with difficulty", forceDifficulty)
		
		local function ResetBaseHP() --[[ line: 2094 ]]
			game.Workspace:SetAttribute("BaseHP", 250)
			game.Workspace:SetAttribute("MaxBaseHP", 250)
			game.Workspace:SetAttribute("BaseHP_1", 250)
			game.Workspace:SetAttribute("MaxBaseHP_1", 250)
			game.Workspace:SetAttribute("BaseHP_2", 250)
			game.Workspace:SetAttribute("MaxBaseHP_2", 250)
		end
		
		GameState.StartTime = SharedHelper.GetUTC()
		game.Workspace:SetAttribute("GameStartTime", GameState.StartTime)
		ClientLoader.Modules.ServerDataHandler.AnalyticsDesignEvent(game.Players:GetPlayers()[1], 1, "tdgame_" .. GameState.MapData.ID, GameState.DifId, "start")
		local item = ClientLoader.Modules.SharedItemData.GetItem(forceDifficulty)
		GameState.DifficultyData = item
		
		local v207 = function() --[[ line: 2112 ]]
			-- upvalues: GameState (copy), forceDifficulty (ref)
			local TowerDefense = {}
			
			if GameState.MapData.Params.CustomDifficultyMultipliers then
				TowerDefense = GameState.MapData.Params.CustomDifficultyMultipliers[forceDifficulty] or {}
			end
			if TowerDefense.ByWave then
				local byWave = TowerDefense.ByWave
				
				for i = #byWave, 1, -1 do
					if byWave[i].MinWave <= (GameState.CurrentRound or 0) then
						TowerDefense = byWave[i].Multipliers
						
						return TowerDefense
					end
				end
			end
			return TowerDefense
		end
		
		if GameState.MapData.Params.CustomDifficultyLighting then
			local v208 = GameState.MapData.Params.CustomDifficultyLighting[forceDifficulty] or "default"
			
			if not GameState.LoadedLighting then
				GameState.LoadedLighting = "default"
			end
			if GameState.LoadedLighting ~= v208 then
				GameState.LoadedLighting = v208
				local v209 = if v208 ~= "default" then game.Workspace.Map:FindFirstChild("LightingSettings_" .. v208) else game.Workspace.Map:FindFirstChild("LightingSettings")
				
				if v209 then
					TowerDefense.LightingSerializer.LoadSmooth(v209)
				else
					warn("Lighting folder not found: " .. tostring(v208))
				end
			end
		end
		for i_1, v in pairs(GameState.PlayerData) do
			v.Cash = nil
		end
		for i_1, v_1 in pairs(game.Players:GetPlayers()) do
			TowerDefense.GiveStarterCash(v_1)
		end
		SharedHelper.FireAllClients("StopDifficultyVote")
		SharedHelper.InstantThread(function() --[[ line: 2167 ]]
			-- upvalues: GameState (copy), TowerDefense (copy), SharedHelper (copy), ResetBaseHP (ref), p121 (ref), PreloadWaveEnemyAnimations (copy), getWaveInfo (copy), SetNewEndlessRecord (copy), endlessRewards (copy), v207 (ref), ClientLoader (copy), WaveCounter (copy), SetWaveDescription (copy), forceDifficulty (ref), t_2 (ref), item (ref), gameNumber (ref), timeEffectsModule (copy), skipEnableTime (ref), replicatedStorageService (copy)
			local name = GameState.MapData.Params.Name
			local v211 = nil
			local v212 = nil
			
			local function loadWaves() --[[ line: 2172 ]]
				-- upvalues: v211 (write), GameState (copy), v212 (write), TowerDefense (copy), SharedHelper (copy), name (ref)
				v211 = GameState.MapData.Params["Waves_" .. GameState.DifId] or (CallGameModeFunction("GetWaves", GameState) or {})
				v212 = GameState.MapData.Params["WaveConfig_" .. GameState.DifId] or {}
				GameState.CurrentRound = 0
				GameState.WavesCleared = nil
				local v250, v251 = TowerDefense.SumWavesHP(v211)
				GameState.TotalWavesHP = v250
				GameState.TotalAverageHP = v251
				GameState.VictorySeedsReward = if SharedHelper.IsDungeonAsync() and not GameState.DifficultyData.Params.IsEndless then GameState.MapData.Params.Rewards[GameState.DifId][GameState.CurrentLevel] else GameState.MapData.Params.Rewards[GameState.DifId]
				game.Workspace:SetAttribute("MapName", name)
				game.Workspace:SetAttribute("Difficulty", GameState.DifId)
				
				if GameState.MapData.Params.DisplayWaveCount then
					game.Workspace:SetAttribute("DisplayMaxRound", GameState.MapData.Params.DisplayWaveCount)
				end
				if GameState.DifficultyData.Params.IsEndless then
					game.Workspace:SetAttribute("MaxRound", "inf")
					game.Workspace:SetAttribute("ForceMaxPlacedUnits", 20)
				else
					game.Workspace:SetAttribute("MaxRound", #v211)
					GameState.MaxRound = #v211
				end
				GameState.TotalEnemiesScheduled = 0
				GameState.EnemiesDied = 0
				game.Workspace:SetAttribute("EnemiesDied", 0)
				game.Workspace:SetAttribute("EnemiesLeft", 0)
			end
			
			local function Cutscene() --[[ line: 2209 ]]
				-- upvalues: GameState (copy), SharedHelper (copy)
				if GameState.MapData.Params.CamCutscene and not game.Workspace:GetAttribute("PlayMapCutscene") then
					game.Workspace:SetAttribute("DifficultyCutsceneDisplay", GameState.DifId)
					game.Workspace:SetAttribute("PlayMapCutscene", true)
					SharedHelper.FireAllClients("PlayCutscene", "map")
					local v252 = false
					local TowerDefense = {}
					SharedHelper.OnRemoteEvent("SkipMapEntryCutscene", function(p122) --[[ line: 2220 ]]
						-- upvalues: TowerDefense (ref), v252 (write)
						if table.find(TowerDefense, p122.Name) then
							return
						end
						table.insert(TowerDefense, p122.Name)
						
						for i, v in pairs(game.Players:GetPlayers()) do
							if not table.find(TowerDefense, v.Name) then
								return
							end
						end
						v252 = true
					end)
					local v254 = 5
					local ok, status = pcall(function() --[[ line: 2235 ]]
						-- upvalues: SharedHelper (copy), GameState (copy), v254 (write)
						local replicatedStorage = SharedHelper.FindFirstChild(game.ReplicatedStorage, "Cutscenes", "MoonAnimator2Saves", GameState.MapData.Params.CamCutscene) or SharedHelper.FindFirstChild(game.ServerStorage, "Cutscenes", "MoonAnimator2Saves", GameState.MapData.Params.CamCutscene)
						
						if not replicatedStorage then
							return
						end
						v254 = game:GetService("HttpService"):JSONDecode(replicatedStorage.Value).Information.Length / (replicatedStorage:GetAttribute("FPS") or 60)
					end)
					
					if not ok then
						warn("Error getting animation length: " .. tostring(status))
					end
					v254 = v254 + 2
					local v255 = 0
					while v254 > 0 do
						local v256 = task.wait(0.5)
						v255 = v255 + v256
						v254 = if v252 then 0 else v254 - v256
					end
					print("Cutscene finished for clients!", v255)
					game.Workspace:SetAttribute("MapCutsceneCompleted", true)
				end
			end
			
			loadWaves()
			while true do
				ResetBaseHP()
				local v215 = SharedHelper.DeepCopy(v211)
				local v216 = if GameState.DifficultyData.Params.IsEndless then 1e999 else #v215
				local p121_1 = p121 or 0
				while p121_1 < v216 do
					local p121_1 = p121_1 + 1
					local jumpWaves = game.Workspace:GetAttribute("JumpWaves") or 0
					
					if jumpWaves ~= 0 then
						if jumpWaves < 0 then
							p121_1 = p121_1 + jumpWaves - 1
							game.Workspace:SetAttribute("JumpWaves", 0)
						else
							game.Workspace:SetAttribute("JumpWaves", jumpWaves - 1)
						end
					end
					local v219 = v215
					local v220 = p121_1
					local v221 = if v219[v220] or not GameState.DifficultyData.Params.IsEndless then v219[v220] else GameState.MapData.Params.GenerateEndlessWave(v220)
					
					if GameState.GameEnded then
						return
					end
					PreloadWaveEnemyAnimations(v221)
					PreloadWaveEnemyAnimations(getWaveInfo(v215, p121_1 + 1))
					SharedHelper.FireSignal("wave_reached", p121_1, GameState)
					SetNewEndlessRecord(p121_1)
					
					if GameState.DifficultyData.Params.IsEndless and p121_1 % 10 == 1 then
						local v222 = endlessRewards.SumSeeds(p121_1, p121_1 + 9, GameState.MapData)
						
						if v222 then
							local list = { v221 }
							
							for i = p121_1 + 1, p121_1 + 9 do
								local v224 = v215
								table.insert(list, if v224[i] or not GameState.DifficultyData.Params.IsEndless then v224[i] else GameState.MapData.Params.GenerateEndlessWave(i))
							end
							local v225 = GameState
							local v226 = GameState
							local v227, v228 = TowerDefense.SumWavesHP(list)
							v225.TotalWavesHP = v227
							v226.TotalAverageHP = v228
							GameState.VictorySeedsReward = v222
						end
					end
					GameState.CurrentRound = p121_1
					
					if v216 < 999999 then
						GameState.WaveCount = v216
					end
					game.Workspace:SetAttribute("MapName", name)
					game.Workspace:SetAttribute("Round", p121_1)
					local v229 = v207()
					
					if game.Workspace:GetAttribute("GamePauseScheduled") then
						while game.Workspace:GetAttribute("GamePauseScheduled") and #ClientLoader.Modules.Units.base.GetActiveEnemies({ GetAll = true }) ~= 0 do
							task.wait(1)
						end
						if game.Workspace:GetAttribute("GamePauseScheduled") then
							game.Workspace:SetAttribute("GamePauseScheduled")
							game.Workspace:SetAttribute("GamePaused", true)
							SharedHelper.FireAllClients("ShowMessage", "The game is now paused!", "success")
							WaveCounter = WaveCounter + 1
							local _ = WaveCounter
							game.Workspace:SetAttribute("WaveDescription", "Game paused!")
							game.Workspace:SetAttribute("WaveDescriptionData")
							while game.Workspace:GetAttribute("GamePaused") do
								wait(1)
							end
							SetWaveDescription()
						end
					end
					if GameState.MapData.Params.CustomWaveTitles and GameState.MapData.Params.CustomWaveTitles[p121_1] then
						local v230 = GameState.MapData.Params.CustomWaveTitles[p121_1]
						WaveCounter = WaveCounter + 1
						local _ = WaveCounter
						game.Workspace:SetAttribute("WaveDescription", v230)
						game.Workspace:SetAttribute("WaveDescriptionData")
					end
					CallGameModeFunction("WaveReached", p121_1, GameState)
					
					if v212["Wave_" .. tostring(p121_1)] then
						for i_1, v in pairs(v212["Wave_" .. tostring(p121_1)].Events or {}) do
							if v.EventType == "PlayerMessage" then
								task.delay(v.TimeDelay or 0.5, function() --[[ line: 2377 ]]
									-- upvalues: SharedHelper (copy), v (ref)
									SharedHelper.FireAllClients("ShowMessage", v.Message, v.MessageType, { SideForPhone = true })
								end)
							elseif v.EventType == "Call" then
								v.Call()
							end
						end
					end
					local waveEvents = SharedHelper.GetSubTable(GameState.MapData.Params, "WaveEvents", forceDifficulty, p121_1, "Before")
					
					if game.Workspace:GetAttribute("CheckpointWaveRestarted") then
						game.Workspace:SetAttribute("CheckpointWaveRestarted")
						waveEvents = nil
					end
					if waveEvents then
						waveEvents({ SetWaveDescription = SetWaveDescription }, GameState)
					end
					local v232 = t_2
					
					if game.Workspace:GetAttribute("AllowedPaths") then
						task.wait()
						v232 = {}
						
						for i_1, v in pairs(string.split(game.Workspace:GetAttribute("AllowedPaths"), ";")) do
							table.insert(v232, tonumber(v))
						end
					end
					local v233 = (p121_1 - 1) % #v232 + 1
					local v234 = v232[v233]
					
					local function _() --[[ line: 2415 | named "NextPath" ]]
						-- upvalues: v233 (write), v232 (write), v234 (write)
						v233 = v233 + 1
						
						if #v232 < v233 then
							v233 = 1
						end
						v234 = v232[v233]
					end
					
					local v235 = 0
					local count = #game.Players:GetPlayers()
					local v237 = 1
					
					if count == 3 then
						v237 = 1.5
					elseif count == 4 then
						v237 = 2
					elseif count > 4 then
						v237 = count / 2
					end
					if GameState.MapData.Params.CustomSpawnMultPerPlayerCount then
						v237 = GameState.MapData.Params.CustomSpawnMultPerPlayerCount[count] or v237
					end
					v237 = v237 * TowerDefense.GetModifierValue("gameplay", "SpawnMult")
					local v238 = SharedHelper.DeepCopy(v229.EnemyConfig or item.Params.EnemyConfig)
					
					if GameState.MapData.Params.GeneralSpeedMult then
						if v238.ForceSpeed then
							v238.ForceSpeed = (v238.ForceSpeed or 1) * GameState.MapData.Params.GeneralSpeedMult
						end
						if v238.SpeedMult then
							v238.SpeedMult = (v238.SpeedMult or 1) * GameState.MapData.Params.GeneralSpeedMult
						end
					end
					if GameState.MapData.Params.EnemyScale then
						v238.ForceScale = GameState.MapData.Params.EnemyScale
					end
					if v238 then
						v237 = v237 * require(script:WaitForChild("GetSpawnMultRamp"))(v238, p121_1)
					end
					for i_1, v in pairs(v221) do
						v235 = v235 + math.ceil(v[2] * v237)
					end
					local v239 = 0
					
					for i_2, v_1 in pairs(v221) do
						v239 = v239 + v_1[2] * ClientLoader.Modules.SharedItemData.GetItem(v_1[1]).Params.UnitConfig.MaxHealth
					end
					v239 = math.max(100, SharedHelper.RoundTo(v239 / 9, 25))
					GameState.TotalEnemiesScheduled = GameState.TotalEnemiesScheduled + v235
					game.Workspace:SetAttribute("EnemiesLeft", GameState.TotalEnemiesScheduled)
					
					if p121_1 == 1 then
						Cutscene()
					end
					TowerDefense.Wait(GameState.MapData.Params.BeforeSpawnDelay or 3)
					
					if p121_1 == 1 and not ClientLoader.FAST_START and not GameState.MapData.Params.FastStart then
						for i_3 = GameState.MapData.Params.CountdownBeforeFirstWave or 5, 1, -1 do
							local v240 = tostring(i_3)
							WaveCounter = WaveCounter + 1
							local v241 = WaveCounter
							game.Workspace:SetAttribute("WaveDescription", v240)
							game.Workspace:SetAttribute("WaveDescriptionData")
							task.delay(5, function() --[[ line: 1889 ]]
								-- upvalues: v241 (ref), WaveCounter (copy), SetWaveDescription (copy)
								if v241 ~= WaveCounter then
									return
								end
								SetWaveDescription()
							end)
							task.wait(1)
						end
						for i_4, v_2 in pairs(ClientLoader.Modules.Units.base.GetActiveEntities()) do
							if v_2.UnitType == "enemy" then
								v_2.Destroy()
							end
						end
						WaveCounter = WaveCounter + 1
						local v242 = WaveCounter
						game.Workspace:SetAttribute("WaveDescription", "Enemies incoming!")
						game.Workspace:SetAttribute("WaveDescriptionData")
						task.delay(5, function() --[[ line: 1889 ]]
							-- upvalues: v242 (ref), WaveCounter (copy), SetWaveDescription (copy)
							if v242 ~= WaveCounter then
								return
							end
							SetWaveDescription()
						end)
					end
					GameState.RoundsActive = true
					local v243 = false
					local v244 = false
					local v245 = false
					local _ = p121_1
					task.spawn(function() --[[ line: 2531 ]]
						-- upvalues: v221 (ref), ClientLoader (copy), v229 (ref), item (copy), SharedHelper (copy), GameState (copy), v234 (write), TowerDefense (copy), v237 (write), gameNumber (copy), timeEffectsModule (copy), count (ref), v233 (write), v232 (write), v243 (write)
						for i, v in pairs(v221) do
							local v261
							local item_1 = ClientLoader.Modules.SharedItemData.GetItem(v[1])
							local gangCount = v229.GangCount or item.Params.GangCount
							local v260 = gangCount
							local _ = nil
							
							if SharedHelper.IsDungeonAsync() then
								v261 = SharedHelper.DeepCopy(v229.EnemyConfig or item.Params.EnemyConfig)
								
								if GameState.MapData.Params.GeneralSpeedMult then
									if v261.ForceSpeed then
										v261.ForceSpeed = (v261.ForceSpeed or 1) * GameState.MapData.Params.GeneralSpeedMult
									end
									if v261.SpeedMult then
										v261.SpeedMult = (v261.SpeedMult or 1) * GameState.MapData.Params.GeneralSpeedMult
									end
								end
								if v[3] then
									v261.ForceSpeed = v[3].Speed
									v261.ForceHealth = v[3].Health
									v261.CustomProps = v[3].Custom
								end
							else
								if v[3] then
									v261 = {
										ForceSpeed = v[3].Speed,
										ForceHealth = v[3].Health,
										CustomProps = v[3].Custom,
										ChosenPath = v[3].Path or v234
									}
									
									if v229.EnemyConfig and v229.EnemyConfig.ForceHealthMult and v261.ForceHealth then
										v261.ForceHealth = v261.ForceHealth * v229.EnemyConfig.HealthMult
										v261.ForceHealth = math.ceil(v261.ForceHealth)
									elseif not v261.ForceHealth and v229.EnemyConfig then
										v261.HealthMult = v229.EnemyConfig.HealthMult
									end
									v260 = v260 or v[3].GangCount
								else
									v261 = SharedHelper.DeepCopy(v229.EnemyConfig or item.Params.EnemyConfig)
								end
								if GameState.MapData.Params.GeneralSpeedMult then
									if v261.ForceSpeed then
										v261.ForceSpeed = (v261.ForceSpeed or 1) * GameState.MapData.Params.GeneralSpeedMult
									end
									if v261.SpeedMult then
										v261.SpeedMult = (v261.SpeedMult or 1) * GameState.MapData.Params.GeneralSpeedMult
									end
								end
							end
							for i_1, v_1 in pairs(ClientLoader.TESTING_ENEMIES or {}) do
								for _ = 1, 3 do
									TowerDefense.SpawnEnemy(v_1, { ChosenPath = 1 })
									
									if i_1 == 1 then
										TowerDefense.Wait(1)
									end
									TowerDefense.Wait(2)
								end
							end
							for _ = 1, math.ceil(v[2] * v237) do
								if GameState.GameEnded then
									return
								end
								if gameNumber ~= GameState.GameNumber then
									return
								end
								while game.Workspace:GetAttribute("PausedSpawning") or timeEffectsModule.IsGlobalTimeStopped() do
									task.wait(0.2)
								end
								if game.Workspace:GetAttribute("FastTrackSkip") or game.Workspace:GetAttribute("RestartCurrentRound") then
									continue
								end
								local v262 = SharedHelper.IsPvpAsync()
								v261.PathIndex = if v262 then 1 else v234
								v261.TeamIndex = 2
								v261.RoundSpawned = GameState.CurrentRound
								TowerDefense.SpawnEnemy(v[1], v261)
								
								if v262 then
									local v263 = SharedHelper.DeepCopy(v261)
									v263.PathIndex = 2
									v263.TeamIndex = 1
									TowerDefense.SpawnEnemy(v[1], v263)
								end
								local currentRound = GameState.CurrentRound or 1
								local v265 = 4 / item_1.Params.UnitConfig.Speed
								local v266 = 1
								local v267 = math.floor((v229.SpawnSpeedRampWaves or (item.Params.SpawnSpeedRampWaves or 0)) / count)
								
								if currentRound <= v267 and v267 > 1 then
									v266 = 2.5 + -1.5 * ((currentRound - 1) / (v267 - 1))
								elseif currentRound == 1 and v267 == 1 then
									v266 = 2.5
								end
								if v260 > 0 then
									v260 = v260 - 1
									
									if v[3] and v[3].WaitAfterSpawn then
										TowerDefense.Wait(v[3].WaitAfterSpawn)
									else
										TowerDefense.Wait(v265 * v266 * 0.5)
									end
								else
									v260 = gangCount
									v233 = v233 + 1
									
									if #v232 < v233 then
										v233 = 1
									end
									v234 = v232[v233]
									
									if v[3] and v[3].WaitAfterSpawn then
										TowerDefense.Wait(v[3].WaitAfterSpawn)
									elseif SharedHelper.IsDungeonAsync() then
										TowerDefense.Wait(0.1)
									else
										TowerDefense.Wait(v265 * v266)
									end
								end
							end
							if v260 ~= gangCount then
								v233 = v233 + 1
								
								if #v232 < v233 then
									v233 = 1
								end
								v234 = v232[v233]
							end
						end
						game.Workspace:SetAttribute("FastTrackSkip")
						v243 = true
					end)
					GameState.Votes.SkipWave = nil
					SharedHelper.FireAllClients("UpdateTDVotes", "SkipWave")
					game.Workspace:SetAttribute("CanSkipWave", false)
					GameState.SkipWave = false
					
					if SharedHelper.IsPvpAsync() and p121_1 ~= #v215 then
						local v246 = p121_1
						task.spawn(function() --[[ line: 2711 ]]
							-- upvalues: v243 (write), GameState (copy), v246 (ref)
							while not v243 do
								wait()
							end
							task.wait(math.max(0, 5 - GameState.CurrentRound) + 5)
							
							if v246 ~= GameState.CurrentRound then
								return
							end
							GameState.SkipWave = true
						end)
					end
					if p121_1 ~= #v215 or GameState.DifficultyData.Params.IsEndless then
						local v247 = p121_1
						TowerDefense.Delay(skipEnableTime, function() --[[ line: 2722 ]]
							-- upvalues: SharedHelper (copy), GameState (copy), gameNumber (copy), v247 (ref), forceDifficulty (copy), p121_1 (write)
							if SharedHelper.IsPvpAsync() then
								return
							end
							while game.Workspace:GetAttribute("PausedSpawning") do
								task.wait(0.2)
							end
							while game.Workspace:GetAttribute("GamePaused") or game.Workspace:GetAttribute("GamePauseScheduled") do
								task.wait(0.2)
							end
							if not (GameState.GameEnded or gameNumber ~= GameState.GameNumber or (GameState.CurrentRound ~= v247 or GameState.RoundEnding) or (SharedHelper.GetSubTable(GameState.MapData.Params, "WaveEvents", forceDifficulty, p121_1 + 1) or GameState.MapData.Params.CanSkipWaves == false)) then
								GameState.Votes.SkipWave = nil
								SharedHelper.FireAllClients("UpdateTDVotes", "SkipWave")
								game.Workspace:SetAttribute("CanSkipWave", true)
							end
						end)
					end
					task.spawn(function() --[[ line: 2736 ]]
						-- upvalues: v244 (write), gameNumber (copy), GameState (copy), v243 (write), ClientLoader (copy)
						while not (v244 or gameNumber ~= GameState.GameNumber) do
							if not v243 then
								task.wait(1)
							elseif #ClientLoader.Modules.Units.base.GetActiveEnemies({ GetAll = true }) == 0 then
								v244 = true
							else
								task.wait(1)
							end
						end
					end)
					task.spawn(function() --[[ line: 2755 ]]
						-- upvalues: v244 (write), gameNumber (copy), GameState (copy), p121_1 (write), v215 (write), v245 (write)
						while not (v244 or gameNumber ~= GameState.GameNumber) do
							if GameState.SkipWave and (p121_1 ~= #v215 or GameState.DifficultyData.Params.IsEndless) then
								v244 = true
								v245 = true
							else
								task.wait(0.05)
							end
						end
					end)
					while gameNumber == GameState.GameNumber do
						task.wait(0.05)
					end
					if v212["Wave_" .. tostring(p121_1)] and v212["Wave_" .. tostring(p121_1)].NextWaveCheck then
						game.Workspace:SetAttribute("WaveEnded", true)
						while not v212["Wave_" .. tostring(p121_1)].NextWaveCheck() do
							task.wait(0.05)
						end
						game.Workspace:SetAttribute("WaveEnded")
					end
					if gameNumber ~= GameState.GameNumber then
						return
					end
					GameState.SkipWave = false
					game.Workspace:SetAttribute("CanSkipWave", false)
					GameState.RoundEnding = true
					GameState.Votes.SkipWave = nil
					SharedHelper.FireAllClients("UpdateTDVotes", "SkipWave")
					
					if GameState.GameEnded then
						return
					end
					local waveEvents_1 = SharedHelper.GetSubTable(GameState.MapData.Params, "WaveEvents", forceDifficulty, p121_1, "After")
					
					if waveEvents_1 then
						waveEvents_1({ SetWaveDescription = SetWaveDescription }, GameState)
					end
					if p121_1 ~= #v215 or GameState.DifficultyData.Params.IsEndless then
						for i_4, v_2 in pairs(game.Players:GetPlayers()) do
							ClientLoader.Modules.ServerDataHandler.AddToData(v_2, "Cash", v239, nil, {
								transactionType = "gameplay",
								transactionItemId = "wave_" .. tostring(GameState.CurrentRound)
							})
							ClientLoader.Modules.ServerDataHandler.AddToData(v_2, "TotalCashEarned", v239)
							local playerCharacterPosition = SharedHelper.GetPlayerCharacterPosition(v_2)
							
							if playerCharacterPosition then
								ClientLoader.Modules.SharedHelper.FireRemoteEvent("CashFloat", v_2, playerCharacterPosition, v239, "Cash")
							end
						end
						for i_4, v_3 in pairs(game.Players:GetPlayers()) do
							ClientLoader.Modules.SharedNotifications.Send(v_3, "Wave reward: $" .. tostring(v239) .. "!", {
								Timeout = 5,
								BackgroundColor = Color3.fromRGB(85, 255, 127),
								Image = SharedHelper.AssetFormat(139470064083190)
							})
						end
					end
					if SharedHelper.IsDungeonAsync() then
						for i_4, v_2 in game.Players:GetPlayers() do
							TowerDefense.HealPlayer(v_2, 25)
							TowerDefense.ChangePlayerData(v_2, function(p123) --[[ line: 432 ]]
								-- upvalues: v_2 (ref), TowerDefense (copy), ClientLoader (copy)
								if not p123.ReviveRoundsLeft then
									return
								end
								p123.ReviveRoundsLeft = p123.ReviveRoundsLeft - 1
								v_2:SetAttribute("ReviveRoundsLeft", p123.ReviveRoundsLeft)
								
								if p123.ReviveRoundsLeft <= 0 then
									p123.ReviveRoundsLeft = nil
									TowerDefense.HealPlayer(v_2)
									
									return
								end
								if p123.ReviveRoundsLeft == 1 then
									ClientLoader.Modules.SharedHelper.FireRemoteEvent("ShowMessage", v_2, "You will respawn next round!", "warn")
									
									return
								end
								ClientLoader.Modules.SharedHelper.FireRemoteEvent("ShowMessage", v_2, "You will respawn in " .. tostring(p123.ReviveRoundsLeft) .. " rounds!", "warn")
							end)
						end
					end
					TowerDefense.Wait(GameState.MapData.Params.WaveEndCoolOff or 1)
					SetWaveDescription("Next wave...", GameState.MapData.Params.NextWaveTimer or 2)
					replicatedStorageService.Others.WaveEnded:Fire()
					task.spawn(function() --[[ line: 2864 ]]
						-- upvalues: ClientLoader (copy), SharedHelper (copy), GameState (copy), p121_1 (write)
						ClientLoader.Modules.ServerDataHandler.AnalyticsDesignEvent(game.Players:GetPlayers()[1], SharedHelper.GetUTC() - GameState.StartTime, "tdgame_" .. GameState.MapData.ID, GameState.DifId, "wave_ended_" .. tostring(p121_1))
					end)
					TowerDefense.Wait(GameState.MapData.Params.WaveEndBreather or 3)
					
					if gameNumber ~= GameState.GameNumber then
						return
					end
					GameState.RoundEnding = false
					
					if game.Workspace:GetAttribute("RestartCurrentRound") then
						game.Workspace:SetAttribute("RestartCurrentRound")
						p121_1 = p121_1 - 1
					end
					if CallGameModeFunction("ShouldResetWaves", GameState) then
						loadWaves()
						local v215 = SharedHelper.DeepCopy(v211)
						local v216 = if GameState.DifficultyData.Params.IsEndless then 1e999 else #v215
						p121_1 = 0
					end
					game.Workspace:SetAttribute("FastTrackSkip")
				end
				if SharedHelper.IsSandboxAsync() and (game.Workspace:GetAttribute("JumpWaves") or 0) ~= 0 then
					game.Workspace:SetAttribute("JumpWaves", v216 + game.Workspace:GetAttribute("JumpWaves"))
				else
					if gameNumber ~= GameState.GameNumber then
						return
					end
					TowerDefense.GameEnded(true, { Tie = true })
					
					return
				end
			end
		end)
	end
	
	local function movePlayersToSpawn() --[[ line: 2913 ]]
		-- upvalues: SharedHelper (copy), ClientLoader (copy)
		local map = SharedHelper.FindFirstChild(game.Workspace, "Map", "Spawns")
		map = if not map then {
			SharedHelper.FindFirstDescendantOfClass(game.Workspace.Map, "SpawnLocation")
		} else map:GetChildren()
		
		if #map > 0 then
			SharedHelper.ShuffleArray(map)
			
			for i, v in pairs(game.Players:GetPlayers()) do
				local v269 = map[(i - 1) % #map + 1]
				SharedHelper.InstantThread(function() --[[ line: 2929 ]]
					-- upvalues: ClientLoader (copy), SharedHelper (copy), v (ref), v269 (ref)
					while not ClientLoader.Modules.ServerPlayerHandler do
						SharedHelper.RSWait()
					end
					ClientLoader.Modules.ServerPlayerHandler.MoveToSpawn(v, v269)
				end)
			end
		end
	end
	
	local function LoadGameState(p124) --[[ line: 2939 ]]
		-- upvalues: GameState (ref), SharedHelper (copy), ClientLoader (copy), GameConfig (copy), TowerDefense (copy), v41 (write), v42 (write), SendWarningMessage (ref), httpService (copy), movePlayersToSpawn (ref), WaveCounter (write), SetWaveDescription (ref), StartWaves (ref)
		if GameState.Loaded then
			return
		end
		if GameState.IsLoading then
			return
		end
		GameState.IsLoading = true
		GameState.InitialTeleportParams = SharedHelper.DeepCopy(p124)
		
		if game.PlaceId == 108533757090220 then
			p124 = {}
		end
		for i, v in pairs(ClientLoader.Config.TeleportPlaces) do
			if v.Test == game.PlaceId or v.Main == game.PlaceId then
				p124 = { MapId = i }
			end
		end
		if p124.ServerCreatedThroughMatchmaking then
			game.Workspace:SetAttribute("ServerCreatedThroughMatchmaking", true)
		end
		GameState.MaxPlayers = p124.MaxPlayers or 1
		GameState.PlayerOrder = p124.PlayerOrder or {}
		GameState.ReturnInfo = p124.ReturnInfo
		
		if p124.MaxPlayers == false then
			GameState.MaxPlayers = 99
		end
		if p124.PlayerOrder == false then
			GameState.PlayerOrder = {}
			
			for i_1, v_1 in pairs(game.Players:GetPlayers()) do
				table.insert(GameState.PlayerOrder, v_1.Name)
			end
			game.Players.PlayerAdded:Connect(function(p125) --[[ line: 2992 ]]
				-- upvalues: GameState (copy)
				if not table.find(GameState.PlayerOrder, p125.Name) then
					table.insert(GameState.PlayerOrder, p125.Name)
				end
			end)
		end
		local v270 = GameConfig.ForceMap or p124.MapId or "map_lobby"
		local v271 = GameConfig.ForceGameMode or p124.GameMode or "normal"
		local v272 = GameConfig.ForceModifiers or {}
		
		if GameConfig.ForceMapPerPlayer then
			local v273 = game.Players:GetPlayers()[1]
			
			if v273 and GameConfig.ForceMapPerPlayer[v273.Name] then
				v270 = GameConfig.ForceMapPerPlayer[v273.Name].map or v270
				v271 = GameConfig.ForceMapPerPlayer[v273.Name].gameMode or v271
				v272 = GameConfig.ForceMapPerPlayer[v273.Name].modifiers or v272
			end
		end
		if p124.ActiveModifiers then
			for i_1, v_1 in pairs(string.split(p124.ActiveModifiers, ";")) do
				if v_1 ~= "" then
					table.insert(v272, v_1)
				end
			end
		end
		GameState.MapId = v270
		GameState.GameMode = v271
		
		for i_1, v_1 in pairs(v272) do
			TowerDefense.SetModifierActive(v_1, true)
		end
		if p124.DifId then
			GameState.ForceDifficulty = p124.DifId
			GameState.ResetForceDifficulty = true
		end
		local v274 = GameState.GameMode:match("sandbox") ~= nil
		local v275 = GameState.GameMode:match("endless") ~= nil
		game.Workspace:SetAttribute("IsSandbox", v274)
		GameState.MapData = ClientLoader.Modules.SharedItemData.GetItem(v270)
		
		if GameState.GameMode ~= "sandbox" and v275 then
			GameState.ForceDifficulty = "dif_endless"
			GameState.ResetForceDifficulty = nil
			
			if ClientLoader.Modules.SharedItemData.GetItem(GameState.ForceDifficulty).Params.IsEndless and not GameState.MapData.Params.NoEndlessLeaderboard and not (v274 or v41) then
				v41 = true
				ClientLoader.BindToLoadedModules(function() --[[ line: 1928 ]]
					-- upvalues: SharedHelper (copy), ClientLoader (copy), v42 (copy), SendWarningMessage (copy)
					task.spawn(function() --[[ line: 1929 ]]
						-- upvalues: SharedHelper (copy), ClientLoader (copy), v42 (copy), SendWarningMessage (copy)
						if SharedHelper.IsTestingServer() then
							return
						end
						while true do
							while #game.Players:GetPlayers() < 1 do
								task.wait(1)
							end
							task.wait(10)
							local weekly = ClientLoader.Modules.ServerDataHandler.ServerLeaderboardsHandler.LeaderboardManager.TimeUntilLeaderboardReset("Weekly")
							
							if weekly > 601200 then
								v42 = false
								game.Workspace:SetAttribute("EndlessLDBDisabled", "fast")
								SendWarningMessage("This week's endless leaderboard has not opened yet! Progress will NOT be saved for this run!")
								
								return
							end
							SharedHelper.Countdown(weekly - 300, nil, function(p126) --[[ line: 1941 ]]
								-- upvalues: v42 (copy), SendWarningMessage (copy), SharedHelper (copy)
								if p126 <= 0 then
									v42 = false
									game.Workspace:SetAttribute("EndlessLDBDisabled", "end")
									SendWarningMessage("This week's endless leaderboard has closed! Further progress will NOT be saved!")
									
									return
								end
								SendWarningMessage("This week's endless leaderboard will close in " .. SharedHelper.CurrencyTextFormat(p126, "hours", { desp = " and " }) .. "! Hurry!")
							end)
						end
					end)
				end, "EndlessLeaderboard - " .. GameState.MapId)
			end
		end
		if GameState.MapData.Params.ForceDifficulty then
			GameState.ForceDifficulty = GameState.MapData.Params.ForceDifficulty
			GameState.ResetForceDifficulty = nil
		end
		print("GAME", GameState.GameMode, GameState.ForceDifficulty)
		local baseMap = GameState.MapData.Params.BaseMap or v270
		local map = game.ServerStorage:WaitForChild("Maps"):WaitForChild(baseMap):Clone()
		
		for i_2, v_2 in pairs(map:GetChildren()) do
			if v_2:GetAttribute("RuntimePosition") or v_2:GetAttribute("RuntimeMoveFarAway") then
				if v_2:GetAttribute("RuntimeMoveFarAway") then
					v_2:PivotTo(v_2:GetPivot() + Vector3.new(20000, 0, 20000))
				else
					v_2:PivotTo(v_2:GetPivot() - v_2:GetPivot().p + v_2:GetAttribute("RuntimePosition"))
				end
			end
		end
		SharedHelper.ToPersistentModel(map:FindFirstChild("Path"))
		SharedHelper.ToPersistentModel(map:FindFirstChild("Placeable"))
		TowerDefense.LightingSerializer.Load(map:WaitForChild("LightingSettings"))
		
		for i_3, v_3 in pairs(GameState.MapData.Params.WorkspaceProperties or {}) do
			game.Workspace[i_3] = v_3
		end
		for i_4, v_4 in pairs(GameState.MapData.Params.WorkspaceAttributes or {}) do
			if type(v_4) == "table" then
				local v289 = nil
				local _ = nil
				while not v289 do
					local ok, status = pcall(function() --[[ line: 3088 ]]
						-- upvalues: v_4 (write), httpService (copy)
						v_4 = httpService:JSONEncode(v_4)
					end)
					v289 = ok
					local _ = status
					
					if not v289 then
						wait(1)
					end
				end
			end
			if game.Workspace:GetAttribute(i_4) ~= nil then
				warn("Map attribute already exists, overwriting: " .. i_4 .. "")
			end
			game.Workspace:SetAttribute(i_4, v_4)
		end
		if map:FindFirstChild("LimitedUnitDisplays") and baseMap ~= "map_lobby" then
			local limitedUnitDisplays = game.ServerStorage:WaitForChild("Maps"):WaitForChild("map_lobby"):WaitForChild("LimitedUnitDisplays")
			
			for i_5, v_5 in pairs(map.LimitedUnitDisplays:GetChildren()) do
				if limitedUnitDisplays:FindFirstChild(v_5.Name) and limitedUnitDisplays[v_5.Name]:FindFirstChild("Model") then
					local v279 = limitedUnitDisplays[v_5.Name].Model:Clone()
					v279.Parent = map
					v279.PrimaryPart = v279.Anchor
					v279:PivotTo(v_5.Anchor.CFrame)
					v279.Name = v_5.Name
				end
			end
			map.LimitedUnitDisplays:Destroy()
		end
		map.Name = "Map"
		local currentTime = tick()
		
		local function OnMapParented() --[[ line: 3129 ]]
			-- upvalues: SharedHelper (copy), movePlayersToSpawn (copy), currentTime (ref)
			if game.Workspace:FindFirstChild("DONOTDELETE") then
				game.Workspace.DONOTDELETE.Spawn.Enabled = false
				
				local function moveToRealSpawns() --[[ line: 3133 ]]
					-- upvalues: SharedHelper (copy), movePlayersToSpawn (copy)
					game.Workspace.DONOTDELETE:Destroy()
					SharedHelper.InstantThread(movePlayersToSpawn)
					task.delay(0.5, function() --[[ line: 3136 ]]
						game.Workspace:SetAttribute("MapLoadingUIEnabled", false)
					end)
				end
				
				if tick() - currentTime > 1 then
					task.delay(3, moveToRealSpawns)
					
					return
				end
				moveToRealSpawns()
			end
		end
		
		if map:FindFirstChild("Anchor") then
			game.Workspace:SetAttribute("MapAnchorCF", map.Anchor.CFrame)
		end
		game.Workspace:SetAttribute("MapId", v270)
		game.Workspace:SetAttribute("CanChangeTickSpeed", GameState.MapData.Params.CanChangeTickSpeed)
		game.Workspace:SetAttribute("CanSkipWaves", GameState.MapData.Params.CanSkipWaves)
		
		if GameState.MapData.Params.CanPlaceUnits == false then
			game.Workspace:SetAttribute("CanPlaceUnits", false)
		end
		GameState.EnemyCashRewardMult = GameState.MapData.Params.CashRewardMult or 1
		
		if not (GameState.MapData.Params.Waves or GameState.MapData.Params.IsDungeon or GameState.MapData.Params.IsAdminArena) then
			GameState.IsTDGame = false
			game.Workspace:SetAttribute("IsTDGame", false)
			game.Workspace:SetAttribute("IsDungeon", false)
			game.Workspace:SetAttribute("IsAdminArena", false)
			game.Workspace:SetAttribute("IsPVP", false)
			game.Workspace:SetAttribute("IsLobby", GameState.MapData.Params.IsLobby or false)
			game.Workspace:SetAttribute("IsAFK", GameState.MapData.Params.IsAFK or false)
			game.Workspace:SetAttribute("IsMorphMode", GameState.MapData.Params.IsMorphMode or false)
			map.Parent = game.Workspace
			OnMapParented()
			
			return
		end
		if GameState.MapData.Params.IsAdminArena then
			GameState.IsTDGame = false
			game.Workspace:SetAttribute("IsTDGame", false)
			game.Workspace:SetAttribute("IsDungeon", false)
			game.Workspace:SetAttribute("IsAdminArena", true)
			game.Workspace:SetAttribute("IsPVP", false)
			game.Workspace:SetAttribute("IsLobby", false)
			game.Workspace:SetAttribute("IsAFK", false)
			game.Workspace:SetAttribute("IsMorphMode", false)
			map.Parent = game.Workspace
			OnMapParented()
			
			return
		end
		GameState.IsTDGame = true
		game.Workspace:SetAttribute("IsTDGame", true)
		game.Workspace:SetAttribute("IsDungeon", GameState.MapData.Params.IsDungeon or false)
		game.Workspace:SetAttribute("IsAdminArena", false)
		game.Workspace:SetAttribute("IsMorphMode", GameState.MapData.Params.IsMorphMode or false)
		game.Workspace:SetAttribute("IsPVP", GameState.MapData.Params.IsPVP or false)
		game.Workspace:SetAttribute("IsLobby", false)
		game.Workspace:SetAttribute("IsAFK", false)
		
		if GameState.MapData.Params.CanPause == nil then
			game.Workspace:SetAttribute("CanPause", true)
		else
			game.Workspace:SetAttribute("CanPause", GameState.MapData.Params.CanPause)
		end
		if game.Workspace:GetAttribute("ServerCreatedThroughMatchmaking") then
			game.Workspace:SetAttribute("CanPause", false)
		end
		CallGameModeFunction("ProcessMapModel", map, GameState)
		map.Parent = game.Workspace
		OnMapParented()
		GameState.Loaded = true
		
		if GameState.MapData.Params.OnMapLoaded then
			GameState.MapData.Params.OnMapLoaded(GameState.MapData.Params)
		end
		local v282 = false
		local t_2 = {}
		
		local function mark(p127) --[[ line: 3229 ]]
			-- upvalues: t_2 (ref), GameState (copy), v282 (write)
			if table.find(t_2, p127.Name) then
				return
			end
			table.insert(t_2, p127.Name)
			
			if GameState.MaxPlayers <= #t_2 then
				v282 = true
			end
		end
		
		for i_5, v_5 in pairs(game.Players:GetPlayers()) do
			if not table.find(t_2, v_5.Name) then
				table.insert(t_2, v_5.Name)
				
				if GameState.MaxPlayers <= #t_2 then
					v282 = true
				end
			end
		end
		game.Players.PlayerAdded:Connect(mark)
		local v285 = if GameState.MapData.Params.WaitForPlayers then 30 else 15
		while not v282 do
			local text = "Waiting for players... (" .. tostring(v285) .. ")"
			WaveCounter = WaveCounter + 1
			local _ = WaveCounter
			game.Workspace:SetAttribute("WaveDescription", text)
			game.Workspace:SetAttribute("WaveDescriptionData")
			v285 = v285 - 1
			
			if v285 <= 0 then
				v282 = true
			end
			task.wait(1)
		end
		SetWaveDescription()
		
		if SharedHelper.IsPvpAsync() then
			task.wait(5)
			local v287 = false
			
			for i = 45, 1, -1 do
				if #game.Players:GetPlayers() >= 2 then
					v287 = true
					break
				else
					local text = "Waiting for opponent... (" .. tostring(i) .. ")"
					WaveCounter = WaveCounter + 1
					local _ = WaveCounter
					game.Workspace:SetAttribute("WaveDescription", text)
					game.Workspace:SetAttribute("WaveDescriptionData")
					task.wait(1)
				end
				if not (v287 or #game.Players:GetPlayers() >= 2) then
					WaveCounter = WaveCounter + 1
					local _ = WaveCounter
					game.Workspace:SetAttribute("WaveDescription", "Match canceled.")
					game.Workspace:SetAttribute("WaveDescriptionData")
					SharedHelper.FireAllClients("ShowGameEnd", {
						Tie = true,
						RunTime = 0,
						CanReplay = false,
						CustomMessage = "Opponent failed to connect",
						PlayerData = GameState.PlayerData
					})
					
					return
				end
				local v290 = game.Players:GetPlayers()[1]
				local v291 = game.Players:GetPlayers()[2]
				local v292 = nil
				SharedHelper.OnRemoteEvent("UnitPickerSetSelected", function(...) --[[ line: 3283 ]]
					-- upvalues: v292 (write)
					if not v292 then
						return
					end
					v292(...)
				end)
				local v293 = false
				local v294 = false
				SharedHelper.OnRemoteEvent("UnitPickerSetReady", function(p128, p129) --[[ line: 3290 ]]
					-- upvalues: v290 (ref), v293 (write), v294 (write)
					if type(p129) ~= "boolean" then
						return
					end
					if p128 == v290 then
						v293 = p129
						
						return
					end
					v294 = p129
				end)
				local _ = ClientLoader.Modules.ServerDataHandler.WaitPlayerData(v290)
				local _ = ClientLoader.Modules.ServerDataHandler.WaitPlayerData(v291)
				local t_2 = {}
				
				for i_1, v in pairs(ClientLoader.Modules.SharedItemData.GetCategory("Units")) do
					if not (v.Params.UnitType == "enemy" or v.Params.System or v.Params.Hidden) then
						table.insert(t_2, v.ID)
					end
				end
				local t_3 = {}
				
				if game.Workspace:GetAttribute("MMRanked") then
					local t_4 = {}
					local t_5 = {}
					
					local _ = function(p130, p131) --[[ line: 3321 ]]
						-- upvalues: t_2 (ref), ClientLoader (copy), v290 (ref), t_4 (write), t_5 (write)
						local v307 = 0
						local TowerDefense = {}
						
						for i, v in p131 do
							local baseUnit = ClientLoader.Modules.SharedItemData.GetItem(v).Params.BaseUnit or v
							
							if not table.find(TowerDefense, baseUnit) then
								table.insert(TowerDefense, baseUnit)
								v307 = v307 + 1
							end
						end
						if v307 > 6 then
							warn("invalid list!", p131)
							
							return
						end
						for i, v_1 in pairs(p131) do
							if not table.find(t_2, v_1) then
								warn("invalid list!", p131)
								
								return
							end
						end
						if p130 == v290 then
							t_4 = p131
							
							return
						end
						t_5 = p131
					end
					
					SharedHelper.FireRemoteEvent("PlayerPickUnits", v290, t_2, "ban", 6)
					SharedHelper.FireRemoteEvent("PlayerPickUnits", v291, t_2, "ban", 6)
					SharedHelper.FireAllClients("ShowMessage", "Choose which units to ban!")
					
					for i_2 = 60, 1, -1 do
						local text = "Pick units to ban (" .. tostring(i_2) .. ")"
						WaveCounter = WaveCounter + 1
						local _ = WaveCounter
						game.Workspace:SetAttribute("WaveDescription", text)
						game.Workspace:SetAttribute("WaveDescriptionData")
						task.wait(1)
					end
					local t_3 = SharedHelper.DeepCopy(t_4)
					
					for i_3, v_1 in pairs(t_5) do
						if not table.find(t_3, v_1) then
							table.insert(t_3, v_1)
						end
					end
					SharedHelper.FireRemoteEvent("PlayerPickUnits", v290)
					SharedHelper.FireRemoteEvent("PlayerPickUnits", v291)
					task.wait(1)
					WaveCounter = WaveCounter
				else
					SharedHelper.FireAllClients("ShowMessage", "This is a casual game! All units allowed!")
					task.wait(3)
					WaveCounter = WaveCounter
				end
				local units = TowerDefense.UnitInventoryManager.GetUniqueInventory(v290, "Units", "unit")
				local units_1 = TowerDefense.UnitInventoryManager.GetUniqueInventory(v291, "Units", "unit")
				local t_6 = {}
				local t_7 = {}
				
				local _ = function(p132, p133) --[[ line: 3382 ]]
					-- upvalues: units_1 (ref), v290 (ref), units (ref), ClientLoader (copy), t_3 (write), t_6 (write), t_7 (write)
					local v310 = if p132 == v290 then units else units_1
					
					if #p133 > 5 then
						return
					end
					for i, v in pairs(p133) do
						if table.find(ClientLoader.Config.PVP.DisabledUnits, v) then
							warn("invalid list!", p133)
							
							return
						end
						if not table.find(v310, v) then
							warn("invalid list!", p133)
							
							return
						end
						if table.find(t_3, v) then
							warn("invalid list!", p133)
							
							return
						end
					end
					if p132 == v290 then
						t_6 = p133
						
						return
					end
					t_7 = p133
				end
				
				SharedHelper.FireRemoteEvent("PlayerPickUnits", v290, units, "select", 5, t_3)
				SharedHelper.FireRemoteEvent("PlayerPickUnits", v291, units_1, "select", 5, t_3)
				SharedHelper.FireAllClients("ShowMessage", "Select your units!")
				local _ = false
				local _ = false
				
				for i_4 = 60, 1, -1 do
					local text_1 = "Select your units (" .. tostring(i_4) .. ")"
					WaveCounter = WaveCounter + 1
					local _ = WaveCounter
					game.Workspace:SetAttribute("WaveDescription", text_1)
					game.Workspace:SetAttribute("WaveDescriptionData")
					task.wait(1)
				end
				local function ProcessCharacter(p134, p135) --[[ line: 3422 ]]
					-- upvalues: ClientLoader (copy)
					for i, v in pairs(ClientLoader.Modules.ServerToolHandler.GetPlayerPlantTools(p134, p135)) do
						ClientLoader.Modules.ServerToolHandler.GiveTool(p134, "tl_unitplacer_" .. tostring(v.ID))
					end
				end
				
				ProcessCharacter(v290, t_6)
				ProcessCharacter(v291, t_7)
				v290.CharacterAdded:Connect(function() --[[ line: 3431 ]]
					-- upvalues: ProcessCharacter (ref), v290 (ref), t_6 (write)
					task.delay(2, function() --[[ line: 3432 ]]
						-- upvalues: ProcessCharacter (copy), v290 (copy), t_6 (copy)
						ProcessCharacter(v290, t_6)
					end)
				end)
				v291.CharacterAdded:Connect(function() --[[ line: 3436 ]]
					-- upvalues: ProcessCharacter (ref), v291 (ref), t_7 (write)
					task.delay(2, function() --[[ line: 3437 ]]
						-- upvalues: ProcessCharacter (copy), v291 (copy), t_7 (copy)
						ProcessCharacter(v291, t_7)
					end)
				end)
				SharedHelper.FireRemoteEvent("PlayerPickUnits", v290)
				SharedHelper.FireRemoteEvent("PlayerPickUnits", v291)
				SharedHelper.FireAllClients("ShowMessage", "Game starting!")
				SetWaveDescription()
			end
		end
		if GameState.ForceDifficulty then
			task.delay(5, StartWaves)
		end
		return true
	end
	
	local function StartDifficultyVote(p136) --[[ line: 3459 ]]
		-- upvalues: GameState (ref), SharedHelper (copy)
		if GameState.WavesStarted then
			return
		end
		if GameState.ForceDifficulty then
			return
		end
		if p136 then
			SharedHelper.FireRemoteEvent("StartDifficultyVote", p136, {
				DifficultyVote = if not GameState.Votes.Difficulty then {} else GameState.Votes.Difficulty.Votes,
				MapId = GameState.MapId
			})
			
			return
		end
		SharedHelper.FireAllClients("StartDifficultyVote", {
			DifficultyVote = if not GameState.Votes.Difficulty then {} else GameState.Votes.Difficulty.Votes,
			MapId = GameState.MapId
		})
	end
	
	function TowerDefense.RestartGame() --[[ line: 3479 ]]
		-- upvalues: GameState (ref), ClientLoader (copy), TowerDefense (copy), SharedHelper (copy), StartDifficultyVote (ref), StartWaves (ref)
		if GameState.MaxReplays + 1 < GameState.GameNumber and GameState.UseMaxReplays then
			return
		end
		GameState.GameNumber = GameState.GameNumber + 1
		GameState.GameEnded = true
		GameState.WavesStarted = false
		GameState.AdjustedPlayTime = 0
		GameState.RoundsActive = false
		GameState.UsedUnits = {}
		GameState.TotalUpgrades = 0
		
		if GameState.ResetForceDifficulty then
			GameState.ResetForceDifficulty = nil
			GameState.ForceDifficulty = nil
		end
		for i, v in pairs(ClientLoader.Modules.Units.base.GetActiveEntities()) do
			v.Destroy()
		end
		GameState.CurrentRound = 0
		GameState.TotalEnemiesScheduled = 0
		GameState.EnemiesDied = 0
		GameState.Votes = {}
		GameState.PlayerData = {}
		GameState.Analytics = {}
		
		for i, v_1 in game.Players:GetPlayers() do
			TowerDefense.InitialisePlayerAnalytics(v_1)
		end
		GameState.GameEnded = false
		GameState.GameFinishedEnding = false
		GameState.RoundEnding = false
		CallGameModeFunction("OnRestart", GameState)
		game.Workspace:SetAttribute("Round", game.Workspace:GetAttribute("CheckpointWave") or 1)
		game.Workspace:SetAttribute("EnemiesLeft", 0)
		game.Workspace:SetAttribute("EnemiesDied", 0)
		game.Workspace:SetAttribute("BaseHP", 250)
		game.Workspace:SetAttribute("MaxBaseHP", 250)
		game.Workspace:SetAttribute("BaseHP_1", 250)
		game.Workspace:SetAttribute("MaxBaseHP_1", 250)
		game.Workspace:SetAttribute("BaseHP_2", 250)
		game.Workspace:SetAttribute("MaxBaseHP_2", 250)
		game.Workspace:SetAttribute("CanSkipWave", false)
		game.Workspace:SetAttribute("GameStartTime")
		game.Workspace:SetAttribute("GameEndTime")
		game.Workspace:SetAttribute("DifficultyVoteEnd")
		game.Workspace:SetAttribute("AlreadyRewind", nil)
		
		if game.Workspace:GetAttribute("CheckpointWave") then
			game.Workspace:SetAttribute("CheckpointWaveRestarted", true)
		end
		for i, v_2 in ipairs(game.Players:GetPlayers()) do
			v_2:SetAttribute("UnitsPlaced", 0)
			ClientLoader.Modules.ServerDataHandler.ChangeData(v_2, "Cash", game.Workspace:GetAttribute("CheckpointCash") or ClientLoader.Modules.ServerDataHandler.GetDefaultData().Cash)
		end
		if not GameState.ForceDifficulty then
			SharedHelper.FireAllClients("ShowMessage", "Match restarted – vote for a level!", { SideForPhone = true })
			StartDifficultyVote()
			
			return
		end
		SharedHelper.FireAllClients("ShowMessage", "Match restarted!", { SideForPhone = true })
		task.delay(5, function() --[[ line: 3573 ]]
			-- upvalues: StartWaves (copy)
			StartWaves((game.Workspace:GetAttribute("CheckpointWave") or 1) - 1)
		end)
	end
	
	local v52 = nil
	ClientLoader.BindToLoadedModules(function() --[[ line: 3581 ]]
		-- upvalues: ClientLoader (copy), SharedHelper (copy), GameConfig (copy), v52 (write)
		ClientLoader.Modules.SharedConfigService.OnConfigSet(function(p137) --[[ line: 3582 ]]
			-- upvalues: SharedHelper (copy), GameConfig (copy), v52 (copy)
			print("GOT TD MAP VERSION")
			print(SharedHelper.TableToString(p137))
			print(SharedHelper.TableToString(GameConfig.TDMapVersions))
			v52 = p137
		end, "tdmap_version")
	end)
	local v53 = false
	SharedHelper.OnRemoteFunction("RestartGame", function(_) --[[ line: 3591 ]]
		-- upvalues: GameState (ref), v52 (write), SharedHelper (copy), GameConfig (copy), v53 (write), ClientLoader (copy), TowerDefense (copy)
		if not GameState.GameEnded then
			return
		end
		print("TD CHECK")
		
		if v52 then
			print("HAD TD MAP VERSION")
			print(SharedHelper.TableToString(v52))
			print(SharedHelper.TableToString(GameConfig.TDMapVersions))
			local mapId = GameState.MapId
			
			if (GameConfig.TDMapVersions.ALL or 0) < (v52.ALL or 0) or mapId and (GameConfig.TDMapVersions[mapId] or 0) < (v52[mapId] or 0) then
				if v53 then
					return
				end
				v53 = true
				local initialTeleportParams = GameState.InitialTeleportParams or {}
				initialTeleportParams.DifId = nil
				
				if ClientLoader.Modules.ServerTeleportHandler.RequiresSecure(initialTeleportParams) then
					SharedHelper.FireAllClients("ShowMessage", "Game was updated! Returning to lobby...", "success")
					task.wait(3)
				else
					SharedHelper.FireAllClients("ShowMessage", "Game was updated! Joining a new server...", "success")
					task.wait(3)
					ClientLoader.Modules.ServerTeleportHandler.Teleport(game.Players:GetPlayers(), game.PlaceId, true, initialTeleportParams)
				end
				task.wait(5)
				v53 = false
				
				return
			end
		end
		TowerDefense.RestartGame()
	end)
	
	function TowerDefense.InitialisePlayerAnalytics(p138) --[[ line: 3627 ]]
		-- upvalues: GameState (ref), ClientLoader (copy)
		if not GameState.Analytics then
			return
		end
		GameState.Analytics[tostring(p138.UserId)] = { Units = {} }
		task.spawn(function() --[[ line: 3632 ]]
			-- upvalues: ClientLoader (copy), p138 (ref), GameState (copy)
			while not ClientLoader.DoneLoading do
				task.wait()
			end
			local v312 = ClientLoader.Modules.ServerDataHandler.WaitPlayerData(p138)
			
			if not GameState.Analytics[tostring(p138.UserId)] then
				return
			end
			GameState.Analytics[tostring(p138.UserId)].GamesPlayed = v312.GamesPlayed or 0
			local TowerDefense = {}
			
			for i, v in ClientLoader.Modules.ServerDataHandler.GetEquippedItems(p138, "Units") do
				local _, v314 = ClientLoader.Modules.ServerDataHandler.HasInInventory(p138, v)
				
				if v314 then
					table.insert(TowerDefense, v314.ItemData.ID)
				end
			end
			table.sort(TowerDefense)
			GameState.Analytics[tostring(p138.UserId)].Loadout = TowerDefense
		end)
	end
	
	local function processPlayer(p139) --[[ line: 3653 ]]
		-- upvalues: GameState (ref), SharedHelper (copy), playersService (copy), ClientLoader (copy), StartDifficultyVote (ref), TowerDefense (copy)
		local v315 = not not GameState.PlayerData[p139.Name]
		p139:SetAttribute("TeamIndex", SharedHelper.IsPvpAsync() and (table.find(playersService:GetPlayers(), p139) or 1))
		p139:SetAttribute("UnitsPlaced", 0)
		p139:SetAttribute("MaxUnitsPlaced", 20)
		ClientLoader.Modules.Units.base.SendActiveEntities(p139)
		task.delay(3, function() --[[ line: 3662 ]]
			-- upvalues: GameState (copy), StartDifficultyVote (copy), p139 (ref)
			if not GameState.IsTDGame then
				return
			end
			StartDifficultyVote(p139)
		end)
		TowerDefense.GiveStarterCash(p139)
		GameState.UserIds[tostring(p139.UserId)] = { Name = p139.Name, AccountAge = p139.AccountAge }
		TowerDefense.InitialisePlayerAnalytics(p139)
		
		if GameState.WaveCount and GameState.CurrentRound then
			CallGameModeFunction("PlayerJoinedAfterStart", GameState, p139)
		end
		task.delay(3, function() --[[ line: 3680 ]]
			-- upvalues: SharedHelper (copy), GameState (copy), v315 (ref), p139 (ref), TowerDefense (copy), ClientLoader (copy)
			if SharedHelper.IsDungeonAsync() and GameState.WaveCount and (GameState.CurrentRound and v315) then
				local v316 = p139
				TowerDefense.ChangePlayerData(v316, function(p140) --[[ line: 451 ]]
					-- upvalues: GameState (copy), v316 (ref), TowerDefense (copy), ClientLoader (copy)
					p140.Ghost = true
					
					if GameState.WaveCount and GameState.CurrentRound then
						p140.ReviveRoundsLeft = math.min(5, GameState.WaveCount + 1 - GameState.CurrentRound)
					else
						p140.ReviveRoundsLeft = 5
					end
					v316:SetAttribute("ReviveRoundsLeft", p140.ReviveRoundsLeft)
					v316:SetAttribute("Ghost", true)
					
					if TowerDefense.AnyoneAlive() then
						if p140.ReviveRoundsLeft == 1 then
							ClientLoader.Modules.SharedHelper.FireRemoteEvent("ShowMessage", v316, "You have died! You will respawn next round!", "warn")
						else
							ClientLoader.Modules.SharedHelper.FireRemoteEvent("ShowMessage", v316, "You have died! You will respawn in " .. tostring(p140.ReviveRoundsLeft) .. " rounds!", "warn")
						end
						for i, v in pairs(game.Players:GetPlayers()) do
							if v ~= v316 then
								ClientLoader.Modules.SharedHelper.FireRemoteEvent("ShowMessage", v, v316.DisplayName .. " has died!", "warn")
							end
						end
					end
				end)
			end
		end)
	end
	
	for i, v in pairs(game.Players:GetPlayers()) do
		task.spawn(function() --[[ line: 3694 ]]
			-- upvalues: processPlayer (ref), v (ref)
			processPlayer(v)
		end)
	end
	game.Players.PlayerAdded:Connect(processPlayer)
	
	function TowerDefense.GetWavesCleared() --[[ line: 3701 ]]
		-- upvalues: GameState (ref), ClientLoader (copy)
		if not GameState.CurrentRound then
			return 0
		end
		local TowerDefense = {}
		
		for i, v in pairs(ClientLoader.Modules.Units.base.GetActiveEnemies({ GetAll = true })) do
			if v.Data.RoundSpawned and not table.find(TowerDefense, v.Data.RoundSpawned) then
				table.insert(TowerDefense, v.Data.RoundSpawned)
			end
			v.Destroy()
		end
		return GameState.CurrentRound - #TowerDefense
	end
	
	function TowerDefense.SessionEnding(p141) --[[ line: 3716 ]]
		-- upvalues: TowerDefense (copy), SharedHelper (copy), GameState (ref), ClientLoader (copy)
		local v318 = false
		
		for i, v in pairs(game.Players:GetPlayers()) do
			if v.Name ~= p141.Name then
				v318 = true
			end
		end
		TowerDefense.SellAllUnits(p141)
		
		if SharedHelper.IsTdGameAsync() then
			if not v318 then
				local ok, status = pcall(function() --[[ line: 3728 ]]
					-- upvalues: GameState (copy), TowerDefense (copy), p141 (ref)
					if (GameState.CurrentRound or 0) > 1 and not GameState.GameEnded then
						TowerDefense.GiveGameEndRewad(p141, false)
					end
				end)
				
				if not ok then
					SharedHelper.SafeError(status)
				end
			elseif not (ClientLoader.IsStudio or SharedHelper.IsPvpAsync()) then
				local playerData = ClientLoader.Modules.ServerDataHandler.GetPlayerData(p141)
				
				if playerData and playerData.Reconnect then
					playerData.Reconnect.JobId = game.JobId
					playerData.Reconnect.UTC = SharedHelper.GetUTC()
				end
			end
			if SharedHelper.IsRankedPvpAsync() then
				while not GameState.GameFinishedEnding do
					wait()
				end
			end
		end
	end
	
	game.Players.PlayerRemoving:Connect(function(p142) --[[ line: 3758 ]]
		-- upvalues: SharedHelper (copy), TowerDefense (copy)
		local teamIndexAttribute = p142:GetAttribute("TeamIndex")
		
		if SharedHelper.IsPvpAsync() then
			for i, v in game.Players:GetPlayers() do
				if v:GetAttribute("TeamIndex") == teamIndexAttribute then
					return
				end
			end
			TowerDefense.GameEnded(false, {
				OpponentLeft = true,
				WinningTeam = if teamIndexAttribute == 1 then 2 else 1,
				LeavingPlayer = p142
			})
		end
	end)
	SharedHelper.CreateRemoteEvent("StartDifficultyVote")
	SharedHelper.CreateRemoteEvent("StopDifficultyVote")
	SharedHelper.CreateRemoteEvent("MoveToSpawn")
	SharedHelper.CreateRemoteEvent("PlayerPickUnits")
	SharedHelper.CreateRemoteEvent("Jumpscare")
	
	local function CastVote(p143, p144, p145) --[[ line: 3818 ]]
		-- upvalues: GameState (ref)
		local v321 = false
		
		if not GameState.Votes[p143] then
			GameState.Votes[p143] = { Winner = nil, Votes = {} }
			v321 = true
		end
		local v322 = GameState.Votes[p143]
		v322.Votes[p144] = p145
		local TowerDefense = {}
		
		for i, v in pairs(v322.Votes) do
			TowerDefense[v] = (TowerDefense[v] or 0) + 1
		end
		local v324 = nil
		local v325 = -1
		local v326 = 0
		
		for i_1, v_1 in pairs(TowerDefense) do
			v326 = v326 + v_1
			
			if v325 >= v_1 then
				if v_1 == v325 then
					if tostring(i_1) < tostring(v324) then
						v325 = v_1
						v324 = i_1
					end
				end
				v325 = v_1
				v324 = i_1
			end
		end
		v322.Winner = v324
		v322.NumberOfVotes = v326
		
		return v321
	end
	
	SharedHelper.CreateRemoteEvent("UpdateTDVotes")
	SharedHelper.OnRemoteFunction("SkipWave", function(p146, p147) --[[ line: 3857 ]]
		-- upvalues: GameState (ref), CastVote (ref), SharedHelper (copy)
		if p147 and not GameState.WavesStarted then
			return
		end
		if not game.Workspace:GetAttribute("CanSkipWave") then
			return
		end
		CastVote("SkipWave", p146.Name, p147)
		SharedHelper.FireAllClients("UpdateTDVotes", "SkipWave", if not GameState.Votes.SkipWave then {} else GameState.Votes.SkipWave.Votes)
		print("VOTE", GameState.Votes.SkipWave.NumberOfVotes, #game.Players:GetPlayers() / 2)
		
		if #game.Players:GetPlayers() / 2 < GameState.Votes.SkipWave.NumberOfVotes then
			GameState.SkipWave = true
		end
	end)
	SharedHelper.CreateRemoteEvent("SandboxToggleSpawning")
	SharedHelper.OnRemoteEvent("SandboxToggleSpawning", function(_) --[[ line: 3870 ]]
		-- upvalues: SharedHelper (copy)
		if not SharedHelper.IsSandboxAsync() then
			return
		end
		game.Workspace:SetAttribute("PausedSpawning", not game.Workspace:GetAttribute("PausedSpawning"))
	end)
	SharedHelper.CreateRemoteEvent("SandboxSetGameSpeed")
	SharedHelper.OnRemoteFunction("SandboxSetGameSpeed", function(_, p148) --[[ line: 3877 ]]
		-- upvalues: SharedHelper (copy)
		if not SharedHelper.IsSandboxAsync() then
			return
		end
		if not (p148 and type(p148) == "number") then
			return
		end
		game.Workspace:SetAttribute("TickSpeed", math.clamp(p148, 0.5, 5))
		
		return true
	end)
	SharedHelper.CreateRemoteEvent("SandboxFunInteraction")
	SharedHelper.OnRemoteEvent("SandboxFunInteraction", function(_, p149, ...) --[[ line: 3887 ]]
		-- upvalues: SharedHelper (copy), ClientLoader (copy)
		if not SharedHelper.IsSandboxAsync() then
			return
		end
		local serverAdminAbuse = ClientLoader.Modules.ServerAdminAbuse
		
		if table.find({ "CharScale", "HeadScale", "GravityScale" }, p149) then
			require(serverAdminAbuse.EventsContainer:WaitForChild("CharacterMod")).Invoked({ Property = p149, Amount = ... })
			
			return
		end
		if p149 == "PlaySound" then
			local playSoundModule = require(serverAdminAbuse.EventsContainer:WaitForChild("PlaySound"))
			local v328 = ...
			
			if not v328 then
				playSoundModule.Invoked({ StopAll = true })
				
				return
			end
			playSoundModule.Invoked({ SoundId = v328 })
		end
	end)
	SharedHelper.CreateRemoteEvent("SandboxGoToWave")
	SharedHelper.OnRemoteFunction("SandboxGoToWave", function(_, p150) --[[ line: 3909 ]]
		-- upvalues: SharedHelper (copy), GameState (ref), ClientLoader (copy)
		if not SharedHelper.IsSandboxAsync() then
			return
		end
		if type(p150) ~= "number" then
			return
		end
		if p150 ~= math.round(p150) then
			return
		end
		game.Workspace:SetAttribute("JumpWaves", math.clamp(p150, 1, GameState.WaveCount or 1000) - (game.Workspace:GetAttribute("Round") + 1))
		game.Workspace:SetAttribute("FastTrackSkip", true)
		game.Workspace:SetAttribute("PausedSpawning", false)
		
		for i, v in pairs(ClientLoader.Modules.Units.base.GetActiveEnemies({ GetAll = true })) do
			v.Destroy()
		end
		return true
	end)
	SharedHelper.CreateRemoteEvent("SandboxAddToCash")
	SharedHelper.OnRemoteFunction("SandboxAddToCash", function(p151, p152) --[[ line: 3932 ]]
		-- upvalues: SharedHelper (copy), ClientLoader (copy)
		if not SharedHelper.IsSandboxAsync() then
			return
		end
		if type(p152) ~= "number" then
			return
		end
		local playerData = ClientLoader.Modules.ServerDataHandler.GetPlayerData(p151)
		
		if not playerData then
			return
		end
		ClientLoader.Modules.ServerDataHandler.AddToData(p151, "Cash", math.min(math.max(100000000 - (playerData.Cash or 0), 0), p152), nil, { transactionType = "sandbox" })
		
		return true
	end)
	SharedHelper.CreateRemoteEvent("SandboxAddEnemyToQueue")
	SharedHelper.OnRemoteEvent("SandboxAddEnemyToQueue", function(p153, p154, p155, p156, p157) --[[ line: 3951 ]]
		-- upvalues: SharedHelper (copy), GameConfig (copy), ClientLoader (copy), GameState (ref), httpService (copy)
		local v334
		print("Spawn enemy with custom settings:", p157)
		
		for i, v in pairs(SharedHelper.DeepCopy(if p157 then nil else {})) do
			v334 = false
			
			for i_1, v_1 in pairs(GameConfig.Sandbox.CustomEnemyConfig) do
				if v_1.Property == i then
					p157[v_1.SetProperty] = p157[v_1.Property]
					p157[v_1.Property] = nil
					v334 = true
					break
				end
			end
			if not v334 then
				warn("Invalid property: " .. i)
				
				return
			end
		end
		p155 = p155 or 1
		p156 = p156 or 2
		
		if not SharedHelper.IsSandboxAsync() then
			return
		end
		local item = ClientLoader.Modules.SharedItemData.GetItem(p154)
		
		if not (item and item.Params.UnitConfig) then
			return
		end
		if item.Params.UnitType ~= "enemy" then
			return
		end
		local v331 = GameState.EnemySendQueue[1] or {}
		
		if #v331 >= 10 then
			return false, "Max 10 enemies in queue!"
		end
		local v332 = httpService:GenerateGUID(false)
		local p157 = p157 or {}
		p157.PathIndex = math.random(1, #ClientLoader.Modules.SharedTowerDefenseHandler.PathHandler.PossiblePaths)
		table.insert(v331, {
			p154,
			p157,
			p153,
			v332,
			p155,
			p156
		})
		
		if #v331 == 1 then
			GameState.TimeUntilNextEnemyFromQueueSent[1] = p156
		end
		SharedHelper.FireRemoteEvent("SendEnemyQueueUpdated", p153, v331, GameState.TimeUntilNextEnemyFromQueueSent[1])
		
		return true
	end)
	SharedHelper.OnRemoteFunction("PlaceDifficultyVote", function(p158, p159) --[[ line: 4005 ]]
		-- upvalues: GameState (ref), CastVote (ref), StartDifficultyVote (ref), ClientLoader (copy), SharedHelper (copy), StartWaves (ref)
		if GameState.WavesStarted then
			return
		end
		if not GameState.MapData then
			return
		end
		if not GameState.MapData.Params.Rewards then
			return
		end
		if not GameState.MapData.Params.Rewards[p159] then
			return
		end
		local v335 = CastVote("Difficulty", p158.Name, p159)
		StartDifficultyVote()
		
		if v335 then
			local v336 = if ClientLoader.FAST_START then 0 elseif GameState.MaxPlayers == 1 then 5 else 15
			game.Workspace:SetAttribute("DifficultyVoteEnd", SharedHelper.GetUTC() + v336)
			task.delay(v336, StartWaves)
		end
	end)
	task.delay(1, function() --[[ line: 4031 ]]
		if game.Workspace:GetAttribute("MapLoadingUIEnabled") ~= false then
			game.Workspace:SetAttribute("MapLoadingUIEnabled", true)
		end
	end)
	
	local function getTeleportData(p160) --[[ line: 4042 ]]
		-- upvalues: ClientLoader (copy), SharedHelper (copy), LoadGameState (ref)
		local joinData = p160:GetJoinData()
		local v338 = if joinData and joinData.TeleportData then joinData.TeleportData else {}
		while not ClientLoader.Modules.ServerTeleportHandler do
			SharedHelper.RSWait()
		end
		local gameServerConfig, gameServerConfig_1 = ClientLoader.Modules.ServerTeleportHandler.GetGameServerConfig(v338)
		
		if gameServerConfig then
			v338 = gameServerConfig_1
			print("Got secure params!")
		else
			print("Loading game using teleport data!")
		end
		if LoadGameState(v338) then
			print("GAMESTATE LOADED - Teleport Player")
		end
	end
	
	game.Players.PlayerAdded:Connect(getTeleportData)
	
	for i_1, v_1 in pairs(game.Players:GetPlayers()) do
		getTeleportData(v_1)
	end
	TowerDefense.EndlessBannedUnits = {}
	TowerDefense.EndlessBannedUpdated = Instance.new("BindableEvent")
	local unitBanPoolModule = require(replicatedStorageService.Others.UnitBanPool)
	local random = Random.new()
	local endlessUnitBans0007DataStore = game:GetService("DataStoreService"):GetDataStore("EndlessUnitBans_0007")
	
	local function buildBans() --[[ line: 4076 ]]
		-- upvalues: unitBanPoolModule (ref), random (ref)
		local raGodly = unitBanPoolModule.ra_godly
		local raExclusive = unitBanPoolModule.ra_exclusive
		random:Shuffle(raGodly)
		random:Shuffle(raExclusive)
		local TowerDefense = {}
		table.insert(TowerDefense, raGodly[1])
		table.insert(TowerDefense, raGodly[2])
		table.insert(TowerDefense, raGodly[3])
		table.insert(TowerDefense, raGodly[4])
		table.insert(TowerDefense, raGodly[5])
		table.insert(TowerDefense, raExclusive[1])
		table.insert(TowerDefense, raExclusive[2])
		table.insert(TowerDefense, raExclusive[3])
		table.insert(TowerDefense, raExclusive[4])
		table.insert(TowerDefense, raExclusive[5])
		table.insert(TowerDefense, raExclusive[6])
		table.insert(TowerDefense, raExclusive[7])
		table.insert(TowerDefense, raExclusive[8])
		table.insert(TowerDefense, raExclusive[9])
		
		return TowerDefense
	end
	
	ClientLoader.BindToLoadedModules(function() --[[ line: 4097 ]]
		-- upvalues: ClientLoader (copy), SharedHelper (copy), endlessUnitBans0007DataStore (ref), buildBans (ref), TowerDefense (copy), GameState (ref)
		local weekly = ClientLoader.Modules.ServerDataHandler.ServerLeaderboardsHandler.LeaderboardManager.GetDateString("Weekly")
		
		local function _() --[[ line: 4100 | named "getBansForThisWeek" ]]
			-- upvalues: weekly (write), SharedHelper (copy), endlessUnitBans0007DataStore (copy), buildBans (copy), TowerDefense (copy)
			local v343 = nil
			SharedHelper.BackoffRetry(function() --[[ line: 4105 ]]
				-- upvalues: endlessUnitBans0007DataStore (copy), weekly (ref), v343 (write), buildBans (copy)
				endlessUnitBans0007DataStore:UpdateAsync(weekly, function(p161) --[[ line: 4106 ]]
					-- upvalues: v343 (copy), buildBans (copy)
					if p161 then
						v343 = p161
						
						return
					end
					v343 = buildBans()
					
					return v343
				end)
			end, 5)
			TowerDefense.EndlessBannedUnits = v343
			TowerDefense.EndlessBannedUpdated:Fire()
			
			return true
		end
		
		task.spawn(function() --[[ line: 4121 ]]
			-- upvalues: ClientLoader (copy), weekly (write), SharedHelper (copy), endlessUnitBans0007DataStore (copy), buildBans (copy), TowerDefense (copy)
			local weekly_1
			while task.wait(10) do
				weekly_1 = ClientLoader.Modules.ServerDataHandler.ServerLeaderboardsHandler.LeaderboardManager.GetDateString("Weekly")
				
				if weekly == weekly_1 then
					continue
				end
				weekly = weekly_1
				local v345 = weekly
				local v346 = nil
				SharedHelper.BackoffRetry(function() --[[ line: 4105 ]]
					-- upvalues: endlessUnitBans0007DataStore (copy), v345 (ref), v346 (write), buildBans (copy)
					endlessUnitBans0007DataStore:UpdateAsync(v345, function(p162) --[[ line: 4106 ]]
						-- upvalues: v346 (copy), buildBans (copy)
						if p162 then
							v343 = p162
							
							return
						end
						v343 = buildBans()
						
						return v343
					end)
				end, 5)
				TowerDefense.EndlessBannedUnits = v346
				TowerDefense.EndlessBannedUpdated:Fire()
			end
		end)
		task.spawn(function() --[[ line: 4132 ]]
			-- upvalues: weekly (write), SharedHelper (copy), endlessUnitBans0007DataStore (copy), buildBans (copy), TowerDefense (copy), GameState (copy), ClientLoader (copy)
			local v347 = nil
			SharedHelper.BackoffRetry(function() --[[ line: 4105 ]]
				-- upvalues: endlessUnitBans0007DataStore (copy), weekly (ref), v347 (write), buildBans (copy)
				endlessUnitBans0007DataStore:UpdateAsync(weekly, function(p163) --[[ line: 4106 ]]
					-- upvalues: v347 (copy), buildBans (copy)
					if p163 then
						v343 = p163
						
						return
					end
					v343 = buildBans()
					
					return v343
				end)
			end, 5)
			TowerDefense.EndlessBannedUnits = v347
			TowerDefense.EndlessBannedUpdated:Fire()
			
			if not SharedHelper.IsEndlessAsync() then
				return
			end
			local t_2 = {}
			
			local function checkPlayerForBanned(p164) --[[ line: 4139 ]]
				-- upvalues: SharedHelper (copy), GameState (copy), t_2 (ref), ClientLoader (copy), TowerDefense (copy)
				if SharedHelper.IsTestingServer() then
					return
				end
				if SharedHelper.IsSandboxAsync() then
					return
				end
				if GameState.MapData.Params.IgnoreEndlessBans then
					return
				end
				if t_2[tostring(p164.UserId)] then
					p164:Kick(t_2[tostring(p164.UserId)] .. " is temporarily banned from Endless, please unequip this Unit to meet the requirements.")
					
					return
				end
				ClientLoader.Modules.ServerDataHandler.WaitPlayerData(p164)
				
				for i, v in ClientLoader.Modules.ServerDataHandler.GetEquippedItems(p164, "Units") do
					local _, v350 = ClientLoader.Modules.ServerDataHandler.HasInInventory(p164, v)
					
					if v350 then
						local iD = v350.ItemData.ID
						local item = ClientLoader.Modules.SharedItemData.GetItem(iD)
						
						if table.find(TowerDefense.EndlessBannedUnits, item.Params.BaseUnit or iD) then
							t_2[tostring(p164.UserId)] = item.Params.Name
							p164:Kick(item.Params.Name .. " is temporarily banned from Endless, please unequip this Unit to meet the requirements.")
							
							return
						end
					end
				end
			end
			
			game.Players.PlayerAdded:Connect(checkPlayerForBanned)
			
			for i, v in game.Players:GetPlayers() do
				task.spawn(checkPlayerForBanned, v)
			end
		end)
		require(ClientLoader.Modules.ServerAdminAbuse.EventsContainer:WaitForChild("PlaySound")).Load(ClientLoader)
		
		if GameState.MapData.Params.IsMorphMode then
			CallGameModeFunction("SetupPlayersAsUnits")
		end
	end, "STDH - endless bans")
end

function ClientLoad() --[[ line: 4185 ]]
	-- upvalues: TowerDefense (ref), SharedHelper (write), ClientLoader (write)
	TowerDefense.LightingSerializer = require(script:WaitForChild("lightingSerializer"))
	
	function TowerDefense.PlaceUnit(unitName, table) --[[ line: 4188 ]]
		-- upvalues: SharedHelper (copy), ClientLoader (copy)
		local success, id = SharedHelper.InvokeRemoteFunction("PlaceUnit", unitName, table)
		print("Placed:", success)
		
		if not success then
			ClientLoader.Modules.ClientGUIHandler.ShowMessage(success or "Something went wrong...", "warn", { SideForPhone = true })
		end
		return success, id
	end
	
	function TowerDefense.SellUnit(p167) --[[ line: 4196 ]]
		-- upvalues: SharedHelper (copy), ClientLoader (copy)
		local sellUnit, sellUnit_1 = SharedHelper.InvokeRemoteFunction("SellUnit", p167)
		print("Sold:", sellUnit)
		
		if not sellUnit then
			ClientLoader.Modules.ClientGUIHandler.ShowMessage(sellUnit_1 or "Something went wrong...", "warn", { SideForPhone = true })
		end
		return sellUnit
	end
	
	function TowerDefense.UpgradeUnit(p168) --[[ line: 4204 ]]
		-- upvalues: SharedHelper (copy), ClientLoader (copy)
		local upgradeUnit, upgradeUnit_1 = SharedHelper.InvokeRemoteFunction("UpgradeUnit", p168)
		
		if not upgradeUnit then
			ClientLoader.Modules.ClientGUIHandler.ShowMessage(upgradeUnit_1 or "Something went wrong...", "warn", { SideForPhone = true })
		end
		return upgradeUnit, upgradeUnit_1
	end
	
	function TowerDefense.LockUnit(p169) --[[ line: 4211 ]]
		-- upvalues: SharedHelper (copy), ClientLoader (copy)
		local lockUnit, lockUnit_1 = SharedHelper.InvokeRemoteFunction("LockUnit", p169)
		
		if not lockUnit then
			ClientLoader.Modules.ClientGUIHandler.ShowMessage(lockUnit_1 or "Something went wrong...", "warn", { SideForPhone = true })
		end
		return lockUnit, lockUnit_1
	end
	
	function TowerDefense.ToggleAutoUpgrade(p170) --[[ line: 4218 ]]
		-- upvalues: SharedHelper (copy), ClientLoader (copy)
		local toggleAutoUpgrade, toggleAutoUpgrade_1 = SharedHelper.InvokeRemoteFunction("ToggleAutoUpgrade", p170)
		
		if not toggleAutoUpgrade then
			ClientLoader.Modules.ClientGUIHandler.ShowMessage(toggleAutoUpgrade_1 or "Something went wrong...", "warn", { SideForPhone = true })
		end
		return toggleAutoUpgrade, toggleAutoUpgrade_1
	end
	
	function TowerDefense.ToggleAutoUpgradePriority(p171) --[[ line: 4225 ]]
		-- upvalues: SharedHelper (copy), ClientLoader (copy)
		local toggleAutoUpgradePriority, toggleAutoUpgradePriority_1 = SharedHelper.InvokeRemoteFunction("ToggleAutoUpgradePriority", p171)
		
		if not toggleAutoUpgradePriority then
			ClientLoader.Modules.ClientGUIHandler.ShowMessage(toggleAutoUpgradePriority_1 or "Something went wrong...", "warn", { SideForPhone = true })
		end
		return toggleAutoUpgradePriority, toggleAutoUpgradePriority_1
	end
	
	function TowerDefense.UpgradeAll() --[[ line: 4233 ]]
		-- upvalues: SharedHelper (copy), ClientLoader (copy)
		local upgradeAll, upgradeAll_1 = SharedHelper.InvokeRemoteFunction("UpgradeAll")
		
		if not upgradeAll then
			ClientLoader.Modules.ClientGUIHandler.ShowMessage(upgradeAll_1 or "Something went wrong...", "warn", { SideForPhone = true })
		end
		return upgradeAll, upgradeAll_1
	end
	
	function TowerDefense.SellAll() --[[ line: 4240 ]]
		-- upvalues: SharedHelper (copy), ClientLoader (copy)
		local sellAll, sellAll_1 = SharedHelper.InvokeRemoteFunction("SellAll")
		
		if not sellAll then
			ClientLoader.Modules.ClientGUIHandler.ShowMessage(sellAll_1 or "Something went wrong...", "warn", { SideForPhone = true })
		end
		return sellAll, sellAll_1
	end
	
	task.spawn(function() --[[ line: 4250 ]]
		-- upvalues: TowerDefense (copy)
		local function updateModifiers() --[[ line: 4251 ]]
			-- upvalues: TowerDefense (copy)
			for i, v in pairs(string.split(game.Workspace:GetAttribute("ActiveModifiers") or "", ";")) do
				if v ~= "" then
					TowerDefense.ApplyModifier(v, "itemdata")
				end
			end
		end
		
		updateModifiers()
		game.Workspace:GetAttributeChangedSignal("ActiveModifiers"):Connect(updateModifiers)
	end)
end

function CallGameModeFunction(p172, ...) --[[ line: 4263 ]]
	-- upvalues: v11 (write), GameState (ref), SharedHelper (write)
	if v11 then
		return GameState[v11][p172](...)
	end
	if SharedHelper.IsDungeonAsync() then
		if GameState.Dungeon[p172] then
			return GameState.Dungeon[p172](...)
		end
		return
	end
	if SharedHelper.IsTdGameAsync() then
		if GameState.TowerDefense[p172] then
			return GameState.TowerDefense[p172](...)
		end
	end
	if SharedHelper.IsAdminArenaAsync() and GameState.AdminArena[p172] then
		return GameState.AdminArena[p172](...)
	end
end

function TowerDefense.Load(p173) --[[ line: 4282 ]]
	-- upvalues: ClientLoader (write), SharedHelper (write), GameConfig (write), TowerDefense (ref), GameState (ref), IsPlayerReady (write)
	ClientLoader = p173
	SharedHelper = ClientLoader.Modules.SharedHelper
	GameConfig = ClientLoader.Config
	TowerDefense.RankedPlay = require(script:WaitForChild("RankedPlay"))
	TowerDefense.RankedPlay.Load(ClientLoader)
	TowerDefense.UnitInventoryManager = require(script:WaitForChild("UnitInventoryManager"))
	TowerDefense.UnitInventoryManager.Load(ClientLoader, TowerDefense, SharedHelper)
	TowerDefense.EndlessRewards = require(script:WaitForChild("EndlessRewards"))
	
	for i, v in pairs({ "TowerDefense", "Dungeon", "AdminArena" }) do
		GameState[v] = require(script:WaitForChild("GameMode_" .. v))
		GameState[v].Load(ClientLoader, TowerDefense)
	end
	if ClientLoader.IsServer then
		ServerLoad()
	else
		ClientLoad()
	end
	CallGameModeFunction("Init")
	CallGameModeFunction("LoadPath")
	
	if ClientLoader.IsClient then
		task.spawn(function() --[[ line: 4306 ]]
			-- upvalues: ClientLoader (copy), SharedHelper (copy)
			local item = ClientLoader.Modules.SharedItemData.GetItem(SharedHelper.GetMapAsync())
			
			if item.Params.OnMapLoaded then
				item.Params.OnMapLoaded(item.Params)
			end
		end)
		
		return
	end
	SharedHelper.OnRemoteEvent("PlayerReady", function() --[[ line: 4314 ]]
		-- upvalues: IsPlayerReady (copy)
		IsPlayerReady = true
	end)
end

return TowerDefense