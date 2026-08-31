--[[ 
    SCRIPT NAME: Real Rocket Dive Bomb - NgoLeDuy
    DESCRIPTION: Điều khiển tên lửa thật, lao xuống đất là nổ
    INSTRUCTION: Đặt vào StarterPlayerScripts hoặc LocalScript
--]]

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local debris = game:GetService("Debris")

-- ===== TẠO MÀN HÌNH UAV =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UAVScreen"
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

-- Chữ ký NgoLeDuy
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

game:GetService("TweenService"):Create(
    signature,
    TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 3),
    {TextTransparency = 1}
):Play()

-- Background HUD
local hudBg = Instance.new("Frame")
hudBg.Name = "HUDBackground"
hudBg.Size = UDim2.new(1, 0, 1, 0)
hudBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
hudBg.BackgroundTransparency = 0.3
hudBg.Visible = false
hudBg.Parent = screenGui

-- Sọc scanline
for i = 0, 30 do
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 2)
    line.Position = UDim2.new(0, 0, 0, i * 25)
    line.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    line.BackgroundTransparency = 0.9
    line.BorderSizePixel = 0
    line.Parent = hudBg
end

-- Viền góc
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

-- Đồng hồ
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
infoHud.Size = UDim2.new(0, 350, 0, 150)
infoHud.Position = UDim2.new(0.02, 0, 0.12, 0)
infoHud.BackgroundTransparency = 1
infoHud.TextColor3 = Color3.fromRGB(0, 255, 100)
infoHud.TextScaled = false
infoHud.Font = Enum.Font.SourceSans
infoHud.Text = "🔍 SEARCHING REAL ROCKETS..."
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

-- Cảnh báo độ cao (ALERT)
local altitudeAlert = Instance.new("TextLabel")
altitudeAlert.Name = "AltitudeAlert"
altitudeAlert.Size = UDim2.new(0, 300, 0, 60)
altitudeAlert.Position = UDim2.new(0.5, -150, 0.15, 0)
altitudeAlert.BackgroundTransparency = 1
altitudeAlert.TextColor3 = Color3.fromRGB(255, 0, 0)
altitudeAlert.TextScaled = true
altitudeAlert.Font = Enum.Font.SourceSansBold
altitudeAlert.Text = "⚠️ LOW ALTITUDE!"
altitudeAlert.Visible = false
altitudeAlert.Parent = hudBg

-- Hướng dẫn
local helpText = Instance.new("TextLabel")
helpText.Size = UDim2.new(0, 500, 0, 40)
helpText.Position = UDim2.new(0.5, -250, 0.92, 0)
helpText.BackgroundTransparency = 1
helpText.TextColor3 = Color3.fromRGB(0, 255, 100)
helpText.TextScaled = false
helpText.Font = Enum.Font.SourceSans
helpText.TextSize = 14
helpText.Text = "V: Vào buồng lái | WASD: Bay | Space: Lên | Z: Xuống | E: Tự hủy"
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

-- ===== HÀM TÌM TÊN LỬA THẬT =====
local function findAllRockets()
    local rockets = {}
    
    for _, child in pairs(workspace:GetDescendants()) do
        if child:IsA("BasePart") and child.Parent ~= player.Character then
            local name = child.Name:lower()
            local isRocket = false
            
            if name:find("rocket") or name:find("missile") or 
               name:find("shell") or name:find("bullet") or
               name:find("tên lửa") or name:find("ten lua") or
               name:find("bomb") or name:find("torpedo") then
                isRocket = true
            end
            
            local size = child.Size
            if size.X > 1 and size.Z > 1 and size.Y < size.X * 2 then
                isRocket = true
            end
            
            if isRocket then
                table.insert(rockets, child)
            end
        end
    end
    
    return rockets
end

local function findNearestRocket()
    local nearest = nil
    local minDist = math.huge
    
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local charPos = player.Character.HumanoidRootPart.Position
    local allRockets = findAllRockets()
    
    for _, rocket in pairs(allRockets) do
        if rocket and rocket.Parent then
            local dist = (rocket.Position - charPos).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = rocket
            end
        end
    end
    
    return nearest, minDist
end

