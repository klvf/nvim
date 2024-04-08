local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, true)[1]:sub(col, col):match("%s") == nil
end

local limitStr = function(str)
    if #str > 25 then
        str = string.sub(str, 1, 22) .. "..."
    end
    return str
end

local dartColonFirst = function(entry1, entry2)
    if vim.bo.filetype ~= "dart" then
        return nil
    end
    local entry1EndsWithColon = string.find(entry1.completion_item.label, ":") and entry1.source.name == "nvim_lsp"
    local entry2EndsWithColon = string.find(entry2.completion_item.label, ":") and entry2.source.name == "nvim_lsp"
    if entry1EndsWithColon and not entry2EndsWithColon then
        return true
    elseif not entry1EndsWithColon and entry2EndsWithColon then
        return false
    end
    return nil
end

local dartColonFirst = function(entry1, entry2)
    if vim.bo.filetype ~= "python" then
        return nil
    end
    local entry1StartsWithUnderscore = string.sub(entry1.completion_item.label, 1, 1) == "_" and entry1.source.name  == "nvim_lsp"
    local entry2StartsWithUnderscore = string.sub(entry2.completion_item.label, 1, 1) == "_" and entry2.source.name  == "nvim_lsp"
    if entry1StartsWithUnderscore and not entry2StartsWithUnderscore then
        return false
    elseif not entry1StartsWithUnderscore and entry2StartsWithUnderscore then
        return false
    end
    return nil
end

local label_comparator = function(entry1, entry2)
    return entry1.completion_item.label < entry2.completion_item.label
end

local setCompHL = function()
end

local moveCursorBeforeComma = function()
    if vim.bo.filetype ~= "dart" then
        return
    end
    vim.defer_fn(function()
        local line = vim.api.nvim_get_current_line()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local char = line:sub(col - 2, col)
        if char == ": ,"then
            vim.api.nvim_win_set_cursor(0, { row, col - 1 })
        end
    end, 100)
end

local M = {}

M.config = {
    "hrsh7th/nvim-cmp",
    after = "SirVer/ultisnips",
    dependencies = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-calc",
        -- "andersevenrud/cmp-tmux",
        {
            "onsails/lspkind.nvim",
            lazy = false,
            config = function()
                require("lspkind").init()
            end,
        },
        {
            "quangnguyen30192/cmp-nvim-ultisnips",
            config = function()
                require("cmp_nvim_ultisnips").setup{}
            end,
        },
        -- "L3MON4D3/LuaSnip",
    },
}

M.configfunc = function()
    local lspkind = require("lspkind")
    vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
    local cmp = require("cmp")
    local cmp_ultisnips_mappings = require("cmp_nvim_ultisnips.mappings")
    -- local luanip = require("luasnip")

    setCompHL()
    cmp.setup({
        preselect = cmp.PreselectMode.None,
        snippet = {
            expand = function(args)
                vim.fn["UltiSnips#Anon"](args.body)
            end,
        },
        window = {
            completion = {
                -- winhighlight = "Normal:Pmenu, FloatBorder:Pmenu, Search:None",
                col_offset = -3,
                side_padding = 0,
            },
            documentation = cmp.config.window.bordered(),
        },
        sorting = {
            comparators = {
                -- label_comparator,
                dartColonFirst,
                cmp.config.compare.offset,
                cmp.config.compare.exact,
                cmp.config.compare.score,
                cmp.config.compare.recently_used,
                cmp.config.compare.kind,
            },
        },
        formatting = {
            fields = { "kind", "abbr", "menu" },
            maxwidth = 60,
            maxheight = 10,
            format = function(entry, vim_item)
                local kind = lspkind.cmp_format({
                    mode = "symbol_text",
                    symbol_map = { Codeium = "", },
                })(entry, vim_item)
                local strings = vim.split(kind.kind, "%s", { trimempty = true })
                kind.kind = " " .. (strings[1] or "") .. " "
                kind.menu = limitStr(entry:get_completion_item().detail or "")
                return kind
            end,
        },
        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "buffer" },
        }, {
            { name = "path" },
            { name = "nvim_lua" },
            { name = "calc" },
            -- { name = "luasnip" },
            -- { name = "tmux", option = { all_panes = true, } }, -- this is kinda slow
        }),
        mapping = cmp.mapping.preset.insert({
            ["<C-o>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping(
                function()
                    cmp_ultisnips_mappings.compose { "expand", "jump_forwards" } (function() end)
                end,
                { "i", "s", --[[ "c" (to enable the mapping in command mode) ]] }
            ),
            ["<C-n>"] = cmp.mapping(
                function(fallback)
                    cmp_ultisnips_mappings.jump_backwards(fallback)
                end,
                { "i", "s", --[[ "c" (to enable the mapping in command mode) ]] }
            ),
            ["<C-f>"] = cmp.mapping({
                i = function(fallback)
                    cmp.close()
                    fallback()
                end
            }),
            ["<C-y>"] = cmp.mapping({ i = function(fallback) fallback() end }),
            ["<C-u>"] = cmp.mapping({ i = function(fallback) fallback() end }),
            ["<CR>"] = cmp.mapping({
                i = function(fallback)
                    if cmp.visible() and cmp.get_active_entry() then
                        cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                    else
                        fallback()
                    end
                end
            }),
            ["<Tab>"] = cmp.mapping({
                i = function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
                        moveCursorBeforeComma()
                    elseif has_words_before() then
                        cmp.complete()
                        moveCursorBeforeComma()
                    else
                        fallback()
                    end
                end,
            }),
            ["<S-Tab>"] = cmp.mapping({
                i = function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
                        moveCursorBeforeComma()
                    else
                        fallback()
                    end
                end,
            }),
        }),
    })
end

return M
