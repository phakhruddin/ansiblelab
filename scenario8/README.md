** Sample complex Ansible playbook examples** that use advanced Ansible features, such as loops, conditionals, roles, handlers, and dynamic inventories. These playbooks demonstrate various real-world use cases like package management, multi-host orchestration, system configuration, and error handling.

* * *

### 1\. **Multi-Host Orchestration with Roles and Handlers**

This playbook demonstrates how to manage multiple hosts with different roles (web servers, database servers), using **roles**, **handlers**, and **delegation**.

#### Playbook: `multi_host_playbook.yml`

```yaml
---
- name: Multi-host orchestration
  hosts: all
  become: yes
  roles:
    - webserver
    - database
  tasks:
    - name: Deploy to all servers
      debug:
        msg: "Deploying services to {{ ansible_hostname }}"

    - name: Deploy web configuration (Only to web servers)
      include_role:
        name: webserver
      when: "'web' in group_names"

    - name: Deploy database configuration (Only to database servers)
      include_role:
        name: database
      when: "'db' in group_names"

    - name: Restart services on all hosts
      ansible.builtin.service:
        name: myservice
        state: restarted
      notify: "Restart MyService on all hosts"

  handlers:
    - name: Restart MyService on all hosts
      ansible.builtin.service:
        name: myservice
        state: restarted
```

#### Key Features:

*   **Roles**: Modularize tasks by defining `webserver` and `database` roles.
*   **Dynamic Targeting**: Playbook only runs specific tasks on hosts in the `web` or `db` group.
*   **Handlers**: Triggers a service restart across all hosts when certain tasks are completed.

* * *

### 2\. **Rolling Update for Multiple Servers**

This playbook demonstrates how to perform a **rolling update** across a cluster of servers, ensuring that only a limited number of servers are updated simultaneously to minimize downtime.

#### Playbook: `rolling_update.yml`

```yaml
---
- name: Perform rolling update across servers
  hosts: app_servers
  become: yes
  serial: 2  # Limit to updating 2 servers at a time
  tasks:
    - name: Stop application service
      ansible.builtin.service:
        name: myapp
        state: stopped

    - name: Perform update task (e.g., pulling a new Docker image)
      ansible.builtin.shell: "docker pull myapp:latest"

    - name: Start application service
      ansible.builtin.service:
        name: myapp
        state: started

    - name: Check application health status
      uri:
        url: "http://{{ ansible_default_ipv4.address }}:8080/health"
        return_content: yes
      register: healthcheck
      retries: 5
      delay: 10
      until: healthcheck.status == 200

    - name: Verify update success
      debug:
        msg: "Server {{ ansible_hostname }} updated successfully!"
```

#### Key Features:

*   **Serial Execution**: Ensures updates happen to 2 servers at a time to minimize downtime.
*   **Retries with `until`**: Checks the health status of the service and retries until it's healthy.
*   **Health Check**: After each update, the playbook verifies that the application is running successfully.

* * *

### 3\. **Error Handling and Notifications**

This example includes **error handling** using the `rescue` block and triggers notifications like sending an email if a task fails.

#### Playbook: `error_handling.yml`

```yaml
---
- name: Error handling and notification example
  hosts: all
  become: yes
  tasks:
    - name: Ensure Nginx is installed
      ansible.builtin.package:
        name: nginx
        state: present
      register: nginx_install
      ignore_errors: yes

    - name: Check if Nginx installation failed
      debug:
        msg: "Nginx installation failed"
      when: nginx_install.failed
      notify: Send failure notification

    - name: Start Nginx service
      ansible.builtin.service:
        name: nginx
        state: started
      rescue:
        - name: Capture the error log
          ansible.builtin.shell: "journalctl -xe | tail -n 20"
          register: error_log

        - name: Send an email notification
          ansible.builtin.mail:
            host: localhost
            to: "admin@example.com"
            subject: "Nginx start failure on {{ ansible_hostname }}"
            body: "Nginx failed to start. Error log:\n{{ error_log.stdout }}"

  handlers:
    - name: Send failure notification
      ansible.builtin.mail:
        host: localhost
        to: "admin@example.com"
        subject: "Nginx Installation Failed on {{ ansible_hostname }}"
        body: "The installation of Nginx failed on {{ ansible_hostname }}. Please check the logs."
```

