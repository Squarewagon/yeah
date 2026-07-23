-- Script Path: game:GetService("Players").Pawn2025.PlayerGui.LogicHolder.ClientLoader.Plugins.UserInterface.GUI.GameControls

local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
game:GetService("RunService")
local Players = game:GetService("Players")
local Trove = require(ReplicatedStorage.Modules.Others.Trove)
local Stream = require(ReplicatedStorage.Modules.Others.Stream)
local BigText = require(ReplicatedStorage.Modules.Gui.BigText)
local GameControls = {
    ["HideBottomMenu"] = false
}
local GUIModule = nil
local ClientHandler = nil
local ClientGUIHandler = nil
local Helper = nil
function Init() -- upvalues: (ref) GUIModule, (copy) GameControls, (ref) ClientHandler, (ref) ClientGUIHandler, (ref) Helper
    GUIModule = GameControls.Modules.GUI
    ClientHandler = GameControls.Modules.ClientHandler
    ClientGUIHandler = GameControls.Modules.ClientGUIHandler
    Helper = GameControls.Modules.Helper
end
function updateVotes(votes, voteContainer) -- upvalues: (ref) Helper
    for _, voteFrame in pairs(voteContainer:GetChildren()) do
        if voteFrame:FindFirstChild("Voters") then
            for _, voterImage in pairs(voteFrame.Voters:GetChildren()) do
                if voterImage.Name ~= "UIListLayout" and voterImage.Name ~= "Template" then
                    voterImage:Destroy()
                end
            end
        end
    end
    for playerName, voteChoice in pairs(votes or {}) do
        local player = game.Players:FindFirstChild(playerName)
        if player then
            local choiceFrame = voteContainer:FindFirstChild(voteChoice)
            if choiceFrame then
                local newVoterImage = choiceFrame:WaitForChild("Voters"):WaitForChild("Template"):Clone()
                newVoterImage.Name = playerName
                newVoterImage.Image = Helper.GetPlayerImage(player.UserId, Enum.ThumbnailType.HeadShot)
                newVoterImage.Visible = true
                newVoterImage.Parent = choiceFrame:WaitForChild("Voters")
            end
        end
    end
end
function showFrameVotes(votes, voteContainer) -- upvalues: (ref) Helper
    for _, voterImage in pairs(voteContainer:GetChildren()) do
        if voterImage.Name ~= "UIListLayout" and voterImage.Name ~= "Template" then
            voterImage:Destroy()
        end
    end
    for playerName, _ in pairs(votes or {}) do
        local player = game.Players:FindFirstChild(playerName)
        if player then
            local newVoterImage = voteContainer:WaitForChild("Template"):Clone()
            newVoterImage.Name = playerName
            newVoterImage.Image = Helper.GetPlayerImage(player.UserId, Enum.ThumbnailType.HeadShot)
            newVoterImage.Visible = true
            newVoterImage.Parent = voteContainer
        end
    end
