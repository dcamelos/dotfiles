return {
    "brenoprata10/nvim-highlight-colors",
    config = function()
        require("nvim-highlight-colors").setup({
            --- @usage 'background'|'foreground'|'virtualtext'
            render = 'background', -- Cómo se ve el color: fondo, texto o texto virtual
            enable_named_colors = true, -- Resalta nombres como 'Red', 'Blue', etc.
            enable_tailwind = true, -- ¡Muy útil si usas Tailwind CSS!
        })
    end
}
