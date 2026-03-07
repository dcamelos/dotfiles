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
        vim.api.nvim_set_hl(0, group, { bg = "none" })
      end
      -- 3. ARREGLO PARA LA LÍNEA DEL CURSOR (CursorLine)
      -- Quitamos el fondo gris opaco y el subrayado blanco.
      -- 'blend' hace que el color se mezcle y no tape las letras.
      vim.api.nvim_set_hl(0, "CursorLine", {
        link = "Visual",
        -- bg = "#2a2e38", -- Un color oscuro que combine con tu fondo azulado
        underline = false, -- Eliminamos la línea blanca molesta
        blend = 20, -- Mezcla el color para que la sintaxis brille a través
      })
      local highlight_info = vim.api.nvim_get_hl(0, { name = "Keyword" })
      -- Opcional: Resaltar el número de línea actual para saber dónde estás
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = highlight_info.fg, bold = true })
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
