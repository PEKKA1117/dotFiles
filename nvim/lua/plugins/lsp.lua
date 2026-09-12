return {
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup({})
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        automatic_enable = true,
        ensure_installed = {
          "lua_ls",
          "vimls",
          "clangd",
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- nvim-lspconfig ships the per-server configs; enable them with the native
      -- API instead of the deprecated `require("lspconfig")` framework.
      -- See :help lspconfig-nvim-0.11
      local servers = { "lua_ls", "vimls", "clangd" }

      -- The old framework fell back to the file's own directory when no project
      -- marker was found; keep that so single files still get a server.
      for _, name in ipairs(servers) do
        local markers = vim.lsp.config[name].root_markers
        vim.lsp.config(name, {
          root_dir = function(bufnr, on_dir)
            on_dir(vim.fs.root(bufnr, markers) or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
          end,
        })
      end

      vim.lsp.enable(servers)

      -- Only set keymap when LSP is attached
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }

          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set({ "n" }, "<C-A>", vim.lsp.buf.code_action, opts)
        end,
      })
    end,
  },
}
