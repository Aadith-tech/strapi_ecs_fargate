# SSH Access Guide - Step by Step

## ✅ Your Configuration is CORRECT!

Here's exactly how SSH access works with your bastion host:

---

## 🔐 Security Configuration

### ✅ Bastion Security Group (`bastion_sg.tf`)
**Allows:**
- ✅ SSH (port 22) FROM your IP address → TO Bastion
- ✅ All outbound traffic FROM Bastion → TO anywhere

### ✅ EC2 (Strapi) Security Group (`ec2_sg.tf`)
**Allows:**
- ✅ SSH (port 22) FROM Bastion Security Group ONLY → TO Strapi EC2
- ✅ Port 1337 FROM ALB → TO Strapi EC2
- ✅ All outbound traffic

### 🔒 What This Means:
- You **CAN** SSH to Bastion from your computer ✅
- You **CAN** SSH from Bastion to Strapi EC2 ✅
- You **CANNOT** SSH directly to Strapi EC2 from internet ❌ (Good! This is secure!)
- Both use the **SAME SSH KEY** (simpler for testing) ✅

---

## 📋 Step-by-Step SSH Access

### Method 1: Two-Step SSH (Manual)

#### Step 1: SSH to Bastion
```bash
ssh -i ~/.ssh/strapi_dev_key ec2-user@<BASTION_PUBLIC_IP>
```

You're now on the bastion host!

#### Step 2: From Bastion, SSH to Strapi EC2
```bash
# You're now ON the bastion host, run this:
ssh -i ~/.ssh/strapi_dev_key ec2-user@<STRAPI_PRIVATE_IP>
```

**Problem with this method:** You need to copy your private key to the bastion host (NOT RECOMMENDED for security!)

---

### Method 2: ProxyJump (Recommended - One Command)

This is the **BEST** way! SSH directly to Strapi EC2 through bastion in ONE command:

```bash
ssh -i ~/.ssh/strapi_dev_key -J ec2-user@<BASTION_PUBLIC_IP> ec2-user@<STRAPI_PRIVATE_IP>
```

**How it works:**
1. SSH connects to bastion
2. SSH automatically jumps through bastion to Strapi EC2
3. Your private key stays on your computer (secure!)
4. All in ONE command!

---

### Method 3: SSH Config File (Most Convenient)

Create/edit `~/.ssh/config`:

```
# Bastion Host
Host strapi-bastion
    HostName <BASTION_PUBLIC_IP>
    User ec2-user
    IdentityFile ~/.ssh/strapi_dev_key
    ServerAliveInterval 60

# Strapi EC2 via Bastion
Host strapi-app
    HostName <STRAPI_PRIVATE_IP>
    User ec2-user
    IdentityFile ~/.ssh/strapi_dev_key
    ProxyJump strapi-bastion
    ServerAliveInterval 60
```

**Then simply use:**
```bash
ssh strapi-bastion   # Connect to bastion
ssh strapi-app       # Connect to Strapi EC2 through bastion
```

---

## 🚀 After Deployment

After you run `terraform apply`, get the IPs:

```bash
# Get bastion public IP
terraform output bastion_public_ip

# Get Strapi private IP
terraform output ec2_private_ip

# Get ready-to-use SSH commands
terraform output ssh_to_bastion
terraform output ssh_to_strapi_via_bastion
```

---

## 🔍 Complete Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                       Your Computer                              │
│  (Has: ~/.ssh/strapi_dev_key - private key)                     │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     │ SSH Port 22
                     │ (Your IP allowed by bastion_allowed_cidrs)
                     │
                     ↓
┌─────────────────────────────────────────────────────────────────┐
│                    Internet Gateway                              │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────────┐
│  Bastion Host (Public Subnet)                                   │
│  ┌────────────────────────────────────────────────────┐         │
│  │ Public IP: <ELASTIC_IP>                            │         │
│  │ Security Group: bastion-sg                          │         │
│  │ Key: strapi_dev_key                                │         │
│  │                                                     │         │
│  │ ✅ Accepts SSH from your IP                         │         │
│  │ ✅ Can SSH out to private instances                 │         │
│  └────────────────────────────────────────────────────┘         │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     │ SSH Port 22
                     │ (Via internal VPC routing)
                     │
                     ↓
