mm2_script.lua
-- MM2 Gelişmiş GUI Script (Silah Envantere Ekleme + M ile Menü Aç/Kapa)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- RemoteEvent (örnek isim, kendi oyundaki event ismine göre değiştir)
local GiveWeaponEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GiveWeapon")

-- UI Kütüphanesi (basit)
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "MM2Gui"
ScreenGui.Enabled = false  -- Başlangıçta gizli

local function createFrame()
    local frame = Instance.new("Frame", ScreenGui)
    frame.Size = UDim2.new(0, 300, 0, 650)
    frame.Position = UDim2.new(0, 10, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    return frame
end

local function createLabel(parent, text, pos)
    local label = Instance.new("TextLabel", parent)
    label.Text = text
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = pos
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    return label
end

local function createToggle(parent, text, pos, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.Position = pos
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Text = text
    label.Size = UDim2.new(0.75, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left

    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(0.25, 0, 1, 0)
    button.Position = UDim2.new(0.75, 0, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    button.TextColor3 = Color3.new(1,1,1)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 16
    button.Text = "OFF"

    local toggled = false
    button.MouseButton1Click:Connect(function()
        toggled = not toggled
        button.Text = toggled and "ON" or "OFF"
        callback(toggled)
    end)

    return frame
end

local function createButton(parent, text, pos, callback)
    local button = Instance.new("TextButton", parent)
    button.Text = text
    button.Size = UDim2.new(1, -20, 0, 30)
    button.Position = pos
    button.BackgroundColor3 = Color3.fromRGB(70,70,70)
    button.TextColor3 = Color3.new(1,1,1)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 16
    button.MouseButton1Click:Connect(callback)
    return button
end

local function createSlider(parent, text, pos, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.Position = pos
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Text = text .. ": " .. tostring(default)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left

    local sliderFrame = Instance.new("Frame", frame)
    sliderFrame.Size = UDim2.new(1, 0, 0, 20)
    sliderFrame.Position = UDim2.new(0, 0, 0, 20)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)

    local slider = Instance.new("TextButton", sliderFrame)
    slider.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    slider.BackgroundColor3 = Color3.fromRGB(100,100,255)
    slider.Text = ""

    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    sliderFrame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
            local percent = pos / sliderFrame.AbsoluteSize.X
            slider.Size = UDim2.new(percent, 0, 1, 0)
            local value = math.floor(min + (max - min) * percent)
            label.Text = text .. ": " .. tostring(value)
            callback(value)
        end
    end)

    return frame
end

local function createTextbox(parent, placeholder, pos, callback)
    local textbox = Instance.new("TextBox", parent)
    textbox.Size = UDim2.new(1, -20, 0, 30)
    textbox.Position = pos
    textbox.PlaceholderText = placeholder
    textbox.ClearTextOnFocus = false
    textbox.BackgroundColor3 = Color3.fromRGB(50,50,50)
    textbox.TextColor3 = Color3.new(1,1,1)
    textbox.Font = Enum.Font.SourceSansBold
    textbox.TextSize = 16

    textbox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            callback(textbox.Text)
        end
    end)
    return textbox
end

local frame = createFrame()
frame.Parent = ScreenGui

createLabel(frame, "MM2 Gelişmiş Script Menü", UDim2.new(0, 10, 0, 5))

createLabel(frame, "Karakter Ayarları", UDim2.new(0,10,0,35))
local walkSpeed = 16
local jumpPower = 50
createSlider(frame, "WalkSpeed", UDim2.new(0,10,0,60), 16, 100, walkSpeed, function(value)
    walkSpeed = value
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = walkSpeed
    end
end)
createSlider(frame, "JumpPower", UDim2.new(0,10,0,105), 50, 150, jumpPower, function(value)
    jumpPower = value
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = jumpPower
    end
end)

local autoKillEnabled = false
local espMurdererEnabled = false
local killAllKey = Enum.KeyCode.B
local espSheriffEnabled = false
local gunEspEnabled = false
local autoWinEnabled = false
local weaponName = ""
local selectedRole = nil

createLabel(frame, "Sheriff Ayarları", UDim2.new(0, 10, 0, 150))
createToggle(frame, "Auto Kill Murderer", UDim2.new(0, 10, 0, 175), function(state)
    autoKillEnabled = state
end)
createToggle(frame, "ESP to Murderer", UDim2.new(0, 10, 0, 210), function(state)
    espMurdererEnabled = state
end)

createLabel(frame, "Murderer Ayarları", UDim2.new(0, 10, 0, 245))
createButton(frame, "Kill All (B Tuşu)", UDim2.new(0, 10, 0, 270), function()
    if player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife") then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") then
                pcall(function()
                    ReplicatedStorage.Remotes.MurderKill:FireServer(plr.Character)
                end)
                wait(0.2)
            end
        end
    end
end)

createLabel(frame, "ESP Ayarları", UDim2.new(0, 10, 0, 305))
createToggle(frame, "ESP to Sheriff", UDim2.new(0, 10, 0, 330), function(state)
    espSheriffEnabled = state
end)
createToggle(frame, "Gun ESP", UDim2.new(0, 10, 0, 365), function(state)
    gunEspEnabled = state
end)
createButton(frame, "Teleport to Gun", UDim2.new(0, 10, 0, 400), function()
    -- Silahı bulunup ışınlanacak
    for _, item in pairs(workspace:GetChildren()) do
        if item:IsA("Tool") and item.Name == "Gun" and item:FindFirstChild("Handle") then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = item.Handle.CFrame + Vector3.new(0,3,0)
                break
            end
        end
    end
end)

createLabel(frame, "Silah Bulucu", UDim2.new(0, 10, 0, 435))
local weaponTextBox = createTextbox(frame, "Silah ismini yaz ve Enter", UDim2.new(0, 10, 0, 460), function(text)
    weaponName = text
end)
createButton(frame, "Get Weapon (Envantere Ekle)", UDim2.new(0, 10, 0, 495), function()
    if weaponName ~= "" then
        -- Serverdan silah iste
        pcall(function()
            GiveWeaponEvent:FireServer(weaponName)
        end)
    end
end)

createLabel(frame, "Oyun Ayarları", UDim2.new(0, 10, 0, 530))
createToggle(frame, "Auto Win", UDim2.new(0, 10, 0, 555), function(state)
    autoWinEnabled = state
end)

local roleOptions = {"Sheriff", "Murderer", "Innocent"}
local selectedRoleIndex = 1

local roleLabel = createLabel(frame, "Sonraki Tur Rolü: "..roleOptions[selectedRoleIndex], UDim2.new(0, 10, 0, 590))
local roleButton = createButton(frame, "Rol Değiştir", UDim2.new(0, 10, 0, 620), function()
    selectedRoleIndex = selectedRoleIndex + 1
    if selectedRoleIndex > #roleOptions then selectedRoleIndex = 1 end
    roleLabel.Text = "Sonraki Tur Rolü: "..roleOptions[selectedRoleIndex]
    selectedRole = roleOptions[selectedRoleIndex]
end)

-- ESP fonksiyonları (basit)

local function addESPToCharacter(plr, color)
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        if not plr.Character:FindFirstChild("ESPBox") then
            local box = Instance.new("BoxHandleAdornment", plr.Character.HumanoidRootPart)
            box.Name = "ESPBox"
            box.Adornee = plr.Character.HumanoidRootPart
            box.AlwaysOnTop = true
            box.ZIndex = 10
            box.Size = Vector3.new(4, 5, 2)
            box.Color3 = color
        end
    end
end

local function removeESP(plr)
    if plr.Character and plr.Character:FindFirstChild("ESPBox") then
        plr.Character.ESPBox:Destroy()
    end
end

local function gunESP()
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Tool") and (v.Name == "Gun" or v.Name == "Knife") then
            if not v:FindFirstChild("ESP") and v:FindFirstChild("Handle") then
                local billboard = Instance.new("BillboardGui", v)
                billboard.Name = "ESP"
                billboard.Size = UDim2.new(0,100,0,40)
                billboard.AlwaysOnTop = true
                billboard.Adornee = v.Handle

                local label = Instance.new("TextLabel", billboard)
                label.Size = UDim2.new(1,0,1,0)
                label.BackgroundTransparency = 1
                label.Text = "🗡️ "..v.Name
                label.TextColor3 = Color3.new(1,1,0)
                label.TextStrokeTransparency = 0
                label.Font = Enum.Font.SourceSansBold
                label.TextSize = 18
            end
        end
    end
end

-- Kill All tuşu (B) ile

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == killAllKey then
        if player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife") then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    pcall(function()
                        ReplicatedStorage.Remotes.MurderKill:FireServer(plr.Character)
                    end)
                    wait(0.2)
                end
            end
        end
    elseif input.KeyCode == Enum.KeyCode.M then
        -- Menü aç/kapa
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- RenderStepped döngüsü

