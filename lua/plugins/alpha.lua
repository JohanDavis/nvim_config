-- ~/.config/nvim/lua/plugins/alpha.lua
-- A standalone Alpha dashboard configuration.
-- No external image files or custom dashboard dependencies required.

return {
    {
        "goolord/alpha-nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        event = "VimEnter",
        config = function()
            local alpha = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            -- Header
            dashboard.section.header.val = {
                [[                                                                       ]],
                [[  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗                    ]],
                [[  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║                    ]],
                [[  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║                    ]],
                [[  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║                    ]],
                [[  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║                    ]],
                [[  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝                    ]],
                [[                                                                       ]],
                [[                    CODE  •  CREATE  •  REPEAT                         ]],
            }

            dashboard.section.header.opts = {
                position = "center",
                hl = "AlphaHeader",
            }

            -- Menu buttons. Alpha's dashboard.button expects a key string.
            dashboard.section.buttons.val = {
                dashboard.button("f", "󰱼  Find file", "<cmd>Telescope find_files<CR>"),
                dashboard.button("g", "󰈬  Find text", "<cmd>Telescope live_grep<CR>"),
                dashboard.button("r", "󰋚  Recent files", "<cmd>Telescope oldfiles<CR>"),
                dashboard.button("n", "󰝒  New file", "<cmd>enew<CR>"),
                dashboard.button("e", "󰙅  File explorer", "<cmd>Neotree toggle<CR>"),
                dashboard.button("c", "  Neovim config", "<cmd>edit $MYVIMRC<CR>"),
                dashboard.button("u", "󰚰  Update plugins", "<cmd>Lazy sync<CR>"),
                dashboard.button("q", "󰗼  Quit Neovim", "<cmd>qa<CR>"),
            }

            dashboard.section.buttons.opts = {
                position = "center",
                spacing = 1,
            }

            -- Footer
            local function footer()
                local version = vim.version()
                local nvim_version = string.format(
                    "Neovim %d.%d.%d",
                    version.major,
                    version.minor,
                    version.patch
                )
                local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
                return {
                    "",
                    "  " .. cwd,
                    "  " .. nvim_version .. "  •  " .. os.date("%A, %d %B %Y"),
                }
            end

            dashboard.section.footer.val = footer()
            dashboard.section.footer.opts = {
                position = "center",
                hl = "AlphaFooter",
            }

            -- Highlights
            local function set_highlights()
                vim.api.nvim_set_hl(0, "AlphaHeader", { link = "Title" })
                vim.api.nvim_set_hl(0, "AlphaFooter", { link = "Comment" })
                vim.api.nvim_set_hl(0, "AlphaButtons", { link = "Keyword" })
            end

            set_highlights()

            -- Layout: keep the structure simple to avoid nil width/height
            -- calculations in Alpha's layout renderer.
            dashboard.config.layout = {
                { type = "padding", val = 2 },
                dashboard.section.header,
                { type = "padding", val = 2 },
                dashboard.section.buttons,
                { type = "padding", val = 1 },
                dashboard.section.footer,
            }

            dashboard.config.opts = {
                margin = 3,
            }

            alpha.setup(dashboard.config)

            -- Refresh highlights if the colorscheme changes.
            vim.api.nvim_create_autocmd("ColorScheme", {
                group = vim.api.nvim_create_augroup("AlphaDashboardHighlights", { clear = true }),
                callback = set_highlights,
            })
        end,
    },
}
