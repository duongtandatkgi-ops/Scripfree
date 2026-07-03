-- =========================================================
-- SCRIPT: TELEPORT & DASH CONTROLLER V2
-- TÍNH NĂNG: LƯU VỊ TRÍ, TỐC BIẾN, LƯỚT TỚI TRƯỚC (CÓ MINI MODE)
-- =========================================================

local player = game:GetService("Players").LocalPlayer
local savedCFrame = nil 

-- 1. TẠO GUI CHÍNH
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportControllerGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui or player:WaitForChild("PlayerGui")

-- Khung chính
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 240)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", MainFrame)
stroke.Color = Color3.fromRGB(60, 120, 255)
stroke.Thickness = 2

-- Thanh tiêu đề
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local bottomFix = Instance.new("Frame")
bottomFix.Size = UDim2.new(1, 0, 0, 5)
bottomFix.Position = UDim2.new(0, 0, 1, -5)
bottomFix.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
bottomFix.BorderSizePixel = 0
bottomFix.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "TELEPORT HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Nút Chuyển Đổi (Thu nhỏ / Mở rộng)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 30, 0, 30)
ToggleBtn.Position = UDim2.new(1, -30, 0, 0)
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Text = "-"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 20
ToggleBtn.Parent = TopBar

-- ==========================================
-- KHUNG 1: CHẾ ĐỘ MỞ RỘNG (ĐẦY ĐỦ)
-- ==========================================
local ExpandedFrame = Instance.new("Frame")
ExpandedFrame.Size = UDim2.new(1, 0, 1, -30)
ExpandedFrame.Position = UDim2.new(0, 0, 0, 30)
ExpandedFrame.BackgroundTransparency = 1
ExpandedFrame.Parent = MainFrame

local SaveBtn = Instance.new("TextButton", ExpandedFrame)
SaveBtn.Size = UDim2.new(0.9, 0, 0, 35)
SaveBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
SaveBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.Text = "LƯU VỊ TRÍ"
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.TextSize = 13
Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 6)

local LoadBtn = Instance.new("TextButton", ExpandedFrame)
LoadBtn.Size = UDim2.new(0.9, 0, 0, 35)
LoadBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
LoadBtn.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadBtn.Text = "TỐC BIẾN VỀ CHỖ LƯU"
LoadBtn.Font = Enum.Font.GothamBold
LoadBtn.TextSize = 13
Instance.new("UICorner", LoadBtn).CornerRadius = UDim.new(0, 6)

local DashLabel = Instance.new("TextLabel", ExpandedFrame)
DashLabel.Size = UDim2.new(0.9, 0, 0, 20)
DashLabel.Position = UDim2.new(0.05, 0, 0.48, 0)
DashLabel.BackgroundTransparency = 1
DashLabel.Text = "Khoảng cách dịch chuyển (Studs):"
DashLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
DashLabel.Font = Enum.Font.Gotham
DashLabel.TextSize = 12

local DistanceBox = Instance.new("TextBox", ExpandedFrame)
DistanceBox.Size = UDim2.new(0.9, 0, 0, 35)
DistanceBox.Position = UDim2.new(0.05, 0, 0.6, 0)
DistanceBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
DistanceBox.TextColor3 = Color3.fromRGB(255, 255, 255)
DistanceBox.PlaceholderText = "Nhập số (VD: 50)..."
DistanceBox.Text = "50" 
DistanceBox.Font = Enum.Font.Gotham
DistanceBox.TextSize = 14
DistanceBox.ClearTextOnFocus = false
Instance.new("UICorner", DistanceBox).CornerRadius = UDim.new(0, 6)

local DashBtn = Instance.new("TextButton", ExpandedFrame)
DashBtn.Size = UDim2.new(0.9, 0, 0, 35)
DashBtn.Position = UDim2.new(0.05, 0, 0.8, 0)
DashBtn.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
DashBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DashBtn.Text = "TỐC BIẾN TỚI TRƯỚC"
DashBtn.Font = Enum.Font.GothamBold
DashBtn.TextSize = 13
Instance.new("UICorner", DashBtn).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- KHUNG 2: CHẾ ĐỘ THU NHỎ (MINI MODE)
-- ==========================================
local MinimizedFrame = Instance.new("Frame")
MinimizedFrame.Size = UDim2.new(1, 0, 0, 45)
MinimizedFrame.Position = UDim2.new(0, 0, 0, 30)
MinimizedFrame.BackgroundTransparency = 1
MinimizedFrame.Visible = false -- Ẩn lúc ban đầu
MinimizedFrame.Parent = MainFrame

