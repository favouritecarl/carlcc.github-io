local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- UI Framework
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/cat"))()
local Window = Library:CreateWindow("cattoware (Mobile)", Vector2.new(350, 450), Enum.KeyCode.RightControl)

-- === Aiming Tab ===
local AimingTab = Window:CreateTab("Aiming")

-- Camlock Sector (left)
local camlockSector = AimingTab:CreateSector("Camlock", "left")

local camlockEnabled = false
local aimPrediction = 0.165
local currentTarget = nil
local ESPBox = nil
local camlockGuiCreated = false

camlockSector:AddTextbox("Prediction", tostring(aimPrediction), function(val)
    local num = tonumber(val)
    if num then aimPrediction = num end
end)

camlockSector:AddButton("Spawn Camlock", function()
    if camlockGuiCreated then return end
    camlockGuiCreated = true

    local gui = Instance.new("ScreenGui")
    gui.Name = "CarlGui"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local main = Instance.new("Frame", gui)
    main.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    main.Size = UDim2.new(0, 180, 0, 60)
    main.Position = UDim2.new(0.5, -90, 0.1, 0)
    main.Active = true
    main.Draggable = true
    main.ClipsDescendants = true

    Instance.new("UICorner", main)
    local stroke = Instance.new("UIStroke", main)
    stroke.Thickness = 2

    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0, 150, 0, 36)
    btn.Position = UDim2.new(0.5, -75, 0.3, 0)
    btn.Text = "Carl OFF"
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", btn)

    local function FindNearestEnemy()
        local closest, shortestDist = nil, math.huge
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local h = p.Character:FindFirstChild("Humanoid")
                if h and h.Health > 0 then
                    local sp, on = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                    if on then
                        local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if dist < shortestDist then
                            closest = p.Character.HumanoidRootPart
                            shortestDist = dist
                        end
                    end
                end
            end
        end
        return closest
    end

    RunService.Heartbeat:Connect(function()
        if camlockEnabled and currentTarget then
            if currentTarget.Parent and currentTarget.Parent:FindFirstChild("HumanoidRootPart") then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, currentTarget.Position + currentTarget.Velocity * aimPrediction)
            else
                currentTarget = nil
            end
        end
    end)

    btn.MouseButton1Click:Connect(function()
        camlockEnabled = not camlockEnabled
        btn.Text = camlockEnabled and "Carl ON" or "Carl OFF"

        if not camlockEnabled then
            if ESPBox then ESPBox:Destroy(); ESPBox = nil end
            currentTarget = nil
        else
            currentTarget = FindNearestEnemy()
            if currentTarget then
                local tgt = Players:GetPlayerFromCharacter(currentTarget.Parent)
                if tgt then
                    ESPBox = Instance.new("BillboardGui", CoreGui)
                    ESPBox.Name = "ESP"
                    ESPBox.AlwaysOnTop = true
                    ESPBox.Size = UDim2.new(4,0,5.5,0)
                    ESPBox.Adornee = currentTarget
                    local frm=Instance.new("Frame",ESPBox)
                    frm.Size=UDim2.new(1,0,1,0)
                    frm.BackgroundColor3=Color3.fromRGB(0,255,0)
                    frm.BackgroundTransparency=0.5
                    frm.BorderSizePixel=0
                end
            end
        end
    end)

    coroutine.wrap(function()
        local h=120
        while gui.Parent do
            local c=Color3.fromHSV(h/360,1,1)
            stroke.Color,c=hue and hue or stroke.Color,c
            btn.TextColor3=c
            h=(h+1)%360
            wait(0.05)
        end
    end)()
end)

local targetSector = AimingTab:CreateSector("Target", "left")

-- === Visual Tab ===
local VisualTab = Window:CreateTab("Visual")
local visSec = VisualTab:CreateSector("ESP Options", "left")

local espEnabled, showName, showHealth, showDistance = false, true, true, true
local playerESP = {}

local function newPart(sz,cf)
    local p=Instance.new("Part")
    p.Size, p.CFrame, p.Anchored, p.CanCollide, p.Material = sz, cf, true, false, Enum.Material.Neon
    p.Color=Color3.new(1,1,1); p.CastShadow=false; p.Parent=CoreGui
    return p
end

