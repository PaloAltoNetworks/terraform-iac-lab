============
Introduction
============

infrastructure as Code
-------------------

This training lab provides hands-on exposure to Infrastructure as Code (IaC) 
concepts and practices.  

.. image:: iac.png


Config Definitions
    TBD

Config Repository
    A version control system (VCS) is a key element in managing application source
    code.  Since infrastructure definitions are just another form of source code, 
    a VCS It supports revision control, code checkout/checkin, team collaboration, 
    code review, and automated build interfaces.

Build Tools
    TBD

Platform APIs
    TBD

Deploy Infrastructure
    TBD

Test and Validate
    TBD



Lab Topology
------------

.. figure:: topology.png

+--------------+--------------+-------------+
| Subnet       | Address      | Interface   |
+==============+==============+=============+
| Management   | 10.5.0.0/24  | Management  |
+--------------+--------------+-------------+
| Untrust      | 10.5.1.0/24  | ethernet1/1 |
+--------------+--------------+-------------+
| Web          | 10.5.2.0/24  | ethernet1/2 |
+--------------+--------------+-------------+
| Database     | 10.5.3.0/24  | ethernet1/3 |
+--------------+--------------+-------------+

Lab Components
--------------

Qwiklabs
    This lab is launched using Qwiklabs, which is an online learning platform
    that deploys and provides access to cloud-based lab environments.  Qwiklabs
    will establish a set of temporary set of credentials in the cloud provider
    in order to deploy and access the cloud infrastructure and services.

Launchpad VM
    A Debian 9 Linux virtual machine will be deployed in each cloud environment
    for you to use as your primary workspace for the lab activities,  This VM
    will be provisioned with all the tools and libraries necessary for
    deploying and managing infrastructure in the cloud provider.

Hashicorp Terraform
    Each cloud provider offers a mechanism that allow you to define a set of
    infrastructure element or services and orchestrate their instantiation.
    However, these tools and templates are specific to each cloud provider.
    We will be using Terraform to perform this function as it provides a
    common set of capabilities and a template formats acroos all cloud
    providers.

Red Hat Ansible
    Whereas Terraform excels at orchestrating deployment activities, Ansible is
    more effective at automating configuration management tasks.  We will be
    using both Terraform and Ansible to make configuration changes to the
    VM-Series firewall in order to illustrate their different capabilities.

Google Cloud Platform (GCP)
    Google Cloud Platform, offered by Google, is a suite of cloud computing
    services that runs on the same infrastructure that Google uses internally
    for its end-user products, such as Google Search and YouTube.

Amazon Web Services (AWS)
    Amazon Web Services is a subsidiary of Amazon that provides on-demand cloud
    computing platforms to individuals, companies and governments, on a metered
    pay-as-you-go basis.
