Here’s an **Ansible playbook** that installs and configures a simple **web server** (NGINX) on the **Debian** host you've created, along with your provided **inventory** configuration.

### Playbook: `web_server_setup.yml`

```yaml
---
- name: Set up NGINX Web Server on Debian
  hosts: vms
  become: true
  tasks:

    - name: Update APT package index
      ansible.builtin.apt:
        update_cache: true

    - name: Install NGINX
      ansible.builtin.apt:
        name: nginx
        state: present

    - name: Ensure NGINX is started and enabled at boot
      ansible.builtin.service:
        name: nginx
        state: started
        enabled: true

```

### Inventory File: `inventory.ini`

Your provided **inventory.ini** file:

```ini
[vms]
vm1 ansible_host=192.168.64.2 ansible_port=22 ansible_user=ansibleuser ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### Playbook Explanation:

*   **Update APT package index**: Ensures that the package index is updated before installing any packages.
*   **Install NGINX**: Installs the NGINX web server on the Debian host.
*   **Ensure NGINX is started and enabled**: Starts the NGINX service and ensures that it is enabled to start automatically at boot.

### How to Run the Playbook:

1.  **Navigate to your playbook directory**:
    
    ```bash
    cd ~/ansiblelab/base
    ```
    
2.  **Run the playbook** using the provided inventory file:
    
    ```bash
    ansible-playbook -i inventory.ini web_server_setup.yml
    ```
    

### Testing the Web Server:

```bash
ansible vm1 -i inventory.ini -m shell -b -a "ps -ef | grep nginx"
```
output will be:
```bash
[WARNING]: Platform linux on host vm1 is using the discovered Python interpreter at /usr/bin/python3.9, but future installation of another Python interpreter
could change the meaning of that path. See https://docs.ansible.com/ansible-core/2.17/reference_appendices/interpreter_discovery.html for more information.
vm1 | CHANGED | rc=0 >>
root        2452       1  0 Oct13 ?        00:00:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
www-data    2455    2452  0 Oct13 ?        00:00:00 nginx: worker process
www-data    2456    2452  0 Oct13 ?        00:00:00 nginx: worker process
www-data    2457    2452  0 Oct13 ?        00:00:00 nginx: worker process
www-data    2458    2452  0 Oct13 ?        00:00:00 nginx: worker process
www-data    2459    2452  0 Oct13 ?        00:00:00 nginx: worker process
www-data    2460    2452  0 Oct13 ?        00:00:00 nginx: worker process
www-data    2461    2452  0 Oct13 ?        00:00:00 nginx: worker process
www-data    2462    2452  0 Oct13 ?        00:00:00 nginx: worker process
root       17566   17565  0 18:51 pts/2    00:00:00 /bin/sh -c ps -ef | grep nginx
root       17568   17566  0 18:51 pts/2    00:00:00 grep nginx
```

This confirms that the NGINX web server is properly installed and running on the Debian host.