game:GetService("RunService").RenderStepped:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = walkSpeed
        player.Character.Humanoid.JumpPower = jumpPower
    end

    -- Auto Kill Murderer (Sheriff içindir)
    if autoKillEnabled then
        local role = player:GetAttribute("Role") or "Innocent"
        if role == "Sheriff" then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr:GetAttribute("Role") == "Murderer" and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                        ReplicatedStorage.Remotes.Shoot:FireServer(plr.Character.HumanoidRootPart.Position)
                    end)
                end
            end
        end
    end

    -- ESP Murderer
    for _, plr in pairs(Players:GetPlayers()) do
        if espMurdererEnabled then
            if plr:GetAttribute("Role") == "Murderer" then
                addESPToCharacter(plr, Color3.fromRGB(255,0,0))
            else
                removeESP(plr)
            end
        end
        if espSheriffEnabled then
            if plr:GetAttribute("Role") == "Sheriff" then
                addESPToCharacter(plr, Color3.fromRGB(0,0,255))
            else
                removeESP(plr)
            end
        end
    end

    -- Gun ESP
    if gunEspEnabled then
        gunESP()
    else
        -- Silah ESP temizle
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Tool") and v:FindFirstChild("ESP") then
                v.ESP:Destroy()
            end
        end
    end

    -- Auto Win
    if autoWinEnabled then
        pcall(function()
            ReplicatedStorage.Remotes.AutoWin:FireServer()
        end)
    end
end)
