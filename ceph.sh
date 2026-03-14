#!/bin/bash

# =====================================================
# CephFS Administration Tool
# Author: Gustavo Rodrigues
# Version: 1.0
# =====================================================

CEPH_MOUNT="/../.."

# -----------------------------------------------------
# Utility functions
# -----------------------------------------------------

pause() {
    read -p "Press ENTER to continue..."
}

error() {
    echo "ERROR: $1"
    pause
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root."
        exit 1
    fi
}

check_mount() {
    if ! mount | grep -q "$CEPH_MOUNT"; then
        echo "CephFS is not mounted at $CEPH_MOUNT"
        exit 1
    fi
}

check_dependencies() {

    DEPS=("microceph.ceph" "setfattr" "getfattr" "numfmt" "bc" "du" "find")

    for cmd in "${DEPS[@]}"; do
        if ! command -v $cmd &>/dev/null; then
            echo "Missing dependency: $cmd"
            exit 1
        fi
    done
}

validate_directory() {

    if [ ! -d "$1" ]; then
        error "Directory does not exist."
        return 1
    fi

    return 0
}

# -----------------------------------------------------
# Menu principal
# -----------------------------------------------------

menu_principal() {

    while true; do

        clear
        echo "======================================="
        echo "       CEPHFS ADMINISTRATION TOOL"
        echo "       By Gustavo.R  v3.0"
        echo "======================================="
        echo "1) Cluster Status"
        echo "2) CephFS Status"
        echo "3) Quota Management"
        echo "4) Disk Usage by Folder"
        echo "5) List OSDs"
        echo "6) List Directories with Quotas"
        echo "7) Cluster Usage (ceph df)"
        echo "8) Health Details"
        echo "9) List Pools"
        echo "0) Exit"
        echo "---------------------------------------"

        read -p "Select an option: " op

        case $op in
            1) status_cluster ;;
            2) status_cephfs ;;
            3) menu_quota ;;
            4) menu_uso ;;
            5) menu_osd ;;
            6) menu_listar_quotas ;;
            7) cluster_usage ;;
            8) health_detail ;;
            9) list_pools ;;
            0) exit 0 ;;
            *) echo "Invalid option"; pause ;;
        esac

    done
}

# -----------------------------------------------------
# Cluster Status
# -----------------------------------------------------

status_cluster() {

    clear
    echo "========== CLUSTER STATUS =========="
    microceph.ceph status
    pause
}

# -----------------------------------------------------
# CephFS Status
# -----------------------------------------------------

status_cephfs() {

    clear
    echo "========== CEPHFS STATUS =========="
    microceph.ceph fs status
    pause
}

# -----------------------------------------------------
# Cluster Usage
# -----------------------------------------------------

cluster_usage() {

    clear
    echo "========== CLUSTER USAGE =========="
    microceph.ceph df
    pause
}

# -----------------------------------------------------
# Health Detail
# -----------------------------------------------------

health_detail() {

    clear
    echo "========== HEALTH DETAIL =========="
    microceph.ceph health detail
    pause
}

# -----------------------------------------------------
# Pools
# -----------------------------------------------------

list_pools() {

    clear
    echo "========== POOLS =========="
    microceph.ceph osd lspools
    pause
}

# -----------------------------------------------------
# OSD Tree
# -----------------------------------------------------

menu_osd() {

    clear
    echo "========== OSD TREE =========="
    microceph.ceph osd tree
    pause
}

# -----------------------------------------------------
# Disk Usage
# -----------------------------------------------------

menu_uso() {

    clear
    echo "========== DISK USAGE =========="
    du -sh ${CEPH_MOUNT}/*
    pause
}

# -----------------------------------------------------
# Quota Menu
# -----------------------------------------------------

menu_quota() {

    while true; do

        clear
        echo "========== QUOTA MANAGEMENT =========="
        echo "1) Create / Update quota"
        echo "2) View quota"
        echo "3) Remove quota"
        echo "0) Back"
        echo "--------------------------------------"

        read -p "Select: " op

        case $op in

            1)

                read -p "Directory path: " PATHQ

                validate_directory "$PATHQ" || continue

                read -p "Quota size (example 10G 50G 1T): " SIZE

                BYTES=$(numfmt --from=iec "$SIZE")

                setfattr -n ceph.quota.max_bytes -v "$BYTES" "$PATHQ"

                echo "Quota applied successfully."

                pause
                ;;

            2)

                read -p "Directory path: " PATHQ

                validate_directory "$PATHQ" || continue

                QUOTA=$(getfattr -n ceph.quota.max_bytes --only-values "$PATHQ" 2>/dev/null)

                if [ -z "$QUOTA" ]; then
                    echo "This directory has NO quota."
                else
                    GB=$(echo "scale=2; $QUOTA/1024/1024/1024" | bc)
                    echo "Configured quota: $GB GB"
                fi

                pause
                ;;

            3)

                read -p "Directory path: " PATHQ

                validate_directory "$PATHQ" || continue

                setfattr -x ceph.quota.max_bytes "$PATHQ"

                echo "Quota removed."

                pause
                ;;

            0)
                return
                ;;

            *)
                echo "Invalid option"
                pause
                ;;
        esac

    done
}

# -----------------------------------------------------
# List directories with quotas
# -----------------------------------------------------

menu_listar_quotas() {

    clear

    echo "========== DIRECTORIES WITH QUOTAS =========="

    find "$CEPH_MOUNT" -type d 2>/dev/null | while read DIR; do

        QUOTA=$(getfattr -n ceph.quota.max_bytes --only-values "$DIR" 2>/dev/null)

        if [ ! -z "$QUOTA" ]; then

            GB=$(echo "scale=2; $QUOTA/1024/1024/1024" | bc)

            USO=$(du -sh "$DIR" 2>/dev/null | awk '{print $1}')

            printf "%-60s | QUOTA: %6s GB | USAGE: %6s\n" "$DIR" "$GB" "$USO"

        fi

    done

    echo "----------------------------------------------"

    pause
}

# -----------------------------------------------------
# Initialization
# -----------------------------------------------------

check_root
check_dependencies
check_mount

menu_principal
