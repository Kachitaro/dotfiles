return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- Plugin gõ tiếng Việt trực tiếp trong Neovim (Chỉ hoạt động ở Insert Mode)
  {
    "sontungexpt/vietnamese.nvim",
    dependencies = { "sontungexpt/bim.nvim" },
    event = "InsertEnter",
    opts = {
      enabled = true,
      input_method = "telex", -- "telex" hoặc "vni"
      orthography = "modern", -- "modern" (hòa, thúy) hoặc "old" (hoà, thuý)
    },
  },

  -- Tự động ép IME hệ điều hành (Windows/macOS/Linux) về English khi ra Normal mode / thoát Neovim
  {
    "keaising/im-select.nvim",
    event = "VeryLazy",
    opts = {
      default_im_select = "1033", -- US English
      default_command = "im-select",
      set_default_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },
      set_previous_events = { "InsertEnter" },
      async_switch_im = true,
    },
  },
}
