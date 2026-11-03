return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            --flavour = "latte"
            --flavour = "frappe"
            --flavour = "macchiato"
            flavour = "mocha"
        })
        vim.cmd.colorscheme("catppuccin")
    end,
}
