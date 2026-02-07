local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 1. الواجهة (نفس تصميمك المفضل)
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "AbuQaht_Smart_VIP"
mainGui.Parent = player:WaitForChild("PlayerGui")
mainGui.ResetOnSpawn = false 

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 70, 0, 70) 
toggleBtn.Position = UDim2.new(0.02, 0, 0.02, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
toggleBtn.Text = "ابو قحط"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = mainGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 180)
mainFrame.Position = UDim2.new(0.5, -160, 0.4, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.Visible = false 
mainFrame.Parent = mainGui
Instance.new("UICorner", mainFrame)
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(255, 215, 0)

local function createBtn(name, pos, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, (name:find("فتح") and 280 or 135), 0, 50)
    b.Position = pos
    b.BackgroundColor3 = color
    b.Text = name
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.Parent = mainFrame
    Instance.new("UICorner", b)
    return b
end

local openBtn = createBtn("🔓 فتح VIP & +VIP", UDim2.new(0.5, -140, 0.25, 0), Color3.fromRGB(90, 80, 200))
local forwardBtn = createBtn("▶️ تقدم (500)", UDim2.new(0.06, 0, 0.62, 0), Color3.fromRGB(0, 150, 0))
local backwardBtn = createBtn("◀️ رجوع (500)", UDim2.new(0.51, 0, 0.62, 0), Color3.fromRGB(180, 0, 0))

-- 2. كود الحركة الذكي (يفتح الاختراق ويقفله)
local function startFly(target)
    if not target or not player.Character then return end
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- [تشغيل الاختراق] أول ما تبدأ الحركة
    local noclipEvent
    noclipEvent = RunService.Stepped:Connect(function()
        if player.Character then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)
    
    -- تثبيت "صنم"
    local bg = Instance.new("BodyGyro", root)
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.CFrame = root.CFrame
    local bv = Instance.new("BodyVelocity", root)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0,0,0)
    
    local dist = (target.Position - root.Position).Magnitude
    
    -- الانتقال بسرعة 500
    local tween = TweenService:Create(root, TweenInfo.new(dist/500, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(target.Position + (root.CFrame.LookVector * 7), target.Position + root.CFrame.LookVector * 10)
    })
    
    tween:Play()
    
    -- [إيقاف الاختراق] فور الوصول للهدف
    tween.Completed:Connect(function()
        if noclipEvent then noclipEvent:Disconnect() end -- هنا فصلنا الاختراق
        bg:Destroy()
        bv:Destroy()
        
        -- إرجاع التصادم للأجزاء الأساسية فوراً عشان ما تطيح من الأرضية
        if player.Character then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
        root.Velocity = Vector3.new(0,0,0) -- إيقاف مفاجئ
    end)
end

-- وظيفة البحث عن البوابات
local function getGate(isFwd)
    local root = player.Character.HumanoidRootPart
    local best, minDist = nil, math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name:find("VIP") or v.Name:find("+") or v.Name:find("Gate")) then
            local dir = (v.Position - root.Position).Unit
            local dot = root.CFrame.LookVector:Dot(dir)
            if (isFwd and dot > 0.5) or (not isFwd and dot < -0.5) then
                local d = (v.Position - root.Position).Magnitude
                if d < minDist and d > 10 then 
                    minDist = d
                    best = v
                end
            end
        end
    end
    return best
end

-- 3. تفعيل الأزرار
toggleBtn.MouseButton1Click:Connect(function() mainFrame.Visible = not mainFrame.Visible end)
forwardBtn.MouseButton1Click:Connect(function() startFly(getGate(true)) end)
backwardBtn.MouseButton1Click:Connect(function() startFly(getGate(false)) end)

openBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name:find("VIP") or v.Name:find("+")) then
            v.CanCollide = false
            v.Transparency = 0.5
        end
    end
end)
