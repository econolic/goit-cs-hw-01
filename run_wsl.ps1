# PowerShell script for compiling and running assembly programs via WSL
# Usage: .\run_wsl.ps1 [command]

param(
    [string]$Command = "run"
)

$SOURCE = "calc.asm"
$TARGET = "calc"

function Show-Help {
    Write-Host "Available commands:"
    Write-Host "  run         - compile and run via WSL (default)"
    Write-Host "  compile     - only compile via WSL"
    Write-Host "  check       - check WSL and NASM availability"
    Write-Host "  clean       - clean compiled files"
    Write-Host "  help        - show this help"
    Write-Host ""
    Write-Host "Usage examples:"
    Write-Host "  .\run_wsl.ps1           # run program"
    Write-Host "  .\run_wsl.ps1 compile   # only compile"
    Write-Host "  .\run_wsl.ps1 clean     # clean files"
}

function Test-Environment {
    Write-Host "Checking WSL availability..." -ForegroundColor Cyan
    
    wsl --version 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "WSL is available" -ForegroundColor Green
    } else {
        Write-Host "WSL is not available" -ForegroundColor Red
        return $false
    }
    
    Write-Host "Checking NASM in WSL..." -ForegroundColor Cyan
    wsl which nasm 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "NASM is installed in WSL" -ForegroundColor Green
        return $true
    } else {
        Write-Host "NASM is not installed in WSL" -ForegroundColor Red
        Write-Host "Install NASM: wsl sudo apt update && wsl sudo apt install nasm" -ForegroundColor Yellow
        return $false
    }
}

function Build-Program {
    Write-Host "Compiling via WSL..." -ForegroundColor Cyan
    
    Write-Host "Compiling $SOURCE..."
    wsl nasm -f bin "$SOURCE" -o "$TARGET.com"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Compilation failed!" -ForegroundColor Red
        return $false
    }
    
    Write-Host "Compilation successful!" -ForegroundColor Green
    return $true
}

function Run-Program {
    if (-not (Test-Environment)) {
        return
    }
    
    if (-not (Build-Program)) {
        return
    }
    
    Write-Host "`nNote: .com files are designed for DOS/DOSBox" -ForegroundColor Yellow
    Write-Host "For actual execution, use:" -ForegroundColor Cyan
    Write-Host "  .\run_dosbox.ps1" -ForegroundColor White
    Write-Host "  or run 'calc.com' in DOSBox" -ForegroundColor White
}

function Clean-Files {
    Write-Host "Cleaning files..." -ForegroundColor Cyan
    
    $filesToDelete = @("$TARGET.com")
    
    foreach ($file in $filesToDelete) {
        if (Test-Path $file) {
            Remove-Item $file -Force
            Write-Host "Deleted: $file" -ForegroundColor Yellow
        }
    }
    
    wsl rm -f $TARGET.com 2>$null
    Write-Host "Files cleaned!" -ForegroundColor Green
}

# Main logic
switch ($Command.ToLower()) {
    "run" { Run-Program }
    "compile" { 
        if (Test-Environment) { 
            Build-Program 
        }
    }
    "check" { Test-Environment }
    "clean" { Clean-Files }
    "help" { Show-Help }
    default { 
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        Show-Help 
    }
}
