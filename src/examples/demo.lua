-- examples/demo.lua
local Style = require(Root.Style)

-- Create an example UI element
local button = Instance.new("TextButton")
button.Text = "Click Me"
button.Parent = game.CoreGui

-- Apply the style
Style.apply(button, "Button.Primary")