#### Key Features:

*   **Error Handling (`rescue`)**: Captures failures and logs the error when the task fails.
*   **Notifications**: Sends an email alert when critical operations (like service start) fail.
*   **Fail-Safe**: Even if the playbook encounters errors, it continues to handle them and notify the admin.

* * *

### 4\. **Managing Multiple Configurations with `with_items` and Dynamic Templates**

This example shows how to manage **multiple configurations** dynamically using loops and templates.

#### Playbook: `multiple_configurations.yml`

```yaml
---
- name: Configure multiple applications using templates
  hosts: webservers
  become: yes
  vars:
    app_configs:
      - { name: "app1", port: 8081, root: "/var/www/app1" }
      - { name: "app2", port: 8082, root: "/var/www/app2" }
      - { name: "app3", port: 8083, root: "/var/www/app3" }
  
  tasks:
    - name: Deploy NGINX configurations for each app
      template:
        src: templates/nginx-app.conf.j2
        dest: "/etc/nginx/conf.d/{{ item.name }}.conf"
      with_items: "{{ app_configs }}"

    - name: Reload NGINX after configuration changes
      ansible.builtin.service:
        name: nginx
        state: reloaded
      when: ansible_facts['distribution'] == "Ubuntu"
```

##### Example NGINX Template: `nginx-app.conf.j2`

```nginx
server {
    listen {{ item.port }};
    server_name {{ item.name }}.example.com;

    location / {
        root {{ item.root }};
        index index.html;
    }
}
```

#### Key Features:

*   **`with_items` Loop**: Iterates over multiple configurations and creates multiple NGINX configuration files.
*   **Dynamic Templates**: Uses the `template` module to dynamically generate configurations for different apps based on variables.
*   **Conditional Service Reload**: Only reloads NGINX if the OS is Ubuntu, showing conditional execution based on facts.

* * *

### 5\. **Dynamic Inventory with Cloud Providers (AWS)**

This playbook demonstrates how to use a **dynamic inventory** from AWS EC2 to target only specific instances (e.g., instances tagged as `webserver`) and deploy an application.

#### Playbook: `deploy_app_ec2.yml`

```yaml
---
- name: Deploy application to AWS EC2 instances dynamically
  hosts: tag_Name_webserver
  become: yes
  gather_facts: no
  tasks:
    - name: Install Docker on EC2 instances
      ansible.builtin.package:
        name: docker
        state: present

    - name: Start Docker service
      ansible.builtin.service:
        name: docker
        state: started

    - name: Deploy the application container
      ansible.builtin.docker_container:
        name: my_app
        image: myapp:latest
        state: started
        ports:
          - "8080:8080"
```

#### Key Features:

*   **Dynamic Inventory**: Leverages AWS EC2 instance tags to dynamically select the target hosts (`tag_Name_webserver`).
*   **EC2 Management**: Installs and configures Docker on the EC2 instances before deploying a container.
*   **Cloud Automation**: Manages cloud-based infrastructure dynamically with Ansible.

* * *

### 6\. **Parallel Execution and Retry Logic**

This playbook demonstrates running tasks in parallel across hosts and implementing a retry mechanism if a task fails.

#### Playbook: `parallel_execution.yml`

```yaml
---
- name: Parallel execution with retries
  hosts: webservers
  become: yes
  strategy: free  # Run tasks in parallel
  tasks:
    - name: Install Apache
      ansible.builtin.package:
        name: apache2
        state: present
      retries: 3
      delay: 5
      until: ansible_facts.packages.apache2 is defined
      ignore_errors: yes

    - name: Start Apache service
      ansible.builtin.service:
        name: apache2
        state: started
```

#### Key Features:

*   **Parallel Execution**: Uses the `free` strategy to run tasks on multiple hosts simultaneously.
*   **Retries**: Implements retries with delays if the package installation fails.

* * *

### Summary

These examples demonstrate how you can use Ansible to manage complex infrastructure with advanced features like roles, loops, conditionals, error handling, dynamic inventories
