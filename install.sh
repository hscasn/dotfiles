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


# Copies a file or directory to a destination
copy() {
  if [ ! $# = 2 ]
  then
    echo "Usage for copy function: copy <file> <file>"
    exit 1
  fi
  if [ -d "$2" ]
  then
    cp -r "$1"/* "$2"
  else
    cp -r "$1" "$2"
  fi
  if [ $? = 0 ]
  then
    echo "  OK - Copied $1 to $2"
  else
    exit 1
  fi
}

# Installs the ./home folder
installHome() {
  for file in $(ls home)
  do
    oldFilePath="./home/$file"
    newFilePath="$HOME/.$file"
    copy "$oldFilePath" "$newFilePath"
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

# Installs misc files
installMisc() {
  sudo cp misc/mirrorlist "/etc/pacman.d/mirrorlist"
  if [ $? = 0 ]
  then
    echo "  OK - Mirror list installed"
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
  # AUR
  if prompt "Install AUR?"
  then
    sudo pacman -S pacaur rofi &&\
    pacaur -Syy # Syncing
  fi

  # i3, rofi, and i3blocks
  if prompt "Install i3 and tools?"
  then
    pacaur -S i3-gaps-next-git &&\
    sudo pacman -S dmenu i3lock compton feh &&\
    pacaur -S i3blocks
  fi

  # Essentials
  if prompt "Install Essentials?"
  then
    sudo pacman -S base-devel wget file abs
  fi

  # Arch Keyring
  if prompt "Install Arch Keyring?"
  then
    sudo pacman -S archlinux-keyring
  fi

  # Redshift
  if prompt "Install Redshift?"
  then
    sudo pacman -S redshift
  fi

  # PHP + Apache
  if prompt "Install php and apache?"
  then
    sudo pacman -S apache php php-apache
  fi

  # Telegram
  if prompt "Install Telegram?"
  then
    pacaur -S telegram-desktop-bin
  fi

  # facebook
  if prompt "Install messenger for desktop?"
  then
    pacaur -S messengerfordesktop-git
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

  # Sensors
  if prompt "Install Sensors?"
  then
    sudo pacman -S lm_sensors
  fi

  # Java
  if prompt "Install Java?"
  then
    sudo pacman -S java-runtime-common java-environment-common &&\
    pacaur -S jdk-devel jre-devel
  fi

  # APT-VIM
  if prompt "Install APT-VIM?"
  then
    curl -sL https://raw.githubusercontent.com/egalpin/apt-vim/master/install.sh | sh
  fi

  # node
  if prompt "Install node?"
  then
    sudo pacman -S npm &&\
    sudo npm install -g n &&\
    sudo n latest
  fi

  # Sublime
  if prompt "Install Sublime?"
  then
    pacaur -S sublime-text
  fi

  # insync
  if prompt "Install insync?"
  then
    pacaur -S insync
  fi

  # VLC
  if prompt "Install VLC?"
  then
    pacaur -S vlc-git
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

  # Nautilus
  if prompt "Install Nautilus?"
  then
    sudo pacman -S nautilus
  fi

  # Scrot
  if prompt "Install Scrot?"
  then
    sudo pacman -S scrot
  fi

  # Vokoscreen
  if prompt "Install Vokoscreen?"
  then
    sudo pacman -S vokoscreen
  fi

  # Music
  if prompt "Install Music?"
  then
    pacaur -S spotify
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

  # Haskell
  if prompt "Install Haskell?"
  then
    sudo pacman -S ghc cabal-install happy alex
  fi
}

# Installs packages for vim
installVimPackages() {
  VIMBUNDLE=~/.vim/bundle
  if [ ! -e $VIMBUNDLE ]
  then
    sudo mkdir $VIMBUNDLE
  fi
  PATH=$PATH:$HOME/.vimpkg/bin

  # NERD TREE
  $HOME/.vimpkg/bin/apt-vim install -y https://github.com/scrooloose/nerdtree.git
  sudo git clone https://github.com/jistr/vim-nerdtree-tabs.git $VIMBUNDLE/vim-nerdtree-tabs

  # Nerd Tree
  $HOME/.vimpkg/bin/apt-vim install -y https://github.com/scrooloose/nerdtree.git

  # Colour schemes
  sudo git submodule add https://github.com/flazz/vim-colorschemes.git $VIMBUNDLE/vim-colorschemes

  # Set colors
  sudo git clone https://github.com/felixhummel/setcolors.vim.git setcolors $VIMBUNDLE/setcolors.vim

  # Indentation
  sudo git clone https://github.com/Yggdroot/indentLine $VIMBUNDLE/indentLine

  # Syntax
  sudo git clone https://github.com/sheerun/vim-polyglot $VIMBUNDLE/vim-polyglot

  # Move lines
  $HOME/.vimpkg/bin/apt-vim install https://github.com/matze/vim-move.git
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

# Installing misc
if prompt "Install misc files?"
then
  echo "- Installing misc files"
  installMisc
fi
