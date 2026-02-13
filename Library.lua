-- * Service & Cache Variables

local uis = game:GetService("UserInputService")
local hs = game:GetService("HttpService")
local cg = game:GetService("CoreGui")
local ts = game:GetService("TweenService")
local rs = game:GetService("RunService")
local ps = game:GetService("Players")
local LocalPlayer = ps.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- * UI Utility

local utility = {
	is_dragging_blocked = false,
	toggles = {},
	options = {}
}

do
	local newInstance = Instance.new

	utility.setDraggable = function(object)
		local dragging = false

		object.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			local inputType = input.UserInputType
			if inputType == Enum.UserInputType.MouseButton1 and not utility.is_dragging_blocked then
				local mouse_location = uis:GetMouseLocation()
				local startPosX = mouse_location.X
				local startPosY = mouse_location.Y
				local objPosX = object.Position.X.Offset
				local objPosY = object.Position.Y.Offset
				dragging = true
				task.spawn(function()
					while dragging and not utility.is_dragging_blocked do
						mouse_location = uis:GetMouseLocation()
						object.Position = UDim2.new(0, objPosX - (startPosX - mouse_location.X), 0, objPosY - (startPosY - mouse_location.Y))
						task.wait()
					end
				end)
			end
		end)

		object.InputEnded:Connect(function(input, gpe)
			if gpe then return end
			local inputType = input.UserInputType
			if inputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
	end

	utility.newObject = function(class, properties)
		local object = newInstance(class)

		for property, value in pairs(properties) do
			object[property] = value
		end

		object.Name = hs:GenerateGUID(false)

		return object
	end
	
	utility.createGradient = function(parent, colors)
		local gradient = newInstance("UIGradient")
		gradient.Color = ColorSequence.new(colors)
		gradient.Parent = parent
		return gradient
	end
	
	utility.round = function(num, decimals)
		local mult = 10^(decimals or 0)
		return math.floor(num * mult + 0.5) / mult
	end
	
	utility.map = function(value, minA, maxA, minB, maxB)
		return (1 - ((value - minA) / (maxA - minA))) * minB + ((value - minA) / (maxA - minA)) * maxB
	end
end

-- * Library Core

local Library = {
	ui = {},
	signals = {},
	font = Enum.Font.SourceSans,
	fontBold = Enum.Font.SourceSansBold,
	
	colors = {
		background = Color3.fromRGB(23, 23, 23),
		main = Color3.fromRGB(40, 40, 40),
		accent = Color3.fromRGB(0, 162, 255),
		accentDark = Color3.fromRGB(0, 120, 200),
		outline = Color3.fromRGB(12, 12, 12),
		text = Color3.fromRGB(198, 198, 198),
		textDark = Color3.fromRGB(109, 109, 109),
		black = Color3.fromRGB(0, 0, 0),
		white = Color3.fromRGB(255, 255, 255),
		risk = Color3.fromRGB(255, 50, 50)
	},
	
	rainbowHue = 0,
	rainbowStep = 0
}

-- * Rainbow color update

table.insert(Library.signals, rs.RenderStepped:Connect(function(delta)
	Library.rainbowStep = Library.rainbowStep + delta
	
	if Library.rainbowStep >= (1/60) then
		Library.rainbowStep = 0
		Library.rainbowHue = (Library.rainbowHue + 0.0025) % 1
	end
end))

-- * Utility Functions

function Library:GetTextBounds(text, font, size)
	local bounds = ts:GetTextSize(text, size, font, Vector2.new(1000, 1000))
	return bounds.X, bounds.Y
end

function Library:SafeCallback(func, ...)
	if not func then return end
	
	local success, err = pcall(func, ...)
	if not success then
		warn("[UI Library] Callback error:", err)
	end
end

-- * UI Window

do
	local newObject = utility.newObject
	
	local _screenGui = newObject("ScreenGui", {
		Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"),
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		DisplayOrder = 100
	})
	
	Library.ScreenGui = _screenGui
	
	function Library:CreateWindow(config)
		config = config or {}
		config.Title = config.Title or "UI Library"
		config.AutoShow = config.AutoShow ~= false
		config.Size = config.Size or UDim2.new(0, 658, 0, 558)
		config.Position = config.Position or UDim2.new(0, 500, 0, 300)
		
		-- * Main Window Construction
		local Border = newObject("Frame", {
			BackgroundColor3 = Library.colors.outline,
			BorderColor3 = Library.colors.black,
			Position = config.Position,
			Size = config.Size,
			Parent = _screenGui
		})
		
		local Border2 = newObject("Frame", {
			BackgroundColor3 = Library.colors.main,
			BorderColor3 = Library.colors.main,
			Position = UDim2.new(0, 2, 0, 2),
			Size = UDim2.new(1, -4, 1, -4),
			Parent = Border
		})
		
		local Background = newObject("ImageLabel", {
			BackgroundColor3 = Library.colors.white,
			BorderColor3 = Library.colors.outline,
			Position = UDim2.new(0, 3, 0, 3),
			Size = UDim2.new(1, -6, 1, -6),
			Image = "rbxassetid://15453092054",
			ScaleType = Enum.ScaleType.Tile,
			TileSize = UDim2.new(0, 4, 0, 548),
			Parent = Border2
		})
		
		local TabHolder = newObject("Frame", {
			BackgroundColor3 = Library.colors.outline,
			BackgroundTransparency = 1,
			BorderColor3 = Library.colors.black,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 14),
			Size = UDim2.new(0, 73, 0, 0),
			Parent = Background
		})
		
		local TabLayout = newObject("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 2),
			Parent = TabHolder
		})
		
		local TopGap = newObject("Frame", {
			BackgroundColor3 = Library.colors.outline,
			BorderColor3 = Library.colors.black,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 73, 0, 14),
			Parent = Background
		})
		
		local TopSideFix = newObject("Frame", {
			BackgroundColor3 = Library.colors.black,
			BorderColor3 = Library.colors.black,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 73, 0, 0),
			Size = UDim2.new(0, 1, 1, 0),
			Parent = TopGap
		})
		
		local TopSideFix2 = newObject("Frame", {
			BackgroundColor3 = Library.colors.main,
			BorderColor3 = Library.colors.black,
			BorderSizePixel = 0,
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(0, 1, 1, 0),
			Parent = TopSideFix
		})
		
		local BottomGap = newObject("Frame", {
			BackgroundColor3 = Library.colors.outline,
			BorderColor3 = Library.colors.black,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 1, -22),
			Size = UDim2.new(0, 73, 0, 22),
			Parent = Background
		})
		
		local BottomSideFix = newObject("Frame", {
			BackgroundColor3 = Library.colors.black,
			BorderColor3 = Library.colors.black,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 73, 0, 0),
			Size = UDim2.new(0, 1, 1, 0),
			Parent = BottomGap
		})
		
		local BottomSideFix2 = newObject("Frame", {
			BackgroundColor3 = Library.colors.main,
			BorderColor3 = Library.colors.black,
			BorderSizePixel = 0,
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(0, 1, 1, 0),
			Parent = BottomSideFix
		})
		
		local TopBar = newObject("ImageLabel", {
			BackgroundColor3 = Library.colors.white,
			BorderColor3 = Library.colors.outline,
			Position = UDim2.new(0, 1, 0, 1),
			Size = UDim2.new(1, -2, 0, 2),
			ZIndex = 2,
			Image = "rbxassetid://15453122383",
			Parent = Background
		})
		
		local BlackBar = newObject("Frame", {
			BackgroundColor3 = Color3.fromRGB(6, 6, 6),
			BorderColor3 = Library.colors.black,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 0, 1),
			ZIndex = 2,
			Parent = TopBar
		})
		
		local Title = newObject("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 80, 0, 0),
			Size = UDim2.new(1, -100, 0, 20),
			Font = Library.fontBold,
			Text = config.Title,
			TextColor3 = Library.colors.text,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Background
		})
		
		utility.setDraggable(Border)
		
		local window = {
			holder = Border,
			background = Background,
			tab_holder = TabHolder,
			active_tab = nil,
			tabs = {},
			config = config,
			visible = config.AutoShow
		}
		
		setmetatable(window, { __index = Library.UIWindow })
		
		if not config.AutoShow then
			Border.Visible = false
		end
		
		-- * Keybind to toggle menu (RightControl by default)
		uis.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			
			local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl
			
			if input.KeyCode == toggleKey then
				window.visible = not window.visible
				
				ts:Create(Border, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = window.visible and 0 or 1
				}):Play()
				
				task.wait(0.2)
				Border.Visible = window.visible
			end
		end)
		
		return window
	end
	
	Library.UIWindow = {}
	
	function Library.UIWindow:AddTab(name, icon)
		icon = icon or "rbxassetid://15453302474"
		
		local new_tab = {
			name = name,
			sections = {},
			is_open = false
		}
		
		-- * Tab Button
		local Button = utility.newObject("Frame", {
			BackgroundColor3 = Library.colors.outline,
			BorderColor3 = Library.colors.black,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 73, 0, 64),
			Parent = self.tab_holder
		})
		
		local BottomBar = utility.newObject("Frame", {
			BackgroundColor3 = Library.colors.black,
			BorderColor3 = Library.colors.black,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 1, 1),
			Size = UDim2.new(1, 0, 0, 1),
			Visible = false,
			ZIndex = 2,
			Parent = Button
		})
		
		local BottomBar2 = utility.newObject("Frame", {
			BackgroundColor3 = Library.colors.main,
			BorderColor3 = Library.colors.black,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, -1),
			Size = UDim2.new(1, 2, 1, 0),
			ZIndex = 2,
			Parent = BottomBar
		})
		
		local Icon = utility.newObject("ImageLabel", {
			BackgroundColor3 = Library.colors.white,
			BackgroundTransparency = 1,
			BorderColor3 = Library.colors.black,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Image = icon,
			ImageColor3 = Library.colors.textDark,
			Parent = Button
		})
		
		local TopBar = utility.newObject("Frame", {
			BackgroundColor3 = Library.colors.black,
			BorderColor3 = Library.colors.black,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, -2),
			Size = UDim2.new(1, 0, 0, 1),
			Visible = false,
			ZIndex = 2,
			Parent = Button
		})
		
		local TopBar2 = utility.newObject("Frame", {
			BackgroundColor3 = Library.colors.main,
			BorderColor3 = Library.colors.black,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 1),
			Size = UDim2.new(1, 2, 1, 0),
			ZIndex = 2,
			Parent = TopBar
		})
		
		local SideBar = utility.newObject("Frame", {
			BackgroundColor3 = Library.colors.black,
			BorderColor3 = Library.colors.black,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 73, 0, 0),
			Size = UDim2.new(0, 1, 1, 0),
			Parent = Button
		})
		
		local SideBar2 = utility.newObject("Frame", {
			BackgroundColor3 = Library.colors.main,
			BorderColor3 = Library.colors.black,
			BorderSizePixel = 0,
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(0, 1, 1, 0),
			Parent = SideBar    
		})
		
		local TabFrame = utility.newObject("Frame", {
			BackgroundColor3 = Library.colors.white,
			BackgroundTransparency = 1,
			BorderColor3 = Library.colors.black,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 96, 0, 23),
			Size = UDim2.new(0, 532, 0, 506),
			Visible = false,
			Parent = self.background
		})
		
		-- * Tab Content Container
		local Content = utility.newObject("ScrollingFrame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 10, 0, 10),
			Size = UDim2.new(1, -20, 1, -20),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Library.colors.accent,
			BottomImage = "",
			TopImage = "",
			Parent = TabFrame
		})
		
		local ContentLayout = utility.newObject("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = Content
		})
		
		ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
		end)
		
		-- * Button Interactions
		Button.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if self.active_tab == new_tab then return end
				self:_setActiveTab(new_tab)
			end
		end)
		
		Button.MouseEnter:Connect(function()
			if self.active_tab == new_tab then return end
			Icon.ImageColor3 = Color3.fromRGB(204, 204, 204)
		end)
		
		Button.MouseLeave:Connect(function()
			if self.active_tab == new_tab then return end
			Icon.ImageColor3 = Library.colors.textDark
		end)
		
		new_tab.button = Button
		new_tab.icon = Icon
		new_tab.bottom_bar = BottomBar
		new_tab.top_bar = TopBar
		new_tab.side_bar = SideBar
		new_tab.frame = TabFrame
		new_tab.content = Content
		new_tab.content_layout = ContentLayout
		
		setmetatable(new_tab, { __index = Library.UITab })
		
		self.tabs[name] = new_tab
		
		if not self.active_tab then
			self:_setActiveTab(new_tab)
		end
		
		return new_tab
	end
	
	function Library.UIWindow:_setActiveTab(tab)
		self.active_tab = tab
		
		for name, _tab in pairs(self.tabs) do
			local is_active = _tab == tab
			_tab.icon.ImageColor3 = is_active and Library.colors.white or Library.colors.textDark
			_tab.bottom_bar.Visible = is_active
			_tab.top_bar.Visible = is_active
			_tab.side_bar.Visible = not is_active
			_tab.button.BackgroundTransparency = is_active and 1 or 0
			_tab.frame.Visible = is_active
		end
	end
	
	function Library.UIWindow:SetVisible(bool)
		self.visible = bool
		self.holder.Visible = bool
	end
	
	function Library.UIWindow:Destroy()
		self.holder:Destroy()
	end
