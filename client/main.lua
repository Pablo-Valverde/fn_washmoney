Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local PED_ID = PlayerPedId()
local ID = 0

ESX = nil


local isWashing = false
local _locked = false

local triggerID = nil
local lastPosition = nil


--#region AUXILIAR FUNCTIONS

function distance (p1, p2)
    return math.sqrt((p1.x - p2.x)^2 + (p1.y - p2.y)^2 + (p1.z - p2.z)^2)
end

--[[
    Loads an animaton dictionary, then loads an animation by its name
]]--
local function playAnimation(dictionary, animation_name)
    RequestAnimDict(dictionary)
    while (not HasAnimDictLoaded(dictionary)) do Citizen.Wait(0) end
    TaskPlayAnim(PED_ID, dictionary, animation_name, 5.0, -1.0, -1, Washing.Animation.Flag, 0, false, false, false)
end

--[[
    wrapper for easier top-left corner information boxes creation
]]--
local function hintToDisplay(text)
	SetTextComponentFormat("STRING")
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

--#endregion

Citizen.CreateThread(function ()

	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

    PlayerData = ESX.GetPlayerData()

    if Blip.Display ~= 0 then
        for _, v in pairs(Marker.Triggers) do
            local blip = AddBlipForCoord(v.x, v.y, v.z)
            SetBlipSprite(blip, Blip.Icon)
            SetBlipDisplay(blip, Blip.Display)
            SetBlipScale(blip, Blip.Scale)
            SetBlipColour(blip, Blip.Color)
            SetBlipAsShortRange(blip, Blip.IsShortRange)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(_U('blip_name'))
            EndTextCommandSetBlipName(blip)
        end
    end
end)

--[[
    Locks the washing in order to avoid the user to spam the button, the times it locks it can be configured at
    the config.lua file Config.SpamLock
]]--
local function Lock()
    if _locked then return end
    _locked = true
    Citizen.CreateThread(function ()
        Citizen.Wait(Config.SpamLock)
        _locked = false 
    end)
end

local function StopWash()
    if not isWashing then return end
    isWashing = false
    Lock()
end

RegisterNetEvent('fn:finishWash', function ()
    StopWash()
end)

--[[
    If the user is not locked or actually washing, starts the washing process.
    1.First thread controlls the new inputs from the user, checking if BACKSPACE is pressed and 
        showing a tooltip at the top-left corner of the screen
    2.Second thread waits for Washing.Delay (config.lua) and sends to the server event of 'fn:washMoney'
    3.Third thread plays the animation given at the config.lua until the player stops washing
    Then checks if the player has leaved the place, if so, cancel the washing
]]--
local function StartWash()
    if _locked then return end
    if isWashing then return end
    isWashing = true

    lastPosition = GetEntityCoords(PED_ID)

    Citizen.CreateThread(function ()
        repeat
            Citizen.Wait(5)

            if IsControlJustPressed(0, Keys['BACKSPACE']) then StopWash() end 

            hintToDisplay(_U('stop_washing'))
        until not isWashing
    end)

    TriggerServerEvent('fn:beforeWash')

    Citizen.CreateThread(function (tID)
        ID = tID

        while true do
            Citizen.Wait(Washing.Delay)

            if not isWashing or tID ~= ID then return end
            TriggerServerEvent('fn:washMoney', triggerID)
        end
    end)

    if Washing.Animation.Enabled then
        Citizen.CreateThread(function ()
            repeat
                playAnimation(Washing.Animation.Dictionary, Washing.Animation.Name)
                Citizen.Wait(Washing.Animation.RestartAfter)
            until not isWashing
        end)
    end

    while isWashing do
        Citizen.Wait(100)
    
        local playerPos = GetEntityCoords(PED_ID)
        local dist = distance(playerPos, lastPosition)
        
        if dist > Marker.MaxFreeMovementDistance then StopWash() end
        if Washing.Animation.Freeze then FreezeEntityPosition(PED_ID, isWashing) end
    end

    if Washing.Animation.Enabled then ClearPedTasksImmediately(PED_ID) end
end

Citizen.CreateThread(function ()
    local dist = math.huge

    while true do
        if isWashing or _locked then -- If the player is actually washing money, hide the world text, avoid him from reusing the marker and wait for 100 ms before repeating this piece of code
            Citizen.Wait(100)
            goto continue
        else
            Citizen.Wait(0)
        end

        playerPos = GetEntityCoords(PED_ID)
        for k, v in pairs(Marker.Triggers) do
            dist = distance(playerPos, v)
            if dist < Marker.AllowInteractionDistance then
                ESX.Game.Utils.DrawText3D(v + WorldText.Offset, _U('start_washing'), WorldText.TextSize)
                if IsControlJustPressed(0, Keys['E']) then
                    triggerID = k
                    Citizen.CreateThread(StartWash, triggerID)
                end		
            end
            if Marker.Draw then
                if dist < Marker.DrawDistance then
                    DrawMarker(Marker.Type, v.x, v.y, v.z, 0, 0, 0, 0, 0, 0, Marker.Size.x, Marker.Size.y, Marker.Size.z, Marker.Color.r, Marker.Color.g, Marker.Color.b, 200, 0, 0, 0, 0)
                end
            end
        end
        ::continue::
    end
end)
