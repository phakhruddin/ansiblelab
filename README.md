
* * *

Ansible Lab - Local Setup on Mac (M1 Chip)
==========================================

Welcome to **Ansible Lab**! This repository contains instructions and resources to set up a local environment for learning and practicing Ansible. This guide will help you set up your MacBook (M1 chip) as the Ansible control node, and configure an **Ubuntu VM** and **Docker containers** as the target nodes.

Prerequisites
-------------

Before starting, ensure you have the following installed on your Mac:

*   **Homebrew**: The package manager for macOS.
*   **UTM**: To create and manage the Ubuntu VM (VirtualBox alternative for M1 chip).
*   **Vagrant**: For provisioning and managing the Ubuntu VM.
*   **Docker Desktop**: To run Docker containers for target nodes.
*   **Ansible**: The automation tool that will be used in this lab.

* * *

1\. Install Homebrew (Package Manager)
--------------------------------------

First, you need **Homebrew** to manage installations on your Mac. If you don't have Homebrew installed, run the following command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After installation, make sure you update Homebrew:

```bash
brew update
```

* * *

2\. Install UTM (M1 Chip Virtualization Alternative)
----------------------------------------------------

Since VirtualBox isn’t fully compatible with the M1 chip, you will need to use **UTM** to create and manage the Ubuntu VM. UTM is a lightweight virtualization tool compatible with macOS on M1 chips.

### a. Install UTM:

Download and install UTM from the official website:

*   Download UTM for M1 Mac

Follow the instructions to install and configure an Ubuntu VM using UTM.

* * *

3\. Install Vagrant
-------------------

**Vagrant** automates the creation and management of virtual machines (VMs). Install Vagrant using Homebrew:

```bash
brew install vagrant
```

Verify the installation:

```bash
vagrant --version
```

### Set up a Vagrant VM (Ubuntu)

Create a directory for your Vagrant environment:

```bash
mkdir ~/ansiblelab-vm
cd ~/ansiblelab-vm
```

Initialize Vagrant with an Ubuntu image:

```bash
vagrant init ubuntu/bionic64
```

Start the VM:

```bash
vagrant up
```

You now have an Ubuntu VM running, which you can use as your target machine.

* * *

4\. Install Docker Desktop
--------------------------

**Docker Desktop** allows you to create and manage Docker containers locally on your Mac, which will serve as additional target nodes for your Ansible lab.

Download and install Docker Desktop for Mac (M1 chip) from the official Docker website:

*   Download Docker Desktop

Once installed, verify Docker is running by checking the version:

```bash
docker --version
```

* * *

5\. Install Ansible
-------------------

Ansible will run on your Mac (the control node) and manage the VM and Docker containers. Install Ansible using Homebrew:

```bash
brew install ansible
```

Verify the installation:

```bash
ansible --version
```

* * *

6\. Set Up the Target Environment
---------------------------------

### a. **Vagrant (Ubuntu VM) Setup**

1.  SSH into the Vagrant VM:
    
    ```bash
    vagrant ssh
    ```
    
2.  Install Python (required by Ansible):
    
    ```bash
    sudo apt update
    sudo apt install -y python3
    ```
    
3.  Exit the VM:
    
    ```bash
    exit
    ```
    

### b. **Docker Setup**

1.  Pull an **Ubuntu Docker image** to act as a target container:
    
    ```bash
    docker pull ubuntu:latest
    ```
    
2.  Run a container from the image:
    
    ```bash
    docker run -d --name ansible-target -h ansible-target --rm -it ubuntu:latest
    ```
    
3.  Install Python in the Docker container:
    
    ```bash
    docker exec -it ansible-target apt update
    docker exec -it ansible-target apt install -y python3
    ```
    

* * *

7\. Configure Ansible Inventory and Playbook
--------------------------------------------

Now, let's set up your Ansible **inventory** and **playbook** in a `base/` directory.

### a. Create the `base/` Directory

First, create a `base/` directory where you will place your Ansible files:

```bash
mkdir -p ~/ansiblelab/base
cd ~/ansiblelab/base
```

### b. Create the `inventory.ini` File

The **inventory.ini** file defines the target hosts (Ubuntu VM and Docker container). To create the file, run the following command:

```bash
vi inventory.ini
```

Then, add the following content to `inventory.ini`:

```ini
[ubuntu_vm]
192.168.56.101 ansible_user=vagrant ansible_ssh_private_key_file=~/.vagrant.d/insecure_private_key

[docker_containers]
ansible-target ansible_host=localhost ansible_user=root ansible_port=2222 ansible_connection=docker
```

**Notes**:

*   Replace `192.168.56.101` with the IP address of your Vagrant Ubuntu VM (you can find this by running `vagrant ssh-config`).
*   The `ansible_connection=docker` line tells Ansible that the Docker container is a target using the Docker connection.

Save the file by pressing `Esc`, typing `:wq`, and pressing `Enter`.

### c. Create the `playbook.yml` File

The **`playbook.yml`** file defines the tasks that Ansible will perform on the target hosts (e.g., installing NGINX). To create the file, run the following command:

```bash
vi playbook.yml
```

Add the following content to `playbook.yml`:

```yaml
---
- hosts: all
  become: yes
  tasks:
    - name: Install NGINX
      ansible.builtin.package:
        name: nginx
        state: present
```

This playbook will install **NGINX** on all target hosts (both the Ubuntu VM and Docker containers).

Save the file by pressing `Esc`, typing `:wq`, and pressing `Enter`.

* * *

8\. Test Ansible Setup
----------------------

Now that you have configured the inventory and playbook, you can test the Ansible connection to your target nodes (VM and Docker containers):

```bash
ansible all -i inventory.ini -m ping
```

If everything is set up correctly, you should see a success response from both targets.

* * *

9\. Run Your First Ansible Playbook
-----------------------------------

To install **NGINX** on both the VM and the Docker container, run the following command:

```bash
ansible-playbook -i inventory.ini playbook.yml
```

This will install NGINX on both the Ubuntu VM and the Docker container.

* * *

Recap:
------

### Directory Structure:

```bash
~/ansiblelab/base
├── inventory.ini   # Inventory file listing Ubuntu VM and Docker targets
└── playbook.yml    # Playbook to install NGINX on all hosts
```

### Key Commands:

*   **Create Files**:
    
    *   `vi inventory.ini`: To create and edit the inventory file.
    *   `vi playbook.yml`: To create and edit the playbook file.
*   **Run Playbooks**:
    
    *   `ansible all -i inventory.ini -m ping`: Verify the connection to all hosts.
    *   `ansible-playbook -i inventory.ini playbook.yml`: Run the playbook to install NGINX.

* * *

Next Steps
----------

*   Explore other Ansible modules and tasks for system automation.
*   Experiment with roles and handlers in your playbooks.
*   Extend the lab by adding more Docker containers or VMs for practice.

* * *

Author
------

Created and maintained by [Phakhruddin](https://github.com/phakhruddin).

* * *

License
-------

This project is licensed under the MIT License - see the LICENSE file for details.

```markdown

### Summary of Updates:
- Instructions to create the `base/` directory.
- Replaced `nano` with `vi` for file editing.
- Comprehensive instructions for setting up Ansible, Ubuntu VM, Docker containers, and running the playbook.

This **README.md** provides all the necessary instructions to start with your Ansible lab on a Mac (M1 chip). Feel free to adapt it as needed!
```
