# Run SFTP server in kubernetes
- GKE 1.21.x Dataplane V2
- Connection incoming and outgoing to pods sftp only allow to spesific IP public via NetworkPolicy
- Bank or oldschool system government still use SFTP not oject storage like GCS or S3 via API

### Create IP Public Region for Loadbalancer SFTP
```
gcloud compute addresses create production-sftp --project=zeus-cloud-329503 --region=asia-southeast1
```
### Add publickey server or user need access sftp to docker-config/authorized_keys

### Create key for docker sftp server ###
```
cd docker-config
ssh-keygen -t dsa -f ssh_host_ecdsa_key < /dev/null
ssh-keygen -t ed25519 -f ssh_host_ed25519_key < /dev/null
ssh-keygen -t rsa -b 2048 -f ssh_host_rsa_key < /dev/null
```

### Build Docker images
```
docker build --no-cache -t zeus-sftp .
docker tag zeus-sftp asia.gcr.io/zeus-cloud-329503/zeus-sftp:v1
docker push asia.gcr.io/zeus-cloud-329503/zeus-sftp:v1
```


### Run only 1 time for fix permission folder
```
kubectl exec -it -n production-external production-sftp-zeus-77d6c7d9dd-5l442 -- /bin/bash

cd /home/sftp_zeus/
chown sftp_zeus:sftp_zeus -R data/
```

### Test connect and make sure config sftp correct
```
sftp -P 4848 sftp_zeus@34.124.237.19

sftp> cd /home
Couldn't stat remote file: No such file or directory

sftp> pwd
Remote working directory: /

sftp> ls
crontab-sftp.txt    data

sftp> cd /etc
Couldn't stat remote file: No such file or directory
```
#### Test ssh
```
ssh -p 4848 sftp_zeus@34.124.237.19
This service allows sftp connection only
connection to 34.124.237.19 closed.
```

### Optional restrict delete or remove or rename permission
edit sshd_config
```
subsystem sftp internal-sftp -P remove,rmdir,rename,posix-rename

ForceCommand internal-sftp  -P remove,rmdir,rename,posix-rename
```


### Convert private key to .ppk di local laptop for access sftp server with sftp client (filezila)
```
sudo apt-get install putty-tools
```

### SFTP Audit
```
git clone https://github.com/arthepsy/ssh-audit.git
cd ssh-audit/
```
#### Edit port
```
nano ssh-audit.py
oport, port = '4848', 4848
```
```
python ssh-audit.py 34.124.237.19
```
![alt text](https://i.imgur.com/m9tVIX8.png)
