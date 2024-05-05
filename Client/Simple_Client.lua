ESX = exports["es_extended"]:getSharedObject()
local isUIVisible = false
RegisterNetEvent('zeigeUI')
AddEventHandler('zeigeUI', function(fraksperreid, datum)
    --print('Fraktions-Sperre-ID erhalten:', fraksperreid) -- Debug-Ausgabe der Fraktions-Sperre-ID
    --print('Datum der Fraktionssperre:', datum) -- Debug-Ausgabe des Datums
    TriggerEvent('toggleNuiFocus', true)
    isUIVisible = true
    SendNUIMessage({
        type = 'showUI',
        data = {
            fraksperreid = fraksperreid, -- Übergebe die Fraktions-Sperre-ID an das UI
            datum = datum -- Übergebe das Datum an das UI
        }
    })
end)
RegisterNetEvent('versteckeUI')
AddEventHandler('versteckeUI', function()
    TriggerEvent('toggleNuiFocus', false)
    isUIVisible = false
    SendNUIMessage({
        type = 'hideUI',
        data = {}
    })
end)
RegisterNetEvent('toggleNuiFocus')
AddEventHandler('toggleNuiFocus', function(state)
    SetNuiFocus(state, state)
end)

RegisterNUICallback('escapePressed', function(data, cb)
    TriggerEvent('versteckeUI')
    cb('ok')
end)
RegisterCommand('Fraksperre', function()
    ESX.TriggerServerCallback('getFraksperreData', function(fraksperreid, datum)
        TriggerEvent('zeigeUI', fraksperreid, datum) -- Übergebe die Fraktions-Sperre-ID und das Datum
    end)
end, false)