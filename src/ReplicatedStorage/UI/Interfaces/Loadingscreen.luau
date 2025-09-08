local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Features = PlayerGui:WaitForChild("LoadingScreen")
local Container = Features:WaitForChild("Container")

-- Récup des éléments
local loadbar = Container:WaitForChild("loadbar")
local fullBar = loadbar:WaitForChild("Full")
local gameLogo = Container:WaitForChild("gameLogo")
local headphoneLogo = Container:WaitForChild("headphoneLogo")
local sxLogo = Container:WaitForChild("sxLogo")
local headphoneText = Container:WaitForChild("headphoneText")
local presskeyText = Container:WaitForChild("presskeyText")

-- Tout rendre visible mais transparent
Container.Visible = true
loadbar.Visible = true
sxLogo.Visible = true
headphoneLogo.Visible = true
headphoneText.Visible = true
gameLogo.Visible = true
presskeyText.Visible = true

sxLogo.ImageTransparency = 1
headphoneLogo.ImageTransparency = 1
headphoneText.TextTransparency = 1
gameLogo.ImageTransparency = 1
presskeyText.TextTransparency = 1
fullBar.Size = UDim2.new(0,0,1,0)

local LoadingScreen = {}

-- Fonction utilitaire pour fade
local function tweenTransparency(obj, property, target, time)
    local tween = TweenService:Create(obj, TweenInfo.new(time), {[property] = target})
    tween:Play()
    tween.Completed:Wait()
end

-- Fonction pour charger les assets et mettre à jour la barre
local function preloadAssetsWithBar(assetList, bar)
    local total = #assetList
    if total == 0 then return end
    local loaded = 0

    -- Fonction pour mettre à jour la barre
    local function updateBar()
        local progress = loaded / total
        bar.Size = UDim2.new(progress,0,1,0)
    end

    -- Préchargement
    for _, asset in ipairs(assetList) do
        ContentProvider:PreloadAsync({asset})
        loaded = loaded + 1
        updateBar()
    end
end

function LoadingScreen:init()
    -- 1. SX Logo
    tweenTransparency(sxLogo, "ImageTransparency", 0, 0.5) -- fade in
    task.wait(2)
    tweenTransparency(sxLogo, "ImageTransparency", 1, 0.5) -- fade out

    -- 2. Headphone logo + text
    tweenTransparency(headphoneLogo, "ImageTransparency", 0, 0.5)
    tweenTransparency(headphoneText, "TextTransparency", 0, 0.5)
    task.wait(2)
    tweenTransparency(headphoneLogo, "ImageTransparency", 1, 0.5)
    tweenTransparency(headphoneText, "TextTransparency", 1, 0.5)

    -- 3. Game logo + loadbar
    tweenTransparency(gameLogo, "ImageTransparency", 0, 0.5)

    -- Liste des assets à précharger (mettre tes assets ici)
    local assetsToLoad = {
        -- game:GetService("ReplicatedStorage").Assets.Asset1,
        -- game:GetService("ReplicatedStorage").Assets.Asset2,
        -- Ajouter tous les assets nécessaires
    }

    -- Préchargement avec progression barre
    preloadAssetsWithBar(assetsToLoad, fullBar)

    -- 4. Press any key
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
