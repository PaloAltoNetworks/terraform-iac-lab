===============
Tool Comparison
===============
At this point, you've now used both Ansible and Terraform to configure a Palo
Alto Networks firewall. Though you've used these two tools to deploy the same
configuration, they differ in some important ways. Let's discuss some of those
differences now.

Idempotence
-----------
Terraform supports `idempotent <https://en.wikipedia.org/wiki/Idempotence>`_ operations. Saying that an
operation is idempotent means that applying it multiple times will not change
the result. This is important for automation tools because they can be run to
change configuration **and** also to verify that the configuration actually
matches what you want. You can run ``terraform apply`` continuously for hours,
and if your configuration matches what is defined in the plan, it won't
actually change anything.

Commits
-------
As you've probably noticed, a lot of the Ansible modules allow you to commit
directly from them. There is also a dedicated Ansible module that just does
commits, containing support for both the firewall and Panorama.

So how do you perform commits with Terraform? Currently, there is no support
for commits inside the Terraform ecosystem, so they have to be handled
externally. Lack of finalizers are `a known shortcoming <https://github.com/hashicorp/terraform/issues/6258>`_ for Terraform and, once
it is addressed, support for it can be added to the provider. In the meantime,
we've provides some Golang code in the appendix
(:doc:`../06-appendix/terraform-commit`) that you can use to fill the gap.

Data Sources
------------
Terraform may not have support for arbitrary operational commands, but it does
have a data source that you can use to retrieve specific parts of a ``show
system info`` command from the firewall or Panorama and then use that in your
Terraform plan file. This same thing is called "facts" in Ansible. Many of the
Ansible modules for PAN-OS support the gathering of facts that may be stored
and referenced in an Ansible playbook.
