-- ==========================================
-- INTEGRATED NEX HUB & RAYFIELD INTERFACE SUITE
-- ==========================================

local HttpService = game:GetService("HttpService")
local vim = game:GetService("VirtualInputManager")
local players = game:GetService("Players")
local TS = game:GetService("TweenService")
local workspace = game:GetService("Workspace")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local coreGui = (gethui and gethui()) or game:GetService("CoreGui") or players.LocalPlayer:WaitForChild("PlayerGui")

local player = players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local HRP = character:WaitForChild("HumanoidRootPart")

-- Flags & Variables
local tweening = false
local index = 1
local pastePercent = 0
local usedList = {}
local selectedBase = nil
local autofarm = false
local rescaleClick = false
local ignoreAnchored = true
local clipboard = nil
local playerToBring = nil
local sitInMouseClickSeatToggle = false
local specialList = {"Glue"}

-- Custom GUI Variables (NEX Hub)
local inspectBase = nil
local inspectTargetName = ""
local firstSeat = nil
local secondSeat = nil

-- ==========================================
-- GIAO DIỆN XEM VẬT LIỆU (CỬA SỔ NHỎ NEX)
-- ==========================================
local matGui = Instance.new("ScreenGui")
matGui.Name = "NEXMaterialGui"
matGui.Parent = coreGui
matGui.Enabled = false

local matFrame = Instance.new("Frame", matGui)
matFrame.Size = UDim2.new(0, 300, 0, 400)
matFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
matFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
matFrame.BorderSizePixel = 0
matFrame.Active = true
Instance.new("UICorner", matFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", matFrame).Color = Color3.fromRGB(0, 150, 255)

local matTitle = Instance.new("TextLabel", matFrame)
matTitle.Size = UDim2.new(1, 0, 0, 40)
matTitle.Text = " VẬT LIỆU CẦN THIẾT"
matTitle.TextColor3 = Color3.new(1,1,1)
matTitle.Font = Enum.Font.GothamBold
matTitle.TextSize = 14
matTitle.TextXAlignment = Enum.TextXAlignment.Left
matTitle.BackgroundTransparency = 1

local closeBtn = Instance.new("TextButton", matFrame)
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -40, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.MouseButton1Click:Connect(function() matGui.Enabled = false end)

local matScroll = Instance.new("ScrollingFrame", matFrame)
matScroll.Size = UDim2.new(1, -20, 1, -50)
matScroll.Position = UDim2.new(0, 10, 0, 40)
matScroll.BackgroundTransparency = 1
matScroll.ScrollBarThickness = 4
matScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local uiList = Instance.new("UIListLayout", matScroll)
uiList.Padding = UDim.new(0, 5)
uiList.SortOrder = Enum.SortOrder.Name

-- Kéo thả cửa sổ Vật Liệu
local matDragging, matDragInput, matDragStart, matStartPos
matTitle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        matDragging = true
        matDragStart = input.Position
        matStartPos = matFrame.Position
    end
end)
matTitle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        matDragInput = input
    end
end)
UIS.InputChanged:Connect(function(input)
    if input == matDragInput and matDragging then
        local delta = input.Position - matDragStart
        matFrame.Position = UDim2.new(matStartPos.X.Scale, matStartPos.X.Offset + delta.X, matStartPos.Y.Scale, matStartPos.Y.Offset + delta.Y)
    end
end)
matTitle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        matDragging = false
    end
end)

-- ==========================================
-- TẠO NÚT THU NHỎ / MỞ RỘNG (FLOATING BUTTON NEX)
-- ==========================================
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "NEXToggleGui"
toggleGui.Parent = coreGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Parent = toggleGui
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Position = UDim2.new(0, 10, 0, 100)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "NEX"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.BorderSizePixel = 0
toggleBtn.ZIndex = 999

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = toggleBtn

local stroke = Instance.new("UIStroke")
stroke.Parent = toggleBtn
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0, 150, 255)

local dragging, dragInput, dragStart, startPos
toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = toggleBtn.Position
    end
end)
toggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
toggleBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

toggleBtn.MouseButton1Click:Connect(function()
    vim:SendKeyEvent(true, Enum.KeyCode.G, false, game)
    task.wait()
    vim:SendKeyEvent(false, Enum.KeyCode.G, false, game)
end)