end

-- * UI Tab

Library.UITab = {}

function Library.UITab:AddSection(name, scale)
	scale = scale or 0.1
	
	local Section = utility.newObject("Frame", {
		BackgroundColor3 = Library.colors.outline,
		BorderColor3 = Library.colors.black,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -20, 0, 0),
		Parent = self.content
	})
	
	local Inside = utility.newObject("Frame", {
		BackgroundColor3 = Library.colors.main,
		BorderColor3 = Library.colors.black,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 1, 0, 1),
		Size = UDim2.new(1, -2, 1, -2),
		Parent = Section
	})
	
	local Inside2 = utility.newObject("Frame", {
		BackgroundColor3 = Library.colors.background,
		BorderColor3 = Library.colors.black,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 1, 0, 1),
		Size = UDim2.new(1, -2, 1, -2),
		Parent = Inside
	})
	
	local SectionLabel = utility.newObject("TextLabel", {
		BackgroundColor3 = Library.colors.white,
		BackgroundTransparency = 1,
		BorderColor3 = Library.colors.black,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 12, 0, -12),
		Font = Library.fontBold,
		Text = name,
		TextColor3 = Library.colors.text,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = Inside2
	})
	
	local Content = utility.newObject("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 20),
		Size = UDim2.new(1, -20, 1, -30),
		Parent = Inside2
	})
	
	local ContentLayout = utility.newObject("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = Content
	})
	
	local section = {
		name = name,
		frame = Section,
		content = Content,
		layout = ContentLayout,
		elements = {}
	}
	
	setmetatable(section, { __index = Library.UISection })
	
	-- * Resize section based on content
	ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Section.Size = UDim2.new(1, -20, 0, ContentLayout.AbsoluteContentSize.Y + 50)
	end)
	
	self.sections[name] = section
	
	task.wait()
	Section.Size = UDim2.new(1, -20, 0, ContentLayout.AbsoluteContentSize.Y + 50)
	
	return section
