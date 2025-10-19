-- bootstrap.lua
-- Paste this as a single loadstring in the executor.

local http_get = (syn and syn.request and function(url) return syn.request({Url = url, Method = "GET"}).Body end)
              or (http_request and function(url) return http_request({Url = url, Method = "GET"}).Body end)
              or (function(url) return game:HttpGet(url) end)

-- Map module name -> raw GitHub URL (use raw.githubusercontent.com path)
local modules_map = {
    requirements = "https://raw.githubusercontent.com/<username>/<repo>/main/modules/requirements.lua",
    symbols      = "https://raw.githubusercontent.com/<username>/<repo>/main/modules/symbols.lua",
    utils        = "https://raw.githubusercontent.com/<username>/<repo>/main/modules/utils.lua",
    -- add more modules here
}

-- Storage for fetched source + evaluated exports
local module_sources = {}  -- name -> source string
local module_exports = {}  -- name -> returned value from module
local module_loaded  = {}  -- name -> boolean

-- Simple fetch with error handling
for name, url in pairs(modules_map) do
    local ok, body = pcall(http_get, url)
    if not ok or not body then
        error(("Failed to download module %q from %q"):format(name, url))
    end
    module_sources[name] = body
end

-- Root "script" surrogate with proxy module objects so
-- require(Root.requirements) style works.
local Root = {}
for name,_ in pairs(modules_map) do
    -- each proxy is a table; we mark it so our require override can detect it
    Root[name] = { __is_repo_module = true, __module_name = name }
end

-- We'll create a custom require function to be used while executing modules.
local function repo_require(obj)
    -- if caller passed our proxy table: return its exports
    if type(obj) == "table" and obj.__is_repo_module and obj.__module_name then
        local nm = obj.__module_name
        if module_loaded[nm] then
            return module_exports[nm]
        end
        -- not loaded yet -> evaluate module
        local src = module_sources[nm]
        if not src then error("module source missing: "..nm) end

        -- Wrap execution in an environment where:
        --  - require maps to repo_require (so modules can require other repo modules)
        --  - script is set to Root
        --  - standard globals still available via _G
        local env = {}
        for k,v in pairs(_G) do env[k] = v end
        env.require = repo_require
        env.script  = Root

        -- Execute module source safely: assume module returns a value
        local chunk, load_err = loadstring(src, nm..".lua")
        if not chunk then error("load error in module "..nm..": "..tostring(load_err)) end

        -- set env for chunk (works on Roblox's Luau/Lua5.1-style)
        if setfenv then
            setfenv(chunk, env)
            local ok, result = pcall(chunk)
            if not ok then error(("runtime error in module %s: %s"):format(nm, result)) end
            module_exports[nm] = result
        else
            -- fallback if setfenv not present — wrap source so it returns value and use loadstring with env
            local wrapped = "return (function()\n" .. src .. "\nend)()"
            local chunk2, err2 = loadstring(wrapped, nm..".lua")
            if not chunk2 then error(("load error (fallback) in module %s: %s"):format(nm, err2)) end
            if setfenv then setfenv(chunk2, env) end
            local ok2, result2 = pcall(chunk2)
            if not ok2 then error(("runtime error (fallback) in module %s: %s"):format(nm, result2)) end
            module_exports[nm] = result2
        end

        module_loaded[nm] = true
        return module_exports[nm]
    end

    -- If obj is a string, allow require by name too
    if type(obj) == "string" then
        local proxy = Root[obj]
        if proxy then return repo_require(proxy) end
    end

    -- fall back to original require for real ModuleScripts / numbers etc.
    return require(obj)
end

-- Optional: export Root to the global so user scripts can access 'script' variable
-- (but be careful - don't overwrite real script if present)
if not _G.__repo_root then
    _G.__repo_root = Root
end

-- Example: run the 'main' module if present
if modules_map.main then
    local ok, err = pcall(function()
        local main_proxy = Root.main
        if main_proxy then
            repo_require(main_proxy)
        end
    end)
    if not ok then
        warn("Failed to run main module: "..tostring(err))
    end
end

-- Expose convenience: set global 'script' to our Root for interactive use
-- (only if there is no real Instance named 'script' in environment)
if type(script) ~= "table" then
    script = Root
end

-- Now the user can write:
-- local requirements = require(script.requirements)
-- local symbols      = require(script.symbols)
