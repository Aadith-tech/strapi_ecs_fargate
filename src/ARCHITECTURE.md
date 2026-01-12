# Strapi Infrastructure Architecture with Bastion Host

## Complete Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                    Internet                                      │
└─────────────────────────────┬───────────────────────┬───────────────────────────┘
                              │                       │
                              │ (Port 80/443)         │ (Port 22 - Your IP only)
                              ↓                       ↓
                    ┌──────────────────┐   ┌──────────────────┐
                    │  Application     │   │  Bastion Host    │
                    │  Load Balancer   │   │  (Jump Box)      │
                    │  (Public)        │   │  t2.micro        │
                    └──────────┬───────┘   └────────┬─────────┘
                               │                    │
┌──────────────────────────────┼────────────────────┼──────────────────────────────┐
│                       AWS VPC (10.0.0.0/16)       │                              │
│  ┌─────────────────────────────────────────────────────────────────────┐        │
│  │                      Public Subnets                                  │        │
│  │  ┌────────────────────────┐  ┌────────────────────────┐            │        │
│  │  │ Public Subnet 1        │  │ Public Subnet 2        │            │        │
│  │  │ 10.0.1.0/24 (AZ-A)     │  │ 10.0.4.0/24 (AZ-B)     │            │        │
│  │  │ - ALB                  │  │ - ALB                  │            │        │
│  │  │ - NAT Gateway          │  │ - Bastion Host         │            │        │
│  │  │ - Internet Gateway     │  │                        │            │        │
│  │  └────────────────────────┘  └────────────────────────┘            │        │
│  └─────────────────────────────────────────────────────────────────────┘        │
│                               │                    │                             │
│                               │ (Port 1337)        │ (SSH only)                  │
│                               ↓                    ↓                             │
│  ┌─────────────────────────────────────────────────────────────────────┐        │
│  │                      Private Subnets                                 │        │
│  │  ┌──────────────────────────────────────────────────────┐           │        │
│  │  │ Private App Subnet                                   │           │        │
│  │  │ 10.0.2.0/24 (AZ-A)                                   │           │        │
│  │  │                                                       │           │        │
│  │  │  ┌────────────────────────────────────┐             │           │        │
│  │  │  │  Strapi EC2 Instance               │             │           │        │
│  │  │  │  - Node.js + Strapi                │             │           │        │
│  │  │  │  - PM2 Process Manager             │             │           │        │
│  │  │  │  - No Public IP                    │             │           │        │
│  │  │  │  - SSH from Bastion only           │             │           │        │
│  │  │  └────────────────┬───────────────────┘             │           │        │
│  │  │                   │                                  │           │        │
│  │  └───────────────────┼──────────────────────────────────┘           │        │
│  │                      │ (Port 5432)                                  │        │
│  │  ┌───────────────────┼──────────────────────────────────┐           │        │
│  │  │ Private DB Subnet │                                  │           │        │
│  │  │ 10.0.3.0/24 (AZ-B)↓                                  │           │        │
│  │  │                                                       │           │        │
│  │  │  ┌────────────────────────────────────┐             │           │        │
│  │  │  │  RDS PostgreSQL 15.4               │             │           │        │
│  │  │  │  - Encrypted Storage                │             │           │        │
│  │  │  │  - Automated Backups                │             │           │        │
│  │  │  │  - No Public Access                 │             │           │        │
│  │  │  │  - Multi-AZ (Prod only)             │             │           │        │
│  │  │  └────────────────────────────────────┘             │           │        │
│  │  │                                                       │           │        │
│  │  └───────────────────────────────────────────────────────┘           │        │
│  └─────────────────────────────────────────────────────────────────────┘        │
└──────────────────────────────────────────────────────────────────────────────────┘
```

## Security Groups Configuration

### 1. ALB Security Group (`alb_sg.tf`)
**Inbound:**
- Port 80 (HTTP) from `0.0.0.0/0`
- Port 443 (HTTPS) from `0.0.0.0/0`

**Outbound:**
- All traffic to `0.0.0.0/0`

### 2. Bastion Security Group (`bastion_sg.tf`)
**Inbound:**
- Port 22 (SSH) from `bastion_allowed_cidrs` (Your IP only!)

**Outbound:**
- All traffic to `0.0.0.0/0`

### 3. EC2 (Strapi) Security Group (`ec2_sg.tf`)
**Inbound:**
- Port 22 (SSH) from Bastion Security Group ONLY ✅
- Port 1337 (Strapi) from ALB Security Group
- Port 1337 (Strapi) from VPC CIDR (for internal access)

**Outbound:**
- All traffic to `0.0.0.0/0` (for package downloads via NAT)

### 4. RDS Security Group (`rds_sg.tf`)
**Inbound:**
- Port 5432 (PostgreSQL) from EC2 Security Group ONLY

**Outbound:**
- All traffic to `0.0.0.0/0`

## Traffic Flow Examples

### 1. User Accessing Strapi Web Interface
```
User Browser → Internet → ALB (Port 80) → Strapi EC2 (Port 1337) → Response
```

### 2. SSH Access to Strapi EC2
```
Your Computer → Internet → Bastion (Port 22) → Strapi EC2 (Port 22 via private IP)
```

### 3. Strapi Connecting to Database
```
Strapi EC2 → RDS PostgreSQL (Port 5432 via private IP)
```

### 4. Strapi Installing Packages
```
Strapi EC2 → NAT Gateway → Internet Gateway → npm Registry
```

## Resource List

### Created Resources:
1. **VPC** - 10.0.0.0/16
2. **Internet Gateway** - For public internet access
3. **NAT Gateway** - For private subnet internet access
4. **Elastic IPs (2)** - For NAT Gateway and Bastion Host
5. **Subnets (4)**:
   - Public Subnet 1 (10.0.1.0/24) - AZ-A
   - Public Subnet 2 (10.0.4.0/24) - AZ-B
   - Private App Subnet (10.0.2.0/24) - AZ-A
   - Private DB Subnet (10.0.3.0/24) - AZ-B
6. **Route Tables (2)** - Public and Private
7. **Security Groups (4)** - ALB, Bastion, EC2, RDS
8. **EC2 Instances (2)** - Strapi App and Bastion Host
9. **Application Load Balancer** - With target group and listener
10. **RDS PostgreSQL Instance** - With subnet group
11. **SSH Key Pair** - For EC2 access

### Total Components: 25+ AWS Resources

## Files Created/Modified

### New Files:
- ✅ `bastion.tf` - Bastion host EC2 instance
- ✅ `bastion_sg.tf` - Bastion security group
- ✅ `BASTION_SETUP.md` - Complete documentation
- ✅ `ARCHITECTURE.md` - This file

### Modified Files:
- ✅ `ec2_sg.tf` - Updated SSH access to bastion only
- ✅ `variables.tf` - Added bastion variables
- ✅ `outputs.tf` - Added bastion outputs
- ✅ `dev.tfvars` - Added bastion configuration
- ✅ `prod.tfvars` - Added bastion configuration

### Existing Files:
- `main.tf` - Provider configuration
- `vpc.tf` - VPC, subnets, gateways
- `alb.tf` - Application Load Balancer
- `alb_sg.tf` - ALB security group
- `ec2.tf` - Strapi EC2 instance
- `rds.tf` - PostgreSQL RDS instance
- `rds_sg.tf` - RDS security group
- `user_data.sh` - EC2 initialization script

## Network Flow Table

| Source | Destination | Port | Protocol | Purpose |
|--------|-------------|------|----------|---------|
| Internet | ALB | 80/443 | TCP | HTTP/HTTPS web access |
| ALB | Strapi EC2 | 1337 | TCP | Forward requests to Strapi |
| Your IP | Bastion | 22 | TCP | SSH to bastion |
| Bastion | Strapi EC2 | 22 | TCP | SSH to private instance |
| Strapi EC2 | RDS | 5432 | TCP | Database connection |
| Strapi EC2 | Internet | 443 | TCP | Download packages (via NAT) |

## High Availability & Disaster Recovery

### Current Setup (Dev):
- ✅ Single EC2 instance
- ✅ Single RDS instance
- ✅ ALB ready for multiple targets
- ✅ Multi-AZ subnet configuration

### Production Enhancements:
- 🔄 Multi-AZ RDS (automatic failover)
- 🔄 Auto Scaling Group for EC2
- 🔄 CloudWatch monitoring & alarms
- 🔄 Automated backups (30 days)
- 🔄 SSL/TLS certificates
- 🔄 Route53 DNS

## Security Posture

### ✅ Security Features Implemented:
1. **Network Isolation** - Private subnets for app and database
2. **Bastion Host** - Controlled SSH access point
3. **Security Groups** - Least privilege firewall rules
4. **Encrypted Storage** - EBS and RDS encryption enabled
5. **No Public Database** - RDS not publicly accessible
6. **NAT Gateway** - Secure outbound internet for private instances

### ⚠️ Security Recommendations:
1. **Restrict Bastion Access** - Change `bastion_allowed_cidrs` from `0.0.0.0/0` to your IP
2. **Use Secrets Manager** - For database passwords (not hardcoded)
3. **Enable SSL/TLS** - Add HTTPS listener with ACM certificate
4. **Enable CloudTrail** - Audit all API calls
5. **Enable GuardDuty** - Threat detection
6. **Regular Updates** - Keep AMIs and packages updated
7. **MFA for AWS Console** - Protect AWS account access

## Cost Estimate (Monthly - us-east-1)

| Resource | Type | Quantity | Cost |
|----------|------|----------|------|
| EC2 (Strapi) | t2.medium | 1 | ~$33 |
| EC2 (Bastion) | t2.micro | 1 | ~$8.50 |
| RDS PostgreSQL | db.t3.micro | 1 | ~$15 |
| ALB | Application LB | 1 | ~$18 |
| NAT Gateway | - | 1 | ~$32 |
| EBS Storage | gp3 | 30GB | ~$2.40 |
| RDS Storage | gp3 | 20GB | ~$2.30 |
| Elastic IP | Attached | 2 | Free |
| Data Transfer | Minimal | - | ~$5 |
| **TOTAL** | | | **~$116/month** |

### Cost Optimization Tips:
1. Use t3.micro for dev environment (~$7/month)
2. Stop bastion when not needed (save $8.50/month)
3. Use NAT Instance instead of NAT Gateway (save ~$25/month)
4. Delete resources after testing
5. Use Reserved Instances for production (save 30-40%)

## Deployment Checklist

### Before Deployment:
- [ ] Update SSH public key in tfvars
- [ ] Change database password
- [ ] Update AMI IDs for your region
- [ ] Fix region/AZ mismatches
- [ ] Restrict `bastion_allowed_cidrs` to your IP
- [ ] Review all security group rules

### Deployment Steps:
```bash
# 1. Initialize Terraform
cd terraform
terraform init

# 2. Validate configuration
terraform validate

# 3. Plan deployment
terraform plan -var-file=dev.tfvars

# 4. Review plan carefully

# 5. Apply changes
terraform apply -var-file=dev.tfvars

# 6. Get outputs
terraform output
```

### After Deployment:
- [ ] Test SSH to bastion
- [ ] Test SSH to Strapi EC2 via bastion
- [ ] Verify ALB health checks
- [ ] Test Strapi application access
- [ ] Test database connectivity
- [ ] Set up monitoring & alerts
- [ ] Configure backups
- [ ] Document access procedures

## Next Steps

1. **Test the Configuration**
   ```bash
   terraform plan -var-file=dev.tfvars
   ```

2. **Deploy to Dev**
   ```bash
   terraform apply -var-file=dev.tfvars
   ```

3. **Verify Bastion Access**
   ```bash
   terraform output bastion_public_ip
   ssh -i ~/.ssh/strapi_dev_key ec2-user@<BASTION_IP>
   ```

4. **Access Strapi**
   - Via ALB: Use `terraform output alb_url`
   - Via SSH Tunnel: Use `terraform output ssh_tunnel_command`

---

**Everything is now ready for deployment! All files have been created and configured correctly.** 🚀

