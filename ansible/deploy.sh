
#!/bin/bash

INSTANCE_NAME="k3s-instance"

# Get the public IP address
IP_ADDRESS=$(ansible-inventory -i aws_ec2.yaml --list | jq -r --arg INSTANCE_NAME "$INSTANCE_NAME" '._meta.hostvars[$INSTANCE_NAME].network_interfaces[0].association.public_ip')

# Check if the IP address was found
if [ "$IP_ADDRESS" == "null" ] || [ -z "$IP_ADDRESS" ]; then
    echo "No instance found with name: $INSTANCE_NAME or it has no public IP."
    exit 1
else
    echo "The public IP address of $INSTANCE_NAME is $IP_ADDRESS"
fi

# Copy Ansible contents to remote machine
scp -i ~/.ssh/my-key -r /home/ahmedkhalid/DEPI-DevOps-Project/ansible/* ubuntu@$IP_ADDRESS:/home/ubuntu/

scp -i ~/.ssh/my-key -r /home/ahmedkhalid/.ssh/my-key ubuntu@$IP_ADDRESS:/home/ubuntu/.ssh/

# SSH into the remote machine and run the Ansible playbook
ssh -i ~/.ssh/my-key ubuntu@$IP_ADDRESS 'source /home/ubuntu/env.sh && ansible-playbook /home/ubuntu/setup.yaml'
