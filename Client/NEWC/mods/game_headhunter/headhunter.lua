local OPCODE_HEADHUNTER = 115

local headhunterWindow = nil
local topWindow = nil
local headhunterButton = nil
local refs = {}
local topRefs = {}
local jsonBuffer = ""

local bounties = {}
local leaderboard = {}
local bountySearchText = ""

local function trim(value)
  return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function findChildById(root, id)
  if not root or not id or id == "" then
    return nil
  end

  if type(root.recursiveGetChildById) == "function" then
    local found = root:recursiveGetChildById(id)
    if found then
      return found
    end
  end

  if root[id] then
    return root[id]
  end

  if type(root.getChildren) ~= "function" then
    return nil
  end

  for _, child in ipairs(root:getChildren()) do
    if type(child.getId) == "function" and child:getId() == id then
      return child
    end
    local nested = findChildById(child, id)
    if nested then
      return nested
    end
  end
  return nil
end

local function formatMoney(value)
  local amount = math.max(0, math.floor(tonumber(value) or 0))
  local formatted = tostring(amount)
  while true do
    local output, changed = formatted:gsub("^(%-?%d+)(%d%d%d)", "%1,%2")
    formatted = output
    if changed == 0 then
      break
    end
  end
  return formatted
end

local function formatDate(value)
  local timestamp = tonumber(value) or 0
  if timestamp <= 0 then
    return "-"
  end
  return os.date("%d %b %H:%M", timestamp)
end

local function setButtonState(enabled)
  if headhunterButton then
    headhunterButton:setOn(enabled and true or false)
  end
end

local function showFailure(text)
  if modules and modules.game_textmessage and modules.game_textmessage.displayFailureMessage then
    modules.game_textmessage.displayFailureMessage(tostring(text or "Operation failed."))
  end
end

local function showStatus(text)
  if modules and modules.game_textmessage and modules.game_textmessage.displayStatusMessage then
    modules.game_textmessage.displayStatusMessage(tostring(text or ""))
  end
end

local function sendAction(action, data)
  local protocol = g_game.getProtocolGame()
  if not protocol then
    return
  end

  protocol:sendExtendedOpcode(OPCODE_HEADHUNTER, json.encode({action = action, data = data or {}}))
end

local function requestSnapshot()
  sendAction("fetch", {})
end

local function destroyChildren(panel)
  if panel and panel.destroyChildren then
    panel:destroyChildren()
  end
end

local function matchesBountySearch(bounty)
  local query = trim(bountySearchText):lower()
  if query == "" then
    return true
  end

  local target = tostring(bounty.target or ""):lower()
  local issuer = tostring(bounty.issuer or ""):lower()
  return target:find(query, 1, true) ~= nil or issuer:find(query, 1, true) ~= nil
end

local function withdrawBounty(id)
  local bountyId = tonumber(id) or 0
  if bountyId <= 0 then
    return
  end
  sendAction("withdraw", {id = bountyId})
end

local function renderBounties()
  if not refs.bountiesList then
    return
  end

  destroyChildren(refs.bountiesList)

  local visible = 0
  for _, bounty in ipairs(bounties) do
    if matchesBountySearch(bounty) then
      visible = visible + 1
      local row = g_ui.createWidget("HeadhunterBountyEntry", refs.bountiesList)
      row.title:setText(tostring(bounty.target or "-"))
      row.reward:setText(string.format("%s gp", formatMoney(bounty.reward or 0)))
      row.issuer:setText(string.format("Issuer: %s", tostring(bounty.issuer or "-")))
      row.createdAt:setText(formatDate(bounty.createdAt))
      row.description:setText(tostring(bounty.description or ""))

      if row.withdrawButton then
        local canWithdraw = bounty.canWithdraw == true
        row.withdrawButton:setVisible(canWithdraw)
        if canWithdraw then
          local bountyId = tonumber(bounty.id) or 0
          row.withdrawButton.onClick = function()
            withdrawBounty(bountyId)
          end
        else
          row.withdrawButton.onClick = nil
        end
      end
    end
  end

  if visible == 0 then
    local empty = g_ui.createWidget("Label", refs.bountiesList)
    if trim(bountySearchText) ~= "" then
      empty:setText("No bounties match the current search.")
    else
      empty:setText("No active bounty contracts.")
    end
    empty:setColor("#a5a5a5")
    empty:setMarginTop(4)
  end
