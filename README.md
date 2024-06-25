There are two things going on here. Bootstrap, and Plain Old Ansible

All this should work on CentOS 9. At present, the official AMIs for us-east-1 are:

amd64 `ami-02bc4964067260ad4`
arm64 `ami-0c5474242fc77c7d6`

#### Bootstrap
`bootstrap.sh` is intended to be placed in the userdata of an instance. It can also be run manually as `root`. It does some basic setup and then hands things over to Ansible. This script also expects the playbook it downloads to be signed (mostly for fun / an excuse to mess with ssh signing)

You can do that with `ssh-keygen -Y sign -f ~/.ssh/<privkey> -n file bootstrap.yml`

`bootstrap.yml` should be purely for base setup of an instance. Here, I went and crammed the rest of the existing userdata script in there for completeness. That's also split out into:

#### Plain Old Ansible
Differs a little since we're still not using ssh and instead all tasks are local tasks

To run it, be `root` or have `sudo` and then: `ansible-playbook -i localhost, site.yml`

Also contains a demo of an external role. In this case to install nginx. This role is included here as a git submodule. Use `git clone --recursive` to make sure it gets pulled too