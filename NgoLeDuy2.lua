--[[ 
    SCRIPT NAME: Rocket First-Person View - NgoLeDuy
    DESCRIPTION: Triệu hồi rocket, ấn V để vào góc nhìn thứ nhất của rocket gần nhất
    INSTRUCTION: Đặt vào StarterPlayerScripts hoặc LocalScript
--]]

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")
local debris = game:GetService("Debris")
local userInputService = game:GetService("UserInputService")

-- ===== TẠO MÀN HÌNH UAV =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UAVScreen"
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

-- Chữ ký NgoLeDuy (xuất hiện 3 giây rồi mờ dần)
local signature = Instance.new("TextLabel")
signature.Name = "Signature"
signature.Size = UDim2.new(0, 300, 0, 60)
signature.Position = UDim2.new(0.5, -150, 0.5, -30)
signature.BackgroundTransparency = 1
signature.Text = "NgoLeDuy"
signature.TextColor3 = Color3.fromRGB(0, 255, 200)
signature.TextScaled = true
signature.Font = Enum.Font.SourceSansBold
signature.TextStrokeTransparency = 0.3
signature.TextStrokeColor3 = Color3.fromRGB(0, 100, 200)
signature.Parent = screenGui

-- Hiệu ứng mờ dần và biến mất sau 3 giây
game:GetService("TweenService"):Create(
    signature,
    TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 3),
    {TextTransparency = 1}
):Play()

-- Background HUD (màn hình UAV)
local hudBg = Instance.new("Frame")
hudBg.Name = "HUDBackground"
hudBg.Size = UDim2.new(1, 0, 1, 0)
hudBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
hudBg.BackgroundTransparency = 0.3
hudBg.Visible = false -- Ẩn khi chưa kích hoạt
hudBg.Parent = screenGui

-- Sọc sọc scanline
for i = 0, 30 do
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 2)
    line.Position = UDim2.new(0, 0, 0, i * 25)
    line.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    line.BackgroundTransparency = 0.9
    line.BorderSizePixel = 0
    line.Parent = hudBg
end

-- Khung viền góc
for i = 1, 4 do
    local corner = Instance.new("Frame")
    corner.Size = UDim2.new(0, 30, 0, 30)
    corner.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    corner.BackgroundTransparency = 0.7
    corner.BorderSizePixel = 0
    corner.Parent = hudBg
    
    if i == 1 then
        corner.Position = UDim2.new(0.05, 0, 0.05, 0)
    elseif i == 2 then
        corner.Position = UDim2.new(0.95, -30, 0.05, 0)
    elseif i == 3 then
        corner.Position = UDim2.new(0.05, 0, 0.95, -30)
    else
        corner.Position = UDim2.new(0.95, -30, 0.95, -30)
    end
end

-- Đồng hồ giờ ngày thật
local clock = Instance.new("TextLabel")
clock.Name = "Clock"
clock.Size = UDim2.new(0, 250, 0, 40)
clock.Position = UDim2.new(0.02, 0, 0.02, 0)
clock.BackgroundTransparency = 1
clock.TextColor3 = Color3.fromRGB(0, 255, 100)
clock.TextScaled = true
clock.Font = Enum.Font.SourceSansBold
clock.Text = ""
clock.TextXAlignment = Enum.TextXAlignment.Left
clock.Parent = hudBg

-- HUD thông tin
local infoHud = Instance.new("TextLabel")
infoHud.Name = "InfoHUD"
infoHud.Size = UDim2.new(0, 300, 0, 150)
infoHud.Position = UDim2.new(0.02, 0, 0.12, 0)
infoHud.BackgroundTransparency = 1
infoHud.TextColor3 = Color3.fromRGB(0, 255, 100)
infoHud.TextScaled = false
infoHud.Font = Enum.Font.SourceSans
infoHud.Text = "📡 SCANNING..."
infoHud.TextSize = 16
infoHud.TextXAlignment = Enum.TextXAlignment.Left
infoHud.TextYAlignment = Enum.TextYAlignment.Top
infoHud.Parent = hudBg

