#!/bin/bash -e

#
# setup-user.sh
#
# This script will configure i3 and user-specific settings.
#

echo "Installing vimrc..."
if [[ -f ~/.vimrc ]]; then
    echo >&2 "~/.vimrc already exists! Skipping vimrc installation."
else
    cp /etc/shareef12-desktop/vimrc ~/.vimrc
fi

echo "Configuring bashrc..."
if cat ~/.bashrc | grep 'Configured by shareef12-desktop' > /dev/null; then
    echo >&2 "~/.bashrc already configured! Skipping bashrc configuration."
else
    cat /etc/shareef12-desktop/bashrc >> ~/.bashrc
    source ~/.bashrc

    # Update the lxterminal background color
    sed -i -e 's/bgcolor=.*/bgcolor=rgb(34,34,34)/' ~/.config/lxterminal/lxterminal.conf
fi

echo "Configuring git..."
git config --global user.name shareef12
git config --global user.email shareef12@twelvetacos.com

echo "Configuring SSH..."
if [ ! -f ~/.ssh/id_rsa ] && [ ! -f ~/.ssh/id_ecdsa ]; then
    ssh-keygen -t ecdsa -C "user@$(hostname)" -N '' -f ~/.ssh/id_ecdsa
    cp ~/.ssh/id_ecdsa ~/.ssh/authorized_keys
    chmod 700 ~/.ssh
fi

echo "Updating filesystem permissions..."
chmod 750 ~/

echo "Configuring i3..."
if [[ -f ~/.config/i3/config ]]; then
    echo >&2 "~/.config/i3/config already exists! Skipping i3 configuration."
else
    i3-config-wizard

    # Rebind window keys to match vim keybindings
    sed -i \
        -e 's/\$mod+j /$mod+h /gI'                      \
        -e 's/\$mod+k /$mod+j /gI'                      \
        -e 's/\$mod+l /$mod+k /gI'                      \
        -e 's/\$mod+semicolon /$mod+l /gI'              \
        -e 's/\$mod+Shift+j /$mod+Shift+h /gI'          \
        -e 's/\$mod+Shift+k /$mod+Shift+j /gI'          \
        -e 's/\$mod+Shift+l /$mod+Shift+k /gI'          \
        -e 's/\$mod+Shift+semicolon /$mod+Shift+l /gI'  \
        ~/.config/i3/config

    # Since we hijacked the $mod+h key-combo, rebind the actions that used it previously
    sed -i \
        -e 's/\$mod+h split h/$mod+semicolon split h/gI' \
        ~/.config/i3/config

    # Rebind the resizing keys
    sed -i \
        -e 's/j resize/h resize/gI'         \
        -e 's/k resize/j resize/gI'         \
        -e 's/l resize/k resize/gI'         \
        -e 's/semicolon resize/l resize/gI' \
        ~/.config/i3/config

    # Update the status bar
    sed -i \
        -e '/status_command i3status/a \        tray_output primary\n        position top\n        font pango:DejaVu Sans Mono 16' \
        ~/.config/i3/config

    # Add a vmware-tools startup command
    sed -i '/set \$mod/i #exec \/usr\/bin\/vmware-user-suid-wrapper' ~/.config/i3/config

    # Add autotstartup commands
    echo "" >> ~/.config/i3/config
    echo '#exec --no-startup-id xscreensaver -no-splash &' >> ~/.config/i3/config
    echo 'bindsym Control+Mod1+l exec xscreensaver-command -lock' >> ~/.config/i3/config
    echo 'bindsym $mod+Shift+m move workspace to output right' >> ~/.config/i3/config
    echo 'bindsym Control+Print exec gnome-screenshot -i' >> ~/.config/i3/config

    i3-msg reload
fi

echo "Configuring i3status..."
if [[ -f ~/.config/i3status/config ]]; then
    echo >&2 "~/.config/i3status/config already exists! Skipping i3status configuration."
else
    mkdir -p ~/.config/i3status
    cp /etc/i3status.conf ~/.config/i3status/config

    # Remove unused options
    sed -i \
        -e 's/\(order += "ipv6"\)/#\1/gI'             \
        -e 's/\(order += "wireless _first_"\)/#\1/gI' \
        -e 's/\(order += "battery .*\)"/#\1/gI'       \
        ~/.config/i3status/config

    # Update the disk format
    sed -i \
        -e 's/format = "%avail"/format = "\/ %avail"/gI' \
        ~/.config/i3status/config

    i3-msg restart
fi
