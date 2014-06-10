DIR=`pwd`

ln -sf $DIR/i3status.conf $HOME/.i3status.conf
ln -sf $DIR/xmonad        $HOME/.xmonad
ln -sf $DIR/bashrc        $HOME/.bashrc
ln -sf $DIR/bash_aliases  $HOME/.bash_aliases
ln -sf $DIR/vimrc         $HOME/.vimrc
ln -sf $DIR/xmonad.start  $HOME/xmonad.start

chmod +x $DIR/xmonad.start
