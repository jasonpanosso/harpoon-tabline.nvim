local has_harpoon, harpoon = pcall(require, "harpoon")
if not has_harpoon then
    error("harpoon-tabline.nvim requires ThePrimeagen/harpoon")
end
local has_extensions, _ = pcall(require, "harpoon.extensions")
if not has_extensions then
    error("Unable to find harpoon.extensions while initing harpoon-tabline.nvim. Are you using Harpoon 2?")
end
local utils = require("harpoon-tabline.utils")

---@class HarpoonTabline
local M = {}

---@class Config
---@field tab_prefix? string
---@field tab_suffix? string
---@field use_editor_color_scheme? boolean
---@field empty_label? string
---@field show_empty? boolean
---@field format_item_names? (fun(list: {value: any}): string[])
local config = {
    tab_prefix = " ",
    tab_suffix = " ",
    use_editor_color_scheme = true,
    empty_label = "(empty)",
    show_empty = true,
    format_item_names = utils.shorten_list_item_names,
}

---@type Config
M.config = config

---@param args Config?
M.setup = function(args)
    M.config = vim.tbl_deep_extend("force", M.config, args or {})

    function _G.tabline()
        local list = harpoon:list()
        local length = list:length()
        local items_shortened = M.config.format_item_names(list)
        local tabline = ""

        local cur_bufnr = vim.api.nvim_get_current_buf()
        local cur_buf_path = vim.api.nvim_buf_get_name(cur_bufnr)
        local cur_buf_abs_path = utils.get_abs_path(cur_buf_path)

        for i = 1, length do
            local item = items_shortened[i]
            local skip = false
            local is_cur_buf

            if item == nil then
                if not M.config.show_empty then
                    skip = true
                else
                    item = M.config.empty_label
                end

                is_cur_buf = false
            else
                is_cur_buf = cur_buf_abs_path == utils.get_abs_path(list.items[i].value)
            end

            if not skip then
                local num_highlight_group = "%#" .. (is_cur_buf and "HarpoonNumberActive" or "HarpoonNumberInactive") .. "#"
                local item_highlight_group = "%#" .. (is_cur_buf and "HarpoonActive" or "HarpoonInactive") .. "#"

                local tab = num_highlight_group
                    .. M.config.tab_prefix
                    .. i
                    .. " %*"
                    .. item_highlight_group
                    .. item
                    .. M.config.tab_suffix
                    .. "%*"

                if i < #items_shortened then
                    tab = tab .. "%T"
                end

                tabline = tabline .. tab
            end
        end

        return tabline
    end

    vim.opt.showtabline = 2

    vim.opt.tabline = "%!v:lua.tabline()"

    -- by default, harpoon:list():append() will not trigger a tabline update,
    -- and for some reason vim.cmd.redrawtabline() does not work here. Resetting
    -- vim.op.tabline does though! X)
    harpoon:extend({
        ADD = function()
            vim.opt.tabline = "%!v:lua.tabline()"
        end,
        REMOVE = function()
            vim.opt.tabline = "%!v:lua.tabline()"
        end,
    })

    if M.config.use_editor_color_scheme then
        -- link hl groups in autocmd callback, and immediately link hl groups to
        -- avoid load order race condition with color scheme plugin
        utils.link_color_scheme_hl_groups()

        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("harpoon-tabline", { clear = true }),
            pattern = { "*" },
            callback = function()
                utils.link_color_scheme_hl_groups()
            end,
        })
    end
end

return M