-- Crosshair
local crosshair = Instance.new("ImageLabel")
crosshair.Size = UDim2.new(0, 50, 0, 50)
crosshair.Position = UDim2.new(0.5, -25, 0.5, -25)
crosshair.BackgroundTransparency = 1
crosshair.Image = "rbxassetid://5058595882"
crosshair.ImageColor3 = Color3.fromRGB(0, 255, 100)
crosshair.ImageTransparency = 0.3
crosshair.Parent = hudBg

-- Hướng dẫn
local helpText = Instance.new("TextLabel")
helpText.Size = UDim2.new(0, 500, 0, 40)
helpText.Position = UDim2.new(0.5, -250, 0.92, 0)
helpText.BackgroundTransparency = 1
helpText.TextColor3 = Color3.fromRGB(0, 255, 100)
helpText.TextScaled = false
helpText.Font = Enum.Font.SourceSans
helpText.TextSize = 14
helpText.Text = "Q: Tạo rocket | V: Vào buồng lái rocket gần nhất | E: Tự hủy | WASD: Điều khiển"
helpText.TextStrokeTransparency = 0.5
helpText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
helpText.Parent = hudBg

-- Cập nhật đồng hồ
local function updateClock()
    while wait(0.5) do
        if hudBg.Visible then
            local time = os.date("*t")
            local dateStr = string.format("%02d/%02d/%04d", time.day, time.month, time.year)
            local timeStr = string.format("%02d:%02d:%02d", time.hour, time.min, time.sec)
            clock.Text = "📡 " .. dateStr .. "  " .. timeStr
        end
    end
end
spawn(updateClock)

-- ===== HÀM TẠO ROCKET =====
local function createRocket()
    local rocket = Instance.new("Model")
    rocket.Name = "Rocket"
    
    -- Thân rocket
    local body = Instance.new("Part")
    body.Size = Vector3.new(3, 2, 8)
    body.Shape = Enum.PartType.Cylinder
    body.Position = player.Character.HumanoidRootPart.Position + Vector3.new(0, 10, 0)
    body.Anchored = false
    body.CanCollide = true
    body.Material = Enum.Material.Metal
    body.Color = Color3.fromRGB(180, 50, 50)
    body.Parent = rocket
    
    -- Mũi rocket
    local tip = Instance.new("Part")
    tip.Size = Vector3.new(2, 2, 3)
    tip.Position = body.Position + Vector3.new(0, 0, 5.5)
    tip.Anchored = false
    tip.CanCollide = true
    tip.Material = Enum.Material.Metal
    tip.Color = Color3.fromRGB(200, 100, 100)
    tip.Parent = rocket
    
    -- Cánh rocket
    for i = 1, 4 do
        local wing = Instance.new("Part")
        wing.Size = Vector3.new(0.3, 3, 1.5)
        wing.Position = body.Position + Vector3.new(
            math.cos(math.rad(i * 90)) * 2.5,
            math.sin(math.rad(i * 90)) * 2.5,
            -3
        )
        wing.Anchored = false
        wing.CanCollide = true
        wing.Material = Enum.Material.Metal
        wing.Color = Color3.fromRGB(150, 150, 150)
        wing.Parent = rocket
    end
    
    -- Lửa
    local fire = Instance.new("Fire")
    fire.Parent = body
    fire.Size = 15
    fire.Heat = 30
    fire.Color = Color3.fromRGB(255, 150, 0)
    fire.SecondaryColor = Color3.fromRGB(255, 50, 0)
    
    -- Khói
    local smoke = Instance.new("Smoke")
    smoke.Parent = body
    smoke.Size = 20
    smoke.RiseVelocity = 5
    smoke.Opacity = 0.5
    
    -- BodyVelocity (bay)
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(10000, 10000, 10000)
    bv.Velocity = Vector3.new(0, 50, 0)
    bv.Parent = body
    
    -- BodyGyro (ổn định)
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(10000, 10000, 10000)
    bg.P = 50000
    bg.CFrame = body.CFrame
    bg.Parent = body
    
    -- Weld
    local weld = Instance.new("Weld")
    weld.Part0 = body
    weld.Part1 = tip
    weld.C0 = CFrame.new(0, 0, 5.5)
    weld.Parent = body
    
    rocket.Parent = workspace
    
    -- Fling mọi thứ xung quanh
    runService.Heartbeat:Connect(function()
        if not rocket.Parent then return end
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("BasePart") and v ~= body and v.Parent ~= player.Character and v.Anchored == false then
                local distance = (v.Position - body.Position).Magnitude
                if distance < 20 then
                    local direction = (v.Position - body.Position).Unit
                    local force = direction * 8000 / (distance + 1)
                    if v:IsA("Part") and v.CanCollide then
                        local bf = Instance.new("BodyForce")
                        bf.Force = force
                        bf.Parent = v
                        debris:AddItem(bf, 0.1)
                    end
                end
            end
        end
        
        -- Fling người chơi
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local root = plr.Character.HumanoidRootPart
                local distance = (root.Position - body.Position).Magnitude
                if distance < 20 then
                    local direction = (root.Position - body.Position).Unit
                    root.Velocity = direction * 300 / (distance + 1)
                    root:BreakJoints()
                end
            end
        end
    end)
    
    return rocket
