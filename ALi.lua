local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- [1] تنظيف النسخ القديمة
if game.CoreGui:FindFirstChild("N6O_Ultra_Fix") then 
    game.CoreGui.N6O_Ultra_Fix:Destroy() 
end

local mainGui = Instance.new("ScreenGui")
mainGui.Name = "N6O_Ultra_Fix"
mainGui.Parent = game.CoreGui
mainGui.ResetOnSpawn = false 

-- [2] الزر الدائري N6O
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 65, 0, 65) 
toggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
toggleBtn.Text = "N6O"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.Parent = mainGui
toggleBtn.ZIndex = 10
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
local btnStroke = Instance.new("UIStroke", toggleBtn)
btnStroke.Color = Color3.fromRGB(255, 215, 0)
btnStroke.Thickness = 2

-- [3] نظام السحب (Drag)
local dragging, dragInput, dragStart, startPos
toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = toggleBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
toggleBtn.InputEnded:Connect(function() dragging = false end)

-- [4] اللوحة الرئيسية
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 180)
mainFrame.Position = UDim2.new(0.5, -140, 0.4, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.Visible = false 
mainFrame.Parent = mainGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(255, 215, 0)

local function createBtn(name, pos, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, (name:find("فتح") and 240 or 115), 0, 50)
    b.Position = pos
    b.BackgroundColor3 = color
    b.Text = name
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold; b.TextSize = 16
    b.Parent = mainFrame
    Instance.new("UICorner", b)
    return b
end

local openBtn = createBtn("🔓 فتح VIP & +VIP", UDim2.new(0.5, -120, 0.2, 0), Color3.fromRGB(50, 50, 120))
local forwardBtn = createBtn("تقدم", UDim2.new(0.06, 0, 0.6, 0), Color3.fromRGB(0, 120, 60))
local backwardBtn = createBtn("رجوع", UDim2.new(0.53, 0, 0.6, 0), Color3.fromRGB(150, 0, 0))

-- [5] وظيفة الانتقال "ثبات وقوة" (The Force System)
local function startUltraMove(target)
    if not target or not player.Character then return end
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- [تشغيل الاختراق]
    local noclip = RunService.Stepped:Connect(function()
        for _, v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end)
    
    -- [تثبيت القوة] نستخدم BodyGyro لمنع الدوران و BodyVelocity للسرعة الثابتة
    local bg = Instance.new("BodyGyro", root)
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 3000 -- قوة الثبات
    bg.CFrame = root.CFrame
    
    local bv = Instance.new("BodyVelocity", root)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)

    -- حساب المسافة والاتجاه
    local targetPos = target.Position + Vector3.new(0, 3, 0) -- رفع بسيط عن الأرض للثبات
    local dist = (targetPos - root.Position).Magnitude
    
    -- [الحركة] توين بمحرك القوة
    local tween = TweenService:Create(root, TweenInfo.new(dist/500, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(targetPos, targetPos + root.CFrame.LookVector)
    })
    
    tween:Play()
    
    tween.Completed:Connect(function()
        noclip:Disconnect()
        bg:Destroy(); bv:Destroy()
        if player.Character then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
        root.Velocity = Vector3.new(0,0,0)
    end)
end

-- [6] البحث الذكي عن البوابات
local function findGate(isFwd)
    local root = player.Character.HumanoidRootPart
    local best, minDist = nil, math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name:find("VIP") or v.Name:find("Gate") or v.Name:find("Door")) then
            local dir = (v.Position - root.Position).Unit
            local dot = root.CFrame.LookVector:Dot(dir)
            
            -- تحديد الأمام والخلف بدقة
            if (isFwd and dot > 0.3) or (not isFwd and dot < -0.3) then
                local d = (v.Position - root.Position).Magnitude
                if d < minDist and d > 5 then 
                    minDist = d
                    best = v
                end
            end
        end
    end
    return best
end

-- تفعيل الأزرار
toggleBtn.MouseButton1Click:Connect(function() mainFrame.Visible = not mainFrame.Visible end)
forwardBtn.MouseButton1Click:Connect(function() startUltraMove(findGate(true)) end)
backwardBtn.MouseButton1Click:Connect(function() startUltraMove(findGate(false)) end)

openBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name:find("VIP") or v.Name:find("+")) then
            v.CanCollide = false; v.Transparency = 0.5
        end
    end
end)
