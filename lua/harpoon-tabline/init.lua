local has_harpoon, harpoon = pcall(require, "harpoon")
if not has_harpoon then
    error("harpoon-tabline.nvim requires ThePrimeagen/harpoon")
end

---@class HarpoonTabline
local M = {}

---@class Config
---@field tabline_prefix string?
---@field tabline_suffix string?
local config = {
    tabline_prefix = "   ",
    tabline_suffix = "   ",
}

---@type Config
M.config = config

local function get_color(group, attr)
    return vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(group)), attr)
end

local function shorten_list_item_names(list)
    local shortened = {}

    local counts = {}
    for _, list_item in ipairs(list) do
        local name = vim.fn.fnamemodify(list_item.value, ":t")
        counts[name] = (counts[name] or 0) + 1
    end

    for _, file in ipairs(list) do
        local name = vim.fn.fnamemodify(file.value, ":t")

        if counts[name] == 1 then
            table.insert(shortened, { value = file.value, shortened = vim.fn.fnamemodify(name, ":t") })
        else
            table.insert(shortened, { value = file.value, shortened = file.value })
        end
    end

    return shortened
end

---@param args Config?
M.setup = function(args)
    M.config = vim.tbl_deep_extend("force", M.config, args or {})

    function _G.tabline()
        local items = shorten_list_item_names(harpoon:list().items)
        local tabline = ""

        local root = harpoon.config.default.get_root_dir()
        local current_buffer = vim.api.nvim_buf_get_name(0)
        for i, item in ipairs(items) do
            local is_current = current_buffer == root .. "/" .. item.value

            local label
            if item.shortened == "" or item.shortened == "(empty)" then
                label = "(empty)"
                is_current = false
            else
                label = item.shortened
            end

            if is_current then
                tabline = tabline
                    .. "%#HarpoonNumberActive#"
                    .. M.config.tabline_prefix
                    .. i
                    .. " %*"
                    .. "%#HarpoonActive#"
            else
                tabline = tabline
                    .. "%#HarpoonNumberInactive#"
                    .. M.config.tabline_prefix
                    .. i
                    .. " %*"
                    .. "%#HarpoonInactive#"
            end

            tabline = tabline .. label .. M.config.tabline_suffix .. "%*"

            if i < #items then
                tabline = tabline .. "%T"
            end
        end

        return tabline
    end

    vim.opt.showtabline = 2

    vim.o.tabline = "%!v:lua.tabline()"

    vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("harpoon", { clear = true }),
        pattern = { "*" },
        callback = function()
            local color = get_color("HarpoonActive", "bg#")

            if color == "" or color == nil then
                vim.api.nvim_set_hl(0, "HarpoonInactive", { link = "Tabline" })
                vim.api.nvim_set_hl(0, "HarpoonActive", { link = "TablineSel" })
                vim.api.nvim_set_hl(0, "HarpoonNumberActive", { link = "TablineSel" })
                vim.api.nvim_set_hl(0, "HarpoonNumberInactive", { link = "Tabline" })
            end
        end,
    })
end

return M
