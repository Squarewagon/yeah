-- Script Path: game:GetService("Players").Pawn2025.PlayerGui.LogicHolder.ClientLoader.GameHandler
-- Took 0.01s to decompile.
-- Executor: Delta (1.2.729.840)

local LogService = game:GetService("LogService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local GameHandler = {
    ["Modules"] = nil,
    ["SharedLogic"] = nil,
    ["DoneLoading"] = false,
    ["Modules"] = {},
    ["SharedLogic"] = {}
}
local LoadedModules = {}
local LoadCallbacks = {}
local SharedHelper = nil
local ServerModules = {
    ["LoadBeforeShared"] = { "ServerTeleportHandler" },
    ["LoadAfterShared"] = {
        "ServerPlayerHandler",
        "ServerDataHandler",
        "ServerToolHandler",
        "ServerChatHandler",
        "ServerPhysicsHandler",
        "ServerAdminAbuse"
    }
}
local SharedModules = {
    "SharedItemData",
    "ZoneMinus",
    "SharedARG",
    "SharedCollectables",
    "SharedMapHandler",
    "SharedTowerDefenseHandler",
    "SharedModelPlacement",
    "SharedPolicyHandler",
    "SharedNotifications",
    "SharedReplication",
    "SharedContentProvider",
    "SharedWanderingTrader",
    "SharedDownedSystem",
    "SharedConfigService",
    "SharedHumanoidLag",
    "SharedStoryline"
}
local ClientModules = {
    ["LoadBeforeShared"] = {},
    ["LoadAfterShared"] = {
        "ClientPlayerHandler",
        "ClientDataHandler",
        "ClientTopBarPlus",
        "ClientToolHandler",
        "ClientDeviceHandler",
        "ClientGUIHandler",
        "ClientInputHandler",
        "ClientCharacterHandler",
        "ClientAssetManager",
        "ClientEffectHandler",
        "ClientSoundHandler",
        "ClientCameraHandler",
        "ClientChatHandler",
        "ClientYoutuberHandler",
        "ClientMondoTextHandler",
        "ClientCutsceneHandler"
    }
}
function Output(_) end
function LoadErrorKeeper()

    local ErrorKeeperFolder = SharedHelper.CreateInstance("Folder", {
        ["Name"] = GameHandler.IsClient and "C_ERROR_KEEPER" or "S_ERROR_KEEPER",
        ["Parent"] = ReplicatedStorage
    })
    function GameHandler.TrackMessage(message, printToConsole)

        local stringValue = Instance.new("StringValue")
        local count = #ErrorKeeperFolder:GetChildren()
        stringValue.Name = tostring(count)
        stringValue.Value = message
        stringValue.Parent = ErrorKeeperFolder
        if printToConsole then
            print(message)
        end
    end
    LogService.MessageOut:Connect(function(message, messageType)

        if table.find({ Enum.MessageType.MessageError }, messageType) then
            local formattedMessage = tostring(messageType) .. ": " .. message
            local stringValue = Instance.new("StringValue")
            local count = #ErrorKeeperFolder:GetChildren()
            stringValue.Name = tostring(count)
            stringValue.Value = formattedMessage
            stringValue.Parent = ErrorKeeperFolder
        end
    end)
end
function WrapFunctionProfile(func, profileName)

    if GameHandler.IsStudio then
        return func
    else
        return type(func) == "function" and function(...)

            debug.profilebegin(profileName)
            local returns = table.pack(func(...))
            debug.profileend()
            return table.unpack(returns)
        end or func
    end
end
function FireEventForAllModules(eventName, arg1, ...)

    Output("EVENT " .. tostring(eventName))
    for _, moduleName in pairs(LoadedModules) do
        local startTime = tick()
        Output("Call Event " .. tostring(eventName) .. " for " .. moduleName)
        SharedHelper.SafeCall(GameHandler.Modules[moduleName][eventName], arg1, ...)
        local OutputFunc = Output
        local eventNameStr = tostring(eventName)
        local elapsedTime = tick() - startTime
        OutputFunc("Done Call Event " .. eventNameStr .. " for " .. moduleName .. " - took: " .. tostring(elapsedTime))
    end
