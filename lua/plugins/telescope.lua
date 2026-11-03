return {
    {
        "nvim-telescope/telescope.nvim",
        version = "*",
        lazy = false,

        dependencies = {
            -- Required
            "nvim-lua/plenary.nvim",

            -- Native fuzzy matching
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
            },

            -- File icons
            "nvim-tree/nvim-web-devicons",

            -- UI select extension
            "nvim-telescope/telescope-ui-select.nvim",
        },

        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Find help" },
        },

        config = function()
            local telescope = require("telescope")

            telescope.setup({
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown({
                            winblend = 10,
                            previewer = false,
                        }),
                    },
                },
            })

            -- Load extensions
            telescope.load_extension("fzf")
            telescope.load_extension("ui-select")
        end,
    },
}
