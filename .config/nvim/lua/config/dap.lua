require("dapui").setup()

-- Auto-open dapUI on dap events.
local dap, dapui = require("dap"), require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- Manualy toggle dapUI
vim.api.nvim_set_keymap("n", "<Leader>dui", ':lua require("dapui").toggle()<Enter>', {noremap=true})

-- toggle breakpoints
vim.api.nvim_set_keymap("n", "<Leader>bp", ':lua require("dap").toggle_breakpoint()<Enter>', {noremap=true})
