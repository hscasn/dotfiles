pip3 install powerline-status

echo '
# Powerline
powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. /usr/local/lib/python3.7/site-packages/powerline/bindings/bash/powerline.sh
' >> ~/.bashrc.work

echo 'If you are using iTerm2, setting Preferences > Text > Non-ASCII Font to "12pt Meslo LG S Regular for Powerline"'
