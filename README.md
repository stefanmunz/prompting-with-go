# prompting-with-go

A Claude Code skill for setting up Go development environments with multiple Go versions using [mise](https://mise.jdx.dev/).

## Setup (3 Steps)

### Step 1: Bootstrap (macOS only)

First, install Xcode Command Line Tools (~1-2GB download):

```bash
xcode-select --install
```

Wait for the installation to fully complete, then run the bootstrap script:

```bash
sudo -v
curl -fsSL https://raw.githubusercontent.com/stefanmunz/prompting-with-go/main/bootstrap.sh | bash
```

The `sudo -v` caches your password (required by Homebrew installer).

This installs Homebrew, git, and clones this repository to `~/prompting-with-go`.

If you already have git, just clone:

```bash
git clone https://github.com/stefanmunz/prompting-with-go.git ~/prompting-with-go
```

### Step 2: Install Claude Code

Install Claude Code following the official instructions:

https://docs.anthropic.com/en/docs/claude-code

### Step 3: Run the setup skill

```bash
cd ~/prompting-with-go
claude
```

Then type:

```
/setup-go-env
```

The skill will:
- Install mise (if needed)
- Install Go 1.24 and Go 1.25 via mise
- Create example projects demonstrating version switching
- Verify everything works

**After the skill completes**, run the command it provides to activate mise in your terminal.

## What You Get

Two example Go projects that use different Go versions:

```
prompting-with-go/
├── go124-project/    # Uses Go 1.24
│   ├── .tool-versions
│   └── main.go
└── go125-project/    # Uses Go 1.25
    ├── .tool-versions
    └── main.go
```

When you `cd` into each project, mise automatically switches to the correct Go version.

## Why mise?

- **Multiple versions**: Run different Go versions per project
- **Automatic switching**: `.tool-versions` file controls the version
- **Polyglot**: Also manages Node, Python, Ruby, and 100+ other tools
