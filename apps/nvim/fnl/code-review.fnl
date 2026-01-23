(local code-review (require :code-review))
(code-review.setup)

(vim.api.nvim_create_autocmd :User
                             {:pattern :CodeReviewInputEnter
                              :callback (fn [ev]
                                          (local buf ev.data.buf)
                                          (local cr (require :code-review))
                                          (local funcs
                                                 (cr.get_input_buffer_functions buf))
                                          (vim.keymap.set [:i :n] :<C-s>
                                                          funcs.submit
                                                          {:buffer buf})
                                          (vim.keymap.set :n :<Esc>
                                                          funcs.cancel
                                                          {:buffer buf})
                                          (vim.keymap.set :n :q funcs.cancel
                                                          {:buffer buf}))})
