# ubuntu-setup

Reproducible bootstrap for a freshly installed Ubuntu workstation. The repository
provides a single declarative `Taskfile.yml` that installs the applications,
toolchains, shells, and lab utilities I use, plus a `MyAliases.sh` script that
deploys a curated set of Bash aliases and helper functions for AI,
cybersecurity, networking, and Python work.

## Contents

| File | Purpose |
|------|---------|
| `Taskfile.yml` | Task definitions consumed by the [Task](https://taskfile.dev) runner. Groups every install command from the original list into named, reusable tasks. |
| `UbuntuApps for new installation.txt` | The original flat list of `apt`, `snap`, `pipx`, `uv`, and PPA commands, kept for reference. |
| `MyAliases.sh` | Idempotent installer for `~/.aliases`, wired into `~/.bashrc` between explicit markers. Includes the `knife`, `network`, `servicecmds`, `processcmds`, `diskcmds`, `syscmds`, and `uvcmds` helpers. |
| `README.md` | This document. |

## Prerequisites

A fresh Ubuntu installation only ships with the bare minimum. Before cloning
this repository, install Git:

```bash
sudo apt update
sudo apt install -y git
```

Then install the Task runner. Two options:

```bash
# Snap (recommended on Ubuntu)
sudo snap install task --classic

# Or the upstream installer
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin
```

Verify:

```bash
task --version
```

## Quick start

```bash
# 1. Clone
git clone https://github.com/MamdouhEgy/ubuntu-setup.git
cd ubuntu-setup

# 2. List available task groups
task -l

# 3. Full non-interactive provisioning
task all

# 4. Install the alias set
bash MyAliases.sh
source ~/.bashrc
```

That sequence brings a clean Ubuntu install up to a working state with the
applications, the dev toolchain, the shells, the Python environment, the lab
utilities, and the aliases in place.

## Listing the task groups

The `Taskfile.yml` is the single source of truth for what gets installed. List
everything the runner knows about:

```bash
task -l
```

Each entry prints its `desc:` line, so the listing doubles as documentation.
Sample output (abbreviated):

```
* all:                Run the full non-interactive provisioning sequence
* base:               Core CLI utilities (wget, nano, unzip, htop, glances, ...)
* dev:                Developer toolchain (build-essential, git, cmake, VS Code)
* cip-pool:           Lab workstation extras (diodon, meld, okular, krop, ...)
* extras:             Helix, eza, indicator-stickynotes, hstr, tree, kazam, pinta
* python:             Install uv and Python 3.12
* shells-install:     Install zsh, fish (PPA), fisher, and fish-abbreviation-tips
* ...
```

Run any group on its own:

```bash
task dev           # only the developer toolchain
task python        # only uv + Python 3.12
task extras        # only the optional editors and utilities
```

Run a single leaf task inside a group:

```bash
task helix
task eza
task pinta
```

## Full non-interactive provisioning

The `all` task chains every non-interactive group in dependency order:

```bash
task all
```

It runs:

1. `update`        – `apt update && apt upgrade`
2. `base`          – core CLI utilities
3. `dev`           – build tools, Git, VS Code, pip
4. `net`           – networking utilities
5. `media`         – VLC, ffmpeg, GIMP
6. `office`        – LibreOffice, Telegram, SumatraPDF, FileZilla
7. `gui`           – GNOME tweaks, terminator, gedit, ScreenCloud, RabbitVCS
8. `build-tools`   – autotools, software-properties-common
9. `utilities`     – screenkey, ca-certificates
10. `shells-install` – Bash extras, zsh, fish (with fisher and tips)
11. `python`       – uv plus Python 3.12
12. `pipx`         – pipx and tldr
13. `cip-pool`     – FAU lab workstation extras
14. `extras`       – Helix, eza, stickynotes, hstr, tree, kazam, Pinta

Tasks use `sudo DEBIAN_FRONTEND=noninteractive apt-get install -y` so APT never
prompts, and PPAs are added with `add-apt-repository -y`. Re-running `task all`
is safe: `apt-get install` is idempotent and the eza repository key step is
guarded by an existing keyring directory.

### Interactive steps (run manually)

Two steps require a TTY or user action and are intentionally kept out of `all`:

```bash
task shells-fish-default    # runs `chsh -s "$(command -v fish)"`, prompts for password
task jupyter                # creates ~/jupyterenv with uv; then run: cd ~/jupyterenv && uv run jupyter lab
```

## Installing the aliases (`MyAliases.sh`)

`MyAliases.sh` is a self-contained installer. It writes `~/.aliases`, backs up
the existing `~/.bashrc`, then appends a guarded block that sources the alias
file on every interactive Bash session.

```bash
bash MyAliases.sh
source ~/.bashrc
```

The script is idempotent: the guarded block uses the markers
`# >>> AI cybersecurity aliases >>>` and `# <<< AI cybersecurity aliases <<<`,
and the script refuses to insert a second copy. `~/.bashrc` is backed up to
`~/.bashrc.backup.<timestamp>` before any change.

After installation, the following helper aliases are available in any new
Bash session:

```text
knife          # Lists the troubleshooting alias menu
network        # Network troubleshooting cheat sheet
servicecmds    # systemd service troubleshooting
processcmds    # Process inspection
diskcmds       # Disk and inode diagnostics
syscmds        # System overview
uvcmds         # uv (Python) shortcuts
```

Plus standard quality-of-life aliases (`ls`, `..`, `grep`, `df`, `mem`,
Git shortcuts, Docker shortcuts, archive helpers, and more). The full list is
in `MyAliases.sh`.

### Removing the aliases

Delete `~/.aliases` and remove the marker block from `~/.bashrc`:

```bash
rm ~/.aliases
sed -i '/# >>> AI cybersecurity aliases >>>/,/# <<< AI cybersecurity aliases <<</d' ~/.bashrc
source ~/.bashrc
```

A timestamped backup of the pre-install `.bashrc` remains in `$HOME`.

## Extending the application list

The `Taskfile.yml` is structured so that adding new applications is a
two-line change.

### 1. Add to an existing group

Open `Taskfile.yml`, find the group that fits (`base`, `dev`, `media`, etc.),
and append an `apt` invocation using the `{{.APT_INSTALL}}` variable:

```yaml
base:
  desc: Core CLI utilities
  cmds:
    - "{{.APT_INSTALL}} timeshift"
    - "{{.APT_INSTALL}} keepass2"
    - "{{.APT_INSTALL}} ripgrep"     # <-- new line
```

`{{.APT_INSTALL}}` expands to
`sudo DEBIAN_FRONTEND=noninteractive apt-get install -y`, which keeps every
install non-interactive.

### 2. Add a new group

For a logically separate collection of tools, declare a new top-level task and
register it inside `all` so the full provisioning picks it up:

```yaml
tasks:

  containers:
    desc: Container tooling (docker, podman, dive)
    cmds:
      - "{{.APT_INSTALL}} docker.io"
      - "{{.APT_INSTALL}} podman"
      - "{{.APT_INSTALL}} dive"

  all:
    desc: Run the full non-interactive provisioning sequence
    cmds:
      - task: update
      - task: base
      - task: dev
      - task: containers      # <-- include the new group
      # ... existing tasks
```

### 3. Add a tool that needs a third-party repository

Follow the pattern used by `helix`, `eza`, `stickynotes`, and `pinta`:

```yaml
mytool:
  desc: My tool from a PPA
  cmds:
    - sudo add-apt-repository -y ppa:vendor/mytool
    - "{{.APT_UPDATE}}"
    - "{{.APT_INSTALL}} mytool"
```

For tools distributed via a signed `.deb` repository, copy the `eza` task,
which adds the keyring under `/etc/apt/keyrings/` and writes a sources file in
`/etc/apt/sources.list.d/`.

### 4. Add a Snap or pipx package

```yaml
snap-mytool:
  desc: My tool via Snap
  cmds:
    - sudo snap install mytool --classic

pipx-mytool:
  desc: My CLI tool via pipx
  cmds:
    - pipx install mytool
```

### Verification before committing

Run the runner with `--dry` to check the task graph without executing
anything, and use `task -l` to confirm the new task is discoverable:

```bash
task -l
task --dry mytool
```

## Layout

```text
ubuntu-setup/
├── README.md
├── Taskfile.yml
├── MyAliases.sh
└── UbuntuApps for new installation.txt
```

## License

Personal configuration. Use, fork, and adapt freely. No warranty.
