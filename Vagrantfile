# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  #ansible-client001
  config.vm.define "ansible-client001" do |cfg|
      cfg.vm.box = "ubuntu/bionic64"
      cfg.vm.provider "virtualbox" do |vb|
          vb.name = "ansible-client001"
      end
      cfg.vm.host_name = "ansible-client001"
      cfg.vm.network "public_network", ip: "192.168.1.1"
      cfg.vm.network "public_network", bridge: "Realtek PCIe GbE Family Controller"
      cfg.vm.network "forwarded_port", guest: 22, host: 60001, auto_correct: true, id: "ssh"
      cfg.vm.network "forwarded_port", guest: 80, host: 60081, auto_correct: true
      cfg.vm.synced_folder "./shared_data", "/shared_data", disabled: true
    #   cfg.vm.provision "shell", inline: "sudo apt update"
      cfg.vm.provision "shell", path: "enable_ssh_password_auth.sh"
    #   cfg.vm.provision "shell", inline: "sudo apt install python3 -y"
  end

  #ansible-client002
  config.vm.define "ansible-client002" do |cfg|
      cfg.vm.box = "ubuntu/bionic64"
      cfg.vm.provider "virtualbox" do |vb|
          vb.name = "ansible-client002"
      end
      cfg.vm.host_name = "ansible-client002"
      cfg.vm.network "public_network", ip: "192.168.1.2"
      cfg.vm.network "public_network", bridge: "Realtek PCIe GbE Family Controller"
      cfg.vm.network "forwarded_port", guest: 22, host: 60002, auto_correct: true, id: "ssh"
      cfg.vm.network "forwarded_port", guest: 80, host: 60082, auto_correct: true
      cfg.vm.synced_folder "./shared_data", "/shared_data", disabled: true
    #   cfg.vm.provision "shell", inline: "sudo apt update"
      cfg.vm.provision "shell", path: "enable_ssh_password_auth.sh"
    #   cfg.vm.provision "shell", inline: "sudo apt install python3 -y"
  end

  #ansible-client003
  config.vm.define "ansible-client003" do |cfg|
      cfg.vm.box = "ubuntu/bionic64"
      cfg.vm.provider "virtualbox" do |vb|
          vb.name = "ansible-client003"
      end
      cfg.vm.host_name = "ansible-client003"
      cfg.vm.network "public_network", ip: "192.168.1.3"
      cfg.vm.network "public_network", bridge: "Realtek PCIe GbE Family Controller"
      cfg.vm.network "forwarded_port", guest: 22, host: 60003, auto_correct: true, id: "ssh"
      cfg.vm.network "forwarded_port", guest: 80, host: 60083, auto_correct: true
      cfg.vm.synced_folder "./shared_data", "/shared_data", disabled: true
    #   cfg.vm.provision "shell", inline: "sudo apt update"
      cfg.vm.provision "shell", path: "enable_ssh_password_auth.sh"
    #   cfg.vm.provision "shell", inline: "sudo apt install python3 -y"
  end

  #ansible-server
  config.vm.define "ansible-server" do |cfg|
      cfg.vm.box = "ubuntu/bionic64"
      cfg.vm.provider "virtualbox" do |vb|
          vb.name="ansible-server"
      end
      cfg.vm.host_name = "ansible-server"
      cfg.vm.network "public_network", ip: "192.168.1.10"
      cfg.vm.network "forwarded_port", guest: 22, host: 60010, auto_correct: true, id: "ssh"
      cfg.vm.synced_folder "./shared_data/", "/shared_data", disabled: false
    #   cfg.vm.provision "shell", inline: "sudo apt update"
    #   cfg.vm.provision "shell", inline: "sudo apt install ansible -y"
    #   cfg.vm.provision "shell", inline: "sudo apt install tree -y"
    #   cfg.vm.provision "shell", inline: "sudo apt install sshpass -y"
    #   cfg.vm.provision "shell", inline: "sudo apt install openssh-server -y"
      cfg.vm.provision "shell", path: "enable_ssh_password_auth.sh"
    #   cfg.vm.provision "file", source: "setup-ansible-env.yml", destination: "setup-ansible-env.yml"
    #   cfg.vm.provision "shell", inline: "ansible-playbook setup-ansible-env.yml"
    #   cfg.vm.provision "file", source: "auto_ssh_connect.yml", destination: "auto_ssh_connect.yml"
    #   cfg.vm.provision "shell", inline: "ansible-playbook auto_ssh_connect.yml", privileged: false
  end
end