end
function FireCallOnLoadCBs()

    local callbacksCopy = SharedHelper.DeepCopy(LoadCallbacks)
    table.clear(LoadCallbacks)
    local function wrapCallback(callbackData)

        local MonitorLoadingTime = SharedHelper.MonitorLoadingTime
        local callbackID = callbackData.ID
        local endMonitorFunc = MonitorLoadingTime("FireCallOnLoadCBs - " .. tostring(callbackID), true)
        callbackData.Call()
        endMonitorFunc()
    end
    for _, callbackDataThread in pairs(callbacksCopy) do
        if callbackDataThread.NewThread then
            task.spawn(wrapCallback, callbackDataThread)
        end
    end
    for _, callbackData in pairs(callbacksCopy) do
        if not callbackData.NewThread then
            local MonitorLoadingTime = SharedHelper.MonitorLoadingTime
            local callbackID = callbackData.ID
            local endMonitorFunc = MonitorLoadingTime("FireCallOnLoadCBs - " .. tostring(callbackID), true)
            callbackData.Call()
            endMonitorFunc()
        end
    end
end
function GameHandler.BindToLoadedModules(callback, id, newThread)

    local shouldSpawn = newThread ~= false and true or newThread
    local callbacksTable = LoadCallbacks
    table.insert(callbacksTable, {
        ["Call"] = callback,
        ["ID"] = id or "unknown",
        ["NewThread"] = shouldSpawn or false
    })
    if GameHandler.DoneLoading then
        FireCallOnLoadCBs()
    end
end
function LoadBindable()

    local function AccessFunc(index, ...)

        if index == "Config" then
            return GameHandler.Config
        elseif index == "BindToLoadedModules" then
            return GameHandler.BindToLoadedModules
        elseif index == "SharedLogic" then
            return GameHandler.SharedLogic
        elseif index then
            return SharedHelper.GetSubTable(GameHandler.Modules, index, ...)
        else
            return GameHandler
        end
    end
    SharedHelper.CreateInstance("BindableFunction", {
        ["Name"] = "Access",
        ["Parent"] = nil,
        ["OnInvoke"] = nil,
        ["Parent"] = script,
        ["OnInvoke"] = WrapFunctionProfile(AccessFunc, "Access")
    })
    SharedHelper.CreateInstance("BindableEvent", {
        ["Name"] = "PersistentCall",
        ["Parent"] = nil,
        ["Parent"] = script
    }).Event:Connect(function(func)

        WrapFunctionProfile(func, "PersistentCall")(GameHandler)
    end)
    GameHandler.TrackMessage("Done loading bindables")
end
function ConnectEvents()

    local function onPlayerAdded(player)

        FireEventForAllModules("PlayerAdded", player)
        if GameHandler.IsClient and player ~= game.Players.LocalPlayer then
            if player.Character then
                FireEventForAllModules("OtherPlayerCharacterAdded", player.Character, player)
            end
            player.CharacterAdded:connect(function(character)

                FireEventForAllModules("OtherPlayerCharacterAdded", character, player)
            end)
        else
            local characterAddedConnection = player.CharacterAdded:connect(function(character)

                FireEventForAllModules("CharacterAdded", character, player)
            end)
            if GameHandler.IsServer then
                GameHandler.Modules.ServerPlayerHandler.BindToPlayerTrove(player, characterAddedConnection)
            end
            if player.Character then
                SharedHelper.InstantThread(function()

                    FireEventForAllModules("CharacterAdded", player.Character, player)
                end)
            end
        end
    end
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(function(...)
        FireEventForAllModules("PlayerRemoving", ...)
    end)
    for _, player in pairs(Players:GetPlayers()) do
        SharedHelper.InstantThread(function()

            onPlayerAdded(player)
        end)
    end
    GameHandler.TrackMessage("Done connecting events")
end
function InitModule(moduleName, moduleParent)

    local module = require((moduleParent or script.Parent:WaitForChild("Modules")):WaitForChild(moduleName))
    GameHandler.Modules[moduleName] = module
    return module
end
function LoadModules(moduleList, listName, moduleParent)

    if moduleList and #moduleList > 0 then
        Output("Loading module list " .. listName)
        for _, moduleName in pairs(moduleList) do
            Output(moduleName .. " - start loading module")
            local endMonitorTime = SharedHelper.MonitorLoadingTime("GameHandler - Loading module " .. tostring(moduleName))
            local module = InitModule(moduleName, moduleParent)
            for funcName, func in pairs(module) do
                module[funcName] = WrapFunctionProfile(func, moduleName .. "_" .. funcName)
            end
            SharedHelper.SafeCall(module.Load, GameHandler)
            Output(moduleName .. " - done loading module")
            endMonitorTime()
            GameHandler.TrackMessage("Loaded module " .. moduleName)
            if table.find(LoadedModules, moduleName) then
                warn(GameHandler.Side .. ": Module already loaded: " .. moduleName)
            else
                local loadedList = LoadedModules
                table.insert(loadedList, moduleName)
            end
        end
        Output("Done loading modules")
    end
