local QBCore, LoggedIn, onRadio, RadioChannel, CurrentVolume = exports['qb-core']:GetCoreObject(), false, false, 0, 100
local primaryChannel = 0  
local secondaryChannel = 0 
local isUsingSecondary = false 

-- Threads

Citizen.CreateThread(function()
    local sleep = 3000
    while true do
        if LocalPlayer.state.isLoggedIn and onRadio then
            sleep = 1000
            local hasItem = exports['qb-inventory']:HasItem("radio", 1)
            if not hasItem then
                if RadioChannel ~= 0 then
                    LeaveRadio()
                end
            end
        else
            sleep = 3000
        end
        Wait(sleep)
    end
end)

-- Events

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    LoggedIn = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    LeaveRadio{true}
    LoggedIn = false
end)

RegisterNetEvent('QBCore:Client:CloseNui', function()
    SetNuiFocus(false, false)
end)

RegisterNetEvent('qb-radio:use', function()
    OpenRadio()
end)

RegisterNetEvent('qb-radio:drop:radio', function()
    QBCore.Functions.TriggerCallback('qb-radio:server:HasItem', function(HasItem)
        if not HasItem then
           LeaveRadio()
        end
    end, "radio")
end)

-- Key Mapping

RegisterKeyMapping('PortoVolUp', 'Radio Volume Up', 'keyboard', '')
RegisterKeyMapping('PortoVolDown', 'Radio Volume Down', 'keyboard', '')
RegisterKeyMapping('PortoUp', 'Radio Channel Up', 'keyboard', '')
RegisterKeyMapping('PortoDown', 'Radio Channel Down', 'keyboard', '')
RegisterKeyMapping('sw', 'Switch Radio Channel', 'keyboard', 'I')

RegisterCommand('PortoVolUp', function(source, args)
    local Player = QBCore.Functions.GetPlayerData()
    if not Player.metadata['ishandcuffed'] then
        Volume('Up')
    end
end, false)

RegisterCommand('PortoVolDown', function(source, args)
    local Player = QBCore.Functions.GetPlayerData()
    if not Player.metadata['ishandcuffed'] then
        Volume('Down')
    end
end, false)

RegisterCommand('PortoUp', function(source, args)
    local Player = QBCore.Functions.GetPlayerData()
    if not Player.metadata['ishandcuffed'] then
        ChangeRadio('Up')
    end
end, false)

RegisterCommand('PortoDown', function(source, args)
    local Player = QBCore.Functions.GetPlayerData()
    if not Player.metadata['ishandcuffed'] then
        ChangeRadio('Down')
    end
end, false)

-- Save channel command
RegisterCommand('sc', function(source, args)
    if #args < 1 then
        QBCore.Functions.Notify('Usage: /sc [1-500] - Saves channel to secondary slot', 'error')
        return
    end
    
    local channel = tonumber(args[1])
    if channel then
        if channel >= 1 and channel <= 500 then
            if RadioChannel ~= 0 then
                primaryChannel = RadioChannel
                QBCore.Functions.Notify('Primary channel saved: ' .. primaryChannel .. ' MHz', 'success')

                secondaryChannel = channel
                QBCore.Functions.Notify('Secondary channel saved: ' .. secondaryChannel .. ' MHz', 'success')
                
                if RadioChannel == primaryChannel then
                    isUsingSecondary = false
                end
            else
                QBCore.Functions.Notify('You need to be connected to a radio channel first!', 'error')
            end
        else
            QBCore.Functions.Notify('Channel must be between 1 and 500', 'error')
        end
    else
        QBCore.Functions.Notify('Invalid channel number', 'error')
    end
end, false)

-- Command to switch between channels
RegisterCommand('sw', function()
    if onRadio and RadioChannel ~= 0 then
        if primaryChannel ~= 0 and secondaryChannel ~= 0 then
            if isUsingSecondary then
               
                JoinRadio(primaryChannel)
                QBCore.Functions.Notify('Switched to primary channel: ' .. primaryChannel .. ' MHz', 'success')
                isUsingSecondary = false
            else
                
                JoinRadio(secondaryChannel)
                QBCore.Functions.Notify('Switched to secondary channel: ' .. secondaryChannel .. ' MHz', 'success')
                isUsingSecondary = true
            end
        else
            QBCore.Functions.Notify('Both primary and secondary channels need to be saved first! Use /sc [channel]', 'error')
        end
    else
        QBCore.Functions.Notify('Radio is not on', 'error')
    end
end, false)

