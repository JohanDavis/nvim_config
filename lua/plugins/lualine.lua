return {
    {
        "nvim-lualine/lualine.nvim",

        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },

        config = function()
            local function get_filename()
                local filename = vim.fn.expand("%:t")
                return filename ~= "" and filename or "[No Name]"
            end

            require("lualine").setup({
                options = {
                    theme = "dracula",
                    globalstatus = true,
                    icons_enabled = true,
                    component_separators = {
                        left = "│",
                        right = "│",
                    },
                    section_separators = {
                        left = "",
                        right = "",
                    },
                    disabled_filetypes = {
                        statusline = { "alpha", "neo-tree" },
                    },
                    always_divide_middle = true,
                },

                sections = {
                    lualine_a = {
                        {
                            "mode",
                            fmt = function(str)
                                return str:sub(1, 1)
                            end,
                        },
                    },

                    lualine_b = {
                        "branch",
                        {
                            "diff",
                            symbols = {
                                added = " ",
                                modified = " ",
                                removed = " ",
                            },
                        },
                    },

                    lualine_c = {
                        {
                            "filename",
                            path = 1,
                            symbols = {
                                modified = " ●",
                                readonly = " ",
                                unnamed = "[No Name]",
                            },
                        },
                    },

                    lualine_x = {
                        {
                            "diagnostics",
                            sources = { "nvim_diagnostic" },
                            symbols = {
                                error = " ",
                                warn = " ",
                                info = " ",
                                hint = "󰌵 ",
                            },
                        },
                        "encoding",
                        "fileformat",
                        "filetype",
                    },

                    lualine_y = {
                        "progress",
                    },

                    lualine_z = {
                        "location",
                    },
                },

                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { "filename" },
                    lualine_x = { "location" },
                    lualine_y = {},
                    lualine_z = {},
                },

                extensions = {
                    "neo-tree",
                    "lazy",
                    "mason",
                    "trouble",
                    "toggleterm",
                },
            })
        end,
    },
}
