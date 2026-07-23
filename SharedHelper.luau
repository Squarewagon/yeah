-- Script Path: game:GetService("Players").Pawn2025.PlayerGui.LogicHolder.ClientLoader.Modules.SharedHelper
-- Took 0.69s to decompile.
-- Executor: Delta (1.2.729.840)

local SharedHelper = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local v_u_5 = nil
function SharedHelper.SafeCall(p6, ...)
    if p6 then
        if typeof(p6) == "function" then
            return p6(...)
        end
    end
end
function SharedHelper.CallFunction(p7, ...)
    if p7 then
        if type(p7) == "string" then
            return v_u_5.Modules.SharedItemData.GetItem(p7).Call(...)
        else
            return p7(...)
        end
    else
        return
    end
end
function SharedHelper.TableInsert(p8, p9)
    for _, v10 in pairs(p9) do
        table.insert(p8, v10)
    end
end
function SharedHelper.IsFiniteNumber(p11)
    local v12
    if type(p11) == "number" and p11 == p11 then
        v12 = math.abs(p11) ~= (1 / 0)
    else
        v12 = false
    end
    return v12
end
function SharedHelper.Strikethrough(p13)
    local v14 = ""
    for v15 in utf8.graphemes(p13) do
        v14 = v14 .. v15 .. utf8.char(822)
    end
    return v14
end
function SharedHelper.ChildrenToAbsoluteSizeY(p16)
    for _, v17 in pairs(p16:GetChildren()) do
        if v17:IsA("GuiObject") then
            v17.Size = UDim2.new(v17.Size.X.Scale, v17.Size.X.Offset, 0, v17.AbsoluteSize.Y)
        end
    end
end
function SharedHelper.AliveSurvivalBases()
    local v18 = 0
    for _, v19 in CollectionService:GetTagged("SurvivalBase") do
        if v19:IsDescendantOf(game.Workspace) and not v19:HasTag("SurvivalBaseDead") then
            v18 = v18 + 1
        end
    end
    return v18
end
function SharedHelper.RandomPointInPartXZ(p20, p21)
    local v22 = p20.Size.X * 0.5
    local v23 = p20.Size.Z * 0.5
    local v24 = (math.random() * 2 - 1) * v22
    local v25 = (math.random() * 2 - 1) * v23
    local newVector3_26 = Vector3.new(v24, 0, v25)
    local cframe_27 = p20.CFrame:PointToWorldSpace(newVector3_26)
    local v28 = cframe_27.X
    local v29 = cframe_27.Z
    return Vector3.new(v28, p21, v29)
end
function SharedHelper.ToPersistentModel(p30)
    if p30 then
        local ModelInstance_31 = Instance.new("Model")
        ModelInstance_31.Name = p30.Name
        ModelInstance_31.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
        ModelInstance_31.Parent = p30.Parent
        for _, v32 in pairs(p30:GetChildren()) do
            v32.Parent = ModelInstance_31
        end
        for v33, v34 in pairs(p30:GetAttributes()) do
            ModelInstance_31:SetAttribute(v33, v34)
        end
        p30:Destroy()
        return ModelInstance_31
    end
end
function SharedHelper.ToModel(p35)
    if p35 then
        if p35.ClassName == "Model" then
            return p35
        end
        local ModelInstance_36 = Instance.new("Model")
        ModelInstance_36.Name = p35.Name
        ModelInstance_36.Parent = p35.Parent
        for _, v37 in pairs(p35:GetChildren()) do
            v37.Parent = ModelInstance_36
        end
        p35:Destroy()
        return ModelInstance_36
    end
end
function SharedHelper.FilterTextBox(p38, p39)
    local v40 = tostring(p38)
    return string.sub(v40, 1, p39 or 250)
end
function SharedHelper.FindFirstDescendantOfClass(p41, p42)
    local v43
    if p41 then
        v43 = p41:IsA("Instance")
    else
        v43 = p41
    end
    assert(v43, "First argument must be an Instance")
    local v44 = type(p42) == "string"
    assert(v44, "Second argument must be a string")
    for _, v45 in ipairs(p41:GetDescendants()) do
        if v45:IsA(p42) then
            return v45
        end
    end
    return nil
end
function SharedHelper.GetServerNameAsync()
    local v46 = SharedHelper.IsTdGameAsync() and "TD Game" or "Lobby"
    local v47 = SharedHelper.IsAfkAsync() and "AFK Place" or v46
    return SharedHelper.IsTradingPlazaAsync() and "Trading Plaza" or v47
end
function SharedHelper.IsTestingServer()
    for _, v48 in pairs(v_u_5.Config.TeleportPlaces) do
        if game.PlaceId == v48.Test then
            return true
        end
    end
    return game.PlaceId == 123663235715246
end
function SharedHelper.IsPrivateServer()
    local v49
    if game.PrivateServerId == "" then
        v49 = false
    else
        v49 = game.PrivateServerOwnerId ~= 0
    end
    return v49
end
function SharedHelper.TradingCheckIsPrivateServer(p50)
    if table.find({ 16102594, 3653648850 }, p50.UserId) then
        return false
    else
        return SharedHelper.IsPrivateServer()
    end
end
function SharedHelper.IsAdmin(p51)
    return table.find({ "16102594", "3653648850" }, (tostring(p51))) and true or false
end
function SharedHelper.IsPlaceTrapsFreelyAsync()
    return SharedHelper.IsDungeonAsync() and true or (SharedHelper.IsAdminArenaAsync() and game.Workspace:GetAttribute("PlaceTrapsFreely") and true or false)
end
function SharedHelper.GetPlaceableModels()
    local v52 = SharedHelper.FindFirstChild(game.Workspace, "Map", "Placeable")
    local CollectionService = game:GetService("CollectionService"):GetTagged("Placeable")
    if not table.find(CollectionService, v52) and v52 then
        table.insert(CollectionService, v52)
    end
    return CollectionService
end
function SharedHelper.GetPath()
    return SharedHelper.FindFirstChild(game.Workspace, "Map", "Path") or SharedHelper.FindFirstChild(game.Workspace, "Map", "LoadedGame", "Path")
end
local function waitForWorkspaceAttribute(p54)
    local v55 = game.Workspace:GetAttribute(p54)
    while v55 == nil do
        game.Workspace:GetAttributeChangedSignal(p54):Wait()
        v55 = game.Workspace:GetAttribute(p54)
    end
    return v55
end
function SharedHelper.IsDungeonAsync()
    return waitForWorkspaceAttribute("IsDungeon")
end
function SharedHelper.IsAdminArenaAsync()
    return waitForWorkspaceAttribute("IsAdminArena")
end
function SharedHelper.IsAdminAbuseActive()
    return game.Workspace:GetAttribute("AdminAbuseActive")
end
function SharedHelper.GetMinigamesStatus()
    local v57 = os.time(os.date("!*t"))
    local v58 = os.date("!*t", v57)
    local v59 = v57 - (v58.hour * 3600 + v58.min * 60 + v58.sec)
    local v60 = v58.wday % 7
    if SharedHelper.IsTestingServer() then
        local v61 = v59 - v60 * 86400
        local v62 = v61 + 86400
        if v57 < v62 then
            return true, v62 - v57
        else
            return false, v61 + 604800 - v57
        end
    else
        local v63 = v59 - v60 * 86400 + 54000
        if v57 < v63 then
            v63 = v63 - 604800
        end
        local v64 = v63 + 86400
        if v57 < v64 then
            return true, v64 - v57
        else
            return false, v63 + 604800 - v57
        end
    end
end
function SharedHelper.IsMorphModeAsync()
    return waitForWorkspaceAttribute("IsMorphMode")
end
function SharedHelper.IsPvpAsync()
    return waitForWorkspaceAttribute("IsPVP")
end
function SharedHelper.IsPVPNoYield()
    return game.Workspace:GetAttribute("IsPVP") and true or false
end
function SharedHelper.IsRankedPvpAsync()
    local v65 = SharedHelper.IsPvpAsync()
    if v65 then
        v65 = game.Workspace:GetAttribute("MMRanked")
    end
    return v65
end
function SharedHelper.IsTdGameAsync()
    return waitForWorkspaceAttribute("IsTDGame")
end
function SharedHelper.IsAfkAsync()
    return waitForWorkspaceAttribute("IsAFK")
end
function SharedHelper.IsTradingPlazaAsync()
    return waitForWorkspaceAttribute("MapId") == "map_trading"
end
function SharedHelper.GetMapAsync()
    return waitForWorkspaceAttribute("MapId")
end
function SharedHelper.IsLobbyAsync()
    local v66 = not (SharedHelper.IsTdGameAsync() or SharedHelper.IsAfkAsync())
    if v66 then
        v66 = not SharedHelper.IsTradingPlazaAsync()
    end
    return v66
end
function SharedHelper.IsEndlessAsync()
    if SharedHelper.IsTdGameAsync() then
        return waitForWorkspaceAttribute("Difficulty") == "dif_endless"
    else
        return false
    end
end
function SharedHelper.IsSandboxAsync()
    if SharedHelper.IsTdGameAsync() then
        return waitForWorkspaceAttribute("IsSandbox")
    else
        return false
    end
end
local FastSignal = require(script:WaitForChild("FastSignal"))
local v_u_68 = {}
function InitSignal(p69)
    if not v_u_68[p69] then
        v_u_68[p69] = FastSignal.new()
    end
    return v_u_68[p69]
end
function SharedHelper.GetSignalLastValues(p70, ...)
    local v71 = InitSignal(p70)
    if v71.LastValues then
        local v72 = v71.LastValues
        local v73 = v71.LastValues.n
        return table.unpack(v72, 1, v73)
    end
end
function SharedHelper.FireSignal(p74, ...)
    local v75 = InitSignal(p74)
    v75.LastValues = table.pack(...)
    v75:Fire(...)
end
function SharedHelper.OnSignal(p76, p77, p78)
    local v79 = InitSignal(p76)
    if p78 and v79.LastValues then
        local v80 = v79.LastValues
        local v81 = v79.LastValues.n
        p77(table.unpack(v80, 1, v81))
    end
    return v79:Connect(p77)
end
function SharedHelper.StringBeginsWith(p82, p83)
    local v84 = #p83
    return string.sub(p82, 1, v84) == p83
end
function SharedHelper.GetSubTable(p85, p86, ...)
    if p85 then
        if not p86 then
            return p85
        end
        if type(p85) == "table" then
            local v87 = p85[p86]
            return SharedHelper.GetSubTable(v87, ...)
        end
    end
end
function SharedHelper.MoveModel(p88, p89)
    p88:PivotTo(p89)
end
function SharedHelper.SafeRandom(p90, p91, p92)
    local v93 = SharedHelper.GetRandom(0, 1, 100000)
    local v94 = p90 + (p91 - p90) * v93
    if p92 then
        v94 = SharedHelper.RoundTo(v94, p92)
    end
    return v94
end
function SharedHelper.MapIsUnlocked(p95, p96, p97)
    if p97 then
        local v98 = v_u_5.Modules.SharedItemData.GetItem(p96)
        if v98 then
            if v98.Params.UnlockRequirement2 then
                if v98.Params.UnlockRequirement2[p97] then
                    return v98.Params.UnlockRequirement2[p97].Check(p95), v98.Params.UnlockRequirement2[p97]
                else
                    return true
                end
            else
                return true
            end
        else
            return true
        end
    else
        return true
    end
end
function SharedHelper.MapIsUnlocked2(p99, p100)
    local v101 = v_u_5.Modules.SharedItemData.GetItem(p100)
    if not v101 then
        return true
    end
    if not v101.Params.UnlockRequirement then
        return true
    end
    local v102 = p99 or {}
    local v103 = {}
    local v104 = true
    for _, v105 in pairs(v101.Params.UnlockRequirement) do
        local v106 = v102[v105.Map] or {
            ["GamesWon"] = 0
        }
        if v106.GamesWon < v105.Amount then
            v104 = false
        end
        local v107 = {
            ["Map"] = v105.Map,
            ["Amount"] = v105.Amount,
            ["Progress"] = v106.GamesWon
        }
        table.insert(v103, v107)
    end
    return v104, v103
