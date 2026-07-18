-- ==========================================
-- BỘ GIAO DIỆN TÍCH HỢP NEX HUB & RAYFIELD
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

-- Cờ và Biến hiệu ứng chuyển động
local motionEnabled = false
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

-- Biến giao diện người dùng tùy chỉnh (NEX Hub)
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
closeBtn.MouseButton1Click:Connect(function()
    matGui.Enabled = false
end)

local matScroll = Instance.new("ScrollingFrame", matFrame)
matScroll.Size = UDim2.new(1, -20, 1, -50)
matScroll.Position = UDim2.new(0, 10, 0, 40)
matScroll.BackgroundTransparency = 1
matScroll.ScrollBarThickness = 4
matScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local uiList = Instance.new("UIListLayout", matScroll)
uiList.Padding = UDim.new(0, 5)
uiList.SortOrder = Enum.SortOrder.Name

-- Kéo thả vật liệu cửa sổ
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
-- TẠO NÚT THU NHỎ / MỞ RỘNG (NÚT NỔI TIẾP THEO)
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
toggleBtn.Text = "TIẾP THEO"
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
-- CÁC CHỨC NĂNG CỐT LÕI
-- ==========================================
local blockData = player:WaitForChild("Data")
local blocksFolder = workspace:WaitForChild("Blocks")

-- Hệ thống ép độ chính xác
local PRECISION = 10000
local function snapVector3(vec)
    return Vector3.new(
        math.round(vec.X * PRECISION) / PRECISION,
        math.round(vec.Y * PRECISION) / PRECISION,
        math.round(vec.Z * PRECISION) / PRECISION
    )
end

local function snapCFrame(cf)
    local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
    return CFrame.new(
        math.round(x * PRECISION) / PRECISION, math.round(y * PRECISION) / PRECISION, math.round(z * PRECISION) / PRECISION,
        math.round(r00 * PRECISION) / PRECISION, math.round(r01 * PRECISION) / PRECISION, math.round(r02 * PRECISION) / PRECISION,
        math.round(r10 * PRECISION) / PRECISION, math.round(r11 * PRECISION) / PRECISION, math.round(r12 * PRECISION) / PRECISION,
        math.round(r20 * PRECISION) / PRECISION, math.round(r21 * PRECISION) / PRECISION, math.round(r22 * PRECISION) / PRECISION
    )
end

local function getBlockID(name)
    return blockData:FindFirstChild(name) and blockData:FindFirstChild(name).Value or 9
end

local function setTransparency(transparencyWanted, block)
    if not block or not block:FindFirstChild("PPart") then return end
    if math.abs(block.PPart.Transparency - transparencyWanted) < 0.05 then return end

    local calls = transparencyWanted / 0.25
    local tool
    if character:FindFirstChild("PropertiesTool") then
        tool = character["PropertiesTool"]
    else
        humanoid:EquipTool(player.Backpack:FindFirstChild("PropertiesTool"))
        task.wait(0.1)
        tool = character:FindFirstChild("PropertiesTool")
    end
    if not tool then return end

    local args = { "Transparency", { block } }
    task.spawn(function()
        for i = 1, calls do
            tool.SetPropertieRF:InvokeServer(unpack(args))
        end
    end)
end

local function setAnchored(block)
    if not block then return end
    local tool
    if character:FindFirstChild("PropertiesTool") then
        tool = character["PropertiesTool"]
    else
        humanoid:EquipTool(player.Backpack:FindFirstChild("PropertiesTool"))
        task.wait(0.1)
        tool = character:FindFirstChild("PropertiesTool")
    end
    if not tool then return end

    local args = { "Anchored", { block } }
    task.spawn(function()
        tool.SetPropertieRF:InvokeServer(unpack(args))
    end)
end

local function rescaleBlock(block, newPos, newSize)
    if not block then return end
    if block:FindFirstChild("PPart") then
        local sizeDiff = (block.PPart.Size - newSize).Magnitude
        local posDiff = (block.PPart.Position - newPos.Position).Magnitude
        if sizeDiff < 0.05 and posDiff < 0.05 then
            return 
        end
    end

    local tool
    if character:FindFirstChild("ScalingTool") then
        tool = character["ScalingTool"]
    else
        humanoid:EquipTool(player.Backpack:FindFirstChild("ScalingTool"))
        task.wait(0.1)
        tool = character:FindFirstChild("ScalingTool")
    end
    if not tool then return end

    local args = { block, snapVector3(newSize), snapCFrame(newPos) }
    task.spawn(function()
        tool.RF:InvokeServer(unpack(args))
    end)
