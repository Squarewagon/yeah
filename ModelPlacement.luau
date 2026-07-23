-- Script Path: game:GetService("Players").Pawn2025.PlayerGui.LogicHolder.ClientLoader.Modules.SharedModelPlacement
-- Took 0.02s to decompile.
-- Executor: Delta (1.2.729.840)

local ModelPlacement = {}
game:GetService("Players")
game:GetService("ReplicatedStorage")
local GameHandler = nil
local SharedHelper = nil
local Config = nil
local HitboxPart = nil
function ModelPlacement.IsPlacementValid(cframe, size, ignoreModels, originPos, maxDistance, teamIndex) -- name: IsPlacementValid
    -- upvalues: (ref) SharedHelper, (ref) HitboxPart
    if game.Workspace:GetAttribute("PlacementDisabled") and not game.Players.LocalPlayer:GetAttribute("PlacementEnabled") then
        return false, "disabled"
    end
    local ignoreList = ignoreModels or {}
    local maxDist = maxDistance or 100
    for _, model in pairs(SharedHelper.GetPlaceableModels()) do
        if not table.find(ignoreList, model) and model then
            table.insert(ignoreList, model)
        end
    end
    local workspace = game.Workspace
    table.insert(ignoreList, workspace:WaitForChild("EffectHolder"))
    if originPos and (originPos - cframe.Position).Magnitude > maxDist then
        return false, "distance"
    end
    HitboxPart.CFrame = cframe
    HitboxPart.Size = size
    local partsInHitbox = game.Workspace:GetPartsInPart(HitboxPart)
    local pvpDivider = SharedHelper.IsPvpAsync() and game.Workspace:WaitForChild("Map"):FindFirstChild("Divider", true)
    if pvpDivider then
        local dividerOffset = pvpDivider.CFrame:PointToObjectSpace(cframe.Position).X
        if dividerOffset <= 0 and teamIndex == 2 then
            return false, "wronghalf"
        end
        if dividerOffset >= 0 and teamIndex == 1 then
            return false, "wronghalf"
        end
    end
    for _, hitPart in ipairs(partsInHitbox) do
        if not hitPart:GetAttribute("IgnorePlacementCollisions") then
            local isIgnored = false
            for _, ignoredModel in pairs(ignoreList) do
                if ignoredModel:IsAncestorOf(hitPart) or (ignoredModel == hitPart or (hitPart.CollisionGroup == "Character" or (hitPart.CollisionGroup == "Enemy" or hitPart.Transparency == 1 and hitPart.Name ~= "TempHitbox"))) or hitPart:IsA("SpawnLocation") then
                    isIgnored = true
                    break
                end
            end
            if not isIgnored then
                return false, "collision"
            end
        end
    end
    return true
end
function ModelPlacement.GetPlacementCFrame(model, ignoreModels, rotationY, maxDistance, params) -- name: GetPlacementCFrame
    -- upvalues: (ref) GameHandler, (ref) SharedHelper, (copy) ModelPlacement
    if game.Workspace:GetAttribute("PlacementDisabled") and not game.Players.LocalPlayer:GetAttribute("PlacementEnabled") then
        return CFrame.new(), false, "disabled"
    end
    local placementParams = params or {}
    local maxDist = maxDistance or 100
    local ignoreList = ignoreModels or {}
    local effectHolder = GameHandler.Modules.SharedMapHandler.EffectHolder
    table.insert(ignoreList, effectHolder)
    local rotY = rotationY or 0
    local localPlayer = game.Players.LocalPlayer
    local character = localPlayer.Character
    if not character then
        return nil, false
    end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return nil, false
    end
    local mousePos = SharedHelper.GetMouseHitPosition()
    local cameraPos = game.Workspace.CurrentCamera.CFrame.Position
    local rayDirection = (mousePos - cameraPos).Unit * 500
    local raycastParams = RaycastParams.new()
    if placementParams.UseWhitelist then
        raycastParams.FilterType = Enum.RaycastFilterType.Include
        raycastParams.FilterDescendantsInstances = placementParams.WhitelistFunction()
    else
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = { character, model, table.unpack(ignoreList) }
    end
    local modelSize = model.Size
    local cframeRot = CFrame.Angles(0, math.rad(rotY), 0)
    local rayResult = game.Workspace:Raycast(cameraPos, rayDirection, raycastParams)
    if not rayResult then
        if placementParams.BadResult then
            placementParams.BadResult()
        end
        local boundsRayParams = RaycastParams.new()
        boundsRayParams.FilterType = Enum.RaycastFilterType.Exclude
        boundsRayParams.FilterDescendantsInstances = { character, model, table.unpack(ignoreList) }
        local boundsRayResult = game.Workspace:Raycast(cameraPos, rayDirection, boundsRayParams)
        if not boundsRayResult then
            return nil, false
        end
        local boundsPos = boundsRayResult.Position
        return CFrame.new(boundsPos) * cframeRot, false, "bounds"
    end
    local hitPos = rayResult.Position
    if rayResult.Normal:Dot(Vector3.new(0, 1, 0)) <= 0.75 then
        return CFrame.new(hitPos) * cframeRot, false, "noground"
    end
    local placementCF = CFrame.new(hitPos) * cframeRot
    if placementParams.FinalCF then
        placementCF = placementParams.FinalCF(placementCF, rayResult)
    end
    local isValidFunc = ModelPlacement.IsPlacementValid
    local hitboxSize = modelSize + Vector3.new(0.2, 0.2, 0.2)
    local validIgnoreList = {}
    local filterInstances = raycastParams.FilterDescendantsInstances
    __set_list(validIgnoreList, 1, {model, table.unpack(filterInstances)})
    local isValid, reason = isValidFunc(placementCF, hitboxSize, validIgnoreList, rootPart.Position, maxDist, localPlayer:GetAttribute("TeamIndex"))
    return placementCF, isValid, reason