end

-- * UI Section

Library.UISection = {}

function Library.UISection:AddToggle(id, config)
	config = config or {}
	config.Text = config.Text or "Toggle"
	config.Default = config.Default or false
	
	local toggle = {
		Value = config.Default,
		Type = "Toggle",
		Callbacks = {},
		Config = config
	}
	
	local ToggleOuter = utility.newObject("Frame", {
		BackgroundColor3 = Library.colors.black,
		BorderColor3 = Library.colors.black,
		Size = UDim2.new(0, 15, 0, 15),
		ZIndex = 5,
		Parent = self.content
	})
	
	local ToggleInner = utility.newObject("Frame", {
		BackgroundColor3 = config.Default and Library.colors.accent or Library.colors.main,
		BorderColor3 = config.Default and Library.colors.accentDark or Library.colors.outline,
		BorderMode = Enum.BorderMode.Inset,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 6,
		Parent = ToggleOuter
	})
	
	local ToggleLabel = utility.newObject("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(1, 8, 0, 0),
		Size = UDim2.new(0, 250, 1, 0),
		Font = Library.font,
		Text = config.Text,
		TextColor3 = config.Risky and Library.colors.risk or Library.colors.text,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = ToggleInner
	})
	
	local ToggleRegion = utility.newObject("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 273, 1, 0),
		ZIndex = 8,
		Parent = ToggleOuter
	})
	
	-- * Tooltip
	if config.Tooltip then
		utility.addTooltip(ToggleRegion, config.Tooltip)
	end
	
	function toggle:SetValue(bool)
		bool = not not bool
		self.Value = bool
		
		ToggleInner.BackgroundColor3 = bool and Library.colors.accent or Library.colors.main
		ToggleInner.BorderColor3 = bool and Library.colors.accentDark or Library.colors.outline
		
		for _, cb in pairs(self.Callbacks) do
			pcall(cb, bool)
		end
		
		pcall(config.Callback, bool)
	end
	
	function toggle:OnChanged(cb)
		table.insert(self.Callbacks, cb)
		pcall(cb, self.Value)
	end
	
	ToggleRegion.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			toggle:SetValue(not toggle.Value)
		end
	end)
	
	utility.toggles[id] = toggle
	self.elements[id] = toggle
	
	return toggle
