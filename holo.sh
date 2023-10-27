#!/bin/bash
while true
do

# Menu

PS3='Select an action: '
options=("NodeJS" "Install" "Faucet" "Run Operator" "Operator service" "Logs" "Exit")
select opt in "${options[@]}"
               do
                   case $opt in                          

"NodeJS")
cd $HOME
    sudo apt-get install -y ca-certificates curl gnupg
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
	NODE_MAJOR=20
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
    sudo apt-get update
    sudo apt-get install nodejs -y
break
;;
"Install")
cd $HOME
npm install -g @holographxyz/cli
echo Create config
sleep 2
holograph config
break
;;
"Run Operator")
#echo Faucet - Testnet HLG
#sleep 2
#holograph faucet
#pod
echo Bonding Into a Pod 
holograph operator:bond
#pass
break
;;
"Operator service")
read -p "Enter Password : " HPass
#service
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
	    --sync \
        --networks fuji mumbai
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
break
;;
"Faucet")
echo Faucet - Testnet HLG
sleep 2
holograph faucet
break
;;
"Bridging")
cd $HOME
holograph create:contract
break
;;

"Logs")
journalctl -n 100 -f -u holograph
break
;;

"Exit")
exit
;;
*) echo "invalid option $REPLY";;
esac
done
done