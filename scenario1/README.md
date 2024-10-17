Ansible Lab: Setting Up Debian on UTM with Ansible User
=======================================================

This guide provides step-by-step instructions for installing **Debian** on **UTM** (specifically for Mac M1/M2 chips), creating a passwordless `ansibleuser`, and setting up SSH access. This setup is ideal for preparing a local environment for Ansible practice or labs.

Prerequisites
-------------

*   **UTM** installed on your Mac. You can download it from here.
*   **Debian ISO** file downloaded from the official Debian website. You can get it from here.

* * *

Step 1: Installing Debian on UTM
--------------------------------

### 1.1 Download and Install UTM

*   Go to UTM's website and download the latest version of UTM for your Mac.
*   Install UTM by dragging it into your **Applications** folder.

### 1.2 Download Debian ISO

Download the latest **Debian ISO** from the official website:

*   Debian ISO Download

Choose the appropriate architecture for your M1/M2 Mac (typically **ARM64**).

### 1.3 Setting Up Debian in UTM

1.  Open UTM and click the **Create a New Virtual Machine** button.
2.  Select **Virtualize** (for ARM64 architecture).
3.  Set the system to **Debian** or **Linux**.
4.  Choose **ARM64** as the architecture (for Mac M1/M2 chips).
5.  In the **Boot** section, click **Browse** and select the **Debian ISO** file you downloaded.
6.  Allocate appropriate **memory (RAM)** and **CPU cores** (e.g., 2GB RAM and 2 CPU cores).
7.  Create a **new disk** (recommended size: 20 GB or more).
8.  Go through the rest of the configuration and then click **Save** to create the virtual machine.

### 1.4 Installing Debian in UTM

1.  Start the Debian VM by clicking the **Play** button in UTM.
2.  Follow the Debian installation process. When prompted:
    *   Choose your language, time zone, and keyboard layout.
    *   Configure the network (you can use the default settings or set up a static IP).
    *   Create the default user and root passwords.
    *   Partition the disk (use the guided option if unsure).
3.  Complete the installation and reboot the VM.

* * *

Step 2: Creating a Passwordless Ansible User
--------------------------------------------

Once Debian is installed and running, you can create an **ansibleuser** account without a password. Follow these steps:

### 2.1 Log in to Your Debian VM

Use the username and password you created during the Debian installation to log into the VM.

### 2.2 Create `ansibleuser` with Passwordless Login

Run the following command to create a new user named `ansibleuser` with a home directory and no password:

```bash
sudo adduser --home /home/ansibleuser --shell /bin/bash --gecos "" ansibleuser --disabled-password
```

### 2.3 Verify the User Creation

To check if the user was created successfully with the correct permissions and home directory, run:

```bash
ls -ld /home/ansibleuser
```

The output should show that the home directory exists and is owned by `ansibleuser`.

* * *

Step 3: Setting Up Passwordless SSH Access for Ansible User
-----------------------------------------------------------

To allow Ansible to manage the system, we need to set up SSH access for `ansibleuser`.

### 3.1 Create SSH Directory and `authorized_keys` File

Run the following commands to create the `.ssh` directory and `authorized_keys` file for `ansibleuser`:

```bash
sudo mkdir -p /home/ansibleuser/.ssh
sudo touch /home/ansibleuser/.ssh/authorized_keys
sudo chmod 700 /home/ansibleuser/.ssh
sudo chmod 600 /home/ansibleuser/.ssh/authorized_keys
sudo chown -R ansibleuser:ansibleuser /home/ansibleuser/.ssh
```

### 3.2 Add Your SSH Public Key

To allow passwordless SSH access, copy your SSH public key into the `authorized_keys` file. If you don’t have an SSH key yet, you can generate one using the following command:

```bash
ssh-keygen -t rsa -b 4096
```

Then, copy your public key to the `ansibleuser`'s `authorized_keys` file:

```bash
echo "your-ssh-public-key" | sudo tee -a /home/ansibleuser/.ssh/authorized_keys
```

### 3.3 Test Passwordless SSH Access

From your local machine, test the SSH connection using:

```bash
ssh ansibleuser@<debian_vm_ip>
```

You should be able to log in without entering a password.

* * *

Step 4: Add `ansibleuser` to the Sudo Group (Optional)
------------------------------------------------------

If you want the `ansibleuser` to have sudo privileges, run the following command:

```bash
sudo usermod -aG sudo ansibleuser
```

This will allow `ansibleuser` to execute commands with `sudo`.

* * *

Step 5: Conclusion
------------------

You have successfully set up Debian in UTM on your Mac, created a passwordless `ansibleuser`, and configured SSH access. This setup is now ready for use as an Ansible target.

Next, you can proceed with configuring Ansible on your local machine and begin running playbooks against your newly created `ansibleuser` on the Debian VM.

* * *

Author
------

Created and maintained by [Phakhruddin](https://github.com/phakhruddin).

* * *

License
-------

This project is licensed under the MIT License - see the LICENSE file for details.

* * *

This **README.md** file provides a complete guide for setting up a Debian environment in UTM, configuring an `ansibleuser`, and setting up SSH access. Feel free to adjust it as needed!