end

function Library.UISection:AddSlider(id, config)
	config = config or {}
	config.Text = config.Text or "Slider"
	config.Default = config.Default or 0
	config.Min = config.Min or 0
	config.Max = config.Max or 100
	config.Rounding = config.Rounding or 0
	config.Suffix = config.Suffix or ""
	
	local slider = {
		Value = config.Default,
		Min = config.Min,
		Max = config.Max,
		Type = "Slider",
		Callbacks = {},
		Config = config
	}
	
	if not config.Compact then
		local Label = utility.newObject("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 15),
			Font = Library.font,
			Text = config.Text,
			TextColor3 = Library.colors.text,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = self.content
		})
		
		utility.newObject("UIPadding", {
			PaddingLeft = UDim.new(0, 5),
			Parent = Label
		})
	end
	
	local SliderOuter = utility.newObject("Frame", {
		BackgroundColor3 = Library.colors.black,
		BorderColor3 = Library.colors.black,
		Size = UDim2.new(1, -10, 0, 15),
		Position = UDim2.new(0, 5, 0, 0),
		ZIndex = 5,
		Parent = self.content
	})
	
	local SliderInner = utility.newObject("Frame", {
		BackgroundColor3 = Library.colors.main,
		BorderColor3 = Library.colors.outline,
		BorderMode = Enum.BorderMode.Inset,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 6,
		Parent = SliderOuter
	})
	
	local Fill = utility.newObject("Frame", {
		BackgroundColor3 = Library.colors.accent,
		BorderColor3 = Library.colors.accentDark,
		Size = UDim2.new(0, 0, 1, 0),
		ZIndex = 7,
		Parent = SliderInner
	})
	
	local DisplayLabel = utility.newObject("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Font = Library.font,
		Text = "",
		TextColor3 = Library.colors.text,
		TextSize = 14,
		ZIndex = 9,
		Parent = SliderInner
	})
	
	local SliderWidth = 232
	
	function slider:Display()
		local percent = (self.Value - self.Min) / (self.Max - self.Min)
		local xSize = math.floor(percent * SliderWidth)
		Fill.Size = UDim2.new(0, xSize, 1, 0)
		
		if config.Compact then
			DisplayLabel.Text = string.format("%s: %s%s", config.Text, self.Value, config.Suffix)
		else
			DisplayLabel.Text = string.format("%s%s / %s%s", self.Value, config.Suffix, self.Max, config.Suffix)
		end
	end
	
	function slider:SetValue(val)
		val = math.clamp(val, self.Min, self.Max)
		if config.Rounding > 0 then
			val = utility.round(val, config.Rounding)
		else
			val = math.floor(val)
		end
		
		self.Value = val
		self:Display()
		
		for _, cb in pairs(self.Callbacks) do
			pcall(cb, val)
		end
		
		pcall(config.Callback, val)
	end
	
	function slider:OnChanged(cb)
		table.insert(self.Callbacks, cb)
		pcall(cb, self.Value)
	end
	
	SliderInner.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			while uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
				local mouseX = Mouse.X
				local minX = Fill.AbsolutePosition.X
				local maxX = minX + SliderWidth
				local percent = math.clamp((mouseX - minX) / SliderWidth, 0, 1)
				local value = self.Min + (percent * (self.Max - self.Min))
				self:SetValue(value)
				rs.RenderStepped:Wait()
			end
		end
	end)
	
	self:Display()
	
	utility.options[id] = slider
	self.elements[id] = slider
	
	return slider
