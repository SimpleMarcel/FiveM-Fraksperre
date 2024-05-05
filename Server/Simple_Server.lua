ESX = exports["es_extended"]:getSharedObject()


local function GenerateFraksperreID()
return tostring(os.time()):sub(-6) 
end

local function debugprint(message)
if SimpleScripts.DebugPrints == true then
print("^5[SIMPLE-SCRIPTS] ^3[DEBUG]^7 " .. message)
end
end

local function SendDiscordMessageWithEmbed(embed)
PerformHttpRequest(SimpleScripts.DiscordLogWebhook, function(err, text, headers) end, 'POST', json.encode({embeds = {embed}}), { ['Content-Type'] = 'application/json' })
end

function SaveJobChangeToDB(playerId, oldJob, newJob)
local player = ESX.GetPlayerFromId(playerId)
local playerName = player.getName()
local playerId = player.identifier 
local date = os.date("%Y-%m-%d") 
local fraksperreID = GenerateFraksperreID()
local lastChangeDate = os.time() - (SimpleScripts.FraksperrendauerinTage * 24 * 60 * 60)
local dateThreshold = os.date("%Y-%m-%d", lastChangeDate)
MySQL.Async.fetchScalar(
    'SELECT COUNT(*) FROM fraksperre WHERE Spieler_ID = @playerId AND DATE(Datum) > @dateThreshold',
    {
        ['@playerId'] = playerId,
        ['@dateThreshold'] = dateThreshold
    },
    function(result)
        local jobChangesWithinThreshold = tonumber(result) or 0
        if jobChangesWithinThreshold == 0 then
            MySQL.Async.execute(
                'INSERT INTO fraksperre (Spieler_ID, Spieler_Name, Alter_Job, Neuer_Job, Datum, Fraksperre_ID) VALUES (@playerId, @playerName, @oldJob, @newJob, @changeDate, @fraksperreID)',
                {
                    ['@playerId'] = playerId,
                    ['@playerName'] = playerName,
                    ['@oldJob'] = oldJob,
                    ['@newJob'] = newJob,
                    ['@changeDate'] = date,
                    ['@fraksperreID'] = fraksperreID
                },
                function(rowsChanged)
                    local embed = {
                        title = "Spieler Jobwechsel",
                        description = ("**Spieler:** %s\n**Alter Job:** %s\n**Neuer Job:** %s\n**Datum:** %s\n**Fraksperren ID:** %s"):format(playerName, oldJob, newJob, date, fraksperreID),
                        color = 65280 
                    }
                    SendDiscordMessageWithEmbed(embed)
                end
            )
        else
            debugprint("Jobwechsel nicht gespeichert. Spieler hat innerhalb der letzten 3 Tage den Job bereits gewechselt.")
        end
    end
)
end

AddEventHandler('esx:setJob', function(playerId, job, lastJob)
local player = ESX.GetPlayerFromId(playerId)
if player then
    if IsJobSupported(lastJob.name) and IsJobSupported(job.name) then
        if lastJob.name ~= 'unemployed' then
            SaveJobChangeToDB(playerId, lastJob.name, job.name)
        end
    end
    local lastChangeDate = os.time() - (SimpleScripts.FraksperrendauerinTage * 24 * 60 * 60) 
    local playerName = player.getName()
    local dateThreshold = os.date("%Y-%m-%d", lastChangeDate) 
    local playerId = player.identifier 

    MySQL.Async.fetchAll(
        'SELECT * FROM fraksperre WHERE Spieler_ID = @playerId AND DATE(Datum) > @dateThreshold',
        {
            ['@playerId'] = playerId,
            ['@dateThreshold'] = dateThreshold
        },
        function(result)
            if result[1] then
                if job.name ~= 'unemployed' then
                    player.setJob('unemployed', 0)
                    debugprint(("Spieler %s hat innerhalb der letzten 3 Tage den Job gewechselt. Job wird zurückgesetzt auf Arbeitslos."):format(playerName))
                end
            else
                debugprint("Keine Jobwechsel in den letzten 3 Tagen gefunden für Spieler mit der ID: " .. playerId)
            end
        end
    )
else
    debugprint("Spieler mit der ID " .. playerId .. " nicht gefunden.")
end
end)

ESX.RegisterServerCallback('getFraksperreData', function(source, cb)
local xPlayer = ESX.GetPlayerFromId(source)
local playerId = xPlayer.identifier
local futureDate = os.date("%Y-%m-%d", os.time() + (SimpleScripts.FraksperrendauerinTage * 24 * 60 * 60))
MySQL.Async.fetchAll('SELECT Fraksperre_ID, Datum FROM fraksperre WHERE Spieler_ID = @playerId ORDER BY Datum DESC LIMIT 1', {
    ['@playerId'] = playerId
}, function(result)
    if result[1] then
        cb(result[1].Fraksperre_ID, futureDate) 
    else
        cb(nil, futureDate) 
    end
end)
end)

