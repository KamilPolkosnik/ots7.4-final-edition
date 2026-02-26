function onSay(player, words, param)
  if not player:getGroup():getAccess() then
    return true
  end

  local params = param:split(" ") -- Split the parameters into separate values

  if #params == 3 then
    local x = tonumber(params[1])
    local y = tonumber(params[2])
    local z = tonumber(params[3])

    if x and y and z then
      player:teleportTo(Position(x, y, z))
      player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Teleported to position: {" .. x .. ", " .. y .. ", " .. z .. "}.")
    else
      player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Invalid coordinates. Usage: /teleport x y z")
    end
  else
    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Invalid parameters. Usage: /teleport x y z")
  end

  return false
end
