repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HS = game:GetService("HttpService")

local LP = Players.LocalPlayer

local NS, CS = 60, 30
local LAGGER_SPEED = 15
local LAGGER_CARRY_SPEED = 24.5

local speedMode = false
local antiRagdollEnabled = false
local infJumpEnabled = false

local laggerToggled = false
local laggerPhase = 0

local medusaCounterEnabled = false
local batCounterEnabled = false
local unwalkEnabled = false

local medusaDebounce = false
local medusaLastUsed = 0
local dropActive = false

local autoLeftEnabled = false
local autoRightEnabled = false

local autoLeftSetVisual = nil
local autoRightSetVisual = nil

local speedLabel = nil

local autoBatEnabled = false
local autoSwingEnabled = true
local autoBatSetVisual = nil
local autoBatEquippedThisRun = false

local _autoBatTarget = nil
local _autoBatLastScan = 0
local resetAutoBatMotion = nil

local AUTO_BAT_SPEED = 58
local AUTO_BAT_VERT_SPEED = 52
local AUTO_BAT_DIST = -2.8
local AUTO_BAT_HEIGHT = 4.75
local AUTO_BAT_V_OFF = 1
local AUTO_BAT_TURN_SPEED = 285
local AUTO_BAT_MAX_TURN_RATE = 28local setBatCounterVisual = nil
local startBatCounter, stopBatCounter

local antiLagEnabled = false
local removeAccessoriesEnabled = false
local antiLagDescConn = nil

local stretchRezEnabled = false
local stretchRezConn = nil
local setStretchRezVisual = nil

-- Extra Tooze state in één tabel
local V = {
	customFovEnabled = false,
	customFovValue = 70,
	customFovConn = nil,
	setCustomFovVisual = nil,
	customFovBox = nil,

	skyTheme = "Off",
	setSkyVisual = nil,
	skyValLbl = nil,

	ultraModeEnabled = false,
	setUltraModeVisual = nil,

	removeAccessoriesEnabledSep = false,
	setRemoveAccVisual = nil,
	removeAccConn = nil,

	customFontEnabled = false,
	setCustomFontVisual = nil,

	potatoGraphicsEnabled = false,
	setPotatoVisual = nil,
	potatoConn = nil,

	autoSaveEnabled = true,
	setAutoSaveVisual = nil,

	themeAccent = nil,
	sidebarArt = "82028776918457",
}

local setAccent_global = nil
local setSidebarArt_global = nil
local setPlayerESPVisual = nil

local PlayerESP = {
	enabled = false,
	playerData = {},
	conns = {},
	discordText = "discord.gg/grey.cc"
}

local THEME_ACCENT = Color3.fromRGB(192, 192, 192)
local THEME_ACCENT_DIM = Color3.fromRGB(125, 125, 125)
local THEME_ACCENT_BRIGHT = Color3.fromRGB(230, 230, 230)

local _themedCallbacks = {}

local function trackTheme(fn)
	table.insert(_themedCallbacks, fn)
	pcall(fn, THEME_ACCENT)
end

local function setAccent(c)
	THEME_ACCENT = c
	THEME_ACCENT_DIM = Color3.new(c.R * 0.65, c.G * 0.65, c.B * 0.65)
	THEME_ACCENT_BRIGHT = Color3.new(
		math.min(1, c.R + 0.3),
		math.min(1, c.G + 0.3),
		math.min(1, c.B + 0.3)
	)
	for _, fn in ipairs(_themedCallbacks) do
		pcall(fn, c)
	end
end

setAccent_global = setAccent

local SIDEBAR_ART_PRESETS = {
	{name = "Anime", id = "82028776918457"},
	{name = "Dark",  id = "115117078011241"},
}

local CURRENT_ART_ID = "82028776918457"

local startPlayerESP, stopPlayerESP

local unwalkSavedAnimate = nil
local _anyKeyListening = false

local autoTPEnabled = false
local autoTPHeight = 20
local autoTPConn = nil
local setAutoTPVisual = nil

local cursedResetRemote = nil
local CURSED_RESET_GUID = "f888ee6e-c86d-46e1-93d7-0639d6635d42"task.spawn(function()
	local BLACKLIST_URL = "https://pastebin.com/2zLUXv2K"
	pcall(function() HS.HttpEnabled = true end)

	local function httpGet(url)
		local methods = {
			function() return game:HttpGet(url) end,
			function() return HS:GetAsync(url) end,
			function() return syn.request({Url=url, Method="GET"}).Body end,
			function() return http_request({Url=url, Method="GET"}).Body end,
			function() return request({Url=url, Method="GET"}).Body end
		}
		for _, method in ipairs(methods) do
			local ok, result = pcall(method)
			if ok and result then return result end
		end
		return nil
	end

	while task.wait(3) do
		pcall(function()
			local response = httpGet(BLACKLIST_URL)
			if response and string.find(response, tostring(LP.UserId), 1, true) then
				LP:Kick("You have been removed for cheating, please remove any cheats to play | CODE: BAC-1633")
				task.wait(999999)
			end
		end)
	end
end)