function IsJobSupported(jobName)
for _, supportedJob in ipairs(SimpleScripts.Jobs) do
    if jobName == supportedJob then
        return true
    end
end
return false
end

RegisterCommand('deletefraksperre', function(source, args, rawCommand)
local player = ESX.GetPlayerFromId(source)
if player then
    if player.getGroup() == SimpleScripts.FraksperrenAdminGroup then 
        local fraksperreId = tonumber(args[1])
        if fraksperreId then
            MySQL.Async.execute(
                'DELETE FROM fraksperre WHERE Fraksperre_ID = @fraksperreId',
                {
                    ['@fraksperreId'] = fraksperreId
                },
                function(rowsDeleted)
                    if rowsDeleted > 0 then
                        if SimpleScripts.UseCustomNotify == true then
                            SimpleNotifyServer(source, SimpleScripts.FraksperreDeleteFarbe, SimpleScripts.FraksperreDeleteHeader, SimpleScripts.FraksperrenIDnichtGefundenText1 .. fraksperreId .. SimpleScripts.FraksperrenIDnichtGefundenText2)
                        elseif SimpleScripts.SimpleNotify == true then
                            TriggerClientEvent('SimpleNotify', source, "Success", SimpleScripts.FraksperreDeleteText1 .. fraksperreId .. SimpleScripts.FraksperreDeleteText2)
                        end
                        local adminName = player.getName()
                        local adminCharId = player.identifier
                        local embed = {
                            title = "Fraksperre gelöscht",
                            color = 16711680,
                            fields = {
                                {name = "Admin:", value = adminName, inline = true},
                                {name = "Charakter ID:", value = adminCharId, inline = true},
                                {name = "Gelöschte Fraksperre ID:", value = fraksperreId, inline = false}
                            }
                        }
                        SendDiscordMessageWithEmbed(embed) 
                    else
                        if SimpleScripts.UseCustomNotify == true then
                            SimpleNotifyServer(source, SimpleScripts.FraksperrenIDnichtGefundenFarbe, SimpleScripts.FraksperrenIDnichtGefundenHeader, SimpleScripts.FraksperrenIDnichtGefundenText1 .. fraksperreId .. SimpleScripts.FraksperrenIDnichtGefundenText2)
                        elseif SimpleScripts.SimpleNotify == true then
                            TriggerClientEvent('SimpleNotify', source, "Error", SimpleScripts.FraksperrenIDnichtGefundenText1 .. fraksperreId .. SimpleScripts.FraksperrenIDnichtGefundenText2)
                        end
                    end
                end
            )
        else
            if SimpleScripts.UseCustomNotify == true then
                SimpleNotifyServer(source, SimpleScripts.FraksperrenIDFehlerFarbe, SimpleScripts.FraksperrenIDnichtGefundenHeader, SimpleScripts.FraksperrenIDFehler)
            elseif SimpleScripts.SimpleNotify == true then
                TriggerClientEvent('SimpleNotify', source, "Error", SimpleScripts.FraksperrenIDFehler)
            end
        end
    else
        if SimpleScripts.UseCustomNotify == true then
            SimpleNotifyServer(source, SimpleScripts.FraksperreKeineRechteFarbe, SimpleScripts.FraksperreKeineRechteHeader, SimpleScripts.FraksperreKeineRechte)
        elseif SimpleScripts.SimpleNotify == true then
            TriggerClientEvent('SimpleNotify', source, "Error", SimpleScripts.FraksperreKeineRechte)
        end
    end
end
end, false)