-- ===== HÀM TẠO NỔ LỚN =====
local function createBigExplosion(position, size)
    -- Nổ chính
    local explosion = Instance.new("Explosion")
    explosion.Position = position
    explosion.BlastRadius = size or 40
    explosion.BlastPressure = 500000
    explosion.DestroyJointRadiusPercent = 0.9
    explosion.Parent = workspace
    
    -- Tia lửa
    for i = 1, 60 do
        local spark = Instance.new("Part")
        spark.Size = Vector3.new(0.5, 0.5, 0.5)
        spark.Shape = Enum.PartType.Ball
        spark.Position = position + Vector3.new(
            math.random(-25, 25),
            math.random(-25, 25),
            math.random(-25, 25)
        )
        spark.Material = Enum.Material.Neon
        spark.Color = Color3.fromRGB(
            math.random(200, 255),
            math.random(50, 150),
            math.random(0, 50)
        )
        spark.Anchored = true
        spark.CanCollide = false
        spark.Parent = workspace
        
        local bf = Instance.new("BodyForce")
        bf.Force = Vector3.new(
            math.random(-4000, 4000),
            math.random(-4000, 4000),
            math.random(-4000, 4000)
        )
        bf.Parent = spark
        debris:AddItem(spark, 3)
    end
    
    -- Khói đen
    for i = 1, 20 do
        local smoke = Instance.new("Part")
        smoke.Size = Vector3.new(5, 5, 5)
        smoke.Shape = Enum.PartType.Ball
        smoke.Position = position + Vector3.new(
            math.random(-20, 20),
            math.random(-20, 20),
            math.random(-20, 20)
        )
        smoke.Material = Enum.Material.SmoothPlastic
        smoke.Color = Color3.fromRGB(50, 50, 50)
        smoke.Anchored = true
        smoke.CanCollide = false
        smoke.Transparency = 0.5
        smoke.Parent = workspace
        
        local bf = Instance.new("BodyForce")
        bf.Force = Vector3.new(
            math.random(-1000, 1000),
            math.random(500, 2000),
            math.random(-1000, 1000)
        )
        bf.Parent = smoke
        debris:AddItem(smoke, 5)
    end
    
    -- Rung màn hình
    for i = 1, 15 do
        hudBg.Position = UDim2.new(
            math.random(-8, 8) / 1000,
            0,
            math.random(-8, 8) / 1000,
            0
        )
        wait(0.02)
    end
    hudBg.Position = UDim2.new(0, 0, 0, 0)
    
    -- Rung camera
    if cameraLocked then
        for i = 1, 10 do
            camera.CFrame = camera.CFrame + Vector3.new(
                math.random(-3, 3),
                math.random(-3, 3),
                math.random(-3, 3)
            )
            wait(0.02)
        end
    end
end

-- ===== BIẾN ĐIỀU KHIỂN =====
local currentRocket = nil
local cameraLocked = false
local keysPressed = {}
local rocketSpeed = 200
local isDiving = false
local diveSpeed = 0

-- Hàm lấy rocket thật
local function getRealRocket(part)
    local parent = part.Parent
    if parent and parent:IsA("Model") then
        local parts = parent:GetChildren()
        for _, child in pairs(parts) do
            if child:IsA("BasePart") and child ~= part then
                return parent
            end
        end
    end
    return part
end

-- Hàm kiểm tra va chạm với mặt đất
local function checkGroundCollision(rocketPart)
    if not rocketPart then return false end
    
    -- Kiểm tra khoảng cách đến mặt đất
    local rayOrigin = rocketPart.Position
    local rayDirection = Vector3.new(0, -1, 0)
    local ray = Ray.new(rayOrigin, rayDirection * 10)
    
    local hit, position = workspace:FindPartOnRay(ray, rocketPart, false, true)
    
    if hit and hit:IsA("BasePart") and hit.Anchored then
        return true, position
    end
    
    -- Kiểm tra độ cao (nếu dưới 5 studs so với mặt đất)
    local groundLevel = 0
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("BasePart") and v.Anchored and v.Position.Y < groundLevel then
            groundLevel = v.Position.Y + v.Size.Y/2
        end
    end
    
    if rocketPart.Position.Y < groundLevel + 3 then
        return true, Vector3.new(rocketPart.Position.X, groundLevel, rocketPart.Position.Z)
    end
    
    return false
end

