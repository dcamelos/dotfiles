return {
  { "rktjmp/lush.nvim" },
  { "rktjmp/shipwright.nvim" }, -- Añade esta línea

  {
    "oncomouse/lushwal.nvim",
    dependencies = { "rktjmp/lush.nvim", "rktjmp/shipwright.nvim" },
    lazy = false,
    priority = 1000,
    config = function()
      -- Creamos una función para aplicar tus estilos
      local function apply_my_highlights()
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
          vim.api.nvim_set_hl(0, group, { bg = "none", force = true })
        end

        -- Arreglo para CursorLine
        vim.api.nvim_set_hl(0, "CursorLine", {
          link = "Visual",
          underline = false,
          blend = 20,
        })
      end

      -- 1. Ejecutar inmediatamente al cargar el plugin
      vim.cmd.colorscheme("lushwal")
      apply_my_highlights()

      -- 2. "EL SEGURO": Re-aplicar si algo cambia el esquema después
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "lushwal",
        callback = apply_my_highlights,
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