-- Optional command to check saved channels
RegisterCommand('check', function()
    if primaryChannel == 0 and secondaryChannel == 0 then
        QBCore.Functions.Notify('No channels saved. Use /sc [1-500]', 'info')
    else
        local current = isUsingSecondary and "Secondary" or "Primary"
        QBCore.Functions.Notify('Primary: ' .. primaryChannel .. ' MHz | Secondary: ' .. secondaryChannel .. ' MHz | Current: ' .. current, 'success')
    end
end, false)

-- Functions

function ConnectRadio(channel)
    RadioChannel = channel
    if onRadio then
        exports["pma-voice"]:setRadioChannel(0)
    else
        onRadio = true
        exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
    end

    exports["pma-voice"]:setRadioChannel(channel)

    if SplitStr(tostring(channel), ".")[2] ~= nil and SplitStr(tostring(channel), ".")[2] ~= "" then
        QBCore.Functions.Notify('Connected to '..channel.. ' MHz', 'success')
    else
        QBCore.Functions.Notify('Connected to '..channel.. '.00 MHz', 'success')
    end
    
   
    if channel == primaryChannel then
        isUsingSecondary = false
    elseif channel == secondaryChannel then
        isUsingSecondary = true
    end
    
    TriggerServerEvent('qb-phub:server:refresh', QBCore.Functions.GetPlayerData().job.name)
    TriggerServerEvent('qb-emshub:server:refresh', QBCore.Functions.GetPlayerData().job.name)
end

function JoinRadio(Channel)
    local rchannel = tonumber(Channel)
    if rchannel ~= nil then
        if rchannel <= Config.MaxFrequency and rchannel ~= 0 then
            if rchannel ~= RadioChannel then
                if Config.RestrictedChannels[rchannel] ~= nil then
                    local Player = QBCore.Functions.GetPlayerData()
                    if Config.RestrictedChannels[rchannel][Player.job.name] and Player.job.onduty then
                        ConnectRadio(rchannel)
                    else
                        QBCore.Functions.Notify('This channel is encoded....', 'error')
                    end
                else
                    ConnectRadio(rchannel)
                end
            else
                QBCore.Functions.Notify("You're already on this frequency...", 'error')
            end
        else
            QBCore.Functions.Notify("Your radio can't connect...", 'error')
        end
    else
        QBCore.Functions.Notify('Your radio is not on...', 'error')
    end
end

function Volume(Type)
    if Type == 'Up'  then
        if CurrentVolume < 100 then
            CurrentVolume = CurrentVolume + 10
            exports["pma-voice"]:setRadioVolume(CurrentVolume)
            QBCore.Functions.Notify('Volume: '..CurrentVolume, 'success', 2500)
        else
            QBCore.Functions.Notify('Highest Volume', 'error', 2500)
        end
    elseif Type == 'Down' then
        if CurrentVolume > 10 then
            CurrentVolume = CurrentVolume - 10
            exports["pma-voice"]:setRadioVolume(CurrentVolume)
            QBCore.Functions.Notify('Volume: '..CurrentVolume, 'success')
        else
            QBCore.Functions.Notify('Lowest Volume', 'error', 2500)
        end
    end
end

function ChangeRadio(Type)
    if Type == 'Up' then
        local NewChannel = RadioChannel + 1
        if NewChannel > 500 then
            NewChannel = 500
        end
        JoinRadio(NewChannel, tostring(NewChannel):len())
        SendNUIMessage({type = 'setchannel', channel = tostring(NewChannel)})
    elseif Type == 'Down' then
        local NewChannel = RadioChannel - 1
        if NewChannel < 1 then
            NewChannel = 1
        end
        JoinRadio(NewChannel, tostring(NewChannel):len())
        SendNUIMessage({type = 'setchannel', channel = tostring(NewChannel)})
    end
end

function LeaveRadio(Forced)
    if onRadio or Forced then
        RadioChannel = 0
        TriggerEvent("qb-sound:client:play", "radio-click", 0.25)
        exports["pma-voice"]:removePlayerFromRadio()
        exports["pma-voice"]:SetRadioChannel(0)
        exports["pma-voice"]:setVoiceProperty("radioEnabled", false)
        isUsingSecondary = false  
        QBCore.Functions.Notify('You are removed from your current frequency!', 'error')
    else
        QBCore.Functions.Notify('Your radio is not on...', 'error')
    end
end

function OpenRadio()
    SetNuiFocus(true, true)
    PhonePlayIn()
    if not onRadio then
        SendNUIMessage({type = "setchannel", channel = 'OFF'})
    end
    SendNUIMessage({
        type = "open",
    })
end

