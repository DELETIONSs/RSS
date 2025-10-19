-- src/styles.lua
-- style rules. Keys are style names like "Button.Primary"

local tokens = require(script.Parent.tokens) -- when run inside loader, script == Root; set accordingly
-- Note: when modules loaded via loader, `script` will be Root; in repoRequire we set script=Root
-- to support both Studio ModuleScripts and loader, use fallback:
if not tokens and script and script.tokens then
    tokens = script.tokens
end

local styles = {}

styles["Button.Primary"] = {
    Class = "TextButton",
    Properties = {
        BackgroundColor3 = tokens.color.primary,
        TextColor3 = tokens.color.text,
        Font = tokens.font.body,
        TextSize = 16,
        Size = UDim2.new(0, 160, 0, 36),
        AutoButtonColor = false
    },
    States = {
        hover = { Properties = { BackgroundTransparency = 0.12 } },
        pressed = { Properties = { BackgroundTransparency = 0.3 } }
    }
}

styles["Frame.Surface"] = {
    Class = "Frame",
    Properties = {
        BackgroundColor3 = tokens.color.surface,
        BorderSizePixel = 0
    }
}

return styles
