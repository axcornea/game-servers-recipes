# Terraria game server

This guide will help you set up a working Terraria server that you can use to play together with your friends.

## About the architecture

This guide will set up 2 VMs: one is the actual server, while the other one is a TCP proxy that will automatically start and stop the first instance based on the traffic, so you can save some money. You can find more details about this TCP proxy [here](https://github.com/axcornea/wakeup-vm-by-tcp).

## Prerequisites

You should have `terraform` installed on your machine. This setup was built using the version shown below.

```shell
$ terraform version
Terraform v1.3.5
on windows_amd64
```

## Setup

> This guide describes the process of deploying the game servers on the GCP. If you would like to use another platform then you'll have to manually adjust Terraform manifest files.

### 1. Create a GCP project

You should create a GCP project, or use an existing one. You should remember the project ID (i.e. `amazing-insight-369402`).

### 2. Create a Service Account for Terraform

Terraform requires a SA in order to do its job. 

If you don't have a service account set up, follow this steps:

1. Open [service accounts page](https://console.cloud.google.com/iam-admin/serviceaccounts).
2. Select the project you created before.
3. Click on "Create service account".
4. Give it any name and click on "Create and continue".
5. In role chooser select "Basic" and then "Editor".
6. Click on "Done".
7. Open "Manage keys" option from the three-dots menu near the newly created service account.
8. Click on "Add key", and create a new JSON key.
9. Keep the generated file.

### 3. Modify `local.auto.tfvars`

Follow instructions inside this file and replace the placeholders.

### 4. Prepare Terraform

Execute the following command. It will download all the required binaries.

```shell
$ terraform init
```

### 5. Create the infrastructure

Execute the following command. It will prompt if you agree to proceed - answer "yes".

The last row will contain the public IP of the newly created Terraria server. Now the servers are up and running.

```shell
$ terraform apply
...
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
...
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

terraria_proxy_ip = "34.141.204.191"
```

The last row will contain the public IP of the newly created Terraria server. You can use this IP to connect to the server. Now the servers are up and running.

### 6. Setup Terraria world

> Right now this is the only step that you have to do manually on the servers. Later it will be automated too.

From [this VM listing page](https://console.cloud.google.com/compute/instances) select "Connect SSH" near the `terraria-server-*` machine.

After the SSH session will load, execute the following commands:

```shell
$ sudo su - terraria
$ tmux attach -t terraria_server
Terraria Server v1.4.4.9

n               New World
d <number>      Delete World

Choose World: 
```

Server will prompt you to create a new world. Follow the prompt until it shows a similar message:

```
Terraria Server v1.4.4.9

Listening on port 7777
Type 'help' for a list of commands.

: Server started

```

Now you're good to go!. Press the following key sequence `Ctrl+b`, then `d`. Now you can close the SSH window and enjoy your Terraria server.