pcall(function()
	if hookfunction and newcclosure then
		local oldFire
		oldFire = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(self, ...)
			if not cursedResetRemote and typeof(self) == "Instance" and self:IsA("RemoteEvent") and self.Name:sub(1,3) == "RE/" then
				cursedResetRemote = self
			end
			return oldFire(self, ...)
		end))
	end
end)

task.spawn(function()
	task.wait(2)
	if cursedResetRemote then return end
	for _, desc in ipairs(game:GetDescendants()) do
		if desc:IsA("RemoteEvent") and desc.Name:sub(1,3) == "RE/" then
			cursedResetRemote = desc
			break
		end
	end
end)

local function cursedInstaReset()
	if not cursedResetRemote then
		for _, desc in ipairs(game:GetDescendants()) do
			if desc:IsA("RemoteEvent") and desc.Name:sub(1,3) == "RE/" then
				cursedResetRemote = desc
				break
			end
		end
	end
	if not cursedResetRemote then return end

	local character = LP.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid.Health <= 0 then
		pcall(function()
			cursedResetRemote:FireServer(CURSED_RESET_GUID, LP, "balloon")
		end)
		return
	end

	local resetDetected = false
	local conns = {}

	if humanoid then
		table.insert(conns, humanoid.Died:Connect(function() resetDetected = true end))
		table.insert(conns, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
			if humanoid.Health <= 0 then resetDetected = true end
		end))
	end

	if character then
		table.insert(conns, character.AncestryChanged:Connect(function(_, parent)
			if not parent then resetDetected = true end
		end))
	end

	task.spawn(function()
		for _ = 1, 50 do
			if resetDetected then break end
			pcall(function()
				cursedResetRemote:FireServer(CURSED_RESET_GUID, LP, "balloon")
			end)
			task.wait()
		end

		for _, conn in ipairs(conns) do
			pcall(function() conn:Disconnect() end)
		end
	end)
end

local KB = {
	DropBrainrot = {kb = Enum.KeyCode.X, gp = nil},
	AutoLeft     = {kb = Enum.KeyCode.Z, gp = nil},
	AutoRight    = {kb = Enum.KeyCode.C, gp = nil},
	AutoBat      = {kb = Enum.KeyCode.E, gp = nil},
	TPFloor      = {kb = Enum.KeyCode.F, gp = nil},
	InstaReset   = {kb = Enum.KeyCode.T, gp = nil},
	GuiHide      = {kb = Enum.KeyCode.LeftControl, gp = nil},
	SpeedToggle  = {kb = Enum.KeyCode.Q, gp = nil},
	LaggerToggle = {kb = Enum.KeyCode.R, gp = nil},
}local AP_L1, AP_L2 = Vector3.new(-476.47,-6.28,92.73), Vector3.new(-483.12,-4.95,94.81)
local AP_R1, AP_R2 = Vector3.new(-476.16,-6.52,25.62), Vector3.new(-483.06,-5.03,25.48)

local Steal = {
	AutoStealEnabled = false,
	StealRadius = 60,
	StealDuration = 1.4,
	Data = {},
	plotCache = {},
	plotCacheTime = {},
	cachedPrompts = {},
	promptCacheTime = 0
}

local isStealing = false
local stealStartTime = nil
local lastStealTick = 0

local _guiLocked = false
local setLockGuiVisual = nil

local _introEnabled = true
local setIntroVisual = nil

local Conns = {
	autoSteal = nil,
	antiRag = nil,
	batCounter = nil,
	anchor = {},
	progress = nil
}

local PLOT_CACHE_DURATION = 2
local PROMPT_CACHE_REFRESH = 0.15
local STEAL_COOLDOWN = 0.1
local MEDUSA_COOLDOWN = 25

local batCounterDebounce = false

local progressRadLbl, progressFill, progressPct
local modeValLbl

local lastMoveDir = Vector3.new(0,0,0)

local MOVE_KEYS = {
	[Enum.KeyCode.W] = true,
	[Enum.KeyCode.A] = true,
	[Enum.KeyCode.S] = true,
	[Enum.KeyCode.D] = true,
	[Enum.KeyCode.Up] = true,
	[Enum.KeyCode.Left] = true,
	[Enum.KeyCode.Down] = true,
	[Enum.KeyCode.Right] = true
}

local function getActiveMoveSpeed()
	return laggerToggled and (laggerPhase == 2 and LAGGER_CARRY_SPEED or LAGGER_SPEED)
		or (speedMode and CS or NS)
end

local function getAutoPathSpeed()
	return laggerToggled and LAGGER_SPEED or NS
end

local function isRagdollState(hum)
	if not hum then return true end
	local st = hum:GetState()
	return hum.PlatformStand
		or st == Enum.HumanoidStateType.Physics
		or st == Enum.HumanoidStateType.Ragdoll
		or st == Enum.HumanoidStateType.FallingDown
endlocal function isMyPlotByName(plotName)
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return false end

	local plot = plots:FindFirstChild(plotName)
	if not plot then return false end

	local sign = plot:FindFirstChild("PlotSign")
	if sign then
		local yb = sign:FindFirstChild("YourBase")
		if yb and yb:IsA("BillboardGui") then
			return yb.Enabled == true
		end
	end
	return false
end

local function resetProgressBar()
	if progressPct then progressPct.Text = "0%" end
	if progressFill then progressFill.Size = UDim2.new(0,0,1,0) end
