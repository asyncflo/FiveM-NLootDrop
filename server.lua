ESX = exports['es_extended']:getSharedObject()

Config = {}
Config.LootDropLocations = {
    vector3(100.0, 200.0, 300.0),
    vector3(400.0, 500.0, 600.0),
    -- 13 weitere Orte hinzufügen
}
Config.LootDropItems = {
    {name = 'WEAPON_ADVANCEDRIFLE', count = 10},
    {name = 'WEAPON_BULLPUPRIFLE', count = 10},
    {name = 'WEAPON_PISTOL50', count = 20},
    {name = 'WEAPON_REVOLVER', count = 2},
    {name = 'WEAPON_MARKSMANPISTOL', count = 2},
}
Config.DropTimeStart = 18
Config.DropTimeEnd = 22

local currentLootDrop = nil

function SpawnLootDrop()
    local hour = tonumber(os.date("%H"))
    if hour >= Config.DropTimeStart and hour < Config.DropTimeEnd then
        local location = Config.LootDropLocations[math.random(#Config.LootDropLocations)]
        currentLootDrop = CreateObject(`prop_box_wood05a`, location.x, location.y, location.z, true, true, true)
        SetEntityHeading(currentLootDrop, math.random(0, 360))
    end
end

RegisterNetEvent('lootdrop:open')
AddEventHandler('lootdrop:open', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)
    
    if currentLootDrop and #(playerCoords - GetEntityCoords(currentLootDrop)) < 2.0 then
        TriggerClientEvent('lootdrop:startOpening', src)
        Citizen.Wait(180000) -- 3 Minuten
        
        for _, item in ipairs(Config.LootDropItems) do
            xPlayer.addInventoryItem(item.name, item.count)
        end
        DeleteObject(currentLootDrop)
        currentLootDrop = nil
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Jede Minute prüfen
        SpawnLootDrop()
    end
end)
