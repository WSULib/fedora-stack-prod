# fedora-stack-prod
fedora-stack-prod

#### Installing via vagrant
  ```
  git clone https://github.com/WSULib/fedora-stack-prod.git
  cd fedora-stack-prod
  mount remote downloads folder to fedora-stack-prod/downloads folder
  vagrant up
  ```

#### Installing via bash script
  ```
  sudo apt-get update
  (if needed) sudo apt-get -y install git
  git clone https://github.com/WSULib/fedora-stack-prod.git
  cd fedora-stack-prod
  Running as root, run ./bash_install.sh
  Prompted to edit /etc/hosts file: enter VM_NAME from envars on same line as IP
  Supply the appropriate password when prompted
  When installing Java, hit enter when prompted
  ```