end
function loadTS() -- upvalues: (ref) GUIModule, (ref) Helper, (ref) ClientGUIHandler, (ref) ClientHandler
    local tickSpeedControls = GUIModule.Get("TopNoInset"):WaitForChild("WaveControls"):WaitForChild("TickSpeed")
    local tickSpeedMobile = GUIModule.Get("TopNoInset"):WaitForChild("WaveControls"):WaitForChild("TickSpeedMobile")
    if Helper.IsDungeonAsync() then
        task.spawn(function()
            -- upvalues: (copy) tickSpeedControls, (copy) tickSpeedMobile
            while true do
                tickSpeedControls.Visible = false
                tickSpeedMobile.Visible = false
                wait(1)
            end
        end)
    else
        local function updateTickSpeedMobileText() -- upvalues: (copy) tickSpeedMobile
            if tickSpeedMobile:WaitForChild("Items").Visible then
                tickSpeedMobile:WaitForChild("Title").Text = "Cancel"
            else
                local titleLabel = tickSpeedMobile:WaitForChild("Title")
                local currentTickSpeed = game.Workspace:GetAttribute("TickSpeed") or 1
                titleLabel.Text = "Game Speed: x" .. tostring(currentTickSpeed)
            end
        end
        ClientGUIHandler.BindButton(tickSpeedMobile, function() -- upvalues: (copy) tickSpeedMobile, (copy) updateTickSpeedMobileText
            tickSpeedMobile:WaitForChild("Items").Visible = not tickSpeedMobile:WaitForChild("Items").Visible
            updateTickSpeedMobileText()
        end)
        for speedMultiplier = 1, 3 do
            ClientGUIHandler.BindButton(tickSpeedControls:WaitForChild("Items"):WaitForChild((tostring(speedMultiplier))), function()
                -- upvalues: (ref) Helper, (copy) speedMultiplier
                Helper.InvokeRemoteFunction("ChangeTickSpeed", speedMultiplier)
            end)
            ClientGUIHandler.BindButton(tickSpeedMobile:WaitForChild("Items"):WaitForChild((tostring(speedMultiplier))), function()
                -- upvalues: (copy) tickSpeedMobile, (copy) updateTickSpeedMobileText, (ref) Helper, (copy) speedMultiplier
                tickSpeedMobile:WaitForChild("Items").Visible = not tickSpeedMobile:WaitForChild("Items").Visible
                updateTickSpeedMobileText()
                Helper.InvokeRemoteFunction("ChangeTickSpeed", speedMultiplier)
            end)
        end
        local function updateSelectedTickSpeed() -- upvalues: (ref) ClientHandler, (copy) tickSpeedControls, (copy) tickSpeedMobile, (copy) updateTickSpeedMobileText
            local currentTickSpeed = game.Workspace:GetAttribute("TickSpeed") or 1
            if table.find({ 1, 2, 3 }, currentTickSpeed) then
                for speedMultiplier = 1, 3 do
                    ClientHandler.Modules.GUI.Sections.UnitViewer.LoadUnitRarity(tickSpeedControls:WaitForChild("Items"):WaitForChild((tostring(speedMultiplier))), "ra_gray")
                    ClientHandler.Modules.GUI.Sections.UnitViewer.LoadUnitRarity(tickSpeedMobile:WaitForChild("Items"):WaitForChild((tostring(speedMultiplier))), "ra_gray")
                end
                ClientHandler.Modules.GUI.Sections.UnitViewer.LoadUnitRarity(tickSpeedControls:WaitForChild("Items"):WaitForChild((tostring(currentTickSpeed))), "ra_green")
                ClientHandler.Modules.GUI.Sections.UnitViewer.LoadUnitRarity(tickSpeedMobile:WaitForChild("Items"):WaitForChild((tostring(currentTickSpeed))), "ra_green")
                updateTickSpeedMobileText()
            end
        end
        updateSelectedTickSpeed()
        game.Workspace:GetAttributeChangedSignal("TickSpeed"):Connect(updateSelectedTickSpeed)
    end
