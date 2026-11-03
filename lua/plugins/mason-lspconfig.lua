return {
    {
        "mason-org/mason-lspconfig.nvim",

        dependencies = {
            "mason-org/mason.nvim",
            "neovim/nvim-lspconfig",
        },

        opts = {
            ensure_installed = {
                -- Lua
                "lua_ls",

                -- C / C++
                "clangd",

                -- Python
                "pyright",

                -- Java
                "jdtls",

                -- JavaScript / TypeScript
                "ts_ls",

                -- Rust
                "rust_analyzer",
            },

            automatic_enable = true,
        },
    },
}
