#remember about public keys!
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - ;
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 94558F59;
add-apt-repository "deb http://dl.google.com/linux/chrome/deb/ stable main";
add-apt-repository "deb http://repository-origin.spotify.com stable non-free";
add-apt-repository "ppa:numix/ppa";
add-apt-repository "ppa:tualatrix/ppa";
add-apt-repository ppa:jerzy-kozera/zeal-ppa;
apt-get update
apt-get install git;
apt-get install ubuntu-tweak;
apt-get install spotify-client;
apt-get install nodejs;
apt-get install ngrok-server;
apt-get install google-chrome-stable;
apt-get install numix-gtk-theme;
apt-get install numix-icons;
apt-get install tmux;
apt-get install php5-cli;
apt-get install imagemagick;
apt-get install python3;
apt-get install python-pip;
apt-get install zeal;
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim;
git clone https://github.com/zajac1/dotfiles/tree/master/ubuntu/.bashrc;
git clone https://github.com/zajac1/dotfiles/tree/master/ubuntu/.vimrc;



###TOOLS
#CSSDig
#Zeal