-- Hàm tự hủy (nổ)
local function selfDestruct()
    if not currentRocket then return end
    
    local rocketPart = currentRocket
    if currentRocket:IsA("Model") then
        rocketPart = currentRocket:FindFirstChildWhichIsA("BasePart")
    end
    
    if rocketPart then
        local explosionPos = rocketPart.Position
        createBigExplosion(explosionPos, 45)
        
        if currentRocket:IsA("Model") then
            currentRocket:Destroy()
        else
            currentRocket:Destroy()
        end
        
        currentRocket = nil
        cameraLocked = false
        camera.CameraType = Enum.CameraType.Custom
        hudBg.Visible = false
        isDiving = false
        
        infoHud.Text = "💥 ROCKET DESTROYED"
        infoHud.TextColor3 = Color3.fromRGB(255, 0, 0)
        wait(1.5)
        infoHud.Text = "🔍 SEARCHING REAL ROCKETS..."
        infoHud.TextColor3 = Color3.fromRGB(0, 255, 100)
    end
end

-- ===== PHÍM ĐIỀU KHIỂN =====

-- V: Vào tên lửa
mouse.KeyDown:Connect(function(key)
    if key == "v" then
        local nearest, distance = findNearestRocket()
        
        if not nearest then
            infoHud.Text = "⚠️ NO REAL ROCKET FOUND!"
            wait(1)
            infoHud.Text = "🔍 SEARCHING REAL ROCKETS..."
            return
        end
        
        infoHud.Text = "🎯 ROCKET FOUND!\n📍 Distance: " .. string.format("%.1f", distance) .. " studs"
        wait(0.5)
        
        if cameraLocked then
            if currentRocket then
                for _, v in pairs(currentRocket:GetChildren()) do
                    if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
                        v:Destroy()
                    end
                end
            end
            camera.CameraType = Enum.CameraType.Custom
            cameraLocked = false
            hudBg.Visible = false
            isDiving = false
            wait(0.1)
        end
        
        local realRocket = getRealRocket(nearest)
        local rocketPart = nearest
        if realRocket:IsA("Model") then
            rocketPart = realRocket:FindFirstChildWhichIsA("BasePart")
        end
        
        if not rocketPart then
            infoHud.Text = "⚠️ INVALID ROCKET!"
            wait(1)
            infoHud.Text = "🔍 SEARCHING REAL ROCKETS..."
            return
        end
        
        currentRocket = realRocket
        cameraLocked = true
        hudBg.Visible = true
        camera.CameraType = Enum.CameraType.Scriptable
        isDiving = false
        
        -- Thêm BodyVelocity
        if not rocketPart:FindFirstChild("BodyVelocity") then
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(30000, 30000, 30000)
            bv.Velocity = Vector3.new(0, 50, 0)
            bv.Parent = rocketPart
        end
        
        -- Thêm BodyGyro
        if not rocketPart:FindFirstChild("BodyGyro") then
            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(30000, 30000, 30000)
            bg.P = 100000
            bg.CFrame = rocketPart.CFrame
            bg.Parent = rocketPart
        end
        
        infoHud.Text = "🎯 COCKPIT ACTIVE\n🚀 " .. currentRocket.Name
    end
end)

-- E: Tự hủy
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
       input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.Z then
        keysPressed[input.KeyCode] = true
    end
end)

userInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.A or 
       input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.D or
       input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.Z then
        keysPressed[input.KeyCode] = nil
    end
end)

