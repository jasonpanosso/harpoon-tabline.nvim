local M = {}

---@param list {value: any}
---@return string[]
M.shorten_list_item_names = function(list)
    local counts = {}
    for _, list_item in ipairs(list) do
        local name = vim.fn.fnamemodify(list_item.value, ":t")
        counts[name or ""] = (counts[name] or 0) + 1
    end

    local shortened = {}
    for _, file in ipairs(list) do
        local name = vim.fn.fnamemodify(file.value, ":t")

        if counts[name] == 1 then
            table.insert(shortened, vim.fn.fnamemodify(name, ":t"))
        else
            table.insert(shortened, file.value)
        end
    end

    return shortened
end

---@param path string
---@return string|nil
M.get_abs_path = function(path)
    return vim.fn.fnamemodify(path, ":p")
end

M.link_color_scheme_hl_groups = function()
    vim.api.nvim_set_hl(0, "HarpoonActive", { link = "TabLineSel" })
    vim.api.nvim_set_hl(0, "HarpoonInactive", { link = "TabLine" })
    vim.api.nvim_set_hl(0, "HarpoonNumberActive", { link = "TabLineSel" })
    vim.api.nvim_set_hl(0, "HarpoonNumberInactive", { link = "TabLine" })
end

return M
