-- 自动瞄准脚本 with 彩色拖动开关
local replicated_storage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local camera = workspace.CurrentCamera
local run_service = game:GetService("RunService")
local tween_service = game:GetService("TweenService")
local utility = require(replicated_storage.Modules.Utility)

-- 自动瞄准开关状态
local aimbot_enabled = false

-- 获取所有玩家实体
local get_players = function()
    local entities = {}
    for _, child in pairs(workspace:GetChildren()) do
        if child:FindFirstChildOfClass("Humanoid") then
            table.insert(entities, child)
        elseif child.Name == "HurtEffect" then
            for _, hurt_player in pairs(child:GetChildren()) do
                if hurt_player.ClassName ~= "Highlight" then
                    table.insert(entities, hurt_player)
                end
            end
        end
    end
    return entities
end

-- 获取最近的玩家
local get_closest_player = function()
    local closest, closest_distance = nil, math.huge
    local character = players.LocalPlayer.Character
    if character == nil then
        return nil
    end
    
    for _, player in pairs(get_players()) do
        if player == players.LocalPlayer.Character then
            continue
        end
        if not player:FindFirstChild("HumanoidRootPart") then
            continue
        end
        
        local position, on_screen = camera:WorldToViewportPoint(player.HumanoidRootPart.Position)
        if not on_screen then
            continue
        end
        
        local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local distance = (center - Vector2.new(position.X, position.Y)).Magnitude
        
        if distance < closest_distance then
            closest = player
            closest_distance = distance
        end
    end
    
    return closest
end

-- 保存原始函数
local old_raycast = utility.Raycast

-- 修改的射线检测函数
utility.Raycast = function(...)
    local arguments = {...}
    
    if aimbot_enabled and #arguments > 0 and arguments[4] == 999 then
        local closest = get_closest_player()
        if closest and closest:FindFirstChild("Head") then
            arguments[3] = closest.Head.Position
        end
    end
    
    return old_raycast(table.unpack(arguments))
end