end

local function getPlayerZone(playerInstance)
    local teamColor = playerInstance.TeamColor
    for _,v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("TeamColor") and v.TeamColor.Value then
            if v.TeamColor.Value == teamColor then
                return v
            end
        end
    end
    return nil
end

local function placeBlock(name, pos, relativeTo, Anchored)
    local tool
    if character:FindFirstChild("BuildingTool") then
        tool = character["BuildingTool"]
    else
        humanoid:EquipTool(player.Backpack:FindFirstChild("BuildingTool"))
        task.wait(0.1)
        tool = character:FindFirstChild("BuildingTool")
    end

    if not relativeTo then relativeTo = getPlayerZone(player) end
    if not tool then return end

    local rawOffset = relativeTo and relativeTo.CFrame:ToObjectSpace(pos) or CFrame.new()
    local capturedOffset = snapCFrame(rawOffset)
    local capturedPos = snapCFrame(pos)

    local args = {
        name,
        getBlockID(name),
        relativeTo,
        capturedOffset,
        ignoreAnchored and true or Anchored,
        capturedPos,
        false,
    }

    task.spawn(function()
        tool.RF:InvokeServer(unpack(args))
    end)
end

local function paintBlock(block, color)
    if not block or not block:FindFirstChild("PPart") then return end
    if block.PPart.Color == color then return end

    local tool
    if character:FindFirstChild("PaintingTool") then
        tool = character["PaintingTool"]
    else
        humanoid:EquipTool(player.Backpack:FindFirstChild("PaintingTool"))
        task.wait(0.1)
        tool = character:FindFirstChild("PaintingTool")
    end
    if not tool then return end

    local args = { { block, color } }
    task.spawn(function()
        tool.RF:InvokeServer(args)
    end)
end

local function getJoint(model)
    for _,v in pairs(model.PPart:GetChildren()) do
        if v:IsA("Snap") or v:IsA("Weld") then
            if v.Part1 then
                if (v.Part1.Parent == model) then
                    return v.Part0
                end
            end
        end
    end
    return getPlayerZone(player)
end

local function getNewBlockPos(hisBase, block, myBase)
    if not block or not block:FindFirstChild("PPart") then return CFrame.new() end
    if not hisBase or not myBase then return snapCFrame(block.PPart.CFrame) end

    local offset = hisBase.CFrame:ToObjectSpace(block.PPart.CFrame)
    offset = snapCFrame(offset)
    return snapCFrame(myBase.CFrame * offset)
end

local function copyBuild(blocks)
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
                    Size = snapVector3(block.PPart.Size),
                    Color = block.PPart.Color
                })
            else
                print("Bạn không có đủ: " .. block.Name)
            end
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

local function getBlock(expected, createdList, usedBlocks)
    usedBlocks = usedBlocks or {}
    local best = nil
    local bestDist = math.huge

    for _, b in ipairs(createdList) do
        if b and b:FindFirstChild("PPart") and b.Name == expected.Name and not usedBlocks[b] then
            local dist = (b.PPart.Position - expected.Pos.Position).Magnitude
            if dist < bestDist then
                bestDist = dist
                best = b
            end
        end
    end

    if best then
        usedBlocks[best] = true
    end
    return best
end

local function getPlayerBase()
    for _,child in pairs(blocksFolder:GetChildren()) do
        if child.Name == player.Name then
            return child
        end
    end
end

