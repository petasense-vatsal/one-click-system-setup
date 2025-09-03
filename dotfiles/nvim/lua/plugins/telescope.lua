return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    -- Find files (even outside Git)
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files (all)" },
    -- Grep project content (live grep)
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep (content)" },
    -- Grep word under cursor
    { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Grep Word Under Cursor" },
    -- Optional: Search open buffers
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" },
  },
  config = function()
    require("telescope").setup({
      defaults = {
        file_ignore_patterns = { "node_modules", "%.git", "dist", "build" },
      },
    })
  end,
}
