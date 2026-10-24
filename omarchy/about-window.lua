-- Optional Omarchy integration for the Fastfetch "About" window.
--
-- Omarchy's About menu item runs `omarchy-launch-about`, which uses
-- ~/.config/fastfetch/config.jsonc when it exists. These rules preserve the
-- smaller window size used by this Fastfetch layout.
--
-- Merge these lines into ~/.config/hypr/hyprland.lua, or copy this file to
-- ~/.config/hypr/fastfetch-about.lua and add:
--     require("hypr.fastfetch-about")
--
-- This file is deliberately not installed automatically because it changes
-- Hyprland window rules, which are outside the Fastfetch configuration itself.

o.window("org.omarchy.about", { center = true })
o.window("org.omarchy.about", { size = { 620, 400 } })
