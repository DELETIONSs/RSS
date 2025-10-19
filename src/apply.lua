local module = {}
local tokens = require(script.Parent.tokens)
local styles = require(script.Parent.styles)

local applied = {}

local function resolveValue(v)
    if type(v) == "table" and v.token then
        return tokens[v.token]
    end
    return v
end

local function applyProps(inst, props)
    for k, v in pairs(props or {}) do
        local resolved = resolveValue(v)
        pcall(function()
            inst[k] = resolved
        end)
    end
end

function module.defineToken(name, value)
    tokens[name] = value
end

function module.defineStyle(name, def)
    styles[name] = def
end

function module.applyStyle(inst, styleName)
    local style = styles[styleName]
    if not style then
        warn("Style not found:", styleName)
        return
    end
    applyProps(inst, style.Properties)

    if style.States then
        if inst:IsA("TextButton") or inst:IsA("ImageButton") then
            inst.MouseEnter:Connect(function()
                applyProps(inst, style.States.hover and style.States.hover.Properties)
            end)
            inst.MouseLeave:Connect(function()
                applyProps(inst, style.Properties)
            end)
            inst.MouseButton1Down:Connect(function()
                applyProps(inst, style.States.pressed and style.States.pressed.Properties)
            end)
            inst.MouseButton1Up:Connect(function()
                applyProps(inst, style.Properties)
            end)
        end
    end
end

function module.removeStyle(inst)
    applied[inst] = nil
end

return module
