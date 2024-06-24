#!/usr/bin/env bash

if ls /home/ansibleuser/bootstrap_complete; then
  echo "Bootstrap is complete, nothing to do."
  exit
else
  : #noop
fi

# Make a user that's only for ansible use and can sudo
useradd -m -s /bin/bash ansibleuser
echo 'ansibleuser  ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/ansibleuser

# Pubkey we use to make sure only authorized playbooks will run
echo 'kayla@lastcallmedia.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG90v2G3S0wE/keqeW6DIsFAiTEQOTdT/vtdxJ8/nJ7J' \
> /home/ansibleuser/bootstrap_signature

# Place our little grab/verify/run playbook script
cat << EOF > /home/ansibleuser/run_ansible.sh
#!/usr/bin/env bash

PATH=/home/ansibleuser/.local/bin:/home/ansibleuser/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin

if python3 -m pip -V; then
  : # noop
else
  python -m ensurepip --upgrade
fi

if ansible --version; then
  : # noop
else
  python3 -m pip install --user ansible
fi

cd

# Grab base playbook+sig from the internets
curl https://raw.githubusercontent.com/LastCallMedia/proto-ansible/main/bootstrap.yml > bootstrap.yml
curl https://raw.githubusercontent.com/LastCallMedia/proto-ansible/main/bootstrap.yml.sig > bootstrap.yml.sig

# Verify and run base playbook
if ssh-keygen -Y verify -f ~/bootstrap_signature -I kayla@lastcallmedia.com \
-n file -s bootstrap.yml.sig < bootstrap.yml; then
  ansible-playbook -i localhost bootstrap.yml
else
  echo "Something went horribly wrong. The playbook's signature is invalid"
  exit
fi

EOF

chmod +x /home/ansibleuser/run_ansible.sh

# Drop root and run ansible for the first time
su - ansibleuser -c "/home/ansibleuser/run_ansible.sh"

