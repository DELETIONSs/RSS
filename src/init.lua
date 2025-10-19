-- init.lua
local Style = {}

local tokens = require(script.tokens)
local styles = require(script.styles)
local apply = require(script.apply)

Style.tokens = tokens
Style.styles = styles
Style.apply = apply.applyStyle
Style.remove = apply.removeStyle
Style.define = apply.defineStyle
Style.defineToken = apply.defineToken

return Style
