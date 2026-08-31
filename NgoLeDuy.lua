--[[ 
  UAV CONTROL SCRIPT - FLING THINGS AND PEOPLE
  Điều khiển: WASD để di chuyển, Chuột để xoay hướng
  Nhấn E để kích hoạt chế độ lao xuống mục tiêu (tự hủy)
  Nhấn X để hủy UAV và quay lại nhân vật chính
  Hiệu ứng: Tên "NgoLeDuy" mờ dần khi bật script
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ========== HIỆU ỨNG TÊN NGOLEDUY MỜ DẦN ==========
local function showWatermark()
    -- Tạo GUI hiển thị tên
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WatermarkGui"
    screenGui.Parent = LocalPlayer.PlayerGui
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "WatermarkText"
    textLabel.Size = UDim2.new(0, 400, 0, 100)
    textLabel.Position = UDim2.new(0.5, -200, 0.5, -50)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "NgoLeDuy"
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextStrokeColor3 = Color3.fromRGB(255, 50, 50)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextTransparency = 0
    textLabel.Parent = screenGui
    
    -- Tạo hiệu ứng mờ dần bằng Tween
    local tweenInfo = TweenInfo.new(
        3, -- Thời gian mờ dần (giây)
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(
        textLabel,
        tweenInfo,
        {
            TextTransparency = 1,  -- Mờ dần đến 100%
            TextStrokeTransparency = 1
        }
    )
    
    tween:Play()
    
    -- Xóa GUI sau khi hiệu ứng kết thúc
    tween.Completed:Connect(function()
        wait(0.5)
        screenGui:Destroy()
    end)
end

-- ========== TẠO UAV ==========
local function createUAV()
    local uav = Instance.new("Model")
    uav.Name = "UAV_Missile"
    
    -- Thân tên lửa
    local body = Instance.new("Part")
    body.Size = Vector3.new(1, 0.5, 3)
    body.Shape = Enum.PartType.Cylinder
    body.Material = Enum.Material.SmoothPlastic
    body.Color = Color3.fromRGB(200, 50, 50)
    body.Anchored = false
    body.CanCollide = true
    body.Parent = uav
    
    -- Đầu tên lửa (hình nón)
    local nose = Instance.new("Part")
    nose.Size = Vector3.new(1, 0.5, 1)
    nose.Shape = Enum.PartType.Cylinder
    nose.Material = Enum.Material.SmoothPlastic
    nose.Color = Color3.fromRGB(255, 100, 100)
    nose.Anchored = false
    nose.CanCollide = true
    nose.Parent = uav
    nose.CFrame = body.CFrame * CFrame.new(0, 0, -1.5)
    
    -- Cánh
    for i = -1, 1, 2 do
        local wing = Instance.new("Part")
        wing.Size = Vector3.new(2, 0.1, 0.5)
        wing.Material = Enum.Material.SmoothPlastic
        wing.Color = Color3.fromRGB(150, 150, 150)
        wing.Anchored = false
        wing.CanCollide = true
        wing.Parent = uav
        wing.CFrame = body.CFrame * CFrame.new(i * 1.5, 0, 0)
    end
    
    -- Gắn Humanoid để có thể điều khiển
    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = uav
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.PlatformStand = true
    
    -- Thêm RootPart để dễ tham chiếu
    local rootPart = body
    rootPart.Name = "HumanoidRootPart"
    
    uav.Parent = workspace
    uav.PrimaryPart = rootPart
    
    return uav
end

-- Biến điều khiển
local uav = nil
local uavRoot = nil
local isActive = false
local isDiving = false
local diveTarget = nil
local speed = 50
local rotationSpeed = 3

-- Hàm lấy mục tiêu gần nhất
local function getNearestTarget(position)
    local nearest = nil
    local minDist = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local dist = (position - root.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = root
                end
            end
        end
    end
    return nearest
end

-- Tạo UAV và đặt gần camera
local function spawnUAV()
    if uav then uav:Destroy() end
    
    uav = createUAV()
    uavRoot = uav.PrimaryPart
    local camPos = Camera.CFrame.Position
    local camLook = Camera.CFrame.LookVector
    
    uavRoot.CFrame = CFrame.new(camPos + camLook * 10 + Vector3.new(0, 5, 0))
    uavRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    uavRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    
    isActive = true
    isDiving = false
    
    -- Hiển thị tên NgoLeDuy khi bật UAV
    showWatermark()
    
    print("🚀 UAV đã sẵn sàng! Dùng WASD + Chuột để điều khiển. Nhấn E để lao xuống mục tiêu.")
end

-- Xóa UAV và quay lại
local function destroyUAV()
    if uav then
        -- Tạo hiệu ứng nổ
        local explosion = Instance.new("Explosion")
        explosion.Position = uavRoot.Position
        explosion.BlastRadius = 15
        explosion.BlastPressure = 500000
        explosion.Parent = workspace
        
        uav:Destroy()
        uav = nil
        uavRoot = nil
        isActive = false
        isDiving = false
        print("💥 UAV đã tự hủy!")
    end
end

-- Vòng lặp điều khiển chính
local function updateUAV()
    if not isActive or not uavRoot then return end
    
    if isDiving and diveTarget and diveTarget.Parent then
        -- Chế độ lao xuống mục tiêu
        local direction = (diveTarget.Position - uavRoot.Position).Unit
        local distance = (diveTarget.Position - uavRoot.Position).Magnitude
        
        uavRoot.CFrame = CFrame.lookAt(uavRoot.Position, uavRoot.Position + direction)
        uavRoot.AssemblyLinearVelocity = direction * speed * 3
        
        -- Nổ khi chạm mục tiêu
        if distance < 5 then
            destroyUAV()
            -- Fling mục tiêu
            diveTarget.AssemblyLinearVelocity = Vector3.new(0, 100, 0) * 10
            diveTarget:BreakJoints()
        end
        return
    end
    
    -- Điều khiển UAV bằng WASD + Chuột
    local moveDirection = Vector3.new(0, 0, 0)
    local keys = {
        [Enum.KeyCode.W] = Vector3.new(0, 0, -1),
        [Enum.KeyCode.S] = Vector3.new(0, 0, 1),
        [Enum.KeyCode.A] = Vector3.new(-1, 0, 0),
        [Enum.KeyCode.D] = Vector3.new(1, 0, 0),
        [Enum.KeyCode.Space] = Vector3.new(0, 1, 0),
        [Enum.KeyCode.LeftShift] = Vector3.new(0, -1, 0)
    }
    
    for key, dir in pairs(keys) do
        if UserInputService:IsKeyDown(key) then
            moveDirection = moveDirection + dir
        end
    end
    
    if moveDirection.Magnitude > 0 then
        moveDirection = moveDirection.Unit
    end
    
    -- Xoay hướng theo chuột
    local mousePos = UserInputService:GetMouseLocation()
    local ray = Camera:ScreenPointToRay(mousePos.X, mousePos.Y)
    local lookPos = ray.Origin + ray.Direction * 100
    local lookCF = CFrame.lookAt(uavRoot.Position, lookPos)
    
    -- Áp dụng di chuyển
    local velocity = lookCF:VectorToWorldSpace(moveDirection) * speed
    uavRoot.AssemblyLinearVelocity = velocity
    uavRoot.CFrame = CFrame.lookAt(uavRoot.Position, uavRoot.Position + lookCF.LookVector)
end

-- Sự kiện phím bấm
UserInputService.InputBegan:Connect(function(input, isProcessed)
    if isProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.E and isActive and not isDiving then
        -- Kích hoạt lao xuống mục tiêu
        local target = getNearestTarget(uavRoot.Position)
        if target then
            diveTarget = target
            isDiving = true
            print("🎯 Đã khóa mục tiêu! Đang lao xuống...")
        else
            print("⚠️ Không tìm thấy mục tiêu gần đó!")
        end
    end
    
    if input.KeyCode == Enum.KeyCode.X and isActive then
        destroyUAV()
    end
    
    if input.KeyCode == Enum.KeyCode.F and not isActive then
        spawnUAV()
    end
end)

-- Vòng lặp chính
RunService.Heartbeat:Connect(updateUAV)

-- Hiển thị tên NgoLeDuy ngay khi chạy script lần đầu
showWatermark()

-- Hướng dẫn
print([[
========== 🚀 UAV CONTROL ==========
[F] - Triển khai UAV
[WASD] - Di chuyển UAV
[Chuột] - Xoay hướng UAV
[Space] - Lên cao
[Shift] - Hạ thấp
[E] - Khóa mục tiêu và lao xuống (tự hủy)
[X] - Hủy UAV ngay lập tức
=====================================
]])
