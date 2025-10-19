-- src/engine.lua
-- applyStyle(instance, styleName)
local engine = {}
local tokens = require(script.Parent.tokens)
local styles = require(script.Parent.styles)

-- keep weak map to track connections so we can remove states
local applied = setmetatable({}, { __mode = "k" })

local function resolveVal(v)
    -- allow { token = "color.primary" } or direct Color3/UDim2/etc
    if type(v) == "table" and v.token then
        -- support token like "color.primary" or "size.buttonHeight"
        local key = v.token
        local category, name = key:match("^([^.]+)%.(.+)$")
        if category and tokens[category] and tokens[category][name] then
            return tokens[category][name]
        end
        return tokens[v.token] or v.value
    end
    return v
end

local function applyProps(inst, props)
    if not props then return end
    for prop, val in pairs(props) do
        local ok, resolved = pcall(resolveVal, val)
        if ok then
            pcall(function()
                if inst and inst[prop] ~= nil then
                    inst[prop] = resolved
                elseif inst and inst:SetAttribute then
                    -- if property not directly available, set attribute as fallback
                    inst:SetAttribute(prop, resolved)
                end
            end)
        end
    end
end

local function bindStates(inst, styleDef)
    local conns = {}
    if not styleDef or not styleDef.States then return conns end
    if (inst:IsA("TextButton") or inst:IsA("ImageButton")) then
        local s = styleDef.States
        if s.hover then
            table.insert(conns, inst.MouseEnter:Connect(function() applyProps(inst, s.hover.Properties) end))
            table.insert(conns, inst.MouseLeave:Connect(function() applyProps(inst, styleDef.Properties) end))
        end
        if s.pressed then
            table.insert(conns, inst.MouseButton1Down:Connect(function() applyProps(inst, s.pressed.Properties) end))
            table.insert(conns, inst.MouseButton1Up:Connect(function() applyProps(inst, styleDef.Properties) end))
        end
    end
    return conns
end

function engine.applyStyle(inst, styleName)
    local styleDef = styles[styleName]
    if not styleDef then warn(("Style %q not found"):format(styleName)); return end

    applyProps(inst, styleDef.Properties)

    local conns = bindStates(inst, styleDef)
    applied[inst] = applied[inst] or {}
    applied[inst][styleName] = conns
end

function engine.removeStyle(inst, styleName)
    local instMap = applied[inst]
    if not instMap then return end
    local conns = instMap[styleName]
    if conns then
        for _, c in ipairs(conns) do
            pcall(function() c:Disconnect() end)
        end
        instMap[styleName] = nil
    end
end

function engine.clearStyles(inst)
    local instMap = applied[inst]
    if not instMap then return end
    for name,_ in pairs(instMap) do engine.removeStyle(inst, name) end
    applied[inst] = nil
end

return engine