end

local function renderLeaderboard()
  if not topRefs.leaderboardList then
    return
  end

  destroyChildren(topRefs.leaderboardList)

  if #leaderboard == 0 then
    local empty = g_ui.createWidget("Label", topRefs.leaderboardList)
    empty:setText("No headhunter claims yet.")
    empty:setColor("#a5a5a5")
    empty:setMarginTop(4)
    return
  end

  for index, rowData in ipairs(leaderboard) do
    local row = g_ui.createWidget("HeadhunterLeaderEntry", topRefs.leaderboardList)
    row.rank:setText(string.format("#%d", index))
    row.name:setText(tostring(rowData.name or "-"))
    row.kills:setText(string.format("%d kills", math.max(0, math.floor(tonumber(rowData.kills) or 0))))
    row.rewards:setText(string.format("%s gp", formatMoney(rowData.rewards or 0)))
  end
end

local function applySnapshot(data)
  if type(data) ~= "table" then
    return
  end

  bounties = type(data.bounties) == "table" and data.bounties or {}
  leaderboard = type(data.leaderboard) == "table" and data.leaderboard or {}

  renderBounties()
  renderLeaderboard()
end

local function onCreateResult(data)
  if type(data) ~= "table" then
    return
  end

  local ok = data.ok == true
  local message = tostring(data.message or "")
  if ok then
    showStatus(message ~= "" and message or "Operation completed.")
    if refs.targetInput then
      refs.targetInput:setText("")
    end
    if refs.rewardInput then
      refs.rewardInput:setText("")
    end
    if refs.descriptionInput then
      refs.descriptionInput:setText("")
    end
    if refs.anonymousCheck then
      refs.anonymousCheck:setChecked(false)
    end
  else
    showFailure(message ~= "" and message or "Operation failed.")
  end
end

local function onExtendedOpcode(protocol, opcode, buffer)
  if type(buffer) ~= "string" or buffer == "" then
    return
  end

  local firstChar = buffer:sub(1, 1)
  local isStartChunk = (firstChar == "S" and buffer:sub(2, 2) == "{")
  local isMiddleChunk = (firstChar == "P" and jsonBuffer ~= "")
  local isEndChunk = (firstChar == "E" and jsonBuffer ~= "")

  if isStartChunk then
    jsonBuffer = buffer:sub(2)
    return
  elseif isMiddleChunk then
    jsonBuffer = jsonBuffer .. buffer:sub(2)
    return
  elseif isEndChunk then
    jsonBuffer = jsonBuffer .. buffer:sub(2)
    buffer = jsonBuffer
    jsonBuffer = ""
  end

  local ok, payload = pcall(function()
    return json.decode(buffer)
  end)
  if not ok or type(payload) ~= "table" then
    return
  end

  local action = payload.action
  if action == "snapshot" then
    applySnapshot(payload.data)
  elseif action == "result" then
    onCreateResult(payload.data)
  end
end

local function bindRefs()
  refs = {}
  if not headhunterWindow then
    return
  end

  local ids = {
    "targetInput", "rewardInput", "descriptionInput", "anonymousCheck", "createButton",
    "topButton", "bountySearchInput", "bountiesList", "closeButton"
  }

  for _, id in ipairs(ids) do
    refs[id] = findChildById(headhunterWindow, id)
  end
end

local function bindTopRefs()
  topRefs = {}
  if not topWindow then
    return
  end

  local ids = {"leaderboardList", "closeTopButton"}
  for _, id in ipairs(ids) do
    topRefs[id] = findChildById(topWindow, id)
  end
end