┌─────────────────────────────────────────────────────────────────┐
│  Strapi EC2 (Private Subnet)                                    │
│  ┌────────────────────────────────────────────────────┐         │
│  │ Private IP: 10.0.2.x                               │         │
│  │ NO Public IP                                        │         │
│  │ Security Group: ec2-sg                              │         │
│  │ Key: strapi_dev_key (same key)                     │         │
│  │                                                     │         │
│  │ ✅ Accepts SSH from bastion-sg ONLY                 │         │
│  │ ❌ NO direct SSH from internet                      │         │
│  │ ✅ Strapi app running on port 1337                  │         │
│  └────────────────────────────────────────────────────┘         │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📝 Real Example

Let's say after deployment you get:
- Bastion IP: `54.123.45.67`
- Strapi Private IP: `10.0.2.100`

### Option 1: Direct ProxyJump
```bash
ssh -i ~/.ssh/strapi_dev_key -J ec2-user@54.123.45.67 ec2-user@10.0.2.100
```

### Option 2: Two Steps
```bash
# Step 1
ssh -i ~/.ssh/strapi_dev_key ec2-user@54.123.45.67

# Step 2 (from bastion)
ssh ec2-user@10.0.2.100
```

### Option 3: With SSH Config
```bash
# Add to ~/.ssh/config
Host strapi-bastion
    HostName 54.123.45.67
    User ec2-user
    IdentityFile ~/.ssh/strapi_dev_key

Host strapi-app
    HostName 10.0.2.100
    User ec2-user
    IdentityFile ~/.ssh/strapi_dev_key
    ProxyJump strapi-bastion

# Then just use:
ssh strapi-app
```

---

## 🛠️ Common Tasks via Bastion

### Check Strapi Logs
```bash
ssh -i ~/.ssh/strapi_dev_key -J ec2-user@<BASTION_IP> ec2-user@<STRAPI_IP>
sudo su - strapi -c "pm2 logs"
```

### Restart Strapi
```bash
ssh -i ~/.ssh/strapi_dev_key -J ec2-user@<BASTION_IP> ec2-user@<STRAPI_IP>
sudo su - strapi -c "pm2 restart all"
```

### Connect to Database from Bastion
```bash
# SSH to bastion
ssh -i ~/.ssh/strapi_dev_key ec2-user@<BASTION_IP>

# Then connect to RDS (psql is pre-installed)
psql -h <RDS_ENDPOINT> -U strapi_admin -d strapi_dev
# Password: Aadith@123
```

### Create SSH Tunnel for Strapi Web Access
```bash
# This maps localhost:1337 to Strapi EC2:1337
ssh -i ~/.ssh/strapi_dev_key -L 1337:<STRAPI_IP>:1337 ec2-user@<BASTION_IP>

# Keep this terminal open, then open browser to:
http://localhost:1337
http://localhost:1337/admin
```

---

## ✅ Security Verification Checklist

After deployment, verify:

- [ ] You CAN SSH to bastion from your computer
- [ ] You CAN SSH from bastion to Strapi EC2
- [ ] You CANNOT directly SSH to Strapi EC2 from internet (should timeout)
- [ ] Bastion has Elastic IP (doesn't change on restart)
- [ ] EC2 security group only allows SSH from bastion-sg
- [ ] Bastion security group only allows SSH from your IP (change from 0.0.0.0/0!)

---

## 🔧 Troubleshooting

### "Permission denied (publickey)"
```bash
# Make sure key has correct permissions
chmod 600 ~/.ssh/strapi_dev_key

# Verify you're using the right key
ssh-keygen -l -f ~/.ssh/strapi_dev_key.pub
```

### "Connection timed out"
1. Check bastion security group allows your current IP
2. Get your current IP: `curl ifconfig.me`
3. Update `bastion_allowed_cidrs` in dev.tfvars if needed

### Can't SSH from bastion to Strapi EC2
1. Verify bastion can reach private subnet
2. Check EC2 security group allows bastion-sg
3. Verify Strapi EC2 is running:
   ```bash
   aws ec2 describe-instances --filters "Name=tag:Name,Values=dev-strapi-instance"
   ```

---

## 🎯 Summary

✅ **Your setup is CORRECT!**

**Access Flow:**
1. You SSH to Bastion (public IP) with your key
2. Bastion SSHs to Strapi EC2 (private IP) with same key
3. Strapi EC2 security group ONLY allows SSH from Bastion

**Why This is Secure:**
- Strapi EC2 has NO public IP
- Strapi EC2 ONLY accepts SSH from Bastion
- Bastion can be restricted to YOUR IP only
- Single point of controlled access

**Best Practice:**
Use ProxyJump (Method 2) or SSH Config (Method 3) - your private key never leaves your computer!

---

**Ready to deploy? Run `terraform apply -var-file=dev.tfvars` and start testing!** 🚀