end

-- ===== BIẾN ĐIỀU KHIỂN =====
local rockets = {} -- Danh sách rocket
local currentRocket = nil -- Rocket đang điều khiển
local cameraLocked = false
local isControlling = false
local rocketSpeed = 200
local keysPressed = {}

-- Tìm rocket gần nhất
local function findNearestRocket()
    local nearest = nil
    local minDist = math.huge
    
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local charPos = player.Character.HumanoidRootPart.Position
    
    for _, rocket in pairs(rockets) do
        if rocket and rocket.Parent then
            local body = rocket:FindFirstChildWhichIsA("Part")
            if body then
                local dist = (body.Position - charPos).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = rocket
                end
            end
        end
    end
    
    return nearest
end

-- Hàm tự hủy rocket
local function selfDestruct()
    if not currentRocket then return end
    
    local body = currentRocket:FindFirstChildWhichIsA("Part")
    if body then
        -- Tạo nổ
        local explosion = Instance.new("Explosion")
        explosion.Position = body.Position
        explosion.BlastRadius = 30
        explosion.BlastPressure = 300000
        explosion.Parent = workspace
        
        -- Hiệu ứng rung
        for i = 1, 10 do
            hudBg.Position = UDim2.new(
                math.random(-5, 5) / 1000,
                0,
                math.random(-5, 5) / 1000,
                0
            )
            wait(0.02)
        end
        hudBg.Position = UDim2.new(0, 0, 0, 0)
        
        -- Xóa rocket
        currentRocket:Destroy()
        currentRocket = nil
        cameraLocked = false
        isControlling = false
        camera.CameraType = Enum.CameraType.Custom
        hudBg.Visible = false
        
        infoHud.Text = "💥 ROCKET DESTROYED"
        infoHud.TextColor3 = Color3.fromRGB(255, 0, 0)
        wait(1)
        infoHud.Text = "📡 SCANNING..."
        infoHud.TextColor3 = Color3.fromRGB(0, 255, 100)
    end
end

-- ===== PHÍM ĐIỀU KHIỂN =====

-- Q: Tạo rocket
mouse.KeyDown:Connect(function(key)
    if key == "q" then
        local newRocket = createRocket()
        table.insert(rockets, newRocket)
        infoHud.Text = "🚀 ROCKET DEPLOYED!\n📍 " .. #rockets .. " rocket(s) active"
        
        -- Tự động hủy sau 30 giây nếu không dùng
        game:GetService("Debris"):AddItem(newRocket, 30)
    end
end)

