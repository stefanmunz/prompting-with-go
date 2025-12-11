# Setup Go Environment with mise

This skill sets up a Go development environment using mise (a polyglot version manager) with two example projects running different Go versions.

## What This Skill Does

1. Checks if `mise` is installed on the system
2. Checks if `Go` is installed
3. Runs the accompanying `setup-go-env.sh` script with appropriate parameters
4. Verifies the setup by running sample Go programs that confirm their Go version

## Instructions for Claude

### Step 1: Check Prerequisites

First, check if mise is installed:

```bash
which mise && mise --version
```

If mise is not found, note that `--install-mise` flag will be needed.

Next, check if Go is installed via mise:

```bash
mise list go 2>/dev/null || echo "Go not installed via mise"
```

If Go is not installed or mise is not available, note that `--install-go` flag will be needed.

### Step 2: Build Script Arguments

Based on the checks above, determine which arguments to pass to the script:

- If mise is NOT installed: add `--install-mise`
- If Go is NOT installed (or mise wasn't available to check): add `--install-go`

### Step 3: Run the Setup Script

The script is located in the same directory as this skill file (`.claude/commands/setup-go-env.sh`).

First, determine the repository root (where the user invoked Claude), then run the script:

```bash
# The script path is relative to the repo root
./.claude/commands/setup-go-env.sh [arguments]
```

Examples:
- Both needed: `./.claude/commands/setup-go-env.sh --install-mise --install-go`
- Only Go needed: `./.claude/commands/setup-go-env.sh --install-go`
- Only mise needed: `./.claude/commands/setup-go-env.sh --install-mise`
- Neither needed (just create projects): `./.claude/commands/setup-go-env.sh`

### Step 4: Handle Script Output

The script will output colored log messages:
- `[INFO]` - Normal progress messages
- `[WARN]` - Warnings that don't stop execution
- `[ERROR]` - Errors that cause the script to fail

**Exit codes:**
- `0` - Success
- `1` - General error
- `2` - mise installation failed
- `3` - Go installation failed
- `4` - Project setup failed

If the script fails, report the error to the user with the exit code and error message.

### Step 5: Verify the Setup

After the script completes successfully, verify that both Go versions work correctly:

**Test Go 1.24 project:**
```bash
cd ./go124-project && mise exec -- go run main.go
```

Expected output should contain: `I am built with Go go1.24`

**Test Go 1.25 project:**
```bash
cd ./go125-project && mise exec -- go run main.go
```

Expected output should contain: `I am built with Go go1.25`

### Step 6: Report Results

After verification, report to the user:

1. Whether mise was installed (or was already present)
2. Whether Go was installed (or was already present)
3. The two projects that were created with their paths
4. The verification results showing each project uses the correct Go version

**IMPORTANT: If mise was installed, always end with this message:**

> To use mise in your terminal, run: `echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc && source ~/.zshrc`
>
> (This requires your action—the agent runs in a non-interactive shell and cannot configure your terminal.)

## Troubleshooting

### mise not found after installation
If mise was just installed, you may need to reload the shell or use the full path: `~/.local/bin/mise`

### Go version mismatch
If the Go version in the output doesn't match the expected version, check:
1. The `.tool-versions` file in the project directory
2. Run `mise current go` in the project directory to see which version mise is using

### Permission denied
Ensure the script is executable: `chmod +x setup-go-env.sh`

## Project Structure Created

```
prompting-with-go/
├── go124-project/
│   ├── .tool-versions    # Contains: go 1.24
│   └── main.go           # Prints Go version
└── go125-project/
    ├── .tool-versions    # Contains: go 1.25
    └── main.go           # Prints Go version
```
