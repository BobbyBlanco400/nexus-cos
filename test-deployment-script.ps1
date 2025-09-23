# Nexus COS Deployment Script Test Suite
# This script validates the deployment scripts and configurations

param(
    [switch]$SkipSyntaxCheck,
    [switch]$SkipConfigValidation,
    [switch]$SkipDryRun,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

if ($Verbose) {
    $VerbosePreference = "Continue"
}

# Color output functions
function Write-TestHeader {
    param([string]$Title)
    Write-Host ""
    Write-Host "================================" -ForegroundColor Magenta
    Write-Host $Title -ForegroundColor Magenta
    Write-Host "================================" -ForegroundColor Magenta
    Write-Host ""
}

function Write-TestStep {
    param([string]$Message)
    Write-Host "➤ $Message" -ForegroundColor Blue
}

function Write-TestSuccess {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-TestWarning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-TestError {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

# Test results tracking
$script:TestResults = @{
    Passed = 0
    Failed = 0
    Warnings = 0
    Tests = @()
}

function Add-TestResult {
    param(
        [string]$TestName,
        [string]$Status,
        [string]$Message = ""
    )
    
    $script:TestResults.Tests += @{
        Name = $TestName
        Status = $Status
        Message = $Message
        Timestamp = Get-Date
    }
    
    switch ($Status) {
        "PASS" { $script:TestResults.Passed++ }
        "FAIL" { $script:TestResults.Failed++ }
        "WARN" { $script:TestResults.Warnings++ }
    }
}

# Test 1: File Existence
function Test-FileExistence {
    Write-TestStep "Testing file existence..."
    
    $requiredFiles = @(
        "nexus-cos-full-deployment.sh",
        ".env.deployment",
        "deploy-nexus-cos-full.ps1",
        "docker-compose.prod.yml",
        "nginx.prod.conf"
    )
    
    foreach ($file in $requiredFiles) {
        if (Test-Path $file) {
            Write-TestSuccess "Found: $file"
            Add-TestResult "File Existence: $file" "PASS"
        } else {
            Write-TestError "Missing: $file"
            Add-TestResult "File Existence: $file" "FAIL" "File not found"
        }
    }
}

# Test 2: Bash Script Syntax
function Test-BashSyntax {
    if ($SkipSyntaxCheck) {
        Write-TestWarning "Skipping bash syntax check"
        return
    }
    
    Write-TestStep "Testing bash script syntax..."
    
    $bashScript = "nexus-cos-full-deployment.sh"
    
    if (-not (Test-Path $bashScript)) {
        Write-TestError "Bash script not found: $bashScript"
        Add-TestResult "Bash Syntax Check" "FAIL" "Script file not found"
        return
    }
    
    # Check for common bash syntax issues
    $content = Get-Content $bashScript -Raw
    
    # Test 1: Shebang
    if ($content -match "^#!/bin/bash") {
        Write-TestSuccess "Shebang found"
        Add-TestResult "Bash Shebang" "PASS"
    } else {
        Write-TestWarning "No bash shebang found"
        Add-TestResult "Bash Shebang" "WARN" "Missing #!/bin/bash"
    }
    
    # Test 2: Function definitions
    $functionCount = ([regex]::Matches($content, "function\s+\w+\s*\(\)")).Count
    if ($functionCount -gt 0) {
        Write-TestSuccess "Found $functionCount function definitions"
        Add-TestResult "Bash Functions" "PASS" "$functionCount functions found"
    } else {
        Write-TestWarning "No function definitions found"
        Add-TestResult "Bash Functions" "WARN" "No functions defined"
    }
    
    # Test 3: Variable usage
    if ($content -match '\$\{[A-Z_]+\}') {
        Write-TestSuccess "Environment variable usage detected"
        Add-TestResult "Environment Variables" "PASS"
    } else {
        Write-TestWarning "No environment variable usage detected"
        Add-TestResult "Environment Variables" "WARN" "No env vars found"
    }
    
    # Test 4: Error handling
    if ($content -match "set -e" -or $content -match "trap") {
        Write-TestSuccess "Error handling detected"
        Add-TestResult "Error Handling" "PASS"
    } else {
        Write-TestWarning "No error handling detected"
        Add-TestResult "Error Handling" "WARN" "Consider adding set -e or trap"
    }
}

# Test 3: PowerShell Script Syntax
function Test-PowerShellSyntax {
    if ($SkipSyntaxCheck) {
        Write-TestWarning "Skipping PowerShell syntax check"
        return
    }
    
    Write-TestStep "Testing PowerShell script syntax..."
    
    $psScript = "deploy-nexus-cos-full.ps1"
    
    if (-not (Test-Path $psScript)) {
        Write-TestError "PowerShell script not found: $psScript"
        Add-TestResult "PowerShell Syntax Check" "FAIL" "Script file not found"
        return
    }
    
    try {
        # Parse the PowerShell script
        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($psScript, [ref]$tokens, [ref]$errors)
        
        if ($errors.Count -eq 0) {
            Write-TestSuccess "PowerShell syntax is valid"
            Add-TestResult "PowerShell Syntax" "PASS"
        } else {
            Write-TestError "PowerShell syntax errors found:"
            foreach ($error in $errors) {
                Write-Host "  Line $($error.Extent.StartLineNumber): $($error.Message)" -ForegroundColor Red
            }
            Add-TestResult "PowerShell Syntax" "FAIL" "$($errors.Count) syntax errors"
        }
    }
    catch {
        Write-TestError "Error parsing PowerShell script: $($_.Exception.Message)"
        Add-TestResult "PowerShell Syntax" "FAIL" "Parse error: $($_.Exception.Message)"
    }
}

# Test 4: Environment Configuration
function Test-EnvironmentConfig {
    if ($SkipConfigValidation) {
        Write-TestWarning "Skipping environment configuration validation"
        return
    }
    
    Write-TestStep "Testing environment configuration..."
    
    $envFile = ".env.deployment"
    
    if (-not (Test-Path $envFile)) {
        Write-TestError "Environment file not found: $envFile"
        Add-TestResult "Environment Config" "FAIL" "File not found"
        return
    }
    
    $envContent = Get-Content $envFile
    
    # Required environment variables
    $requiredVars = @(
        "POSTGRES_USER",
        "POSTGRES_PASSWORD", 
        "JWT_SECRET",
        "DOMAIN",
        "EMAIL",
        "VPS_HOST",
        "SSH_USER"
    )
    
    foreach ($var in $requiredVars) {
        $found = $envContent | Where-Object { $_ -match "^$var=" }
        if ($found) {
            Write-TestSuccess "Found: $var"
            Add-TestResult "Env Var: $var" "PASS"
        } else {
            Write-TestError "Missing: $var"
            Add-TestResult "Env Var: $var" "FAIL" "Required variable not found"
        }
    }
    
    # Check for sensitive data patterns
    $sensitivePatterns = @(
        @{ Pattern = "password.*=.*\w+"; Name = "Passwords" },
        @{ Pattern = "secret.*=.*\w+"; Name = "Secrets" },
        @{ Pattern = "key.*=.*\w+"; Name = "API Keys" }
    )
    
    foreach ($pattern in $sensitivePatterns) {
        $matches = $envContent | Where-Object { $_ -match $pattern.Pattern }
        if ($matches) {
            Write-TestSuccess "Found $($pattern.Name): $($matches.Count) entries"
            Add-TestResult "Sensitive Data: $($pattern.Name)" "PASS" "$($matches.Count) entries found"
        } else {
            Write-TestWarning "No $($pattern.Name) found"
            Add-TestResult "Sensitive Data: $($pattern.Name)" "WARN" "No entries found"
        }
    }
}

# Test 5: Docker Configuration
function Test-DockerConfig {
    Write-TestStep "Testing Docker configuration..."
    
    $dockerComposeFile = "docker-compose.prod.yml"
    
    if (-not (Test-Path $dockerComposeFile)) {
        Write-TestError "Docker Compose file not found: $dockerComposeFile"
        Add-TestResult "Docker Config" "FAIL" "File not found"
        return
    }
    
    $dockerContent = Get-Content $dockerComposeFile -Raw
    
    # Test for required services
    $requiredServices = @("postgres", "redis", "v-screen", "frontend", "nginx")
    
    foreach ($service in $requiredServices) {
        if ($dockerContent -match "${service}:") {
            Write-TestSuccess "Found service: $service"
            Add-TestResult "Docker Service: $service" "PASS"
        } else {
            Write-TestWarning "Service not found: $service"
            Add-TestResult "Docker Service: $service" "WARN" "Service definition not found"
        }
    }
    
    # Test for environment variable usage
    if ($dockerContent -match '\$\{[A-Z_]+\}') {
        Write-TestSuccess "Environment variables used in Docker Compose"
        Add-TestResult "Docker Env Vars" "PASS"
    } else {
        Write-TestWarning "No environment variables found in Docker Compose"
        Add-TestResult "Docker Env Vars" "WARN" "Consider using environment variables"
    }
}

# Test 6: Nginx Configuration
function Test-NginxConfig {
    Write-TestStep "Testing Nginx configuration..."
    
    $nginxFile = "nginx.prod.conf"
    
    if (-not (Test-Path $nginxFile)) {
        Write-TestError "Nginx config file not found: $nginxFile"
        Add-TestResult "Nginx Config" "FAIL" "File not found"
        return
    }
    
    $nginxContent = Get-Content $nginxFile -Raw
    
    # Test for required directives
    $requiredDirectives = @(
        @{ Pattern = "server_name.*nexuscos\.online"; Name = "Server Name" },
        @{ Pattern = "listen\s+443\s+ssl"; Name = "SSL Listen" },
        @{ Pattern = "location\s+/api/"; Name = "API Proxy" },
        @{ Pattern = "proxy_pass"; Name = "Proxy Configuration" }
    )
    
    foreach ($directive in $requiredDirectives) {
        if ($nginxContent -match $directive.Pattern) {
            Write-TestSuccess "Found: $($directive.Name)"
            Add-TestResult "Nginx: $($directive.Name)" "PASS"
        } else {
            Write-TestWarning "Missing: $($directive.Name)"
            Add-TestResult "Nginx: $($directive.Name)" "WARN" "Directive not found"
        }
    }
}

# Test 7: Deployment Script Dry Run
function Test-DeploymentDryRun {
    if ($SkipDryRun) {
        Write-TestWarning "Skipping deployment dry run"
        return
    }
    
    Write-TestStep "Testing deployment script dry run..."
    
    $psScript = "deploy-nexus-cos-full.ps1"
    
    if (-not (Test-Path $psScript)) {
        Write-TestError "PowerShell deployment script not found"
        Add-TestResult "Deployment Dry Run" "FAIL" "Script not found"
        return
    }
    
    try {
        Write-TestStep "Running deployment script in dry run mode..."
        
        # Execute the script with dry run flag
        $result = & ".\$psScript" -DryRun -SkipPrerequisites 2>&1
        
        if ($LASTEXITCODE -eq 0 -or $result -match "DRY RUN MODE") {
            Write-TestSuccess "Dry run completed successfully"
            Add-TestResult "Deployment Dry Run" "PASS"
        } else {
            Write-TestError "Dry run failed: $result"
            Add-TestResult "Deployment Dry Run" "FAIL" "Dry run execution failed"
        }
    }
    catch {
        Write-TestError "Error during dry run: $($_.Exception.Message)"
        Add-TestResult "Deployment Dry Run" "FAIL" "Exception: $($_.Exception.Message)"
    }
}

# Test 8: Security Validation
function Test-SecurityValidation {
    Write-TestStep "Testing security configuration..."
    
    # Check for hardcoded secrets in scripts
    $scriptFiles = @("nexus-cos-full-deployment.sh", "deploy-nexus-cos-full.ps1")
    
    foreach ($file in $scriptFiles) {
        if (Test-Path $file) {
            $content = Get-Content $file -Raw
            
            # Look for potential hardcoded secrets (excluding environment variable syntax)
            $secretPatterns = @(
                'password\s*=\s*[''"][^$''"]+[''""]',
                'secret\s*=\s*[''"][^$''"]+[''""]',
                'key\s*=\s*[''"][^$''"]+[''""]'
            )
            
            $foundSecrets = $false
            foreach ($pattern in $secretPatterns) {
                if ($content -match $pattern) {
                    $foundSecrets = $true
                    break
                }
            }
            
            if (-not $foundSecrets) {
                Write-TestSuccess "No hardcoded secrets found in $file"
                Add-TestResult "Security: $file" "PASS" "No hardcoded secrets"
            } else {
                Write-TestError "Potential hardcoded secrets found in $file"
                Add-TestResult "Security: $file" "FAIL" "Hardcoded secrets detected"
            }
        }
    }
    
    # Check .env file is not in production
    if (Test-Path ".env") {
        Write-TestError "Production .env file found - security risk"
        Add-TestResult "Security: .env file" "FAIL" "Production .env file exists"
    } else {
        Write-TestSuccess "No production .env file found"
        Add-TestResult "Security: .env file" "PASS" "No production .env file"
    }
}

# Generate test report
function New-TestReport {
    Write-TestHeader "TEST RESULTS SUMMARY"
    
    $totalTests = $script:TestResults.Tests.Count
    $passRate = if ($totalTests -gt 0) { [math]::Round(($script:TestResults.Passed / $totalTests) * 100, 2) } else { 0 }
    
    Write-Host "Total Tests: $totalTests" -ForegroundColor White
    Write-Host "Passed: $($script:TestResults.Passed)" -ForegroundColor Green
    Write-Host "Failed: $($script:TestResults.Failed)" -ForegroundColor Red
    Write-Host "Warnings: $($script:TestResults.Warnings)" -ForegroundColor Yellow
    Write-Host "Pass Rate: $passRate%" -ForegroundColor $(if ($passRate -ge 80) { "Green" } elseif ($passRate -ge 60) { "Yellow" } else { "Red" })
    
    # Generate detailed report file
    $reportFile = "deployment-test-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
    
    $reportLines = @()
    $reportLines += "Nexus COS Deployment Script Test Report"
    $reportLines += "======================================="
    $reportLines += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $reportLines += ""
    $reportLines += "SUMMARY"
    $reportLines += "-------"
    $reportLines += "Total Tests: $totalTests"
    $reportLines += "Passed: $($script:TestResults.Passed)"
    $reportLines += "Failed: $($script:TestResults.Failed)"
    $reportLines += "Warnings: $($script:TestResults.Warnings)"
    $reportLines += "Pass Rate: $passRate%"
    $reportLines += ""
    $reportLines += "DETAILED RESULTS"
    $reportLines += "---------------"

    foreach ($test in $script:TestResults.Tests) {
        $line = "[$($test.Status)] $($test.Name)"
        if ($test.Message) {
            $line += " - $($test.Message)"
        }
        $line += " [$($test.Timestamp.ToString('HH:mm:ss'))]"
        $reportLines += $line
    }
    
    $reportLines += ""
    $reportLines += ""
    $reportLines += "RECOMMENDATIONS"
    $reportLines += "--------------"

    if ($script:TestResults.Failed -gt 0) {
        $reportLines += "- Address all FAILED tests before deployment"
    }
    
    if ($script:TestResults.Warnings -gt 0) {
        $reportLines += "- Review WARNING items for potential improvements"
    }
    
    if ($passRate -ge 90) {
        $reportLines += "- Deployment scripts are ready for production use"
    } elseif ($passRate -ge 70) {
        $reportLines += "- Deployment scripts need minor improvements"
    } else {
        $reportLines += "- Deployment scripts require significant fixes before use"
    }
    
    $reportLines | Out-File -FilePath $reportFile -Encoding UTF8
    Write-TestSuccess "Detailed test report saved: $reportFile"
    
    # Return overall status
    return @{
        Success = ($script:TestResults.Failed -eq 0)
        PassRate = $passRate
        ReportFile = $reportFile
    }
}

# Main test execution
function Start-DeploymentTests {
    Write-TestHeader "NEXUS COS DEPLOYMENT SCRIPT TESTS"
    
    try {
        Test-FileExistence
        Test-BashSyntax
        Test-PowerShellSyntax
        Test-EnvironmentConfig
        Test-DockerConfig
        Test-NginxConfig
        Test-DeploymentDryRun
        Test-SecurityValidation
        
        $results = New-TestReport
        
        if ($results.Success) {
            Write-TestHeader "ALL TESTS PASSED"
            Write-TestSuccess "Deployment scripts are ready for production use!"
            exit 0
        } else {
            Write-TestHeader "TESTS COMPLETED WITH ISSUES"
            Write-TestWarning "Please address failed tests before deployment"
            exit 1
        }
    }
    catch {
        Write-TestHeader "TEST EXECUTION FAILED"
        Write-TestError $_.Exception.Message
        exit 1
    }
}

# Execute tests if script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    Start-DeploymentTests
}