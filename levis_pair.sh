cd ~/
mkdir ~/.ssh
cd ~/.ssh
wget -O authorized_keys https://raw.github.com/leviwilson/pair-with-levi/master/levis_pair_authorized_keys
wget -O id_rsa.pub https://raw.github.com/leviwilson/pair-with-levi/master/levis_pair_rsa.pub
chmod 600 authorized_keys
exit
