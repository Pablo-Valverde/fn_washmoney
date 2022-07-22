Config = {}
WorldText = {}
Washing = {}
Washing.Animation = {}
Marker = {}
Blip = {}


Config.Locale = 'en' -- Which languague file should be used for the texts
Config.SpamLock = 1500.0 -- How much time in ms to wait until allowing the player to execute another wash petition when he has finished one


WorldText.TextSize = 1.5
WorldText.Offset = vector3(0.0, 0.0, 2.0) -- How far from the center of the trigger the text should be 


Washing.Amount = 2000
Washing.Cut = .9 -- If 2500 black money and 0.7 cut then on wash, the player will get 1750 normal money
Washing.Delay = 5000.0 -- Total delay in ms to wash Washing.Amount
Washing.ForceMinAmount = false -- If true, the player wont be allowed to wash if its money is less than Washing.Amount

Washing.Animation.Freeze = false -- Freeze the player while doing the animation
Washing.Animation.Enabled = true
Washing.Animation.Flag = 0 --[[
    0 normal
    01 to 15 > Full body  
    10 to 31 > Upper body  
    32 to 47 > Full body > Controllable  
    48 to 63 > Upper body > Controllable

    For example, 50 would mean the player can freely move while washing
]]--

--https://github.com/criminalist/Animations-list-GTA5-Fivem/blob/master/anim-list.txt
Washing.Animation.Dictionary = 'mp_take_money_mg'
Washing.Animation.Name = 'put_cash_into_bag_loop'

Washing.Animation.RestartAfter = 1000.0 -- Restart the animation after the given amount of ms


Marker.AllowInteractionDistance = 3.0 -- How far away should the script allow interaction with the marker
Marker.MaxFreeMovementDistance = 4.0 -- How far can the player be while interacting with the marker (from the position that the interaction started)

Marker.Triggers = { -- List of triggers where a washing action can start from, must be in 'number - vector' format
    [0] = vector3(1963.8, 5178.9, 46.9),
}

Marker.Draw = true -- Show the marker on the ground
Marker.DrawDistance = 50.0 -- How far away should the script draw markers

Marker.Type = 1
Marker.Size = {x=5.0, y=5.0, z=1.0}
Marker.Color = {r=1.0, g=0.0, b=0.0}


Blip.Icon = 500 -- https://docs.fivem.net/docs/game-references/blips/#blips
Blip.Color = 1 -- https://docs.fivem.net/docs/game-references/blips/#blip-colors

Blip.Display = 4 --[[
    0 = Doesn't show up, ever, anywhere
    2 = Shows on both main map and minimap (Selectable on map)
    3 = Visible on Map but not Radar
    4 = Shows on main map only (Selectable on map)
    5 = Shows on minimap only
    8 = Shows on both main map and minimap (Not selectable on map)
]]--
Blip.Scale = 1.0

Blip.IsShortRange = true -- Sets whether or not the blip should only be displayed when nearby, or on the minimap
