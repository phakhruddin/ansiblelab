Demonstrates the use of **roles**, **handlers**, **conditionals**, **loops**, and **error handling**. This playbook is designed to set up a **multi-tier application** environment that includes:

*   A **web server** (NGINX).
*   An **application server** (Python Flask).
*   A **database server** (PostgreSQL).

The playbook also includes **conditional logic** to manage different tasks based on the host type and uses **handlers** to restart services only when changes occur.

### Playbook: `site.yml`

```yaml
---
- name: Multi-Tier Application Deployment
  hosts: all
  become: yes
  vars:
    app_user: myappuser
    db_name: myappdb
    db_user: myappuser
    db_password: secretpassword

  roles:
    - web
    - app
    - db

  tasks:
    - name: Ensure application user exists
      ansible.builtin.user:
        name: "{{ app_user }}"
        state: present

    - name: Create directories for application
      ansible.builtin.file:
        path: "/var/www/{{ app_user }}"
        state: directory
        owner: "{{ app_user }}"
        mode: '0755'
      with_items:
        - logs
        - config
        - releases

    - name: Deploy base configuration files
      ansible.builtin.template:
        src: templates/common_config.j2
        dest: "/etc/myapp/config.conf"
      notify: Restart Application Service

    - name: Notify user of successful setup
      ansible.builtin.debug:
        msg: "Setup completed for {{ inventory_hostname }}"
```

### Directory Structure

```css
ansiblelab/
├── site.yml
├── inventory.ini
├── roles/
│   ├── web/
│   │   ├── tasks/
│   │   │   └── main.yml
│   │   └── handlers/
│   │       └── main.yml
│   ├── app/
│   │   ├── tasks/
│   │   │   └── main.yml
│   │   └── handlers/
│   │       └── main.yml
│   └── db/
│       ├── tasks/
│       │   └── main.yml
│       └── handlers/
│           └── main.yml
└── templates/
    └── common_config.j2
```

### Inventory File: `inventory.ini`

```ini
[webservers]
web1 ansible_host=192.168.1.101 ansible_user=ansibleuser ansible_ssh_private_key_file=~/.ssh/id_rsa

[appservers]
app1 ansible_host=192.168.1.102 ansible_user=ansibleuser ansible_ssh_private_key_file=~/.ssh/id_rsa

[dbservers]
db1 ansible_host=192.168.1.103 ansible_user=ansibleuser ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### Role: `web/tasks/main.yml`

```yaml
---
- name: Install NGINX
  ansible.builtin.apt:
    name: nginx
    state: present
  notify: Restart NGINX

- name: Ensure NGINX is running
  ansible.builtin.service:
    name: nginx
    state: started
    enabled: yes

- name: Deploy NGINX configuration
  ansible.builtin.template:
    src: templates/nginx.conf.j2
    dest: /etc/nginx/sites-available/myapp
  notify: Restart NGINX
```

### Role: `web/handlers/main.yml`

```yaml
---
- name: Restart NGINX
  ansible.builtin.service:
    name: nginx
    state: restarted
```

### Role: `app/tasks/main.yml`

```yaml
---
- name: Install Python and pip
  ansible.builtin.apt:
    name:
      - python3
      - python3-pip
    state: present

- name: Install Flask
  ansible.builtin.pip:
    name: flask

- name: Deploy Flask app
  ansible.builtin.copy:
    src: files/myapp.py
    dest: /var/www/myapp/myapp.py
    owner: "{{ app_user }}"
    mode: '0755'
  notify: Restart Flask Application

- name: Ensure Flask application is running with systemd
  ansible.builtin.template:
    src: templates/flask.service.j2
    dest: /etc/systemd/system/flask.service
  notify: Restart Flask Application
```

### Role: `app/handlers/main.yml`

```yaml
---
- name: Restart Flask Application
  ansible.builtin.service:
    name: flask
    state: restarted
    enabled: yes
```

### Role: `db/tasks/main.yml`

```yaml
---
- name: Install PostgreSQL
  ansible.builtin.apt:
    name: postgresql
    state: present

- name: Ensure PostgreSQL is running
  ansible.builtin.service:
    name: postgresql
    state: started
    enabled: yes

- name: Create database user
  ansible.builtin.postgresql_user:
    name: "{{ db_user }}"
    password: "{{ db_password }}"
    state: present

- name: Create application database
  ansible.builtin.postgresql_db:
    name: "{{ db_name }}"
    owner: "{{ db_user }}"
    state: present
```

### Role: `db/handlers/main.yml`

```yaml
---
- name: Restart PostgreSQL
  ansible.builtin.service:
    name: postgresql
    state: restarted
```

### Template Example: `templates/common_config.j2`

```ini
[app]
app_user = {{ app_user }}
db_host = {{ hostvars['db1'].ansible_host }}
db_name = {{ db_name }}
db_user = {{ db_user }}
db_password = {{ db_password }}
```

### Template Example: `templates/nginx.conf.j2`

```nginx
server {
    listen 80;
    server_name myapp.example.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### Template Example: `templates/flask.service.j2`

```ini
[Unit]
Description=Flask Application

[Service]
User={{ app_user }}
WorkingDirectory=/var/www/myapp
ExecStart=/usr/bin/python3 /var/www/myapp/myapp.py

[Install]
WantedBy=multi-user.target
```

* * *

### Running the Playbook

To run the playbook, ensure that you are in the directory containing `site.yml` and `inventory.ini`, and then execute the following command:

```bash
ansible-playbook -i inventory.ini site.yml
```

### Explanation of the Playbook

*   **Roles**: The playbook uses three roles—`web`, `app`, and `db`—to organize tasks and ensure modularity.
*   **Handlers**: Each role has handlers to restart services when a change is detected.
*   **Variables**: Uses `vars` in `site.yml` to centralize database user, password, and other configuration values.
*   **Templates**: Uses Jinja2 templates to generate configuration files like `nginx.conf` and `flask.service`.
*   **Conditional Logic**: Handles different tasks based on host groups (`webservers`, `appservers`, `dbservers`).
*   **Loops**: Uses a loop to create directories for logs, configuration, and application releases.

### What This Playbook Does:

1.  **Sets up a web server**:
    
    *   Installs and configures NGINX.
    *   Sets up a reverse proxy to the Flask app.
    *   Deploys a configuration template and restarts NGINX if changes occur.
2.  **Deploys a Flask application**:
    
    *   Installs Python and Flask.
    *   Deploys a Flask application and configures it to run as a service using `systemd`.
    *   Restarts the Flask service when changes are detected.
3.  **Configures a PostgreSQL database**:
    
    *   Installs PostgreSQL.
    *   Creates a database user and a database.
    *   Restarts the PostgreSQL service if changes are detected.
4.  **Deploys a common configuration**:
    
    *   Uses a template to generate a configuration file with database connection details.
    *   Uses `hostvars` to dynamically insert the database host's IP.

### Benefits of this Approach:

*   **Modularity**: Roles make it easier to manage tasks and reuse them for other projects.
*   **Scalability**: You can add more web, app, or database servers easily by updating the inventory file.
*   **Separation of Concerns**: Different roles manage specific services, improving clarity and maintainability.
*   **Resiliency**: Uses handlers to ensure services restart when configuration files change, ensuring that updates are applied without manual intervention.

This complex playbook showcases how Ansible can automate the setup of a multi-tier application environment with best practices like modularity and dynamic configuration.
