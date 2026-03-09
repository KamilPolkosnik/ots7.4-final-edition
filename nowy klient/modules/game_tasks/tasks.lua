local OPCODE_TASKS = 106

local tasksWindow
local tasksButton
local tasksList

local function renderTasks(tasks)
  if not tasksList then return end
  tasksList:destroyChildren()

  if not tasks or #tasks == 0 then
    local label = g_ui.createWidget('TaskEntry', tasksList)
    label:setText('No tasks data.')
    return
  end

  for _, task in ipairs(tasks) do
    local label = g_ui.createWidget('TaskEntry', tasksList)
    label:setText(string.format('%s: %d', task.name, task.count or 0))
  end
end

local function requestTasks()
  if not g_game.isOnline() then return end
  local protocol = g_game.getProtocolGame()
  if protocol then
    protocol:sendExtendedOpcode(OPCODE_TASKS, 'list')
  end
end

local function onExtendedOpcode(protocol, opcode, buffer)
  if opcode ~= OPCODE_TASKS then return end
  local ok, payload = pcall(function() return json.decode(buffer) end)
  if not ok or not payload or not payload.tasks then
    return
  end
  renderTasks(payload.tasks)
end

function init()
  tasksButton = modules.client_topmenu.addLeftButton('tasksButton', tr('Tasks (Ctrl+Shift+T)'),
    '/images/topbuttons/analyzers', toggle)
  tasksButton:setOn(false)

  tasksWindow = g_ui.displayUI('tasks')
  tasksWindow:hide()
  tasksList = tasksWindow:recursiveGetChildById('tasksList')

  g_keyboard.bindKeyDown('Ctrl+Shift+T', toggle)

  ProtocolGame.registerExtendedOpcode(OPCODE_TASKS, onExtendedOpcode)
  connect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
end

function terminate()
  disconnect(g_game, { onGameStart = onGameStart, onGameEnd = onGameEnd })
  if tasksButton then
    tasksButton:destroy()
    tasksButton = nil
  end
  if tasksWindow then
    tasksWindow:destroy()
    tasksWindow = nil
  end
  g_keyboard.unbindKeyDown('Ctrl+Shift+T')
  pcall(function() ProtocolGame.unregisterExtendedOpcode(OPCODE_TASKS) end)
end

function onGameStart()
  if tasksWindow and tasksWindow:isVisible() then
    requestTasks()
  end
end

function onGameEnd()
  if tasksList then
    tasksList:destroyChildren()
  end
  if tasksButton then
    tasksButton:setOn(false)
  end
end

function toggle()
  if not tasksWindow then return end
  if tasksWindow:isVisible() then
    tasksWindow:hide()
    tasksButton:setOn(false)
  else
    tasksWindow:show()
    tasksWindow:raise()
    tasksWindow:focus()
    tasksButton:setOn(true)
    requestTasks()
  end
end
