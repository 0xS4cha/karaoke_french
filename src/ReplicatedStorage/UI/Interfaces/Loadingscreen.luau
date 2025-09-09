local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")

local LocalPlayer = Players.LocalPlayer
local assets = game.Workspace:GetDescendants()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Features = PlayerGui:WaitForChild("LoadingScreen")
local Container = Features:WaitForChild("Container")

-- Récup des éléments
local loadbar = Container:WaitForChild("loadbar")
local full = loadbar:WaitForChild("Full")
local gameLogo = Container:WaitForChild("gameLogo")
local headphoneLogo = Container:WaitForChild("headphoneLogo")
local sxLogo = Container:WaitForChild("sxLogo")
local headphoneText = Container:WaitForChild("headphoneText")
local presskeyText = Container:WaitForChild("presskeyText")

-- Tout rendre visible mais transparent
Container.Visible = true


sxLogo.ImageTransparency = 1
headphoneLogo.ImageTransparency = 1
headphoneText.TextTransparency = 1
gameLogo.ImageTransparency = 1
presskeyText.TextTransparency = 1


local LoadingScreen = {}

-- Fonction utilitaire pour fade
local function tweenTransparency(obj, property, target, time)
    local tween = TweenService:Create(obj, TweenInfo.new(time), {[property] = target})
    tween:Play()
    tween.Completed:Wait()
end

-- Fonction principale
local function loadAssets(assets)
    local total = #assets
    local loaded = 0

    full.Size = UDim2.new(0,0,1,0)
    for _, asset in ipairs(assets) do
        -- Précharger l'asset
        ContentProvider:PreloadAsync({asset})

        -- Incrémenter la progression
        loaded += 1
        local progress = loaded / total
        full.Size = UDim2.new(progress, 0, 1, 0)
    end
end

function LoadingScreen:init()
    -- 1. SX Logo
    sxLogo.Visible = true
    tweenTransparency(sxLogo, "ImageTransparency", 0, 0.5) -- fade in
    task.wait(2)
    tweenTransparency(sxLogo, "ImageTransparency", 1, 0.5) -- fade out
    sxLogo.Visible = false

    -- 2. Headphone logo + text
    headphoneLogo.Visible = true
    headphoneText.Visible = true

    tweenTransparency(headphoneLogo, "ImageTransparency", 0, 0.5)
    tweenTransparency(headphoneText, "TextTransparency", 0, 0.5)
    task.wait(2)
    tweenTransparency(headphoneLogo, "ImageTransparency", 1, 0.5)
    tweenTransparency(headphoneText, "TextTransparency", 1, 0.5)
    headphoneLogo.Visible = false
    headphoneText.Visible = false

    -- 3. Game logo + loadbar
    gameLogo.Visible = true
    tweenTransparency(gameLogo, "ImageTransparency", 0, 0.5)

    -- Liste des assets à précharger (mettre tes assets ici)
    local assetsToLoad = {
        --game:GetService("ReplicatedStorage").Assets.Asset1,

    }

    -- Préchargement avec progression barre
    loadbar.Visible = true
    loadAssets(assets)
    loadAssets(assetsToLoad)
    -- 4. Press any key
    presskeyText.Visible = true
    tweenTransparency(presskeyText, "TextTransparency", 0, 0.5)

    -- Attente input joueur
    local connection
    connection = UserInputService.InputBegan:Connect(function(input, processed)
        if not processed then
            connection:Disconnect()
            self:destroy()
        end
    end)
end

function LoadingScreen:destroy()
    Features:Destroy()
end

return LoadingScreen