end
function GameControls.Load() -- upvalues: (ref) GUIModule, (ref) ClientHandler, (ref) Helper, (ref) ClientGUIHandler, (copy) Stream, (copy) Trove, (copy) BigText, (copy) Players
    Init()
    loadTS()
    local isAutoSkipEnabled = false
    local skipWaveFrame = GUIModule.Get("TopNoInset"):WaitForChild("SkipWave")
    local skipVoteValue = nil
    ClientHandler.BindToLoadedModules(function() end, "GameControls")
    local function updateShowSkipButton() -- upvalues: (ref) skipVoteValue, (ref) isAutoSkipEnabled, (ref) Helper, (ref) ClientHandler, (copy) skipWaveFrame
        if game.Workspace:GetAttribute("MapId") == "map_tutorial" then
            return
        elseif game.Workspace:GetAttribute("CanSkipWave") then
            skipVoteValue = nil
            if isAutoSkipEnabled then
                skipVoteValue = "y"
                Helper.InvokeRemoteFunction("SkipWave", skipVoteValue)
                task.delay(0.1, function()
                    -- upvalues: (ref) ClientHandler, (ref) skipWaveFrame
                    if game.Workspace:GetAttribute("CanSkipWave") then
                        ClientHandler.Modules.ClientGUIHandler.FrameVisibleAndGate(skipWaveFrame, "default", true)
                    end
                end)
            else
                ClientHandler.Modules.ClientGUIHandler.FrameVisibleAndGate(skipWaveFrame, "default", true)
            end
        else
            ClientHandler.Modules.ClientGUIHandler.FrameVisibleAndGate(skipWaveFrame, "default", false)
            return
        end
    end
    updateShowSkipButton()
    game.Workspace:GetAttributeChangedSignal("CanSkipWave"):Connect(updateShowSkipButton)
    Helper.OnRemoteEvent("UpdateTDVotes", function(voteType, votesTable)
        -- upvalues: (copy) skipWaveFrame
        if voteType == "SkipWave" then
            if #game.Players:GetPlayers() == 1 then
                skipWaveFrame:WaitForChild("Button"):WaitForChild("Title").Text = "Skip Wave >>"
            else
                local voteCount = 0
                for _, _ in pairs(votesTable or {}) do
                    voteCount = voteCount + 1
                end
                local titleLabel = skipWaveFrame:WaitForChild("Button"):WaitForChild("Title")
                local voteCountStr = tostring(voteCount)
                local halfPlayers = #game.Players:GetPlayers() / 2
                local requiredVotes = math.floor(halfPlayers) + 1
                titleLabel.Text = "Skip Wave (" .. voteCountStr .. " / " .. tostring(requiredVotes) .. ")"
            end
            showFrameVotes(votesTable, skipWaveFrame:WaitForChild("Button"):WaitForChild("Voters"))
        end
    end)
    ClientGUIHandler.BindButton(skipWaveFrame:WaitForChild("Button"), function()
        -- upvalues: (ref) skipVoteValue, (ref) Helper
        if skipVoteValue then
            skipVoteValue = nil
        else
            skipVoteValue = "y"
        end
        Helper.InvokeRemoteFunction("SkipWave", skipVoteValue)
    end)
    local waveControls = GUIModule.Get("TopNoInset"):WaitForChild("WaveControls")
    ClientHandler.Modules.GUI.Sections.UnitViewer.LoadUnitRarity(waveControls:WaitForChild("AutoSkip"), "ra_epic")
    ClientGUIHandler.BindButton(waveControls:WaitForChild("AutoSkip"), function()
        -- upvalues: (ref) isAutoSkipEnabled, (copy) waveControls, (ref) ClientHandler, (copy) skipWaveFrame, (ref) skipVoteValue, (ref) Helper
        isAutoSkipEnabled = not isAutoSkipEnabled
        if isAutoSkipEnabled then
            waveControls:WaitForChild("AutoSkip"):WaitForChild("Title").Text = "Auto Skip: On"
            ClientHandler.Modules.GUI.Sections.UnitViewer.LoadUnitRarity(waveControls:WaitForChild("AutoSkip"), "ra_green")
            if skipWaveFrame.Visible and skipVoteValue ~= "y" then
                skipVoteValue = "y"
                Helper.InvokeRemoteFunction("SkipWave", skipVoteValue)
                return
            end
        else
            waveControls:WaitForChild("AutoSkip"):WaitForChild("Title").Text = "Auto Skip: Off"
            ClientHandler.Modules.GUI.Sections.UnitViewer.LoadUnitRarity(waveControls:WaitForChild("AutoSkip"), "ra_epic")
        end
    end)
    if Helper.IsTdGameAsync() then
        local function updateWaveControlsVisibility() -- upvalues: (copy) waveControls, (ref) Helper
            if game.Workspace:GetAttribute("CanSkipWaves") == false then
                waveControls:WaitForChild("AutoSkip").Visible = false
            end
            if game.Workspace:GetAttribute("MapId") == "map_tutorial" or Helper.IsPvpAsync() then
                if game.Workspace:GetAttribute("MapId") == "map_tutorial" then
                    waveControls.Visible = true
                    waveControls:WaitForChild("AutoSkip").Visible = false
                else
                    waveControls.Visible = false
                end
            else
                waveControls.Visible = true
                return
            end
        end
        updateWaveControlsVisibility()
        game.Workspace:GetAttributeChangedSignal("MapId"):Connect(updateWaveControlsVisibility)
        game.Workspace:GetAttributeChangedSignal("CanSkipWaves"):Connect(updateWaveControlsVisibility)
        local function updatePauseResumeVisibility() -- upvalues: (copy) waveControls
            local pauseButton = waveControls:WaitForChild("Pause")
            local canPause = game.Workspace:GetAttribute("CanPause") and not game.Workspace:GetAttribute("GamePauseScheduled")
            if canPause then
                canPause = not game.Workspace:GetAttribute("GamePaused")
            end
            pauseButton.Visible = canPause
            local resumeButton = waveControls:WaitForChild("Resume")
            local canResume = game.Workspace:GetAttribute("CanPause")
            if canResume then
                canResume = not waveControls:WaitForChild("Pause").Visible
            end
            resumeButton.Visible = canResume
        end
        updatePauseResumeVisibility()
        for _, attributeName in pairs({ "CanPause", "GamePauseScheduled", "GamePaused" }) do
            game.Workspace:GetAttributeChangedSignal(attributeName):Connect(updatePauseResumeVisibility)
        end
        ClientGUIHandler.BindButton(waveControls:WaitForChild("Pause"), function()
            -- upvalues: (ref) Helper
            Helper.InvokeRemoteFunction("PauseGameplay", true)
        end)
        ClientGUIHandler.BindButton(waveControls:WaitForChild("Resume"), function()
            -- upvalues: (ref) Helper
            Helper.InvokeRemoteFunction("PauseGameplay", false)
        end)
    end
    Helper.InstantThread(function()
        -- upvalues: (copy) waveControls, (ref) ClientHandler, (ref) GUIModule, (ref) Helper
        if waveControls.Visible then
            ClientHandler.Modules.ClientGUIHandler.FrameVisibleAndGate(GUIModule.Get("TopNoInset"):WaitForChild("WaveControls"), "pvp", not Helper.IsPvpAsync())
            local function updateCanChangeTickSpeed() -- upvalues: (ref) ClientHandler, (ref) GUIModule
                ClientHandler.Modules.ClientGUIHandler.FrameVisibleAndGate(GUIModule.Get("TopNoInset"):WaitForChild("WaveControls"), "wrkCanChangeTickSpeed", game.Workspace:GetAttribute("CanChangeTickSpeed") ~= false)
            end
            ClientHandler.Modules.ClientGUIHandler.FrameVisibleAndGate(GUIModule.Get("TopNoInset"):WaitForChild("WaveControls"), "wrkCanChangeTickSpeed", game.Workspace:GetAttribute("CanChangeTickSpeed") ~= false)
            game.Workspace:GetAttributeChangedSignal("CanChangeTickSpeed"):Connect(updateCanChangeTickSpeed)
        end
    end)
    if Helper.IsTdGameAsync() then
        Stream.listenTidy(Stream.attributeOf(workspace, "TickSpeed"), function(newTickSpeed)
            -- upvalues: (ref) Trove, (ref) BigText, (ref) Players
            local textTrove = Trove.new()
            if typeof(newTickSpeed) == "number" then
                local screenGui = Instance.new("ScreenGui")
                screenGui.Archivable = false
                screenGui.ResetOnSpawn = false
                screenGui.Name = "TickSpeedBigTextOverlay"
                screenGui.IgnoreGuiInset = true
                screenGui.DisplayOrder = 5
                local bigTextLabel = BigText.mount(textTrove, ("x%* Speed!"):format(newTickSpeed), Color3.new(0.917647, 0.917647, 0.917647), false, 3)
                bigTextLabel.Position = UDim2.fromScale(0, 0)
                bigTextLabel.Parent = screenGui
                screenGui.Parent = Players.LocalPlayer.PlayerGui
                textTrove:Add(task.delay(5, function()
                    -- upvalues: (copy) textTrove
                    task.spawn(function()
                        -- upvalues: (ref) textTrove
                        textTrove:Destroy()
                    end)
                end))
            end
            return textTrove
        end)
    end
end
return GameControls
