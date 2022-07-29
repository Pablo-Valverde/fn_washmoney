max_distance = 0

Citizen.CreateThread(function () max_distance = Marker.AllowInteractionDistance + Marker.MaxFreeMovementDistance + 1 end)

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
	ESX = obj
end)

--#region AUXILIAR FUNCTIONS

function distance (p1, p2)
    return math.sqrt((p1.x - p2.x)^2 + (p1.y - p2.y)^2 + (p1.z - p2.z)^2)
end

-- https://love2d.org/forums/viewtopic.php?t=1856
function math.clamp(val, min, max)
    if min - val > 0 then
        return min
    end

    if max - val < 0 then
        return max
    end

    return val
end

--#endregion

function GetTotalCleanableMoney(xPlayer)
    local accBMoney = xPlayer.getAccount('black_money').money

    -- If accBMoney is higger or equal than Washing.Amount then return Washing.Amount, else if Washing.ForceMinAmount is true return 0, else clamp accBMoney between 0 and Washing.Amount and return it
    return accBMoney >= Washing.Amount and Washing.Amount or Washing.ForceMinAmount and 0 or math.clamp(accBMoney, 0, Washing.Amount)
end

function SendSilentFinishSignal(xPlayer)
    xPlayer.triggerEvent('fn:finishWash')
end

function SendFinishSignal(xPlayer)
    xPlayer.showNotification(_U('not_enough_money'))
    SendSilentFinishSignal(xPlayer)
end

function SendErrorSignal(xPlayer)
    xPlayer.showNotification(_U('player_not_near_trigger'))
    SendSilentFinishSignal(xPlayer)
end

--[[
    Not mandatory to be called before a wash, but lets the client know if he can continue or 
    he don't have enough black money
]]--
RegisterNetEvent('fn:beforeWash')
AddEventHandler('fn:beforeWash', function ()
    local xPlayer = ESX.GetPlayerFromId(source)
    if GetTotalCleanableMoney(xPlayer) <= 0 then SendFinishSignal(xPlayer) end
end)

--[[
    Needs to be passed a trigger id in order to check if the player is near it, 
    if not, it probably means that the player has called this event from outside this resource.
    if it is near the trigger, the server gets the total amount of black money that the player can wash,
    if it is 0 sends a finish signal to the client else the server updates the player accounts
]]--
RegisterNetEvent('fn:washMoney')
AddEventHandler('fn:washMoney', function (triggerID)
    local xPlayer = ESX.GetPlayerFromId(source)
    local trigger = Marker.Triggers[triggerID]

    if distance(xPlayer.getCoords(true), trigger) > max_distance then
        SendErrorSignal(xPlayer)
        return
    end

    local cleanable = GetTotalCleanableMoney(xPlayer)

    if cleanable <= 0 then 
        SendFinishSignal(xPlayer)
        return
    end

    local afterWash = cleanable * Washing.Cut

    xPlayer.removeAccountMoney('black_money', cleanable)
    xPlayer.addMoney(afterWash)

    if GetTotalCleanableMoney(xPlayer) <= 0 then 
        SendSilentFinishSignal(xPlayer) 
    end
end)
