local REPO_BASE = "https://raw.githubusercontent.com/DELETIONSs/RSS/main/src/"

-- modules you want available via Root.<name>
local MODULES = {
    tokens = REPO_BASE .. "tokens.lua",
    styles = REPO_BASE .. "styles.lua",
    engine = REPO_BASE .. "engine.lua",
    utils  = REPO_BASE .. "utils.lua",
    -- add more if you create them
}

-- HTTP helper (tries syn.request, http_request, http.get, game:HttpGet)
local function http_get(url)
    -- syn
    if syn and syn.request then
        local ok, res = pcall(syn.request, {Url = url, Method = "GET"})
        if ok and res and (res.Body) then return res.Body end
    end
    -- http_request (older)
    if http_request then
        local ok, res = pcall(http_request, {Url = url, Method = "GET"})
        if ok and res and (res.Body) then return res.Body end
    end
    -- request (other executors)
    if request then
        local ok, res = pcall(request, {Url = url, Method = "GET"})
        if ok and res and (res.Body) then return res.Body end
    end
    -- game:HttpGet fallback
    if game and game.HttpGet then
        local ok, body = pcall(function() return game:HttpGet(url, true) end)
        if ok and body then return body end
    end
    error(("No http get available to fetch %s"):format(tostring(url)))
end

-- caches
local sources = {}
local exports = {}
local loaded  = {}

-- prepare Root proxies
local Root = {}
for name,_ in pairs(MODULES) do
    Root[name] = { __is_repo_module = true, __module_name = name }
end

-- custom require that supports require(Root.x) and require("tokens") fallback
local function repoRequire(obj)
    if type(obj) == "table" and obj.__is_repo_module and obj.__module_name then
        local name = obj.__module_name
        if loaded[name] then return exports[name] end
        local src = sources[name] or http_get(MODULES[name])
        sources[name] = src

        local chunk, err = loadstring(src, name .. ".lua")
        if not chunk then error(("Failed to load module %s: %s"):format(name, tostring(err))) end

        -- sandboxed env where require maps to repoRequire and script -> Root
        local env = setmetatable({ require = repoRequire, script = Root }, { __index = _G })
        if setfenv then
            setfenv(chunk, env)
            local ok, result = pcall(chunk)
            if not ok then error(("Runtime error in %s: %s"):format(name, tostring(result))) end
            exports[name] = result
        else
            -- fallback for environments without setfenv
            local wrapper = "return (function()\n" .. src .. "\nend)()"
            local chunk2, err2 = loadstring(wrapper, name .. ".lua")
            if not chunk2 then error(("Failed to load (fallback) %s: %s"):format(name, tostring(err2))) end
            local ok2, res2 = pcall(function()
                local f = chunk2
                -- try to set env with debug (best-effort)
                return f()
            end)
            if not ok2 then error(("Runtime error (fallback) in %s: %s"):format(name, tostring(res2))) end
            exports[name] = res2
        end

        loaded[name] = true
        return exports[name]
    end

    if type(obj) == "string" and Root[obj] then
        return repoRequire(Root[obj])
    end

    -- fallback to regular require (works in Studio with ModuleScripts)
    return require(obj)
end

-- expose Root as script when environment doesn't have Instance 'script'
-- careful: do not override real script instance in actual ModuleScripts
if type(script) ~= "table" then
    script = Root
end

-- preload modules lazily or proactively (choose)
-- For now, we do not auto-load every module — repoRequire will load on demand.
-- Example: local tokens = repoRequire(Root.tokens)

-- return Root so user can do: local Root = loadstring(... )()
return Root
