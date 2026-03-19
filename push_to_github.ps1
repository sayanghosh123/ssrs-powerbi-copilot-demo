# push_to_github.ps1
# Run this from PowerShell to initialise the git repo and push to GitHub
# Requirements: git and gh (GitHub CLI) must be installed
#   winget install GitHub.cli
#   gh auth login

$repoName = "ssrs-powerbi-copilot-demo"
$owner    = "sayanghosh123"
$demoDir  = "C:\Code\demo\ssrs-powerbi-copilot-demo"

Set-Location $demoDir

# 1. Initialise git
git init
git branch -M main

# 2. Stage all files
git add .

# 3. Commit
git commit -m "feat: SSRS to Power BI migration demo - Copilot-driven agentic approach

- 3 SSRS sample reports (RDL) with shared datasets (RSD) and data source (RDS)
- SQLite + Azure SQL database setup scripts with AdventureWorks seed data
- Power Query M scripts for all 3 reports (SSRS SQL → Power BI)
- DAX measure files for all 3 reports
- Report layout specifications (SSRS feature → Power BI mapping)
- Self-guided README and QUICKSTART for public repo consumers

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"

# 4. Create public repo and push
gh repo create "$owner/$repoName" `
    --public `
    --description "Copilot-driven agentic SSRS to Power BI migration demo using AdventureWorks" `
    --source . `
    --remote origin `
    --push

Write-Host ""
Write-Host "Done! Repo live at: https://github.com/$owner/$repoName" -ForegroundColor Green
