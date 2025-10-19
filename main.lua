local function fetch(url)
    local ok, res
    if syn and syn.request then
        ok, res = pcall(syn.request, {Url = url, Method = "GET"})
        return ok and res.Body or error("Failed to fetch: " .. url)
    elseif http_request then
        ok, res = pcall(http_request, {Url = url, Method = "GET"})
        return ok and res.Body or error("Failed to fetch: " .. url)
    else
        ok, res = pcall(game.HttpGet, game, url)
        return ok and res or error("Failed to fetch: " .. url)
    end
end

-- Map of all modules in your repo
local base = "https://raw.githubusercontent.com/<your-username>/TideLib/main/modules/"
local modules = {
    requirements = base .. "requirements.lua",
    symbols      = base .. "symbols.lua"
}

-- Caches
local sources = {}
local exports = {}
local loaded  = {}

-- Fake Root (acts like a script container)
local Root = {}
for name in pairs(modules) do
    Root[name] = { __isModule = true, __moduleName = name }
end

-- Custom require that works with require(Root.module)
local function repoRequire(obj)
    if type(obj) == "table" and obj.__isModule then
        local name = obj.__moduleName
        if loaded[name] then
            return exports[name]
        end

        local src = sources[name] or fetch(modules[name])
        sources[name] = src

        local env = setmetatable({require = repoRequire, script = Root}, {__index = _G})
        local chunk, err = loadstring(src, name .. ".lua")
        if not chunk then
            error("Error loading module " .. name .. ": " .. tostring(err))
        end
        setfenv(chunk, env)
        local result = chunk()
        exports[name] = result
        loaded[name] = true
        return result
    end

    return require(obj) -- fallback for normal ModuleScripts
end

-- Publicly expose require and Root
local M = {}
M.Root = Root
M.require = repoRequire

-- Make require(script.module) pattern work
getfenv(0).script = Root

-- Example auto-load behavior: preload all modules
for name in pairs(modules) do
    repoRequire(Root[name])
end

-- Return Root so the user can do:
-- local Root = loadstring(game:HttpGet("..."))()
return Root
