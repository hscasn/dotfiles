#!/bin/bash

echo "------------------------------"
echo "To disable Ctrl+Alt+Backspace from killing X11:"
echo "$ cd /etc/X11/xorg.conf.d"
echo "Edit 99-killX.conf, ensure that DontZap === yes"
echo "Section \"ServerFlags\""
echo "    Option \"DontZap\" \"yes\""
echo "EndSection"
echo "------------------------------"

# Used to delete a file
delete() {
  if [ ! $# = 1 ]
  then
    echo "Usage for delete function: delete <file>"
    exit 1
  fi
  if [ -e $1 ]
  then
    rm -rf "$1"
    if [ $? = 0 ]
    then
      echo "  OK - Deleted file $1"
    else
      exit 1
    fi
  else
    echo "  OK - File $1 does not exist - not deleting"
  fi
}


# Creates a soft link for a file or directory
soft_link() {
  if [ ! $# = 2 ]
  then
    echo "Usage for soft_link function: soft_link <file> <file>"
    exit 1
  fi
  rm -rf "$2" 2>/dev/null
  ln -s "$(pwd)/$1" "$2"
  if [ $? = 0 ]
  then
    echo "  OK - Soft linked $1 to $2"
  else
    exit 1
  fi
}

# Installs the ./home folder
installHome() {
  for file in home/*
  do
    oldFilePath="./home/$file"
    newFilePath="$HOME/.$file"
    if [ "${file}" = "config" ]; then
        mkdir $HOME/.$file
        for subfile in home/${file}/*; do
            oldSubFilePath="$oldFilePath/$subfile"
            newSubFilePath="$newFilePath/$subfile"
            soft_link "$oldSubFilePath" "$newSubFilePath"
        done
    else
        soft_link "$oldFilePath" "$newFilePath"
    fi
  done
}

# Installs the fonts
installFonts() {
  sudo cp -r fonts/* "/usr/share/fonts"
  if [ $? = 0 ]
  then
    echo "  OK - Fonts installed"
  else
    exit 1
  fi
}

# Prompts the user for y or n - returns 0 for yes, 1 for n
prompt() {
  if [ ! $# = 1 ]
  then
    echo "Usage for prompt function: prompt <message> (message should not have '(Y/n)')"
    exit 1
  fi
  read -rn1 -p "$1 (Y/n)"
  echo ""
  if [[ $REPLY =~ [yY] ]]
  then
    return 0
  else
    return 1
  fi
}

installApps() {
  # yay
  sudo pacman -Syyu
  sudo pacman -S yay base-devel

  # i3, rofi, and i3blocks
  if prompt "Install i3 and tools?"
  then
    yay -S i3-gaps-next-git termite rofi &&\
    sudo pacman -S dmenu i3lock picom feh &&\
    yay -S i3blocks i3blocks-contrib sysstat
    yay -S tumbler tumbler-extra-thumbnailers ffmpegthumbnailer
  fi

  # Essentials
  if prompt "Install Essentials?"
  then
    sudo pacman -S wget file abs
  fi

  # Python
  if prompt "Install Python?"
  then
    yay -S python python-pip
  fi

  # Unipicker
  if prompt "Install Unipicker?"
  then
    yay -S unipicker
  fi

  # XClip
  if prompt "Install XClip?"
  then
    yay -S xclip
  fi

  # Redshift
  if prompt "Install Redshift?"
  then
    sudo pacman -S redshift
  fi

  # Telegram
  if prompt "Install Telegram?"
  then
    yay -S telegram-desktop
  fi

  # ACPI
  if prompt "Install ACPI (for laptop battery)?"
  then
    sudo pacman -S acpi
  fi

  # Transmission
  if prompt "Install Transmission?"
  then
    sudo pacman -S transmission-gtk
  fi

  # Thunderbird
  if prompt "Install Thunderbird?"
  then
    sudo pacman -S thunderbird
  fi

  # Sensors
  if prompt "Install Sensors?"
  then
    sudo pacman -S lm_sensors
  fi

  # Node
  if prompt "Install node?"
  then
    sudo pacman -S npm &&\
    sudo npm install -g n &&\
    sudo n latest
  fi

  # Sublime
  if prompt "Install Sublime?"
  then
    yay -S sublime-text-dev
  fi

  # VSCode
  if prompt "Install VSCode?"
  then
    yay -S visual-studio-code-bin
  fi

  # insync
  if prompt "Install insync?"
  then
    yay -S insync
  fi

  # VLC
  if prompt "Install VLC?"
  then
    yay -S vlc-git
  fi

  # PDF viewer
  if prompt "Install PDF viewer?"
  then
    sudo pacman -S zathura
  fi

  # VIM
  if prompt "Install VIM?"
  then
    sudo pacman -S vim
  fi

  # Scrot
  if prompt "Install Scrot?"
  then
    sudo pacman -S scrot
  fi

  # Music
  if prompt "Install Spotify?"
  then
    yay -S spotify
  fi

  # Docker
  if prompt "Install Docker?"
  then
    sudo pacman -S docker
  fi

  # Network manager
  if prompt "Install Network manager?"
  then
    sudo pacman -S networkmanager network-manager-applet
  fi

  # Cowsay and fortune
  if prompt "Install Cowsay and Fortune?"
  then
    yay -S fortune-mod cowsay
  fi
}

# Installs packages for vim
installVimPackages() {
  # Powerline
  yay -S powerline-fonts

  # Vundle
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  vim +PluginInstall +qall
}

# Installing apps
if prompt "Install apps?"
then
  echo "- Installing apps"
  installApps
fi

# Installing dot files
if prompt "Install home dot files?"
then
  echo "- Installing home dot files"
  installHome
fi

# Installing VIM packages
if prompt "Install VIM packages?"
then
  echo "- installing vim packages"
  installVimPackages
fi

# Installing fonts
if prompt "Install fonts?"
then
  echo "- Installing fonts"
  installFonts
fi

