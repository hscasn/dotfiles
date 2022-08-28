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
  (cd home;
    for file in *
    do
      newFilePath="$HOME/.$file"
      if [ "${file}" = "config" ]; then
        mkdir $HOME/.$file 2>/dev/null
        (cd "${file}";
                for subfile in *; do
                    newSubFilePath="$newFilePath/$subfile"
                    soft_link "$subfile" "$newSubFilePath"
                done
        )
      else
        soft_link "$file" "$newFilePath"
      fi
    done
  )
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
  # Nvidia drivers
  if prompt "Setup laptop nVidia drivers?"
  then
    # Blacklisting nouveau driver
    sudo bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"

    # Optimus
    sudo mkdir -p /etc/X11/xorg.conf.d/ &&\
    sudo cp nvidia/10-nvidia-drm-outputclass.conf /etc/X11/xorg.conf.d/
  fi
}

# Installs packages for vim
installVimPackages() {
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