-- Cập nhật mỗi frame
runService.RenderStepped:Connect(function()
    if not cameraLocked or not currentRocket then return end
    
    local body = nil
    if currentRocket:IsA("Model") then
        body = currentRocket:FindFirstChildWhichIsA("BasePart")
    else
        body = currentRocket
    end
    
    if not body then return end
    
    local bv = body:FindFirstChild("BodyVelocity")
    if not bv then return end
    
    local bg = body:FindFirstChild("BodyGyro")
    
    -- ===== KIỂM TRA VA CHẠM MẶT ĐẤT =====
    local hitGround, groundPos = checkGroundCollision(body)
    if hitGround and body.Velocity.Y < -10 then
        -- NỔ KHI CHẠM ĐẤT!
        createBigExplosion(body.Position, 50)
        
        -- Xóa rocket
        if currentRocket:IsA("Model") then
            currentRocket:Destroy()
        else
            currentRocket:Destroy()
        end
        currentRocket = nil
        cameraLocked = false
        camera.CameraType = Enum.CameraType.Custom
        hudBg.Visible = false
        isDiving = false
        
        infoHud.Text = "💥 CRASHED!"
        infoHud.TextColor3 = Color3.fromRGB(255, 0, 0)
        wait(1.5)
        infoHud.Text = "🔍 SEARCHING REAL ROCKETS..."
        infoHud.TextColor3 = Color3.fromRGB(0, 255, 100)
        return
    end
    
    -- ===== ĐIỀU KHIỂN =====
    local camCF = camera.CFrame
    local forward = camCF.LookVector
    local right = camCF.RightVector
    local up = camCF.UpVector
    
    local speed = rocketSpeed
    local moveVec = Vector3.new(0, 0, 0)
    
    -- Di chuyển ngang
    if keysPressed[Enum.KeyCode.W] then
        moveVec = moveVec + forward * speed
    end
    if keysPressed[Enum.KeyCode.S] then
        moveVec = moveVec - forward * speed * 0.6
    end
    if keysPressed[Enum.KeyCode.A] then
        moveVec = moveVec - right * speed
    end
    if keysPressed[Enum.KeyCode.D] then
        moveVec = moveVec + right * speed
    end
    
    -- Lên/xuống (dễ dàng)
    if keysPressed[Enum.KeyCode.Space] then
        moveVec = moveVec + Vector3.new(0, speed * 0.7, 0)
        isDiving = false
    elseif keysPressed[Enum.KeyCode.Z] then
        -- LAO XUỐNG (Dive Bomb!)
        moveVec = moveVec + Vector3.new(0, -speed * 2, 0)
        isDiving = true
    end
    
    -- Nếu đang lao xuống và không nhấn gì, tiếp tục lao
    if isDiving and not keysPressed[Enum.KeyCode.Z] and not keysPressed[Enum.KeyCode.Space] then
        moveVec = moveVec + Vector3.new(0, -speed * 1.5, 0)
    end
    
    -- Áp dụng vận tốc
    if moveVec.Magnitude > 0 then
        bv.Velocity = moveVec
        local speedDisplay = moveVec.Magnitude
        
        -- Cảnh báo khi lao xuống
        if moveVec.Y < -100 then
            infoHud.Text = "💥 DIVING!\n📍 Speed: " .. string.format("%.0f", speedDisplay) .. " m/s"
            altitudeAlert.Visible = true
            altitudeAlert.Text = "⚠️ DIVING! PULL UP!"
            altitudeAlert.TextColor3 = Color3.fromRGB(255, 0, 0)
        elseif moveVec.Y < -50 then
            infoHud.Text = "⬇️ DESCENDING\n📍 Speed: " .. string.format("%.0f", speedDisplay) .. " m/s"
            altitudeAlert.Visible = true
            altitudeAlert.Text = "⚠️ LOW ALTITUDE!"
            altitudeAlert.TextColor3 = Color3.fromRGB(255, 200, 0)
        else
            infoHud.Text = "✈️ FLYING\n📍 Speed: " .. string.format("%.0f", speedDisplay) .. " m/s"
            altitudeAlert.Visible = false
        end
    else
        bv.Velocity = Vector3.new(0, 0, 0)
        infoHud.Text = "🔄 HOVERING\n📍 Ready"
        altitudeAlert.Visible = false
    end
    
    -- Xoay rocket theo hướng bay
    if bg and bv.Velocity.Magnitude > 5 then
        local targetCF = CFrame.lookAt(body.Position, body.Position + bv.Velocity)
        bg.CFrame = targetCF
    end
    
    -- ===== GÓC NHÌN THỨ NHẤT =====
    local offset = Vector3.new(0, 0.5, 3)
    local cameraPos = body.Position + (body.CFrame:VectorToWorldSpace(offset))
    local lookAtPos = body.Position + (body.CFrame:VectorToWorldSpace(Vector3.new(0, 0, 30)))
    
    camera.CFrame = CFrame.new(cameraPos, lookAtPos)
    
    -- Hiển thị độ cao
    if body then
        local height = body.Position.Y
        if height < 10 then
            altitudeAlert.Visible = true
            altitudeAlert.Text = "⚠️ DANGER! LOW ALTITUDE!"
            altitudeAlert.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    end
end)

print("🚀 DIVE BOMB ROCKET SYSTEM - NgoLeDuy")
print("📡 Press V to enter cockpit")
print("🎮 WASD = Fly | Space = Up | Z = DIVE BOMB!")
print("💥 LAO XUỐNG ĐẤT SẼ NỔ!")
print("🔄 Auto-hover mode active!")
