local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- 踢出功能函数
local function KickPlayer(targetName, kickMessage)
    local message = kickMessage or "你已被踢出游戏"
    local kicked = false    
    if not targetName or targetName == "" then
        local localPlayer = Players.LocalPlayer
        if localPlayer then
            localPlayer:Kick(message)
            print("已踢出自己: " .. localPlayer.Name)
            return true
        end
        return false
    end   
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name == targetName then
            player:Kick(message)
            print("已踢出玩家: " .. player.Name)
            kicked = true
            break
        end
    end    
    if not kicked then
        print("未找到玩家: " .. targetName)
    end    
    return kicked
end

-- 创建主界面
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KickAlertGui"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

-- 创建主容器（缩小50%，从屏幕右侧开始）
local MainFrame = Instance.new("Frame")
MainFrame.Name = "KickAlert"
MainFrame.Size = UDim2.new(0, 160, 0, 100) -- 缩小50%
MainFrame.Position = UDim2.new(1, 10, 0, 10) -- 从屏幕右侧外开始
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BackgroundTransparency = 0.2 -- 半透明效果
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

-- 添加圆角
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8) -- 缩小圆角
UICorner.Parent = MainFrame

-- 添加阴影效果
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(100, 100, 150)
UIStroke.Thickness = 1 -- 缩小边框
UIStroke.Transparency = 0.3
UIStroke.Parent = MainFrame

-- 标题栏
local TitleFrame = Instance.new("Frame")
TitleFrame.Size = UDim2.new(1, 0, 0, 20) -- 缩小高度
TitleFrame.Position = UDim2.new(0, 0, 0, 0)
TitleFrame.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
TitleFrame.BackgroundTransparency = 0.1
TitleFrame.BorderSizePixel = 0
TitleFrame.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -10, 1, 0)
TitleLabel.Position = UDim2.new(0, 5, 0, 0) -- 调整边距
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "秋容提醒"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 10 -- 缩小字体
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleFrame

-- 内容区域
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -10, 1, -50) -- 调整尺寸
ContentFrame.Position = UDim2.new(0, 5, 0, 25) -- 调整位置
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- 添加文本内容
local ContentLabel = Instance.new("TextLabel")
ContentLabel.Size = UDim2.new(1, 0, 1, 0)
ContentLabel.Position = UDim2.new(0, 0, 0, 0)
ContentLabel.BackgroundTransparency = 1
ContentLabel.Text = "你已违规，将被踢出\n原因:恶意捣乱\n你有权限拒绝但仅限这一次警告！"
ContentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ContentLabel.TextSize = 8 -- 缩小字体
ContentLabel.Font = Enum.Font.Gotham
ContentLabel.TextWrapped = true
ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
ContentLabel.Parent = ContentFrame

-- 按钮容器
local ButtonFrame = Instance.new("Frame")
ButtonFrame.Size = UDim2.new(1, -10, 0, 20) -- 调整尺寸
ButtonFrame.Position = UDim2.new(0, 5, 1, -25) -- 调整位置
ButtonFrame.BackgroundTransparency = 1
ButtonFrame.Parent = MainFrame

-- 取消按钮（左边）
local CancelButton = Instance.new("TextButton")
CancelButton.Size = UDim2.new(0.45, 0, 1, 0)
CancelButton.Position = UDim2.new(0, 0, 0, 0)
CancelButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
CancelButton.BackgroundTransparency = 0.3
CancelButton.Text = "取消"
CancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CancelButton.TextSize = 8 -- 缩小字体
CancelButton.Font = Enum.Font.GothamBold
CancelButton.Parent = ButtonFrame

local CancelCorner = Instance.new("UICorner")
CancelCorner.CornerRadius = UDim.new(0, 4) -- 缩小圆角
CancelCorner.Parent = CancelButton

-- 踢出按钮（右边）
local KickButton = Instance.new("TextButton")
KickButton.Size = UDim2.new(0.45, 0, 1, 0)
KickButton.Position = UDim2.new(0.55, 0, 0, 0)
KickButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
KickButton.BackgroundTransparency = 0.2
KickButton.Text = "踢出"
KickButton.TextColor3 = Color3.fromRGB(255, 255, 255)
KickButton.TextSize = 8 -- 缩小字体
KickButton.Font = Enum.Font.GothamBold
KickButton.Parent = ButtonFrame

local KickCorner = Instance.new("UICorner")
KickCorner.CornerRadius = UDim.new(0, 4) -- 缩小圆角
KickCorner.Parent = KickButton

-- 将主界面添加到屏幕
MainFrame.Parent = ScreenGui

-- 创建滑动动画
local function slideIn()
    local targetPosition = UDim2.new(1, -170, 0, 10) -- 滑动到右上角，调整位置
    local tweenInfo = TweenInfo.new(
        0.8, -- 持续时间
        Enum.EasingStyle.Quad, -- 缓动样式
        Enum.EasingDirection.Out -- 缓动方向
    )
    
    local tween = TweenService:Create(MainFrame, tweenInfo, {Position = targetPosition})
    tween:Play()
end

-- 按钮功能
CancelButton.MouseButton1Click:Connect(function()
    -- 点击取消按钮，滑动出去并移除界面
    local tweenOut = TweenService:Create(
        MainFrame, 
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {Position = UDim2.new(1, 10, 0, 10)}
    )
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        ScreenGui:Destroy()
    end)
end)

KickButton.MouseButton1Click:Connect(function()
    -- 点击踢出按钮，执行踢出逻辑
    print("执行踢出操作")
    
    -- 先关闭UI
    local tweenOut = TweenService:Create(
        MainFrame, 
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {Position = UDim2.new(1, 10, 0, 10)}
    )
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- 延迟一小段时间后执行踢出
    wait(0.5)
    
    -- 调用踢出函数
    KickPlayer("", "你已违规，已被踢出")
end)

-- 启动动画
slideIn()

-- 可选：添加鼠标悬停效果
local function addHoverEffect(button, originalColor, hoverColor)
    local originalTransparency = button.BackgroundTransparency
    
    button.MouseEnter:Connect(function()
        button.BackgroundTransparency = originalTransparency - 0.1
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundTransparency = originalTransparency
    end)
end

addHoverEffect(CancelButton, Color3.fromRGB(80, 80, 100), Color3.fromRGB(100, 100, 130))
addHoverEffect(KickButton, Color3.fromRGB(200, 60, 60), Color3.fromRGB(220, 80, 80))

-- 将踢出函数设为全局，以便其他脚本使用
_G.KickPlayer = KickPlayer
