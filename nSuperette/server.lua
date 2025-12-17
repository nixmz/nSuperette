ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Event pour give l'item
RegisterServerEvent('sup:giveInventoryItem')
AddEventHandler('sup:giveInventoryItem', function(item, label, quantity)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer then
        xPlayer.addInventoryItem(item, quantity)
        TriggerClientEvent('esx:showNotification', _source, "~g~"..quantity.." x "..label.." ajouté(s) à votre inventaire")
    else
    end
end)