-- ==========================================
-- CORE FUNCTIONS (MERGED & PRESERVED)
-- ==========================================
local blockData = player:WaitForChild("Data")
local blocksFolder = workspace:WaitForChild("Blocks")

local function getBlockID(name)
    return blockData:FindFirstChild(name) and blockData:FindFirstChild(name).Value or 9
end

local function setTransparency(transparencyWanted : number, block : Model) : ()
    if not block then return end
    if block.PPart.Transparency == transparencyWanted then return end
    local calls = transparencyWanted / 0.25
    local tool
    if character:FindFirstChild("PropertiesTool") then
        tool = character["PropertiesTool"]
    else
        humanoid:EquipTool(player.Backpack.PropertiesTool)
        task.wait()
        tool = character.PropertiesTool
    end

    local args = { "Transparency", { block } }

    task.spawn(function()
        for i = 1, calls do
            tool.SetPropertieRF:InvokeServer(unpack(args))
        end
    end)
end

local function setAnchored(block : Model)
    if not block then return end
    local tool
    if character:FindFirstChild("PropertiesTool") then
        tool = character["PropertiesTool"]
    else
        humanoid:EquipTool(player.Backpack.PropertiesTool)
        task.wait()
        tool = character.PropertiesTool
    end

    local args = { "Anchored", { block } }
    task.spawn(function()
        tool.SetPropertieRF:InvokeServer(unpack(args))
    end)
end

local function rescaleBlock(block:Model, newPos:CFrame, newSize:Vector3) : ()
    if not block then 
        print("Block Not Found, Function rescaleBlock")
        return 
    end
    local tool
    if character:FindFirstChild("ScalingTool") then
        tool = character["ScalingTool"]
    else
        humanoid:EquipTool(player.Backpack.ScalingTool)
        task.wait()
        tool = character.ScalingTool
    end

    local args = { block, newSize, newPos }
    task.spawn(function()
        tool.RF:InvokeServer(unpack(args))
    end)
end

local function getPlayerZone(playerInstance : Player) : BasePart
    local teamColor = playerInstance.TeamColor
    for _,v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("TeamColor") and v.TeamColor.Value then
            if v.TeamColor.Value == teamColor then
                return v
            end
        end
    end
    print("Base Not Found for player: ".. playerInstance.Name)
    return nil
end

local function placeBlock(name : string, pos : CFrame, relativeTo : BasePart, Anchored : boolean) : ()
    local tool
    if character:FindFirstChild("BuildingTool") then
        tool = character["BuildingTool"]
    else
        humanoid:EquipTool(player.Backpack.BuildingTool)
        task.wait()
        tool = character.BuildingTool
    end
    if not relativeTo then relativeTo = getPlayerZone(player) end
    local args = {
        name,
        getBlockID(name),
        relativeTo,
        relativeTo and relativeTo.CFrame:ToObjectSpace(pos) or CFrame.new(),
        ignoreAnchored and true or Anchored,
        pos,
        false,
    }
    task.spawn(function()
        tool.RF:InvokeServer(unpack(args))
    end)
end

local function paintBlock(block : Model, color : Color3)
    if not block then 
        print("Block Not Found, function paintBlock")
        return 
    end
    if not block:FindFirstChild("PPart") then 
        print("Not PPart found for: ".. block.Name)
        return
    end
    if block.PPart.Color == color then return end
    local tool
    if character:FindFirstChild("PaintingTool") then
        tool = character["PaintingTool"]
    else
        humanoid:EquipTool(player.Backpack.PaintingTool)
        task.wait()
        tool = character.PaintingTool
    end
    local args = { { block, color } }
    task.spawn(function()
        tool.RF:InvokeServer(args)
    end)
end

local function getJoint(model : Model) : JointInstance?
    for _,v in pairs(model.PPart:GetChildren()) do
        if v:IsA("Snap") or v:IsA("Weld") then
            if v.Part1 then 
                if not (v.Part1.Parent == model) then
                    return v.Part1
                end
            end
        end
    end
    return getPlayerZone(player)
end