end
function SharedHelper.CurveValue(p108, p109)
    for v110 = 1, #p109 - 1 do
        local v111 = p109[v110][1]
        local v112 = p109[v110][2]
        local v113 = p109[v110 + 1][1]
        local v114 = p109[v110 + 1][2]
        if p108 <= v111 then
            return v112
        end
        if p108 <= v113 then
            local v115 = (p108 - v111) / (v113 - v111)
            return v112 + (v114 - v112) * v115
        end
    end
    return p109[#p109][2]
end
function SharedHelper.BuildCage(p116, p117, p118)
    local v119 = p116.Size * 0.5
    local v120 = p117 or 1
    local v121 = Instance.new("Folder", p118)
    v121.Name = "Cage"
    local cframe_122 = p116.CFrame
    local v123 = cframe_122 * CFrame.new(v119.X, v119.Y, 0)
    local v124 = p116.Size.Y
    local v125 = p116.Size.Z
    local newVector3_126 = Vector3.new(v120, v124, v125)
    local PartInstance_127 = Instance.new("Part")
    PartInstance_127.Size = newVector3_126
    local v128 = v119.Y
    PartInstance_127.CFrame = v123 - Vector3.new(0, v128, 0)
    PartInstance_127.Anchored = true
    PartInstance_127.CanCollide = true
    PartInstance_127.Transparency = 1
    PartInstance_127.Parent = v121
    local v129 = cframe_122 * CFrame.new(-v119.X, v119.Y, 0)
    local v130 = p116.Size.Y
    local v131 = p116.Size.Z
    local newVector3_132 = Vector3.new(v120, v130, v131)
    local PartInstance_133 = Instance.new("Part")
    PartInstance_133.Size = newVector3_132
    local v134 = v119.Y
    PartInstance_133.CFrame = v129 - Vector3.new(0, v134, 0)
    PartInstance_133.Anchored = true
    PartInstance_133.CanCollide = true
    PartInstance_133.Transparency = 1
    PartInstance_133.Parent = v121
    local v135 = cframe_122 * CFrame.new(0, v119.Y, v119.Z)
    local v136 = p116.Size.X
    local v137 = p116.Size.Y
    local newVector3_138 = Vector3.new(v136, v137, v120)
    local PartInstance_139 = Instance.new("Part")
    PartInstance_139.Size = newVector3_138
    local v140 = v119.Y
    PartInstance_139.CFrame = v135 - Vector3.new(0, v140, 0)
    PartInstance_139.Anchored = true
    PartInstance_139.CanCollide = true
    PartInstance_139.Transparency = 1
    PartInstance_139.Parent = v121
    local v141 = cframe_122 * CFrame.new(0, v119.Y, -v119.Z)
    local v142 = p116.Size.X
    local v143 = p116.Size.Y
    local newVector3_144 = Vector3.new(v142, v143, v120)
    local PartInstance_145 = Instance.new("Part")
    PartInstance_145.Size = newVector3_144
    local v146 = v119.Y
    PartInstance_145.CFrame = v141 - Vector3.new(0, v146, 0)
    PartInstance_145.Anchored = true
    PartInstance_145.CanCollide = true
    PartInstance_145.Transparency = 1
    PartInstance_145.Parent = v121
    local v147 = cframe_122 * CFrame.new(0, p116.Size.Y, 0)
    local v148 = p116.Size.X
    local v149 = p116.Size.Z
    local newVector3_150 = Vector3.new(v148, v120, v149)
    local PartInstance_151 = Instance.new("Part")
    PartInstance_151.Size = newVector3_150
    local v152 = v119.Y
    PartInstance_151.CFrame = v147 - Vector3.new(0, v152, 0)
    PartInstance_151.Anchored = true
    PartInstance_151.CanCollide = true
    PartInstance_151.Transparency = 1
    PartInstance_151.Parent = v121
    return v121
end
function SharedHelper.CapitalizeFirst(p153)
    local v154 = string.lower(p153)
    return string.upper((string.sub(v154, 1, 1))) .. string.sub(v154, 2)
end
function SharedHelper.CamelToSpaced(p155)
    return p155:gsub("[_%-%./]", " "):gsub("(%u)(%u%l)", "%1 %2"):gsub("(%l)(%u)", "%1 %2"):gsub("(%a)(%d)", "%1 %2"):gsub("(%d)(%a)", "%1 %2"):gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
end
function SharedHelper.CountdownLabel(p_u_156, p_u_157, p_u_158, p_u_159, p_u_160)
    local v161 = p_u_157 - SharedHelper.GetUTC()
    if v161 <= 0 then
        p_u_156.Text = p_u_159
    else
        p_u_156.Text = p_u_158 .. SharedHelper.CurrencyTextFormat(v161, p_u_160 or "eventtime")
    end
    task.spawn(function()
        while p_u_156 do
            if not p_u_156.Parent then
                return
            end
            local v162 = p_u_157 - SharedHelper.GetUTC()
            if v162 <= 0 then
                p_u_156.Text = p_u_159
            else
                p_u_156.Text = p_u_158 .. SharedHelper.CurrencyTextFormat(v162, p_u_160 or "eventtime")
            end
            task.wait(1 - tick() % 1)
        end
    end)
end
function SharedHelper.Countdown(p163, p164, p_u_165, p166)
    local v167 = p163 < 0 and 0 or p163
    local v168 = p164 or {
        86400,
        43200,
        21600,
        10800,
        7200,
        3600,
        900,
        300
    }
    if v167 < v168[1] and (v167 > 0 and not p166) then
        p_u_165(v167)
    end
    local v169 = {}
    for _, v_u_170 in pairs(v168) do
        if v_u_170 < v167 then
            local v171 = v167 - v_u_170
            task.delay(v171, function()
                p_u_165(v_u_170)
            end)
            table.insert(v169, v171)
        end
    end
    task.delay(v167, function()
        p_u_165(0)
    end)
end
function SharedHelper.GetModelYBounds(p172)
    local v173, v174 = p172:GetBoundingBox()
    local v175 = v174.Y / 2
    return v173.Position.Y - v175, v173.Position.Y + v175
end
function SharedHelper.GetPartYExtremes(p176)
    local cframe_177 = p176.CFrame
    local v178 = p176.Size * 0.5
    local v179 = cframe_177.RightVector.Y
    local v180 = math.abs(v179) * v178.X
    local v181 = cframe_177.UpVector.Y
    local v182 = v180 + math.abs(v181) * v178.Y
    local v183 = cframe_177.LookVector.Y
    local v184 = v182 + math.abs(v183) * v178.Z
    return cframe_177.Position.Y - v184, cframe_177.Position.Y + v184
end
function SharedHelper.GetAbsoluteContentSize(p185, p186)
    local v_u_187 = (1 / 0)
    local v_u_188 = (1 / 0)
    local v_u_189 = (-1 / 0)
    local v_u_190 = (-1 / 0)
    local function crawl(p191)
        if p191:IsA("GuiObject") and (p191.Visible and not p191:HasTag("IgnoreInContentSizeCalculation")) then
            local v192 = p191.AbsolutePosition
            local v193 = p191.AbsoluteSize
            local v194 = v_u_187
            local v195 = v192.X
            v_u_187 = math.min(v194, v195)
            local v196 = v_u_188
            local v197 = v192.Y
            v_u_188 = math.min(v196, v197)
            local v198 = v_u_189
            local v199 = v192.X + v193.X
            v_u_189 = math.max(v198, v199)
            local v200 = v_u_190
            local v201 = v192.Y + v193.Y
            v_u_190 = math.max(v200, v201)
            for _, v202 in ipairs(p191:GetChildren()) do
                crawl(v202)
            end
        end
    end
    local v204, v205, v206
    if p186 then
        v204 = v_u_188
        v205 = v_u_190
        v206 = v_u_189
        for _, v207 in ipairs(p185:GetChildren()) do
            crawl(v207)
        end
    else
        crawl(p185)
        v204 = v_u_188
        v205 = v_u_190
        v206 = v_u_189
    end
    if v_u_187 == (1 / 0) then
        return Vector2.zero
    else
        return Vector2.new(v206 - v_u_187, v205 - v204)
    end
end
function SharedHelper.GetModelTopCenter(p208)
    local v209
    if typeof(p208) == "Instance" then
        v209 = p208:IsA("Model")
    else
        v209 = false
    end
    assert(v209, "GetModelTopCenter expects a Model")
    local v210, v211 = p208:GetBoundingBox()
    local v212 = v210.UpVector.Y
    local v213 = math.abs(v212) * v211.Y
    local v214 = v210.RightVector.Y
    local v215 = v213 + math.abs(v214) * v211.X
    local v216 = v210.LookVector.Y
    local v217 = 0.5 * (v215 + math.abs(v216) * v211.Z)
    return v210.Position + Vector3.new(0, v217, 0)
end
game:GetService("PhysicsService")
local v_u_218 = {}
task.spawn(function()
    while task.wait(1) do
        for v219, v220 in v_u_218 do
            if not v219:IsDescendantOf(game) then
                v220:Disconnect()
                v_u_218[v219] = nil
            end
        end
    end
end)
function SharedHelper.ApplyCollisionGroup(p221, p_u_222)
    if typeof(p221) ~= "Instance" or not p221:IsA("Model") then
        error("First argument must be a Model", 2)
    end
    local function setGroup(p223)
        if p223:IsA("BasePart") then
            p223.CollisionGroup = p_u_222
        end
    end
    for _, v225 in ipairs(p221:GetDescendants()) do
        if v225:IsA("BasePart") then
            v225.CollisionGroup = p_u_222
        end
    end
    if not v_u_218[p221] then
        v_u_218[p221] = p221.DescendantAdded:Connect(setGroup)
    end
end
function SharedHelper.GetPartExtremePoint(p226, p227)
    local v232 = p227 and function(p228)
        local v229 = p228.Y == 0 and Vector3.new()
        if v229 then
            p228 = v229
        elseif p228.Y < 0 then
            p228 = -p228 or p228
        end
        return p228
    end or function(p230)
        local v231 = p230.Y == 0 and Vector3.new()
        if v231 then
            p230 = v231
        elseif p230.Y > 0 then
            p230 = -p230 or p230
        end
        return p230
    end
    local cframe_233 = p226.CFrame
    local v234 = p226.Size / 2
    local v235 = v232(cframe_233.RightVector) * v234.X
    local v236 = v232(cframe_233.UpVector) * v234.Y
    local v237 = v232(cframe_233.LookVector) * v234.Z
    return (cframe_233 + v235 + v236 + v237).p
end
function SharedHelper.GetModelCFrame(p238)
    if p238:IsA("BasePart") then
        return p238.CFrame
    elseif p238.ClassName == "Model" then
        if p238.PrimaryPart then
            return p238.PrimaryPart.CFrame
        else
            return p238:GetBoundingBox()
        end
    else
        return SharedHelper.GetModelCFrame(p238.Parent)
    end
end
function SharedHelper.CheckDestroyed(p239)
    return not p239 and true or not p239.Parent
end
function SharedHelper.RoundTo(p240, p241)
    local v242 = (not p241 or type(p241) ~= "number") and 1 or p241
    local v243 = p240 + v242 / 2
    return v243 - v243 % v242
end
function SharedHelper.ReplaceTokensInString(p244, p245)
    for v246, v247 in pairs(p245) do
        local v248 = "{" .. v246 .. "}"
        p244 = string.gsub(p244, v248, v247)
    end
    return p244
end
function SharedHelper.CreateConnectionManager()
    local v_u_256 = {
        ["Connections"] = {},
        ["Disconnect"] = function(_)
            for _, v249 in pairs(v_u_256.Connections) do
                if v249 then
                    v249:Disconnect()
                end
            end
            v_u_256.Connections = {}
        end,
        ["AddConnection"] = function(p250, p251)
            local v_u_252 = p250:Connect(p251)
            local v253 = v_u_256.Connections
            local v254 = v_u_252
            table.insert(v253, v254);
            ({}).Disconnect = function(_)
                if v_u_252 then
                    local v255 = table.find(v_u_256.Connections, v_u_252)
                    if v255 then
                        table.remove(v_u_256.Connections, v255)
                    end
                    v_u_252:Disconnect()
                    v_u_252 = nil
                end
            end
        end
    }
    return v_u_256
end
local v_u_257 = {
    ["Default"] = {
        {
            ["UpTo"] = 100,
            ["Round"] = 5
        },
        {
            ["UpTo"] = 250,
            ["Round"] = 10
        },
        {
            ["UpTo"] = 1000,
            ["Round"] = 25
        },
        {
            ["UpTo"] = 10000,
            ["Round"] = 100
        },
        {
            ["UpTo"] = 100000,
            ["Round"] = 500
        },
        {
            ["UpTo"] = 1000000,
            ["Round"] = 1000
        },
        {
            ["UpTo"] = 10000000,
            ["Round"] = 10000
        },
        {
            ["UpTo"] = 100000000,
            ["Round"] = 100000
        },
        {
            ["UpTo"] = (1 / 0),
            ["Round"] = 1000000
        }
    }
}
function SharedHelper.RoundUsingTable(p258, p259)
    if p259 then
        if type(p259) == "string" then
            p259 = v_u_257[p259]
        end
    else
        p259 = v_u_257.Default
    end
    local v260 = 1
    for _, v261 in pairs(p259) do
        if p258 < v261.UpTo then
            v260 = v261.Round
            break
        end
    end
    local v262 = p258 + v260 / 2
    return v262 - v262 % v260
end
function SharedHelper.BackoffRetry(p_u_263, p264)
    local v265 = p264 or 1
    while true do
        local v266, v267 = pcall(function()
            p_u_263()
        end)
        if v266 then
            break
        end
        warn("BackOff Retry: " .. v267)
        task.wait(v265)
        v265 = v265 * 2
    end
    return v266
end
function SharedHelper.EliminateUpRotation(p268)
    local v269 = p268.p + p268.LookVector
    local v270 = p268.p.Y - v269.Y
    local v271 = v269 + Vector3.new(0, v270, 0)
    return CFrame.new(p268.p, v271)
end
function SharedHelper.ProtectedRetry(p272, p273)
    local v274 = nil
    local v275 = nil
    local v276 = 0
    local v277 = p273 or 5
    while not v274 and v276 < v277 do
        v276 = v276 + v277
        v274, v275 = pcall(p272)
        if not v274 then
            SharedHelper.SafeError("ProtectedRetry: " .. tostring(v275))
            task.wait(0.25)
        end
    end
    return v274, v275
end
local v_u_278 = {}
function SharedHelper.WarnGroup(p_u_279, p280, p281)
    local v_u_282 = v_u_278[p_u_279]
    if not v_u_282 then
        v_u_282 = {
            ["Messages"] = nil,
            ["Count"] = 0,
            ["Messages"] = {}
        }
        v_u_278[p_u_279] = v_u_282
    end
    local v283 = v_u_282.Messages
    table.insert(v283, p280)
    v_u_282.Count = v_u_282.Count + 1
    local v_u_284 = v_u_282.Count
    delay(p281, function()
        if v_u_282.Count == v_u_284 then
            local v285 = p_u_279
            warn("Group warning: " .. tostring(v285))
            print(v_u_282.Messages)
            v_u_278[p_u_279] = nil
        end
    end)
end
function SharedHelper.SafeError(p_u_286)
    SharedHelper.InstantThread(function()
        error(p_u_286)
    end)
end
function SharedHelper.MonitorLoadingTime(p_u_287, p_u_288, p_u_289)
    local tickTime_290 = tick()
    local v_u_291 = nil
    SharedHelper.InstantThread(function()
        local v292 = p_u_289 or 2
        while tickTime_290 do
            local tickTime_293 = tick() - tickTime_290
            if v292 <= tickTime_293 then
                v292 = v292 * 2
                v_u_291 = tickTime_293
                if p_u_288 and tickTime_293 > 60 then
                    local v294 = SharedHelper.SafeError
                    local v295 = p_u_287
                    local v296 = SharedHelper.GetNumber2DecimalsStr
                    v294("[!] Slow Loading Time - " .. v295 .. " - " .. tostring(v296(tickTime_293)) .. "s")
                else
                    local v297 = warn
                    local v298 = p_u_287
                    local v299 = SharedHelper.GetNumber2DecimalsStr
                    v297("[!] Slow Loading Time - " .. v298 .. " - " .. tostring(v299(tickTime_293)) .. "s")
                end
            end
            wait(1)
        end
    end)
    return function()
        local tickTime_300 = tick() - tickTime_290
        tickTime_290 = nil
        if v_u_291 then
            if p_u_288 and tickTime_300 > 60 then
                local v301 = SharedHelper.SafeError
                local v302 = p_u_287
                local v303 = SharedHelper.GetNumber2DecimalsStr
                local v304 = v_u_291
                v301("[ok] Finished Slow Load - " .. v302 .. " - " .. tostring(v303(v304)) .. "s")
                return
            end
            local v305 = warn
            local v306 = p_u_287
            local v307 = SharedHelper.GetNumber2DecimalsStr
            local v308 = v_u_291
            v305("[ok] Finished Slow Load - " .. v306 .. " - " .. tostring(v307(v308)) .. "s")
        end
    end
end
local v_u_309 = nil
function SharedHelper.DebugTime(p310)
    local tickTime_311 = tick()
    if not v_u_309 then
        v_u_309 = tickTime_311
    end
    local v312 = print
    local v313 = tickTime_311 - v_u_309
    v312(p310 .. ": " .. tostring(v313))
    v_u_309 = tickTime_311
end
function SharedHelper.AccessSubTable(p314, p315, ...)
    if not p314 then
        return p314
    end
    if not p315 then
        return p314
    end
    if not p314[p315] then
        p314[p315] = {}
    end
    local v316 = p314[p315]
    return SharedHelper.AccessSubTable(v316, ...)
end
function SharedHelper.ListenToAnimationEvents(p_u_317, p_u_318, p319)
    local v_u_320 = p319 or {}
    local v_u_321 = {}
    local function ListenToEvent(p322, p323)
        local v_u_324 = p322:Connect(p323)
        local v325 = v_u_321
        local v326 = v_u_324
        table.insert(v325, v326);
        ({}).Disconnect = function(_)
            if v_u_324 then
                local v327 = table.find(v_u_321, v_u_324)
                if v327 then
                    table.remove(v_u_321, v327)
                end
                v_u_324:Disconnect()
                v_u_324 = nil
            end
        end
        return v_u_324
    end
    local function StopListeningToEvents()
        for _, v329 in pairs(v_u_321) do
            v329:Disconnect()
        end
        v_u_321 = {}
    end
    SharedHelper.OnDestroy(p_u_318, function()
        StopListeningToEvents()
    end)
    local function GetPP()
        local HumanoidRootPartChild_331 = p_u_318:FindFirstChild("HumanoidRootPart")
        if not HumanoidRootPartChild_331 then
            for _, v332 in pairs(p_u_318:GetChildren()) do
                if v332:IsA("BasePart") then
                    return v332
                end
            end
        end
        return HumanoidRootPartChild_331
    end
    local function SetTransparencyModifier(p334)
        for _, v335 in pairs(p_u_318:GetDescendants()) do
            if v335:IsA("BasePart") and not v335:GetAttribute("ExcludeTransparencyAnimation") then
                v_u_5.Modules.ClientEffectHandler.SetLocalTransparency(v335, "animation", p334)
            end
        end
    end
    ListenToEvent(p_u_317:GetMarkerReachedSignal("PlaySound"), function(p337)
        local v338 = GetPP()
        if v338 then
            if not v_u_320.CheckPlaySound or v_u_320.CheckPlaySound(p337) then
                if v_u_320.GetSound then
                    p337 = v_u_320.GetSound(p337)
                end
                local _, v_u_339 = v_u_5.Modules.ClientSoundHandler.PlaySound(p337, {
                    ["Parent"] = v338
                })
                p_u_317.Stopped:Connect(function()
                    if v_u_339 then
                        if not v_u_320.DontStopSoundsOnTrackStop then
                            v_u_339.Destroy()
                        end
                    else
                        return
                    end
                end)
            end
        else
            warn("RIG HAS NOT PARTS", p_u_318:GetFullName())
            return
        end
    end)
    ListenToEvent(p_u_317:GetMarkerReachedSignal("Particle"), function(p340)
        local v341 = SharedHelper.FindDescendant(p_u_318, p340)
        if v341 then
            if v341.ClassName == "ParticleEmitter" then
                v341:Emit(v341:GetAttribute("EmitAmount") or 1)
            else
                for _, v342 in pairs(v341:GetChildren()) do
                    if v342.ClassName == "ParticleEmitter" then
                        v342:Emit(v342:GetAttribute("EmitAmount") or 1)
                    end
                end
            end
        else
            warn("RIG HAS NO PART NAMED", p340, p_u_318:GetFullName())
            return
        end
    end)
    local v_u_343 = {}
    local v_u_344 = {}
    ListenToEvent(p_u_317:GetMarkerReachedSignal("ParticleOn"), function(p345)
        local v346 = SharedHelper.FindDescendant(p_u_318, p345)
        if v346 then
            v346.Enabled = true
            if not table.find(v_u_343, v346) then
                local v347 = v_u_343
                table.insert(v347, v346)
            end
        else
            return
        end
    end)
    ListenToEvent(p_u_317:GetMarkerReachedSignal("ParticleOff"), function(p348)
        local v349 = SharedHelper.FindDescendant(p_u_318, p348)
        if v349 then
            v349.Enabled = false
        end
    end)
    ListenToEvent(p_u_317:GetMarkerReachedSignal("FadeOut"), function(p350)
        local v351 = tonumber(p350)
        local v_u_353 = SharedHelper.TweenValue("NumberValue", 0, 1, TweenInfo.new(v351, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), function(p352)
            SetTransparencyModifier(p352)
        end)
        local v354 = v_u_344
        table.insert(v354, function()
            v_u_353:Cancel()
        end)
    end)
    ListenToEvent(p_u_317:GetMarkerReachedSignal("FadeIn"), function(p355)
        local v356 = tonumber(p355)
        local v_u_358 = SharedHelper.TweenValue("NumberValue", 1, 0, TweenInfo.new(v356, Enum.EasingStyle.Sine, Enum.EasingDirection.In), function(p357)
            SetTransparencyModifier(p357)
        end)
        local v359 = v_u_344
        table.insert(v359, function()
            v_u_358:Cancel()
        end)
    end)
    local v_u_360 = v_u_344
    for v361, v362 in pairs(v_u_320.ExtraEvents or {}) do
        ListenToEvent(p_u_317:GetMarkerReachedSignal(v361), v362)
    end
    ListenToEvent(p_u_317.Stopped, function()
        for _, v363 in pairs(v_u_360) do
            task.spawn(v363)
        end
        v_u_360 = {}
        SetTransparencyModifier(0)
        for _, v_u_364 in pairs(v_u_343) do
            pcall(function()
                v_u_364.Enabled = false
            end)
        end
    end)
    return StopListeningToEvents
end
function SharedHelper.ChangeScale(p365, p366)
    if p366 ~= 1 then
        for _, v367 in pairs(p365:GetDescendants()) do
            if v367:IsA("BasePart") then
                v367.Size = v367.Size * p366
            end
            if v367:IsA("Motor6D") or (v367:IsA("Weld") or v367:IsA("JointInstance")) then
                local v368 = v367.C0
                v367.C0 = CFrame.new(v368.X * p366, v368.Y * p366, v368.Z * p366) * v367.C0.Rotation
                local v369 = v367.C1
                v367.C1 = CFrame.new(v369.X * p366, v369.Y * p366, v369.Z * p366) * v367.C1.Rotation
            end
        end
    end
end
function SharedHelper.ChangeModelScale(p370, p371)
    if p371 ~= 1 then
        local v372
        if p370 then
            v372 = p370:IsA("Model")
        else
            v372 = p370
        end
        assert(v372, "ChangeScale: first arg must be a Model")
        local v373 = p370.PrimaryPart
        assert(v373, "ChangeScale: Model needs a PrimaryPart")
        local v374
        if type(p371) == "number" then
            v374 = p371 > 0
        else
            v374 = false
        end
        assert(v374, "ChangeScale: scale must be > 0")
        local v375 = p370.PrimaryPart
        for _, v376 in ipairs(p370:GetDescendants()) do
            if v376:IsA("BasePart") then
                v376.Size = v376.Size * p371
                if v376 ~= v375 then
                    local cframe_377 = v375.CFrame:ToObjectSpace(v376.CFrame)
                    local position_378 = cframe_377.Position * p371
                    local position_379 = cframe_377 - cframe_377.Position
                    v376.CFrame = v375.CFrame * (CFrame.new(position_378) * position_379)
                end
            elseif v376:IsA("Attachment") then
                v376.Position = v376.Position * p371
            elseif v376:IsA("SpecialMesh") then
                v376.Scale = v376.Scale * p371
            end
        end
    end
end
function SharedHelper.FindFirstDescendantWithAttribute(p380, p381, p382, p383)
    if not (p380 and p380:IsA("Instance")) then
        return nil
    end
    local v384 = { p380 }
    local v385 = 1
    while v385 <= #v384 do
        local v386 = v384[v385]
        v385 = v385 + 1
        if p383 or v386 ~= p380 then
            local v387 = v386:GetAttribute(p381)
            if v387 ~= nil and (p382 == nil or v387 == p382) then
                return v386
            end
        end
        for _, v388 in ipairs(v386:GetChildren()) do
            table.insert(v384, v388)
        end
    end
    return nil
end
function SharedHelper.GetDescendantsWithAttribute(p389, p390, p391, p392)
    if not (p389 and p389:IsA("Instance")) then
        return {}
    end
    local v393 = { p389 }
    local v394 = 1
    local v395 = {}
    while v394 <= #v393 do
        local v396 = v393[v394]
        v394 = v394 + 1
        if p392 or v396 ~= p389 then
            local v397 = v396:GetAttribute(p390)
            if v397 ~= nil and (p391 == nil or v397 == p391) then
                table.insert(v395, { v396, v397 })
            end
        end
        for _, v398 in ipairs(v396:GetChildren()) do
            table.insert(v393, v398)
        end
    end
    return v395
end
function SharedHelper.GetFValue(p399, ...)
    if type(p399) == "function" then
        return p399(...)
    else
        return p399
    end
end
function SharedHelper.EnableFX(p400, p401)
    if p400 then
        if p401 then
            for _, v402 in pairs(p400:GetDescendants()) do
                if v402:IsA("BasePart") then
                    if v402:GetAttribute("WasNeon") then
                        v402.Material = Enum.Material.Neon
                    elseif v402:GetAttribute("WasForceField") then
                        v402.Material = Enum.Material.ForceField
                        v402.Transparency = 0
                    elseif v402:GetAttribute("WasGlass") then
                        v402.Material = Enum.Material.Glass
                    end
                elseif v402.ClassName == "ParticleEmitter" and v402:GetAttribute("WasActive") then
                    v402.Enabled = true
                end
            end
        else
            for _, v403 in pairs(p400:GetDescendants()) do
                if v403:IsA("BasePart") then
                    if v403.Material == Enum.Material.Neon then
                        v403.Material = Enum.Material.SmoothPlastic
                        v403:SetAttribute("WasNeon", true)
                    elseif v403.Material == Enum.Material.Glass then
                        v403.Material = Enum.Material.SmoothPlastic
                        v403:SetAttribute("WasGlass", true)
                    elseif v403.Material == Enum.Material.ForceField then
                        v403.Material = Enum.Material.SmoothPlastic
                        v403.Transparency = 0.85
                        v403:SetAttribute("WasForceField", true)
                    end
                elseif v403.ClassName == "ParticleEmitter" and v403.Enabled then
                    v403.Enabled = false
                    v403:SetAttribute("WasActive", true)
                end
            end
        end
    else
        return
    end
end
function SharedHelper.AppendTable(p404, p405)
    if not p405 then
        return p404
    end
    for _, v406 in pairs(p405) do
        table.insert(p404, v406)
    end
    return p404
end
function SharedHelper.FindDescendant(p407, p408, p409)
    if p407 then
        for _, v410 in pairs(p407:GetDescendants()) do
            if v410.Name == p408 and (not p409 or p409(v410)) then
                return v410
            end
        end
    end
end
function SharedHelper.GetCharacterFace(p411)
    local v412 = SharedHelper.FindFirstChild(p411, "Head", "face")
    if v412 then
        return v412
    end
    local v413 = SharedHelper.FindFirstChild(p411, "Head", "Face")
    if v413 then
        return v413
    end
    local v414 = SharedHelper.FindFirstChild(p411, "Head")
    if v414 then
        return v414:FindFirstChildOfClass("Decal")
    end
end
function SharedHelper.GetIsFriendsWith(p_u_415, p_u_416)
    if p_u_415 == p_u_416 then
        return
    end
    local v_u_417 = nil
    for _ = 1, 5 do
        if pcall(function()
            v_u_417 = p_u_415:IsFriendsWith(p_u_416.UserId)
        end) or not (p_u_415 and (p_u_416 and (p_u_415.Parent and p_u_416.Parent))) then
            break
        end
        task.wait(30)
    end
    return v_u_417 == true
end
function SharedHelper.GetFriendsInServer(p418)
    local v419 = {}
    for _, v420 in pairs(game.Players:GetPlayers()) do
        if v420 ~= p418 and SharedHelper.GetIsFriendsWith(p418, v420) then
            table.insert(v419, v420)
        end
    end
    return v419
end
function SharedHelper.AreFriends(p421, p422, _)
    return SharedHelper.GetIsFriendsWith(p421, p422)
end
function SharedHelper.GetModelCFrameToPivotToAttachment(p423, p424)
    local v425 = p423.PrimaryPart:FindFirstChild(p424.Name)
    if v425 then
        return p424.WorldCFrame * v425.CFrame:Inverse()
    else
        return p424.WorldCFrame
    end
end
function SharedHelper.PivotModelToAttachment(p426, p427)
    p426:PivotTo(SharedHelper.GetModelCFrameToPivotToAttachment(p426, p427))
end
local v_u_428 = {}
function SharedHelper.GetPlayerImage(p_u_429, p430, p431)
    local v_u_432 = p430 or Enum.ThumbnailType.AvatarThumbnail
    local v_u_433 = p431 or Enum.ThumbnailSize.Size420x420
    local v434 = tostring(p_u_429) .. "/" .. tostring(v_u_432) .. "/" .. tostring(v_u_433)
    if v_u_428[v434] then
        return v_u_428[v434]
    end
    local v_u_435 = nil
    local v436 = 0
    local v_u_437 = nil
    while not v_u_435 and v436 < 5 do
        v436 = v436 + 1
        pcall(function()
            local v438, v439 = game.Players:GetUserThumbnailAsync(p_u_429, v_u_432, v_u_433)
            v_u_435 = v438
            v_u_437 = v439
        end)
        if not v_u_435 then
            wait(1)
        end
    end
    v_u_428[v434] = v_u_435
    return v_u_435
end
function SharedHelper.PWrap(p440, p_u_441, p442, p443)
    local v444 = nil
    local v_u_445 = nil
    local v446 = 0
    local v447 = 2
    local v448 = p442 or 5
    while not v444 do
        v446 = v446 + 1
        local v449
        v444, v449 = pcall(function()
            v_u_445 = p_u_441()
        end)
        if p443 then
            if p443 <= v446 then
                return
            end
        elseif v447 <= v446 then
            v447 = v447 * 2
            warn("Wrapped call id " .. tostring(p440) .. " is getting errors (" .. tostring(v446) .. "): " .. tostring(v449))
        end
        if not v444 then
            wait(v448)
        end
    end
    return v_u_445
end
function SharedHelper.VerbosePCall(p450)
    local v451, v452 = pcall(p450)
    if not v451 then
        warn(v452)
    end
end
function SharedHelper.GetTableAnd(p453)
    for _, v454 in pairs(p453) do
        if not v454 then
            return false
        end
    end
    return true
end
function SharedHelper.LerpPosition(p455, p456, p457)
    return p455 + (p456 - p455) * p457
end
function SharedHelper.ArcPosition(p458, p459, p460, p461, p462)
    local v463 = math.clamp(p461, 0, 1)
    if p462 then
        v463 = p462(v463)
    end
    local v464 = p458:Lerp(p459, v463)
    local v465 = 4 * p460 * v463 * (1 - v463)
    return v464 + Vector3.new(0, v465, 0)
end
function SharedHelper.SetLocalTransparencyInstance(p466, p467, p468)
    local v469 = math.clamp(p468, 0, 1)
    if p466:IsA("BasePart") then
        v_u_5.Modules.ClientEffectHandler.SetLocalTransparency(p466, p467, v469)
        return
    elseif p466.ClassName == "Model" then
        for _, v470 in pairs(p466:GetDescendants()) do
            SharedHelper.SetLocalTransparencyInstance(v470, p467, v469)
        end
    elseif table.find({ "Texture", "Decal" }, p466.ClassName) then
        if p466:GetAttribute("OriginalTransparency") then
            if v469 == 0 then
                p466.Transparency = p466:GetAttribute("OriginalTransparency")
                return
            end
        else
            p466:SetAttribute("OriginalTransparency", p466.Transparency)
        end
        local OriginalTransparencyAttr_471 = p466:GetAttribute("OriginalTransparency")
        if OriginalTransparencyAttr_471 < 1 then
            p466.Transparency = OriginalTransparencyAttr_471 + (1 - OriginalTransparencyAttr_471) * v469
            return
        end
    elseif table.find({ "SurfaceGui" }, p466.ClassName) then
        if v469 == 1 then
            p466.Enabled = false
            return
        end
        p466.Enabled = true
    end
end
function SharedHelper.Disconnect(p_u_472)
    local _, v473 = pcall(function()
        p_u_472:Disconnect()
    end)
    if v473 then
        warn("Error disconnecting event: " .. tostring(v473))
    end
end
function SharedHelper.FormatPlural(p474)
    local v475 = table.find
    local v476 = string.lower
    local v477 = #p474
    local v478 = #p474
    if v475({ "s" }, v476((string.sub(p474, v477, v478)))) then
        return p474
    else
        return p474 .. "s"
    end
end
function SharedHelper.FormatAAn(p479)
    local v480 = table.find
    local v481 = string.lower
    local v482 = #p479
    local v483 = #p479
    if v480({ "s" }, v481((string.sub(p479, v482, v483)))) then
        return "" .. p479
    else
        return SharedHelper.FormatAAnSingular(p479)
    end
end
function SharedHelper.FormatAAnSingular(p484)
    if table.find({
        "a",
        "e",
        "i",
        "o",
        "u"
    }, string.lower((string.sub(p484, 1, 1)))) then
        return "an " .. p484
    else
        return "a " .. p484
    end
end
function SharedHelper.DeepCopy(p485)
    local v486 = {}
    for v487, v489 in pairs(p485) do
        if type(v489) == "table" then
            local v489 = SharedHelper.DeepCopy(v489)
        end
        v486[v487] = v489
    end
    return v486
end
function SharedHelper.OverwriteTable(p490, p491)
    local v492 = SharedHelper.DeepCopy(p490)
    for v493, v494 in pairs(p491) do
        v492[v493] = v494
    end
    return v492
end
function SharedHelper.DeepOverwriteTable(p495, p496)
    local v497 = typeof(p495) ~= "table" and {} or p495
    if typeof(p496) ~= "table" then
        return v497
    end
    for v498, v499 in pairs(p496) do
        if typeof(v499) == "table" then
            local v500 = v497[v498]
            if typeof(v500) ~= "table" then
                goto l8
            end
            SharedHelper.DeepOverwriteTable(v497[v498], v499)
        else
            ::l8::
            v497[v498] = v499
        end
    end
    return v497
end
function SharedHelper.WaitForChild(p501, p502, ...)
    if not p502 then
        return p501
    end
    local v503 = p501:WaitForChild(p502)
    return SharedHelper.WaitForChild(v503, ...)
end
function SharedHelper.FindFirstChild(p504, p505, ...)
    if not p505 then
        return p504
    end
    local v506 = p504:FindFirstChild(p505)
    if v506 then
        return SharedHelper.FindFirstChild(v506, ...)
    end
end
function SharedHelper.Wait(p507)
    if p507 > 0 then
        wait(p507)
    end
end
function SharedHelper.GetGUI(...)
    local GUIChild_508 = ReplicatedStorage:WaitForChild("GUI")
    return SharedHelper.WaitForChild(GUIChild_508, ...)
end
function SharedHelper.GetPlayerList()
    local v509 = {}
    for _, v510 in pairs(game.Players:GetPlayers()) do
        local v511 = v510.Name
        table.insert(v509, v511)
    end
    return v509
end
function SharedHelper.DarkenColor(p512, p513)
    local v514, v515, v516 = p512:ToHSV()
    return Color3.fromHSV(v514, v515, v516 * p513)
end
function SharedHelper.TablePath(p517, p518, ...)
    if not p518 then
        return p517
    end
    local v519 = p517 .. "/" .. p518
    return SharedHelper.TablePath(v519, ...)
end
function SharedHelper.SplitPath(p520)
    return string.split(p520, "/")
end
function SharedHelper.AccessTableByPath(p521, p522, p523)
    local v524 = string.split(p522, "/")
    local v525 = nil
    for _, v526 in pairs(v524) do
        if v526 and v526 ~= "" then
            local v527 = p521[v526]
            v525 = v526
            v524 = p521
            p521 = v527
        end
    end
    if p523 then
        p523(v524, v525)
    end
    return p521
end
function SharedHelper.CheckPosInPart(p528, p529, p530)
    if p528 then
        if p529 then
            local v531 = p530 or 0
            if p528.X < p529.Position.X - p529.Size.X / 2 - v531 then
                return false
            elseif p528.X > p529.Position.X + p529.Size.X / 2 + v531 then
                return false
            elseif p528.Z < p529.Position.Z - p529.Size.Z / 2 - v531 then
                return false
            else
                return p528.Z <= p529.Position.Z + p529.Size.Z / 2 + v531
            end
        else
            return
        end
    else
        return
    end
end
function SharedHelper.CheckPositionInsidePart(p532, p533, p534)
    local v535 = p534 or 0
    local cframe_536 = p533.CFrame:PointToObjectSpace(p532)
    local v537 = cframe_536.X
    local v538
    if math.abs(v537) <= p533.Size.X / 2 + v535 then
        local v539 = cframe_536.Y
        if math.abs(v539) <= p533.Size.Y / 2 + v535 then
            local v540 = cframe_536.Z
            v538 = math.abs(v540) <= p533.Size.Z / 2 + v535
        else
            v538 = false
        end
    else
        v538 = false
    end
    return v538
end
function SharedHelper.GetSettingValue(p541, p542)
    local v543 = v_u_5.Modules.SharedItemData.GetItem(p541)
    if v543 then
        return v_u_5.Modules.SharedItemData.GetItem(v543.Type).GetValue(v543, p542)
    end
    warn("Setting not found: " .. tostring(p541))
end
function SharedHelper.ShuffleArray(p544)
    for v545 = 1, #p544 - 1 do
        local v546 = math.random(v545, #p544)
        local v547 = p544[v546]
        local v548 = p544[v545]
        p544[v545] = v547
        p544[v546] = v548
    end
    return p544
end
function SharedHelper.EncodeCompact(p549)
    local v550 = p549 + 100
    local v551 = tonumber(v550)
    local v552
    if v551 then
        v552 = v551 >= 0
    else
        v552 = v551
    end
    assert(v552, "EncodeCompact expected a positive number")
    if v551 == 0 then
        return ("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#$%&()*+,-.:;<=>?@[]^_`{|}~"):sub(1, 1)
    end
    local v553 = ""
    while v551 > 0 do
        local v554 = v551 % 90 + 1
        v553 = ("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#$%&()*+,-.:;<=>?@[]^_`{|}~"):sub(v554, v554) .. v553
        local v555 = v551 / 90
        v551 = math.floor(v555)
    end
    return v553
end
function SharedHelper.DeterministicShuffle(p556, p557)
    return (function(p558, p559)
        local v560 = table.clone(p558)
        local v561 = 2166136261
        for v562 = 1, #p559 do
            local v563 = string.byte
            v561 = bit32.bxor(v561, v563(p559, v562)) * 16777619 % 4294967296
        end
        local v_u_564 = v561
        local function v569(p565, p566)
            v_u_564 = (1664525 * v_u_564 + 1013904223) % 4294967296
            local v567 = v_u_564 / 4294967296
            if not (p565 and p566) then
                return v567
            end
            local v568 = v567 * (p566 - p565 + 1)
            return math.floor(v568) + p565
        end
        for v570 = #v560, 2, -1 do
            local v571 = v569(1, v570)
            local v572 = v560[v571]
            local v573 = v560[v570]
            v560[v570] = v572
            v560[v571] = v573
        end
        return v560
    end)(p556, (tostring(p557)))
end
function SharedHelper.PlayerInGeneralArea(p574)
    local v575 = v_u_5.Modules.ClientCharacterHandler.LazyPos
    return v575 and SharedHelper.FlatDistance(v575, p574.Position) < 150 and true or false
end
function SharedHelper.GetRandomUnique(p_u_576, p_u_577)
    local v_u_578 = nil
    local function getnext()
        if #v_u_578 <= 0 then
            if p_u_577 then
                return
            end
            v_u_578 = SharedHelper.DeepCopy(p_u_576)
            v_u_578 = SharedHelper.ShuffleArray(v_u_578)
        end
        local v579 = v_u_578[1]
        table.remove(v_u_578, 1)
        return v579
    end
    v_u_578 = SharedHelper.DeepCopy(p_u_576)
    v_u_578 = SharedHelper.ShuffleArray(v_u_578)
    return getnext
end
function SharedHelper.ShuffleArray2(p581)
    local v582 = {}
    while #p581 > 0 do
        local v583 = math.random(1, #p581)
        local v584 = p581[v583]
        table.insert(v582, v584)
        table.remove(p581, v583)
    end
    return v582
end
function SharedHelper.IterateRandomly(p585, p586)
    local v587 = {}
    for v588, _ in pairs(p585) do
        table.insert(v587, v588)
    end
    SharedHelper.ShuffleArray(v587)
    for _, v589 in pairs(v587) do
        if p586(p585[v589], v589) then
            return
        end
    end
end
function SharedHelper.Ghostify(p590)
    SharedHelper.ApplyCollisionGroup(p590, "NONE")
    for _, v591 in pairs(p590:GetDescendants()) do
        if v591:IsA("BasePart") then
            v591.Transparency = (v591.Transparency + 1) / 2
            v591.CanCollide = false
            v591.CanQuery = false
            v591.Anchored = true
        end
        if v591.ClassName == "Script" then
            v591:Destroy()
        end
    end
end
function SharedHelper.AnchoredNoCollisions(p592)
    SharedHelper.ApplyCollisionGroup(p592, "NONE")
    for _, v593 in pairs(p592:GetDescendants()) do
        if v593:IsA("BasePart") then
            v593.CanCollide = false
            v593.Anchored = true
        end
    end
end
function SharedHelper.ChangeModelColor(p594, p595)
    for _, v596 in pairs(p594:GetDescendants()) do
        if not v596:GetAttribute("IgnoreColorChange") then
            if v596:IsA("BasePart") then
                v596.Color = p595
            elseif v596.ClassName == "SpecialMesh" then
                local v597 = p595.R
                local v598 = p595.G
                local v599 = p595.B
                v596.VertexColor = Vector3.new(v597, v598, v599)
            end
        end
    end
end
function SharedHelper.AssetFormat(p600)
    if not p600 or p600 == "CHANGE_ME" then
        return "rbxassetid://9737276270"
    end
    local v601 = tostring(p600)
    if string.sub(v601, 1, 13) ~= "rbxassetid://" then
        local v602 = tostring(p600)
        if string.sub(v602, 1, 11) ~= "rbxasset://" then
            local v603 = tostring(p600)
            if string.sub(v603, 1, 11) ~= "rbxthumb://" then
                return "rbxassetid://" .. tostring(p600)
            end
        end
    end
    return p600
end
function SharedHelper.CreateFolder(p604, p605)
    local FolderInstance_606 = Instance.new("Folder")
    FolderInstance_606.Name = p604
    FolderInstance_606.Parent = p605
    return FolderInstance_606
end
function SharedHelper.FilterTable(p607, p608)
    local v609 = {}
    local v610 = {}
    for v611, v612 in pairs(p607) do
        if p608(v612, v611) then
            if type(v611) == "string" then
                v609[v611] = v612
                table.insert(v610, v611)
            else
                table.insert(v609, v612)
            end
        end
    end
    return v609, v610
end
function SharedHelper.CreateSubscription()
    local v_u_613 = {}
    local v_u_614 = {}
    local v_u_615 = {}
    local v_u_616 = false
    function v_u_613.Fire(...)
        v_u_616 = true
        v_u_615 = table.pack(...)
        for _, v617 in pairs(v_u_614) do
            task.spawn(v617, ...)
        end
    end
    function v_u_613.Subscribe(p618, p619, p620)
        if v_u_614[p618] then
            warn("Subscriber " .. tostring(p618) .. " already exists!")
            print(v_u_613)
            print(v_u_614)
        end
        v_u_614[p618] = p619
        if p620 and v_u_616 then
            local v621 = v_u_615
            local v622 = v_u_615.n
            p619(table.unpack(v621, 1, v622))
        end
    end
    function v_u_613.Unsubscribe(p623)
        v_u_614[p623] = nil
    end
    return v_u_613
end
function SharedHelper.CreateAndGate(p_u_624, p_u_625)
    local v_u_626 = {}
    local v_u_627 = {}
    local v_u_628 = false
    function v_u_626.Update()
        if p_u_625 then
            print("UPDATE!")
        end
        local v629 = true
        for _, v630 in pairs(v_u_627) do
            if not v630 then
                v629 = false
                break
            end
        end
        if p_u_625 then
            print("now", v629)
            print("last", v_u_628)
        end
        local v631 = v_u_628
        v_u_628 = v629
        if v629 and not v631 then
            p_u_624.OnActivate()
        elseif not v629 and v631 then
            p_u_624.OnDeactivate()
        end
        if p_u_625 then
            print("AND GATE")
            print(v_u_627)
        end
    end
    function v_u_626.Deactivate(p632)
        if p_u_625 then
            print("SET ", p632, false)
        end
        if v_u_627[p632] ~= false then
            v_u_627[p632] = false
            v_u_626.Update()
        end
    end
    function v_u_626.Activate(p633)
        if p_u_625 then
            print("SET ", p633, true)
        end
        if v_u_627[p633] ~= true then
            v_u_627[p633] = true
            v_u_626.Update()
        end
    end
    function v_u_626.GetActive()
        return v_u_627
    end
    function v_u_626.Remove(p634)
        v_u_627[p634] = nil
    end
    function v_u_626.Reset()
        for v635, _ in pairs(v_u_627) do
            v_u_626.Remove(v635)
        end
    end
    function v_u_626.Set(p636, p637)
        if p637 then
            return v_u_626.Activate(p636)
        else
            return v_u_626.Deactivate(p636)
        end
    end
    v_u_626.Update()
    return v_u_626
end
function round(p638)
    local v639 = p638 + 0.5
    return math.floor(v639)
end
function SharedHelper.Color3ToRichText(p640)
    return "rgb(" .. round(p640.r * 255) .. "," .. round(p640.g * 255) .. "," .. round(p640.b * 255) .. ")"
end
function SharedHelper.HasPremium(p641)
    return p641.MembershipType == Enum.MembershipType.Premium
end
function SharedHelper.CreateOrGate(p_u_642, p_u_643)
    local v_u_644 = {}
    local v_u_645 = {}
    local v_u_646 = false
    function v_u_645.Update()
        local v647 = false
        for _, v648 in pairs(v_u_644) do
            if v648 then
                v647 = true
                break
            end
        end
        if v647 and not v_u_646 then
            p_u_642.OnActivate()
        elseif not v647 and v_u_646 then
            p_u_642.OnDeactivate()
        end
        v_u_646 = v647
        if p_u_643 then
            print("OR GATE")
            print(v_u_644)
        end
    end
    function v_u_645.GetActive()
        return v_u_644
    end
    function v_u_645.Deactivate(p649)
        if v_u_644[p649] then
            v_u_644[p649] = nil
            v_u_645.Update()
        end
    end
    function v_u_645.Activate(p650)
        if not v_u_644[p650] then
            v_u_644[p650] = true
            v_u_645.Update()
        end
    end
    function v_u_645.Set(p651, p652)
        if p652 then
            return v_u_645.Activate(p651)
        else
            return v_u_645.Deactivate(p651)
        end
    end
    v_u_645.Update()
    return v_u_645
end
function SharedHelper.CreateInstance(p653, p654)
    local v655 = Instance.new(p653)
    for v656, v657 in pairs(p654) do
        v655[v656] = v657
    end
    return v655
end
function SharedHelper.InstantThread(p658)
    return task.spawn(p658)
end
function SharedHelper.GetRandom(p659, p660, p661)
    local v662 = p661 or 100
    return math.random(p659 * v662, p660 * v662) / v662
end
function SharedHelper.RandomChanceOLD(p663)
    if p663 <= 0 then
        return false
    else
        return p663 >= 1 and true or SharedHelper.GetRandom(0, 1, 1000) <= p663
    end
end
function SharedHelper.RandomChance(p664)
    local v665
    if p664 > 0 then
        v665 = math.random() < p664
    else
        v665 = false
    end
    return v665
end
function SharedHelper.GetRandomVector(p666, p667, p668)
    local v669 = p667 or -p666
    local v670 = SharedHelper.GetRandom(v669, p666, p668)
    local v671 = SharedHelper.GetRandom(v669, p666, p668)
    local v672 = SharedHelper.GetRandom(v669, p666, p668)
    return Vector3.new(v670, v671, v672)
end
function SharedHelper.AccurateWait(p673)
    if p673 > 0 then
        return task.wait(p673)
    end
end
function SharedHelper.SendLoadEvent(p674)
    print("sendload", p674)
    local tickTime_675 = tick()
    local LastLoadSentAttr_676 = tickTime_675 - (game.Workspace:GetAttribute("LastLoadSent") or tickTime_675)
    game.Workspace:SetAttribute("LastLoadSent", tickTime_675)
    SharedHelper.FireRemoteEvent("LoadingStage", LastLoadSentAttr_676, (game.Workspace:GetAttribute("LastLoad") or "init") .. "_to_" .. p674)
    game.Workspace:SetAttribute("LastLoad", p674)
end
function SharedHelper.GetRemoteEvent(p677, p678)
    if v_u_5.IsClient then
        return ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild(p677)
    end
    local RemoteEventsChild_679 = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if not RemoteEventsChild_679 then
        RemoteEventsChild_679 = Instance.new("Folder")
        RemoteEventsChild_679.Name = "RemoteEvents"
        RemoteEventsChild_679.Parent = ReplicatedStorage
    end
    local v680 = RemoteEventsChild_679:FindFirstChild(p677)
    if not v680 then
        v680 = Instance.new(p678 and "UnreliableRemoteEvent" or "RemoteEvent")
        v680.Name = p677
        v680.Parent = RemoteEventsChild_679
    end
    return v680
end
function SharedHelper.CreateRemoteEvent(...)
    return SharedHelper.GetRemoteEvent(...)
end
function SharedHelper.FireRemoteEvent(p681, ...)
    local v_u_682 = SharedHelper.GetRemoteEvent(p681)
    if v_u_5.IsClient then
        v_u_682:FireServer(...)
    else
        local v_u_683 = table.pack(...)
        pcall(function()
            local v684 = v_u_683
            v_u_682:FireClient(table.unpack(v684))
        end)
    end
end
function SharedHelper.FireAllClients(p685, ...)
    for _, v686 in pairs(game.Players:GetPlayers()) do
        SharedHelper.FireRemoteEvent(p685, v686, ...)
    end
end
function SharedHelper.FireAllClientsExcept(p687, p688, ...)
    if v_u_5.IsServer then
        for _, v689 in pairs(game.Players:GetPlayers()) do
            if v689 ~= p688 then
                SharedHelper.FireRemoteEvent(p687, v689, ...)
            end
        end
    end
end
function SharedHelper.WrapFunctionProfile(p_u_690, p_u_691)
    if v_u_5.IsStudio then
        return p_u_690
    end
    if type(p_u_690) ~= "function" then
        return p_u_690
    end
    if v_u_5.IsClient then
        local v692 = table.find
        local v693 = game.Players.LocalPlayer.UserId
        if not v692({ "16102594", "38833699" }, (tostring(v693))) then
            return p_u_690
        end
    end
    return function(...)
        debug.profilebegin(p_u_691)
        local v694 = table.pack(p_u_690(...))
        debug.profileend()
        return table.unpack(v694)
    end
end
local v_u_695 = {
    ["Rebirthius"] = true,
    ["89five"] = true
}
local v_u_696 = nil
local HttpService = game:GetService("HttpService")
local v_u_698 = nil
function SanitizeInput(p699, p_u_700, ...)
    local v_u_701 = SharedHelper.DeepCopy(table.pack(...))
    if v_u_695[p699.Name] then
        return true, v_u_701
    end
    if v_u_698 == nil then
        v_u_698 = SharedHelper.IsTestingServer()
    end
    if v_u_698 and p_u_700 == "GameAnalyticsError" or p_u_700 == "CmdrFunction" then
        return true, v_u_701
    end
    if not v_u_696 then
        v_u_696 = require(game:GetService("ServerScriptService"):WaitForChild("Modules"):WaitForChild("Assertion"))
    end
    local v702, v703 = v_u_696.SanitizeInput(...)
    if not v702 then
        task.spawn(function()
            if v_u_5.IsServer then
                if p_u_700 == "GameAnalyticsError" or p_u_700 == "CmdrFunction" then
                    return
                end
                local v704 = v_u_701
                v_u_5.Modules.ServerDataHandler.ExploitDetector.SerializeParamsSafe(table.unpack(v704))
                error("ILLEGAL_PARAMS - " .. p_u_700)
            end
        end)
    end
    return v702, v703
end
function SharedHelper.OnRemoteEvent(p705, p_u_706, p_u_707)
    local v_u_708
    if type(p705) == "string" then
        v_u_708 = SharedHelper.GetRemoteEvent(p705) or p705
    else
        v_u_708 = p705
    end
    local v_u_709 = type(p705) == "string" and p705 and p705 or v_u_708.Name
    if v_u_5.IsClient then
        return v_u_708.OnClientEvent:Connect(SharedHelper.WrapFunctionProfile(p_u_706, v_u_709))
    else
        return v_u_708.OnServerEvent:Connect(function(p710, ...)
            if p_u_707 and not p_u_707(p710, ...) then
                return
            elseif require(game:GetService("ServerScriptService"):WaitForChild("Modules"):WaitForChild("AntiRemoteFlood"))(v_u_5, p710, v_u_708, ...) then
                local v711 = table.pack(...)
                local v712 = SanitizeInput
                local v713 = v_u_709
                local v714 = v711.n
                local v715, v716 = v712(p710, v713, table.unpack(v711, 1, v714))
                if v715 then
                    local v717 = p_u_706
                    local v718 = v716.n
                    v717(p710, table.unpack(v716, 1, v718))
                end
            else
                return
            end
        end)
    end
end
function SharedHelper.GetButtonPrice(p719)
    return p719 and (p719:GetAttribute("Price") or 0) or 0
end
function SharedHelper.GetUTC()
    return os.time()
end
function SharedHelper.GetCFOffset(p720, p721)
    return p721:ToObjectSpace(p720)
end
function SharedHelper.GetDateString(p722)
    local v723 = os.date("!*t", SharedHelper.GetUTC() + (p722 or 0))
    local v724 = v723.year
    local v725 = tostring(v724)
    local v726 = v723.month
    local v727 = tostring(v726)
    local v728 = v723.day
    return v725 .. "-" .. v727 .. "-" .. tostring(v728)
end
function SharedHelper.GetDayEndUTC(p729)
    return p729 + 86400 - p729 % 86400 - 1
end
function SharedHelper.FindChildRecursive(p730, p731, ...)
    if not p731 then
        return p730
    end
    local v732 = p730:FindFirstChild(p731)
    if v732 then
        return SharedHelper.FindChildRecursive(v732, ...)
    end
end
function SharedHelper.GetRemoteFunction(p733)
    if v_u_5.IsClient then
        return ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild(p733)
    end
    local RemoteFunctionsChild_734 = ReplicatedStorage:FindFirstChild("RemoteFunctions")
    if not RemoteFunctionsChild_734 then
        RemoteFunctionsChild_734 = Instance.new("Folder")
        RemoteFunctionsChild_734.Name = "RemoteFunctions"
        RemoteFunctionsChild_734.Parent = ReplicatedStorage
    end
    local v735 = RemoteFunctionsChild_734:FindFirstChild(p733)
    if not v735 then
        v735 = Instance.new("RemoteFunction")
        v735.Name = p733
        v735.Parent = RemoteFunctionsChild_734
    end
    return v735
end
function SharedHelper.CreateLatch()
    local v736 = {}
    local v_u_737 = false
    local v_u_738 = false
    local v_u_739 = {}
    local v_u_740 = {}
    local function release()
        local v741 = v_u_739
        local v742 = v_u_740
        v_u_739 = {}
        v_u_740 = {}
        for _, v743 in ipairs(v741) do
            task.spawn(v743)
        end
        for _, v744 in ipairs(v742) do
            task.spawn(v744)
        end
    end
    function v736.Fire()
        if not (v_u_737 or v_u_738) then
            v_u_737 = true
            release()
        end
    end
    function v736.OnEvent(p746)
        if v_u_738 then
            return
        elseif v_u_737 then
            task.spawn(p746)
        else
            local v747 = v_u_739
            table.insert(v747, p746)
        end
    end
    function v736.Wait()
        if not (v_u_737 or v_u_738) then
            local v748 = v_u_740
            local v749 = coroutine.running
            table.insert(v748, v749())
            return coroutine.yield()
        end
    end
    function v736.Destroy()
        if not v_u_738 then
            v_u_738 = true
            release()
        end
    end
    return v736
end
function SharedHelper.CreateThreadEvent()
    local v750 = {}
    local v_u_751 = false
    local v_u_752 = {}
    local function release()
        local v753 = v_u_752
        v_u_752 = {}
        for _, v754 in ipairs(v753) do
            task.spawn(v754)
        end
    end
    function v750.Fire()
        if not v_u_751 then
            release()
        end
    end
    function v750.Wait()
        if not v_u_751 then
            local v756 = v_u_752
            local v757 = coroutine.running
            table.insert(v756, v757())
            return coroutine.yield()
        end
    end
    function v750.Destroy()
        if not v_u_751 then
            v_u_751 = true
            release()
        end
    end
    return v750
end
function SharedHelper.CreateRemoteFunction(...)
    return SharedHelper.GetRemoteFunction(...)
end
function SharedHelper.GetRangeDisplay(p758, p759, p760)
    local OthersChild_761 = game.ReplicatedStorage:WaitForChild("Others")
    local v_u_779 = {
        ["Parent"] = function(p762)
            v_u_779.Model.Parent = p762
        end,
        ["PivotTo"] = function(p763)
            v_u_779.Model:PivotTo(p763)
        end,
        ["Position"] = function(p764)
            if v_u_779.Model:IsA("BasePart") then
                v_u_779.Model.Position = p764
            end
        end,
        ["Property"] = function(p765, p766)
            if v_u_779.Model:IsA("BasePart") then
                v_u_779.Model[p765] = p766
            else
                for _, v767 in pairs(v_u_779.Model:GetChildren()) do
                    if v767:IsA("BasePart") then
                        v767[p765] = p766
                    end
                end
            end
        end,
        ["Attribute"] = function(p768, p769)
            if v_u_779.Model:IsA("BasePart") then
                v_u_779.Model:SetAttribute(p768, p769)
            else
                for _, v770 in pairs(v_u_779.Model:GetChildren()) do
                    if v770:IsA("BasePart") then
                        v770:SetAttribute(p768, p769)
                    end
                end
            end
        end,
        ["Color"] = function(p771)
            v_u_779.Property("Color", p771)
        end,
        ["Transparency"] = function(p772)
            v_u_779.Property("Transparency", p772)
        end,
        ["CanCollide"] = function(p773)
            v_u_779.Property("CanCollide", p773)
        end,
        ["SetAttribute"] = function(p774, p775)
            v_u_779.Attribute(p774, p775)
        end,
        ["GetTransparency"] = function()
            if not v_u_779 then
                return 1
            end
            if not v_u_779.Model then
                return 1
            end
            if v_u_779.Model:IsA("BasePart") then
                return v_u_779.Model.Transparency
            end
            for _, v776 in pairs(v_u_779.Model:GetChildren()) do
                if v776:IsA("BasePart") then
                    return v776.Transparency
                end
            end
        end,
        ["AddTag"] = function(p777)
            if v_u_779.Model:IsA("BasePart") then
                v_u_779.Model:AddTag(p777)
            else
                for _, v778 in pairs(v_u_779.Model:GetChildren()) do
                    if v778:IsA("BasePart") then
                        v778:AddTag(p777)
                    end
                end
            end
        end,
        ["Destroy"] = function()
            v_u_779.Model:Destroy()
            v_u_779 = nil
        end
    }
    if p760 then
        v_u_779.Model = require(OthersChild_761:WaitForChild(p758 .. "Template"):WaitForChild("Generator"))(p759)
    else
        v_u_779.Model = OthersChild_761:WaitForChild(p758):Clone()
        local v780 = v_u_779.Model
        local v781 = p759 * 2
        local v782 = p759 * 2
        v780.Size = Vector3.new(0.6, v781, v782)
    end
    return v_u_779
end
function SharedHelper.InvokeRemoteFunction(p783, ...)
    local v784 = v_u_5.IsClient
    assert(v784, "[SharedHelper] Server->client remote function invocation removed")
    return SharedHelper.GetRemoteFunction(p783):InvokeServer(...)
end
function SharedHelper.OnRemoteFunction(p785, p_u_786)
    local v_u_787
    if type(p785) == "string" then
        v_u_787 = SharedHelper.GetRemoteFunction(p785) or p785
    else
        v_u_787 = p785
    end
    local v_u_788 = type(p785) == "string" and p785 and p785 or v_u_787.Name
    if v_u_5.IsClient then
        v_u_787.OnClientInvoke = p_u_786
    else
        function v_u_787.OnServerInvoke(p789, ...)
            if require(game:GetService("ServerScriptService"):WaitForChild("Modules"):WaitForChild("AntiRemoteFlood"))(v_u_5, p789, v_u_787, ...) then
                local v790 = table.pack(...)
                local v791 = SanitizeInput
                local v792 = v_u_788
                local v793 = v790.n
                local v794, v795 = v791(p789, v792, table.unpack(v790, 1, v793))
                if v794 then
                    local v796 = p_u_786
                    local v797 = v795.n
                    return v796(p789, table.unpack(v795, 1, v797))
                end
            end
        end
    end
end
local RunService = game:GetService("RunService")
local v_u_799 = nil
function SharedHelper.RSWait()
    if not v_u_799 then
        if v_u_5.IsServer then
            v_u_799 = RunService.Heartbeat
        else
            v_u_799 = RunService.RenderStepped
        end
    end
    return v_u_799:wait()
end
function SharedHelper.HBWait()
    return RunService.Heartbeat:wait()
end
function SharedHelper.CreateValue(p800, p801, p802, p803)
    local v804 = Instance.new(p800 .. "Value")
    v804.Name = p801
    if p803 ~= nil then
        v804.Value = p803
    end
    if p802 ~= nil then
        v804.Parent = p802
    end
    return v804
end
function SharedHelper.GetValue(p805, p806)
    if p806:FindFirstChild(p805) then
        return p806[p805].Value
    end
end
function SharedHelper.CloneTableExcept(p807, p808)
    local v809 = {}
    for _, v810 in pairs(p807) do
        if v810 ~= p808 then
            table.insert(v809, v810)
        end
    end
    return v809
end
function SharedHelper.CallCustomHandler(p811, p812)
    if p811 then
        local v813 = p812 or {}
        v813.GameHandler = v_u_5
        v813.Helper = SharedHelper
        return p811(v813)
    end
end
function SharedHelper.GetHumanoid(p814)
    if p814 then
        return p814:FindFirstChildOfClass("Humanoid")
    end
end
function SharedHelper.GetHRP(p815, p816)
    if p815 then
        if not p816 then
            return p815:FindFirstChild("HumanoidRootPart")
        end
        if SharedHelper.CharacterIsAlive(p815) then
            return SharedHelper.GetHRP(p815)
        end
    end
end
function SharedHelper.CharacterIsAlive(p817)
    if p817 then
        local v818 = SharedHelper.GetHumanoid(p817)
        if v818 then
            return v818.Health > 0
        end
    end
end
function SharedHelper.GetClosestPart(p819, p820)
    local v821 = (1 / 0)
    local v822 = nil
    for _, v823 in pairs(p819) do
        local position_824 = (v823.Position - p820).magnitude
        if position_824 < v821 then
            v822 = v823
            v821 = position_824
        end
    end
    return v822
end
function SharedHelper.ClosestPointOnPart(p825, p826)
    if p826 then
        local cframe_827 = p825.CFrame:pointToObjectSpace(p826)
        local v828 = p825.Size * 0.5
        local cframe_829 = p825.CFrame
        local v830 = cframe_827.x
        local v831 = -v828.x
        local v832 = v828.x
        local v833 = math.clamp(v830, v831, v832)
        local v834 = cframe_827.y
        local v835 = -v828.y
        local v836 = v828.y
        local v837 = math.clamp(v834, v835, v836)
        local v838 = cframe_827.z
        local v839 = -v828.z
        local v840 = v828.z
        local v841 = math.clamp(v838, v839, v840)
        return cframe_829 * Vector3.new(v833, v837, v841)
    end
end
function SharedHelper.ShortestDistanceFromPointToPart(p842, p843)
    local v844 = SharedHelper.ClosestPointOnPart(p843, p842)
    if v844 then
        return (v844 - p842).magnitude
    end
end
function SharedHelper.FlatDistance(p845, p846)
    local v847 = p845.X
    local v848 = p845.Z
    local newVector3_849 = Vector3.new(v847, 0, v848)
    local v850 = p846.X
    local v851 = p846.Z
    return (newVector3_849 - Vector3.new(v850, 0, v851)).magnitude
end
function SharedHelper.Distance(p852, p853)
    if p852 and p853 then
        return (p853 - p852).magnitude
    end
    warn("Points not available.")
    return (1 / 0)
end
function SharedHelper.GetCharacter(p854, p855)
    local v856 = p854.Character
    if p855 and not SharedHelper.CharacterIsAlive(v856) then
        return false
    else
        return v856
    end
end
function SharedHelper.PlaySoundForPlayers(...)
    SharedHelper.FireAllClients("PlaySound", ...)
end
function SharedHelper.PlaySoundForPlayersExcept(...)
    SharedHelper.FireAllClientsExcept("PlaySound", ...)
end
function SharedHelper.RoundInt(p857)
    local v858 = p857 + 0.5
    return math.floor(v858)
end
function SharedHelper.StopPlayingSoundForPlayersExcept(...)
    SharedHelper.FireAllClientsExcept("StopPlayingSound", ...)
end
function SharedHelper.StopPlayingSoundForPlayers(...)
    SharedHelper.FireAllClients("StopPlayingSound", ...)
end
function SharedHelper.GetPlayerCharacterPosition(p859)
    if p859 then
        return SharedHelper.GetCharacterPosition(p859.Character)
    end
end
function SharedHelper.GetCharacterPosition(p860)
    if p860 then
        local HumanoidRootPartChild_861 = p860:FindFirstChild("HumanoidRootPart")
        if HumanoidRootPartChild_861 then
            return HumanoidRootPartChild_861.Position
        end
    end
end
function SharedHelper.GetCharacterCF(p862)
    if p862 then
        local HumanoidRootPartChild_863 = p862:FindFirstChild("HumanoidRootPart")
        if HumanoidRootPartChild_863 then
            return HumanoidRootPartChild_863.CFrame
        end
    end
end
function SharedHelper.GetProjectileIgnore(p864)
    local v865 = { p864.Character }
    if p864.Character.Humanoid.SeatPart and p864.Character.Humanoid.SeatPart:GetAttribute("IsVehicleSeat") then
        local v866 = p864.Character.Humanoid.SeatPart
        while not v866:GetAttribute("IsVehicle") and v866 ~= game.Workspace do
            v866 = v866.Parent
        end
        if v866 ~= game.Workspace then
            table.insert(v865, v866)
        end
    end
    return v865
end
function SharedHelper.Sum(p867)
    local v868 = 0
    for _, v869 in pairs(p867) do
        v868 = v868 + v869
    end
    return v868
end
function SharedHelper.Average(p870)
    return SharedHelper.Sum(p870) / #p870
end
function SharedHelper.SubTable(p871, p872, p873)
    local v874 = {}
    for v875 = p873 or 1, p872 do
        local v876 = p871[v875]
        table.insert(v874, v876)
    end
    return v874
end
function SharedHelper.MaxFromTable(p877)
    local v878 = p877[1]
    for v879 = 2, #p877 do
        if v878 < p877[v879] then
            v878 = p877[v879]
        end
    end
    return v878
end
function SharedHelper.BindToPlayerTouch(p880, p_u_881, p_u_882, p_u_883, p884)
    local v_u_885 = p884 or {}
    local v_u_886 = 0
    return p880.Touched:connect(function(p887)
        if v_u_885.DebounceTime and tick() - v_u_886 < v_u_885.DebounceTime then
            return
        elseif p887 then
            if v_u_885.MustHaveName and p887.Name ~= v_u_885.MustHaveName then
                return
            else
                local v888 = SharedHelper.GetCharacter(p_u_883, p_u_881)
                if v888 then
                    if v888:IsAncestorOf(p887) then
                        v_u_886 = tick()
                        p_u_882(p_u_883, v888, p887)
                    end
                end
            end
        else
            return
        end
    end)
end
function comma_value(p889)
    repeat
        local v890
        p889, v890 = string.gsub(p889, "^(-?%d+)(%d%d%d)", "%1,%2")
    until v890 == 0
    return p889
end
local v_u_891 = {
    ["default"] = {
        ["applycomma"] = true,
        ["symbol"] = "$"
    },
    ["k"] = {
        ["applycomma"] = true,
        ["symbol"] = "$",
        ["div"] = 1000,
        ["suffix"] = "K"
    },
    ["k1"] = {
        ["applycomma"] = true,
        ["symbol"] = "$",
        ["div"] = 1000,
        ["decs"] = 1,
        ["suffix"] = "K"
    },
    ["kd"] = {
        ["applycomma"] = true,
        ["symbol"] = "$",
        ["div"] = 1000,
        ["decs"] = 2,
        ["suffix"] = "K"
    },
    ["mil"] = {
        ["applycomma"] = true,
        ["symbol"] = "$",
        ["div"] = 1000000,
        ["suffix"] = "M"
    },
    ["mild"] = {
        ["applycomma"] = true,
        ["symbol"] = "$",
        ["div"] = 1000000,
        ["decs"] = 1,
        ["suffix"] = "M"
    },
    ["mil2"] = {
        ["applycomma"] = true,
        ["symbol"] = "$",
        ["div"] = 1000000,
        ["decs"] = 2,
        ["suffix"] = "M"
    },
    ["bil"] = {
        ["applycomma"] = true,
        ["symbol"] = "$",
        ["div"] = 1000000000,
        ["decs"] = 2,
        ["suffix"] = "B"
    },
    ["tril"] = {
        ["applycomma"] = true,
        ["symbol"] = "$",
        ["div"] = 1000000000000,
        ["decs"] = 2,
        ["suffix"] = "T"
    },
    ["quad"] = {
        ["applycomma"] = true,
        ["symbol"] = "$",
        ["div"] = 1000000000000000,
        ["decs"] = 2,
        ["suffix"] = "Q"
    },
    ["robux"] = {
        ["applycomma"] = true
    },
    ["comma"] = {
        ["applycomma"] = true
    },
    ["playtime"] = {},
    ["minutes"] = {},
    ["playtime_badge"] = {},
    ["boosttimeadd"] = {},
    ["timeleft"] = {},
    ["percentage"] = {},
    ["rebirthtokens"] = {}
}
function SharedHelper.StringCat(p892, p893)
    local v894 = ""
    local v895 = p893 or ";"
    for _, v896 in pairs(p892) do
        v894 = v894 .. tostring(v896) .. v895
    end
    return v894
end
function SharedHelper.StringUncat(p897, p898)
    if not p897 then
        return {}
    end
    local v899 = {}
    for _, v900 in pairs(string.split(p897, p898 or ";")) do
        if v900 ~= "" then
            table.insert(v899, v900)
        end
    end
    return v899
end
function SharedHelper.SmallNumberString(p901, p902)
    local v903 = "%." .. tostring(p902 or 1) .. "f"
    return string.format(v903, p901):gsub("%.?0+$", "")
end
function SharedHelper.FormatDateByCountry(p904, p905, p906, p907)
    local v908 = p907 or v_u_5.Modules.ClientPlayerHandler.PlayerCountryCode
    local v909 = {
        ["CN"] = true,
        ["JP"] = true,
        ["KR"] = true,
        ["TW"] = true,
        ["IR"] = true,
        ["KP"] = true
    }
    if ({
        ["US"] = true,
        ["PH"] = true,
        ["FM"] = true,
        ["GU"] = true,
        ["MH"] = true,
        ["MP"] = true,
        ["PW"] = true,
        ["UM"] = true,
        ["VI"] = true
    })[v908] then
        return string.format("%02d / %02d / %04d", p905, p904, p906)
    elseif v909[v908] then
        return string.format("%04d / %02d / %02d", p906, p905, p904)
    else
        return string.format("%02d / %02d / %04d", p904, p905, p906)
    end
end
function SharedHelper.CurrencyTextFormat(p910, p911, p912)
    local v913 = p912 or {}
    if p910 then
        local v914 = p911 or "default"
        if v914 == "robux" then
            return "\238\128\130 " .. SharedHelper.CurrencyTextFormat(p910, "comma", v913)
        elseif v914 == "abv" then
            if p910 < 100000 then
                return SharedHelper.CurrencyTextFormat(p910, nil, v913)
            elseif p910 < 1000000 then
                return SharedHelper.CurrencyTextFormat(p910, "k", v913)
            elseif p910 < 10000000 then
                return SharedHelper.CurrencyTextFormat(p910, "mil2", v913)
            elseif p910 < 100000000 then
                return SharedHelper.CurrencyTextFormat(p910, "mild", v913)
            elseif p910 < 1000000000 then
                return SharedHelper.CurrencyTextFormat(p910, "mil", v913)
            elseif p910 < 1000000000000 then
                return SharedHelper.CurrencyTextFormat(p910, "bil", v913)
            elseif p910 < 1000000000000000 then
                return SharedHelper.CurrencyTextFormat(p910, "tril", v913)
            else
                return SharedHelper.CurrencyTextFormat(p910, "quad", v913)
            end
        else
            local v915 = v_u_891[v914]
            local function oo(p916, p917)
                local v918 = math.abs(p916)
                local v919 = math.floor(v918)
                local v920 = ""
                local v921 = p917 or 2
                while string.len(v920) < v921 do
                    if v919 > 0 then
                        local v922 = v919 % 10
                        v920 = tostring(v922) .. v920
                        local v923 = v919 / 10
                        v919 = math.floor(v923)
                    else
                        v920 = "0" .. v920
                    end
                end
                return v920
            end
            if v914 == "minutes" then
                local v925 = p910 / 60
                local v926 = v925 - v925 % 1
                return tostring(v926) .. " MIN"
            elseif v914 == "date" then
                local v927 = os.date("*t", p910)
                return SharedHelper.FormatDateByCountry(v927.day, v927.month, v927.year)
            elseif v914 == "date_nospace" then
                local v928 = os.date("*t", p910)
                return SharedHelper.FormatDateByCountry(v928.day, v928.month, v928.year):gsub(" ", "")
            elseif v914 == "playtime_badge" then
                local v929 = math.floor(p910)
                if v929 < 3600 then
                    local v930 = v929 / 60
                    local v931 = math.floor(v930)
                    return tostring(v931) .. " MIN"
                else
                    local v932 = v929 / 3600
                    local v933 = math.floor(v932)
                    local v934 = (v929 - v933 * 3600) / 60
                    local v935 = math.floor(v934)
                    if v935 > 0 then
                        return tostring(v933) .. " H, " .. tostring(v935) .. " MIN"
                    else
                        return tostring(v933) .. " H"
                    end
                end
            elseif v914 == "playtime" then
                local v936 = math.floor(p910)
                if v936 < 3600 then
                    local v937 = v936 / 60
                    local v938 = math.floor(v937)
                    return tostring(v938) .. " MIN"
                end
                local v939 = v936 / 3600
                local v940 = math.floor(v939)
                local v941 = (v936 - v940 * 3600) / 60
                local v942 = math.floor(v941)
                return tostring(v940) .. " H, " .. tostring(v942) .. " MIN"
            elseif v914 == "percentage" then
                local v943 = p910 * 100
                local v944 = SharedHelper.RoundTo(v943)
                return tostring(v944) .. "%"
            elseif v914 == "percentage2" then
                local v945 = p910 * 100
                return string.format("%.2f", v945):gsub("%.?0+$", "") .. "%"
            elseif v914 == "percentage3" then
                local v946 = p910 * 100
                return string.format("%.3f", v946):gsub("%.?0+$", "") .. "%"
            elseif v914 == "percentage4" then
                local v947 = p910 * 100
                return string.format("%.4f", v947):gsub("%.?0+$", "") .. "%"
            elseif v914 == "timeleft" then
                local v948 = p910 / 3600
                local v949 = math.floor(v948)
                local v950 = p910 - v949 * 60 * 60
                local v951 = v950 / 60
                local v952 = math.floor(v951)
                local v953 = v950 - v952 * 60
                local v954 = math.floor(v953)
                return oo(v949) .. ":" .. oo(v952) .. ":" .. oo(v954)
            elseif v914 == "timeleftshort" then
                local v955 = p910 / 3600
                local v956 = math.floor(v955)
                local v957 = p910 - v956 * 60 * 60
                local v958 = v957 / 60
                local v959 = math.floor(v958)
                local v960 = v957 - v959 * 60
                local v961 = math.floor(v960)
                if v956 > 0 then
                    return tostring(v956) .. ":" .. oo(v959) .. ":" .. oo(v961)
                elseif v959 > 0 then
                    return tostring(v959) .. ":" .. oo(v961)
                else
                    return tostring(v961)
                end
            elseif v914 == "timeleft2" then
                local v962 = p910 / 60
                local v963 = math.floor(v962)
                local v964 = p910 - v963 * 60
                local v965 = math.floor(v964)
                return tostring(v963) .. ":" .. oo(v965)
            elseif v914 == "eventtime" then
                local v966 = p910 / 86400
                local v967 = math.floor(v966)
                local v968 = p910 - v967 * 24 * 60 * 60
                local v969 = v968 / 3600
                local v970 = math.floor(v969)
                local v971 = v968 - v970 * 60 * 60
                local v972 = v971 / 60
                local v973 = math.floor(v972)
                local v974 = v971 - v973 * 60
                local v975 = math.floor(v974)
                if v967 > 0 then
                    local v976 = tostring(v970)
                    local v977
                    if v976 == "1" then
                        v977 = v976 .. " Hour"
                    else
                        v977 = v976 .. " Hours"
                    end
                    local v978 = not v913.desp and ", " or v913.desp
                    if v967 >= 2 then
                        return tostring(v967) .. " Days" .. v978 .. v977
                    end
                    if v967 == 1 then
                        return tostring(v967) .. " Day" .. v978 .. v977
                    end
                end
                return oo(v970) .. ":" .. oo(v973) .. ":" .. oo(v975)
            elseif v914 == "hours" then
                local v979 = math.max(p910, 0)
                local v980 = v979 / 86400
                local v981 = math.floor(v980)
                local v982 = v979 - v981 * 24 * 60 * 60
                local v983 = v982 / 3600
                local v984 = math.floor(v983)
                local v985 = v982 - v984 * 60 * 60
                local v986 = v985 / 60
                local v987 = math.floor(v986)
                local v988 = v985 - v987 * 60
                local v989 = math.floor(v988)
                local v990 = tostring(v984)
                local v991
                if v990 == "1" then
                    v991 = v990 .. " Hour"
                else
                    v991 = v990 .. " Hours"
                end
                if v981 > 0 then
                    local v992 = not v913.desp and ", " or v913.desp
                    if v984 > 0 then
                        if v981 >= 2 then
                            return tostring(v981) .. " Days" .. v992 .. v991
                        end
                        if v981 == 1 then
                            return tostring(v981) .. " Day" .. v992 .. v991
                        end
                    else
                        if v981 >= 2 then
                            return tostring(v981) .. " Days"
                        end
                        if v981 == 1 then
                            return tostring(v981) .. " Day"
                        end
                    end
                else
                    if v984 > 0 then
                        return v991
                    end
                    if v987 > 0 then
                        if v989 > 0 then
                            v987 = v987 + 1
                        end
                        return v987 == 1 and "1 Minute" or tostring(v987) .. " Minutes"
                    end
                end
                return v989 == 1 and "1 Second" or tostring(v989) .. " Seconds"
            elseif v914 == "boosttimeadd" then
                local v993 = p910 / 60
                if v993 < 60 then
                    local v994 = math.floor(v993)
                    return "+" .. tostring(v994) .. " Min"
                else
                    local v995 = v993 / 60
                    if math.floor(v995) == 1 then
                        local v996 = math.floor(v995)
                        return "+" .. tostring(v996) .. " Hour"
                    else
                        local v997 = math.floor(v995)
                        return "+" .. tostring(v997) .. " Hours"
                    end
                end
            else
                local v998 = ""
                if v915.div then
                    local v999 = p910 / v915.div
                    if v915.decs then
                        local v1000 = v999 % 1 * 10 ^ v915.decs + 0.5
                        v998 = "." .. oo(math.floor(v1000), v915.decs)
                    end
                    p910 = math.floor(v999)
                end
                if v915.applycomma then
                    p910 = comma_value(p910)
                end
                if v913.symbol then
                    p910 = v913.symbol .. p910
                else
                    local v1001 = v_u_5.Config.CashSymbol or v915.symbol
                    if v1001 then
                        p910 = v1001 .. p910
                    end
                end
                local v1002 = p910 .. ((v998 == ".0" or v998 == ".00") and "" or v998)
                if v915.suffix then
                    if v913.PreSuffix then
                        return v1002 .. v913.PreSuffix .. v915.suffix
                    end
                    v1002 = v1002 .. v915.suffix
                end
                return v1002
            end
        end
    else
        return "nan"
    end
end
function SharedHelper.LoadBoostAppearance(p1003, p1004)
    p1003.Image = SharedHelper.AssetFormat(p1004.Texture)
    p1003:WaitForChild("Shadow").Image = SharedHelper.AssetFormat(p1004.Texture)
    local v1005 = ColorSequence.new({ ColorSequenceKeypoint.new(0, p1004.Color), ColorSequenceKeypoint.new(0.25, p1004.Color), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)) })
    p1003:WaitForChild("UIGradient").Color = v1005
    local UIGradientChild_1006 = p1003:WaitForChild("UIGradient"):Clone()
    UIGradientChild_1006.Parent = p1003:WaitForChild("Amount")
    UIGradientChild_1006.Enabled = true
    p1003:WaitForChild("Amount").Text = "x2"
end
function SharedHelper.GetCurrencyToCollectAttributeName(p1007)
    return p1007 .. "ToCollect"
end
function SharedHelper.BindToTagTouch(p1008, p_u_1009, p_u_1010)
    return p1008.Touched:connect(function(p1011)
        if p1011 then
            if CollectionService:HasTag(p1011, p_u_1009) then
                p_u_1010(p1011)
            end
        else
            return
        end
    end)
end
local TweenService = game:GetService("TweenService")
function SharedHelper.Tween(p1013, p1014, p1015, p1016)
    if p1013 then
        local v1017 = TweenService:Create(p1013, p1015, p1014)
        v1017:Play()
        if p1016 then
            task.wait(p1014.Time)
        end
        return v1017
    end
end
function SharedHelper.SafeTween(p1018, p1019, p1020)
    TweenService:Create(p1018, p1020, p1019):Play()
end
function SharedHelper.GetTweenValue(p1021, p1022, p1023)
    return TweenService:GetValue(p1021, p1022, p1023)
end
function SharedHelper.TableSum(p1024)
    local v1025 = 0
    for _, v1026 in pairs(p1024) do
        v1025 = v1025 + v1026
    end
    return v1025
end
function SharedHelper.TweenValue(p1027, p1028, p1029, p1030, p_u_1031, p_u_1032)
    local v_u_1033 = Instance.new(p1027)
    v_u_1033.Value = p1028
    local v_u_1034 = v_u_1033.Changed:connect(function()
        p_u_1031(v_u_1033.Value)
    end)
    local v_u_1035 = false
    local v_u_1036 = nil
    local TweenService = game:GetService("TweenService"):Create(v_u_1033, p1030, {
        ["Value"] = p1029
    })
    v_u_1036 = TweenService.Completed:Connect(function()
        if not v_u_1035 then
            v_u_1035 = true
            v_u_1034:Disconnect()
            v_u_1036:Disconnect()
            v_u_1034 = nil
            v_u_1036 = nil
            v_u_1033:Destroy()
            if p_u_1032 then
                p_u_1032()
            end
        end
    end)
    TweenService:Play()
    return TweenService
end
function SharedHelper.TweenCurrentValue(p1038, p1039, p1040, p1041, p1042, p1043)
    local v1044 = p1041 * (1 - (p1040 - p1038) / (p1039 - p1038))
    return SharedHelper.TweenValue("NumberValue", p1040, p1039, TweenInfo.new(v1044, Enum.EasingStyle.Linear, Enum.EasingDirection.In), p1042, p1043)
end
function SharedHelper.HTTPGet(p_u_1045)
    local v1046, v1047 = pcall(function()
        return HttpService:JSONDecode((HttpService:GetAsync(p_u_1045)))
    end)
    if v1046 then
        return v1047
    end
    warn("HTTP Error: " .. tostring(v1047))
    return false
end
function SharedHelper.BindToPlayerInsidePart(p_u_1048, p_u_1049, p_u_1050, p_u_1051)
    p_u_1048.Touched:Connect(function() end)
    local v_u_1052 = {}
    local v_u_1057 = p_u_1048.Touched:connect(function(p1053)
        if p1053.Parent then
            if p1053.Parent:FindFirstChild("Humanoid") then
                if not table.find(v_u_1052, p1053.Parent) then
                    if p_u_1051 then
                        local v1054 = game.Players:FindFirstChild(p1053.Parent.Name)
                        if not v1054 then
                            return
                        end
                        if not table.find(p_u_1051, v1054) then
                            return
                        end
                    end
                    local v1055 = v_u_1052
                    local v1056 = p1053.Parent
                    table.insert(v1055, v1056)
                    if #v_u_1052 == 1 then
                        p_u_1049()
                    end
                end
            else
                return
            end
        else
            return
        end
    end)
    local v_u_1060 = p_u_1048.TouchEnded:Connect(function(p1058)
        if p1058.Parent then
            if p1058.Parent:FindFirstChild("Humanoid") then
                if p1058.Parent:FindFirstChild("HumanoidRootPart") then
                    if SharedHelper.CheckPositionInsidePart(p1058.Parent.HumanoidRootPart.Position, p_u_1048) then
                        return
                    else
                        local v1059 = table.find(v_u_1052, p1058.Parent)
                        if v1059 then
                            table.remove(v_u_1052, v1059)
                            if #v_u_1052 == 0 then
                                p_u_1050()
                            end
                        end
                    end
                else
                    return
                end
            else
                return
            end
        else
            return
        end
    end)
    SharedHelper.OnDestroy(p_u_1048, function()
        v_u_1057:Disconnect()
        v_u_1060:Disconnect()
    end)
end
function SharedHelper.BindToAnyPlayerInsidePart(p1061, p1062, p1063)
    return SharedHelper.BindToPlayerInsidePart(p1061, p1062, p1063)
end
function SharedHelper.BindToAnyPlayerTouch(p1064, p_u_1065, p_u_1066, p_u_1067, p1068)
    local v_u_1069 = p1068 or {}
    local v_u_1070 = {}
    return p1064.Touched:connect(function(p1071)
        if p1071 then
            if p_u_1067 and p1071.Name ~= p_u_1067 then
                return
            else
                local v1072 = p1071.Parent
                if v1072 then
                    if v1072:FindFirstChildOfClass("Humanoid") then
                        local v1073 = v_u_1069.CanBeNPC or Players:FindFirstChild(v1072.Name)
                        if v1073 then
                            if p_u_1065 and not SharedHelper.CharacterIsAlive(v1072) then
                                return false
                            end
                            local v_u_1074
                            if v1073 then
                                v_u_1074 = v1073.Name
                                if v_u_1069.DebounceTime then
                                    if v_u_1070[v_u_1074] then
                                        return
                                    end
                                    v_u_1070[v_u_1074] = true
                                end
                            else
                                v_u_1074 = nil
                            end
                            p_u_1066(v1073, v1072, p1071)
                            if v_u_1069.DebounceTime and v_u_1074 then
                                delay(v_u_1069.DebounceTime, function()
                                    v_u_1070[v_u_1074] = nil
                                end)
                            end
                        end
                    else
                        return
                    end
                else
                    return
                end
            end
        else
            return
        end
    end)
end
function SharedHelper.TeleportInside(p1075, p1076, p1077)
    if p1075 and (p1075.Character and (p1076 and p1076:IsA("BasePart"))) then
        local v1078 = p1076.Size * 0.5
        local v1079 = math.random() * 2 - 1
        local v1080 = v1078.X - 2
        local v1081 = v1079 * math.max(v1080, 0)
        local v1082 = math.random() * 2 - 1
        local v1083 = v1078.Z - 2
        local v1084 = v1082 * math.max(v1083, 0)
        local newVector3_1085 = Vector3.new(v1081, p1077 or 3, v1084)
        local cframe_1086 = p1076.CFrame:PointToWorldSpace(newVector3_1085)
        v_u_5.Modules.ServerPlayerHandler.MoveCharacter(p1075, CFrame.new(cframe_1086))
    end
end
function SharedHelper.FindCharacter(p1087, p1088)
    local v1089 = nil
    while (v1089 or 0) <= #p1087 do
        v1089 = (v1089 or 0) + 1
        if string.sub(p1087, v1089, v1089) == p1088 then
            return v1089
        end
    end
end
function SharedHelper.GetNumber2DecimalsStr(p1090)
    local v1091 = p1090 - p1090 % 0.01
    local v1092 = tostring(v1091)
    local v1093 = SharedHelper.FindCharacter(v1092, ".")
    if v1093 then
        local v1094 = v1093 + 3
        v1092 = string.sub(v1092, 1, v1094)
        while true do
            local v1095 = #v1092
            local v1096 = #v1092
            local v1097 = string.sub(v1092, v1095, v1096)
            if v1097 ~= "0" then
                break
            end
            local v1098 = #v1092 - 1
            v1092 = string.sub(v1092, 1, v1098)
        end
        if v1097 == "." then
            local v1099 = #v1092 - 1
            return string.sub(v1092, 1, v1099)
        end
        if #v1092 <= 0 then
            return v1092
        end
    end
    return v1092
end
function SharedHelper.OnDestroy(p_u_1100, p_u_1101)
    if type(p_u_1100) == "userdata" then
        local v_u_1102 = nil
        local function rip()
            if not p_u_1100:IsDescendantOf(game) then
                local v1103 = p_u_1101
                v_u_1102:Disconnect()
                p_u_1101 = nil
                v_u_1102 = nil
                p_u_1100 = nil
                v1103()
            end
        end
        v_u_1102 = p_u_1100.AncestryChanged:Connect(rip)
        local v1105
        if p_u_1100:IsDescendantOf(game) or p_u_1100:IsDescendantOf(game) then
            v1105 = v_u_1102
        else
            local v1106 = p_u_1101
            v_u_1102:Disconnect()
            local _ = nil
            v_u_1102 = nil
            local _ = nil
            v1106()
            v1105 = v_u_1102
        end
        return v1105
    end
end
function SharedHelper.NVL(p1107, p1108)
    if p1107 == nil then
        return p1108
    else
        return p1107
    end
end
function SharedHelper.DestroyDescendantsClass(p1109, p1110)
    for _, v1111 in pairs(p1109:GetDescendants()) do
        if table.find(p1110, v1111.ClassName) then
            v1111:Destroy()
        end
    end
end
function SharedHelper.DestroyChildren(p1112, p1113)
    if p1113 then
        for _, v1114 in pairs(p1112:GetChildren()) do
            if not table.find(p1113, v1114.Name) then
                v1114:Destroy()
            end
        end
    else
        for _, v1115 in pairs(p1112:GetChildren()) do
            v1115:Destroy()
        end
    end
end
function SharedHelper.GetPlayerWalkSpeed(p1116)
    if p1116 then
        local v1117 = p1116.Character
        if v1117 then
            local HumanoidChild_1118 = v1117:FindFirstChild("Humanoid")
            if HumanoidChild_1118 then
                return HumanoidChild_1118.WalkSpeed
            end
        end
    else
        return
    end
end
function SharedHelper.GetTools(p1119)
    local BackpackChild_1120 = p1119:WaitForChild("Backpack"):GetChildren()
    local v1121 = p1119.Character and p1119.Character:FindFirstChildOfClass("Tool")
    if v1121 then
        table.insert(BackpackChild_1120, v1121)
    end
    return BackpackChild_1120
end
function SharedHelper.IsTouchingCharacter(p1122, p1123, p1124)
    if SharedHelper.CharacterIsAlive(p1123) then
        for _, v1125 in pairs(p1122:GetTouchingParts()) do
            if ((not p1124 or v1125.Name == p1124) and true or false) and p1123:IsAncestorOf(v1125) then
                return p1123
            end
        end
        return false
    end
end
function SharedHelper.Weld(p1126, p1127)
    local WeldInstance_1128 = Instance.new("Weld")
    WeldInstance_1128.Part0 = p1127
    WeldInstance_1128.Part1 = p1126
    WeldInstance_1128.C0 = p1127.CFrame:Inverse()
    WeldInstance_1128.C1 = p1126.CFrame:Inverse()
    WeldInstance_1128.Parent = p1126
    return WeldInstance_1128
end
function SharedHelper.WeldModel(p1129)
    local v1130
    if p1129.ClassName == "Model" then
        v1130 = p1129.PrimaryPart
    else
        v1130 = p1129:WaitForChild("Handle")
    end
    for _, v1131 in pairs(p1129:GetDescendants()) do
        if v1131:IsA("BasePart") and v1131 ~= v1130 then
            SharedHelper.Weld(v1131, v1130)
        end
    end
end
function SharedHelper.SetModelAnchored(p1132, p1133)
    for _, v1134 in pairs(p1132:GetDescendants()) do
        if v1134:IsA("BasePart") then
            v1134.Anchored = p1133 or false
        end
    end
end
function SharedHelper.SetModelPartProperty(p1135, p1136, p1137)
    for _, v1138 in pairs(p1135:GetChildren()) do
        if v1138:IsA("BasePart") then
            v1138[p1136] = p1137 or false
        end
    end
end
function SharedHelper.WeldTool(p1139)
    for _, v1140 in pairs(p1139:GetDescendants()) do
        if v1140.Name ~= "Handle" and v1140:IsA("BasePart") then
            SharedHelper.Weld(v1140, p1139:WaitForChild("Handle"))
            v1140.Anchored = false
            v1140.CanCollide = false
        end
    end
end
function SharedHelper.FindFirstPartParent(p1141)
    local v1142 = p1141.Parent
    if v1142:IsA("BasePart") then
        return v1142
    else
        return SharedHelper.FindFirstPartParent(v1142)
    end
end
function SharedHelper.GiveParticle(p1143, p1144)
    if p1143 and p1144 then
        local v1145 = SharedHelper.GetCharacter(p1143)
        if v1145 then
            local UpperTorsoChild_1146 = v1145:FindFirstChild("UpperTorso")
            if UpperTorsoChild_1146 then
                local v1147 = 0
                for _, v1148 in pairs(UpperTorsoChild_1146:GetChildren()) do
                    if v1148.Name == "__particle_effect__" then
                        v1147 = v1147 + 1
                    end
                end
                if v1147 < 3 or p1144 == "remove_all" then
                    v1145:SetAttribute("LoadedMorph", nil)
                    if p1144 == "remove_all" then
                        local v1149 = false
                        for _, v1150 in pairs(UpperTorsoChild_1146:GetChildren()) do
                            if v1150.Name == "__particle_effect__" then
                                v1150:Destroy()
                                v1149 = true
                            end
                        end
                        return v1149
                    end
                    local v1151 = v_u_5.Modules.SharedItemData.GetItem(p1144)
                    if v1151 then
                        for _, v1152 in pairs(UpperTorsoChild_1146:GetChildren()) do
                            if v1152.Name == "__particle_effect__" and v1152:GetAttribute("OriginalID") == p1144 then
                                return
                            end
                        end
                        local v1153 = SharedHelper.WaitForChild(ReplicatedStorage, "Models", "Particles", v1151.ID):Clone()
                        for _, v1154 in pairs(v1153:GetDescendants()) do
                            local v1155 = v1154:Clone()
                            v1155.Name = "__particle_effect__"
                            v1155:SetAttribute("OriginalID", p1144)
                            v1155.Parent = UpperTorsoChild_1146
                        end
                        return true
                    end
                end
            else
                return
            end
        else
            return
        end
    else
        return
    end
end
function prettyTableToString(p1156)
    local HttpService = game:GetService("HttpService"):JSONEncode(p1156)
    local v1158 = #HttpService
    local v1159 = 1
    local v1160 = {}
    local v1161 = 0
    while v1159 <= v1158 do
        local v1162 = HttpService:sub(v1159, v1159)
        if v1162 == "{" or v1162 == "[" then
            local v1163 = v1162 .. "\n"
            table.insert(v1160, v1163)
            v1161 = v1161 + 1
            local v1164 = string.rep
            table.insert(v1160, v1164("\t", v1161))
        elseif v1162 == "}" or v1162 == "]" then
            v1161 = v1161 - 1
            local v1165 = "\n" .. string.rep("\t", v1161) .. v1162
            table.insert(v1160, v1165)
        elseif v1162 == "," then
            local v1166 = ",\n" .. string.rep("\t", v1161)
            table.insert(v1160, v1166)
        else
            table.insert(v1160, v1162)
        end
        v1159 = v1159 + 1
    end
    return table.concat(v1160)
end
function SharedHelper.TableToString(p1167, p1168)
    if p1168 then
        return prettyTableToString(p1167)
    else
        return game:GetService("HttpService"):JSONEncode(p1167)
    end
end
function SharedHelper.FilterTable2(p1169, p1170)
    local v1171 = {}
    for _, v1172 in pairs(p1169) do
        if p1170(v1172) then
            table.insert(v1171, v1172)
        end
    end
    return v1171
end
function SharedHelper.ForAllBasePartDescendants(p1173, p1174)
    for _, v1175 in pairs(p1173:GetDescendants()) do
        if v1175:IsA("BasePart") then
            p1174(v1175)
        end
    end
end
function SharedHelper.ClearWelds(p1176)
    for _, v1177 in pairs(p1176:GetDescendants()) do
        if v1177.ClassName == "Weld" or v1177.ClassName == "Motor6D" then
            v1177:Destroy()
        end
    end
end
function SharedHelper.ForAllBasePartDescendantsProperty(p1178, p1179)
    local v1180 = { p1178, table.unpack(p1178:GetDescendants()) }
    for _, v1181 in pairs(v1180) do
        if v1181:IsA("BasePart") then
            for _, v1182 in pairs(p1179) do
                v1181[v1182[1]] = v1182[2]
            end
        end
    end
end
function SharedHelper.EnableEffects(p1183)
    local v1184 = { p1183, table.unpack(p1183:GetDescendants()) }
    local v1185 = false
    for _, v1186 in pairs(v1184) do
        if v1186.ClassName == "Trail" or v1186.ClassName == "ParticleEmitter" then
            v1186.Enabled = true
            v1185 = true
        end
    end
    return v1185
end
function SharedHelper.GetDescendantsWithTag(p1187, p1188)
    local v1189 = type(p1188) ~= "table" and { p1188 } or p1188
    local v1190 = {}
    for _, v1191 in pairs(p1187:GetDescendants()) do
        for _, v1192 in pairs(v1189) do
            if CollectionService:HasTag(v1191, v1192) and not table.find(v1190, v1191) then
                table.insert(v1190, v1191)
                break
            end
        end
    end
    return v1190
end
function SharedHelper.RemoveTags(p1193)
    for _, v1194 in pairs(CollectionService:GetTags(p1193)) do
        CollectionService:RemoveTag(p1193, v1194)
    end
end
function SharedHelper.ModelRemoveTags(p1195)
    SharedHelper.RemoveTags(p1195)
    for _, v1196 in pairs(p1195:GetDescendants()) do
        SharedHelper.RemoveTags(v1196)
    end
end
function SharedHelper.TrimSpaces(p1197)
    return string.gsub(p1197, "^%s*(.-)%s*$", "%1")
end
function SharedHelper.GetLowestPart(p1198)
    local v1199 = (1 / 0)
    local v1200 = nil
    for _, v1201 in ipairs(p1198:GetDescendants()) do
        if v1201:IsA("BasePart") then
            local cframe_1202 = v1201.CFrame
            local v1203 = v1201.Size
            local v1204 = cframe_1202.RightVector.Y
            local v1205 = math.abs(v1204) * v1203.X * 0.5
            local v1206 = cframe_1202.UpVector.Y
            local v1207 = v1205 + math.abs(v1206) * v1203.Y * 0.5
            local v1208 = cframe_1202.LookVector.Y
            local v1209 = v1207 + math.abs(v1208) * v1203.Z * 0.5
            local position_1210 = cframe_1202.Position.Y - v1209
            if position_1210 < v1199 then
                v1200 = v1201
                v1199 = position_1210
            end
        end
    end
    return v1200
end
function SharedHelper.CreateMoveAnchor(p_u_1211)
    if p_u_1211.PrimaryPart then
        local v_u_1212 = p_u_1211.PrimaryPart:Clone()
        SharedHelper.RemoveTags(v_u_1212)
        v_u_1212.Name = p_u_1211.Name .. "_moveanchor"
        v_u_1212.Transparency = 1
        v_u_1212.CanCollide = false
        v_u_1212.Anchored = true
        v_u_1212.Parent = p_u_1211.Parent
        local CFrameValueInstance_1213 = Instance.new("CFrameValue")
        CFrameValueInstance_1213.Value = v_u_1212.CFrame
        CFrameValueInstance_1213.Name = "OriginalCF"
        CFrameValueInstance_1213.Parent = v_u_1212
        local function updatepos()
            if p_u_1211 then
                if p_u_1211.Parent then
                    p_u_1211:PivotTo(v_u_1212.CFrame)
                end
            else
                return
            end
        end
        if p_u_1211 and p_u_1211.Parent then
            p_u_1211:PivotTo(v_u_1212.CFrame)
        end
        v_u_1212:GetPropertyChangedSignal("CFrame"):Connect(updatepos)
        return v_u_1212
    end
    pcall(function()
        warn("No primary part")
        print(p_u_1211:GetFullName())
    end)
end
function SharedHelper.PickRandom(p1215, p1216)
    local v1217 = p1216 or {}
    if type(v1217) ~= "table" then
        v1217 = { v1217 }
    end
    repeat
        local v1218 = p1215[math.random(1, #p1215)]
    until not table.find(v1217, v1218)
    return v1218
end
function SharedHelper.PersistentMoveAnchor(p1219, p1220)
    if p1219 and p1220 then
        if p1219:FindFirstChild("MAO") then
            return p1219.MAO.Value
        end
        local ObjectValueInstance_1221 = Instance.new("ObjectValue")
        local v1222 = SharedHelper.CreateMoveAnchor(p1220)
        ObjectValueInstance_1221.Value = v1222
        ObjectValueInstance_1221.Name = "MAO"
        ObjectValueInstance_1221.Parent = p1219
        return v1222, ObjectValueInstance_1221
    end
end
function SharedHelper.ClosestPlayer(p1223)
    local v1224 = 9999999
    for _, v1225 in pairs(game.Players:GetPlayers()) do
        local v1226 = SharedHelper.GetCharacterPosition(v1225.Character)
        if v1226 then
            local v1227 = (p1223 - v1226).magnitude
            if v1227 < v1224 then
                v1224 = v1227
            end
        end
    end
    return v1224
end
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local v_u_1230 = {}
function SharedHelper.GetAllAnimationEventNames(p1231)
    local v1232 = tostring(p1231)
    if not v1232:match("^rbxassetid://") then
        v1232 = "rbxassetid://" .. v1232:gsub("%D", "")
    end
    if v_u_1230[v1232] then
        return v_u_1230[v1232]
    end
    local v_u_1233 = {}
    local function recurse(p1234)
        for _, v1235 in pairs(p1234:GetChildren()) do
            if v1235:IsA("KeyframeMarker") then
                local v1236 = v_u_1233
                local v1237 = v1235.Name
                table.insert(v1236, v1237)
            end
            if #v1235:GetChildren() > 0 then
                recurse(v1235)
            end
        end
    end
    recurse((KeyframeSequenceProvider:GetKeyframeSequenceAsync(v1232)))
    v_u_1230[v1232] = v_u_1233
    return v_u_1233
end
local v_u_1239 = {}
function SharedHelper.GetAnimationLength(p1240)
    local v_u_1241 = tostring(p1240)
    if not v_u_1241:match("^rbxassetid://") then
        v_u_1241 = "rbxassetid://" .. v_u_1241:gsub("%D", "")
    end
    if v_u_1239[v_u_1241] then
        return v_u_1239[v_u_1241]
    end
    local v1242, v1243 = pcall(function()
        return KeyframeSequenceProvider:GetKeyframeSequenceAsync(v_u_1241)
    end)
    if not v1242 then
        warn(("Couldn\'t load animation %s \226\128\147 %s"):format(v_u_1241, v1243))
        return nil
    end
    local v1244 = 0
    for _, v1245 in ipairs(v1243:GetKeyframes()) do
        if v1244 < v1245.Time then
            v1244 = v1245.Time
        end
    end
    v_u_1239[v_u_1241] = v1244
    return v1244
end
SharedHelper.ToolHelp = {}
local v_u_1246 = {
    "Cooldowns",
    "Animations",
    "Sounds",
    "ExplosionConfig",
    "Binds"
}
local function BuildToolManager(p1247, p1248)
    local v1249 = v_u_5.Modules.SharedItemData.GetItem(p1247)
    if v1249 then
        local v_u_1250 = {
            ["Tool"] = nil,
            ["ToolID"] = nil,
            ["ServerIdentifier"] = nil,
            ["IsEquipped"] = false,
            ["EquipNumber"] = 0,
            ["ToolData"] = nil,
            ["ToolProperties"] = nil,
            ["ToolMethods"] = nil,
            ["Tool"] = p1248,
            ["ToolID"] = p1247,
            ["ServerIdentifier"] = p1248:GetAttribute("ServerIdentifier"),
            ["ToolData"] = {
                ["Events"] = {}
            },
            ["ToolProperties"] = {},
            ["ToolMethods"] = {}
        }
        local v_u_1251 = {}
        local function loadData(p1252)
            if p1252 then
                for _, v1253 in pairs(p1252.ToolProperties.Inherits or {}) do
                    if not v_u_1251[v1253] then
                        v_u_1251[v1253] = true
                        loadData(v_u_5.Modules.SharedItemData.GetItem(v1253))
                    end
                end
                for v1254, v1255 in pairs(p1252.ToolProperties or {}) do
                    if table.find(v_u_1246, v1254) then
                        if not v_u_1250.ToolProperties[v1254] then
                            v_u_1250.ToolProperties[v1254] = {}
                        end
                        for v1256, v1257 in pairs(v1255) do
                            v_u_1250.ToolProperties[v1254][v1256] = v1257
                        end
                    else
                        v_u_1250.ToolProperties[v1254] = v1255
                    end
                end
                for v1258, v1259 in pairs(p1252.ToolMethods or {}) do
                    v_u_1250.ToolMethods[v1258] = v1259
                end
            end
        end
        loadData(v1249)
        return v_u_1250
    end
end
SharedHelper.ToolHelp.BuildToolManager = BuildToolManager
SharedHelper.BinarySearch = require(script:WaitForChild("BinarySearch"))
SharedHelper.LeakyBucket = require(script:WaitForChild("LeakyBucket"))
function SharedHelper.AddToHumanoidProperty(p1262, p1263, p1264)
    if p1263 and p1264 then
        if p1264 == 0 then
            return
        elseif p1262 then
            local v1265 = SharedHelper.GetHumanoid(p1262)
            if v1265 then
                if v1265[p1263] ~= nil then
                    v1265[p1263] = v1265[p1263] + p1264
                end
            else
                return
            end
        else
            return
        end
    else
        return
    end
end
function SharedHelper.AccountCreatedBefore(p1266, p1267)
    local v1268 = nil
    if typeof(p1266) == "DateTime" then
        v1268 = p1266.UnixTimestamp
    elseif type(p1266) == "number" then
        v1268 = p1266
    elseif type(p1266) == "string" then
        local v1269, v1270, v1271 = p1266:match("^(%d+)%-(%d+)%-(%d+)$")
        local v1272
        if v1269 then
            if v1270 then
                v1272 = v1271
            else
                v1272 = v1270
            end
        else
            v1272 = v1269
        end
        assert(v1272, ("AccountCreatedBefore: bad date string \'%s\' \226\128\147 expected \'YYYY-MM-DD\'"):format(p1266))
        v1268 = os.time({
            ["year"] = nil,
            ["month"] = nil,
            ["day"] = nil,
            ["hour"] = 0,
            ["year"] = tonumber(v1269),
            ["month"] = tonumber(v1270),
            ["day"] = tonumber(v1271)
        })
    else
        error("AccountCreatedBefore: unsupported date type " .. typeof(p1266))
    end
    return os.time() - p1267 * 86400 < v1268
end
function SharedHelper.WithinReasonableDistance(p1273, p1274, p1275)
    if p1273 and (p1274 and p1275) then
        return (p1273 - p1274).magnitude <= p1275 * 1.5
    end
end
function SharedHelper.PlayerWithinReasonableDistance(p1276, p1277, p1278)
    local v1279 = p1276.Character
    if v1279 then
        local v1280 = SharedHelper.GetCharacterPosition(v1279)
        return SharedHelper.WithinReasonableDistance(v1280, p1277, p1278)
    end
end
function SharedHelper.WaitForDescendant(p1281, p1282)
    local v1283 = 0
    while true do
        for _, v1284 in pairs(p1281:GetDescendants()) do
            if v1284.Name == p1282 then
                return v1284
            end
        end
        v1283 = v1283 + SharedHelper.RSWait()
        if v1283 > 5 then
            warn("Wait for descendant is slow: " .. p1281:GetFullName() .. " waiting for " .. tostring(p1282))
            v1283 = 0
        end
    end
end
function SharedHelper.GetFPDist(p1285, p1286)
    if not (p1285 and p1286) then
        return false
    end
    local position_1287 = p1286.Position + Vector3.new(0, 1.5, 0)
    local cframe_1288 = (p1285.CFrame.p - position_1287).magnitude
    return cframe_1288, cframe_1288 < 0.9
end
function SharedHelper.UDim2Mult(p1289, p1290)
    return UDim2.new(p1289.X.Scale * p1290, p1289.X.Offset * p1290, p1289.Y.Scale * p1290, p1289.Y.Offset * p1290)
end
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
function SharedHelper.GetPointerScreenPos()
    if UserInputService.MouseEnabled or UserInputService.TouchEnabled then
        local v1293 = UserInputService:GetMouseLocation()
        return Vector2.new(v1293.X, v1293.Y)
    else
        local v1294 = GuiService.SelectedObject
        if v1294 and v1294:IsA("GuiObject") then
            local v1295, _ = GuiService:GetGuiInset()
            return v1294.AbsolutePosition + v1294.AbsoluteSize / 2 - v1295
        else
            local camera_1296 = workspace.CurrentCamera
            return (camera_1296 and camera_1296.ViewportSize or Vector2.new(1920, 1080)) / 2
        end
    end
end
function SharedHelper.GetMouseUIPosition(p1297, p1298)
    local v1299 = p1298 or {}
    if v_u_5.Modules.ClientDeviceHandler.GetDevice() == "PC" then
        local mouse_1300 = game.Players.LocalPlayer:GetMouse()
        if v1299.ToTheLeft then
            return UDim2.new(0, mouse_1300.X - 8, 0, mouse_1300.Y - 4)
        else
            return UDim2.new(0, mouse_1300.X + 14, 0, mouse_1300.Y - 4)
        end
    elseif v1299.ToTheLeft then
        return UDim2.new(0, p1297.AbsolutePosition.X - 8, 0, p1297.AbsolutePosition.Y)
    else
        return UDim2.new(0, p1297.AbsolutePosition.X + p1297.AbsoluteSize.X + 8, 0, p1297.AbsolutePosition.Y)
    end
end
function SharedHelper.GetMousePosition()
    local mouse = game.Players.LocalPlayer:GetMouse()
    if not v_u_5.Modules.ClientDeviceHandler.IsTouch() then
        return mouse.X, mouse.Y
    end
    local character = game.Players.LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = humanoid and (humanoid.Health > 0 and character:FindFirstChild("HumanoidRootPart"))
        if rootPart then
            local camera = workspace.CurrentCamera
            local screenPoint, _ = camera:WorldToScreenPoint(rootPart.Position + Vector3.new(0, 3.5, 0))
            local inset = v_u_5.Modules.ClientDeviceHandler.GetInset()
            local yPos = screenPoint.Y
            local adjustedY = inset.Y + yPos / 2
            local fpDist, inFirstPerson = SharedHelper.GetFPDist(camera, rootPart)
            local targetY = camera.ViewportSize.Y / 2 - inset.Y - 10
            if inFirstPerson then
                adjustedY = targetY
            elseif fpDist < 5 then
                local alpha = 1 - (fpDist - 0.9) / 4.1
                adjustedY = adjustedY + (targetY - adjustedY) * alpha
            end
            return game.Workspace.CurrentCamera.ViewportSize.X / 2, adjustedY
        end
    end
    return game.Workspace.CurrentCamera.ViewportSize.X / 2, game.Workspace.CurrentCamera.ViewportSize.Y / 3.5
end
function SharedHelper.ShouldIgnoreInMouseHitDetection(hitPart)
    if hitPart.Name == "HitMask" then
        return false
    elseif hitPart.Parent:FindFirstChild("Humanoid") then
        return false
    else
        return hitPart.Transparency == 1 and true or hitPart.CanCollide == false
    end
end
function SharedHelper.GetAllPlayerCharacters()
    local characters = {}
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character then
            local char = player.Character
            table.insert(characters, char)
        end
    end
    return characters
end
function SharedHelper.RayCast(origin, target, ignoreList)
    if ignoreList then
        local effectHolder = v_u_5.Modules.SharedMapHandler.EffectHolder
        table.insert(ignoreList, effectHolder)
    else
        ignoreList = { v_u_5.Modules.SharedMapHandler.EffectHolder }
    end
    local dist = (origin - target).magnitude
    local dir = (target - origin).unit
    local ray = Ray.new(origin, dir * dist)
    local hitPart, hitPos = game.Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    return hitPart, hitPos
end
function SharedHelper.IgnoreConditionRay(origin, target, ignoreList, conditionFunc)
    debug.profilebegin("hlpr_3")
    local hitPart, hitPos = SharedHelper.RayCast(origin, target, ignoreList)
    debug.profileend()
    while hitPart do
        if not conditionFunc(hitPart) then
            return hitPart, hitPos, ignoreList
        end
        table.insert(ignoreList, hitPart)
        debug.profilebegin("hlpr_4")
        hitPart = SharedHelper.RayCast(origin, target, ignoreList)
        debug.profileend()
    end
end
function SharedHelper.GetMouseHitWithIgnoreFunction(ignoreFunc, ignoreList)
    local currentIgnore = ignoreList or { game.Players.LocalPlayer.Character, v_u_5.Modules.SharedMapHandler.EffectHolder }
    for _, projIgnore in pairs(SharedHelper.GetProjectileIgnore(game.Players.LocalPlayer)) do
        table.insert(currentIgnore, projIgnore)
    end
    local camera = workspace.CurrentCamera
    local mouseX, mouseY = SharedHelper.GetMousePosition()
    local inset = v_u_5.Modules.ClientDeviceHandler.GetInset()
    local mousePos = {
        ["X"] = mouseX + inset.X,
        ["Y"] = mouseY + inset.Y
    }
    local viewportRay = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
    local dir = viewportRay.Direction
    local ray = Ray.new(viewportRay.Origin, dir * 1000)
    while true do
        local hitPart, _ = game.Workspace:FindPartOnRayWithIgnoreList(ray, currentIgnore)
        if not hitPart then
            break
        end
        if not ignoreFunc(hitPart) then
            return hitPart
        end
        table.insert(currentIgnore, hitPart)
    end
    local _ = viewportRay.Origin + dir * 1000
    return hitPart
end
function SharedHelper.GetMouseHitPosition(ignoreList, randomVector)
    local currentIgnore = ignoreList or { game.Players.LocalPlayer.Character, v_u_5.Modules.SharedMapHandler.EffectHolder }
    for _, projIgnore in pairs(SharedHelper.GetProjectileIgnore(game.Players.LocalPlayer)) do
        table.insert(currentIgnore, projIgnore)
    end
    local camera = workspace.CurrentCamera
    local mouseX, mouseY = SharedHelper.GetMousePosition()
    local inset = v_u_5.Modules.ClientDeviceHandler.GetInset()
    local mousePos = {
        ["X"] = mouseX + inset.X,
        ["Y"] = mouseY + inset.Y
    }
    local viewportRay = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
    local dir = viewportRay.Direction
    if randomVector then
        local randVec = SharedHelper.GetRandomVector(randomVector)
        local cframeOrigin = CFrame.new(viewportRay.Origin, viewportRay.Origin + dir)
        local cframeAngles = CFrame.Angles
        local randX = randVec.X
        local radX = math.rad(randX)
        local randY = randVec.Y
        local radY = math.rad(randY)
        local randZ = randVec.Z
        dir = (cframeOrigin * cframeAngles(radX, radY, (math.rad(randZ)))).LookVector
    end
    local ray = Ray.new(viewportRay.Origin, dir * 1000)
    debug.profilebegin("hlpr_2")
    while true do
        local hitPart, hitPosition = game.Workspace:FindPartOnRayWithIgnoreList(ray, currentIgnore)
        if not hitPart then
            break
        end
        if not SharedHelper.ShouldIgnoreInMouseHitDetection(hitPart) then
            return hitPosition
        end
        table.insert(currentIgnore, hitPart)
    end
    return viewportRay.Origin + dir * 1000
end
local v_u_1368 = nil
function SharedHelper.BillboardDistanceSizeOptimizer(p_u_1369, p_u_1370, p_u_1371, p1372)
    local v_u_1373 = p1372 or {}
    if p_u_1369 and (p_u_1370 and p_u_1371) then
        if not p_u_1369:GetAttribute("optimizer") then
            if not v_u_1368 then
                v_u_1368 = {
                    ["CameraPosition"] = Vector3.new()
                }
                SharedHelper.InstantThread(function()
                    while true do
                        local camera_1374 = game.Workspace.CurrentCamera.CFrame.p
                        local v1375 = v_u_5.Modules.ClientCharacterHandler.LazyPos
                        if v1375 and (v1375 - camera_1374).magnitude < 25 then
                            v_u_1368.CameraPosition = v1375
                        else
                            v_u_1368.CameraPosition = camera_1374
                        end
                        wait(0.1)
                    end
                end)
                local v_u_1376 = {}
                function v_u_1368.Register(p1377, p1378)
                    v_u_1376[p1377] = p1378
                end
                function v_u_1368.Unregister(p1379)
                    v_u_1376[p1379] = nil
                end
                v_u_5.Modules.ClientDeviceHandler.OnDeviceChange("BillboardDistanceSizeOptimizer", function(_)
                    for _, v1380 in pairs(v_u_1376) do
                        v1380.Update()
                    end
                end)
            end
            p_u_1369:SetAttribute("optimizer", (p_u_1369:GetAttribute("optimizer") or 0) + 1)
            local v_u_1381 = nil
            local v_u_1382 = { 0.5, 0.25, 0.65 }
            local v_u_1383 = p_u_1369.Size.X.Offset
            local v_u_1384 = p_u_1369.Size.Y.Offset
            local PhoneStudsOffsetWorldSpaceAttr_1385 = p_u_1369:GetAttribute("PhoneStudsOffsetWorldSpace")
            local v_u_1386 = p_u_1369.StudsOffsetWorldSpace
            local function LoadStage(p1387, p1388)
                if p1387 ~= v_u_1381 or p1388 then
                    v_u_1381 = p1387
                    local v1389 = v_u_1383
                    local v1390 = v_u_1384
                    if v_u_5.Modules.ClientDeviceHandler.IsPhone() then
                        p_u_1369:SetAttribute("OriginalSizeX", v1389)
                        p_u_1369:SetAttribute("OriginalSizeY", v1390)
                        v1389 = v1389 * 0.7
                        v1390 = v1390 * 0.7
                        if PhoneStudsOffsetWorldSpaceAttr_1385 then
                            p_u_1369.StudsOffsetWorldSpace = PhoneStudsOffsetWorldSpaceAttr_1385
                        end
                    elseif PhoneStudsOffsetWorldSpaceAttr_1385 then
                        p_u_1369.StudsOffsetWorldSpace = v_u_1386
                    end
                    if p1387 == 0 then
                        p_u_1369.Size = UDim2.new(0, v1389, 0, v1390)
                        if v_u_1373.FullSizeAlwaysOnTop then
                            p_u_1369.AlwaysOnTop = true
                            return
                        end
                    else
                        p_u_1369.Size = UDim2.new(0, v1389 * p_u_1371[p1387], 0, v1390 * p_u_1371[p1387])
                        if v_u_1373.FullSizeAlwaysOnTop then
                            p_u_1369.AlwaysOnTop = false
                        end
                    end
                end
            end
            local v_u_1392 = 0
            local v_u_1393 = nil
            local v_u_1394 = p_u_1369.MaxDistance
            local function DistanceCheck(p1395)
                if p_u_1369.Parent then
                    local v1396 = v_u_1368.CameraPosition
                    if v1396 ~= v_u_1393 or p1395 then
                        v_u_1393 = v1396
                        local v1397
                        if p_u_1369.Adornee then
                            v1397 = p_u_1369.Adornee.Position
                        elseif p_u_1369.Parent.ClassName == "Attachment" then
                            v1397 = p_u_1369.Parent.WorldPosition
                        else
                            v1397 = p_u_1369.Parent.Position
                        end
                        local v1398 = (v_u_1393 - v1397).magnitude
                        for v1399, v1400 in pairs(p_u_1370) do
                            if v1398 < v1400 then
                                LoadStage(v1399 - 1, p1395)
                                return v1398
                            end
                        end
                        LoadStage(#p_u_1370, p1395)
                        return v1398
                    end
                else
                    v_u_1392 = v_u_1392 + 1
                end
            end
            v_u_1368.Register(p_u_1369, {
                ["Update"] = function()
                    DistanceCheck(true)
                end
            })
            local PlayerGuiChild_1402 = game.Players.LocalPlayer:WaitForChild("PlayerGui")
            if p_u_1369:IsDescendantOf(game.Workspace) or p_u_1369:IsDescendantOf(PlayerGuiChild_1402) then
                v_u_1392 = v_u_1392 + 1
                local v_u_1403 = v_u_1392
                local v_u_1404 = true
                local v_u_1405 = false
                SharedHelper.InstantThread(function()
                    if #p_u_1370 == 0 then
                        LoadStage(0, true)
                    else
                        while v_u_1403 == v_u_1392 do
                            local v1406 = DistanceCheck(v_u_1405)
                            v_u_1405 = false
                            if v_u_1404 then
                                v_u_1405 = true
                                v_u_1404 = false
                                SharedHelper.RSWait()
                            elseif v1406 and v_u_1394 < v1406 then
                                task.wait(2)
                            else
                                task.wait(v_u_1382[(v_u_1381 or 0) + 1])
                            end
                        end
                    end
                end)
            end
            local v_u_1411 = p_u_1369.AncestryChanged:Connect(function()
                if p_u_1369:IsDescendantOf(game.Workspace) or p_u_1369:IsDescendantOf(PlayerGuiChild_1402) then
                    v_u_1392 = v_u_1392 + 1
                    local v_u_1407 = v_u_1392
                    local v_u_1408 = true
                    local v_u_1409 = false
                    SharedHelper.InstantThread(function()
                        if #p_u_1370 == 0 then
                            LoadStage(0, true)
                        else
                            while v_u_1407 == v_u_1392 do
                                local v1410 = DistanceCheck(v_u_1409)
                                v_u_1409 = false
                                if v_u_1408 then
                                    v_u_1409 = true
                                    v_u_1408 = false
                                    SharedHelper.RSWait()
                                elseif v1410 and v_u_1394 < v1410 then
                                    task.wait(2)
                                else
                                    task.wait(v_u_1382[(v_u_1381 or 0) + 1])
                                end
                            end
                        end
                    end)
                else
                    v_u_1392 = v_u_1392 + 1
                end
            end)
            SharedHelper.OnDestroy(p_u_1369, function()
                v_u_1411:Disconnect()
                v_u_1411 = nil
                v_u_1368.Unregister(p_u_1369)
                v_u_1392 = v_u_1392 + 1
            end)
        end
    else
        return
    end
end
function SharedHelper.WaitForAttribute(p1412, p1413)
    if not p1412:GetAttribute(p1413) then
        p1412:GetAttributeChangedSignal(p1413):wait()
    end
end
function SharedHelper.WaitForPlayerCharacter(p1414)
    while not p1414.Character do
        wait()
    end
end
function SharedHelper.AdjustVFXForTimestep(p1415, p1416)
    local v1417 = p1416 == 0 and 1 or p1416
    if p1415:IsA("ParticleEmitter") then
        if not p1415:GetAttribute("OriginalLifetime") then
            p1415:SetAttribute("OriginalLifetime", p1415.Lifetime.Min)
        end
        if not p1415:GetAttribute("OriginalRate") then
            p1415:SetAttribute("OriginalRate", p1415.Rate)
        end
        if not p1415:GetAttribute("OriginalSpeed") then
            p1415:SetAttribute("OriginalSpeed", p1415.Speed.Min)
        end
        p1415.Lifetime = NumberRange.new(p1415:GetAttribute("OriginalLifetime") / v1417)
        p1415.Speed = NumberRange.new(p1415:GetAttribute("OriginalSpeed") * v1417)
    end
end
function SharedHelper.EmitTimeAdjustedVFX(p1418, p1419)
    local v1420 = p1419.Modules.SharedHelper
    local v1421 = p1419.Modules.SharedTowerDefenseHandler.GetTSSafe()
    if p1419.Modules.ClientPlayerHandler.TryWithPooling(nil, 1 / v1421) then
        for _, v1422 in p1418:GetDescendants() do
            if v1422:IsA("ParticleEmitter") then
                v1420.AdjustVFXForTimestep(v1422, v1421)
                v1422:Emit(v1422:GetAttribute("EmitCount"))
            end
        end
    end
end
function SharedHelper.WeightedChoice(p1423, p1424)
    local v_u_1425 = SharedHelper.DeepCopy(p1423)
    local v1426 = 1
    local v1427 = p1424 or {}
    for _, v1428 in pairs(v_u_1425) do
        if v1428.Weight and v1428.Weight < 1 then
            v1426 = v1428.Weight < 0.1 and 100 or 10
            if v1428.Weight < 0.01 then
                v1426 = 1000
            end
        end
    end
    for _, v1429 in pairs(v_u_1425) do
        if v1429.Weight then
            v1429.Weight = v1429.Weight * v1426
        else
            v1429.Weight = v1426
        end
    end
    local function makeChoice()
        local v1430 = 0
        for _, v1431 in pairs(v_u_1425) do
            v1430 = v1430 + (v1431.Weight or 1)
        end
        local v1432 = math.random(1, v1430)
        local v1433 = 0
        for _, v1434 in pairs(v_u_1425) do
            v1433 = v1433 + (v1434.Weight or 1)
            if v1432 <= v1433 then
                return v1434
            end
        end
    end
    if not v1427.Quantity then
        return makeChoice()
    end
    local v1436 = {}
    for _ = 1, v1427.Quantity do
        local v1437 = makeChoice()
        if v1427.Unique then
            table.remove(v_u_1425, table.find(v_u_1425, v1437))
        end
        if v1427.Incompatible then
            for _, v1438 in pairs(v1427.Incompatible) do
                if v1427.FindIncompatibleByID then
                    if table.find(v1438, v1437.ID) then
                        for _, v1439 in pairs(v1438) do
                            local v1440 = nil
                            for v1441, v1442 in pairs(v_u_1425) do
                                if v1442.ID == v1439 then
                                    v1440 = v1441
                                end
                            end
                            if v1440 then
                                table.remove(v_u_1425, v1440)
                            end
                        end
                    end
                elseif table.find(v1438, v1437) then
                    for _, v1443 in pairs(v1438) do
                        local v1444 = table.find(v_u_1425, v1443)
                        if v1444 then
                            table.remove(v_u_1425, v1444)
                        end
                    end
                end
            end
        end
        table.insert(v1436, v1437)
        if #v_u_1425 <= 0 then
            break
        end
    end
    return v1436
end
function SharedHelper.PlayAnimation(p1445, p1446, p1447)
    local v1448 = p1447 or {}
    if p1445 then
        local v1449 = p1445:FindFirstChildOfClass("Humanoid")
        if v1449 then
            if v1449.Health > 0 then
                local v1450 = v1448.AnimationID
                if not v1450 then
                    local v1451 = v_u_5.Modules.SharedItemData.GetItem(p1446)
                    if not v1451 then
                        warn(p1445:GetFullName() .. " couldn\'t play animation " .. tostring(p1446) .. " / exit 4")
                        return
                    end
                    v1450 = v1451.AnimationID
                end
                local AnimationInstance_1452 = Instance.new("Animation")
                AnimationInstance_1452.AnimationId = "rbxassetid://" .. v1450
                local v1453 = v1449:LoadAnimation(AnimationInstance_1452)
                if not v1448.NoPlay then
                    v1453:Play(v1448.fadeTime)
                end
                return v1453
            end
            warn(p1445:GetFullName() .. " couldn\'t play animation " .. tostring(p1446) .. " / exit 3")
        else
            warn(p1445:GetFullName() .. " couldn\'t play animation " .. tostring(p1446) .. " / exit 2")
        end
    else
        warn(p1445:GetFullName() .. " couldn\'t play animation " .. tostring(p1446) .. " / exit 1")
        return
    end
end
function SharedHelper.CountKeys(p1454)
    local v1455 = 0
    for _, _ in pairs(p1454) do
        v1455 = v1455 + 1
    end
    return v1455
end
function SharedHelper.OnBindableEvent(p1456, p1457, p1458)
    local BindableEventInstance_1459 = Instance.new("BindableEvent")
    BindableEventInstance_1459.Name = p1457
    BindableEventInstance_1459.Parent = p1456
    return BindableEventInstance_1459.Event:Connect(p1458), BindableEventInstance_1459
end
function SharedHelper.FireBindableEvent(p1460, p1461, ...)
    local v1462 = p1460:FindFirstChild(p1461)
    if v1462 then
        v1462:Fire(...)
    end
end
function SharedHelper.OnBindableFunction(p1463, p1464, p1465)
    local BindableFunctionInstance_1466 = Instance.new("BindableFunction")
    BindableFunctionInstance_1466.Name = p1464
    BindableFunctionInstance_1466.Parent = p1463
    BindableFunctionInstance_1466.OnInvoke = p1465
    return BindableFunctionInstance_1466
end
function SharedHelper.InvokeBindableFunction(p1467, p1468, ...)
    local v1469 = p1467:FindFirstChild(p1468)
    if v1469 then
        return v1469:Invoke(...)
    end
end
local function CreateToolManager(p1470, p_u_1471)
    if v_u_5.Modules.SharedItemData.GetItem(p1470) then
        local v_u_1472 = SharedHelper.ToolHelp.BuildToolManager(p1470, p_u_1471)
        if v_u_1472 then
            local v_u_1473 = nil
            local function PlayAnimation(p1474, p1475)
                local v1476 = p1475 or {}
                if v_u_1472.ToolProperties.Animations then
                    if v_u_5.IsClient then
                        if v_u_1472.ToolProperties.AnimationTracks then
                            if v_u_1472.ToolProperties.AnimationTracks[p1474] == false then
                                return
                            elseif v_u_1472.ToolProperties.AnimationTracks[p1474] then
                                local v1477
                                if v1476.Duration then
                                    v1477 = v_u_1472.ToolProperties.AnimationTracks[p1474].Object.Length / v1476.Duration
                                else
                                    v1477 = nil
                                end
                                local v1478 = v1476.FadeTime
                                v_u_1472.ToolProperties.AnimationTracks[p1474]:Play(v1478, nil, v1477)
                            else
                                warn("Animation not loaded: " .. tostring(p1474))
                            end
                        else
                            return
                        end
                    else
                        return
                    end
                else
                    return
                end
            end
            local function StopAnimation(p1480)
                if v_u_1472.ToolProperties.AnimationTracks then
                    if v_u_5.IsClient then
                        if v_u_1472.ToolProperties.AnimationTracks[p1480] == false then
                            return
                        elseif v_u_1472.ToolProperties.AnimationTracks[p1480] then
                            v_u_1472.ToolProperties.AnimationTracks[p1480]:Stop()
                        else
                            warn("Can\'t Stop - Animation not loaded: " .. tostring(p1480))
                        end
                    else
                        return
                    end
                else
                    return
                end
            end
            local function StopAllAnimations()
                for v1482, _ in pairs(v_u_1472.ToolProperties.AnimationTracks or {}) do
                    StopAnimation(v1482)
                end
            end
            local function PlaySoundForOthers(p1484, p1485)
                if v_u_1472.ToolProperties.Sounds then
                    local HandleChild_1486 = p_u_1471:FindFirstChild("Handle")
                    local v1487 = v_u_1472.ToolProperties.Sounds[p1484]
                    local v1488 = {}
                    for v1489, v1490 in pairs(p1485) do
                        v1488[v1489] = v1490
                    end
                    v1488.Parent = HandleChild_1486
                    SharedHelper.PlaySoundForPlayersExcept(v_u_1472.Player, v1487, v1488)
                end
            end
            local function PlayToolSound(p1492, p1493)
                local v1494 = p1493 or {}
                if v1494.UniqueID then
                    v1494.UniqueID = v_u_1472.ServerIdentifier .. "_" .. v1494.UniqueID
                end
                if v_u_5.IsServer then
                    return PlaySoundForOthers(p1492, v1494)
                elseif v_u_1472.ToolProperties.Sounds then
                    local HandleChild_1495 = p_u_1471:FindFirstChild("Handle")
                    local camera_1496 = game.Workspace.CurrentCamera
                    if camera_1496 and (HandleChild_1495 and (camera_1496.CFrame.p - HandleChild_1495.Position).magnitude < 8) then
                        HandleChild_1495 = nil
                    end
                    local v1497 = v_u_1472.ToolProperties.Sounds[p1492]
                    local v1498 = {}
                    for v1499, v1500 in pairs(v1494) do
                        v1498[v1499] = v1500
                    end
                    v1498.Parent = HandleChild_1495
                    v_u_5.Modules.ClientSoundHandler.PlaySound(v1497, v1498)
                end
            end
            local function StopToolSound(p1502)
                if p1502 then
                    local v1503 = v_u_1472.ServerIdentifier .. "_" .. p1502
                    if v_u_5.IsServer then
                        return SharedHelper.StopPlayingSoundForPlayersExcept(v_u_1472.Player, v1503)
                    end
                    v_u_5.Modules.ClientSoundHandler.StopPlayingSound(v1503)
                end
            end
            local function IsCoolingDown(p1505, p1506)
                if type(p1505) == "string" then
                    if v_u_1472.ToolProperties.Cooldowns then
                        local v1507 = v_u_1472.ToolProperties.Cooldowns[p1505]
                        if v1507 then
                            if not v_u_1472.ToolProperties.CooldownsActive then
                                v_u_1472.ToolProperties.CooldownsActive = {}
                            end
                            if v_u_5.IsServer then
                                v1507 = v1507 / 2
                            end
                            return (v_u_1472.ToolProperties.CooldownsActive[p1505] or 0) + v1507 > (p1506 or tick())
                        end
                    end
                else
                    return
                end
            end
            local function MarkCooldown(p1509, p1510)
                if type(p1509) == "string" then
                    if v_u_1472.ToolProperties.Cooldowns then
                        if v_u_1472.ToolProperties.Cooldowns[p1509] then
                            if not v_u_1472.ToolProperties.CooldownsActive then
                                v_u_1472.ToolProperties.CooldownsActive = {}
                            end
                            v_u_1472.ToolProperties.CooldownsActive[p1509] = p1510 or tick()
                        end
                    else
                        return
                    end
                else
                    return
                end
            end
            local v_u_1512 = {}
            local function BreakAction(p1513)
                if v_u_1512[p1513] then
                    v_u_1512[p1513].current = v_u_1512[p1513].current + 1
                    if v_u_1512[p1513].isActive then
                        v_u_1512[p1513].isActive = false
                        v_u_1473("ActionBroken", {
                            ["Action"] = p1513
                        })
                    end
                end
            end
            local function CheckActionBroken(p1515, p1516)
                if not v_u_1512[p1515] then
                    v_u_1512[p1515] = {
                        ["isActive"] = false,
                        ["current"] = 0
                    }
                end
                if p1516 then
                    if v_u_1512[p1515].current == p1516 then
                        v_u_1512[p1515].isActive = false
                    end
                    return v_u_1512[p1515].current ~= p1516
                end
                BreakAction(p1515)
                v_u_1512[p1515].current = v_u_1512[p1515].current + 1
                v_u_1512[p1515].isActive = true
                return v_u_1512[p1515].current
            end
            local function ActivateInheritedMethod(p1518, p1519, p1520)
                if p1518 and p1519 then
                    local v1521 = v_u_5.Modules.SharedItemData.GetItem(p1518)
                    if v1521 then
                        if v1521.ItemCategory == "Tools" then
                            return v_u_1473(v1521.ToolMethods[p1519], p1520)
                        end
                    end
                else
                    return
                end
            end
            local v_u_1523 = {}
            local function ListenUntilUnequip(p_u_1524)
                local v1525 = v_u_1523
                table.insert(v1525, function()
                    p_u_1524:Disconnect()
                end)
            end
            local v_u_1527 = {}
            v_u_1473 = function(p1528, p1529)
                local v1530
                if type(p1528) == "string" then
                    v1530 = v_u_1472.ToolMethods[p1528]
                else
                    v1530 = p1528
                end
                if not v1530 then
                    return false
                end
                local tickTime_1531 = tick()
                if IsCoolingDown(p1528, tickTime_1531) then
                    return false
                end
                local v1532 = {
                    ["IsClient"] = v_u_5.IsClient,
                    ["IsServer"] = v_u_5.IsServer,
                    ["Manager"] = v_u_1472,
                    ["Properties"] = v_u_1472.ToolProperties,
                    ["Methods"] = v_u_1472.ToolMethods,
                    ["Model"] = p_u_1471,
                    ["TempStore"] = v_u_1527,
                    ["Name"] = p_u_1471.Name,
                    ["ActivateMethod"] = v_u_1473,
                    ["ActivateInheritedMethod"] = ActivateInheritedMethod,
                    ["CheckActionBroken"] = CheckActionBroken,
                    ["BreakAction"] = BreakAction,
                    ["PlaySound"] = PlayToolSound,
                    ["StopSound"] = StopToolSound,
                    ["PlayAnimation"] = PlayAnimation,
                    ["StopAnimation"] = StopAnimation,
                    ["StopAllAnimations"] = StopAllAnimations,
                    ["MarkCooldown"] = MarkCooldown,
                    ["IsCoolingDown"] = IsCoolingDown,
                    ["ListenUntilUnequip"] = ListenUntilUnequip,
                    ["Extra"] = p1529
                }
                local v1533 = table.pack(v1530(v1532))
                MarkCooldown(p1528, tickTime_1531)
                return table.unpack(v1533)
            end
            v_u_1472.ActivateToolMethod = v_u_1473
            local function Activated()
                v_u_1472.ToolProperties.IsActivated = true
                v_u_1473("OnActivate")
                if v_u_5.IsServer then
                    v_u_1473("OnServerActivate")
                else
                    v_u_1473("OnClientActivate")
                end
            end
            local function Deactivated()
                v_u_1472.ToolProperties.IsActivated = false
                v_u_1473("OnDeactivate")
                if v_u_5.IsServer then
                    v_u_1473("OnServerDeactivate")
                else
                    v_u_1473("OnClientDeactivate")
                end
            end
            local function Unequipped()
                local v1536 = v_u_1472
                v1536.EquipNumber = v1536.EquipNumber + 1
                for _, v1537 in pairs(v_u_1523) do
                    task.spawn(v1537)
                end
                table.clear(v_u_1523)
                v_u_1472.ToolProperties.IsActivated = false
                v_u_1473("OnDeactivate")
                if v_u_5.IsServer then
                    v_u_1473("OnServerDeactivate")
                else
                    v_u_1473("OnClientDeactivate")
                end
                v_u_1473("OnUnequip")
                if v_u_5.IsServer then
                    v_u_1473("OnServerUnequip")
                else
                    v_u_1473("OnClientUnequip")
                end
            end
            local v_u_1539 = {}
            local v_u_1540 = {}
            local v_u_1541 = {}
            local function StartListeningToEvents()
                local v1542 = p_u_1471.Activated:Connect(Activated)
                local v1543 = v_u_1472.ToolData.Events
                table.insert(v1543, v1542)
                local v1544 = p_u_1471.Deactivated:Connect(Deactivated)
                local v1545 = v_u_1472.ToolData.Events
                table.insert(v1545, v1544)
                if v_u_5.IsClient and v_u_1472.Player == game.Players.LocalPlayer then
                    for _, v_u_1546 in pairs(v_u_1472.ToolProperties.Binds or {}) do
                        if v_u_1546 ~= false then
                            function v_u_1546.Activate()
                                v_u_1473(v_u_1546.Method)
                                return true
                            end
                            if v_u_1546.InputType == Enum.UserInputType.Touch then
                                local v1548 = v_u_1546.CheckShow and function()
                                    local v1547 = {
                                        ["ActivateMethod"] = v_u_1473
                                    }
                                    return v_u_1546.CheckShow(v1547)
                                end or nil
                                local v1549 = v_u_5.Modules.ClientDeviceHandler.CreateTouchBind
                                local v1550 = nil
                                local v1551 = v_u_1546.ButtonModel
                                local v1552 = {
                                    ["Call"] = function()
                                        if p_u_1471.Name == "Shovel" or p_u_1471.Name == "Sword" then
                                            p_u_1471:Activate()
                                        else
                                            v_u_1473(v_u_1546.Method, {
                                                ["ActivateTouch"] = true
                                            })
                                        end
                                        return true
                                    end,
                                    ["CheckVisible"] = v1548,
                                    ["ActivationMode"] = v_u_1546.ActivationMode
                                }
                                local v1553 = v_u_1546.GetText
                                if v1553 then
                                    v1553 = v_u_1546.GetText()
                                end
                                v1552.Title = v1553
                                local v1554 = v1549(v1550, v1551, v1552)
                                local v1555 = v_u_1541
                                table.insert(v1555, v1554)
                            elseif not v_u_1546.CheckShow or v_u_1546.CheckShow() then
                                local v1556 = v_u_5.Modules.GUI.UIDeviceSettings.KeybindButton(v_u_1546.Activate, v_u_1546.Input, "right", {
                                    ["FrameParent"] = v_u_5.Modules.GUI.Get("MouseFollower"),
                                    ["Title"] = v_u_1546.Title or v_u_1546.Method,
                                    ["MaxSize"] = Vector2.new(48, 48)
                                })
                                local v1557 = v_u_1539
                                table.insert(v1557, v1556)
                            end
                        end
                    end
                end
            end
            local function StopListeningToEvents()
                for _, v1559 in pairs(v_u_1472.ToolData.Events) do
                    v1559:Disconnect()
                end
                v_u_1472.ToolData.Events = {}
                if v_u_5.IsClient then
                    for _, v1560 in pairs(v_u_1539) do
                        v1560()
                    end
                    for _, v1561 in pairs(v_u_1541) do
                        v_u_5.Modules.ClientDeviceHandler.RemoveTouchBind(v1561)
                    end
                    v_u_1539 = {}
                    v_u_1540 = {}
                end
            end
            function v_u_1472.Equip()
                v_u_1472.IsEquipped = true
                StartListeningToEvents()
                local v1563 = v_u_1472
                v1563.EquipNumber = v1563.EquipNumber + 1
                v_u_1473("OnEquip")
                if v_u_5.IsServer then
                    v_u_1473("OnServerEquip")
                else
                    v_u_1473("OnClientEquip")
                end
            end
            function v_u_1472.Unequip()
                v_u_1472.IsEquipped = false
                StopListeningToEvents()
                for v1564, _ in pairs(v_u_1512) do
                    BreakAction(v1564)
                end
                Unequipped()
            end
            local v_u_1565 = {}
            function v_u_1472.OnDestroy(p1566)
                local v1567 = v_u_1565
                table.insert(v1567, p1566)
            end
            function v_u_1472.Destroy()
                if v_u_1472.IsDestroyed then
                    return false
                end
                v_u_1472.IsDestroyed = true
                SharedHelper.FireAllClientsExcept("DestroyToolManager", v_u_1472.Player, v_u_1472.ServerIdentifier)
                v_u_1472.Unequip()
                pcall(function()
                    p_u_1471:Destroy()
                end)
                for _, v1568 in pairs(v_u_1565) do
                    task.spawn(v1568)
                end
                return true
            end
            function v_u_1472.SetPlayer(p1569)
                v_u_1472.Player = p1569
                v_u_1472.Character = p1569.Character
                v_u_1473("OnPlayerSet")
            end
            if v_u_5.IsServer then
                function v_u_1472.FireServer() end
                function v_u_1472.InvokeServer() end
                function v_u_1472.FireClient(p1570, ...)
                    SharedHelper.FireRemoteEvent("ClientToolEvent", v_u_1472.Player, p_u_1471, p1570, ...)
                end
            else
                function v_u_1472.FireServer(p1571, ...)
                    if v_u_1472.Player == game.Players.LocalPlayer then
                        SharedHelper.FireRemoteEvent("ToolEvent", v_u_1472.ServerIdentifier, p1571, ...)
                    end
                end
                function v_u_1472.InvokeServer(p1572, ...)
                    if v_u_1472.Player == game.Players.LocalPlayer then
                        return SharedHelper.InvokeRemoteFunction("ToolFunction", v_u_1472.ServerIdentifier, p1572, ...)
                    end
                end
                function v_u_1472.FireClient() end
            end
            p_u_1471.Equipped:Connect(v_u_1472.Equip)
            p_u_1471.Unequipped:Connect(v_u_1472.Unequip)
            SharedHelper.OnDestroy(v_u_1472.Tool, function()
                if v_u_5.IsClient and v_u_1472.Player == game.Players.LocalPlayer then
                    v_u_1472.Destroy()
                end
            end)
            v_u_1473("Load")
            if v_u_5.IsClient and v_u_1472.ToolProperties.LoadAssets then
                for _, v1573 in pairs(v_u_1472.ToolProperties.LoadAssets) do
                    v_u_5.Modules.SharedContentProvider.PreloadAsset(table.unpack(v1573))
                end
            end
            return v_u_1472
        end
    end
end
SharedHelper.ToolHelp.CreateToolManager = CreateToolManager
function SharedHelper.PosInFrame(p1575, p1576)
    if p1576 then
        if p1575.X < p1576.AbsolutePosition.X then
            return false
        elseif p1575.Y < p1576.AbsolutePosition.Y then
            return false
        elseif p1575.X > p1576.AbsolutePosition.X + p1576.AbsoluteSize.X then
            return false
        else
            return p1575.Y <= p1576.AbsolutePosition.Y + p1576.AbsoluteSize.Y
        end
    else
        return false
    end
end
function SharedHelper.GetServerTime()
    return game.Workspace:GetServerTimeNow()
end
local v_u_1577 = nil
local v_u_1578 = 0
local v_u_1579 = false
local v_u_1580 = 0
function SharedHelper.GetServerUTC()
    if v_u_5.IsServer then
        return SharedHelper.GetUTC()
    end
    while v_u_1579 do
        SharedHelper.RSWait()
    end
    if not v_u_1577 then
        v_u_1579 = true
        local tickTime_1581 = tick()
        v_u_1577 = SharedHelper.InvokeRemoteFunction("GetUTC")
        local tickTime_1582 = tick()
        v_u_1578 = v_u_1577 - (tickTime_1582 - tickTime_1581) / 2 - tick()
        v_u_1579 = false
        v_u_1580 = v_u_1580 + 1
        if v_u_1580 < tickTime_1582 - tickTime_1581 then
            local v1583 = v_u_1578
            v_u_1578 = nil
            v_u_1577 = nil
            return tick() + v1583
        end
    end
    return tick() + v_u_1578
end
function SharedHelper.Instance(p1584, p1585, p1586)
    local v1587 = Instance.new(p1584)
    v1587.Name = p1586
    v1587.Parent = p1585
    return v1587
end
function SharedHelper.Load(p1588)
    v_u_5 = p1588
end
return SharedHelper
