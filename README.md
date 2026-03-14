# CephFS Administration Script

A Bash-based interactive tool designed to simplify **CephFS administration and monitoring**.

This script provides a menu-driven interface for common Ceph cluster and filesystem operations such as:

* Checking cluster status
* Managing CephFS quotas
* Monitoring storage usage
* Inspecting OSD topology
* Listing directories with configured quotas

The goal is to provide a quick operational tool for **SysAdmins, NOC engineers, and storage administrators**.

---

# Author

**Gustavo Henrique Rodrigues**
SysAdmin – NOC Engineer

LinkedIn
https://www.linkedin.com/in/gustavo-henrique-rodrigues-3070a5260

---

# Features

* Interactive terminal menu
* Ceph cluster status monitoring
* CephFS status inspection
* Directory quota management
* Disk usage analysis by folder
* OSD topology visualization
* Automatic quota detection
* Quota and usage comparison
* CephFS administrative utilities

---

# Requirements

The following tools must be available on the system:

* microceph
* ceph
* bc
* numfmt
* attr utilities (`setfattr`, `getfattr`)
* du
* find

Install dependencies if needed:

```id="dpxkfd"
sudo apt install attr coreutils bc
```

---

# Configuration

Edit the mount point if necessary:

```id="b16t7x"
CEPH_MOUNT="/mnt/example"
```

This should point to your mounted CephFS path.

---

# Installation

Clone the repository:

```id="v57pf7"
git clone https://github.com/gustavoohrodrigues/cephfs-admin-tool.git
```

Enter the directory:

```id="qg7e20"
cd cephfs-admin-tool
```

Make the script executable:

```id="7p5kha"
chmod +x ceph.sh
```

Run the script:

```id="vq69qs"
sudo ./ceph.sh
```

---

# Menu Overview

Main menu options:

| Option | Description                  |
| ------ | ---------------------------- |
| 1      | Cluster Status               |
| 2      | CephFS Status                |
| 3      | Quota Management             |
| 4      | Disk Usage by Folder         |
| 5      | List OSDs                    |
| 6      | List Directories with Quotas |
| 0      | Exit                         |

---

# Quota Management

The script manages CephFS directory quotas using extended attributes:

```
ceph.quota.max_bytes
```

Example quota:

```
10G
50G
1T
```

The script automatically converts these values to bytes.

---

# Example Output

```
/mnt/example/projectA      | QUOTA: 100 GB | USAGE: 45G
/mnt/example/backups       | QUOTA: 500 GB | USAGE: 220G
```

---

# Important Notes

* The script must run with sufficient privileges.
* The CephFS mount must exist before running the script.
* Incorrect quota configuration may impact application storage.

---

# Possible Future Improvements

* Ceph health monitoring
* Cluster capacity reporting
* Pool inspection
* Storage alerts
* Logging system
* Integration with monitoring systems

---

# License

MIT License
