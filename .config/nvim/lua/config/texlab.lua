require'lspconfig'.texlab.setup({
  log_level = vim.lsp.protocol.MessageType.Log;
  settings = {
  texlab = {
      build = {
          args = { "%f" };
          executable = "tectonic";
          forwardSearchAfter = false;
          onSave = true;
        }
    }
}
});
