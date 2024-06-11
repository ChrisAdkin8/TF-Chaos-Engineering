# Overview

This Terraform config creates and EC2 instance with a gremlin agent installed which it then registers with the gremlin control plane.

# Instructions

1. Create a terraform.tfvars file as follows, substitute your gremlin team id and gremlin team secret as appropriate:
```
gremlin_team_id     = "<Your team id goes here>"
gremlin_team_secret = "<Your team secret goes here>"
```

2. Specify environment variables for connecting to your AWS account, note that the last two environment variables are only required if you are using session tokens:
```
export AWS_ACCESS_KEY_ID=<Your AWS Access Key Id goes here>
export AWS_SECRET_ACCESS_KEY=<Your AWS Access Key Secret goes here>
export AWS_SESSION_TOKEN=<Your AWS session token goes here>
export AWS_SESSION_EXPIRATION=<Your AWS token session date/time expiry goes here>
```

3. In the directory containing the config, issue:
```
terraform init
```

4. In the directory containing the config, issue:
```
terraform apply -auto-approve
```

5. Note the text of the terraform apply output and use the ssh command for ssh'ing into your EC2 instance:
```
Apply complete! Resources: 11 added, 0 changed, 0 destroyed.

Outputs:

ssh_command = <<EOT
ssh -i id_rsa.pem ubuntu@44.192.16.145

EOT
```

6. Your EC2 instance may not register with the gremlin control plane instantaneously due to the fact that the cloudinit process has to complete in order for this to happen,
   however, once everything is ready the status of the gremlind system unit should looks something like this, note the line in the output containing:

**[INFO] gremlind::daemon - Successfully registered Gremlin daemon with control plane**
```
   ubuntu@ip-172-31-85-162:~$ systemctl status gremlind
● gremlind.service - Gremlin Daemon
     Loaded: loaded (/etc/systemd/system/gremlind.service; enabled; preset: enabled)
     Active: active (running) since Tue 2024-06-11 07:48:31 UTC; 18min ago
   Main PID: 2411 (gremlind)
      Tasks: 8 (limit: 1130)
     Memory: 14.0M (peak: 17.5M)
        CPU: 413ms
     CGroup: /system.slice/gremlind.service
             └─2411 /usr/sbin/gremlind

Jun 11 07:48:37 ip-172-31-85-162 gremlind[2411]: 2024-06-11 07:48:37 [WARN] gremlin_common::client::metadata::cloud::aws - Unable to describe AWS tags.  The error message is: No such file or directory (os error 2)
Jun 11 07:48:37 ip-172-31-85-162 gremlind[2411]: 2024-06-11 07:48:37 [INFO] gremlin_common::client::metadata::cloud - Azure metadata may be present
Jun 11 07:48:37 ip-172-31-85-162 gremlind[2411]: 2024-06-11 07:48:37 [INFO] gremlind::daemon - Daemon has credentials and needs a session, perform auth
Jun 11 07:48:38 ip-172-31-85-162 gremlind[2411]: 2024-06-11 07:48:38 [INFO] gremlind::daemon - Successfully registered Gremlin daemon with control plane
Jun 11 07:48:38 ip-172-31-85-162 gremlind[2411]: 2024-06-11 07:48:38 [INFO] gremlind::daemon - Running validation checks
Jun 11 07:48:41 ip-172-31-85-162 gremlind[2411]: 2024-06-11 07:48:41 [INFO] gremlind::daemon - Validating host CPU
Jun 11 07:48:41 ip-172-31-85-162 gremlind[2411]: Finished successfully
Jun 11 07:48:41 ip-172-31-85-162 gremlind[2411]: Validating host Latency
Jun 11 07:48:41 ip-172-31-85-162 gremlind[2411]: Finished successfully
Jun 11 07:48:41 ip-172-31-85-162 gremlind[2411]: 2024-06-11 07:48:41 [INFO] gremlin_pcap::thread - dependency_discovery: monitoring network interface `any` for DNS resolutions
```