-- V: Vào góc nhìn thứ nhất của rocket gần nhất
mouse.KeyDown:Connect(function(key)
    if key == "v" then
        local nearest = findNearestRocket()
        
        if not nearest then
            infoHud.Text = "⚠️ NO ROCKET FOUND!\n📡 Deploy one with Q"
            wait(1)
            infoHud.Text = "📡 SCANNING..."
            return
        end
        
        -- Nếu đang điều khiển rocket khác, thoát trước
        if cameraLocked then
            camera.CameraType = Enum.CameraType.Custom
            cameraLocked = false
            isControlling = false
            hudBg.Visible = false
            wait(0.1)
        end
        
        -- Vào rocket mới
        currentRocket = nearest
        cameraLocked = true
        isControlling = true
        hudBg.Visible = true
        camera.CameraType = Enum.CameraType.Scriptable
        
        infoHud.Text = "🎯 COCKPIT VIEW ACTIVE\n⚡ Controlling: " .. currentRocket.Name
    end
end)

-- E: Tự hủy rocket đang điều khiển
mouse.KeyDown:Connect(function(key)
    if key == "e" and cameraLocked then
        selfDestruct()
    end
end)

-- Điều khiển WASD
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not cameraLocked or not currentRocket then return end
    
    if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.A or 
       input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.D or
       input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftShift then
        keysPressed[input.KeyCode] = true
    end
end)

userInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.A or 
       input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.D or
       input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftShift then
        keysPressed[input.KeyCode] = nil
    end
end)

-- Cập nhật mỗi frame
runService.RenderStepped:Connect(function()
    if not cameraLocked or not currentRocket then return end
    
    local body = currentRocket:FindFirstChildWhichIsA("Part")
    if not body then return end
    
    local bv = body:FindFirstChild("BodyVelocity")
    if not bv then return end
    
    -- Điều khiển di chuyển
    local moveVec = Vector3.new(0, 0, 0)
    local forward = camera.CFrame.LookVector * rocketSpeed
    local right = camera.CFrame.RightVector * rocketSpeed
    local up = camera.CFrame.UpVector * rocketSpeed
    
    if keysPressed[Enum.KeyCode.W] then
        moveVec = moveVec + forward
    end
    if keysPressed[Enum.KeyCode.S] then
        moveVec = moveVec - forward
    end
    if keysPressed[Enum.KeyCode.A] then
        moveVec = moveVec - right
    end
    if keysPressed[Enum.KeyCode.D] then
        moveVec = moveVec + right
    end
    if keysPressed[Enum.KeyCode.Space] then
        moveVec = moveVec + up * 0.7
    end
    if keysPressed[Enum.KeyCode.LeftShift] then
        moveVec = moveVec - up * 0.7
    end
    
    if moveVec.Magnitude > 0 then
        bv.Velocity = moveVec
        infoHud.Text = "🎯 FLYING\n📍 Speed: " .. string.format("%.0f", moveVec.Magnitude) .. " m/s"
    else
        infoHud.Text = "🎯 HOVERING\n📍 Speed: " .. string.format("%.0f", bv.Velocity.Magnitude) .. " m/s"
    end
    
    -- Xoay rocket theo hướng bay
    if bv.Velocity.Magnitude > 10 then
        local bg = body:FindFirstChild("BodyGyro")
        if bg then
            bg.CFrame = CFrame.lookAt(body.Position, body.Position + bv.Velocity)
        end
    end
    
    -- GÓC NHÌN THỨ NHẤT (Camera trong buồng lái)
    local cameraPos = body.Position + (body.CFrame:VectorToWorldSpace(Vector3.new(0, 0.5, 4)))
    local lookAtPos = body.Position + (body.CFrame:VectorToWorldSpace(Vector3.new(0, 0, 50)))
    
    camera.CFrame = CFrame.new(cameraPos, lookAtPos)
end)

-- Dọn dẹp rocket khi bị xóa
game:GetService("RunService").Heartbeat:Connect(function()
    for i = #rockets, 1, -1 do
        if not rockets[i] or not rockets[i].Parent then
            table.remove(rockets, i)
        end
    end
end)

-- Thoát camera khi nhấn V lần nữa (đã xử lý ở trên)

print("🚀 ROCKET SYSTEM INITIALIZED - NgoLeDuy")
print("📡 Press Q to create rocket")
print("🎯 Press V to enter cockpit view of nearest rocket")
print("💥 Press E to self-destruct")
print("🔄 Press V again to exit cockpit view")
