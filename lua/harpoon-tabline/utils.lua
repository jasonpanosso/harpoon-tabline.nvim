local M = {}

---@param list HarpoonList
---@return string[]
M.shorten_list_item_names = function(list)
    local counts = {}
    local length = list:length()

    for i = 1, length do
        local list_item = list.items[i]
        if list_item ~= nil then
            local name = vim.fn.fnamemodify(list_item.value, ":t")
            counts[name or ""] = (counts[name] or 0) + 1
        end
    end

    local shortened = {}
    for i = 1, length do
        local file = list.items[i]
        if file == nil then
            table.insert(shortened, i, nil)
        else
            local name = vim.fn.fnamemodify(file.value, ":t")

            if counts[name] == 1 then
                table.insert(shortened, i, vim.fn.fnamemodify(name, ":t"))
            else
                table.insert(shortened, i, file.value)
            end
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
