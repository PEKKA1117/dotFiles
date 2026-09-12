return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- oil must load before netrw hijacks directory buffers
    lazy = false,
    config = function()
      require("oil").setup({
        default_file_explorer = true,
        delete_to_trash = true, -- uses gio trash
        skip_confirm_for_simple_edits = true,
        columns = { "icon" },
        win_options = {
          signcolumn = "yes:2",
        },
        view_options = {
          show_hidden = true,
        },
        float = {
          padding = 2,
          border = "rounded",
          win_options = {
            winblend = 0,
          },
        },
      })

      vim.keymap.set("n", "<leader>e", "<Cmd>Oil<CR>", { desc = "Open parent directory (oil)" })
      vim.keymap.set("n", "-", "<Cmd>Oil<CR>", { desc = "Open parent directory (oil)" })
      vim.keymap.set("n", "<leader>E", require("oil").toggle_float, { desc = "Open oil in a floating window" })
    end,
  },
}
