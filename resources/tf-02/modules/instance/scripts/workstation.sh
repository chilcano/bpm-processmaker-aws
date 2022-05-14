#!/usr/bin/env bash

sudo apt -yqq update -y
sudo apt -yqq install -y language-pack-en

echo "--> Installing Tools" 
sudo apt -yqq install -y default-jdk maven libssl-dev openssl git awscli curl jq unzip tree
sudo snap install go --classic 
wget https://github.com/smallstep/cli/releases/download/v0.15.3/step-cli_0.15.3_amd64.deb
sudo dpkg -i step-cli_0.15.3_amd64.deb
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https

echo "--> Setting hostname"
echo "${hostname}" | sudo tee /etc/hostname
sudo hostname -F /etc/hostname

echo "--> Adding hostname to /etc/hosts"
sudo tee -a /etc/hosts > /dev/null <<EOF
# For local resolution
$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4) ${hostname}
EOF

echo "--> Create new user, edit ssh settings" 
sudo useradd ${username} \
   --shell /bin/bash \
   --create-home 
echo '${username}:${ssh_pass}' | sudo chpasswd
sudo sed -ie 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo service sshd reload

echo "--> Adding ${username} user to sudoers"
sudo tee /etc/sudoers.d/${username} > /dev/null <<"EOF"
${username} ALL=(ALL:ALL) ALL
EOF
sudo chmod 0440 /etc/sudoers.d/${username}
sudo usermod -a -G sudo ${username}

echo "--> Installing Docker"
curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt -yqq update
sudo apt -yqq install -y docker-ce docker-ce-cli containerd.io
sudo usermod -a -G docker ${username}
sudo systemctl enable docker

echo "--> Installing Wetty"
docker run --rm -p 80:3000 --detach --name wetty wettyoss/wetty --ssh-host=172.17.0.1 --ssh-user ${username}

echo "--> Cloning the repo"
sudo mkdir /home/${username}/workdir
cd /home/${username}/workdir
#git clone https://github.com/chilcano/mtls-apps-examples 
sudo git clone ${gitrepo}
## important - make sure the owner is playground
sudo chown -R ${username} /home/${username}/workdir

echo "--> Running CodeServer container"
sudo docker run -dit -p 8000:8080 \
  -v "$PWD:/home/coder/project" \
  -u "$(id -u):$(id -g)" \
  --detach \
  --name code-server \
  codercom/code-server:latest --auth none