end
local CurrentRotation = 180
local CurrentGhost = nil
function ModelPlacement.StartGhost(modelTemplate, ghostParams) -- name: StartGhost
    -- upvalues: (ref) CurrentGhost, (ref) CurrentRotation, (ref) SharedHelper, (ref) GameHandler, (copy) ModelPlacement
    local rotateAmount = ghostParams.CustomRotateAmount or 45
    if CurrentGhost then
        CurrentGhost.Destroy()
        CurrentGhost = nil
    end
    local ghostModel = modelTemplate:Clone()
    local ghostData = {
        ["Info"] = {
            ["Position"] = nil,
            ["Rotation"] = nil,
            ["Valid"] = false,
            ["Position"] = Vector3.new(),
            ["Rotation"] = CurrentRotation - CurrentRotation % rotateAmount
        }
    }
    SharedHelper.Ghostify(ghostModel)
    ghostModel.Parent = GameHandler.Modules.SharedMapHandler.EffectHolder
    local isDestroyed = false
    local function destroyFunc() -- name: Destroy
        -- upvalues: (ref) isDestroyed, (copy) ghostModel
        if isDestroyed then
            return
        else
            isDestroyed = true
            if ghostModel.Parent then
                ghostModel:Destroy()
            end
        end
    end
    task.spawn(function()
        -- upvalues: (copy) ghostModel, (ref) ModelPlacement, (copy) ghostData, (copy) ghostParams, (ref) SharedHelper
        while ghostModel.Parent do
            local ghostIgnore = { ghostModel }
            local ghostCF, isValid, reason = ModelPlacement.GetPlacementCFrame(ghostModel.PrimaryPart, ghostIgnore, ghostData.Info.Rotation, nil, ghostParams)
            if ghostCF then
                ghostData.Info.Position = ghostCF.p
                ghostData.Info.CF = ghostCF
            end
            ghostData.Info.Valid = isValid
            ghostData.Info.Reason = reason
            if isValid then
                SharedHelper.ChangeModelColor(ghostModel, Color3.fromRGB(85, 255, 127))
            else
                SharedHelper.ChangeModelColor(ghostModel, Color3.fromRGB(255, 32, 80))
            end
            if ghostCF then
                ghostModel:PivotTo(ghostCF)
            end
            SharedHelper.RSWait()
        end
    end)
    ghostData.Destroy = destroyFunc
    function ghostData.Rotate()
        -- upvalues: (copy) ghostData, (copy) rotateAmount, (ref) CurrentRotation
        local info = ghostData.Info
        info.Rotation = info.Rotation + rotateAmount
        if ghostData.Info.Rotation == 360 then
            ghostData.Info.Rotation = 0
        end
        CurrentRotation = ghostData.Info.Rotation
    end
    if ghostParams.GhostLoaded then
        ghostParams.GhostLoaded(ghostModel)
    end
    if CurrentGhost then
        CurrentGhost.Destroy()
        CurrentGhost = nil
    end
    CurrentGhost = ghostData
    return ghostData
end
function ModelPlacement.Load(gameHandler) -- name: Load
    -- upvalues: (ref) GameHandler, (ref) SharedHelper, (ref) Config, (ref) HitboxPart
    GameHandler = gameHandler
    SharedHelper = GameHandler.Modules.SharedHelper
    Config = GameHandler.Config
    HitboxPart = Instance.new("Part")
    HitboxPart.Anchored = true
    HitboxPart.CanCollide = false
    HitboxPart.Transparency = 1
    HitboxPart:AddTag("MouseIgnore")
    HitboxPart.Parent = GameHandler.Modules.SharedMapHandler.EffectHolder
end
return ModelPlacement