local function getNewBlockPos(hisBase : BasePart?, block : Model, myBase : BasePart?) : CFrame
    if not block or not block:FindFirstChild("PPart") then
        warn("Block missing PPart:", block and block.Name or "nil")
        return CFrame.new()
    end

    if not hisBase or not myBase then
        return block.PPart.CFrame
    end

    local offset = hisBase.CFrame:ToObjectSpace(block.PPart.CFrame)
    return myBase.CFrame * offset
end

local function copyBuild(blocks : Folder) : table
    local t = {}
    local myBase = getPlayerZone(player)
    local hisBase = getPlayerZone(players:FindFirstChild(blocks.Name))

    for _,block in ipairs(blocks:GetChildren()) do
        if block:FindFirstChild("PPart") then
            if not (getBlockID(block.Name) == 0 or (usedList[block.Name] or 0) > getBlockID(block.Name)) then 
                local relative = getJoint(block)
                relative = relative == hisBase and myBase or relative
                if usedList[block.Name] then
                    usedList[block.Name] += 1
                else
                    usedList[block.Name] = 1
                end
                table.insert(t, {
                    Name = block.Name,
                    Pos = getNewBlockPos(hisBase, block, myBase),
                    Relative = getPlayerZone(player),
                    Transparency = block.PPart.Transparency,
                    Anchored = block.PPart.Anchored,
                    Size = block.PPart.Size,
                    Color = block.PPart.Color
                })
            else
                print("You Dont Have Enough: ".. block.Name .. "s")
            end
        else
            print(block.Name.. " Didnt Have A PPart")
        end
    end
    return t
end

local function getMissingBlocks(expectedList, createdList)
    local missing = {}
    for i, v in ipairs(expectedList) do
        local found = false
        for _, b in ipairs(createdList) do
            if b and b:FindFirstChild("PPart") and (b.Name == v.Name) then
                found = true
                break
            end
        end
        if not found then
            table.insert(missing, {Index = i, Name = v.Name, Pos = v.Pos})
        end
    end
    return missing
end

local function getBlock(expected, createdList)
    local best = nil
    local bestDist = math.huge
    for _, b in ipairs(createdList) do
        if b and b:FindFirstChild("PPart") and b.Name == expected.Name then
            local dist = (b.PPart.Position - expected.Pos.Position).Magnitude
            if dist < bestDist then
                bestDist = dist
                best = b
            end
        end
    end
    return best
end

local function getPlayerBase() : Folder
    for _,child in pairs(blocksFolder:GetChildren()) do
        if child.Name == player.Name then
            return child
        end
    end
end