end

function Library.UISection:AddButton(config)
	config = config or {}
	config.Text = config.Text or "Button"
	config.Func = config.Func or function() end
	config.DoubleClick = config.DoubleClick or false
	
	local ButtonOuter = utility.newObject("Frame", {
		BackgroundColor3 = Library.colors.black,
		BorderColor3 = Library.colors.black,
		Size = UDim2.new(1, -10, 0, 25),
		Position = UDim2.new(0, 5, 0, 0),
		ZIndex = 5,
		Parent = self.content
	})
	
	local ButtonInner = utility.newObject("Frame", {
		BackgroundColor3 = Library.colors.main,
		BorderColor3 = Library.colors.outline,
		BorderMode = Enum.BorderMode.Inset,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 6,
		Parent = ButtonOuter
	})
	
	local ButtonLabel = utility.newObject("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Font = Library.fontBold,
		Text = config.Text,
		TextColor3 = Library.colors.text,
		TextSize = 15,
		ZIndex = 7,
		Parent = ButtonInner
	})
	
	local locked = false
	
	ButtonOuter.InputBegan:Connect(function(input, gpe)
		if gpe or locked then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if config.DoubleClick then
				locked = true
				ButtonLabel.TextColor3 = Library.colors.accent
				ButtonLabel.Text = "Are you sure?"
				
				task.wait(0.5)
				
				ButtonLabel.TextColor3 = Library.colors.text
				ButtonLabel.Text = config.Text
				locked = false
			else
				pcall(config.Func)
			end
		end
	end)
	
	local button = {
		ButtonOuter = ButtonOuter,
		SetText = function(text)
			ButtonLabel.Text = text
		end
	}
	
	return button