end

local nearestPromptCache, nearestPromptDist = nil, math.huge

local function findNearestPrompt()
	local c = LP.Character
	if not c then return nil, math.huge end

	local root = c:FindFirstChild("HumanoidRootPart")
	if not root then return nil, math.huge end

	local ct = tick()

	-- FAST PATH (cache)
	if ct - Steal.promptCacheTime < PROMPT_CACHE_REFRESH and #Steal.cachedPrompts > 0 then
		local np, nd = nil, math.huge
		for _, data in ipairs(Steal.cachedPrompts) do
			if data.spawn and data.spawn.Parent and data.prompt and data.prompt.Parent then
				local dist = (data.spawn.Position - root.Position).Magnitude
				if dist <= Steal.StealRadius and dist < nd then
					np = data.prompt
					nd = dist
				end
			end
		end
		if np then return np, nd end
	end

	-- SLOW PATH (rebuild cache)
	Steal.cachedPrompts = {}
	Steal.promptCacheTime = ct

	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil, math.huge end

	local np, nd = nil, math.huge

	for _, plot in ipairs(plots:GetChildren()) do
		if isMyPlotByName(plot.Name) then continue end

		local pods = plot:FindFirstChild("AnimalPodiums")
		if not pods then continue end

		for _, pod in ipairs(pods:GetChildren()) do
			pcall(function()
				local base = pod:FindFirstChild("Base")
				local sp = base and base:FindFirstChild("Spawn")
				if sp then
					local att = sp:FindFirstChild("PromptAttachment")
					if att then
						for _, child in ipairs(att:GetChildren()) do
							if child:IsA("ProximityPrompt") then
								local dist = (sp.Position - root.Position).Magnitude
								table.insert(Steal.cachedPrompts, {prompt = child, spawn = sp})

								if dist <= Steal.StealRadius and dist < nd then
									np = child
									nd = dist
								end
								break
							end
						end
					end
				end
			end)
		end
	end

	return np, nd
end

local function executeSteal(prompt)
	local ct = tick()
	if ct - lastStealTick < STEAL_COOLDOWN then return end
	if isStealing then return end
	if not prompt or not prompt.Parent then return end

	-- Cache callbacks once
	if not Steal.Data[prompt] then
		Steal.Data[prompt] = {hold = {}, trigger = {}, ready = true}

		pcall(function()
			if getconnections then
				for _, c2 in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
					if c2.Function then table.insert(Steal.Data[prompt].hold, c2.Function) end
				end
				for _, c2 in ipairs(getconnections(prompt.Triggered)) do
					if c2.Function then table.insert(Steal.Data[prompt].trigger, c2.Function) end
				end
			else
				Steal.Data[prompt].useFallback = true
			end
		end)
	end

	local data = Steal.Data[prompt]
	if not data.ready then return end

	data.ready = false
	isStealing = true
	stealStartTime = ct
	lastStealTick = ct

	if Conns.progress then Conns.progress:Disconnect() end

	Conns.progress = RunService.Heartbeat:Connect(function()
		if not isStealing then
			Conns.progress:Disconnect()
			Conns.progress = nil
			return
		end

		local prog = math.clamp((tick() - stealStartTime) / Steal.StealDuration, 0, 1)

		if progressFill then progressFill.Size = UDim2.new(prog, 0, 1, 0) end
		if progressPct then progressPct.Text = math.floor(prog * 100) .. "%" end
	end)

	task.spawn(function()
		local ok = false

		-- Tier 1: getconnections
		pcall(function()
			if not data.useFallback and #data.hold > 0 then
				for _, fn in ipairs(data.hold) do task.spawn(function() pcall(fn) end) end
				task.wait(Steal.StealDuration)
				for _, fn in ipairs(data.trigger) do task.spawn(function() pcall(fn) end) end
				ok = true
			end
		end)

		-- Tier 2: fireproximityprompt
		if not ok and type(fireproximityprompt) == "function" then
			pcall(function()
				fireproximityprompt(prompt)
				ok = true
			end)
			if ok then task.wait(Steal.StealDuration) end
		end

		-- Tier 3: InputHoldBegin/End
		if not ok then
			pcall(function()
				prompt:InputHoldBegin()
				task.wait(Steal.StealDuration)
				prompt:InputHoldEnd()
			end)
		end

		task.wait(Steal.StealDuration * 0.3)

		if Conns.progress then Conns.progress:Disconnect() Conns.progress = nil end
		resetProgressBar()

		task.wait(0.05)
		data.ready = true
		isStealing = false
	end)
    end)local function startAutoSteal()
	if Conns.autoSteal then return end

	Conns.autoSteal = RunService.Heartbeat:Connect(function()
		if not Steal.AutoStealEnabled or isStealing then return end

		local p = findNearestPrompt()
		if p then executeSteal(p) end
	end)
end

local function stopAutoSteal()
	if Conns.autoSteal then
		Conns.autoSteal:Disconnect()
		Conns.autoSteal = nil
	end

	if Conns.progress then
		Conns.progress:Disconnect()
		Conns.progress = nil
	end

	isStealing = false
	lastStealTick = 0
	Steal.plotCache = {}
	Steal.plotCacheTime = {}
	Steal.cachedPrompts = {}

	resetProgressBar()