local function pasteBuild(t, folder)
    pastePercent = 0
    local childrenDebug = 0
    local c
    local blocks = {}
    local tCount = #t
    local lastPlaced = tick()
    c = folder.ChildAdded:Connect(function(child)
        childrenDebug += 1
        lastPlaced = tick()
    end) 
    print("Started Placing Blocks")
    for i,v in ipairs(t) do
        placeBlock(v.Name, v.Pos, v.Relative, v.Anchored)
        pastePercent += 50/tCount
        if i % 20 == 0 then
            task.wait(0.05)
        end
    end
    repeat
        task.wait(0.1)
    until tick() - lastPlaced > 5
    print("Children Count After Placing: "..childrenDebug .. " Expected: ".. tCount)
    if tCount - childrenDebug > 0 then
        local missing = getMissingBlocks(t, blocks)
        print("Missing " .. #missing .. " children which includes:")
        for _, b in ipairs(missing) do
            print("Index:", b.Index, "Name:", b.Name, "Position:", b.Pos.Position)
        end
    end
    print("Started Painting And Rescaling")
    local playerBaseList = folder:GetChildren()
    for i,v in ipairs(t) do
        local b = getBlock(v, playerBaseList)
        rescaleBlock(b, v.Pos, v.Size)
        paintBlock(b, v.Color)
        setTransparency(v.Transparency, b)
        if i % 20 == 0 then
            task.wait(0.05)
        end
        pastePercent += 50/tCount
    end
    c:Disconnect()
    pastePercent = 0
end

local function getPlayers()
    local playersy = {}
    for _,playery in pairs(game:GetService("Players"):GetChildren()) do
        table.insert(playersy, playery.DisplayName)
    end
    return playersy
end

local function getRealName(DisplayNamey : string) : string
    for _,v in pairs(players:GetChildren()) do
        if v.DisplayName == DisplayNamey then return v.Name end
    end
    print("Player Not Found")
    return nil
end

-- ==========================================
-- NEX MATERIAL LOGIC
-- ==========================================
local function showMaterialList(sourceData, targetName)
    if not sourceData then
        Rayfield:Notify({
            Title = "Lỗi",
            Content = "Người này không có thuyền hoặc chưa chọn!",
            Duration = 3,
            Image = "alert-triangle"
        })
        return
    end

    matTitle.Text = " VẬT LIỆU CỦA: " .. string.upper(targetName)

    local mats = {}
    for _, block in ipairs(sourceData:GetChildren()) do
        if block:FindFirstChild("PPart") then
            mats[block.Name] = (mats[block.Name] or 0) + 1
        end
    end

    for _, child in ipairs(matScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local blockData = player:WaitForChild("Data")
    local ySize = 0
    local hasItems = false

    for name, count in pairs(mats) do
        hasItems = true
        local owned = blockData:FindFirstChild(name) and blockData:FindFirstChild(name).Value or 0
        
        local itemFrame = Instance.new("Frame", matScroll)
        itemFrame.Size = UDim2.new(1, -10, 0, 40)
        itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 5)

        local icon = Instance.new("ImageLabel", itemFrame)
        icon.Size = UDim2.new(0, 30, 0, 30)
        icon.Position = UDim2.new(0, 5, 0, 5)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://7331592364" 

        local nameLabel = Instance.new("TextLabel", itemFrame)
        nameLabel.Size = UDim2.new(0.5, -35, 1, 0)
        nameLabel.Position = UDim2.new(0, 40, 0, 0)
        nameLabel.Text = name
        nameLabel.TextColor3 = Color3.new(1,1,1)
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 13
        nameLabel.BackgroundTransparency = 1

        local countLabel = Instance.new("TextLabel", itemFrame)
        countLabel.Size = UDim2.new(0.5, -10, 1, 0)
        countLabel.Position = UDim2.new(0.5, 0, 0, 0)
        countLabel.Text = count .. " / " .. owned
        countLabel.TextColor3 = (owned >= count) and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        countLabel.TextXAlignment = Enum.TextXAlignment.Right
        countLabel.Font = Enum.Font.GothamBold
        countLabel.TextSize = 13
        countLabel.BackgroundTransparency = 1

        ySize = ySize + 45
    end
    
    if not hasItems then
        Rayfield:Notify({
            Title = "Thông báo",
            Content = "Thuyền này không có vật liệu nào!",
            Duration = 3,
            Image = "alert-triangle"
        })
        return
    end

    matScroll.CanvasSize = UDim2.new(0, 0, 0, ySize)
    matGui.Enabled = true
end

-- ==========================================
-- FUN TAB UTILITIES
-- ==========================================
local function bringPlayer(playerToBring : Player , firstSeat : Seat, secondSeat : Seat) : ()
    local originalPos = character:GetPivot()
    local otherPlayerCharacter = playerToBring.Character
    if not otherPlayerCharacter then
        print("Other Player No Character Found")
        return
    end
    local offset = firstSeat.CFrame:Inverse() * secondSeat.CFrame
    repeat
        local torso = otherPlayerCharacter:FindFirstChild("LowerTorso") or otherPlayerCharacter:FindFirstChild("Torso")
        if torso then
            local newPivot = torso.CFrame * offset:Inverse()
            firstSeat:PivotTo(newPivot + Vector3.new(math.random(-1,1), math.random(-1,1), math.random(-1,1)))
        end
        task.wait(0.5)
    until not otherPlayerCharacter.Parent or otherPlayerCharacter.Humanoid.SeatPart

    firstSeat:PivotTo(originalPos)
end

local function getCar() : Model
    return humanoid.SeatPart and humanoid.SeatPart.Parent or nil
end

-- ==========================================
-- RAYFIELD UI INTERFACE
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Build A Boat For Treasure - NEX HUB Integrated",
   Icon = 0,
   LoadingTitle = "Rayfield Interface Suite",
   LoadingSubtitle = "by Sirius & NEX HUB",
   Theme = "Default",
   ToggleUIKeybind = "G",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "BABFT",
      FileName = "Build A Boat Config"
   },
})

