-- Script Path: game:GetService("Players").Pawn2025.PlayerGui.LogicHolder.ClientLoader.Modules.ClientToolHandler
-- Took 0.02s to decompile.
-- Executor: Delta (1.2.729.840)

local v_u_1 = nil
local v_u_2 = nil
local v_u_3 = {}
local v_u_4 = {}
function LoadConfig(_) end
function ToolEquipped(p5) -- upvalues: (copy) v_u_3
    v_u_3.ToolEquippedSubscription.Fire(p5)
end
function ToolUnequipped(p6) -- upvalues: (copy) v_u_3
    v_u_3.ToolUnequippedSubscription.Fire(p6)
end
function LoadTool(p7, p_u_8) -- upvalues: (ref) v_u_2, (copy) v_u_4, (ref) v_u_1, (copy) v_u_3
    local v9 = game.Players.LocalPlayer.Character
    while not (v9 and v9.Parent) do
        wait()
        v9 = game.Players.LocalPlayer.Character
    end
    local v10 = v9:WaitForChild("Humanoid")
    if p_u_8 then
        if p_u_8.Parent then
            if p_u_8.Parent == game.Players.LocalPlayer:WaitForChild("Backpack") or p_u_8.Parent == v9 then
                local v_u_11 = v_u_2.ToolHelp.CreateToolManager(p7, p_u_8)
                v_u_4[p_u_8] = v_u_11
                v_u_11.OnDestroy(function()
                    -- upvalues: (ref) v_u_4, (copy) p_u_8
                    v_u_4[p_u_8] = nil
                end)
                v_u_11.SetPlayer(game.Players.LocalPlayer)
                v_u_11.ToolProperties.AnimationTracks = {}
                for v12, v13 in pairs(v_u_11.ToolProperties.Animations or {}) do
                    if v13 == false then
                        v_u_11.ToolProperties.AnimationTracks[v12] = false
                    else
                        local v14 = v_u_1.Modules.SharedItemData.GetItem(v13)
                        if v14 then
                            local v15 = Instance.new("Animation")
                            v15.AnimationId = v_u_2.AssetFormat(v14.AnimationID)
                            v15.Parent = v10
                            local v_u_16 = v10:LoadAnimation(v15)
                            local v17 = {
                                ["Duration"] = v_u_16.Length,
                                ["Object"] = v_u_16,
                                ["Play"] = function(_, ...) -- upvalues: (copy) v_u_16
                                    v_u_16:Play(...)
                                end,
                                ["Stop"] = function(_, ...) -- upvalues: (copy) v_u_16
                                    v_u_16:Stop(...)
                                end
                            }
                            v_u_11.ToolProperties.AnimationTracks[v12] = v17
                        else
                            warn("Animation could not be loaded: " .. tostring(v13))
                        end
                    end
                end
                if v_u_11.ToolProperties.AutoEquip or v_u_11.Tool:GetAttribute("AutoEquip") then
                    task.spawn(function()
                        -- upvalues: (ref) v_u_3, (copy) v_u_11
                        v_u_3.UnequipAllTools()
                        local v18 = game.Players.LocalPlayer.Character
                        if v18 then
                            local v19 = v18:FindFirstChildOfClass("Humanoid")
                            if v19 then
                                game.Workspace:SetAttribute("NoCharacterEffectSounds", tick() + 1)
                                v19:EquipTool(v_u_11.Tool)
                            end
                        else
                            return
                        end
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
function v_u_3.GetToolManager(p20) -- upvalues: (copy) v_u_4
    return v_u_4[p20]
end
function v_u_3.UnequipAllTools() local v21 = game.Players.LocalPlayer.Character
    if v21 then
        local v22 = v21:FindFirstChildOfClass("Humanoid")
        if v22 then
            v22:UnequipTools()
        end
    else
        return
    end
end
function ToolCall(p23, p24, p25) -- upvalues: (copy) v_u_3
    local v26 = v_u_3.GetToolManager(p23)
    if v26 then
        if v26.Player == game.Players.LocalPlayer then
            if v26.ToolMethods[p24] then
                return v26.ActivateToolMethod(p24, p25 or {})
            end
        end
    else
        return
    end
end
function ConnectEvents() -- upvalues: (ref) v_u_2
    v_u_2.OnRemoteEvent("ClientToolEvent", ToolCall)
    v_u_2.OnRemoteEvent("LoadTool", LoadTool)
end
local v_u_27 = nil
function v_u_3.SetBackpackEnabled(p28, p29) -- upvalues: (ref) v_u_27
    v_u_27.Set(p28, p29)
end
function v_u_3.GetPlayerEquippedToolManager(p30) -- upvalues: (copy) v_u_3
    local v31 = game.Players.LocalPlayer:WaitForChild("Backpack"):GetChildren()
    local v32 = game.Players.LocalPlayer.Character
    local v33 = v32 and v32:FindFirstChildOfClass("Tool")
    if v33 then
        table.insert(v31, v33)
    end
    for _, v34 in pairs(v31) do
        local v35 = v_u_3.GetToolManager(v34)
        if v35 and v35.ToolID == p30 then
            return v35, v34.Parent == v32
        end
    end
end
local v_u_36 = {}
function v_u_3.OnInventoryChanged(p37, p38) -- upvalues: (copy) v_u_36
    v_u_36[p37] = p38
end
function v_u_3.GetToolCount() return 0
end
local v_u_39 = nil
function EquipLastTool() -- upvalues: (ref) v_u_2, (ref) v_u_39
    v_u_2.VerbosePCall(function()
        -- upvalues: (ref) v_u_39
        if v_u_39 then
            local v40 = game.Players.LocalPlayer.Character
            if v40 then
                if v40:FindFirstChildOfClass("Tool") then
                    return
                else
                    local v41 = game.Players.LocalPlayer.Backpack:FindFirstChild(v_u_39)
                    v_u_39 = nil
                    if v41 then
                        local v42 = v40:FindFirstChildOfClass("Humanoid")
                        if v42 then
                            game.Workspace:SetAttribute("NoCharacterEffectSounds", tick() + 1)
                            v42:EquipTool(v41)
                        end
                    else
                        return
                    end
                end
            else
                return
            end
        else
            return
        end
    end)
end
function SaveLastTool() -- upvalues: (ref) v_u_2, (ref) v_u_39
    v_u_2.VerbosePCall(function()
        -- upvalues: (ref) v_u_39
        v_u_39 = nil
        local v43 = game.Players.LocalPlayer.Character
        if v43 then
            local v44 = v43:FindFirstChildOfClass("Tool")
            if v44 then
                v_u_39 = v44.Name
            end
        else
            return
        end
    end)
end
function v_u_3.CharacterAdded(p_u_45) -- upvalues: (ref) v_u_39, (copy) v_u_3, (copy) v_u_36
    v_u_39 = nil
    local v_u_46 = game.Players.LocalPlayer:WaitForChild("Backpack")
    function v_u_3.GetToolCount() -- upvalues: (copy) p_u_45, (copy) v_u_46
        local v47 = p_u_45:FindFirstChildOfClass("Tool") and 1 or 0
        return #v_u_46:GetChildren() + v47
    end
    local v_u_48 = nil
    local v49 = p_u_45:FindFirstChildOfClass("Tool") and 1 or 0
    local v50 = #v_u_46:GetChildren() + v49
    if v50 ~= v_u_48 then
        v_u_48 = v50
        for _, v51 in pairs(v_u_36) do
            v51(v50)
        end
    end
    v_u_46.ChildAdded:Connect(function()
        -- upvalues: (copy) p_u_45, (copy) v_u_46, (ref) v_u_48, (ref) v_u_36
        local v52 = p_u_45:FindFirstChildOfClass("Tool") and 1 or 0
        local v53 = #v_u_46:GetChildren() + v52
        if v53 ~= v_u_48 then
            v_u_48 = v53
            for _, v54 in pairs(v_u_36) do
                v54(v53)
            end
        end
    end)
    v_u_46.ChildRemoved:Connect(function()
        -- upvalues: (copy) p_u_45, (copy) v_u_46, (ref) v_u_48, (ref) v_u_36
        local v55 = p_u_45:FindFirstChildOfClass("Tool") and 1 or 0
        local v56 = #v_u_46:GetChildren() + v55
        if v56 ~= v_u_48 then
            v_u_48 = v56
            for _, v57 in pairs(v_u_36) do
                v57(v56)
            end
        end
    end)
    p_u_45.ChildAdded:Connect(function(p58)
        -- upvalues: (copy) p_u_45, (copy) v_u_46, (ref) v_u_48, (ref) v_u_36
        if p58.ClassName == "Tool" then
            ToolEquipped(p58)
            local v59 = p_u_45:FindFirstChildOfClass("Tool") and 1 or 0
            local v60 = #v_u_46:GetChildren() + v59
            if v60 ~= v_u_48 then
                v_u_48 = v60
                for _, v61 in pairs(v_u_36) do
                    v61(v60)
                end
            end
        else
            return
        end
    end)
    p_u_45.ChildRemoved:Connect(function(p62)
        -- upvalues: (copy) p_u_45, (copy) v_u_46, (ref) v_u_48, (ref) v_u_36
        if p62.ClassName == "Tool" then
            ToolUnequipped(p62)
            local v63 = p_u_45:FindFirstChildOfClass("Tool") and 1 or 0
            local v64 = #v_u_46:GetChildren() + v63
            if v64 ~= v_u_48 then
                v_u_48 = v64
                for _, v65 in pairs(v_u_36) do
                    v65(v64)
                end
            end
        else
            return
        end
    end)
end
function v_u_3.Load(p66) -- upvalues: (ref) v_u_1, (ref) v_u_2, (copy) v_u_3, (ref) v_u_27
    v_u_1 = p66
    v_u_2 = v_u_1.Modules.SharedHelper
    LoadConfig(v_u_1.Config)
    ConnectEvents()
    v_u_3.ToolEquippedSubscription = v_u_2.CreateSubscription()
    v_u_3.ToolUnequippedSubscription = v_u_2.CreateSubscription()
    game:GetService("StarterGui")
    local v67 = {
        ["OnActivate"] = function() game.Workspace:SetAttribute("BackpackDisabled", false)
        end,
        ["OnDeactivate"] = function() -- upvalues: (ref) v_u_3
            v_u_3.UnequipAllTools()
            game.Workspace:SetAttribute("BackpackDisabled", true)
        end
    }
    v_u_27 = v_u_2.CreateAndGate(v67)
    v_u_27.Deactivate("Loading")
    v_u_27.Activate("NotFocusedPopup")
    v_u_27.Activate("NotInteracting")
    game.Workspace:GetAttributeChangedSignal("PlayerInteracting"):Connect(function()
        -- upvalues: (ref) v_u_3
        if game.Workspace:GetAttribute("PlayerInteracting") then
            v_u_3.SetBackpackEnabled("NotInteracting", false)
        else
            v_u_3.SetBackpackEnabled("NotInteracting", true)
        end
    end)
    v_u_1.BindToLoadedModules(function()
        -- upvalues: (ref) v_u_1, (ref) v_u_2, (ref) v_u_27
        v_u_1.Modules.ClientDataHandler.OnDataLoaded(function()
            -- upvalues: (ref) v_u_2, (ref) v_u_27
            v_u_2.InstantThread(function()
                -- upvalues: (ref) v_u_27
                while game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("LoadingGui") do
                    wait()
                end
                v_u_27.Activate("Loading")
            end)
        end, "ClientToolHandler")
    end, "ClientToolHandler")
end
return v_u_3