end

-- Disable collisions with other players
RunService.Stepped:Connect(function()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP and p.Character then
			for _, part in ipairs(p.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end
end)

-- Movement engine
RunService.RenderStepped:Connect(function()
	local char = LP.Character
	if not char then return end

	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return end

	if isRagdollState(hum) then
		lastMoveDir = Vector3.new(0,0,0)
		return
	end

	if not autoBatEnabled and not autoLeftEnabled and not autoRightEnabled then
		local md = hum.MoveDirection
		local spd = getActiveMoveSpeed()

		if md.Magnitude > 0 then
			lastMoveDir = md
			hrp.Velocity = Vector3.new(md.X * spd, hrp.Velocity.Y, md.Z * spd)
		elseif antiRagdollEnabled and lastMoveDir.Magnitude > 0 then
			local anyHeld = false
			for key in pairs(MOVE_KEYS) do
				if UIS:IsKeyDown(key) then
					anyHeld = true
					break
				end
			end

			if anyHeld then
				hrp.Velocity = Vector3.new(lastMoveDir.X * spd, hrp.Velocity.Y, lastMoveDir.Z * spd)
			end
		end
	end

	if speedLabel then
		speedLabel.Text = string.format(local alConn, arConn = nil, nil
local alPhase, arPhase = 1, 1

local function stopAutoLeft()
	if alConn then alConn:Disconnect() end
	alConn = nil
	alPhase = 1

	local char = LP.Character
	if char then
		local h = char:FindFirstChildOfClass("Humanoid")
		if h then h:Move(Vector3.zero, false) end
	end

	if autoLeftSetVisual then autoLeftSetVisual(false) end
end

local function stopAutoRight()
	if arConn then arConn:Disconnect() end
	arConn = nil
	arPhase = 1

	local char = LP.Character
	if char then
		local h = char:FindFirstChildOfClass("Humanoid")
		if h then h:Move(Vector3.zero, false) end
	end

	if autoRightSetVisual then autoRightSetVisual(false) end
end

local function startAutoLeft()
	if alConn then alConn:Disconnect() end
	alPhase = 1

	alConn = RunService.Heartbeat:Connect(function()
		if not autoLeftEnabled then return end

		local char = LP.Character
		if not char then return end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return end

		if isRagdollState(hum) then
			hum:Move(Vector3.zero, false)
			return
		end

		local spd = getAutoPathSpeed()

		if alPhase == 1 then
			local tgt = Vector3.new(AP_L1.X, hrp.Position.Y, AP_L1.Z)
			if (tgt - hrp.Position).Magnitude < 1 then
				alPhase = 2
				local d = AP_L2 - hrp.Position
				local mv = Vector3.new(d.X, 0, d.Z).Unit
				hum:Move(mv, false)
				hrp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, hrp.AssemblyLinearVelocity.Y, mv.Z * spd)
				return
			end

			local d = AP_L1 - hrp.Position
			local mv = Vector3.new(d.X, 0, d.Z).Unit
			hum:Move(mv, false)
			hrp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, hrp.AssemblyLinearVelocity.Y, mv.Z * spd)

		elseif alPhase == 2 then
			local tgt = Vector3.new(AP_L2.X, hrp.Position.Y, AP_L2.Z)
			if (tgt - hrp.Position).Magnitude < 1 then
				hum:Move(Vector3.zero, false)
				hrp.AssemblyLinearVelocity = Vector3.zero

				autoLeftEnabled = false
				if alConn then alConn:Disconnect() end
				alConn = nil
				alPhase = 1

				if autoLeftSetVisual then autoLeftSetVisual(false) end
				return
			end

			local d = AP_L2 - hrp.Position
			local mv = Vector3.new(d.X, 0, d.Z).Unit
			hum:Move(mv, false)
			hrp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, hrp.AssemblyLinearVelocity.Y, mv.Z * spd)
		end
	end)
end

local function startAutoRight()
	if arConn then arConn:Disconnect() end
	arPhase = 1

	arConn = RunService.Heartbeat:Connect(function()
		if not autoRightEnabled then return end

		local char = LP.Character
		if not char then return end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return end

		if isRagdollState(hum) then
			hum:Move(Vector3.zero, false)
			return
		end

		local spd = getAutoPathSpeed()

		if arPhase == 1 then
			local tgt = Vector3.new(AP_R1.X, hrp.Position.Y, AP_R1.Z)
			if (tgt - hrp.Position).Magnitude < 1 then
				arPhase = 2
				local d = AP_R2 - hrp.Position
				local mv = Vector3.new(d.X, 0, d.Z).Unit
				hum:Move(mv, false)
				hrp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, hrp.AssemblyLinearVelocity.Y, mv.Z * spd)
				return
			end

			local d = AP_R1 - hrp.Position
			local mv = Vector3.new(d.X, 0, d.Z).Unit
			hum:Move(mv, false)
			hrp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, hrp.AssemblyLinearVelocity.Y, mv.Z * spd)

		elseif arPhase == 2 then
			local tgt = Vector3.new(AP_R2.X, hrp.Position.Y, AP_R2.Z)
			if (tgt - hrp.Position).Magnitude < 1 then
				hum:Move(Vector3.zero, false)
				hrp.AssemblyLinearVelocity = Vector3.zero

				autoRightEnabled = false
				if arConn then arConn:Disconnect() end
				arConn = nil
				arPhase = 1

				if autoRightSetVisual then autoRightSetVisual(false) end
				return
			end

			local d = AP_R2 - hrp.Position
			local mv = Vector3.new(d.X, 0, d.Z).Unit
			hum:Move(mv, false)
			hrp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, hrp.AssemblyLinearVelocity.Y, mv.Z * spd)
		end
	end)
                end
			"Speed: %.1f",
			Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z).Magnitude
		)
	end
