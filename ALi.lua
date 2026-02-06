local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- 1. إنشاء الزر الدائري (ابو قحط) في الزاوية العلوية
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "AbuQaht_System_V2"
mainGui.Parent = player:WaitForChild("PlayerGui")
mainGui.ResetOnSpawn = false 

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "AbuQahtBtn"
toggleBtn.Size = UDim2.new(0, 70, 0, 70) 
toggleBtn.Position = UDim2.new(0.02, 0, 0.02, 0) -- الزاوية العلوية اليسرى
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- خلفية سوداء
toggleBtn.Text = "ابو قحط"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.Parent = mainGui

-- جعل الزر دائرياً
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = toggleBtn

-- جعل كلمة "ابو قحط" ملونة (قوس قزح متحرك)
local textGradient = Instance.new("UIGradient")
textGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
}
textGradient.Parent = toggleBtn

-- سكربت تحريك الألوان (اختياري لجعل الاسم يلمع)
task.spawn(function()
    while task.wait() do
        textGradient.Rotation = textGradient.Rotation + 2
    end
end)

-- 2. القائمة الرئيسية (RTX HUB)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 180)
mainFrame.Position = UDim2.new(0.5, -160, 0.4, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.Visible = false 
mainFrame.Active = true
mainFrame.Draggable = true 
mainFrame.Parent = mainGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.Text = "الانتقال التلقائي بواسطة VIP"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.Parent = mainFrame

-- الأزرار الداخلية (نفس الحركة الثابتة)
local function createBtn(name, pos, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, (name == "🔓 فتح VIP" and 280 or 135), 0, 50)
    b.Position = pos
    b.BackgroundColor3 = color
    b.Text = name
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.Parent = mainFrame
    Instance.new("UICorner", b)
    return b
end

local openBtn = createBtn("🔓 فتح VIP", UDim2.new(0.5, -140, 0.25, 0), Color3.fromRGB(70, 60, 140))
local forwardBtn = createBtn("▶️ تقدم تلقائي", UDim2.new(0.06, 0, 0.62, 0), Color3.fromRGB(75, 150, 75))
local backwardBtn = createBtn("◀️ رجوع تلقائي", UDim2.new(0.51, 0, 0.62, 0), Color3.fromRGB(160, 50, 50))

-- 3. البرمجة والتحكم
toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

local function startFly(target)
    if not target then return end
    local root = player.Character.HumanoidRootPart
    target.CanCollide = false
    
    local bg = Instance.new("BodyGyro", root)
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.CFrame = root.CFrame
    
    local bv = Instance.new("BodyVelocity", root)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0,0,0)
    
    local dist = (target.Position - root.Position).Magnitude
    local tween = TweenService:Create(root, TweenInfo.new(dist/100, Enum.EasingStyle.Linear), {CFrame = CFrame.new(target.Position, target.Position + root.CFrame.LookVector)})
    tween:Play()
    tween.Completed:Connect(function() bg:Destroy() bv:Destroy() end)
end

local function getGate(isFwd)
    local root = player.Character.HumanoidRootPart
    local best, minDist = nil, math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name:find("VIP") or v.Name:find("Gate")) then
            local dot = root.CFrame.LookVector:Dot((v.Position - root.Position).Unit)
            if (isFwd and dot > 0.3) or (not isFwd and dot < -0.3) then
                local d = (v.Position - root.Position).Magnitude
                if d < minDist then minDist = d; best = v end
            end
        end
    end
    return best
end

forwardBtn.MouseButton1Click:Connect(function() startFly(getGate(true)) end)
backwardBtn.MouseButton1Click:Connect(function() startFly(getGate(false)) end)
openBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:find("VIP") then v.CanCollide = false v.Transparency = 0.5 end
    end
end)
