return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    build = ":TSUpdate",

    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                -- General
                "c",
                "cpp",
                "python",
                "rust",
                "go",

                -- Web development
                "javascript",
                "typescript",
                "tsx",
                "html",
                "css",
                "json",

                -- Backend
                "c_sharp",
                "java",

                -- Configuration and scripting
                "lua",
                "vim",
                "vimdoc",
                "bash",
                "yaml",
                "toml",

                -- Other
                "sql",
                "markdown",
                "markdown_inline",
            },

            highlight = {
                enable = true,
            },

            indent = {
                enable = true,
            },

            sync_install = false,
        })
    end,
}