-- TABS
local autoBuildTab = Window:CreateTab("Xây Dựng", "hammer")
local materialTab = Window:CreateTab("Quản Lý", "clipboard-list")
local autoFarmTab = Window:CreateTab("Auto Farm", "coins")
local funTab = Window:CreateTab("Fun Tab", "rewind")
local serverTab = Window:CreateTab("Server", "server")

-- ==========================================
-- TAB 1: XÂY DỰNG
-- ==========================================
autoBuildTab:CreateButton({
    Name = "Place Wood Block",
    Callback = function()
        placeBlock("WoodBlock", HRP.CFrame, nil, true)
    end,
})

autoBuildTab:CreateToggle({
    Name = "Rescale Block ( click block )",
    Callback = function(Value)
        rescaleClick = Value
        print("Set rescaleClick to: "..tostring(Value))
    end,
})

local dd = autoBuildTab:CreateDropdown({
    Name = "Choose Player Base To Copy",
    Options = getPlayers(),
    CurrentOption = {"None Selected"},
    MultipleOptions = false,
    Callback = function(Options)
        local realName = getRealName(Options[1])
        for _,folder in pairs(blocksFolder:GetChildren()) do
            if folder.Name == realName then
                selectedBase = folder
            end
        end
    end,
})

autoBuildTab:CreateButton({
    Name = "Copy Base",
    Callback = function()
        if selectedBase then
            clipboard = copyBuild(selectedBase)
            Rayfield:Notify({
                Title = "Thành công",
                Content = "Đã Copy thuyền vào bộ nhớ tạm!",
                Duration = 3,
                Image = "check-circle"
            })
        else
            Rayfield:Notify({
                Title = "Please Select A Valid Player",
                Content = "Either No Player Selected or Player Left",
                Duration = 10,
                Image = "alert-triangle"
            })
        end
    end,
})

autoBuildTab:CreateButton({
    Name = "Paste Base",
    Callback = function()
        if clipboard then
            pasteBuild(clipboard, getPlayerBase())
        else
            Rayfield:Notify({
                Title = "Lỗi",
                Content = "Bộ nhớ trống, hãy copy trước!",
                Duration = 3,
                Image = "alert-triangle"
            })
        end
    end,
})

local pasteStatus = autoBuildTab:CreateParagraph({
    Title = "Auto Build Progress", 
    Content = "0%"
})

task.spawn(function()
    while task.wait(0.2) do
        pasteStatus:Set({Title = "Auto Build Progress", Content = tostring(math.floor(pastePercent)) .. "%"})
    end
end)

autoBuildTab:CreateSection("auto build settings")
autoBuildTab:CreateToggle({
    Name = "Ignore Anchored State",
    CurrentValue = true,
    Callback = function(Value)
        ignoreAnchored = Value
    end,
})

-- ==========================================
-- TAB 2: QUẢN LÝ VẬT LIỆU
-- ==========================================
local dd3 = materialTab:CreateDropdown({
    Name = "Tên của người khác (Chọn để xem)",
    Options = getPlayers(),
    CurrentOption = {"None Selected"},
    MultipleOptions = false,
    Callback = function(Options)
        inspectTargetName = Options[1]
        local realName = getRealName(Options[1])
        for _, folder in pairs(blocksFolder:GetChildren()) do
            if folder.Name == realName then inspectBase = folder end
        end
    end,
})

materialTab:CreateButton({
    Name = "🔍 XEM CẦN BAO NHIÊU VẬT LIỆU",
    Callback = function()
        if inspectBase then
            showMaterialList(inspectBase, inspectTargetName)
        else
            Rayfield:Notify({
                Title = "Lỗi",
                Content = "Chưa chọn người chơi nào!",
                Duration = 3,
                Image = "alert-triangle"
            })
        end
    end,
})

-- ==========================================
-- TAB 3: AUTO FARM
-- ==========================================
autoFarmTab:CreateToggle({
    Name = "Auto Farm Toggle",
    CurrentValue = false,
    Callback = function(value)
        autofarm = value
    end,
})

-- ==========================================
-- TAB 4: FUN TAB & UTILITIES
-- ==========================================
funTab:CreateSection("Bring Player")

