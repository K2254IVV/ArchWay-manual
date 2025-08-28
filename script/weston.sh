wget -P /usr/share/backgrounds/ https://raw.githubusercontent.com/K2254IVV/ArchWay-manual/refs/heads/main/files/archway.jpg
cat << EOF > ~/.config/weston.ini
[core]
modules=desktop-shell.so,xwayland.so

[shell]
background-image=/usr/share/backgrounds/archway.jpg
panel-color=0x90ff0000
panel-position=bottom
locking=true
animation=zoom
#binding-modifier=ctrl
num-workspaces=6

[launcher]
icon=/usr/share/icons/gnome/24x24/apps/utilities-terminal.png
path=/usr/bin/weston-terminal

EOF
