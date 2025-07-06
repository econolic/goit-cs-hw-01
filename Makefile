# Makefile for goit-cs-hw-01
# Computer architecture homework: Assembly calculator + Python interpreter

# Variables
ASM_SOURCE = calc.asm
COM_TARGET = calc.com
PYTHON_INTERPRETER = interpreter.py
PYTHON_DEMO = demo_interpreter.py

# Default target
.PHONY: all
all: compile

# Compile assembly program (universal .com format)
.PHONY: compile
compile:
	@echo "Compiling $(ASM_SOURCE) to $(COM_TARGET)..."
	@if command -v nasm >/dev/null 2>&1; then \
		nasm -f bin $(ASM_SOURCE) -o $(COM_TARGET) && \
		echo "Compilation successful! Use run-dosbox to test."; \
	else \
		echo "NASM not found. Use run-wsl for WSL compilation."; \
	fi

# Run via WSL (compile only - execution in DOSBox)
.PHONY: run-wsl
run-wsl:
	@echo "Running via WSL..."
	@powershell.exe -File run_wsl.ps1

# Instructions for DOSBox execution
.PHONY: run-dosbox
run-dosbox:
	@echo "To run in DOSBox:"
	@echo "1. Start DOSBox"
	@echo "2. Mount directory: mount c ."
	@echo "3. Switch to C: drive"
	@echo "4. Run: calc.com"
	@echo ""
	@echo "Or use automated script:"
	@echo "powershell.exe -File run_dosbox.ps1"

# Check WSL environment
.PHONY: check-wsl
check-wsl:
	@powershell.exe -File run_wsl.ps1 check

# Test Python interpreter
.PHONY: test-python
test-python:
	@echo "Testing Python interpreter..."
	@if command -v python >/dev/null 2>&1; then \
		python $(PYTHON_DEMO); \
	else \
		echo "Using python3..."; \
		python3 $(PYTHON_DEMO); \
	fi

# Test Python interpreter via WSL
.PHONY: test-python-wsl
test-python-wsl:
	@echo "Testing Python interpreter via WSL..."
	@wsl python3 $(PYTHON_DEMO)

# Run Python interpreter interactively
.PHONY: run-python
run-python:
	@echo "Starting Python interpreter..."
	@if command -v python >/dev/null 2>&1; then \
		python $(PYTHON_INTERPRETER); \
	else \
		echo "Using python3..."; \
		python3 $(PYTHON_INTERPRETER); \
	fi

# Clean compiled files
.PHONY: clean
clean:
	@echo "Cleaning compiled files..."
	@rm -f $(COM_TARGET) *.o *.out
	@echo "Files cleaned!"

# Help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all         - compile assembly program (default)"
	@echo "  compile     - compile calc.asm to calc.com"
	@echo "  run-wsl     - compile via WSL (use DOSBox for execution)"
	@echo "  run-dosbox  - show DOSBox execution instructions"
	@echo "  check-wsl   - check WSL environment"
	@echo "  test-python     - test Python interpreter with demo"
	@echo "  test-python-wsl - test Python interpreter via WSL"
	@echo "  run-python      - run Python interpreter interactively"
	@echo "  clean       - remove compiled files"
	@echo "  help        - show this help"
	@echo ""
	@echo "Quick start:"
	@echo "  make run-wsl      # Compile via WSL"
	@echo "  make run-dosbox   # Instructions for DOSBox"
	@echo "  make test-python  # Test Python interpreter"
