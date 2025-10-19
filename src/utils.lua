local utils = {}

function utils.safeRequire(name)
    local ok, res = pcall(require, name)
    if ok then return res end
    return nil
end

return utils