end)local function setupSpeedIndicator(char)
	local head = char:WaitForChild("Head", 5)
	if not head then return end

	local bb = Instance.new("BillboardGui", head)
	bb.Size = UDim2.new(0, 160, 0, 52)
	bb.StudsOffset = Vector3.new(0, 2.5, 0)
	bb.AlwaysOnTop = true

	-- Discord label
	local discordLbl = Instance.new("TextLabel", bb)
	discordLbl.Size = UDim2.new(1, 0, 0, 22)
	discordLbl.Position = UDim2.new(0, 0, 0, 0)
	discordLbl.BackgroundTransparency = 1
	discordLbl.Text = "discord.gg/grey.cc"
	discordLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	discordLbl.Font = Enum.Font.GothamBlack
	discordLbl.TextScaled = true
	discordLbl.TextStrokeTransparency = 0
	discordLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

	-- Speed label
	speedLabel = Instance.new("TextLabel", bb)
	speedLabel.Size = UDim2.new(1, 0, 0, 28)
	speedLabel.Position = UDim2.new(0, 0, 0, 24)
	speedLabel.BackgroundTransparency = 1
	speedLabel.Text = "Speed: 0"
	speedLabel.TextColor3 = THEME_ACCENT
	speedLabel.Font = Enum.Font.GothamBlack
	speedLabel.TextScaled = true
	speedLabel.TextStrokeTransparency = 0
	speedLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

	trackTheme(function(c)
		if speedLabel and speedLabel.Parent then
			speedLabel.TextColor3 = c
		end
	end)
end

local function startAntiRagdoll()
	if Conns.antiRag then return end

	Conns.antiRag = RunService.Heartbeat:Connect(function()
		local char = LP.Character
		if not char then return end

		local hum = char:FindFirstChildOfClass("Humanoid")
		local root = char:FindFirstChild("HumanoidRootPart")

		if hum then
			local st = hum:GetState()
			if st == Enum.HumanoidStateType.Physics
				or st == Enum.HumanoidStateType.Ragdoll
				or st == Enum.HumanoidStateType.FallingDown
			then
				hum:ChangeState(Enum.HumanoidStateType.Running)
				workspace.CurrentCamera.CameraSubject = hum

				pcall(function()
					local pm = LP.PlayerScripts:FindFirstChild("PlayerModule")
					if pm then
						require(pm:FindFirstChild("ControlModule")):Enable()
					end
				end)

				if root then
					root.Velocity = Vector3.zero
					root.RotVelocity = Vector3.zero
				end
			end
		end

		for _, obj in ipairs(char:GetDescendants()) do
			if obj:IsA("Motor6D") and not obj.Enabled then
				obj.Enabled = true
			end
		end
	end)
end

local function stopAntiRagdoll()
	if Conns.antiRag then
		Conns.antiRag:Disconnect()
		Conns.antiRag = nil
	end
