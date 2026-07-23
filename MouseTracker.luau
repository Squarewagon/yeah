-- Script Path: game:GetService("Players").Pawn2025.PlayerGui.LogicHolder.ClientLoader.Modules.ClientInputHandler.MouseTracker
-- Took 0.16s to decompile.
-- Executor: Delta (1.2.729.840)

local MouseTracker = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Icon = Mouse.Icon
local TrackedEntries = {}
local CurrentEntry = nil
local OnClickNothingCallbacks = {}
local RenderSteppedConnection = nil
local InputBeganConnection = nil
local InputEndedConnection = nil
local TouchInputState = nil
local function uiUnderCursor(mouseLocation) -- upvalues: (copy) UserInputService, (copy) GuiService, (copy) LocalPlayer
    local mousePosition = mouseLocation or UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then
        return false
    end
    local guiObjects = playerGui:GetGuiObjectsAtPosition(mousePosition.X, mousePosition.Y)
    for _, guiObject in ipairs(guiObjects) do
        if guiObject:IsA("TextButton") or guiObject:IsA("ImageButton") then
            return true
        end
        if guiObject:IsA("Frame") and guiObject.BackgroundTransparency < 1 then
            return true
        end
        if guiObject:IsA("ImageLabel") and guiObject.ImageTransparency < 1 then
            return true
        end
    end
    return false
end
local function enableQuery(target) if target:IsA("BasePart") then
        target.CanQuery = true
    else
        for _, descendant in ipairs(target:GetDescendants()) do
            if descendant:IsA("BasePart") then
                descendant.CanQuery = true
            end
        end
    end
end
local function targetMatchesEntry(entry, target) if not target then
        return false
    end
    local entryObject = entry.object
    if not (entryObject and entryObject.Parent) then
        return false
    end
    if entryObject:IsA("Model") then
        if not target:IsDescendantOf(entryObject) then
            return false
        end
    else
        if not entryObject:IsA("BasePart") then
            return false
        end
        if target ~= entryObject then
            return false
        end
    end
    if entry.ignore then
        for _, ignoreObj in ipairs(entry.ignore) do
            if ignoreObj and (target == ignoreObj or target:IsDescendantOf(ignoreObj)) then
                return false
            end
        end
    end
    return true
end
local function getEntryFromTarget(target) -- upvalues: (copy) TrackedEntries, (copy) targetMatchesEntry
    if not target then
        return nil
    end
    for _, entry in ipairs(TrackedEntries) do
        if targetMatchesEntry(entry, target) then
            return entry
        end
    end
    return nil
end
local function getGlobalIgnoreList() -- upvalues: (copy) CollectionService, (copy) TrackedEntries, (copy) MouseTracker, (copy) LocalPlayer
    local ignoreList = CollectionService:GetTagged("MouseIgnore")
    for _, entry in ipairs(TrackedEntries) do
        if entry.ignore then
            for _, ignoreObj in ipairs(entry.ignore) do
                if ignoreObj then
                    table.insert(ignoreList, ignoreObj)
                end
            end
        end
    end
    if MouseTracker.ClientCameraHandler and (MouseTracker.ClientCameraHandler.IsFirstPerson and (MouseTracker.ClientCameraHandler.IsFirstPerson() and LocalPlayer.Character)) then
        local character = LocalPlayer.Character
        table.insert(ignoreList, character)
    end
    return ignoreList
end
local function getTargetAtScreenPosition(screenPosition) -- upvalues: (copy) Workspace, (copy) getGlobalIgnoreList
    local camera = Workspace.CurrentCamera
    if camera then
        local ray = camera:ViewportPointToRay(screenPosition.X, screenPosition.Y)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = getGlobalIgnoreList()
        raycastParams.IgnoreWater = true
        local raycastResult = Workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
        if raycastResult then
            return raycastResult.Instance
        else
            return nil
        end
    else
        return nil
    end
end
local function updateHover() -- upvalues: (copy) LocalPlayer, (copy) uiUnderCursor, (ref) CurrentEntry, (copy) Mouse, (copy) Icon, (copy) getTargetAtScreenPosition, (copy) UserInputService, (copy) getEntryFromTarget
    local hasTool = LocalPlayer.Character
    if hasTool then
        hasTool = hasTool:FindFirstChildWhichIsA("Tool") ~= nil
    end
    if hasTool or uiUnderCursor() then
        if CurrentEntry then
            if CurrentEntry.hovering and CurrentEntry.OnStop then
                CurrentEntry.OnStop()
            end
            CurrentEntry.hovering = false
            CurrentEntry = nil
            Mouse.Icon = Icon
        end
    else
        local targetEntry = getEntryFromTarget((getTargetAtScreenPosition(UserInputService:GetMouseLocation())))
        if targetEntry ~= CurrentEntry then
            if CurrentEntry and (CurrentEntry.hovering and CurrentEntry.OnStop) then
                CurrentEntry.OnStop()
                CurrentEntry.hovering = false
            end
            CurrentEntry = targetEntry
            if CurrentEntry and not CurrentEntry.hovering then
                CurrentEntry.hovering = true
                if CurrentEntry.OnHover then
                    CurrentEntry.OnHover()
                end
                Mouse.Icon = "rbxassetid://104277630115925"
                return
            end
            Mouse.Icon = Icon
        end
    end