local dd2 = funTab:CreateDropdown({
    Name = "Choose Player To Lock Or Bring",
    Options = getPlayers(),
    CurrentOption = {"None Selected"},
    MultipleOptions = false,
    Callback = function(Options)
        local realName = getRealName(Options[1])
        playerToBring = players:FindFirstChild(realName)
    end,
})

funTab:CreateButton({
    Name = "Sit In The First Seat and Click",
    Callback = function()
        firstSeat = humanoid.SeatPart
        if firstSeat then
            print("firstSeat: "..firstSeat:GetFullName())
        end
    end,
})

funTab:CreateButton({
    Name = "Sit In The Second Seat and Click",
    Callback = function()
        secondSeat = humanoid.SeatPart
        if secondSeat then
            print("secondSeat: "..secondSeat:GetFullName())
        end
    end,
})

funTab:CreateButton({
    Name = "Bring Player after selecting",
    Callback = function()
        if secondSeat and firstSeat then
            if secondSeat ~= firstSeat then
                if playerToBring then
                    bringPlayer(playerToBring, firstSeat, secondSeat)
                else
                    Rayfield:Notify({
                        Title = "Please Select A Player and try again",
                        Content = "Select A Valid Player!",
                        Duration = 10,
                        Image = "alert-triangle"
                    })
                end
            else
                Rayfield:Notify({
                    Title = "Please Select Two DIFFERENT seats before trying again",
                    Content = "Select 2 Different Seats connected to the same base and try again",
                    Duration = 10,
                    Image = "alert-triangle"
                })
            end
        else
            Rayfield:Notify({
                Title = "Please Select Both Seats Before Trying",
                Content = "Select 2 Different Seats connected to the same base and try again",
                Duration = 10,
                Image = "alert-triangle"
            })
        end
    end,
})

funTab:CreateButton({
    Name = "Car Fly",
    Callback = function()
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local UserInputService = game:GetService("UserInputService")

        local player = Players.LocalPlayer
        local humanoid = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")

        local flying = false
        local flySpeed = 50
        local flyConnection
        local bv

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "CarFlyGUI"
        screenGui.Parent = player:WaitForChild("PlayerGui")
        screenGui.ResetOnSpawn = false

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 220, 0, 120)
        frame.Position = UDim2.new(0.05, 0, 0.4, 0)
        frame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
        frame.Parent = screenGui

        local toggleButton = Instance.new("TextButton")
        toggleButton.Size = UDim2.new(0, 100, 0, 30)
        toggleButton.Position = UDim2.new(0, 10, 0, 10)
        toggleButton.Text = "Toggle Fly"
        toggleButton.Parent = frame

        local speedLabel = Instance.new("TextLabel")
        speedLabel.Size = UDim2.new(0, 50, 0, 30)
        speedLabel.Position = UDim2.new(0, 120, 0, 10)
        speedLabel.Text = tostring(flySpeed)
        speedLabel.Parent = frame

        local plusButton = Instance.new("TextButton")
        plusButton.Size = UDim2.new(0, 30, 0, 30)
        plusButton.Position = UDim2.new(0, 180, 0, 10)
        plusButton.Text = "+"
        plusButton.Parent = frame

        local minusButton = Instance.new("TextButton")
        minusButton.Size = UDim2.new(0, 30, 0, 30)
        minusButton.Position = UDim2.new(0, 180, 0, 50)
        minusButton.Text = "-"
        minusButton.Parent = frame

        local destroyButton = Instance.new("TextButton")
        destroyButton.Size = UDim2.new(0, 100, 0, 30)
        destroyButton.Position = UDim2.new(0, 10, 0, 80)
        destroyButton.Text = "Destroy GUI"
        destroyButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        destroyButton.Parent = frame

        local ctrl = {f=0, b=0, l=0, r=0}
        UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == Enum.KeyCode.W then ctrl.f = 1 end
            if input.KeyCode == Enum.KeyCode.S then ctrl.b = -1 end
            if input.KeyCode == Enum.KeyCode.A then ctrl.l = -1 end
            if input.KeyCode == Enum.KeyCode.D then ctrl.r = 1 end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W then ctrl.f = 0 end
            if input.KeyCode == Enum.KeyCode.S then ctrl.b = 0 end
            if input.KeyCode == Enum.KeyCode.A then ctrl.l = 0 end
            if input.KeyCode == Enum.KeyCode.D then ctrl.r = 0 end
        end)

        toggleButton.MouseButton1Click:Connect(function()
            flying = not flying
            local car = getCar()
            if car then
                local primaryPart = car.PrimaryPart or car:FindFirstChildWhichIsA("BasePart")
                if primaryPart then
                    if flying then
                        if not bv or not bv.Parent then
                            bv = Instance.new("BodyVelocity")
                            bv.Name = "FlyBV"
                            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                            bv.Parent = primaryPart
                        end
                        if not flyConnection then
                            flyConnection = RunService.RenderStepped:Connect(function()
                                if not flying then return end
                                local cam = workspace.CurrentCamera
                                local moveDir = (cam.CFrame.LookVector * (ctrl.f + ctrl.b)) +
                                                ((cam.CFrame * CFrame.new(ctrl.l + ctrl.r, 0, 0)).p - cam.CFrame.p)

                                if moveDir.Magnitude > 0 then
                                    bv.Velocity = moveDir.Unit * flySpeed
                                else
                                    bv.Velocity = Vector3.zero
                                end
                                primaryPart.CFrame = CFrame.new(primaryPart.Position, primaryPart.Position + cam.CFrame.LookVector)
                            end)
                        end
                    else
                        if bv then bv:Destroy() bv = nil end
                        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
                    end
                end
            end
        end)

        plusButton.MouseButton1Click:Connect(function()
            flySpeed = flySpeed + 10
            speedLabel.Text = tostring(flySpeed)
        end)

        minusButton.MouseButton1Click:Connect(function()
            flySpeed = math.max(10, flySpeed - 10)
            speedLabel.Text = tostring(flySpeed)
        end)

        destroyButton.MouseButton1Click:Connect(function()
            flying = false
            if bv then bv:Destroy() bv = nil end
            if flyConnection then flyConnection:Disconnect() flyConnection = nil end
            screenGui:Destroy()
        end)
    end,
})