end-- =========================================================
-- PLAYER ESP — highlight + name + speed above each player
-- =========================================================
do
	local function _espCleanupPlayer(player)
		local d = PlayerESP.playerData[player]
		if not d then return end

		if d.highlight then pcall(function() d.highlight:Destroy() end) end
		if d.billboard then pcall(function() d.billboard:Destroy() end) end

		if d.conns then
			for _, c in ipairs(d.conns) do
				pcall(function() c:Disconnect() end)
			end
		end

		PlayerESP.playerData[player] = nil
	end

	local function _espSetupCharacter(player, char)
		if not PlayerESP.enabled or player == LP then return end

		_espCleanupPlayer(player)
		if not char or not char.Parent then return end

		local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
		local head = char:FindFirstChild("Head") or char:WaitForChild("Head", 5)
		if not hrp or not head then return end

		-- Highlight
		local hl = Instance.new("Highlight")
		hl.Name = "ToozeESP"
		hl.Adornee = char
		hl.FillColor = THEME_ACCENT
		hl.FillTransparency = 0.65
		hl.OutlineColor = Color3.fromRGB(255,255,255)
		hl.OutlineTransparency = 0
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Parent = char

		-- Billboard
		local bb = Instance.new("BillboardGui")
		bb.Name = "ToozeESPTag"
		bb.Adornee = head
		bb.Size = UDim2.new(0,180,0,64)
		bb.StudsOffset = Vector3.new(0,3,0)
		bb.AlwaysOnTop = true
		bb.LightInfluence = 0
		bb.Parent = head

		-- Discord label
		local dLbl = Instance.new("TextLabel", bb)
		dLbl.Size = UDim2.new(1,0,0,18)
		dLbl.Position = UDim2.new(0,0,0,0)
		dLbl.BackgroundTransparency = 1
		dLbl.Text = PlayerESP.discordText
		dLbl.TextColor3 = Color3.fromRGB(255,255,255)
		dLbl.Font = Enum.Font.GothamBlack
		dLbl.TextScaled = true
		dLbl.TextStrokeTransparency = 0
		dLbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)

		-- Name label
		local nLbl = Instance.new("TextLabel", bb)
		nLbl.Size = UDim2.new(1,0,0,24)
		nLbl.Position = UDim2.new(0,0,0,18)
		nLbl.BackgroundTransparency = 1
		nLbl.Text = player.DisplayName .. " (@" .. player.Name .. ")"
		nLbl.TextColor3 = Color3.fromRGB(255,255,255)
		nLbl.Font = Enum.Font.GothamBlack
		nLbl.TextScaled = true
		nLbl.TextStrokeTransparency = 0
		nLbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)

		-- Speed label
		local sLbl = Instance.new("TextLabel", bb)
		sLbl.Size = UDim2.new(1,0,0,22)
		sLbl.Position = UDim2.new(0,0,0,42)
		sLbl.BackgroundTransparency = 1
		sLbl.Text = "Speed: 0"
		sLbl.TextColor3 = THEME_ACCENT
		sLbl.Font = Enum.Font.GothamBlack
		sLbl.TextScaled = true
		sLbl.TextStrokeTransparency = 0
		sLbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)

		local speedConn = RunService.Heartbeat:Connect(function()
			if not PlayerESP.enabled or not hrp or not hrp.Parent then return end
			local v = hrp.AssemblyLinearVelocity or hrp.Velocity
			local mag = Vector3.new(v.X,0,v.Z).Magnitude
			sLbl.Text = string.format("Speed: %.1f", mag)
		end)

		PlayerESP.playerData[player] = {
			highlight = hl,
			billboard = bb,
			nameLabel = nLbl,
			speedLabel = sLbl,
			discordLabel = dLbl,
			conns = {speedConn},
		}
	end

	local function _espOnPlayerAdded(player)
		if not PlayerESP.enabled or player == LP then return end

		local function onChar(char)
			task.spawn(function()
				_espSetupCharacter(player, char)
			end)
		end

		if player.Character then onChar(player.Character) end
		player.CharacterAdded:Connect(onChar)
	end

	startPlayerESP = function()
		if PlayerESP.enabled then return end
		PlayerESP.enabled = true

		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LP then _espOnPlayerAdded(p) end
		end

		table.insert(PlayerESP.conns, Players.PlayerAdded:Connect(_espOnPlayerAdded))
		table.insert(PlayerESP.conns, Players.PlayerRemoving:Connect(_espCleanupPlayer))
	end

	stopPlayerESP = function()
		if not PlayerESP.enabled then return end
		PlayerESP.enabled = false

		for _, c in ipairs(PlayerESP.conns) do
			pcall(function() c:Disconnect() end)
		end
		PlayerESP.conns = {}

		for player, _ in pairs(PlayerESP.playerData) do
			_espCleanupPlayer(player)
		end
	end

	trackTheme(function(c)
		for _, d in pairs(PlayerESP.playerData) do
			if d.highlight then d.highlight.FillColor = c end
			if d.speedLabel then d.speedLabel.TextColor3 = c end
		end
	end)
    end-- =========================================================
-- AUTO BAT — smooth tracking + vertical offset + hit assist
-- =========================================================

local function getClosestBatTarget()
	local char = LP.Character
	if not char then return nil end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end

	local closest, dist = nil, math.huge

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP and p.Character then
			local hrp2 = p.Character:FindFirstChild("HumanoidRootPart")
			if hrp2 then
				local d = (hrp2.Position - hrp.Position).Magnitude
				if d < dist and d < 80 then
					closest = hrp2
					dist = d
				end
			end
		end
	end

	return closest
end

local function autoBatMove()
	local char = LP.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end

	local target = getClosestBatTarget()
	_autoBatTarget = target

	if not target then
		hum:Move(Vector3.zero, false)
		return
	end

	local pos = target.Position
	local my = hrp.Position

	local dx = pos.X - my.X
	local dz = pos.Z - my.Z
	local dy = (pos.Y + AUTO_BAT_HEIGHT) - my.Y

	local horiz = Vector3.new(dx, 0, dz)
	local dist = horiz.Magnitude

	if dist < 0.1 then
		hum:Move(Vector3.zero, false)
		return
	end

	local mv = horiz.Unit
	local spd = AUTO_BAT_SPEED

	hrp.AssemblyLinearVelocity = Vector3.new(
		mv.X * spd,
		dy * (AUTO_BAT_VERT_SPEED / 10),
		mv.Z * spd
	)

	local desiredYaw = math.atan2(-mv.X, -mv.Z)
	local currentYaw = hrp.Orientation.Y
	local delta = math.deg(desiredYaw) - currentYaw

	delta = math.clamp(delta, -AUTO_BAT_MAX_TURN_RATE, AUTO_BAT_MAX_TURN_RATE)

	hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(delta), 0)
end

