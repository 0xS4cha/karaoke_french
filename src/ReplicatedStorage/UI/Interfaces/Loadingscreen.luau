local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local assets = game.Workspace:GetDescendants()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Features = PlayerGui:WaitForChild("LoadingScreen")
local Mainmenu = require(ReplicatedStorage.UI.Interfaces.Mainmenu)
local Container = Features:WaitForChild("Container")

local loadbar = Container:WaitForChild("loadbar")
local full = loadbar:WaitForChild("Full")
local gameLogo = Container:WaitForChild("gameLogo")
local headphoneLogo = Container:WaitForChild("headphoneLogo")
local sxLogo = Container:WaitForChild("sxLogo")
local skipButton = Container:WaitForChild("skipButton")
local headphoneText = Container:WaitForChild("headphoneText")
local presskeyText = Container:WaitForChild("presskeyText")

Container.Visible = true
sxLogo.ImageTransparency = 1
headphoneLogo.ImageTransparency = 1
headphoneText.TextTransparency = 1
gameLogo.ImageTransparency = 1
presskeyText.TextTransparency = 1

local LoadingScreen = {}

local function tweenTransparency(obj, property, target, time)
    local tween = TweenService:Create(obj, TweenInfo.new(time), {[property] = target})
    tween:Play()
    tween.Completed:Wait()
end

local function loadAssets(assets)
    local total = #assets
    local loaded = 0
    full.Size = UDim2.new(0,0,1,0)

    for _, asset in ipairs(assets) do
        ContentProvider:PreloadAsync({asset})
        loaded += 1
        local progress = loaded / total
        full.Size = UDim2.new(progress, 0, 1, 0)
    end
end

function LoadingScreen:init()
    task.spawn(function()
        sxLogo.Visible = true
        tweenTransparency(sxLogo, "ImageTransparency", 0, 0.5)
        task.wait(2)
        tweenTransparency(sxLogo, "ImageTransparency", 1, 0.5)
        sxLogo.Visible = false

        headphoneLogo.Visible = true
        headphoneText.Visible = true
        tweenTransparency(headphoneLogo, "ImageTransparency", 0, 0.5)
        tweenTransparency(headphoneText, "TextTransparency", 0, 0.5)
        task.wait(2)
        tweenTransparency(headphoneLogo, "ImageTransparency", 1, 0.5)
        tweenTransparency(headphoneText, "TextTransparency", 1, 0.5)
        headphoneLogo.Visible = false
        headphoneText.Visible = false

        gameLogo.Visible = true
        tweenTransparency(gameLogo, "ImageTransparency", 0, 0.5)

        local assetsToLoad = {
            -- ReplicatedStorage.Assets.Asset1, etc.
        }

        loadbar.Visible = true

        while not Mainmenu:isReady() do
            task.wait()
        end

        skipButton.Visible = true

        local skipConnection
        skipConnection = skipButton.MouseButton1Click:Connect(function()
            if skipConnection then
                skipConnection:Disconnect()
                skipConnection = nil
            end
            Mainmenu:showWithFadeIn()
            LoadingScreen:destroy()
        end)

        loadAssets(assets)
        loadAssets(assetsToLoad)

        presskeyText.Visible = true
        skipButton.Visible = false
        tweenTransparency(presskeyText, "TextTransparency", 0, 0.5)

        local connection
        connection = UserInputService.InputBegan:Connect(function(input, processed)
            if not processed then
                connection:Disconnect()
                Mainmenu:showWithFadeIn()
                LoadingScreen:destroy()
            end
        end)
    end)
end

function LoadingScreen:destroy()
    Features:Destroy()
end

return LoadingScreen
