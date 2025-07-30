
# Terraform CI/CD: EFS with Cost Estimation & Manual Approval

This project automates the creation of:

- An Amazon EFS file system
- VPC and subnet integration
- Auto-mount EFS to EC2 (optional)
- Terraform + GitHub Actions with cost visibility and manual approval

---

## What It Deploys

### Amazon EFS
- Shared file system
- Auto-scaling, high-availability
- Multi-AZ support via mount targets

### S3 Bucket
- Stores Terraform remote state
- Auto-created if not existing

---

## How It Works

GitHub Actions workflow triggers on push to `main`:
- Runs `terraform init`, `terraform plan`
- Displays cost summary via Infracost
- Waits for manual approval via GitHub Environments
- On approval, runs `terraform apply`

---

## Steps to Use This Project

### 1. Clone the Repo

```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>
```

### 2. Set Up GitHub Secrets

Go to `Settings → Secrets → Actions`, add:

| Name                  | Value              |
|-----------------------|--------------------|
| AWS_ACCESS_KEY_ID     | Your AWS access key |
| AWS_SECRET_ACCESS_KEY | Your AWS secret key |

These credentials must allow access to manage EFS, VPC, and S3.

---

### 3. Add Collaborators

Go to `Settings → Collaborators → Invite collaborator`, enter GitHub usernames and set permissions (Write/Admin).

---

### 4. Add GitHub Environment for Manual Approval

Go to `Settings → Environments`, create `dev-approval`, and add yourself or team members under **Required reviewers**.

---

### 5. Push Code

```bash
git add .
git commit -m "initial commit"
git push origin main
```

This triggers GitHub Actions CI/CD pipeline.

---

## Folder Structure

```
.
├── main.tf               # EFS + Mount Targets
├── provider.tf           # AWS provider config
├── variables.tf          # Inputs: VPC, Subnets, etc.
├── outputs.tf            # EFS ID, Mount Targets, etc.
├── backend.tf            # S3 backend
├── environments/
│   ├── dev.tfvars
├── terraform.tfvars      # Default values (optional)
└── .github/workflows/
    └── terraform.yml     # CI/CD pipeline
```

---

## Architecture Diagram

```
GitHub Repo
   |
   ▼ (Push to main)
GitHub Actions CI/CD
   ├── terraform init
   ├── terraform plan     → Infracost cost summary
   ├── wait for approval  → dev-approval env
   └── terraform apply
        ├── Creates EFS
        ├── Creates Mount Targets (subnets)
        └── Configures Security Groups

AWS Infrastructure:
   ┌────────────┐
   │   EC2s     │
   └────┬───────┘
        │ (optional mount)
   ┌────▼───────┐
   │    EFS     │
   └────────────┘
```

---

## Estimated Monthly Costs

| Resource       | Amount      | Approx Cost      |
|----------------|-------------|------------------|
| EFS Storage    | 10 GB       | ~$0.30/month     |
| EFS Throughput | Burst mode  | Included         |
| Mount Targets  | 2 targets   | ~$0.60/month     |

**Total Estimate:** ~$0.90/month  
*Estimates vary based on actual usage.*

---

## Cleanup

To destroy all infrastructure:
```bash
terraform destroy -var-file="environments/dev.tfvars"
```

---

## Troubleshooting

- **Permission Denied**: Ensure AWS credentials have access to EFS, EC2, VPC
- **Missing Subnets**: Double-check `subnet_ids` in `terraform.tfvars`
- **VPC errors**: Confirm correct `vpc_id`


---

##  Cost Estimation with Infracost

We use [Infracost](https://www.infracost.io/) to estimate monthly AWS costs based on Terraform configurations.

### How Infracost Works

1. `terraform plan` is executed and converted to JSON
2. `infracost breakdown` analyzes the plan and estimates costs
3. Output is shown in the GitHub Actions summary and stored as a downloadable report

---

### How to Get an Infracost API Key

1. Go to [https://dashboard.infracost.io](https://dashboard.infracost.io)
2. Sign up with GitHub or email
3. Copy your **API key** from the dashboard

---

###  How to Set Up Infracost in GitHub

1. **Create a secret** in your GitHub repository:
   - Navigate to `Settings → Secrets → Actions`
   - Add:

     | Name                | Value                    |
     |---------------------|--------------------------|
     | `INFRACOST_API_KEY` | your copied API token    |

2. **Verify your GitHub workflow includes these steps:**

```yaml
- name: Setup Infracost
  uses: infracost/actions/setup@v2.1.0
  with:
    api-key: ${{ secrets.INFRACOST_API_KEY }}

- name: Generate Plan JSON
  run: terraform show -json tfplan > plan.json

- name: Run Infracost Breakdown
  run: |
    infracost breakdown \
      --path=plan.json \
      --format=table \
      --out-file=infracost-report.txt

- name: Upload Infracost Report
  uses: actions/upload-artifact@v4
  with:
    name: infracost-report
    path: infracost-report.txt

- name: Show Infracost Cost Summary
  run: |
    echo "##  Infracost Estimate Summary" >> $GITHUB_STEP_SUMMARY
    cat infracost-report.txt >> $GITHUB_STEP_SUMMARY
```

This will ensure cost visibility is included in every pull request or commit to `main`.

---