local MiniLoadBtn = Instance.new("TextButton", MinimizedFrame)
MiniLoadBtn.Size = UDim2.new(0.45, 0, 0, 35)
MiniLoadBtn.Position = UDim2.new(0.03, 0, 0.1, 0)
MiniLoadBtn.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
MiniLoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniLoadBtn.Text = "VỀ CHỖ LƯU"
MiniLoadBtn.Font = Enum.Font.GothamBold
MiniLoadBtn.TextSize = 11
Instance.new("UICorner", MiniLoadBtn).CornerRadius = UDim.new(0, 6)

local MiniDashBtn = Instance.new("TextButton", MinimizedFrame)
MiniDashBtn.Size = UDim2.new(0.45, 0, 0, 35)
MiniDashBtn.Position = UDim2.new(0.52, 0, 0.1, 0)
MiniDashBtn.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
MiniDashBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniDashBtn.Text = "TỚI TRƯỚC"
MiniDashBtn.Font = Enum.Font.GothamBold
MiniDashBtn.TextSize = 11
Instance.new("UICorner", MiniDashBtn).CornerRadius = UDim.new(0, 6)

-- =========================================================
-- 2. HÀM XỬ LÝ LÕI
-- =========================================================
local function getRoot()
    local char = player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function doTeleportToSave(btn1, btn2)
    local root = getRoot()
    if root then
        if savedCFrame then
            root.CFrame = savedCFrame
        else
            local oldText1, oldText2 = btn1.Text, btn2.Text
            btn1.Text, btn2.Text = "CHƯA LƯU!", "CHƯA LƯU!"
            task.wait(1)
            btn1.Text, btn2.Text = oldText1, oldText2
        end
    end
end

local function doDashForward(btn1, btn2)
    local root = getRoot()
    if root then
        local distance = tonumber(DistanceBox.Text)
        if distance then
            root.CFrame = root.CFrame * CFrame.new(0, 0, -distance)
        else
            local oldText1, oldText2 = btn1.Text, btn2.Text
            btn1.Text, btn2.Text = "LỖI SỐ!", "LỖI SỐ!"
            task.wait(1)
            btn1.Text, btn2.Text = oldText1, oldText2
        end
    end
end

-- =========================================================
-- 3. GẮN SỰ KIỆN CHO NÚT
-- =========================================================

-- Nút Lưu vị trí (Chỉ có ở bảng to)
SaveBtn.MouseButton1Click:Connect(function()
    local root = getRoot()
    if root then
        savedCFrame = root.CFrame
        SaveBtn.Text = "ĐÃ LƯU!"
        task.wait(1)
        SaveBtn.Text = "LƯU VỊ TRÍ"
    end
end)

-- Gắn nút Tốc biến (Bảng to + Bảng nhỏ)
LoadBtn.MouseButton1Click:Connect(function() doTeleportToSave(LoadBtn, MiniLoadBtn) end)
MiniLoadBtn.MouseButton1Click:Connect(function() doTeleportToSave(LoadBtn, MiniLoadBtn) end)

-- Gắn nút Tới trước (Bảng to + Bảng nhỏ)
DashBtn.MouseButton1Click:Connect(function() doDashForward(DashBtn, MiniDashBtn) end)
MiniDashBtn.MouseButton1Click:Connect(function() doDashForward(DashBtn, MiniDashBtn) end)

-- Thu nhỏ / Mở rộng bảng
local isMinimized = false
ToggleBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        -- Chuyển sang Mini Mode
        ExpandedFrame.Visible = false
        MinimizedFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 220, 0, 75) -- Kích thước gọn gàng chỉ đủ chứa 2 nút
        ToggleBtn.Text = "+"
    else
        -- Chuyển về chế độ đầy đủ
        ExpandedFrame.Visible = true
        MinimizedFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 220, 0, 240)
        ToggleBtn.Text = "-"
    end
end)
