# Bastion Host Setup - Complete Guide

## What is a Bastion Host?

A **bastion host** (also called a jump box) is a special-purpose server that acts as a secure gateway to access your private resources (EC2 instances, RDS databases) that are not directly accessible from the internet.

## Architecture Overview

```
Internet
    ↓
[Bastion Host] ← SSH from your computer (port 22)
(Public Subnet)
    ↓
[Strapi EC2] ← SSH only from Bastion (port 22)
(Private Subnet)
    ↓
[RDS PostgreSQL] ← Connection from Strapi EC2 only
(Private Subnet)
```

## What Was Added

### 1. **bastion.tf** - Bastion Host EC2 Instance
- Small t2.micro instance in the public subnet
- Has an Elastic IP so the public IP doesn't change
- Includes PostgreSQL client and useful tools pre-installed
- Encrypted root volume for security

### 2. **bastion_sg.tf** - Bastion Security Group
- Allows SSH (port 22) from specified IP addresses
- By default allows from anywhere (0.0.0.0/0) - **CHANGE THIS IN PRODUCTION!**
- Allows all outbound traffic

### 3. **Updated ec2_sg.tf** - EC2 Security Group
- **Changed:** SSH now only allowed from Bastion host (not entire VPC)
- This ensures your Strapi server can ONLY be accessed via the bastion

### 4. **New Variables** - In variables.tf
- `bastion_instance_type` - Size of bastion (default: t2.micro)
- `bastion_allowed_cidrs` - IP addresses allowed to SSH to bastion

### 5. **New Outputs** - In outputs.tf
- `bastion_public_ip` - The public IP of your bastion host
- `ssh_to_bastion` - Command to SSH into bastion
- `ssh_to_strapi_via_bastion` - Command to SSH into Strapi via bastion (jump)
- `ssh_tunnel_command` - Command to create SSH tunnel

## How to Use the Bastion Host

### 1. SSH Directly to Bastion
```bash
ssh -i ~/.ssh/strapi_dev_key ec2-user@<BASTION_IP>
```

### 2. SSH to Strapi EC2 via Bastion (Jump Host)
```bash
# Using ProxyJump (modern way)
ssh -i ~/.ssh/strapi_dev_key -J ec2-user@<BASTION_IP> ec2-user@<STRAPI_PRIVATE_IP>
```

### 3. Create SSH Tunnel to Access Strapi Locally
```bash
# This creates a tunnel so you can access Strapi on localhost:1337
ssh -i ~/.ssh/strapi_dev_key -L 1337:<STRAPI_PRIVATE_IP>:1337 ec2-user@<BASTION_IP>

# Then open browser to: http://localhost:1337
```

### 4. Connect to RDS from Bastion
```bash
# SSH into bastion first
ssh -i ~/.ssh/strapi_dev_key ec2-user@<BASTION_IP>

# Then connect to RDS
psql -h <RDS_ENDPOINT> -U strapi_admin -d strapi_dev
```

## Security Best Practices

### 🔒 **CRITICAL: Restrict Bastion SSH Access**

In production, you should NEVER allow `0.0.0.0/0` for SSH access!

**Option 1: Your Home/Office IP**
```terraform
# In prod.tfvars or dev.tfvars
bastion_allowed_cidrs = ["203.0.113.45/32"]  # Your public IP
```

**Option 2: Multiple IPs (office, home, VPN)**
```terraform
bastion_allowed_cidrs = [
  "203.0.113.45/32",   # Office
  "198.51.100.10/32",  # Home
  "192.0.2.0/24"       # VPN range
]
```

**How to find your public IP:**
```bash
curl ifconfig.me
```

### 🔒 **Additional Security Measures**

1. **Use SSH Config File** (~/.ssh/config)
```
Host strapi-bastion
    HostName <BASTION_IP>
    User ec2-user
    IdentityFile ~/.ssh/strapi_dev_key
    ServerAliveInterval 60

Host strapi-app
    HostName <STRAPI_PRIVATE_IP>
    User ec2-user
    IdentityFile ~/.ssh/strapi_dev_key
    ProxyJump strapi-bastion
    ServerAliveInterval 60
```

Then simply use:
```bash
ssh strapi-bastion  # To access bastion
ssh strapi-app      # To access Strapi EC2
```

2. **Enable MFA for SSH** (Advanced)
   - Use AWS Systems Manager Session Manager instead
   - Integrate with Google Authenticator

3. **Audit and Logging**
   - Enable CloudTrail for all bastion activities
   - Set up CloudWatch Logs for SSH access logs
   - Monitor failed login attempts

## Cost Impact

### Bastion Host Costs (Approximate)
- **EC2 t2.micro**: ~$8.50/month (us-east-1)
- **Elastic IP**: Free while attached to running instance
- **Data Transfer**: Minimal (SSH traffic is tiny)

**Total additional cost: ~$8-10/month**

## Troubleshooting

### Can't SSH to Bastion
1. Check security group allows your IP:
   ```bash
   curl ifconfig.me  # Get your current IP
   ```
2. Verify bastion_allowed_cidrs includes your IP
3. Ensure key permissions are correct:
   ```bash
   chmod 600 ~/.ssh/strapi_dev_key
   ```

### Can't SSH from Bastion to Strapi EC2
1. Verify bastion security group allows outbound traffic
2. Verify EC2 security group allows inbound from bastion SG
3. Check if Strapi EC2 is running:
   ```bash
   aws ec2 describe-instances --instance-ids <INSTANCE_ID>
   ```

### Connection Times Out
1. Check NACL rules (if configured)
2. Verify route tables are correct
3. Ensure NAT Gateway is working for private subnet

## Alternative: AWS Systems Manager Session Manager

If you don't want to manage bastion hosts, consider **AWS Systems Manager Session Manager**:

### Advantages
- No bastion host needed (saves $8-10/month)
- No SSH keys to manage
- Full audit logging
- Works with IAM permissions
- No public IP exposure

### How to Enable
1. Add IAM role to EC2 instances with SSM permissions
2. Install SSM agent (pre-installed on Amazon Linux 2023)
3. Connect via AWS Console or CLI:
   ```bash
   aws ssm start-session --target <INSTANCE_ID>
   ```

**Would you like me to add SSM configuration as well?**

## Summary

✅ **What You Get:**
- Secure SSH access to private EC2 instances
- Jump host capability
- SSH tunneling for local development
- Pre-installed tools (psql, htop, nc)
- Elastic IP (doesn't change on restart)
- Enhanced security (private instances not exposed)

✅ **What You Need to Do:**
1. Deploy with Terraform
2. Get the bastion IP from outputs
3. Restrict `bastion_allowed_cidrs` to your IP
4. Use SSH commands from outputs to access resources

✅ **Deployment Commands:**
```bash
# Plan
terraform plan -var-file=dev.tfvars

# Apply
terraform apply -var-file=dev.tfvars

# Get bastion IP
terraform output bastion_public_ip

# Get all connection commands
terraform output ssh_to_bastion
terraform output ssh_to_strapi_via_bastion
```

---

**Need help with anything else regarding the bastion setup?**

