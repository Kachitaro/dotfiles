require "nvchad.autocmds"


if vim.fn.has("win32") == 1 and vim.fn.executable("im-select.exe") == 1 then
  local default_im = "1033"
  local current_im = default_im

  local function get_im()
    local result = vim.fn.system('im-select.exe')
    return result:gsub("%s+", "")
  end

  local function set_im(im)
    vim.fn.jobstart({ 'im-select.exe', im }, { detach = true })
  end

  local im_augroup = vim.api.nvim_create_augroup("IMSelect", { clear = true })

  vim.api.nvim_create_autocmd("InsertLeave", {
    group = im_augroup,
    callback = function()
      current_im = get_im()
      set_im(default_im)
    end,
  })

  vim.api.nvim_create_autocmd("InsertEnter", {
    group = im_augroup,
    callback = function()
      set_im(current_im)
    end,
  })

  vim.api.nvim_create_autocmd("VimEnter", {
    group = im_augroup,
    callback = function()
      set_im(default_im)
    end,
  })

  vim.api.nvim_create_autocmd("CmdlineEnter", {
    group = im_augroup,
    callback = function()
      set_im(default_im)
    end,
  })
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("nvim-tree.api").tree.open()
    
    -- Nếu bạn muốn mở Neovim lên, sidebar hiện ra nhưng con trỏ chuột (focus) 
    -- tự động nhảy sang cửa sổ soạn thảo code chính thì bỏ comment dòng bên dưới:
    -- vim.cmd("wincmd p")
  end,
})
