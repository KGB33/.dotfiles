(local dap (require :dap))

(set dap.adapters.erlang-edb
  { :type "executable"
    :command "edb"
    :args ["dap"]
  })


(set dap.configurations.gleam
  [{ :type "erlang-edb"
    :request "launch"
    :name "Launch Gleam with Erlang target"
    :runInTerminal {
      :kind "integrated"
      :cwd "$(workspaceFolder)"
      :args ["gleam" "run"]
    }
  }])

(local dapui (require :dapui))

(dapui.setup)
(local dapListeners dap.listeners.before)

;; Auto-open dap-ui on dap events
(set dapListeners.attach.dapui_config (fn [] (dapui.open)))
(set dapListeners.launch.dapui_config (fn [] (dapui.open)))
(set dapListeners.event_terminated.dapui_config (fn [] (dapui.close)))
(set dapListeners.event_exited.dapui_config (fn [] (dapui.close)))
