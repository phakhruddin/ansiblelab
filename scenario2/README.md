
Web Server Setup with Ansible
=============================

This Ansible playbook installs and configures an **NGINX web server** on a Debian-based system. It automates the installation of NGINX, creates a simple HTML webpage, ensures the web server is running, and optionally opens the HTTP port (80) using UFW.

Playbook Overview
-----------------

This repository contains the **web.yml** playbook, which performs the following tasks:

1.  Updates the APT package index.
2.  Installs the NGINX web server.
3.  Ensures the NGINX service is started and enabled at boot.
4.  Creates a custom HTML file in the `/var/www/html/` directory.
5.  Verifies if NGINX is running and accessible.

* * *

Prerequisites
-------------

Before you run this playbook, make sure you have the following:

*   **Ansible** installed on your control machine (the machine running Ansible).
*   A **Debian-based VM** or server accessible over SSH.
*   A configured **inventory file** that lists the target VM.
*   **SSH key-based authentication** set up for the Ansible user on the target VM.

* * *

Step 1: Configure Inventory
---------------------------

Create or update your **inventory file** (e.g., `inventory.ini`) to include your target Debian VM. Below is an example inventory file:

```ini
[vms]
vm1 ansible_host=192.168.64.2 ansible_port=22 ansible_user=ansibleuser ansible_ssh_private_key_file=~/.ssh/id_rsa
```

Replace the following placeholders with your actual setup:

*   **`ansible_host`**: The IP address of your Debian VM.
*   **`ansible_user`**: The user with SSH access to the VM (e.g., `ansibleuser`).
*   **`ansible_ssh_private_key_file`**: Path to the SSH private key for authentication.

* * *

Step 2: Playbook Details
------------------------

### Playbook: `web.yml`

The playbook installs NGINX and sets up a simple HTML webpage. Here is the content of the playbook:

```yaml
---
- name: Set up NGINX Web Server on Debian
  hosts: vms
  become: yes
  tasks:

    - name: Update APT package index
      ansible.builtin.apt:
        update_cache: yes

    - name: Install NGINX
      ansible.builtin.apt:
        name: nginx
        state: present

    - name: Ensure NGINX is started and enabled at boot
      ansible.builtin.service:
        name: nginx
        state: started
        enabled: yes

    - name: Create a simple HTML file for the web server
      ansible.builtin.copy:
        dest: /var/www/html/index.html
        content: |
          <!DOCTYPE html>
          <html>
          <head>
              <title>Welcome to Ansible Web Server!</title>
          </head>
          <body>
              <h1>Hello from Ansible!</h1>
              <p>This is a simple web page deployed via Ansible on a Debian host.</p>
          </body>
          </html>
        mode: '0644'

    - name: Open HTTP (Port 80) in UFW (if installed)
      ansible.builtin.ufw:
        rule: allow
        port: '80'
        proto: tcp
      ignore_errors: yes

    - name: Test if NGINX is running
      ansible.builtin.shell: 
        cmd: |
          curl http://{{ ansible_default_ipv4.address }}/
        executable: /bin/bash
      register: nginx_test

    - name: Display the NGINX test stdout
      ansible.builtin.debug:
        msg: "{{ nginx_test.stdout }}"
```

### Explanation of Playbook Tasks:

1.  **Update APT package index**: Updates the package list on the target system.
2.  **Install NGINX**: Installs the NGINX web server package.
3.  **Start and Enable NGINX**: Ensures NGINX is running and enabled to start on boot.
4.  **Create HTML File**: Creates a simple HTML file that NGINX will serve.
5.  **Test NGINX**: Checks if NGINX is serving content by making an HTTP request to `localhost`.

* * *

Step 3: Running the Playbook
----------------------------

### 3.1. Run the Playbook

Navigate to the directory where the playbook and inventory file are located, then run the playbook using the following command:

```bash
ansible-playbook -i inventory.ini web.yml
```

This will execute the playbook and set up the NGINX web server on the specified VM.

### 3.2. Verify the Web Server

Once the playbook has run successfully, you can verify the NGINX web server by opening a web browser and navigating to your VM's IP address:

```arduino
http://192.168.64.2
```

You should see a webpage with the following message:

```csharp
Hello from Ansible!
This is a simple web page deployed via Ansible on a Debian host.
```

* * *

Step 4: Run in Check Mode
-------------------------

If you want to simulate the playbook execution without making any changes (dry-run), use the `--check` option:

```bash
ansible-playbook -i inventory.ini web.yml --check
```

This will show you the tasks that would be executed, but no changes will be applied to the system.

* * *

Step 5: Troubleshooting
-----------------------

If you encounter any issues during the playbook execution, you can use the verbose mode to get more detailed output:

```bash
ansible-playbook -i inventory.ini web.yml -v
```

For even more detailed logs, use multiple `v` options:

```bash
ansible-playbook -i inventory.ini web.yml -vvv
```

This will help in debugging any problems that occur during the playbook run.

* * *

Conclusion
----------

This playbook provides an automated way to set up a basic NGINX web server on a Debian VM. By following the steps in this guide, you should be able to deploy and test the web server using Ansible.

* * *

Author
------

Created and maintained by [Phakhruddin](https://github.com/phakhruddin).

* * *

License
-------

This project is licensed under the MIT License - see the LICENSE file for details.

* * *

This **README.md** will guide users through the entire process of setting up a web server using Ansible, starting with the inventory configuration and running the `web.yml` playbook. You can now add this to your repository!