#!/bin/bash
sudo apt install curl -y < "/dev/null"
bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi

function installNodeJS {
	echo -e '\n\e[42mPreparing to install\e[0m\n' && sleep 1
	cd $HOME
	sudo apt update && apt upgrade -y
    sudo apt install -y curl git jq lz4 build-essential unzip < "/dev/null"
	apt install nodejs -y
  sleep 1
}

function installSoftware {
  echo -e '\n\e[42mInstall node\e[0m\n' && sleep 1
	npm install -g @holographxyz/cli
}
function installConfig {
    echo -e '\n\e[42mCreate config\e[0m\n' && sleep 1
    cd $HOME
	holograph config
	}
function installFaucet {
    echo -e '\n\e[42mFaucet\e[0m\n' && sleep 1
    cd $HOME
	holograph faucet
	
  }
function installBond {
    holograph operator:bond
}

function installService {
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
options=("Node" "Install" "Faucet" "Create config" "Logs" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "NodeJS")
			installNodeJS
			break
            ;;
        "Install")
			installSoftware
            installConfig 
			break
            ;;
		"Create config")
			installService 
			break
            ;;
        "Faucet")
            installFaucet
		    break
            ;;
        "Logs")
            journalctl -n 100 -f -u holograph
			break
            ;;    	
        "Quit")
            break
            ;;
        *) echo -e "\e[91minvalid option $REPLY\e[0m";;
    esac
done