end
local function fireClickAnywhereElse(ignoreEntry) -- upvalues: (copy) TrackedEntries
    for _, entry in ipairs(TrackedEntries) do
        if entry ~= ignoreEntry and entry.OnClickAnywhereElse then
            task.spawn(function()
                -- upvalues: (copy) entry
                pcall(entry.OnClickAnywhereElse)
            end)
        end
    end
end
local function fireClickNothing() -- upvalues: (copy) OnClickNothingCallbacks, (copy) fireClickAnywhereElse
    for _, callback in ipairs(OnClickNothingCallbacks) do
        task.spawn(function()
            -- upvalues: (copy) callback
            pcall(callback)
        end)
    end
    fireClickAnywhereElse(nil)
end
local function onInputBegan(input, gameProcessed) -- upvalues: (copy) LocalPlayer, (copy) uiUnderCursor, (ref) TouchInputState, (copy) updateHover, (copy) UserInputService, (ref) CurrentEntry, (copy) MouseTracker, (copy) fireClickAnywhereElse, (copy) fireClickNothing
    if input.UserInputType == Enum.UserInputType.Touch then
        if not gameProcessed then
            local hasTool = LocalPlayer.Character
            if hasTool then
                hasTool = hasTool:FindFirstChildWhichIsA("Tool") ~= nil
            end
            if not (hasTool or uiUnderCursor()) then
                updateHover()
                TouchInputState = {
                    ["input"] = input,
                    ["startTime"] = os.clock(),
                    ["startPosition"] = UserInputService:GetMouseLocation(),
                    ["startEntry"] = CurrentEntry,
                    ["startHadTrackedTarget"] = CurrentEntry ~= nil
                }
                return
            end
        end
        TouchInputState = nil
        return
    elseif not gameProcessed or input.UserInputType == Enum.UserInputType.Gamepad1 then
        updateHover()
        if not uiUnderCursor() then
            local hasTool = LocalPlayer.Character
            if hasTool then
                hasTool = hasTool:FindFirstChildWhichIsA("Tool") ~= nil
            end
            if not hasTool then
                local isClickInput
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isClickInput = true
                elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
                    isClickInput = input.KeyCode == Enum.KeyCode.ButtonA and true or input.KeyCode == Enum.KeyCode.ButtonR2
                else
                    isClickInput = false
                end
                if isClickInput then
                    if CurrentEntry and CurrentEntry.hovering then
                        local entry = CurrentEntry
                        if entry and entry.OnClick then
                            if MouseTracker.PlaySound then
                                MouseTracker.PlaySound(entry.ClickSound or "sn_ui_button")
                            end
                            entry.OnClick()
                        end
                        fireClickAnywhereElse(entry)
                    else
                        fireClickNothing()
                    end
                else
                    return
                end
            end
        end
    end
end
local function onInputEnded(input, gameProcessed) -- upvalues: (ref) TouchInputState, (copy) UserInputService, (copy) LocalPlayer, (copy) uiUnderCursor, (copy) updateHover, (ref) CurrentEntry, (copy) MouseTracker, (copy) fireClickAnywhereElse, (copy) fireClickNothing
    if input.UserInputType == Enum.UserInputType.Touch then
        if gameProcessed then
            TouchInputState = nil
            return
        elseif TouchInputState and TouchInputState.input == input then
            local state = TouchInputState
            TouchInputState = nil
            if os.clock() - state.startTime > 0.5 then
                return
            elseif (UserInputService:GetMouseLocation() - state.startPosition).Magnitude > 40 then
                return
            else
                local hasTool = LocalPlayer.Character
                if hasTool then
                    hasTool = hasTool:FindFirstChildWhichIsA("Tool") ~= nil
                end
                if hasTool or uiUnderCursor() then
                    return
                else
                    updateHover()
                    local entry = CurrentEntry
                    if state.startEntry and entry == state.startEntry then
                        if entry and entry.OnClick then
                            if MouseTracker.PlaySound then
                                MouseTracker.PlaySound(entry.ClickSound or "sn_ui_button")
                            end
                            entry.OnClick()
                        end
                        fireClickAnywhereElse(entry)
                    elseif not (state.startHadTrackedTarget or entry) then
                        fireClickNothing()
                    end
                end
            end
        else
            return
        end
    else
        return
    end
