---
- hosts: all
  become: yes
  tasks:
    - name: Install NGINX
      ansible.builtin.package:
        name: nginx
        state: present