-- ==========================================
-- CHỨC NĂNG PASTE BUILD + CẢNH BÁO THIẾU VẬT LIỆU
-- ==========================================
local function pasteBuild(t, folder)
    pastePercent = 0
    local childrenDebug = 0
    local c
    local tCount = #t
    local lastPlaced = tick()

    c = folder.ChildAdded:Connect(function(child)
        childrenDebug += 1
        lastPlaced = tick()
    end)

    print("Bắt đầu đặt các khối")
    for i,v in ipairs(t) do
        placeBlock(v.Name, v.Pos, v.Relative, v.Anchored)
        pastePercent += 50/tCount
        if i % 20 == 0 then
            task.wait(0.05)
        end
    end

    repeat task.wait(0.1) until tick() - lastPlaced > 5

    if tCount - childrenDebug > 0 then
        local missing = getMissingBlocks(t, folder:GetChildren())
        print("Thiếu " .. #missing .. " khối bao gồm:")
        
        -- [TÍNH NĂNG MỚI]: Đếm và hiện thông báo thiếu vật liệu cụ thể
        local missingCounts = {}
        for _, b in ipairs(missing) do
            missingCounts[b.Name] = (missingCounts[b.Name] or 0) + 1
        end
        
        local missingText = ""
        for name, count in pairs(missingCounts) do
            missingText = missingText .. name .. ": " .. count .. "\n"
        end
        
        Rayfield:Notify({
            Title = "⚠️ THIẾU VẬT LIỆU!",
            Content = "Bạn không đủ block để xây hoàn chỉnh:\n" .. missingText,
            Duration = 10,
            Image = "triangle-alert"
        })
    end

    print("Bắt đầu vẽ và thay đổi kích thước")
    local playerBaseList = folder:GetChildren()
    local usedBlocksTracker = {}

    for i,v in ipairs(t) do
        local b = getBlock(v, playerBaseList, usedBlocksTracker)
        if b then
            rescaleBlock(b, v.Pos, v.Size)
            paintBlock(b, v.Color)
            setTransparency(v.Transparency, b)
        end
        if i % 10 == 0 then
            task.wait(0.05)
        end
        pastePercent += 50/tCount
    end

    c:Disconnect()
    pastePercent = 0
end

local function getPlayers()
    local playersList = {}
    for _,playery in pairs(game:GetService("Players"):GetChildren()) do
        table.insert(playersList, playery.DisplayName)
    end
    return playersList
end

local function getRealName(DisplayNamey)
    for _,v in pairs(players:GetChildren()) do
        if v.DisplayName == DisplayNamey then
            return v.Name
        end
    end
    return nil
end

local function showMaterialList(sourceData, targetName)
    if not sourceData then
        Rayfield:Notify({
            Title = "Lỗi",
            Content = "Người này không có thuyền hoặc chưa được chọn!",
            Duration = 3,
            Image = "triangle-alert"
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
            Image = "triangle-alert"
        })
        return
    end

    matScroll.CanvasSize = UDim2.new(0, 0, 0, ySize)
    matGui.Enabled = true
end

local function bringPlayer(playerToBring, firstSeat, secondSeat)
    local originalPos = character:GetPivot()
    local otherPlayerCharacter = playerToBring.Character

    if not otherPlayerCharacter then
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

local function getCar()
    return humanoid.SeatPart and humanoid.SeatPart.Parent or nil
end

-- ==========================================
-- GIAO DIỆN NGƯỜI DÙNG RAYFIELD
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Đóng thuyền đi tìm kho báu - Tích hợp NEX HUB",
    Icon = 0,
    LoadingTitle = "Bộ giao diện Rayfield",
    LoadingSubtitle = "by Sirius & NEX HUB",
    Theme = "Default",
    ToggleUIKeybind = "G",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BABFT",
        FileName = "BuildBoatConfig"
    },
})

-- TAB
local autoBuildTab = Window:CreateTab("Xây Build", "hammer")
local materialTab = Window:CreateTab("Quản Lý", "clipboard-list")
local autoFarmTab = Window:CreateTab("Auto Farm", "coins")
local funTab = Window:CreateTab("Fun Tab", "rewind")
local serverTab = Window:CreateTab("Server", "server")

-- ==========================================
-- TAB 1: XÂY DỰNG
-- ==========================================
autoBuildTab:CreateButton({
    Name = "Đặt khối gỗ",
    Callback = function()
        placeBlock("WoodBlock", HRP.CFrame, nil, true)
    end,
})

autoBuildTab:CreateToggle({
    Name = "Thay đổi kích thước khối (nhấp chuột vào khối)",
    Callback = function(Value)
        rescaleClick = Value
    end,
})

local dd = autoBuildTab:CreateDropdown({
    Name = "Chọn cơ sở người chơi để sao chép",
    Options = getPlayers(),
    CurrentOption = {"Chưa được chọn"},
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
    Name = "Sao Chép Base",
    Callback = function()
        if selectedBase then
            clipboard = copyBuild(selectedBase)
            Rayfield:Notify({
                Title = "Thành công",
                Content = "Đã sao chép vào bộ nhớ tạm thời!",
                Duration = 3,
                Image = "check"
            })
        else
            Rayfield:Notify({
                Title = "Lỗi",
                Content = "Không có người chơi nào được chọn",
                Duration = 10,
                Image = "triangle-alert"
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
                Content = "Bộ nhớ trống, hãy sao chép trước!",
                Duration = 3,
                Image = "triangle-alert"
            })
        end
    end,
})