local function autoBatHit()
	local char = LP.Character
	if not char then return end

	local tool = char:FindFirstChildOfClass("Tool")
	if not tool then return end

	local handle = tool:FindFirstChild("Handle")
	if not handle then return end

	local target = _autoBatTarget
	if not target then return end

	local dist = (target.Position - handle.Position).Magnitude
	if dist < 6 then
		pcall(function()
			tool:Activate()
		end)
	end
end

RunService.Heartbeat:Connect(function()
	if autoBatEnabled then
		autoBatMove()
		autoBatHit()
	end
end)-- =========================================================
-- DROP BRAINROT
-- =========================================================
local function runDrop()
	if dropActive then return end
	dropActive = true

	local char = LP.Character
	if not char then dropActive = false return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then dropActive = false return end

	local tool = char:FindFirstChildOfClass("Tool")
	if not tool then dropActive = false return end

	local handle = tool:FindFirstChild("Handle")
	if not handle then dropActive = false return end

	for _ = 1, 12 do
		pcall(function()
			tool:Activate()
		end)
		task.wait(0.05)
	end

	dropActive = false
end

-- =========================================================
-- AUTO TP (FLOAT ABOVE GROUND)
-- =========================================================
local function startAutoTP()
	if autoTPConn then autoTPConn:Disconnect() end

	autoTPConn = RunService.Heartbeat:Connect(function()
		if not autoTPEnabled then return end

		local char = LP.Character
		if not char then return end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		local pos = hrp.Position
		hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		hrp.CFrame = CFrame.new(pos.X, autoTPHeight, pos.Z)
	end)
end

local function stopAutoTP()
	if autoTPConn then
		autoTPConn:Disconnect()
		autoTPConn = nil
	end
end

