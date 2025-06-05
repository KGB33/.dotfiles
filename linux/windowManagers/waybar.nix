{...}: {
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
    };
    settings.mainBar = {
      modules-left = ["hyprland/workspaces" "hyprland/submap"];
      modules-center = ["hyprland/window"];
      modules-right = ["network" "backlight" "battery" "clock"];
      clock = {
        format = "{:%I:%M%p}";
        format-alt = "{:%I:%M%p %a, %b %d}";
        tooltip = false;
      };
      backlight = {
        format = "{icon} {percent}%";
        format-icons = ["" "" "" "" "" "" "" "" ""];
      };
      battery = {
        states = {
          "warning" = 30;
          "critical" = 15;
        };
        format = "{icon} {capacity}%";
        format-full = "{icon} {capacity}%";
        format-charging = " {capacity}%";
        format-plugged = " {capacity}%";
        format-alt = "{icon} {time}";
        format-icons = ["" "" "" "" ""];
        tooltip = false;
      };
      bluetooth = {
        format = "";
      };
      network = {
        format = "{ifname}";
        format-wifi = "{essid} ({signalStrength}%) ";
        format-ethernet = "{ipaddr}/{cidr} 󰊗";
        tooltip = false;
      };
      reload_style_on_change = true;
    };
    style = builtins.readFile ./waybar.css;
  };
}