local pasteStatus = autoBuildTab:CreateParagraph({
    Title = "Tiến độ xây dựng tự động",
    Content = "0%"
})

task.spawn(function()
    while task.wait(0.2) do
        pasteStatus:Set({Title = "Tiến độ xây dựng", Content = tostring(math.floor(pastePercent)) .. "%"})
    end
end)

autoBuildTab:CreateSection("Cài đặt tự động xây dựng")
autoBuildTab:CreateToggle({
    Name = "Bỏ qua trạng thái neo",
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
    CurrentOption = {"Chưa được chọn"},
    MultipleOptions = false,
    Callback = function(Options)
        inspectTargetName = Options[1]
        local realName = getRealName(Options[1])
        for _, folder in pairs(blocksFolder:GetChildren()) do
            if folder.Name == realName then
                inspectBase = folder
            end
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
                Content = "Không chọn người chơi nào!",
                Duration = 3,
                Image = "triangle-alert"
            })
        end
    end,
})

-- ==========================================
-- TAB 3: NÔNG TRẠI TỰ ĐỘNG
-- ==========================================
autoFarmTab:CreateToggle({
    Name = "Bật/Tắt Tự động Trang trại",
    CurrentValue = false,
    Callback = function(value)
        autofarm = value
    end,
})

-- ==========================================
-- TAB 4: TAB GIẢI TRÍ & TIỆN ÍCH
-- ==========================================
funTab:CreateSection("Bring Player")
local dd2 = funTab:CreateDropdown({
    Name = "Chọn người chơi để khóa hoặc mang theo",
    Options = getPlayers(),
    CurrentOption = {"Chưa được chọn"},
    MultipleOptions = false,
    Callback = function(Options)
        local realName = getRealName(Options[1])
        playerToBring = players:FindFirstChild(realName)
    end,
})

funTab:CreateButton({
    Name = "Ngồi vào ghế đầu và bấm nút",
    Callback = function()
        firstSeat = humanoid.SeatPart
    end,
})

funTab:CreateButton({
    Name = "Ngồi vào ghế thứ hai và bấm nút",
    Callback = function()
        secondSeat = humanoid.SeatPart
    end,
})

funTab:CreateButton({
    Name = "Đưa người chơi vào sau khi chọn",
    Callback = function()
        if secondSeat and firstSeat then
            if secondSeat ~= firstSeat then
                if playerToBring then
                    bringPlayer(playerToBring, firstSeat, secondSeat)
                else
                    Rayfield:Notify({Title = "Lỗi", Content = "Chọn một người chơi hợp lệ!", Duration = 10})
                end
            else
                Rayfield:Notify({Title = "Lỗi", Content = "Chọn 2 ghế khác nhau!", Duration = 10})
            end
        else
            Rayfield:Notify({Title = "Lỗi", Content = "Chọn 2 ghế trước khi thử", Duration = 10})
        end
    end,
})