-- =========================================================
-- INF JUMP
-- =========================================================
UIS.JumpRequest:Connect(function()
	if infJumpEnabled then
		local char = LP.Character
		if not char then return end

		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- =========================================================
-- UNWALK (FREEZE ANIMATION)
-- =========================================================
local function startUnwalk()
	local char = LP.Character
	if not char then return end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	local animate = char:FindFirstChild("Animate")
	if animate then
		unwalkSavedAnimate = animate:Clone()
		animate:Destroy()
	end
end

local function stopUnwalk()
	local char = LP.Character
	if not char then return end

	if unwalkSavedAnimate then
		unwalkSavedAnimate.Parent = char
		unwalkSavedAnimate = nil
	end
        end-- =========================================================
-- KEYBINDS / INPUT HANDLING
-- =========================================================

UIS.InputBegan:Connect(function(input, gp)
	if gp then return end

	-- SPEED TOGGLE (Q)
	if input.KeyCode == KB.SpeedToggle.kb then
		speedMode = not speedMode
	end

	-- LAGGER TOGGLE (R)
	if input.KeyCode == KB.LaggerToggle.kb then
		laggerToggled = not laggerToggled
		laggerPhase = 0
	end

	-- AUTO LEFT (Z)
	if input.KeyCode == KB.AutoLeft.kb then
		autoLeftEnabled = not autoLeftEnabled
		if autoLeftEnabled then
			if autoLeftSetVisual then autoLeftSetVisual(true) end
			startAutoLeft()
		else
			stopAutoLeft()
		end
	end

	-- AUTO RIGHT (C)
	if input.KeyCode == KB.AutoRight.kb then
		autoRightEnabled = not autoRightEnabled
		if autoRightEnabled then
			if autoRightSetVisual then autoRightSetVisual(true) end
			startAutoRight()
		else
			stopAutoRight()
		end
	end

	-- AUTO BAT (E)
	if input.KeyCode == KB.AutoBat.kb then
		autoBatEnabled = not autoBatEnabled
		if autoBatSetVisual then autoBatSetVisual(autoBatEnabled) end
	end

	-- DROP BRAINROT (X)
	if input.KeyCode == KB.DropBrainrot.kb then
		runDrop()
	end

	-- TP FLOOR (F)
	if input.KeyCode == KB.TPFloor.kb then
		local char = LP.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.CFrame = CFrame.new(hrp.Position.X, 3, hrp.Position.Z)
			end
		end
	end

	-- INSTA RESET (T)
	if input.KeyCode == KB.InstaReset.kb then
		cursedInstaReset()
	end

	-- HIDE GUI (CTRL)
	if input.KeyCode == KB.GuiHide.kb then
		_guiLocked = not _guiLocked
		if setLockGuiVisual then setLockGuiVisual(_guiLocked) end
	end
end)-- =========================================================
-- VISUAL CALLBACKS (UI buttons update)
-- =========================================================

autoLeftSetVisual = function(state)
	if modeValLbl then
		modeValLbl.Text = state and "AUTO LEFT" or "IDLE"
	end
end

autoRightSetVisual = function(state)
	if modeValLbl then
		modeValLbl.Text = state and "AUTO RIGHT" or "IDLE"
	end
end

autoBatSetVisual = function(state)
	if modeValLbl then
		modeValLbl.Text = state and "AUTO BAT"
	end
end

setLockGuiVisual = function(state)
	if modeValLbl then
		modeValLbl.Text = state and "GUI LOCKED" or "IDLE"
	end
end

setIntroVisual = function(state)
	if modeValLbl then
		modeValLbl.Text = state and "INTRO ON" or "INTRO OFF"
	end
end

-- =========================================================
-- THEME SYSTEM
-- =========================================================

local function applyThemeToGui(gui)
	for _, obj in ipairs(gui:GetDescendants()) do
		if obj:IsA("TextLabel") or obj:IsA("TextButton") then
			obj.TextColor3 = THEME_ACCENT
		elseif obj:IsA("Frame") then
			obj.BackgroundColor3 = THEME_ACCENT_DIM
		end
	end
end

trackTheme(function(c)
	for _, d in pairs(PlayerESP.playerData) do
		if d.speedLabel then d.speedLabel.TextColor3 = c end
		if d.highlight then d.highlight.FillColor = c end
	end
end)

-- =========================================================
-- SIDEBAR ART
-- =========================================================

setSidebarArt_global = function(id)
	CURRENT_ART_ID = id

	local char = LP.Character
	if not char then return end

	local head = char:FindFirstChild("Head")
	if not head then return end

	local gui = head:FindFirstChild("CleanHubSidebar")
	if not gui then return end

	local img = gui:FindFirstChild("Art")
	if img then
		img.Image = "rbxassetid://" .. tostring(id)
	end
end

local function applySidebarArt(char)
	local head = char:WaitForChild("Head", 5)
	if not head then return end

	local gui = Instance.new("BillboardGui", head)
	gui.Name = "CleanHubSidebar"
	gui.Size = UDim2.new(0, 4, 0, 4)
	gui.StudsOffset = Vector3.new(3, 0, 0)
	gui.AlwaysOnTop = true

	local img = Instance.new("ImageLabel", gui)
	img.Name = "Art"
	img.Size = UDim2.new(1, 0, 1, 0)
	img.BackgroundTransparency = 1
	img.Image = "rbxassetid://" .. tostring(CURRENT_ART_ID)
            end-- =========================================================
-- CHARACTER ADDED SETUP
-- =========================================================

local function onCharacterAdded(char)
	task.wait(0.5)

	-- Apply sidebar art
	applySidebarArt(char)

	-- Setup speed indicator
	setupSpeedIndicator(char)

	-- Anti-ragdoll
	if antiRagdollEnabled then
		startAntiRagdoll()
	end

	-- Auto TP
	if autoTPEnabled then
		startAutoTP()
	end

	-- ESP refresh
	if PlayerESP.enabled then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LP and p.Character then
				task.spawn(function()
					local hrp = p.Character:FindFirstChild("HumanoidRootPart")
					if hrp then
						-- Force ESP rebuild
						stopPlayerESP()
						task.wait(0.1)
						startPlayerESP()
					end
				end)
			end
		end
	end
end

LP.CharacterAdded:Connect(onCharacterAdded)
if LP.Character then onCharacterAdded(LP.Character) end

-- =========================================================
-- AUTOSAVE (THEME + SETTINGS)
-- =========================================================

local function autoSave()
	if not V.autoSaveEnabled then return end

	local data = {
		accent = {
			r = THEME_ACCENT.R,
			g = THEME_ACCENT.G,
			b = THEME_ACCENT.B
		},
		sidebar = CURRENT_ART_ID,
		fov = V.customFovValue,
		sky = V.skyTheme,
	}

	pcall(function()
		writefile("cleanhub_settings.json", HS:JSONEncode(data))
	end)
end

task.spawn(function()
	while task.wait(10) do
		autoSave()
	end
end)

-- =========================================================
-- LOAD SETTINGS (IF EXIST)
-- =========================================================

pcall(function()
	if isfile("cleanhub_settings.json") then
		local raw = readfile("cleanhub_settings.json")
		local data = HS:JSONDecode(raw)

		if data.accent then
			setAccent(Color3.new(data.accent.r, data.accent.g, data.accent.b))
		end

		if data.sidebar then
			CURRENT_ART_ID = data.sidebar
		end

		if data.fov then
			V.customFovValue = data.fov
		end

		if data.sky then
			V.skyTheme = data.sky
		end
	end
end)

-- =========================================================
-- INITIAL STARTUP
-- =========================================================

task.wait(1)

-- Auto-steal OFF by default (manual enable)
-- startAutoSteal()

-- ESP OFF by default
-- startPlayerESP()

print("[CleanHub] Loaded successfully.")-- =========================================================
-- FINAL RETURN TABLE (OPTIONAL EXPORT)
-- =========================================================

return {
    AutoSteal = Steal,
    PlayerESP = PlayerESP,
    Theme = {
        Accent = THEME_ACCENT,
        SetAccent = setAccent_global,
        SidebarArt = setSidebarArt_global
    },
    Toggles = {
        Speed = function() return speedMode end,
        Lagger = function() return laggerToggled end,
        AutoLeft = function() return autoLeftEnabled end,
        AutoRight = function() return autoRightEnabled end,
        AutoBat = function() return autoBatEnabled end,
        AutoTP = function() return autoTPEnabled end,
        InfJump = function() return infJumpEnabled end,
        Unwalk = function() return unwalkEnabled end,
    }
}

-- =========================================================
-- END OF CLEANHUB.LUA
-- =========================================================
