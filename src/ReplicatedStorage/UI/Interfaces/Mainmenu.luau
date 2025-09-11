local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local SocialService = game:GetService('SocialService')

local LocalPlayer = Players.LocalPlayer
local photo = game.Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Features = PlayerGui:WaitForChild("Main_menu")
local Menu = Features:WaitForChild("Background")
local CreditMenu = Features:WaitForChild('Credit')
local Profile = Menu:WaitForChild("Profile")
local Content = Profile:WaitForChild('Content')
local Camera = workspace.CurrentCamera
local cameraConnection

local Mainmenu = {}
local Creditmenu = {}

Mainmenu.ready = false

local buttons = {
    { dict = Menu.Container.storeButton, action = function() end},
    { dict = Menu.Container.creditButton, action = function() Mainmenu:openSubmenu(Creditmenu) end},
    { dict = Menu.Container.playButton},
    { dict = Menu.Container.bottomGrid.inviteButton, action = function() SocialService:PromptGameInvite(LocalPlayer) end},
    { dict = Menu.Container.bottomGrid.serverButton},
}

function Mainmenu:init()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
    Profile.ImageLabel.Image = photo
    Content.displayName.Text = LocalPlayer.DisplayName
    Content.Username.Text = '@' .. LocalPlayer.Name
    self:initButton()
    Creditmenu:init()
    Mainmenu.ready = true
end

function Mainmenu:isReady()
    return Mainmenu.ready
end

function Mainmenu:setupRigInCamFolder()
    local camFolder = workspace:WaitForChild("camFolder")
    local introPart = camFolder:WaitForChild("introPart")

    local humanoidDescription = Players:GetHumanoidDescriptionFromUserId(LocalPlayer.UserId)
    local rig = Players:CreateHumanoidModelFromDescription(humanoidDescription, Enum.HumanoidRigType.R15)
    rig.Name = "MenuPlayer"
    rig.Parent = camFolder

    if rig.PrimaryPart then
        rig:PivotTo(introPart.CFrame * CFrame.new(2, 0, 5) * CFrame.Angles(0, math.rad(180), 0))
    end

    for _, part in ipairs(rig:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.CastShadow = true
            if part.Name == "HumanoidRootPart" then
                part.Anchored = true
            else
                part.Anchored = false
            end
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part.Transparency = 0
        end
    end

    local humanoid = rig:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
        local sitAnim = Instance.new("Animation")
        sitAnim.AnimationId = "rbxassetid://507768133"
        local track = animator:LoadAnimation(sitAnim)
        track.Priority = Enum.AnimationPriority.Action
        track:Play()
    end

    return rig
end



function Mainmenu:setupMenuCam()
    -- Clone du camPart et placement
    local CamPart = ReplicatedStorage:FindFirstChild("camPart"):Clone()
    CamPart.Parent = workspace:FindFirstChild("camFolder")

    local targetPart = CamPart.Parent:FindFirstChild("introPart") -- le canapé ou la cible
    local Camera = workspace.CurrentCamera
    Camera.CameraType = Enum.CameraType.Scriptable

    -- Position de base de la caméra par rapport au canapé
    CamPart.Position = targetPart.Position + Vector3.new(10, 2, 2) -- ajuste selon ta scène
    local originalPosition = CamPart.Position

    local moveFactor = 0.0005
    local previousMouseX, previousMouseY = nil, nil
    local MAX_POSITION = 0.5
    local targetPosition = originalPosition
    local moving = false
    local resetContent = true

    cameraConnection = RunService.RenderStepped:Connect(function()
        if resetContent then
            resetContent = false
        end

        local mouse = LocalPlayer:GetMouse()
        local screenX = Camera.ViewportSize.X
        local screenY = Camera.ViewportSize.Y

        local leftoverScreenX = screenX - mouse.X
        local leftoverScreenY = screenY - mouse.Y

        local DistanceFromOriginX = (screenX/2) - leftoverScreenX
        local DistanceFromOriginY = leftoverScreenY - (screenY/2)

        local clampedX = math.clamp(DistanceFromOriginX * moveFactor, -MAX_POSITION, MAX_POSITION)
        local clampedY = math.clamp(DistanceFromOriginY * moveFactor, -MAX_POSITION, MAX_POSITION)

        if previousMouseX and previousMouseY then
            local mouseMoved = (DistanceFromOriginX ~= previousMouseX) or (DistanceFromOriginY ~= previousMouseY)
            if mouseMoved then
                moving = true
                targetPosition = originalPosition + Vector3.new(clampedX, clampedY, 0)
            else
                moving = false
            end
        end

        if moving then
            CamPart.CFrame = CamPart.CFrame:Lerp(CFrame.new(targetPosition), 0.1)
        else
            CamPart.CFrame = CamPart.CFrame:Lerp(CFrame.new(targetPosition), 0.2)
        end

        local desiredCFrame = CFrame.lookAt(CamPart.Position, targetPart.Position)
        Camera.CFrame = Camera.CFrame:Lerp(desiredCFrame, 0.2)

        previousMouseX = DistanceFromOriginX
        previousMouseY = DistanceFromOriginY
    end)
end


Mainmenu.showWithFadeIn = function()
    Menu.Visible = true
    Menu.BackgroundTransparency = 1
    Mainmenu:setupMenuCam()
    Mainmenu:setupRigInCamFolder()
    local tween = TweenService:Create(Menu, TweenInfo.new(1), {BackgroundTransparency = 0})
    tween:Play()
end

Mainmenu.toggleVisibility = function(bool)
    if not bool then
        bool = not Menu.Visibile
    end
    Menu.Visible = bool
end

function Mainmenu:initButton()    
    for _, button in ipairs(buttons) do
        button.dict.selectZone.AutoButtonColor = false
        local originalSize = button.dict.Size

        button.dict.selectZone.MouseButton1Click:Connect(function()
            if button.action then
                button.action()
            end
        end)

        button.dict.selectZone.MouseEnter:Connect(function()
            TweenService:Create(
                button.dict,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = originalSize + UDim2.new(0, 10, 0, 10)}
            ):Play()
        end)
    
        button.dict.selectZone.MouseLeave:Connect(function()
            TweenService:Create(
                button.dict,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = originalSize}
            ):Play()
        end)
    end
