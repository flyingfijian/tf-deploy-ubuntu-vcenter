#VMware vSphere Provider
provider "vsphere" {  
  #Set of variables used to connect to the vCenter
    vsphere_server = var.vsphere_server 
    user           = var.vsphere_user
    password       = var.vsphere_password
  
#If you have a self-signed cert
    allow_unverified_ssl = true
  }
  
#Name of the Datacenter in the vCenter
  data "vsphere_datacenter" "dc" {
    name = "dc01"
  }
#Name of the Cluster in the vCenter
  data "vsphere_compute_cluster" "cluster" {
    name          = "cl01"
    datacenter_id = data.vsphere_datacenter.dc.id
  }
#Name of the Datastore in the vCenter, where VM will be deployed
  data "vsphere_datastore" "datastore" {
    name          = "localssd"
    datacenter_id = data.vsphere_datacenter.dc.id
  }
#Name of the Portgroup in the vCenter, to which VM will be attached
  data "vsphere_network" "network" {
    name          = "VM Network"
    datacenter_id = data.vsphere_datacenter.dc.id
  }
#Name of the Templete in the vCenter, which will be used to the deployment
  data "vsphere_virtual_machine" "ubuntu20-04" {
    name          = "Ubuntu-TMP"
    datacenter_id = data.vsphere_datacenter.dc.id
  }
  
#Set VM parameteres
  resource "vsphere_virtual_machine" "ubu-testing" {
    name = "jenkins"
    num_cpus = 2
    memory   = 4096
    guest_id = "ubuntu64Guest"
    resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
    datastore_id     = data.vsphere_datastore.datastore.id

    network_interface {
      network_id = data.vsphere_network.network.id
    }
  
  
    disk {
      label            = "disk0"
      thin_provisioned = true
      size             = 50
    }
  
  
    clone {
      template_uuid = data.vsphere_virtual_machine.ubuntu20-04.id
#Linux_options are required section, while deploying Linux virtual machines
      customize {
          linux_options {
              host_name = "jenkins"
              domain = "thecloudkb.com"
          }
          network_interface {
              ipv4_address = "192.168.1.223"
              ipv4_netmask = "24"
          }
#There are a global parameters and need to be outside linux_options section. If you put IP Gateway or DNS in the linux_options, these will not be added
          ipv4_gateway = "192.168.1.1"
          dns_server_list = ["192.168.1.200"]
          dns_suffix_list = ["thecloudkb.com"]
      }

      
    }
  }
#Outup section will display vsphere_virtual_machine.ubu-testing Name and IP Address
output "VM_Name" {
  value = vsphere_virtual_machine.ubu-testing.name
}

output "VM_IP_Address" {
  value = vsphere_virtual_machine.ubu-testing.guest_ip_addresses
}