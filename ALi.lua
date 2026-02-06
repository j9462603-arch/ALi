local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- 1. بناء القائمة بنفس شكل الصورة والمقطع
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RTX_VIP_Final"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 180)
mainFrame.Position = UDim2.new(0.5, -160, 0.4, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.Active = true
mainFrame.Draggable = true -- للتحريك على الايباد
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.Text = "الانتقال التلقائي بواسطة VIP"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.Parent = mainFrame

-- زر فتح VIP
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 280, 0, 55)
openBtn.Position = UDim2.new(0.5, -140, 0.25, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(70, 60, 140)
openBtn.Text = "🔓 فتح VIP"
openBtn.TextColor3 = Color3.new(1, 1, 1)
openBtn.Font = Enum.Font.GothamBold
openBtn.Parent = mainFrame
Instance.new("UICorner", openBtn)

-- زر تقدم تلقائي (الأخضر)
local forwardBtn = Instance.new("TextButton")
forwardBtn.Size = UDim2.new(0, 135, 0, 50)
forwardBtn.Position = UDim2.new(0.06, 0, 0.62, 0)
forwardBtn.BackgroundColor3 = Color3.fromRGB(75, 150, 75)
forwardBtn.Text = "▶️ تقدم تلقائي"
forwardBtn.TextColor3 = Color3.new(1, 1, 1)
forwardBtn.Font = Enum.Font.GothamBold
forwardBtn.Parent = mainFrame
Instance.new("UICorner", forwardBtn)

-- زر رجوع تلقائي (الأحمر)
local backwardBtn = Instance.new("TextButton")
backwardBtn.Size = UDim2.new(0, 135, 0, 50)
backwardBtn.Position = UDim2.new(0.51, 0, 0.62, 0)
backwardBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
backwardBtn.Text = "◀️ رجوع تلقائي"
backwardBtn.TextColor3 = Color3.new(1, 1, 1)
backwardBtn.Font = Enum.Font.GothamBold
backwardBtn.Parent = mainFrame
Instance.new("UICorner", backwardBtn)

-- 2. الوظائف البرمجية الذكية (توجيه 360 درجة)
local function findGateByDirection(isForward)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local bestGate = nil
    local minDistance = math.huge

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:find("VIP") or obj.Name:find("Gate")) then
            local dirToGate = (obj.Position - root.Position).Unit
            local lookDir = root.CFrame.LookVector
            local dotProduct = lookDir:Dot(dirToGate)

            -- التقدم يبحث عن dot > 0 (أمامك)، الرجوع يبحث عن dot < 0 (خلفك)
            local isValidDirection = isForward and (dotProduct > 0.3) or (not isForward and dotProduct < -0.3)

            if isValidDirection then
                local dist = (obj.Position - root.Position).Magnitude
                if dist < minDistance then
                    minDistance = dist
                    bestGate = obj
                end
            end
        end
    end
    return bestGate
end

local function startSmartFly(targetGate)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not targetGate then return end

    targetGate.CanCollide = false -- فتح الحاجز

    -- تثبيت حديدي (صنم)
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 50000
    bg.CFrame = root.CFrame
    bg.Parent = root

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0,0,0)
    bv.Parent = root

    -- حركة Tween بسرعة 100
    local dist = (targetGate.Position - root.Position).Magnitude
    local tInfo = TweenInfo.new(dist/100, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, tInfo, {CFrame = CFrame.new(targetGate.Position, targetGate.Position + root.CFrame.LookVector)})
    
    tween:Play()
    tween.Completed:Connect(function()
        bg:Destroy()
        bv:Destroy()
    end)
end

-- ربط الأزرار
openBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:find("VIP") then v.CanCollide = false v.Transparency = 0.5 end
    end
end)

forwardBtn.MouseButton1Click:Connect(function()
    local gate = findGateByDirection(true)
    if gate then startSmartFly(gate) end
end)

backwardBtn.MouseButton1Click:Connect(function()
    local gate = findGateByDirection(false)
    if gate then startSmartFly(gate) end
end)