end
function MouseTracker.StartTracking(target, params, ignore) -- upvalues: (copy) enableQuery, (copy) TrackedEntries, (ref) RenderSteppedConnection, (copy) RunService, (copy) updateHover, (ref) InputBeganConnection, (copy) UserInputService, (copy) onInputBegan, (ref) InputEndedConnection, (copy) onInputEnded, (ref) CurrentEntry, (copy) Mouse, (copy) Icon, (ref) TouchInputState
    if typeof(target) == "Instance" then
        if target:IsA("Player") then
            target = target.Character or target.CharacterAdded:Wait()
        end
    else
        target = nil
    end
    if target then
        local isInstance = target:IsA("Instance")
    end
    assert(isInstance, "StartTracking expects a BasePart, Model, or Player")
    local isValidTarget = target:IsA("Model") or target:IsA("BasePart")
    assert(isValidTarget, "StartTracking expects a BasePart, Model, or Player character")
    enableQuery(target)
    local params = params or {}
    local newEntry = {
        ["object"] = nil,
        ["OnHover"] = nil,
        ["OnStop"] = nil,
        ["OnClick"] = nil,
        ["OnClickAnywhereElse"] = nil,
        ["ignore"] = nil,
        ["hovering"] = false,
        ["object"] = target,
        ["OnHover"] = params.OnHover,
        ["OnStop"] = params.OnStopHover,
        ["OnClick"] = params.OnClick,
        ["OnClickAnywhereElse"] = params.OnClickAnywhereElse,
        ["ignore"] = ignore
    }
    local entries = TrackedEntries
    table.insert(entries, newEntry)
    if not RenderSteppedConnection then
        RenderSteppedConnection = RunService.RenderStepped:Connect(updateHover)
    end
    if not InputBeganConnection then
        InputBeganConnection = UserInputService.InputBegan:Connect(onInputBegan)
    end
    if not InputEndedConnection then
        InputEndedConnection = UserInputService.InputEnded:Connect(onInputEnded)
    end
    local stopped = false
    local function stop() -- upvalues: (ref) stopped, (ref) CurrentEntry, (copy) newEntry, (ref) Mouse, (ref) Icon, (ref) TrackedEntries, (ref) RenderSteppedConnection, (ref) InputBeganConnection, (ref) InputEndedConnection, (ref) TouchInputState
        if stopped then
            return
        end
        stopped = true
        if CurrentEntry == newEntry then
            if newEntry.hovering and newEntry.OnStop then
                newEntry.OnStop()
            end
            newEntry.hovering = false
            CurrentEntry = nil
            Mouse.Icon = Icon
        end
        for index, entry in ipairs(TrackedEntries) do
            if entry == newEntry then
                table.remove(TrackedEntries, index)
                break
            end
        end
        if #TrackedEntries == 0 then
            if RenderSteppedConnection then
                RenderSteppedConnection:Disconnect()
                RenderSteppedConnection = nil
            end
            if InputBeganConnection then
                InputBeganConnection:Disconnect()
                InputBeganConnection = nil
            end
            if InputEndedConnection then
                InputEndedConnection:Disconnect()
                InputEndedConnection = nil
            end
            TouchInputState = nil
        end
    end
    return setmetatable({
        ["Destroy"] = stop
    }, {
        ["__call"] = stop
    })
end
function MouseTracker.OnClickNothing(callback) -- upvalues: (copy) OnClickNothingCallbacks
    local isFunction = typeof(callback) == "function"
    assert(isFunction, "Callback must be a function")
    local callbacks = OnClickNothingCallbacks
    table.insert(callbacks, callback)
    local disconnected = false
    return function()
        -- upvalues: (ref) disconnected, (ref) OnClickNothingCallbacks, (copy) callback
        if not disconnected then
            disconnected = true
            for index, cb in ipairs(OnClickNothingCallbacks) do
                if cb == callback then
                    table.remove(OnClickNothingCallbacks, index)
                    return
                end
            end
        end
    end
end
function MouseTracker.Cleanup() -- upvalues: (ref) CurrentEntry, (copy) Mouse, (copy) Icon, (ref) RenderSteppedConnection, (ref) InputBeganConnection, (ref) InputEndedConnection, (ref) TouchInputState, (copy) TrackedEntries, (copy) OnClickNothingCallbacks
    if CurrentEntry then
        if CurrentEntry.hovering and CurrentEntry.OnStop then
            CurrentEntry.OnStop()
        end
        CurrentEntry.hovering = false
        CurrentEntry = nil
        Mouse.Icon = Icon
    end
    if RenderSteppedConnection then
        RenderSteppedConnection:Disconnect()
        RenderSteppedConnection = nil
    end
    if InputBeganConnection then
        InputBeganConnection:Disconnect()
        InputBeganConnection = nil
    end
    if InputEndedConnection then
        InputEndedConnection:Disconnect()
        InputEndedConnection = nil
    end
    TouchInputState = nil
    table.clear(TrackedEntries)
    table.clear(OnClickNothingCallbacks)
    Mouse.Icon = Icon
end
return MouseTracker
