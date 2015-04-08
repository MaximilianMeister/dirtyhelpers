## zVM

IBM Hypervisor for the SystemZ Platform

Everything like CPU, RAM is virtualized comparable to KVM

## zVM Directory Manager (DirMaint)

CMS application that helps manage an installations VM directory

It can be seen as a management/commandline interface to define a zVM Virtual Machine

Can be invoked over SMAPI

* automatic disk allocation (advantage: no keeping track of open disk areas)
* amount of storage
* CPU
* RAM
* Security properties
* Virtual switch connections

http://enterprisesystemsmedia.com/article/configuration-and-use-of-z-vm-dirmaint

### Manual Approach

All VM definitions can be done manually as well in a file called USER DIRECT

This is **not** recommended though, as the File can be very large and therefore manual changes are error-prone

Therefore it is recommended to use the DirMaint Command Line Interface

Once you activate DirMaint you have to stick with it, it is either/or

The test zVM that we will be working with has DirMaint activated

## SMAPI

The Systems Management APIs simplify the task of managing many virtual images running under a single z/VM image

The SMAPI is a set of servers (virtual machines) which work together

## xCAT

The Extreme Cloud Administration Tool is a toolkit that provides support for the deployment and administration of large cloud environments

It is an open source scalable distributed computing management and provisioning tool for

* Hardware control
* Discovery
* OS diskful/diskfree deployment

![Architecture of xCAT](/img/xcat-architecture.png "Architecture of xCAT")

Supports REST API and a GUI (though Horizon should be used when available)

### xCAT Servers

#### xCAT MN

* Management Node with which the user or some other program communicates to request management changes
* Only one instance of xCAT MN is necessary to manage multiple zVM Hypervisors
* Managed by only **one** nova-compute service node
* Contains a local repository of images, which are used by the ZHCP agents when provisioning the disks of a VM that is about to be instantiated
* Access to the images is provided by an NFS mount on the ZHCP agent.

TODO: see how that interacts with glance

![xCAT MN](/img/xCAT-mn.png "A Single xCAT Management Node Managing Three z/VM Hypervisor Instances")

#### ZHCP

An agent that interacts with:

* SMAPI (which runs as a set of VMs on the zVM Hypervisor)
* zVM Directory Manager (which maintains the stored definitions of the virtual machines, allocates minidisk storage among other duties).
  minidisks are smaller disks (like partitions) on a DASD, and are easier to manage with tools than DASDs

Only one instance of ZHCP per zVM hypervisor installation is necessary

### List of supported functionalities for xCAT

1. Lifecycle Management
 * Power on/off VM
 * Create/edit/delete VM
 * Migrate VM between any z/VM in an SSI cluster (only in z/VM 6.2)
2. Inventory
 * Software and hardware inventory of VM or z/VM system
 * Resource (e.g. disks, networks) inventory of z/VM system
3. Image Management
 * Cloning VM
 * Vanilla installation of Linux via Autoyast or Kickstart
 * Provisioning diskless VM via NFS read-only root filesystem
4. Network Management
 * Supports Layer 2 and 3 network switching for QDIO GLAN/VSWITCH and Hipersockets GLAN
 * Create/edit/delete QDIO GLAN/VSWITCH and Hipersockets GLAN
 * Add/delete virtual network devices to VM
5. Storage Management
 * Manage ECKD/FBAnative SCSI disks within a disk pool
 * Add/remove ECKD/FBA/native SCSI disks from VM
 * Attach or detach ECKD/FBA/native SCSI disks to a z/VM system
6. OS Management
 * Upgrading Linux OS
 * Add/update/remove software packages on OS
 * Basic xCAT functionalities, e.g. remote shell, post-scripts, rsync, etc.
7. Monitoring
 * Linux monitoring using Ganglia
8. Others
 * Full command line interface support
 * Web user interface support
 * Self-service portal to provision VM on demand

### Prerequisites

* Interaction from the OpenStack side through xCATs REST API
* Each zVM system (which resides in a LPAR) has one nova-compute service node
* There is only one xCAT MN (management node) which is managed by only **one** nova-compute service node
* Compute node and xCAT MN can ssh to each other without a password
* nova.conf properly configured. see https://wiki.openstack.org/wiki/Nova-z/VM or https://wiki.openstack.org/wiki/ZVMDriver#nova-zvm-virt-driver
* neutron.conf properly configured. see https://wiki.openstack.org/wiki/Quantum-zVM-Plugin#Configure_Examples
* cinder.conf properly configured. see https://wiki.openstack.org/wiki/Cinder-zvm-plugin#zVM_specified_Configuration_Samples

