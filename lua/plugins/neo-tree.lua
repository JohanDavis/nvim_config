return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",

        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },

        keys = {
            {
                "<leader>e",
                "<cmd>Neotree toggle<cr>",
                desc = "Toggle file explorer",
            },
        },
        lazy = false,
    },
}
