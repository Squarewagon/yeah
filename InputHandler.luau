-- Script Path: game:GetService("Players").Pawn2025.PlayerGui.LogicHolder.ClientLoader.Modules.ClientInputHandler
-- Took 0.05s to decompile.
-- Executor: Delta (1.2.729.840)

local v_u_1 = nil
local v_u_2 = nil
local UserInputService = game:GetService("UserInputService")
local v_u_4 = 0
local v_u_5 = {}
local v_u_6 = {}
local v_u_7 = {}
function LoadConfig(_) end
function CheckTable(p8, p9) if not p8[p9] then
        p8[p9] = {}
    end
end
function v_u_5.Bind(p10) -- upvalues: (ref) v_u_4, (ref) v_u_2, (copy) v_u_6, (copy) v_u_7
    v_u_4 = v_u_4 + 1
    local v11 = v_u_4
    p10.StoreKey = tostring(v11)
    local v12 = v_u_2.AccessSubTable
    local v13 = v_u_6
    local v14 = p10.InputMoment
    local v15 = tostring(v14)
    local v16 = p10.InputType
    local v17 = v12(v13, v15, (tostring(v16)))
    local v18
    if p10.InputType == Enum.UserInputType.Keyboard then
        local v19 = p10.KeyCode
        v18 = tostring(v19)
        if not v17[v18] then
            v17[v18] = {}
        end
        local v20 = v17[v18]
        table.insert(v20, p10)
    else
        v18 = nil
    end
    v_u_7[p10.StoreKey] = {
        ["SaveTable"] = v17,
        ["SaveKey"] = v18
    }
    return p10.StoreKey
end
function v_u_5.Unbind(p21) -- upvalues: (copy) v_u_7
    if v_u_7[p21] then
        v_u_7[p21].SaveTable[v_u_7[p21].SaveKey] = nil
        v_u_7[p21] = nil
    end
end
function processInput(p22, p23, p24) -- upvalues: (ref) v_u_2, (copy) v_u_6
    if p23 then
        return
    else
        local v25 = v_u_2.GetSubTable
        local v26 = v_u_6
        local v27 = tostring(p24)
        local v28 = p22.UserInputType
        local v29 = v25(v26, v27, (tostring(v28)))
        if v29 then
            if p22.UserInputType == Enum.UserInputType.Keyboard then
                local v30 = v_u_2.GetSubTable
                local v31 = p22.KeyCode
                v29 = v30(v29, (tostring(v31)))
            end
            if v29 then
                for v32 = #v29, 1, -1 do
                    if v29[v32].Activate() then
                        break
                    end
                end
            end
        else
            return
        end
    end
end
function onInputBegan(p33, p34) processInput(p33, p34, Enum.UserInputState.Begin)
end
function onInputEnded(p35, p36) processInput(p35, p36, Enum.UserInputState.End)
end
function ConnectEvents() -- upvalues: (copy) UserInputService
    UserInputService.InputBegan:Connect(onInputBegan)
    UserInputService.InputEnded:Connect(onInputEnded)
end
function v_u_5.Load(p37) -- upvalues: (ref) v_u_1, (ref) v_u_2, (copy) v_u_5
    v_u_1 = p37
    v_u_2 = v_u_1.Modules.SharedHelper
    v_u_5.MouseTracker = require(script:WaitForChild("MouseTracker"))
    v_u_5.MouseTracker.Helper = v_u_2
    v_u_1.BindToLoadedModules(function()
        -- upvalues: (ref) v_u_5, (ref) v_u_1
        v_u_5.MouseTracker.ClientCameraHandler = v_u_1.Modules.ClientCameraHandler
        v_u_5.MouseTracker.PlaySound = v_u_1.Modules.ClientSoundHandler.PlaySound
    end, "ClientInputHandler")
    LoadConfig(v_u_1.Config)
    ConnectEvents()
end
return v_u_5