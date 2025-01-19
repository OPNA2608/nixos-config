local tym = require ("tym")

local fontName = "Input Mono Condensed, Regular"

local screenIsSmall = @screenIsSmall@
local fontSizeScreenLarge = 9
local fontSizeScreenSmall = 12

local fontSize = screenIsSmall and fontSizeScreenSmall or fontSizeScreenLarge
local fontAdd = 0

local function setFont()
  tym.set ("font", fontName .. " " .. tostring (fontSize + fontAdd))
end

setFont()

tym.set_keymap ("<Ctrl><Shift>I", function()
  fontAdd = fontAdd - 1

  if (fontAdd * -1) >= fontSize then
    fontAdd = fontAdd + 1
  end

  setFont()
end)

tym.set_keymap ("<Ctrl><Shift>O", function()
  fontAdd = 0
  setFont()
end)

tym.set_keymap ("<Ctrl><Shift>P", function()
  fontAdd = fontAdd + 1
  setFont()
end)

tym.set_keymap ("<Ctrl><Shift>A", function()
  tym.select_all()
end)

tym.set_keymap ("<Ctrl><Shift>N", function()
  os.execute ("tym &")
end)

tym.set_hook ("clicked", function (button)
  if button == 2 then
    tym.paste ("primary")
    return true
  end
end)