-- ==========================================
-- TAB 5: SERVER HOP LOGIC & AUTO EXECUTE
-- ==========================================
serverTab:CreateSection("Quản Lý Server")

-- Hàm hỗ trợ tự động chạy lại Script khi sang server mới qua executor
local queue_on_teleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport) or function() end

-- CẤU HÌNH LINK SCRIPT CỦA BẠN TẠI ĐÂY
-- (Hãy thay "script.lua" thành tên file thực tế chứa đoạn script này)
local scriptUrl = "https://raw.githubusercontent.com/duongtandatkgi-ops/Toolall/main/script.lua"
local autoExecuteCode = 'loadstring(game:HttpGet("' .. scriptUrl .. '"))()'

serverTab:CreateButton({
    Name = "Sao Chép ID Server Hiện Tại",
    Callback = function()
        pcall(function()
            setclipboard(tostring(game.JobId))
            Rayfield:Notify({
                Title = "Thành công",
                Content = "Đã sao chép ID Server!",
                Duration = 3,
                Image = "check-circle"
            })
        end)
    end,
})

local targetServerId = ""
serverTab:CreateInput({
    Name = "Nhập ID Server",
    PlaceholderText = "Dán JobId vào đây để Join...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        targetServerId = Text
    end,
})

serverTab:CreateButton({
    Name = "Hop Server Theo ID Đã Nhập",
    Callback = function()
        if targetServerId and targetServerId ~= "" then
            Rayfield:Notify({
                Title = "Đang chuyển Server",
                Content = "Vui lòng chờ giây lát...",
                Duration = 3,
                Image = "info"
            })
            pcall(function()
                queue_on_teleport(autoExecuteCode) -- Bật lại script qua lệnh queue_on_teleport
                TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServerId, game.Players.LocalPlayer)
            end)
        else
            Rayfield:Notify({
                Title = "Lỗi",
                Content = "Vui lòng nhập ID Server hợp lệ trước!",
                Duration = 3,
                Image = "alert-triangle"
            })
        end
    end,
})

