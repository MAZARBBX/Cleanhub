--// CLEANHUB UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "CleanHubUI"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 350)
Main.Position = UDim2.new(0.5, -150, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "CLEAN HUB"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 26
Title.TextColor3 = Color3.fromRGB(255, 255, 255)

local UIList = Instance.new("UIListLayout", Main)
UIList.Padding = UDim.new(0, 6)
UIList.FillDirection = Enum.FillDirection.Vertical
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.SortOrder = Enum.SortOrder.LayoutOrder

local function MakeButton(txt, callback)
    local B = Instance.new("TextButton", Main)
    B.Size = UDim2.new(0.9, 0, 0, 36)
    B.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    B.Text = txt
    B.Font = Enum.Font.GothamBold
    B.TextSize = 18
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.MouseButton1Click:Connect(callback)
    return B
end

MakeButton("Speed Toggle (Q)", function()
    speedMode = not speedMode
end)

MakeButton("Lagger Toggle (R)", function()
    laggerToggled = not laggerToggled
end)

MakeButton("Auto Steal", function()
    Steal.AutoStealEnabled = not Steal.AutoStealEnabled
    if Steal.AutoStealEnabled then startAutoSteal() else stopAutoSteal() end
end)

MakeButton("ESP Toggle", function()
    if PlayerESP.enabled then stopPlayerESP() else startPlayerESP() end
end)

MakeButton("Inf Jump", function()
    infJumpEnabled = not infJumpEnabled
end)

MakeButton("Anti-Ragdoll", function()
    antiRagdollEnabled = not antiRagdollEnabled
    if antiRagdollEnabled then startAntiRagdoll() else stopAntiRagdoll() end
end)

MakeButton("Auto Bat (E)", function()
    autoBatEnabled = not autoBatEnabled
end)

MakeButton("Drop Brainrot (X)", function()
    runDrop()
end)

MakeButton("TP Floor (F)", function()
    runTPFloor()
end)

MakeButton("Hide UI (CTRL)", function()
    Main.Visible = not Main.Visible
end)
