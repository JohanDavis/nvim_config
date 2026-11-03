-- Enhanced completion capabilities for all LSP servers
vim.lsp.config("*", {
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

-- Lua language server configuration
vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
        },
    },
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
        local opts = { buffer = event.buf }

        -- Go to definition
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

        -- Go to declaration
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

        -- Find references
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

        -- Hover documentation
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

        -- Rename symbol
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        -- Code actions
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

        -- Show diagnostics
        vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

        -- Navigate diagnostics
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    end,
})
