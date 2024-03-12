#!/bin/bash
# IP Address Consumption List
# Lists all subnets in all compartments and how many IP addresses are consumed

# Compartments
compartments=$(oci iam compartment list --all --include-root | jq -r .data[].id)
for compartment in $compartments; do
        compartment_name=$(oci iam compartment get --compartment-id $compartment | jq -r '.data.name')
        vcns=$(oci network vcn list --compartment-id $compartment | jq -r '.data[].id')
        vcn_names=$(oci network vcn list --compartment-id $compartment | jq -r '.data[]."display-name"')
        if [ -z "${vcns// /}" ]; then
                echo "No VCNs in Compartment ${compartment_name}"
                echo "------------------------------------------"
        else
                echo "Compartment: ${compartment_name}"
                echo "-----------------------------------------"
                echo "VCNs:"
                echo "${vcn_names}"
                echo "-----------------------------------------"
                subnet_list=$(oci network subnet list --compartment-id $compartment | jq .data[] | jq .id)
                for subnet in $subnet_list; do
                        subnet_ocid=$(echo ${subnet} | tr -d '"')
                        ip_list=$(oci network private-ip list --all --subnet-id $subnet_ocid | jq -r .data[].id | wc -l)
                        subnet_name=$(oci network subnet get --subnet-id $subnet_ocid | jq -r '.data."display-name"')
                        subnet_cidr_block=$(oci network subnet get --subnet-id $subnet_ocid | jq -r '.data."cidr-block"')
                        echo ${subnet_name}
                        echo "---"
                        echo "Subnet CIDR Block: ${subnet_cidr_block}"
                        echo "Used IP Addresses: ${ip_list}"
                        echo ""
                done
        fi
done