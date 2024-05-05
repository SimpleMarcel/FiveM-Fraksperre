SimpleScripts = {}

--Die Jobs bei der die Fraksperre ausgelöst werden soll.
SimpleScripts.Jobs = {
    "police",
    "ambulance",
    "unemployed",
    "mechanic",
}

--STANDART NOTFIY von SIMPLESCRIPTS.eu | Dafür muss SimpleNotify Installiert sein!
SimpleScripts.SimpleNotify = true

--CUSTOM NOTIFY
SimpleScripts.UseCustomNotify = false

function SimpleNotifyServer(source, color, title, msg)
    TriggerClientEvent('notifications', source, color, title, msg) -- Dein Notify Server Trigger, falls du eine eigene Nutzt.
end

--NOTIFY Nachrichten Inhalte.
SimpleScripts.FraksperrenIDnichtGefundenFarbe = "WHITE"
SimpleScripts.FraksperrenIDnichtGefundenHeader = "Error"
SimpleScripts.FraksperrenIDnichtGefundenText1 = "Fraksperre mit ID "
SimpleScripts.FraksperrenIDnichtGefundenText2 = " wurde nicht gefunden."
SimpleScripts.FraksperrenIDFehlerFarbe = "RED"
SimpleScripts.FraksperrenIDFehler = "Ungültige Fraksperre ID."
SimpleScripts.FraksperreKeineRechteHeader = "Error"
SimpleScripts.FraksperreKeineRechteFarbe = "RED"
SimpleScripts.FraksperreKeineRechte = "Du hast keine Berechtigung, diesen Befehl auszuführen."
SimpleScripts.FraksperreDeleteFarbe = "GREEN"
SimpleScripts.FraksperreDeleteHeader = "Success"
SimpleScripts.FraksperreDeleteText1 = "Fraksperre mit ID "
SimpleScripts.FraksperreDeleteText2 = " erfolgreich gelöscht."
SimpleScripts.FraksperreAddHeader = "Success"
SimpleScripts.FraksperreAddFarbe = "GREEN"
SimpleScripts.FraksperreAddText1 = "Fraksperre erfolgreich für Spieler "
SimpleScripts.FraksperreAddText2 = " hinzugefügt. Fraksperre ID: "
SimpleScripts.FraksperreAddErrorFarbe = "RED"
SimpleScripts.FraksperreAddErrorHeader = "Error"
SimpleScripts.FraksperreAddErrorText1 = "Fehler beim Hinzufügen der Fraksperre für Spieler "
SimpleScripts.FraksperreAddErrorHeader2 = "Error"
SimpleScripts.FraksperreAddText3 = "Der Spieler hat bereits innerhalb der letzten 3 Tage eine Fraksperre."
SimpleScripts.FraksperreAddErrorHeader4 = "Error"
SimpleScripts.FraksperreAddText4 = "Ungültige Spieler-ID."
SimpleScripts.FraksperreAddErrorHeader5 = "Error"
SimpleScripts.FraksperreAddText5 = "Du hast keine Berechtigung, diesen Befehl auszuführen."


--Admin Einstellungen.
SimpleScripts.DebugPrints = false
SimpleScripts.FraksperrenAdminGroup = "admin"
SimpleScripts.FraksperrenAutoinDB = "AdminEintrag"
SimpleScripts.FraksperrendauerinTage = "3"
SimpleScripts.DiscordLogWebhook = ""