end

function Library.UISection:AddLabel(text, wrap)
	wrap = wrap or false
	
	local Label = utility.newObject("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 0, 20),
		Position = UDim2.new(0, 5, 0, 0),
		Font = Library.font,
		Text = text,
		TextColor3 = Library.colors.text,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = wrap,
		Parent = self.content
	})
	
	if wrap then
		local ySize = ts:GetTextSize(text, 15, Library.font, Vector2.new(Label.AbsoluteSize.X, 1000)).Y
		Label.Size = UDim2.new(1, -10, 0, ySize + 10)
	end
	
	local label = {
		Label = Label,
		SetText = function(newText)
			Label.Text = newText
			if wrap then
				local ySize = ts:GetTextSize(newText, 15, Library.font, Vector2.new(Label.AbsoluteSize.X, 1000)).Y
				Label.Size = UDim2.new(1, -10, 0, ySize + 10)
			end
		end
	}
	
	return label
end

function Library.UISection:AddDivider()
	local DividerOuter = utility.newObject("Frame", {
		BackgroundColor3 = Library.colors.black,
		BorderColor3 = Library.colors.black,
		Size = UDim2.new(1, -10, 0, 2),
		Position = UDim2.new(0, 5, 0, 0),
		ZIndex = 5,
		Parent = self.content
	})
	
	local DividerInner = utility.newObject("Frame", {
		BackgroundColor3 = Library.colors.outline,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 6,
		Parent = DividerOuter
	})
end