![xCAT OpenStack](/img/xCAT-openstack.png "The Architecture for z/VM Management")

#### Disk Requisites

TODO

#### Network Requisites

We have the neutron zVM driver which is designed as a Neutron Layer 2 Plugin/agent to explore the virtual networking facilities of zVM
When using Layer 3 network or DHCP features, you need to configure OpenVswitch and other Layer 3 agents with the neutron server

Who does what?
* The neutron zvm agent does the configuration part on the hypervisor (zVM) via xCATs REST API
* The neutron zvm plugin performs the database related work

Notes:
* One neutron-zvm-agent can work with/configure only **one** zVM host
* neutron-zvm-agent does not need to run on the same server with nova-compute
* the Neutron z/VM driver does not support IPV6

### zVM server side configuration

For a detailed explanation how to prepare the System itself (zVM, SMAPI, xCAT) refer to Chapter 3 and 4 in http://publibz.boulder.ibm.com/epubs/pdf/hcso2c20.pdf

### CMA and non-CMA

#### CMA

IBM provides a Cloud Manager Appliance (CMA) which contains everything including OpenStack

This Appliance will be tested and inspected to get a first view about the functionality itself

To be able to run it the necessary configurations are described in detail in Chapter 5 of http://publibz.boulder.ibm.com/epubs/pdf/hcso2c20.pdf under "Configuring the CMA" Page 29

#### non-CMA

Using Crowbar for deploying compute nodes means that we have to configure a non-CMA compute node (the necessary config files, etc.) by the usual provisioning with Chef

Details are in Chapter 5 of http://publibz.boulder.ibm.com/epubs/pdf/hcso2c20.pdf under "Configuring the non-CMA Node" Page 42

##### We will need

* a xCAT MN in addition to nodes that represent the ZHCP agent

A File called DMSSICNF COPY needs to contain:

* IP Address of the xCAT MN
* Netmask for the xCAT management network
* xCAT node name that represents the xCAT MN
* ZHCP node name that represents the ZHCP agent
* zVM system node name that represents the zVM system
* User and Password to contact the xCAT MN over the REST API (or the xCAT GUI)
* zVM Directory Manager disk pool name (that has been set up for allocation of minidisks) from the zVM system administrator

an example of the DMSSICNF COPY file looks like this:

![DMSSICNF COPY](/img/dmssicnf_copy.png "DMSSICNF COPY")

The OpenStack nova controller node will maybe be on x86 for the first tests, the goal is as well to run it on the s390 architecture

Cinder, Glance and Neutron will also have to be tested and evaluated in that context

##### Verification

After configuring the non-CMA compute node, the properties should be verified

There are two perl scripts which perform the first validation steps described in Chapter "Appendix A. Installation Verification Programs" Page 103 in http://publibz.boulder.ibm.com/epubs/pdf/hcso2c20.pdf

The second steps are simple nova, neutron and cinder CLI commands described in Chapter "Verify the OpenStack Configuration for a non-CMA Compute Node" Page 43 in http://publibz.boulder.ibm.com/epubs/pdf/hcso2c20.pdf

##### OpenStack Configuration Files

The following files should be configured by Chef:

* nova.conf in "Settings for Nova" Page 45 in http://publibz.boulder.ibm.com/epubs/pdf/hcso2c20.pdf
* neutron.conf in "Settings for Nova" Page 52 http://publibz.boulder.ibm.com/epubs/pdf/hcso2c20.pdf
* cinder.conf in "Settings for Cinder" Page 51 http://publibz.boulder.ibm.com/epubs/pdf/hcso2c20.pdf

##### Configuration of SSH for xCAT and Nova Compute Nodes

* SSH communication is needed between the xCAT MN and the compute node
* SSH communication is needed between all the compute nodes for novas resize function

refer to the Section "Configuration of SSH for xCAT and Nova Compute Nodes" Page 56 in http://publibz.boulder.ibm.com/epubs/pdf/hcso2c20.pdf

### Contacts

for questions please send a mail to:

* Ihno Krumreich <ihno@suse.de>
* Berthold Gunreben <bg@suse.de>
* Cameron Seader <cseader@suse.com>

### Documents

* [z/VM: A Key Cloud Infrastructure Component with Open Stack Enablement](http://www.vm.ibm.com/sysman/openstk.html)
* [xCAT](http://sourceforge.net/p/xcat/wiki/Main_Page/)
* [Nova + zVM](https://wiki.openstack.org/wiki/Nova-z/VM)
* [s390 Wiki on Redmine](https://redmine.nue.suse.com/projects/s390/wiki) You will need access for that, ask the Admin of Redmine
