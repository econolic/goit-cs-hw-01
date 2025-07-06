# DOSBox runner script
param([string]$Action = "run")

Write-Host "DOSBox Automation Script" -ForegroundColor Green

$projectDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Test-Nasm {
    # First try to find NASM in PATH
    try {
        $null = Get-Command nasm -ErrorAction Stop
        return $true
    } catch {
        # If not found, try common installation paths
        $nasmPaths = @(
            "$env:USERPROFILE\AppData\Local\bin\NASM\nasm.exe",
            "C:\Program Files\NASM\nasm.exe",
            "C:\Program Files (x86)\NASM\nasm.exe",
            "C:\NASM\nasm.exe"
        )
        
        foreach ($path in $nasmPaths) {
            if (Test-Path $path) {
                # Add to PATH for current session
                $nasmDir = Split-Path -Parent $path
                if ($env:PATH -notlike "*$nasmDir*") {
                    $env:PATH = "$nasmDir;" + $env:PATH
                    Write-Host "Added NASM to PATH: $nasmDir" -ForegroundColor Yellow
                }
                return $true
            }
        }
        return $false
    }
}

function Find-DOSBox {
    $paths = @(
        "dosbox",
        "C:\Program Files (x86)\DOSBox-0.74-3\DOSBox.exe",
        "C:\Program Files\DOSBox-0.74-3\DOSBox.exe",
        "D:\Program Files\DOSBox-0.74-3\DOSBox.exe"
    )
    
    foreach ($path in $paths) {
        try {
            if ($path -eq "dosbox") {
                $null = Get-Command dosbox -ErrorAction Stop
                return "dosbox"
            } elseif (Test-Path $path) {
                return $path
            }
        } catch {
            continue
        }
    }
    return $null
}

switch ($Action.ToLower()) {
    "help" {
        Write-Host ""
        Write-Host "DOSBox Assembly Runner" -ForegroundColor Green
        Write-Host "=====================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Commands:" -ForegroundColor White
        Write-Host "  compile - Compile assembly code only" -ForegroundColor Gray
        Write-Host "  run     - Compile and run in DOSBox" -ForegroundColor Gray
        Write-Host "  help    - Show this help" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Requirements:" -ForegroundColor White
        Write-Host "  - NASM assembler" -ForegroundColor Gray
        Write-Host "  - DOSBox emulator" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Alternative:" -ForegroundColor White
        Write-Host "  .\run_wsl.ps1 - Run via WSL (recommended)" -ForegroundColor Gray
    }
    "compile" {
        Write-Host "Compiling assembly code..." -ForegroundColor Yellow
        
        if (-not (Test-Nasm)) {
            Write-Host "Error: NASM not found!" -ForegroundColor Red
            Write-Host "Please install NASM from: https://www.nasm.us/" -ForegroundColor Yellow
            Write-Host "Alternative: Use .\run_wsl.ps1" -ForegroundColor Gray
            exit 1
        }
        
        $sourceFile = "calc.asm"
        $outputFile = "calc.com"
        
        if (-not (Test-Path $sourceFile)) {
            Write-Host "Error: Source file not found: $sourceFile" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "Assembling $sourceFile..." -ForegroundColor White
        nasm -f bin $sourceFile -o $outputFile
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Compilation successful: $outputFile" -ForegroundColor Green
        } else {
            Write-Host "Compilation failed!" -ForegroundColor Red
            exit 1
        }
    }
    "run" {
        Write-Host "Running assembly code in DOSBox..." -ForegroundColor Yellow
        
        # Check compilation
        $outputFile = "calc.com"
        if (-not (Test-Path $outputFile)) {
            Write-Host "Compiled file not found. Compiling first..." -ForegroundColor Yellow
            & $MyInvocation.MyCommand.Path "compile"
            if ($LASTEXITCODE -ne 0) { exit 1 }
        }
        
        # Check DOSBox
        $dosboxPath = Find-DOSBox
        if (-not $dosboxPath) {
            Write-Host "Error: DOSBox not found!" -ForegroundColor Red
            Write-Host "Please install DOSBox from: https://www.dosbox.com/" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Manual steps:" -ForegroundColor White
            Write-Host "1. Start DOSBox" -ForegroundColor Gray
            Write-Host "2. Type: mount c ." -ForegroundColor Gray
            Write-Host "3. Type: c:" -ForegroundColor Gray
            Write-Host "4. Type: calc.com" -ForegroundColor Gray
            Write-Host ""
            Write-Host "Alternative: .\run_wsl.ps1" -ForegroundColor Green
            exit 1
        }
        
        Write-Host "DOSBox found: $dosboxPath" -ForegroundColor Green
        Write-Host "Creating temporary directory for DOSBox..." -ForegroundColor White
        
        # Create temporary directory with simple English name
        $tempDir = Join-Path $env:TEMP "calc"
        if (Test-Path $tempDir) {
            Remove-Item $tempDir -Recurse -Force
        }
        New-Item -ItemType Directory -Path $tempDir | Out-Null
        
        # Copy calc.com to temp directory
        Copy-Item "calc.com" $tempDir
        
        # Get DOS 8.3 short path name
        $shortPath = $tempDir
        try {
            # Try to get short path using .NET method
            Add-Type -TypeDefinition @"
                using System;
                using System.Runtime.InteropServices;
                using System.Text;
                public class Win32 {
                    [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
                    public static extern int GetShortPathName(
                        [MarshalAs(UnmanagedType.LPTStr)] string path,
                        [MarshalAs(UnmanagedType.LPTStr)] StringBuilder shortPath,
                        int shortPathLength
                    );
                }
"@
            $sb = New-Object System.Text.StringBuilder(260)
            $result = [Win32]::GetShortPathName($tempDir, $sb, $sb.Capacity)
            if ($result -gt 0) {
                $shortPath = $sb.ToString()
            }
        } catch {
            # Fallback to regular path
            $shortPath = $tempDir
        }
        
        Write-Host "Temporary directory: $tempDir" -ForegroundColor Gray
        Write-Host "Short path: $shortPath" -ForegroundColor Gray
        Write-Host "Starting DOSBox..." -ForegroundColor Green
        Write-Host "Commands to execute:" -ForegroundColor Gray
        Write-Host "  mount c `"$shortPath`"" -ForegroundColor Gray
        Write-Host "  c:" -ForegroundColor Gray
        Write-Host "  calc.com" -ForegroundColor Gray
        
        # Create a batch file for DOSBox commands
        $batchFile = Join-Path $tempDir "run.bat"
        @"
@echo off
calc.com
pause
"@ | Out-File -FilePath $batchFile -Encoding ascii
        
        # Create DOSBox config file
        $configFile = Join-Path $tempDir "dosbox.conf"
        @"
[autoexec]
mount c "$shortPath"
c:
run.bat
"@ | Out-File -FilePath $configFile -Encoding ascii
        
        # Start DOSBox with config file
        $dosboxArgs = @("-conf", $configFile)
        
        Start-Process -FilePath $dosboxPath -ArgumentList $dosboxArgs -Wait
    }
    default {
        Write-Host "Unknown command: $Action" -ForegroundColor Red
        Write-Host "Use: .\run_dosbox.ps1 help" -ForegroundColor Yellow
    }
}