function Library.UISection:AddDropdown(id, config)
	config = config or {}
	config.Text = config.Text or "Dropdown"
	config.Values = config.Values or {"Option 1", "Option 2", "Option 3"}
	config.Default = config.Default or 1
	config.Multi = config.Multi or false
	
	local dropdown = {
		Value = config.Multi and {} or nil,
		Values = config.Values,
		Multi = config.Multi,
		Type = "Dropdown",
		Callbacks = {},
		Config = config
	}
	
	if not config.Multi and type(config.Default) == "number" then
		dropdown.Value = config.Values[config.Default]
	elseif not config.Multi and type(config.Default) == "string" then
		dropdown.Value = config.Default
	elseif config.Multi and type(config.Default) == "table" then
		for _, val in pairs(config.Default) do
			if type(val) == "number" then
				dropdown.Value[config.Values[val]] = true
			elseif type(val) == "string" then
				dropdown.Value[val] = true
			end
		end
	end
	
	if not config.Compact then
		local Label = utility.newObject("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 15),
			Font = Library.font,
			Text = config.Text,
			TextColor3 = Library.colors.text,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = self.content
		})
		
		utility.newObject("UIPadding", {
			PaddingLeft = UDim.new(0, 5),
			Parent = Label
		})
	end
	
	local DropdownOuter = utility.newObject("Frame", {
		BackgroundColor3 = Library.colors.black,
		BorderColor3 = Library.colors.black,
		Size = UDim2.new(1, -10, 0, 25),
		Position = UDim2.new(0, 5, 0, 0),
		ZIndex = 5,
		Parent = self.content
	})
	
	local DropdownInner = utility.newObject("Frame", {
		BackgroundColor3 = Library.colors.main,
		BorderColor3 = Library.colors.outline,
		BorderMode = Enum.BorderMode.Inset,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 6,
		Parent = DropdownOuter
	})
	
	local DisplayLabel = utility.newObject("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 8, 0, 0),
		Size = UDim2.new(1, -30, 1, 0),
		Font = Library.font,
		Text = "",
		TextColor3 = Library.colors.text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 7,
		Parent = DropdownInner
	})
	
	local Arrow = utility.newObject("ImageLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -20, 0.5, -6),
		Size = UDim2.new(0, 12, 0, 12),
		Image = "http://www.roblox.com/asset/?id=6282522798",
		ZIndex = 8,
		Parent = DropdownInner
	})
	
	-- * Dropdown List
	local ListOuter = utility.newObject("Frame", {
		BackgroundColor3 = Library.colors.black,
		BorderColor3 = Library.colors.black,
		Size = UDim2.new(0, DropdownOuter.AbsoluteSize.X, 0, 0),
		Visible = false,
		ZIndex = 20,
		Parent = Library.ScreenGui
	})
	
	local ListInner = utility.newObject("Frame", {
		BackgroundColor3 = Library.colors.main,
		BorderColor3 = Library.colors.outline,
		BorderMode = Enum.BorderMode.Inset,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 21,
		Parent = ListOuter
	})
	
	local Scrolling = utility.newObject("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Library.colors.accent,
		ZIndex = 22,
		Parent = ListInner
	})
	
	local ListLayout = utility.newObject("UIListLayout", {
		Padding = UDim.new(0, 1),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = Scrolling
	})
	
	-- * Update position
	local function updateListPosition()
		ListOuter.Position = UDim2.fromOffset(
			DropdownOuter.AbsolutePosition.X,
			DropdownOuter.AbsolutePosition.Y + DropdownOuter.AbsoluteSize.Y + 1
		)
		ListOuter.Size = UDim2.new(0, DropdownOuter.AbsoluteSize.X, 0, math.min(#config.Values * 26, 208))
	end
	
	DropdownOuter:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateListPosition)
	DropdownOuter:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateListPosition)
	
	-- * Build dropdown items
	local items = {}
	
	local function buildItems()
		for _, child in pairs(Scrolling:GetChildren()) do
			if not child:IsA("UIListLayout") then
				child:Destroy()
			end
		end
		
		for i, value in ipairs(config.Values) do
			local Item = utility.newObject("Frame", {
				BackgroundColor3 = Library.colors.background,
				BorderColor3 = Library.colors.outline,
				Size = UDim2.new(1, -2, 0, 24),
				Position = UDim2.new(0, 1, 0, 0),
				ZIndex = 23,
				Parent = Scrolling
			})
			
			local ItemLabel = utility.newObject("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 6, 0, 0),
				Size = UDim2.new(1, -6, 1, 0),
				Font = Library.font,
				Text = value,
				TextColor3 = Library.colors.text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 24,
				Parent = Item
			})
			
			local isSelected = false
			
			local function updateSelected()
				if dropdown.Multi then
					isSelected = dropdown.Value[value] or false
				else
					isSelected = dropdown.Value == value
				end
				ItemLabel.TextColor3 = isSelected and Library.colors.accent or Library.colors.text
			end
			
			Item.InputBegan:Connect(function(input, gpe)
				if gpe then return end
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					if dropdown.Multi then
						dropdown.Value[value] = not dropdown.Value[value]
					else
						dropdown.Value = value
						dropdown:Close()
					end
					dropdown:Display()
					updateSelected()
					
					for _, cb in pairs(dropdown.Callbacks) do
						pcall(cb, dropdown.Value)
					end
					pcall(config.Callback, dropdown.Value)
				end
			end)
			
			Item.MouseEnter:Connect(function()
				Item.BackgroundColor3 = Library.colors.main
			end)
			
			Item.MouseLeave:Connect(function()
				Item.BackgroundColor3 = Library.colors.background
			end)
			
			updateSelected()
			items[value] = Item
		end
		
		Scrolling.CanvasSize = UDim2.new(0, 0, 0, #config.Values * 25)
	end
	
	function dropdown:Display()
		if dropdown.Multi then
			local text = ""
			for val, selected in pairs(dropdown.Value) do
				if selected then
					text = text .. val .. ", "
				end
			end
			DisplayLabel.Text = #text > 0 and text:sub(1, -3) or "--"
		else
			DisplayLabel.Text = dropdown.Value or "--"
		end
	end
	
	function dropdown:Open()
		updateListPosition()
		ListOuter.Visible = true
		Arrow.Rotation = 180
		Library.openedDropdown = ListOuter
	end
	
	function dropdown:Close()
		ListOuter.Visible = false
		Arrow.Rotation = 0
		Library.openedDropdown = nil
	end
	
	function dropdown:SetValue(val)
		if dropdown.Multi then
			local newTable = {}
			for _, v in pairs(val) do
				if type(v) == "string" then
					newTable[v] = true
				end
			end
			dropdown.Value = newTable
		else
			dropdown.Value = val
		end
		dropdown:Display()
		buildItems()
	end
	
	function dropdown:OnChanged(cb)
		table.insert(dropdown.Callbacks, cb)
		pcall(cb, dropdown.Value)
	end
	
	DropdownOuter.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if ListOuter.Visible then
				dropdown:Close()
			else
				dropdown:Open()
			end
		end
	end)
	
	uis.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if ListOuter.Visible and not utility.isMouseOverFrame(ListOuter) and not utility.isMouseOverFrame(DropdownOuter) then
				dropdown:Close()
			end
		end
	end)
	
	buildItems()
	dropdown:Display()
	
	utility.options[id] = dropdown
	self.elements[id] = dropdown
	
	return dropdown
