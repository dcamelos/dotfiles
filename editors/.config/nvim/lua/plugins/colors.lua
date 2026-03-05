return {
  { "rktjmp/lush.nvim" },
  { "rktjmp/shipwright.nvim" }, -- Añade esta línea

  {
    "oncomouse/lushwal.nvim",
    dependencies = {
      "rktjmp/lush.nvim",
      "rktjmp/shipwright.nvim", -- También aquí como dependencia
    },
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("lushwal")
      local groups = {
        "Normal", -- Fondo principal
        "NormalNC", -- Fondo en ventanas inactivas
        "NormalFloat", -- Ventanas flotantes (LSP, diagnósticos)
        "FloatBorder", -- Bordes de ventanas flotantes
        "SignColumn", -- Columna de signos (iconos de Git/errores)
        "LineNr", -- Números de línea
        "CursorLineNr", -- Número de línea actual
        "EndOfBuffer", -- Los tildes (~) al final del archivo
        "MsgArea", -- Área de mensajes/comandos abajo
        "StatusLine", -- Barra de estado (si Lualine no la tapa)
        "StatusLineNC", -- Barra de estado inactiva
        "NvimTreeNormal", -- Si usas NvimTree (explorador de archivos)
      }

      for _, group in ipairs(groups) do
        vim.api.nvim_set_hl(0, "CursorLine", { underline = true, bg = "none" })
      end
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- Para iconos bonitos
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto", -- 'auto' detectará los colores de lushwal/pywal
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
      })
    end,
  },
}
