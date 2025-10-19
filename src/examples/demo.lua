-- src/examples/demo.lua
-- Show how to load via loader (executor)
local loaderUrl = "https://raw.githubusercontent.com/DELETIONSs/RSS/main/src/loader.lua"
local ok, Root = pcall(function()
    return loadstring(game:HttpGet(loaderUrl, true))()
end)
if not ok then
    warn("Failed to load loader:", Root)
    return
end

local tokens = require(Root.tokens)
local styles = require(Root.styles)
local engine = require(Root.engine)

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 160, 0, 36)
btn.Position = UDim2.new(0.5, -80, 0.5, -18)
btn.AnchorPoint = Vector2.new(0.5, 0.5)
btn.Text = "Demo"
btn.Parent = game:GetService("CoreGui")

engine.applyStyle(btn, "Button.Primary")
