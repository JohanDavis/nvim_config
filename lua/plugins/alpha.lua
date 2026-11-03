-- ~/.config/nvim/lua/plugins/alpha.lua
-- Two-column dashboard:
--   left  : NEOVIM on ONE line (block letters, diagonal gradient, shadowed edges),
--           a gradient accent bar, greeting, quote, date, cwd, git branch,
--           Neovim version and plugin/startup stats
--   right : actions (including update) and recent files
-- Narrow terminals fall back to a single stacked column.

return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")
    math.randomseed(os.time())

    local name = "Johan" -- change me
    local dw = vim.fn.strdisplaywidth
    local function ico(code)
      return vim.fn.nr2char(code)
    end

    ---------------------------------------------------------------------------
    -- The logo: NEOVIM on a single line
    ---------------------------------------------------------------------------
    local LOGO = {
      "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
      "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
      "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
      "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
      "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
      "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
    }
    local LOGO_W = 0
    for _, l in ipairs(LOGO) do
      LOGO_W = math.max(LOGO_W, dw(l))
    end

    ---------------------------------------------------------------------------
    -- Size knobs
    ---------------------------------------------------------------------------
    local SEP_W = 8 -- divider between columns
    local RW_MAX, RW_MIN = 58, 38 -- right column width limits
    local roomy = vim.o.lines >= 40 -- blank rows between items when there is space

    local cols = vim.o.columns
    local LW_TWO = LOGO_W + 2
    local two_col = cols >= LW_TWO + SEP_W + RW_MIN + 4
    local show_logo = cols >= LOGO_W + 6

    local RW, CW, W_TOTAL -- right width, left (content) width, total width
    if two_col then
      RW = math.min(RW_MAX, cols - LW_TWO - SEP_W - 4)
      CW = LW_TWO
      W_TOTAL = CW + SEP_W + RW
    else
      RW = math.min(RW_MAX, math.max(30, cols - 4))
      CW = RW
      W_TOTAL = RW
    end

    ---------------------------------------------------------------------------
    -- Highlights
    ---------------------------------------------------------------------------
    local NB = 20 -- number of gradient bands
    local stops = { "#22d3ee", "#818cf8", "#e879f9" } -- cyan -> indigo -> pink

    local function hex2rgb(h)
      return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16)
    end

    local function gradient_at(t)
      local seg = t * (#stops - 1)
      local i = math.min(math.floor(seg) + 1, #stops - 1)
      local f = seg - (i - 1)
      local r1, g1, b1 = hex2rgb(stops[i])
      local r2, g2, b2 = hex2rgb(stops[i + 1])
      return string.format(
        "#%02x%02x%02x",
        math.floor(r1 + (r2 - r1) * f + 0.5),
        math.floor(g1 + (g2 - g1) * f + 0.5),
        math.floor(b1 + (b2 - b1) * f + 0.5)
      )
    end

    local function set_highlights()
      for i = 1, NB do
        vim.api.nvim_set_hl(0, "AlphaGrad" .. i, { fg = gradient_at((i - 1) / (NB - 1)), bold = true })
      end
      vim.api.nvim_set_hl(0, "AlphaShadow", { fg = "#475569" })
      vim.api.nvim_set_hl(0, "AlphaGreeting", { fg = "#a78bfa", bold = true })
      vim.api.nvim_set_hl(0, "AlphaQuote", { fg = "#6b7280", italic = true })
      vim.api.nvim_set_hl(0, "AlphaSection", { fg = "#38bdf8", bold = true })
      vim.api.nvim_set_hl(0, "AlphaIcon", { fg = "#f472b6" })
      vim.api.nvim_set_hl(0, "AlphaKey", { fg = "#fbbf24", bold = true })
      vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#34d399", italic = true })
      vim.api.nvim_set_hl(0, "AlphaDivider", { fg = "#374151" })
      vim.api.nvim_set_hl(0, "AlphaLabel", { link = "Normal" })
    end
    set_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_highlights })

    ---------------------------------------------------------------------------
    -- Small helpers
    ---------------------------------------------------------------------------
    local function fit(s, w)
      return s .. string.rep(" ", math.max(0, w - dw(s)))
    end

    local function center_pad(s)
      return math.max(0, math.floor((CW - dw(s)) / 2))
    end

    local function centered(s)
      return string.rep(" ", center_pad(s)) .. s
    end

    local function shorten(s, max)
      if dw(s) <= max then
        return s
      end
      return "…" .. vim.fn.strcharpart(s, vim.fn.strchars(s) - (max - 1))
    end

    -- Add items to `target`, with a blank spec between them when there is room
    local blank = { text = "" }
    local function add_spaced(target, list)
      for i, item in ipairs(list) do
        target[#target + 1] = item
        if roomy and i < #list then
          target[#target + 1] = blank
        end
      end
    end

    ---------------------------------------------------------------------------
    -- Left column
    ---------------------------------------------------------------------------
    local function logo_rows()
      local rows = {}
      local pad = math.max(0, math.floor((CW - LOGO_W) / 2))
      for y, line in ipairs(LOGO) do
        local ranges, cur, start, bytes, x = {}, nil, 0, pad, 0
        for _, ch in ipairs(vim.fn.split(line, "\\zs")) do
          local grp
          if ch == "█" then
            -- diagonal gradient sweep across the letters
            local t = (x + 2 * (y - 1)) / (LOGO_W + 2 * (#LOGO - 1))
            grp = "AlphaGrad" .. (math.floor(t * (NB - 1) + 0.5) + 1)
          elseif ch ~= " " then
            grp = "AlphaShadow" -- box-drawing edges act as the shadow
          end
          if grp ~= cur then
            if cur then
              ranges[#ranges + 1] = { cur, start, bytes }
            end
            cur, start = grp, bytes
          end
          bytes = bytes + #ch
          x = x + 1
        end
        if cur then
          ranges[#ranges + 1] = { cur, start, bytes }
        end
        rows[#rows + 1] = { text = string.rep(" ", pad) .. line, hl = ranges }
      end
      return rows
    end

    local function accent_row()
      local w = math.floor(LOGO_W * 0.6)
      local pad = math.max(0, math.floor((CW - w) / 2))
      local ranges, cur, start, bytes = {}, nil, 0, pad
      for i = 0, w - 1 do
        local grp = "AlphaGrad" .. (math.floor(i / (w - 1) * (NB - 1) + 0.5) + 1)
        if grp ~= cur then
          if cur then
            ranges[#ranges + 1] = { cur, start, bytes }
          end
          cur, start = grp, bytes
        end
        bytes = bytes + #"━"
      end
      ranges[#ranges + 1] = { cur, start, bytes }
      return { text = string.rep(" ", pad) .. string.rep("━", w), hl = ranges }
    end

    local function greeting()
      local h = tonumber(os.date("%H"))
      local icon, msg
      if h < 5 then
        icon, msg = ico(0xf186), "Burning the midnight oil"
      elseif h < 12 then
        icon, msg = ico(0xf0f4), "Good morning"
      elseif h < 17 then
        icon, msg = ico(0xf185), "Good afternoon"
      elseif h < 21 then
        icon, msg = ico(0xf185), "Good evening"
      else
        icon, msg = ico(0xf186), "Late night session"
      end
      return string.format("%s  %s, %s", icon, msg, name)
    end

    local quotes = {
      "Make it work, make it right, make it fast.",
      "Talk is cheap. Show me the code.",
      "There is no place like 127.0.0.1.",
      "It works on my machine.",
      "To iterate is human, to recurse divine.",
      "Real programmers exit with :wq.",
      "ESC, :w, repeat. Muscle memory wins.",
      "Simplicity is prerequisite for reliability.",
      "First, solve the problem. Then, code.",
    }

    local function info_line(code, s)
      local icon = ico(code)
      local body = icon .. "  " .. s
      local pad = center_pad(body)
      return {
        text = string.rep(" ", pad) .. body,
        hl = { { "AlphaIcon", pad, pad + #icon }, { "AlphaLabel", pad + #icon, pad + #body } },
      }
    end

    local function git_branch()
      if vim.fn.executable("git") ~= 1 then
        return nil
      end
      local out = vim.fn.systemlist({ "git", "-C", vim.fn.getcwd(), "rev-parse", "--abbrev-ref", "HEAD" })
      if vim.v.shell_error ~= 0 or not out[1] or out[1] == "" then
        return nil
      end
      return out[1]
    end

    local left = {}
    local function ladd(s)
      left[#left + 1] = s
    end

    if show_logo then
      for _, r in ipairs(logo_rows()) do
        ladd(r)
      end
      ladd(accent_row())
      ladd(blank)
      if roomy then
        ladd(blank)
      end
    end

    ladd({ text = centered(greeting()), hl = "AlphaGreeting" })
    ladd({ text = centered(shorten(quotes[math.random(#quotes)], CW - 2)), hl = "AlphaQuote" })
    ladd(blank)
    if roomy then
      ladd(blank)
    end

    local v = vim.version()
    local infos = {
      info_line(0xf073, os.date("%A, %d %B")),
      info_line(0xf07b, shorten(vim.fn.fnamemodify(vim.fn.getcwd(), ":~"), CW - 8)),
    }
    local branch = git_branch()
    if branch then
      infos[#infos + 1] = info_line(0xf126, shorten(branch, CW - 8))
    end
    infos[#infos + 1] = info_line(0xf121, string.format("Neovim v%d.%d.%d", v.major, v.minor, v.patch))
    add_spaced(left, infos)

    ladd(blank)
    ladd({ kind = "footer", text = centered(ico(0xf0e7) .. "  loading…"), hl = "AlphaFooter" })

    ---------------------------------------------------------------------------
    -- Right column
    ---------------------------------------------------------------------------
    local function section(title)
      local label = "── " .. title .. " "
      return { text = label .. string.rep("─", math.max(0, RW - dw(label))), hl = "AlphaSection" }
    end

    local actions = {
      { "f", ico(0xf07c), "Find file", "<cmd>Telescope find_files<CR>" },
      { "g", ico(0xf002), "Live grep", "<cmd>Telescope live_grep<CR>" },
      { "o", ico(0xf017), "Old files", "<cmd>Telescope oldfiles<CR>" },
      { "n", ico(0xf15b), "New file", "<cmd>ene | startinsert<CR>" },
      { "c", ico(0xf013), "Config", "<cmd>e $MYVIMRC | cd %:p:h<CR>" },
      { "u", ico(0xf021), "Update plugins", "<cmd>Lazy update<CR>" },
      { "l", ico(0xf0e7), "Lazy", "<cmd>Lazy<CR>" },
      { "q", ico(0xf011), "Quit", "<cmd>qa<CR>" },
    }

    local function button_spec(key, icon, icon_hl, label, cmd)
      local text = icon .. "  " .. label
      return {
        kind = "button",
        key = key,
        cmd = cmd,
        text = text,
        hl = { { icon_hl, 0, #icon }, { "AlphaLabel", #icon, #text } },
      }
    end

    local function recent_files(max)
      local ok_dev, devicons = pcall(require, "nvim-web-devicons")
      local cwd = vim.fn.getcwd()
      local out = {}
      for _, f in ipairs(vim.v.oldfiles) do
        if #out >= max then
          break
        end
        if vim.fn.filereadable(f) == 1 and f:find(cwd, 1, true) == 1 then
          local fname = vim.fn.fnamemodify(f, ":t")
          local icon, icon_hl = ico(0xf15b), "AlphaIcon"
          if ok_dev then
            icon, icon_hl = devicons.get_icon(fname, vim.fn.fnamemodify(fname, ":e"), { default = true })
          end
          out[#out + 1] = button_spec(
            tostring(#out + 1),
            icon,
            icon_hl or "AlphaIcon",
            shorten(vim.fn.fnamemodify(f, ":~:."), RW - 10),
            "<cmd>e " .. vim.fn.fnameescape(f) .. "<CR>"
          )
        end
      end
      return out
    end

    local right = {}
    local function radd(s)
      right[#right + 1] = s
    end

    radd(section("Actions"))
    if roomy then
      radd(blank)
    end
    local action_specs = {}
    for _, a in ipairs(actions) do
      action_specs[#action_specs + 1] = button_spec(a[1], a[2], "AlphaIcon", a[3], a[4])
    end
    add_spaced(right, action_specs)

    radd(blank)
    radd(section("Recent in " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")))
    if roomy then
      radd(blank)
    end
    local recents = recent_files(5)
    if #recents == 0 then
      radd({ text = "Nothing here yet. Time to create something.", hl = "AlphaQuote" })
    else
      add_spaced(right, recents)
    end

    ---------------------------------------------------------------------------
    -- Stitch columns into screen rows
    ---------------------------------------------------------------------------
    local screen = {}
    if two_col then
      local n = math.max(#left, #right)
      local lo, ro = math.floor((n - #left) / 2), math.floor((n - #right) / 2)
      for i = 1, n do
        screen[i] = { l = left[i - lo], r = right[i - ro] }
      end
    else
      for _, s in ipairs(left) do
        screen[#screen + 1] = { l = s }
      end
      screen[#screen + 1] = {}
      for _, s in ipairs(right) do
        screen[#screen + 1] = { r = s }
      end
    end

    -- Returns the row string, highlight ranges and the byte offset of the right column
    local function build(pair)
      local val, hl = "", {}
      local function put(text, h)
        local s = #val
        val = val .. text
        if type(h) == "string" then
          hl[#hl + 1] = { h, s, #val }
        elseif h then
          for _, x in ipairs(h) do
            hl[#hl + 1] = { x[1], s + x[2], s + x[3] }
          end
        end
        return s
      end

      local l, r = pair.l, pair.r
      local start = 0
      if two_col then
        put(l and fit(l.text, CW) or string.rep(" ", CW), l and l.hl)
        put("    ")
        put("│", "AlphaDivider")
        put("   ")
        start = put(r and r.text or "", r and r.hl)
      else
        local one = l or r
        if one then
          start = put(one.text, one.hl)
        end
      end
      return val, hl, start
    end

    local function text_el(val, hl)
      local padded = val .. string.rep(" ", math.max(0, W_TOTAL - dw(val)))
      return { type = "text", val = { padded }, opts = { position = "center", hl = { hl } } }
    end

    local elements, footer = {}, nil
    for i, pair in ipairs(screen) do
      local r = pair.r
      if r and r.kind == "button" then
        local val, hl, start = build(pair)
        local b = dashboard.button(r.key, r.text, r.cmd)
        b.val = val
        b.opts.hl = hl
        b.opts.shortcut = "[" .. r.key .. "]"
        b.opts.hl_shortcut = "AlphaKey"
        b.opts.width = W_TOTAL
        b.opts.cursor = start
        elements[i] = b
      else
        local val, hl = build(pair)
        elements[i] = text_el(val, hl)
        if (pair.l and pair.l.kind == "footer") or (r and r.kind == "footer") then
          footer = { el = elements[i], pair = pair }
        end
      end
    end

    ---------------------------------------------------------------------------
    -- Footer: filled in once lazy.nvim reports its stats
    ---------------------------------------------------------------------------
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyVimStarted",
      once = true,
      callback = function()
        if not footer then
          return
        end
        local stats = require("lazy").stats()
        local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
        local txt = string.format("%s  %d/%d plugins loaded in %sms", ico(0xf0e7), stats.loaded, stats.count, ms)
        local spec = footer.pair.l or footer.pair.r
        spec.text = centered(txt)
        local val, hl = build(footer.pair)
        footer.el.val = { val .. string.rep(" ", math.max(0, W_TOTAL - dw(val))) }
        footer.el.opts.hl = { hl }
        pcall(vim.cmd.AlphaRedraw)
      end,
    })

    ---------------------------------------------------------------------------
    -- Final layout (vertically centered)
    ---------------------------------------------------------------------------
    local top_pad = math.max(1, math.floor((vim.fn.winheight(0) - #screen) / 2) - 1)

    dashboard.config.layout = {
      { type = "padding", val = top_pad },
      { type = "group", val = elements, opts = { spacing = 0 } },
    }
    dashboard.config.opts.noautocmd = true
    alpha.setup(dashboard.config)

    ---------------------------------------------------------------------------
    -- Clean look while the dashboard is open
    ---------------------------------------------------------------------------
    vim.api.nvim_create_autocmd("User", {
      pattern = "AlphaReady",
      callback = function()
        local prev_ls, prev_tl = vim.o.laststatus, vim.o.showtabline
        vim.o.laststatus = 0
        vim.o.showtabline = 0
        vim.api.nvim_create_autocmd("BufUnload", {
          buffer = 0,
          once = true,
          callback = function()
            vim.o.laststatus = prev_ls
            vim.o.showtabline = prev_tl
          end,
        })
      end,
    })
  end,
}
