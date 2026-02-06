QBCore = exports['qb-core']:GetCoreObject()

-- Items

QBCore.Functions.CreateUseableItem("radio", function(source, item)
  TriggerClientEvent('qb-radio:use', source)
end)

-- Callbacks

QBCore.Functions.CreateCallback('qb-radio:server:GetItem', function(source, cb, item)
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  if Player ~= nil then
      local RadioItem = Player.Functions.GetItemByName(item)
      if RadioItem ~= nil and not Player.PlayerData.metadata["isdead"] then
          cb(true)
      else
          cb(false)
      end
  else
      cb(false)
  end
end)