serverTab:CreateButton({
    Name = "Hop Server Ngẫu Nhiên (Random)",
    Callback = function()
        Rayfield:Notify({
            Title = "Đang tìm Server...",
            Content = "Hệ thống đang quét các Server trống...",
            Duration = 2,
            Image = "info"
        })
        pcall(function()
            local req = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
            local decoded = HttpService:JSONDecode(req)
            local servers = {}
            for _, v in ipairs(decoded.data) do
                if v.playing and v.maxPlayers and v.playing < v.maxPlayers and v.id ~= game.JobId then
                    table.insert(servers, v.id)
                end
            end
            
            if #servers > 0 then
                local randomServer = servers[math.random(1, #servers)]
                queue_on_teleport(autoExecuteCode) -- Bật lại script qua lệnh queue_on_teleport
                TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, game.Players.LocalPlayer)
            else
                Rayfield:Notify({
                    Title = "Thất bại",
                    Content = "Không tìm thấy Server nào phù hợp!",
                    Duration = 3,
                    Image = "alert-triangle"
                })
            end
        end)
    end,
})

-- ==========================================
-- PLAYERS REFRESH FUNCTION
-- ==========================================
local function refreshAllDropdowns()
    local plrs = getPlayers()
    dd:Refresh(plrs)
    dd2:Refresh(plrs)
    dd3:Refresh(plrs)
end

players.PlayerAdded:Connect(refreshAllDropdowns)
players.PlayerRemoving:Connect(refreshAllDropdowns)

-- ==========================================
-- MOUSE EVENT FOR CLICK SCALING
-- ==========================================
local mouse = player:GetMouse()
mouse.Button1Down:Connect(function()
    if rescaleClick then
        if mouse.Target then
            print(mouse.Target:GetFullName())
            local ppart = mouse.Target
            rescaleBlock(ppart.Parent, ppart.CFrame, Vector3.new(4, 4, 4))
        end
    end
end)

-- ==========================================
-- BACKGROUND COROUTINES (AFK, AUTO FARM, HEARTBEAT)
-- ==========================================
task.spawn(function()
    while true do
        task.wait()
        if autofarm then
            if not HRP then continue end
            if index == 11 then
                local Stages = workspace:FindFirstChild("BoatStages")
                if not Stages then continue end
                local normalStages = Stages:FindFirstChild("NormalStages")
                if not normalStages then continue end
                local endpoint = normalStages:FindFirstChild("TheEnd")
                if not endpoint then continue end
                local chest = endpoint:FindFirstChild("GoldenChest")
                if not chest then continue end
                HRP:PivotTo(chest:GetPivot() + Vector3.new(0, 0, -10))
                local ii = 0
                repeat 
                    task.wait(1) 
                    ii += 1
                    if ii % 20 == 0 then
                        HRP:PivotTo(chest:GetPivot() + Vector3.new(0, 0, -10))
                    end
                    if not HRP then continue end
                until (HRP.Position - chest:GetPivot().Position).Magnitude > 500
                index = 1
            else
                local stages = workspace:FindFirstChild("BoatStages")
                if not stages then continue end
                local normalStages = stages:FindFirstChild("NormalStages")
                if not normalStages then continue end
                local roomName = "CaveStage"..index
                local stage = normalStages:FindFirstChild(roomName)
                if not stage then continue end
                local darkPart = stage:FindFirstChild("DarknessPart")
                if not darkPart then continue end
                character:PivotTo(darkPart.CFrame - Vector3.new(0, 0, 15))
                local tween2 = TS:Create(HRP, TweenInfo.new(2, Enum.EasingStyle.Linear), {CFrame = darkPart.CFrame + Vector3.new(0, 0, 20)})
                tweening = true
                tween2:Play()
                tween2.Completed:Wait()
                tweening = false
                index += 1
            end
        end
    end
end)

runService.Heartbeat:Connect(function()
    if tweening and HRP then
        HRP.Velocity = Vector3.zero
    end
end)

player.CharacterAdded:Connect(function(charactery)
    character = charactery
    HRP = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
end)

task.spawn(function()
    while task.wait(100) do
        vim:SendKeyEvent(true, Enum.KeyCode.Tilde, false, nil)
        task.wait(0.1)
        vim:SendKeyEvent(false, Enum.KeyCode.Tilde, false, nil)
    end
end)

Rayfield:LoadConfiguration()
