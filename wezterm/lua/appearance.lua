local wezterm = require("wezterm")

local module = {}

function module.is_dark()
    if wezterm.gui then
        return wezterm.gui.get_appearance():find("Dark") ~= nil
    end
    -- 默认返回暗色主题
    return true
end

return module