local function makeBox(cpart)
    local s=Vector3.new(2,5,1)/2; local cf=cpart.CFrame; local tArray={}
    table.insert(tArray,newPart(Vector3.new(2,0.05,0.05),cf*CFrame.new(0,-s.Y,-s.Z)))
    table.insert(tArray,newPart(Vector3.new(0.05,0.05,2),cf*CFrame.new(-s.X,-s.Y,0)))
    table.insert(tArray,newPart(Vector3.new(2,0.05,0.05),cf*CFrame.new(0,-s.Y,s.Z)))
    table.insert(tArray,newPart(Vector3.new(0.05,0.05,2),cf*CFrame.new(s.X,-s.Y,0)))
    table.insert(tArray,newPart(Vector3.new(2,0.05,0.05),cf*CFrame.new(0,s.Y,-s.Z)))
    table.insert(tArray,newPart(Vector3.new(0.05,0.05,2),cf*CFrame.new(-s.X,s.Y,0)))
    table.insert(tArray,newPart(Vector3.new(2,0.05,0.05),cf*CFrame.new(0,s.Y,s.Z)))
    table.insert(tArray,newPart(Vector3.new(0.05,0.05,2),cf*CFrame.new(s.X,s.Y,0)))
    table.insert(tArray,newPart(Vector3.new(0.05,2,0.05),cf*CFrame.new(-s.X,0,-s.Z)))
    table.insert(tArray,newPart(Vector3.new(0.05,2,0.05),cf*CFrame.new(s.X,0,-s.Z)))
    table.insert(tArray,newPart(Vector3.new(0.05,2,0.05),cf*CFrame.new(-s.X,0,s.Z)))
    table.insert(tArray,newPart(Vector3.new(0.05,2,0.05),cf*CFrame.new(s.X,0,s.Z)))
    return tArray
end

local function makeText(cpart, text, yoffset)
    local p=Instance.new("Part")
    p.Anchored, p.CanCollide, p.Transparency = true, false, 1
    p.Size, p.CFrame = Vector3.new(2,1,0.1), cpart.CFrame * CFrame.new(0,yoffset,0)
    p.Parent = CoreGui
    local gui=Instance.new("SurfaceGui",p)
    gui.Adornee, gui.Face, gui.AlwaysOnTop, gui.ClipsDescendants = p, Enum.NormalId.Top, true, false
    local lbl=Instance.new("TextLabel",gui)
    lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(1,0,1,0)
    lbl.Font, lbl.TextSize, lbl.TextColor3 = Enum.Font.SourceSans, 14, Color3.new(1,1,1)
    lbl.Text= text
    return p,lbl
end

visSec:AddToggle("Enable 3D ESP", false, function(s) espEnabled = s end)
visSec:AddToggle("Show Name", true, function(s) showName = s end)
visSec:AddToggle("Show Health", true, function(s) showHealth = s end)
visSec:AddToggle("Show Distance", true, function(s) showDistance = s end)

RunService.Heartbeat:Connect(function()
    if espEnabled then
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl~=LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") and pl.Character:FindFirstChild("Humanoid") then
                if not playerESP[pl] then
                    local hrp,h=pl.Character.HumanoidRootPart,pl.Character.Humanoid
                    local parts=makeBox(hrp)
                    local np,nl=makeText(hrp,pl.Name,3)
                    local hp,hl=makeText(hrp,"H:"..math.floor(h.Health),2.5)
                    local dp,dl=makeText(hrp,"",2)
                    playerESP[pl]={parts=parts,nameLbl=nl,healthLbl=hl,distLbl=dl,hum=h,hrp=hrp,np=np,hp=hp,dp=dp}
                end
                local d=playerESP[pl]; local cf,hum=d.hrp.CFrame,h=d.hum
                local s=Vector3.new(2,5,1)/2
                for i,part in ipairs(d.parts) do
                    local offs = {
                        Vector3.new(0,-s.Y,-s.Z),Vector3.new(-s.X,-s.Y,0),
                        Vector3.new(0,-s.Y,s.Z),Vector3.new(s.X,-s.Y,0),
                        Vector3.new(0,s.Y,-s.Z),Vector3.new(-s.X,s.Y,0),
                        Vector3.new(0,s.Y,s.Z),Vector3.new(s.X,s.Y,0),
                        Vector3.new(-s.X,0,-s.Z),Vector3.new(s.X,0,-s.Z),
                        Vector3.new(-s.X,0,s.Z),Vector3.new(s.X,0,s.Z),
                    }
                    part.CFrame,part.Size = cf * CFrame.new(offs[i]),part.Size
                    part.Transparency=espEnabled and 0 or 1
                end
                d.np.CFrame = cf * CFrame.new(0,3,0)
                d.hp.CFrame = cf * CFrame.new(0,2.5,0)
                d.dp.CFrame = cf * CFrame.new(0,2,0)
                d.nameLbl.Text = showName and pl.Name or ""
                d.healthLbl.Text = showHealth and ("H:"..math.floor(h.Health)) or ""
                local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) 
                    and (LocalPlayer.Character.HumanoidRootPart.Position - cf.Position).Magnitude or 0
                d.distLbl.Text = showDistance and ("D:"..string.format("%.1f",dist)) or ""
            end
        end
    else
        for pl, data in pairs(playerESP) do
            for _,p in ipairs(data.parts) do p:Destroy() end
            data.np, data.hp, data.dp:Destroy()
            playerESP[pl]=nil
        end
    end
end)

-- === Misc Tab ===
local MiscTab = Window:CreateTab("misc")
local miscSector = MiscTab:CreateSector("Macro", "left")

miscSector:AddSlider("WalkSpeed",16,250,100,1,function(v)
    local c=LocalPlayer.Character
    if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed=v end
end)