end

-- * Utility functions

function utility.isMouseOverFrame(frame)
	local absPos, absSize = frame.AbsolutePosition, frame.AbsoluteSize
	local mousePos = uis:GetMouseLocation()
	
	return mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X
		and mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y
end

function utility.addTooltip(parent, text)
	local x, y = Library:GetTextBounds(text, Library.font, 14)
	
	local Tooltip = utility.newObject("Frame", {
		BackgroundColor3 = Library.colors.main,
		BorderColor3 = Library.colors.outline,
		Size = UDim2.new(0, x + 10, 0, y + 6),
		Visible = false,
		ZIndex = 100,
		Parent = Library.ScreenGui
	})
	
	local Label = utility.newObject("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 5, 0, 3),
		Size = UDim2.new(0, x, 0, y),
		Font = Library.font,
		Text = text,
		TextColor3 = Library.colors.text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 101,
		Parent = Tooltip
	})
	
	local hovering = false
	
	parent.MouseEnter:Connect(function()
		hovering = true
		Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 10)
		Tooltip.Visible = true
		
		while hovering do
			Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 10)
			rs.Heartbeat:Wait()
		end
	end)
	
	parent.MouseLeave:Connect(function()
		hovering = false
		Tooltip.Visible = false
	end)
end

-- * Global access

getgenv().Toggles = utility.toggles
getgenv().Options = utility.options
getgenv().Library = Library

return Library