end

function Mainmenu:openSubmenu(submenu)
    submenu:toggleView(true)
end
------------------------------
---       CREDITMENU       ---
------------------------------

local creditList = {
    {
        categoryLabel = 'Equipe de dévelopement',
        memberList = {
            { displayName = 'Sacha_dev', userName = 'kx_syrone', job = 'Createur & Dev'}
        }
    },
    {
        categoryLabel = 'Autre',
        memberList = {
            { displayName = 'capwonbang', userName = 'capwonbang', job = 'Support mental'}
        }
    }
}

function Creditmenu:init()

    local ScrollingFrame = CreditMenu:WaitForChild('ScrollingFrame')
    local playerExample = ScrollingFrame:WaitForChild('playerExample')
    local separatorExample = ScrollingFrame:WaitForChild('separatorExample')

    for i = 1, #creditList do
        local data = creditList[i]
        local newSeparator = separatorExample:Clone()
		newSeparator.Name = i .. '_separator'
		newSeparator.TextLabel.Text = data.categoryLabel
		newSeparator.Visible = true
		newSeparator.Parent = ScrollingFrame

        for v = 1, #data.memberList do
            local member = data.memberList[v]
            local newMember = playerExample:Clone()
            newMember.Name = v .. i .. '_member'
            newMember.job.Text = member.job
            newMember.username.Text = '@' .. member.userName
            newMember.displayname.Text = member.displayName
            newMember.Visible = true
            newMember.Parent = ScrollingFrame
        end
    end
end

function Creditmenu:toggleView(bool)
    if not bool then
        bool = not Creditmenu.Visible
    end
    CreditMenu.Visible = bool
end

return Mainmenu