local function showWindow()
  if not headhunterWindow then
    return
  end

  requestSnapshot()
  headhunterWindow:show()
  headhunterWindow:raise()
  headhunterWindow:focus()
  setButtonState(true)
end

local function hideWindow()
  if headhunterWindow then
    headhunterWindow:hide()
  end
  setButtonState(false)
end

local function showTopWindow()
  if not topWindow then
    return
  end

  requestSnapshot()
  renderLeaderboard()
  topWindow:show()
  topWindow:raise()
  topWindow:focus()
end

local function hideTopWindow()
  if topWindow then
    topWindow:hide()
  end
end

function onBountySearch()
  scheduleEvent(function()
    if not refs.bountySearchInput then
      return
    end
    bountySearchText = refs.bountySearchInput:getText() or ""
    renderBounties()
  end, 50)
end

function createBounty()
  if not refs.targetInput or not refs.rewardInput or not refs.descriptionInput then
    return
  end

  local targetName = trim(refs.targetInput:getText() or "")
  local rewardText = trim(refs.rewardInput:getText() or "")
  local description = trim(refs.descriptionInput:getText() or "")
  local anonymous = refs.anonymousCheck and refs.anonymousCheck:isChecked() or false

  if targetName == "" then
    showFailure("Enter target player name.")
    return
  end

  local reward = math.floor(tonumber(rewardText) or 0)
  if reward <= 0 then
    showFailure("Enter valid reward amount.")
    return
  end

  if description == "" then
    showFailure("Enter bounty description.")
    return
  end

  sendAction("create", {
    targetName = targetName,
    reward = reward,
    description = description,
    anonymous = anonymous
  })
end

function onWindowClose()
  setButtonState(false)
end

function onTopWindowClose()
  -- handled by window itself
end

function toggleTopWindow()
  if not topWindow then
    return
  end

  if topWindow:isVisible() then
    hideTopWindow()
  else
    showTopWindow()
  end
end

function toggle()
  if not headhunterWindow then
    return
  end

  if headhunterWindow:isVisible() then
    hideWindow()
  else
    showWindow()
  end
end

local function onGameStart()
  requestSnapshot()
end

local function onGameEnd()
  hideWindow()
  hideTopWindow()
  jsonBuffer = ""
end

function init()
  ProtocolGame.registerExtendedOpcode(OPCODE_HEADHUNTER, onExtendedOpcode)

  connect(g_game, {
    onGameStart = onGameStart,
    onGameEnd = onGameEnd
  })

  headhunterButton = modules.client_topmenu.addRightGameToggleButton(
    "headhunterButton",
    tr("Headhunter"),
    "/images/topbuttons/headhunter",
    toggle,
    false,
    27
  )
  headhunterButton:setOn(false)

  headhunterWindow = g_ui.displayUI("headhunter")
  headhunterWindow:hide()
  bindRefs()

  topWindow = g_ui.displayUI("headhunter_top")
  topWindow:hide()
  bindTopRefs()

  if refs.createButton then
    refs.createButton.onClick = createBounty
  end
  if refs.bountySearchInput then
    refs.bountySearchInput.onKeyPress = onBountySearch
  end
  if refs.topButton then
    refs.topButton.onClick = toggleTopWindow
  end

  if g_game.isOnline() then
    requestSnapshot()
  end
end

function terminate()
  pcall(function()
    ProtocolGame.unregisterExtendedOpcode(OPCODE_HEADHUNTER, onExtendedOpcode)
  end)

  disconnect(g_game, {
    onGameStart = onGameStart,
    onGameEnd = onGameEnd
  })

  if headhunterWindow then
    headhunterWindow:destroy()
    headhunterWindow = nil
  end

  if topWindow then
    topWindow:destroy()
    topWindow = nil
  end

  if headhunterButton then
    headhunterButton:destroy()
    headhunterButton = nil
  end

  refs = {}
  topRefs = {}
  bounties = {}
  leaderboard = {}
  bountySearchText = ""
  jsonBuffer = ""
end
