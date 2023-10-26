#!/bin/bash
if exists curl; then
	echo ''
else
  sudo apt install curl -y < "/dev/null"
fi
bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi

function Deps {
	echo -e '\n\e[42mPreparing to install\e[0m\n' && sleep 1
	cd $HOME
	sudo apt update && apt upgrade -y
    sudo apt install -y curl git jq lz4 build-essential unzip < "/dev/null"
	curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
	apt install nodejs -y
  sleep 1
}

function Software {
  echo -e '\n\e[42mInstall node\e[0m\n' && sleep 1
	npm install -g @holographxyz/cli
}
function Config {
    echo -e '\n\e[42mCreate config\e[0m\n' && sleep 1
    cd $HOME
	holograph config
	}
function Faucet {
    echo -e '\n\e[42mFaucet\e[0m\n' && sleep 1
    cd $HOME
	holograph faucet
	
  }

function Service {
    if [ ! $HPass ]; then
    read -p "Enter Password: " HPass
    fi
    echo 'source $HOME/.bashrc' >> $HOME/.bash_profile
    sleep 1
    

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/holograph.service
[Unit]
Description=Holograph node
After=network.target
[Service]
Type=simple
User=root
WorkingDirectory=/root/
ExecStart=holograph operator \
        --mode=auto \
        --unsafePassword=$HPass \
	    --sync 
Restart=always
RestartSec=60
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl restart systemd-journald &>/dev/null
sudo systemctl daemon-reload &>/dev/null
sudo systemctl enable holograph &>/dev/null
sudo systemctl restart holograph &>/dev/null

}



PS3='Please enter your choice (input your option number and press enter): '
options=("Install" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install")
 		echo -e '\n\e[42mYou choose install...\e[0m\n' && sleep 1
			Deps
			Software
            Config
            Faucet
			Service 
			echo -e '\n\e[33mNode install!\e[0m\n' && sleep 1
			restore
			echo -e "Check logs: \e[35m journalctl -n 100 -f -u gear\e[0m\n"
			break
            ;;
			
        "Quit")
            break
            ;;
        *) echo -e "\e[91minvalid option $REPLY\e[0m";;
    esac
done