funTab:CreateButton({
    Name = "Car Fly",
    Callback = function()
        local flySpeed = 50
        local flying = false
        local bv
        local flyConnection
        
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
        toggleButton.Text = "Bật/Tắt Fly"
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
        destroyButton.Text = "Xóa giao diện"
        destroyButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        destroyButton.Parent = frame
        
        local ctrl = {f=0, b=0, l=0, r=0}
        
        UIS.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == Enum.KeyCode.W then ctrl.f = 1 end
            if input.KeyCode == Enum.KeyCode.S then ctrl.b = -1 end
            if input.KeyCode == Enum.KeyCode.A then ctrl.l = -1 end
            if input.KeyCode == Enum.KeyCode.D then ctrl.r = 1 end
        end)
        
        UIS.InputEnded:Connect(function(input)
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
                            flyConnection = runService.RenderStepped:Connect(function()
                                if not flying then return end
                                local cam = workspace.CurrentCamera
                                local moveDir = (cam.CFrame.LookVector * (ctrl.f + ctrl.b)) + ((cam.CFrame * CFrame.new(ctrl.l + ctrl.r, 0, 0)).p - cam.CFrame.p)
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

-- [TÍNH NĂNG MỚI]: Nút Dịch chuyển đến người có nhiều block nhất
funTab:CreateSection("Dịch Chuyển & Tìm Kiếm")
funTab:CreateButton({
    Name = "Dịch Chuyển Đến Người Có Thuyền Lớn Nhất",
    Callback = function()
        local maxBlocks = 0
        local targetPlayerName = nil
        
        for _, folder in pairs(blocksFolder:GetChildren()) do
            local count = 0
            for _, block in pairs(folder:GetChildren()) do
                if block:FindFirstChild("PPart") then
                    count = count + 1
                end
            end
            
            if count > maxBlocks then
                maxBlocks = count
                targetPlayerName = folder.Name
            end
        end
        
        if targetPlayerName and maxBlocks > 0 then
            local targetPlayer = players:FindFirstChild(targetPlayerName)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                HRP.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                Rayfield:Notify({
                    Title = "Thành Công",
                    Content = "Đã dịch chuyển tới " .. targetPlayerName .. " (" .. maxBlocks .. " blocks)",
                    Duration = 5,
                    Image = "check"
                })
            else
                Rayfield:Notify({
                    Title = "Lỗi",
                    Content = "Người chơi " .. targetPlayerName .. " không có nhân vật hợp lệ trên map!",
                    Duration = 3,
                    Image = "triangle-alert"
                })
            end
        else
            Rayfield:Notify({
                Title = "Thông báo",
                Content = "Hiện tại chưa có ai đặt block nào trên bản đồ!",
                Duration = 3,
                Image = "info"
            })
        end
    end,
})

-- ==========================================
-- TAB 5: SERVER LOGIC
-- ==========================================
local queue_on_teleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport) or function() end
local scriptUrl = "https://raw.githubusercontent.com/duongtandatkgi-ops/Scripfree/refs/heads/main/Buil.lua"
local autoExecuteCode = 'loadstring(game:HttpGet("' .. scriptUrl .. '"))()'

serverTab:CreateButton({
    Name = "Sao Chép ID Server Hiện Tại",
    Callback = function()
        pcall(function()
            setclipboard(tostring(game.JobId))
            Rayfield:Notify({Title = "Thành công", Content = "ID Máy chủ đã được sao chép!", Duration = 3})
        end)
    end,
})

local targetServerId = ""
serverTab:CreateInput({
    Name = "Máy chủ ID mới",
    PlaceholderText = "Dán JobId vào đây...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        targetServerId = Text
    end,
})

serverTab:CreateButton({
    Name = "Hop Server Theo ID",
    Callback = function()
        if targetServerId and targetServerId ~= "" then
            Rayfield:Notify({Title = "Đang chuyển", Content = "Vui lòng đợi...", Duration = 3})
            pcall(function()
                queue_on_teleport(autoExecuteCode)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServerId, player)
            end)
        end
    end,
})

serverTab:CreateButton({
    Name = "Hop Server Ngẫu Nhiên",
    Callback = function()
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
                queue_on_teleport(autoExecuteCode)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, player)
            end
        end)
    end,
})

-- ==========================================
-- SỰ KIỆN CHUỘT VÀ CẬP NHẬT
-- ==========================================
local function refreshAllDropdowns()
    local plrs = getPlayers()
    dd:Refresh(plrs)
    dd2:Refresh(plrs)
    dd3:Refresh(plrs)
end
players.PlayerAdded:Connect(refreshAllDropdowns)
players.PlayerRemoving:Connect(refreshAllDropdowns)

local mouse = player:GetMouse()
mouse.Button1Down:Connect(function()
    if rescaleClick then
        if mouse.Target then
            local ppart = mouse.Target
            rescaleBlock(ppart.Parent, ppart.CFrame, Vector3.new(4, 4, 4))
        end
    end
end)

-- Background processes
task.spawn(function()
    while true do
        task.wait()
        if autofarm then
            if not HRP then continue end
            if index == 11 then
                local stages = workspace:FindFirstChild("BoatStages")
                if not stages then continue end
                local normalStages = stages:FindFirstChild("NormalStages")
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
                motionEnabled = true
                tween2:Play()
                tween2.Completed:Wait()
                motionEnabled = false
                index += 1
            end
        end
    end
end)

runService.Heartbeat:Connect(function()
    if motionEnabled and HRP then
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