RegisterCommand('addfraksperre', function(source, args, rawCommand)
local player = ESX.GetPlayerFromId(source)
if player then
    if player.getGroup() == SimpleScripts.FraksperrenAdminGroup then 
        local targetId = tonumber(args[1])
        local oldJob = SimpleScripts.FraksperrenAutoinDB
        local newJob = SimpleScripts.FraksperrenAutoinDB

        if targetId then
            local characterId = ESX.GetPlayerFromId(targetId).getIdentifier()  

            MySQL.Async.fetchScalar(
                'SELECT COUNT(*) FROM fraksperre WHERE Spieler_ID = @characterId AND DATE(Datum) > DATE_SUB(CURDATE(), INTERVAL 3 DAY)',
                {
                    ['@characterId'] = characterId  
                },
                function(existingFraksperres)
                    if existingFraksperres == 0 then
                        local fraksperreID = GenerateFraksperreID()
                        local playerName = GetPlayerName(targetId)
                        local date = os.date("%Y-%m-%d") 

                        MySQL.Async.execute(
                            'INSERT INTO fraksperre (Spieler_ID, Spieler_Name, Alter_Job, Neuer_Job, Fraksperre_ID, Datum) VALUES (@characterId, @playerName, @oldJob, @newJob, @fraksperreId, @date)',
                            {
                                ['@characterId'] = characterId,  
                                ['@playerName'] = playerName,
                                ['@oldJob'] = oldJob,
                                ['@newJob'] = newJob,
                                ['@fraksperreId'] = fraksperreID,
                                ['@date'] = date
                            },
                            function(rowsInserted)
                                if rowsInserted > 0 then
                                    if SimpleScripts.UseCustomNotify == true then
                                        SimpleNotifyServer(source, SimpleScripts.FraksperreAddFarbe, SimpleScripts.FraksperreAddHeader, SimpleScripts.FraksperreAddText1 .. playerName .. SimpleScripts.FraksperreAddText2 .. fraksperreID)
                                    elseif SimpleScripts.SimpleNotify == true then
                                        TriggerClientEvent('SimpleNotify', source, "Success", SimpleScripts.FraksperreAddText1 .. playerName .. SimpleScripts.FraksperreAddText2 .. fraksperreID)
                                    end
                                    local logMessage = ("Admin %s hat eine Fraksperre für Spieler %s hinzugefügt. Fraksperre ID: %s"):format(player.getName(), playerName, fraksperreID)
                                    debugprint(logMessage)
                                    local embed = {
                                        title = "Fraksperre hinzugefügt",
                                        color = 65280, 
                                        fields = {
                                            {name = "Admin:", value = player.getName(), inline = true},
                                            {name = "Spieler:", value = playerName, inline = true},
                                            {name = "Fraksperre ID:", value = fraksperreID, inline = false}
                                        }
                                    }
                                    SendDiscordMessageWithEmbed(embed) 
                                else
                                    if SimpleScripts.UseCustomNotify == true then
                                        SimpleNotifyServer(source, SimpleScripts.FraksperreAddErrorFarbe, SimpleScripts.FraksperreAddErrorHeader, SimpleScripts.FraksperreAddErrorText1 .. playerName)
                                    elseif SimpleScripts.SimpleNotify == true then
                                        TriggerClientEvent('SimpleNotify', source, "Error", SimpleScripts.FraksperreAddErrorText1 .. playerName)
                                    end
                                end
                            end
                        )
                    else
                        if SimpleScripts.UseCustomNotify == true then
                            SimpleNotifyServer(source, SimpleScripts.FraksperreAddErrorFarbe, SimpleScripts.FraksperreAddErrorHeader2, SimpleScripts.FraksperreAddText3)
                        elseif SimpleScripts.SimpleNotify == true then
                            TriggerClientEvent('SimpleNotify', source, "Error", SimpleScripts.FraksperreAddText3)
                        end
                    end
                end
            )
        else
            if SimpleScripts.UseCustomNotify == true then
                SimpleNotifyServer(source, SimpleScripts.FraksperreAddErrorFarbe, SimpleScripts.FraksperreAddErrorHeader4, SimpleScripts.FraksperreAddText4)
            elseif SimpleScripts.SimpleNotify == true then
                TriggerClientEvent('SimpleNotify', source, "Error", SimpleScripts.FraksperreAddText4)
            end
        end
    else
        if SimpleScripts.UseCustomNotify == true then
            SimpleNotifyServer(source, SimpleScripts.FraksperreAddErrorFarbe, SimpleScripts.FraksperreAddErrorHeader5, SimpleScripts.FraksperreAddText5)
        elseif SimpleScripts.SimpleNotify == true then
            TriggerClientEvent('SimpleNotify', source, "Error", SimpleScripts.FraksperreAddText5)
        end
    end
end
end, false)

RegisterCommand("SimpleInstallDBFraksperre", function(source, args, rawCommand)
local src = source
if src ~= 0 then
    return
end

MySQL.Async.execute([[
    CREATE TABLE IF NOT EXISTS `fraksperre` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `Spieler_ID` varchar(255) DEFAULT NULL,
        `Spieler_Name` varchar(255) DEFAULT NULL,
        `Alter_Job` varchar(255) DEFAULT NULL,
        `Neuer_Job` varchar(255) DEFAULT NULL,
        `Datum` date DEFAULT NULL,
        `Fraksperre_ID` varchar(20) DEFAULT NULL,
        PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
]], {}, function(rowsChanged)
    print("^5[SIMPLE-SCRIPTS] ^2INFO: Die Tabelle fraksperre konnte erfolgreich erstellt werden!")
end)
end, true)

