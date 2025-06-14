#!/bin/bash
set -e

echo "Setting up Runic Vitals… 🧱"
echo "Installing dependencies… 📦"
sudo apt update
sudo apt install -y conky lm-sensors curl unzip fonts-noto-color-emoji
sudo sensors-detect --auto

echo "Creating config directory… 📁"
mkdir -p ~/.config/conky ~/.local/share/fonts ~/.config/autostart
cd ~/.config/conky || exit

echo "Writing vitals.conf… 📝"
cat <<'CFG' > vitals.conf
conky.config = {
    alignment = 'bottom_right',
    background = true,
    update_interval = 1,
    double_buffer = true,
    use_xft = true,
    font = 'JetBrainsMono Nerd Font:size=9',
    xftalpha = 1,
    override_utf8_locale = true,
    own_window = true,
    own_window_type = 'normal',
    own_window_argb_visual = true,
    own_window_argb_value = 120,
    own_window_transparent = false,
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
    minimum_width = 270,
    maximum_width = 270,
    gap_x = 20,
    gap_y = 40,
    draw_shades = false,
    draw_outline = false,
    draw_borders = false,
    draw_graph_borders = false,
    default_color = 'white',
    color1 = '#aaaaaa',
    use_spacer = 'none',
    border_inner_margin = 10,
    border_outer_margin = 0,
    lua_draw_hook_pre = 'draw_bg',
    lua_load = '~/.config/conky/rounded.lua',
};

conky.text = [[
${color1} Temp:     ${color}${exec sensors | grep -m 1 'Package id 0:' | awk '{print $4}'}
${color1} RAM:      ${color}${memperc}% (${mem / 1024 / 1024} GB of ${memmax / 1024 / 1024} GB)
${color1} CPU:      ${color}${cpu}%
${color1} Disk:     ${color}${fs_used /} / ${fs_size /}
${color1} Uptime:   ${color}${uptime} ${execpi 60 bash -c 'U=$(cut -d. -f1 /proc/uptime); D=$((U / 86400)); [ $D -ge 1 ] && echo "/ Day $((D+1))"'}
${color1} Network:  ${color}Runic Interactive
${color1} IP:       ${color}${addr $gw_iface}
${color1} Down:     ${color}${downspeedf $gw_iface}
${color1} Up:       ${color}${upspeedf $gw_iface}
]];
CFG

echo "Writing rounded.lua… 🧠"
cat <<'LUA' > rounded.lua
require 'cairo'
function conky_draw_bg()
    if conky_window == nil then return end
    local w,h = conky_window.width, conky_window.height
    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, w, h)
    local cr = cairo_create(cs)
    local r,g,b,a = 0,0,0,0.5
    local radius = 20
    cairo_set_source_rgba(cr,r,g,b,a)
    cairo_move_to(cr,radius,0)
    cairo_line_to(cr,w-radius,0)
    cairo_arc(cr,w-radius,radius,radius,-math.pi/2,0)
    cairo_line_to(cr,w,h-radius)
    cairo_arc(cr,w-radius,h-radius,radius,0,math.pi/2)
    cairo_line_to(cr,radius,h)
    cairo_arc(cr,radius,h-radius,radius,math.pi/2,math.pi)
    cairo_line_to(cr,0,radius)
    cairo_arc(cr,radius,radius,radius,math.pi,3*math.pi/2)
    cairo_close_path(cr)
    cairo_fill(cr)
end
LUA

echo "Installing JetBrainsMono Nerd Font… 🔤"
cd ~/.local/share/fonts
wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip -O font.zip
unzip -o font.zip >/dev/null
rm font.zip
fc-cache -fv

echo "Creating autostart entry… ⚙️"
cat <<'DESK' > ~/.config/autostart/runic-vitals.desktop
[Desktop Entry]
Type=Application
Exec=conky -c ~/.config/conky/vitals.conf
X-GNOME-Autostart-enabled=true
Name=Runic Vitals
DESK

echo "Launching Runic Vitals… 🔁"
pkill conky || true
sleep 1
conky -c ~/.config/conky/vitals.conf &

echo "✅ Runic Vitals installed and running!"
echo "🔁 Will auto-start at login."
echo "🔤 If icons don’t appear, log out and back in to refresh fonts."
