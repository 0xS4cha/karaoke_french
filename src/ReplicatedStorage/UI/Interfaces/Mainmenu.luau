local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local photo = game.Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
local StarterGui = game:GetService("StarterGui")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Features = PlayerGui:WaitForChild("Main_menu")
local Menu = Features:WaitForChild("Background")
local Profile = Menu:WaitForChild("Profile")
local Camera = workspace.CurrentCamera
local cameraConnection

local Mainmenu = {}

function Mainmenu:init()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
    Profile.ImageLabel.Image = photo
    self:initButton()
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

        -- Mouvement fluide de la caméra
        if moving then
            CamPart.CFrame = CamPart.CFrame:Lerp(CFrame.new(targetPosition), 0.1)
        else
            CamPart.CFrame = CamPart.CFrame:Lerp(CFrame.new(targetPosition), 0.2)
        end

        -- Caméra orientée vers introPart avec smooth Lerp
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
    local buttons = {
        Menu.Container.storeButton,
        Menu.Container.creditButton,
        Menu.Container.playButton,
        Menu.Container.bottomGrid.inviteButton,
        Menu.Container.bottomGrid.serverButton,
    }
    
    for _, button in ipairs(buttons) do
        button.selectZone.AutoButtonColor = false
        local originalSize = button.Size


        button.selectZone.MouseEnter:Connect(function()
            TweenService:Create(
                button,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = originalSize + UDim2.new(0, 10, 0, 10)}
            ):Play()
        end)
    
        button.selectZone.MouseLeave:Connect(function()
            TweenService:Create(
                button,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = originalSize}
            ):Play()
        end)
    end
end

return Mainmenu