function SplitStr(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function SetRadioState(bool)
    RadioOn = bool
end

function IsRadioOn()
    return onRadio    
end

exports("IsRadioOn", IsRadioOn)

-- NUI

RegisterNUICallback('JoinRadio', function(data)
    local channel = tonumber(data.channel)
    if channel then
        JoinRadio(channel, data.channel:len())
      
        if primaryChannel == 0 then
            primaryChannel = channel
        end
    end
end)

RegisterNUICallback('LeaveRadio', function(data, cb)
    if RadioChannel == 0 then
        QBCore.Functions.Notify('You are not connected to a channel', 'error')
    else
        LeaveRadio()
    end
end)

RegisterNUICallback('Escape', function(data, cb)
    SetNuiFocus(false, false)
    PhonePlayOut()
end)

RegisterNUICallback('SetVolume', function(data)
    if data.Type == 'Up'  then
        if CurrentVolume < 100 then
            CurrentVolume = CurrentVolume + 10
            exports["pma-voice"]:setRadioVolume(CurrentVolume)
            QBCore.Functions.Notify('Volume: '..CurrentVolume, 'success', 2500)
        else
            QBCore.Functions.Notify('Highest Volume', 'error', 2500)
        end
    elseif data.Type == 'Down' then
        if CurrentVolume > 10 then
            CurrentVolume = CurrentVolume - 10
            exports["pma-voice"]:setRadioVolume(CurrentVolume)
            QBCore.Functions.Notify('Volume: '..CurrentVolume, 'success')
        else
            QBCore.Functions.Notify('Lowest Volume', 'error', 2500)
        end
    end
end)

RegisterNUICallback('ToggleOnOff', function()
    Citizen.SetTimeout(150, function()
        if not onRadio then
            onRadio = true
            if RadioChannel ~= 0 then
                SendNUIMessage({type = 'setchannel', channel = RadioChannel})
                exports["pma-voice"]:addPlayerToRadio(RadioChannel, "Radio", "radio")
                exports["pma-voice"]:SetRadioChannel(RadioChannel)
            else
                SendNUIMessage({type = "setchannel", channel = 0})
            end
            exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
            exports["pma-voice"]:setRadioVolume(CurrentVolume)
            SendNUIMessage({type = "enableinput"})
            TriggerEvent("qb-sound:client:play", "radio-on", 0.25)
            QBCore.Functions.Notify('Radio On.', 'success')
        else
            onRadio = false
            exports["pma-voice"]:removePlayerFromRadio()
            exports["pma-voice"]:setVoiceProperty("radioEnabled", false)
            SendNUIMessage({type = "setchannel", channel = 'OFF'})
            SendNUIMessage({type = "disableinput"})
            TriggerEvent("qb-sound:client:play", "radio-click", 0.25)
            QBCore.Functions.Notify('Radio Out.', 'error')
        end
    end)
end)

RegisterNUICallback('OnClick', function()
    PlaySound(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
end)

RegisterNUICallback('NotEnabled', function()
    -- QBCore.Functions.Notify('Je radio staat niet aan..', 'error', 2500)
    PlaySound(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
end)

RegisterNetEvent('qb:radio:hackradio', function(data)
    ConnectRadio(data)
end)

-- Optional: Add NUI callback to display saved channels in UI
RegisterNUICallback('GetSavedChannels', function(data, cb)
    cb({
        primary = primaryChannel,
        secondary = secondaryChannel,
        isUsingSecondary = isUsingSecondary
    })
end)

local function SplitStr(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        t[#t + 1] = str
    end
    return t
end

RegisterNetEvent('qb-radio:client:JoinRadioChannel1')
AddEventHandler('qb-radio:client:JoinRadioChannel1', function(channel)
    local hasItem = QBCore.Functions.HasItem("radio")
    if hasItem then
        local channel = 1
        if onRadio then
            isDead = true
            exports["pma-voice"]:setRadioChannel(0)
        else
            onRadio = true
            isDead = false
            exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
        end
        exports["pma-voice"]:setRadioChannel(channel)
        if SplitStr(tostring(channel), ".")[2] ~= nil and SplitStr(tostring(channel), ".")[2] ~= "" then
            QBCore.Functions.Notify(Config.messages['joined_to_radio'] .. channel .. ' MHz', 'success')
        else
            QBCore.Functions.Notify(Config.messages['joined_to_radio'] .. channel .. '.00 MHz', 'success')
        end

        if primaryChannel == 0 then
            primaryChannel = channel
        end
    end
end)

RegisterNetEvent('qb-radio:client:JoinRadioChannel2')
AddEventHandler('qb-radio:client:JoinRadioChannel2', function(channel)
    local hasItem = QBCore.Functions.HasItem("radio")
    if hasItem then
        local channel = 2
        if onRadio then
            isDead = true
            exports["pma-voice"]:setRadioChannel(0)
        else
            onRadio = true
            isDead = false
            exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
        end
        exports["pma-voice"]:setRadioChannel(channel)
        if SplitStr(tostring(channel), ".")[2] ~= nil and SplitStr(tostring(channel), ".")[2] ~= "" then
            QBCore.Functions.Notify(Config.messages['joined_to_radio'] .. channel .. ' MHz', 'success')
        else
            QBCore.Functions.Notify(Config.messages['joined_to_radio'] .. channel .. '.00 MHz', 'success')
        end
 
        if primaryChannel == 0 then
            primaryChannel = channel
        end
    end
end)

RegisterNetEvent('qb-radio:client:JoinRadioChannel3')
AddEventHandler('qb-radio:client:JoinRadioChannel3', function(channel)
    local hasItem = QBCore.Functions.HasItem("radio")
    if hasItem then
        local channel = 3
        if onRadio then
            isDead = true
            exports["pma-voice"]:setRadioChannel(0)
        else
            onRadio = true
            isDead = false
            exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
        end
        exports["pma-voice"]:setRadioChannel(channel)
        if SplitStr(tostring(channel), ".")[2] ~= nil and SplitStr(tostring(channel), ".")[2] ~= "" then
            QBCore.Functions.Notify(Config.messages['joined_to_radio'] .. channel .. ' MHz', 'success')
        else
            QBCore.Functions.Notify(Config.messages['joined_to_radio'] .. channel .. '.00 MHz', 'success')
        end
 
        if primaryChannel == 0 then
            primaryChannel = channel
        end
    end
end)

RegisterNetEvent('qb-radio:client:JoinRadioChannel4')
AddEventHandler('qb-radio:client:JoinRadioChannel4', function(channel)
    local hasItem = QBCore.Functions.HasItem("radio")
    if hasItem then
        local channel = 4
        if onRadio then
            isDead = true
            exports["pma-voice"]:setRadioChannel(0)
        else
            onRadio = true
            isDead = false
            exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
        end
        exports["pma-voice"]:setRadioChannel(channel)
        if SplitStr(tostring(channel), ".")[2] ~= nil and SplitStr(tostring(channel), ".")[2] ~= "" then
            QBCore.Functions.Notify(Config.messages['joined_to_radio'] .. channel .. ' MHz', 'success')
        else
            QBCore.Functions.Notify(Config.messages['joined_to_radio'] .. channel .. '.00 MHz', 'success')
        end

        if primaryChannel == 0 then
            primaryChannel = channel
        end
    end
end)

RegisterNetEvent('qb-radio:client:JoinRadioChannel5')
AddEventHandler('qb-radio:client:JoinRadioChannel5', function(channel)
    local hasItem = QBCore.Functions.HasItem("radio")
    if hasItem then
        local channel = 5
        if onRadio then
            isDead = true
            exports["pma-voice"]:setRadioChannel(0)
        else
            onRadio = true
            isDead = false
            exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
        end
        exports["pma-voice"]:setRadioChannel(channel)
        if SplitStr(tostring(channel), ".")[2] ~= nil and SplitStr(tostring(channel), ".")[2] ~= "" then
            QBCore.Functions.Notify(Config.messages['joined_to_radio'] .. channel .. ' MHz', 'success')
        else
            QBCore.Functions.Notify(Config.messages['joined_to_radio'] .. channel .. '.00 MHz', 'success')
        end
      
        if primaryChannel == 0 then
            primaryChannel = channel
        end
    end
end)

for i = 6, 20 do
    RegisterNetEvent('qb-radio:client:JoinRadioChannel'..i)
    AddEventHandler('qb-radio:client:JoinRadioChannel'..i, function(channel)
        local hasItem = QBCore.Functions.HasItem("radio")
        if hasItem then
            local channel = i
            if onRadio then
                isDead = true
                exports["pma-voice"]:setRadioChannel(0)
            else
                onRadio = true
                isDead = false
                exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
            end

            exports["pma-voice"]:setRadioChannel(channel)

            if SplitStr(tostring(channel), ".")[2] ~= nil and SplitStr(tostring(channel), ".")[2] ~= "" then
                QBCore.Functions.Notify(Config.messages['joined_to_radio'] .. channel .. ' MHz', 'success')
            else
                QBCore.Functions.Notify(Config.messages['joined_to_radio'] .. channel .. '.00 MHz', 'success')
            end
         
            if primaryChannel == 0 then
                primaryChannel = channel
            end
        end
    end)
end