-- 创建GUI界面
local function createAimbotGUI()
    -- 创建主屏幕GUI
    local screen_gui = Instance.new("ScreenGui")
    screen_gui.Name = "AimbotGUI"
    screen_gui.Parent = players.LocalPlayer:WaitForChild("PlayerGui")
    screen_gui.ResetOnSpawn = false
    screen_gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- 创建主按钮框架
    local main_frame = Instance.new("Frame")
    main_frame.Name = "MainFrame"
    main_frame.Size = UDim2.new(0, 100, 0, 50)
    main_frame.Position = UDim2.new(0, 10, 0, 10)
    main_frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    main_frame.BackgroundTransparency = 0.3
    main_frame.BorderSizePixel = 0
    main_frame.Parent = screen_gui

    -- 圆角效果
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = main_frame

    -- 彩色边框
    local border_frame = Instance.new("Frame")
    border_frame.Name = "Border"
    border_frame.Size = UDim2.new(1, 4, 1, 4)
    border_frame.Position = UDim2.new(0, -2, 0, -2)
    border_frame.BackgroundColor3 = Color3.new(1, 0, 0) -- 默认红色
    border_frame.BackgroundTransparency = 0.2
    border_frame.BorderSizePixel = 0
    border_frame.ZIndex = -1
    border_frame.Parent = main_frame

    local border_corner = Instance.new("UICorner")
    border_corner.CornerRadius = UDim.new(0, 14)
    border_corner.Parent = border_frame

    -- 开关按钮
    local toggle_button = Instance.new("TextButton")
    toggle_button.Name = "ToggleButton"
    toggle_button.Size = UDim2.new(0.8, 0, 0.6, 0)
    toggle_button.Position = UDim2.new(0.1, 0, 0.2, 0)
    toggle_button.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5) -- 默认灰色
    toggle_button.BorderSizePixel = 0
    toggle_button.Text = "已关闭" -- 默认关闭状态
    toggle_button.TextColor3 = Color3.new(1, 1, 1)
    toggle_button.TextScaled = true
    toggle_button.Font = Enum.Font.GothamBold
    toggle_button.Parent = main_frame

    local button_corner = Instance.new("UICorner")
    button_corner.CornerRadius = UDim.new(0, 8)
    button_corner.Parent = toggle_button

    -- 标题标签
    local title_label = Instance.new("TextLabel")
    title_label.Name = "Title"
    title_label.Size = UDim2.new(1, 0, 0, 15)
    title_label.Position = UDim2.new(0, 0, -0.4, 0)
    title_label.BackgroundTransparency = 1
    title_label.Text = "自动瞄准"
    title_label.TextColor3 = Color3.new(1, 1, 1)
    title_label.TextSize = 12
    title_label.TextScaled = false
    title_label.Font = Enum.Font.GothamBold
    title_label.Parent = main_frame

    -- 拖动功能
    local dragging = false
    local drag_input
    local drag_start
    local start_pos

    local function update_input(input)
        local delta = input.Position - drag_start
        main_frame.Position = UDim2.new(
            start_pos.X.Scale, 
            start_pos.X.Offset + delta.X,
            start_pos.Y.Scale, 
            start_pos.Y.Offset + delta.Y
        )
    end

    main_frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            drag_start = input.Position
            start_pos = main_frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    main_frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            drag_input = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == drag_input and dragging then
            update_input(input)
        end
    end)

    -- 颜色切换功能
    local colors = {
        Color3.new(1, 0, 0),    -- 红色
        Color3.new(1, 0.5, 0),  -- 橙色
        Color3.new(1, 1, 0),    -- 黄色
        Color3.new(0, 1, 0),    -- 绿色
        Color3.new(0, 0.5, 1),  -- 浅蓝
        Color3.new(0.5, 0, 1)   -- 紫色
    }
    
    local current_color_index = 1
    local color_cycling = true -- 控制颜色循环的标志

    -- 边框颜色动画
    local color_tween_info = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    
    local function cycle_border_color()
        if not color_cycling then return end
        
        current_color_index = current_color_index + 1
        if current_color_index > #colors then
            current_color_index = 1
        end
        
        local color_tween = tween_service:Create(
            border_frame,
            color_tween_info,
            {BackgroundColor3 = colors[current_color_index]}
        )
        color_tween:Play()
    end

    -- 自动颜色循环（仅当关闭时）
    spawn(function()
        while screen_gui.Parent do
            wait(2) -- 每2秒切换一次颜色
            if not aimbot_enabled then
                cycle_border_color()
            end
        end
    end)

    -- 切换按钮功能
    toggle_button.MouseButton1Click:Connect(function()
        aimbot_enabled = not aimbot_enabled
        
        if aimbot_enabled then
            -- 开启状态 - 红色主题
            toggle_button.Text = "已开启"
            toggle_button.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2) -- 红色
            border_frame.BackgroundColor3 = Color3.new(1, 0, 0) -- 纯红色边框
            border_frame.BackgroundTransparency = 0.1
            color_cycling = false -- 停止颜色循环
            
            -- 开启时的动画效果
            local tween = tween_service:Create(
                toggle_button,
                TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                {Size = UDim2.new(0.85, 0, 0.65, 0)}
            )
            tween:Play()
            
            -- 边框脉动效果
            local pulse_tween = tween_service:Create(
                border_frame,
                TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true),
                {BackgroundTransparency = 0.3}
            )
            pulse_tween:Play()
        else
            -- 关闭状态 - 灰色主题
            toggle_button.Text = "已关闭"
            toggle_button.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5) -- 灰色
            border_frame.BackgroundTransparency = 0.2
            color_cycling = true -- 恢复颜色循环
            
            -- 停止所有边框动画
            for _, tween in pairs(border_frame:GetTweens()) do
                tween:Cancel()
            end
            
            -- 关闭时的动画效果
            local tween = tween_service:Create(
                toggle_button,
                TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                {Size = UDim2.new(0.8, 0, 0.6, 0)}
            )
            tween:Play()
        end
    end)

    -- 鼠标悬停效果
    toggle_button.MouseEnter:Connect(function()
        if not aimbot_enabled then
            local tween = tween_service:Create(
                toggle_button,
                TweenInfo.new(0.2),
                {BackgroundColor3 = Color3.new(0.6, 0.6, 0.6)}
            )
            tween:Play()
        else
            -- 开启状态下的悬停效果
            local tween = tween_service:Create(
                toggle_button,
                TweenInfo.new(0.2),
                {BackgroundColor3 = Color3.new(0.9, 0.3, 0.3)}
            )
            tween:Play()
        end
    end)

    toggle_button.MouseLeave:Connect(function()
        if not aimbot_enabled then
            local tween = tween_service:Create(
                toggle_button,
                TweenInfo.new(0.2),
                {BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)}
            )
            tween:Play()
        else
            -- 开启状态下的离开效果
            local tween = tween_service:Create(
                toggle_button,
                TweenInfo.new(0.2),
                {BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)}
            )
            tween:Play()
        end
    end)

    return screen_gui
end

-- 等待玩家加载后创建GUI
players.LocalPlayer:WaitForChild("PlayerGui")
createAimbotGUI()

-- 玩家重生时重新创建GUI
players.LocalPlayer.CharacterAdded:Connect(function()
    wait(1) -- 等待角色完全加载
    if not players.LocalPlayer.PlayerGui:FindFirstChild("AimbotGUI") then
        createAimbotGUI()
    end
end)

print("自动瞄准脚本已加载！使用屏幕左上角的开关控制自动瞄准。")