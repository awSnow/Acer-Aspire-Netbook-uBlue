#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Desktop Environment Configuration for Acer Minimal OS
# Configures LightDM, Openbox defaults, and system tweaks for low-RAM
# =============================================================================

echo "=== Configuring desktop environment ==="

# -----------------------------------------------------------------------------
# LightDM Configuration
# -----------------------------------------------------------------------------
mkdir -p /etc/lightdm/lightdm.conf.d

cat > /etc/lightdm/lightdm.conf.d/50-acer-minimal.conf << 'EOF'
[Seat:*]
# Default session to Openbox
user-session=openbox

# Auto-login for convenience (comment out for security)
autologin-user=dj
autologin-user-timeout=5

# Greeter settings
greeter-hide-users=false
EOF

echo "LightDM configured"

# -----------------------------------------------------------------------------
# System-wide Openbox Configuration
# -----------------------------------------------------------------------------
mkdir -p /etc/xdg/openbox

# Openbox autostart - runs when Openbox starts
cat > /etc/xdg/openbox/autostart << 'EOF'
#!/bin/bash
# Openbox autostart script

# Start panel
tint2 &

# Set background (fallback to solid color if no image)
if [ -f /usr/share/backgrounds/default.png ]; then
    feh --bg-scale /usr/share/backgrounds/default.png
else
    xsetroot -solid "#2d2d2d"
fi

# Network manager applet (system tray)
nm-applet &

# Set keyboard repeat rate
xset r rate 300 30
EOF
chmod +x /etc/xdg/openbox/autostart

# Openbox menu (right-click desktop)
cat > /etc/xdg/openbox/menu.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu xmlns="http://openbox.org/3.4/menu">
  <menu id="root-menu" label="Acer Minimal OS">
    <item label="Terminal">
      <action name="Execute"><execute>xterm</execute></action>
    </item>
    <item label="File Manager">
      <action name="Execute"><execute>pcmanfm</execute></action>
    </item>
    <item label="Text Editor">
      <action name="Execute"><execute>mousepad</execute></action>
    </item>
    <separator/>
    <item label="System Monitor (htop)">
      <action name="Execute"><execute>xterm -e htop</execute></action>
    </item>
    <item label="Network Settings">
      <action name="Execute"><execute>nm-connection-editor</execute></action>
    </item>
    <separator/>
    <menu id="system-menu" label="System">
      <item label="Reconfigure Openbox">
        <action name="Reconfigure"/>
      </item>
      <item label="Restart Openbox">
        <action name="Restart"/>
      </item>
      <separator/>
      <item label="Reboot">
        <action name="Execute"><execute>systemctl reboot</execute></action>
      </item>
      <item label="Shutdown">
        <action name="Execute"><execute>systemctl poweroff</execute></action>
      </item>
    </menu>
    <separator/>
    <item label="Log Out">
      <action name="Exit"/>
    </item>
  </menu>
</openbox_menu>
EOF

# Openbox rc.xml - window manager settings
cat > /etc/xdg/openbox/rc.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<openbox_config xmlns="http://openbox.org/3.4/rc">
  <resistance><strength>10</strength><screen_edge_strength>20</screen_edge_strength></resistance>
  <focus><focusNew>yes</focusNew><followMouse>no</followMouse></focus>
  <placement><policy>Smart</policy><center>yes</center></placement>
  <theme><name>Clearlooks</name></theme>
  <desktops><number>2</number><names><name>Main</name><name>Work</name></names></desktops>
  <keyboard>
    <keybind key="A-Tab"><action name="NextWindow"/></keybind>
    <keybind key="A-F4"><action name="Close"/></keybind>
    <keybind key="A-F2"><action name="Execute"><execute>xterm</execute></action></keybind>
  </keyboard>
  <mouse>
    <context name="Root"><mousebind button="Right" action="Press"><action name="ShowMenu"><menu>root-menu</menu></action></mousebind></context>
  </mouse>
</openbox_config>
EOF

echo "Openbox configured"

# -----------------------------------------------------------------------------
# Performance Tweaks for Low-RAM System (2GB)
# -----------------------------------------------------------------------------
cat > /etc/sysctl.d/99-low-ram-tweaks.conf << 'EOF'
# Low-RAM optimizations for Acer C-50 (2GB)

# Reduce swappiness - prefer keeping apps in RAM
vm.swappiness = 10

# Lower dirty ratio to avoid large write bursts on slow HDD
vm.dirty_ratio = 10
vm.dirty_background_ratio = 5

# Reduce vfs cache pressure
vm.vfs_cache_pressure = 50
EOF

echo "Performance tweaks applied"

# -----------------------------------------------------------------------------
# Set hostname
# -----------------------------------------------------------------------------
echo "acer-ublue" > /etc/hostname

echo "=== Desktop configuration complete ==="
