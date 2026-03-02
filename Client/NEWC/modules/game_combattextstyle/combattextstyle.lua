local combatTextStyleByText = {
  ["Critical!"] = { bold = true, size = 14 },
  ["CRITICAL!"] = { bold = true, size = 14, text = "Critical!" },
  ["CRIT!"] = { bold = true, size = 14, text = "Critical!" },
  ["Dodge!"] = { italic = true, size = 9 },
  ["Reflect!"] = { italic = true, size = 9 },
}

local warnedNoAnimatedTextFontSupport = false

local function resolveFontName(style)
  if style.font and style.font:len() > 0 then
    return style.font
  end

  local size = tonumber(style.size) or 11
  local isBold = style.bold == true
  local isItalic = style.italic == true

  if isBold and isItalic then
    -- No dedicated bold+italic font is shipped by default in this client.
    if size >= 14 then
      return "terminus-14px-bold"
    end
    return "verdana-9px-bold"
  end

  if isBold then
    if size >= 14 then
      return "terminus-14px-bold"
    end
    return "verdana-9px-bold"
  end

  if isItalic then
    return "verdana-9px-italic"
  end

  if size >= 11 then
    return "verdana-11px-monochrome"
  end
  return "verdana-9px"
end

local function applyAnimatedTextStyle(animatedText, text)
  local style = combatTextStyleByText[text]
  if not style then
    return
  end

  if style.text and style.text:len() > 0 then
    pcall(function()
      animatedText:setText(style.text)
    end)
  end

  local fontName = resolveFontName(style)
  local ok = pcall(function()
    animatedText:setFont(fontName)
  end)
  if not ok and not warnedNoAnimatedTextFontSupport then
    warnedNoAnimatedTextFontSupport = true
    g_logger.warning("[game_combattextstyle] AnimatedText:setFont is not available in this client build.")
  end

  if style.color ~= nil then
    pcall(function()
      animatedText:setColor(style.color)
    end)
  end
end

function onAnimatedText(thing, text)
  if not thing or not text or text:len() == 0 then
    return
  end

  applyAnimatedTextStyle(thing, text)
end

function init()
  connect(g_map, { onAnimatedText = onAnimatedText })
end

function terminate()
  disconnect(g_map, { onAnimatedText = onAnimatedText })
end