end
function LoadPlugins()

    local side = GameHandler.IsClient and "Client" or "Server"
    Output("Loading plugins...", SharedHelper.GetSubTable(GameHandler.Config, "Plugins"))
    local sharedPlugins = SharedHelper.DeepCopy(SharedHelper.GetSubTable(GameHandler.Config, "SharedPlugins") or {})
    local sidePlugins = SharedHelper.GetSubTable(GameHandler.Config, "Plugins")
    local allPlugins = SharedHelper.AppendTable(sharedPlugins, sidePlugins)
    for _, pluginName in pairs(allPlugins) do
        LoadModules({ pluginName }, "Plugin loader " .. pluginName, script.Parent:WaitForChild("Plugins"))
        LoadModules(GameHandler.Modules[pluginName].SharedModules, "Plugin shared " .. pluginName, script.Parent.Plugins:WaitForChild(pluginName))
        LoadModules(GameHandler.Modules[pluginName][side .. "Modules"], "Plugin side " .. pluginName, script.Parent.Plugins:WaitForChild(pluginName))
    end
    for moduleName, extraFuncs in pairs(SharedHelper.GetSubTable(GameHandler.Config, "ExtraModuleFunctionality") or {}) do
        for funcName, extraFunc in pairs(extraFuncs) do
            GameHandler.Modules[moduleName][funcName] = function(...)

                extraFunc(GameHandler, GameHandler.Modules[moduleName], ...)
            end
        end
    end
end
function LoadShared()

    LoadModules(SharedModules, "Shared modules")
end
function CheckOneTimeCall(side)

    if Workspace:GetAttribute("GameHandlerLoaded" .. side) then
        error(side .. " side already loaded!")
    else
        Workspace:SetAttribute("GameHandlerLoaded" .. side, true)
    end
end
function LoadServer()

    GameHandler.Side = "Server"
    CheckOneTimeCall("Server")
    spawn(function()
        while true do
            pcall(function()
                local placeId = game.PlaceId
                local iconId = game:GetService("MarketplaceService"):GetProductInfo(placeId).IconImageAssetId
                game.Workspace:SetAttribute("PlaceIconID", (tostring(iconId)))
            end)
            wait(600)
        end
    end)
    LoadModules(ServerModules.LoadBeforeShared, "Server modules before shared")
    LoadShared()
    LoadModules(ServerModules.LoadAfterShared, "Server modules after shared")
    LoadPlugins()
    GameHandler.TrackMessage("Done loading server modules")
end
function LoadClient()

    GameHandler.Side = "Client"
    CheckOneTimeCall("Client")
    LoadModules(ClientModules.LoadBeforeShared, "Client modules before shared")
    LoadShared()
    LoadModules(ClientModules.LoadAfterShared, "Client modules after shared")
    LoadPlugins()
end
function LoadConfig()

    GameHandler.Config = require(GameHandler.ScriptObject:WaitForChild("SharedConfig"))
    local localConfig = require(GameHandler.ScriptObject:WaitForChild("Config"))
    for configKey, configValue in pairs(localConfig) do
        GameHandler.Config[configKey] = configValue
    end
end
function GameHandler.Load(scriptObject)

    GameHandler.StartTick = tick()
    GameHandler.IsStudio = RunService:IsStudio()
    GameHandler.IsServer = RunService:IsServer()
    GameHandler.IsClient = not GameHandler.IsServer
    GameHandler.ScriptObject = scriptObject
    if RunService:IsServer() then
        function WrapFunctionProfile(func)
            return func
        end
    else
        function WrapFunctionProfile(func)
            return func
        end
    end
    LoadConfig()
    InitModule("SharedHelper")
    SharedHelper = GameHandler.Modules.SharedHelper
    SharedHelper.Load(GameHandler)
    LoadErrorKeeper()
    if GameHandler.IsServer then
        local TrackMessageFunc = GameHandler.TrackMessage
        local placeVersion = game.PlaceVersion
        TrackMessageFunc("Loading game handler server. Game version " .. tostring(placeVersion), true)
    else
        local TrackMessageFunc = GameHandler.TrackMessage
        local placeVersion = game.PlaceVersion
        TrackMessageFunc("Loading game handler client. Game version " .. tostring(placeVersion), true)
    end
    if GameHandler.IsServer then
        LoadServer()
    else
        LoadClient()
    end
    LoadBindable()
    ConnectEvents()
    GameHandler.DoneLoading = true
    GameHandler.TrackMessage("Done loading, firing call on load...")
    FireCallOnLoadCBs()
end
return GameHandler