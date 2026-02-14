local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- [1] تنظيف النسخ القديمة
if game.CoreGui:FindFirstChild("N6O_Mobile_Edition") then 
    game.CoreGui.N6O_Mobile_Edition:Destroy() 
end

local mainGui = Instance.new("ScreenGui")
mainGui.Name = "N6O_Mobile_Edition"
mainGui.Parent = game.CoreGui
mainGui.ResetOnSpawn = false 

-- [2] الزر الدائري N6O (يدعم السحب واللمس)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 65, 0, 65) 
toggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
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

-- [3] نظام السحب المتطور (Drag System)
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    -- تحريك الزر بنعومة
    TweenService:Create(toggleBtn, TweenInfo.new(0.1), {Position = newPos}):Play()
end

toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = toggleBtn.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

toggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- [4] اللوحة الرئيسية
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 180)
mainFrame.Position = UDim2.new(0.5, -140, 0.4, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
mainFrame.Visible = false 
mainFrame.Parent = mainGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(255, 215, 0)

-- دالة صنع الأزرار (تقدم / رجوع)
local function createBtn(name, pos, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, (name:find("فتح") and 240 or 115), 0, 45)
    b.Position = pos
    b.BackgroundColor3 = color
    b.Text = name
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 15
    b.Parent = mainFrame
    Instance.new("UICorner", b)
    return b
end

local openBtn = createBtn("🔓 فتح VIP & +VIP", UDim2.new(0.5, -120, 0.2, 0), Color3.fromRGB(50, 50, 100))
local forwardBtn = createBtn("تقدم", UDim2.new(0.06, 0, 0.6, 0), Color3.fromRGB(0, 100, 50))
local backwardBtn = createBtn("رجوع", UDim2.new(0.53, 0, 0.6, 0), Color3.fromRGB(120, 0, 0))

-- [5] الوظائف البرمجية
toggleBtn.MouseButton1Click:Connect(function()
    -- إذا كان السحب بسيط نفتح القائمة، لو سحب طويل ما تفتح (اختياري)
    mainFrame.Visible = not mainFrame.Visible
end)

local function startFly(target)
    if not target or not player.Character then return end
    local root = player.Character.HumanoidRootPart
    local noclip = RunService.Stepped:Connect(function()
        for _, v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end)
    
    local dist = (target.Position - root.Position).Magnitude
    local tween = TweenService:Create(root, TweenInfo.new(dist/500, Enum.EasingStyle.Linear), {CFrame = target.CFrame * CFrame.new(0, 5, 0)})
    tween:Play()
    tween.Completed:Connect(function()
        noclip:Disconnect()
        for _, v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
    end)
end

local function findGate(isFwd)
    local root = player.Character.HumanoidRootPart
    local best, dist = nil, 1000
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name:find("VIP") or v.Name:find("Gate")) then
            local dot = root.CFrame.LookVector:Dot((v.Position - root.Position).Unit)
            if (isFwd and dot > 0) or (not isFwd and dot < 0) then
                local d = (v.Position - root.Position).Magnitude
                if d < dist and d > 10 then dist = d; best = v end
            end
        end
    end
    return best
end

forwardBtn.MouseButton1Click:Connect(function() startFly(findGate(true)) end)
backwardBtn.MouseButton1Click:Connect(function() startFly(findGate(false)) end)
openBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name:find("VIP") or v.Name:find("+")) then
            v.CanCollide = false; v.Transparency = 0.5
        end
    end
end)
