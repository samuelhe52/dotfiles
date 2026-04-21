# Remote Machine Environment Setup Pipeline

## Overview
This pipeline automates the setup of a complete development environment on a remote Linux machine (Ubuntu 22.04+) with zsh, oh-my-zsh, Powerlevel10k theme, plugins, and dotfiles configuration via stow.

## Prerequisites
- SSH access to remote machine with password authentication
- `sshpass` installed locally for non-interactive password authentication
- Remote machine running Ubuntu 22.04 or similar
- Git installed on remote machine
- Access to user's dotfiles repository on GitHub

## Pipeline Steps

### 1. Initial System Update
```bash
sshpass -p '<PASSWORD>' ssh -o StrictHostKeyChecking=no -p <PORT> <USER>@<HOST> << 'EOF'
apt-get update
apt-get install -y zsh git curl wget gpg stow
EOF
```
**Purpose**: Update package manager and install core dependencies
**Variables**: PASSWORD, PORT, USER, HOST

### 2. Install oh-my-zsh
```bash
sshpass -p '<PASSWORD>' ssh -o StrictHostKeyChecking=no -p <PORT> <USER>@<HOST> << 'EOF'
rm -rf ~/<USER>/.oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
EOF
```
**Purpose**: Install oh-my-zsh framework
**Note**: Remove existing installation to avoid conflicts

### 3. Install Powerlevel10k Theme and Plugins
```bash
sshpass -p '<PASSWORD>' ssh -o StrictHostKeyChecking=no -p <PORT> <USER>@<HOST> << 'EOF'
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/Aloxaf/fzf-tab ~/.oh-my-zsh/custom/plugins/fzf-tab
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all
EOF
```
**Purpose**: Install Powerlevel10k theme and essential zsh plugins
**Plugins installed**:
- zsh-autosuggestions: Command suggestions
- zsh-syntax-highlighting: Syntax highlighting
- fzf-tab: Fuzzy completion menu
- fzf: Fuzzy finder binary

### 4. Install eza (ls replacement)
```bash
sshpass -p '<PASSWORD>' ssh -o StrictHostKeyChecking=no -p <PORT> <USER>@<HOST> << 'EOF'
apt-get update
apt-get install -y gpg wget
mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
printf 'deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main\n' > /etc/apt/sources.list.d/gierens.list
chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
apt-get update
apt-get install -y eza
EOF
```
**Purpose**: Install eza (modern ls replacement) via official APT repository
**Note**: Required for aliases in dotfiles that use `eza`

### 5. Clone Dotfiles Repository
```bash
sshpass -p '<PASSWORD>' ssh -o StrictHostKeyChecking=no -p <PORT> <USER>@<HOST> 'cd ~/ && git clone <DOTFILES_REPO_URL>'
```
**Purpose**: Clone user's dotfiles repository
**Variables**: DOTFILES_REPO_URL (e.g., https://github.com/username/dotfiles.git)

### 6. Apply Dotfiles with Stow
```bash
sshpass -p '<PASSWORD>' ssh -o StrictHostKeyChecking=no -p <PORT> <USER>@<HOST> << 'EOF'
rm ~/.zshrc
cd ~/dotfiles && stow linux-zsh tmux vim aliases git
EOF
```
**Purpose**: Symlink dotfiles packages to home directory
**Note**: Remove generated .zshrc first to avoid stow conflicts
**Packages**: linux-zsh, tmux, vim, aliases, git

### 7. Set Default Shell to zsh
```bash
sshpass -p '<PASSWORD>' ssh -o StrictHostKeyChecking=no -p <PORT> <USER>@<HOST> 'chsh -s /bin/zsh'
```
**Purpose**: Set zsh as default login shell

## Environment Variables Required
- `PASSWORD`: SSH password for remote user
- `HOST`: Remote server hostname or IP
- `PORT`: SSH port (default 22)
- `USER`: Remote username (typically root or user with sudo)
- `DOTFILES_REPO_URL`: URL to user's dotfiles GitHub repository

## Configuration Files Referenced
- `linux-zsh/.zshrc`: Main zsh configuration
- `tmux/.tmux.conf`: Tmux configuration
- `vim/.vimrc`: Vim configuration
- `aliases/.aliases`: Shell aliases (includes eza aliases)
- `git/.gitconfig`: Git configuration

## Notes
- All commands use `sshpass` for non-interactive password authentication
- `StrictHostKeyChecking=no` bypasses host key verification (use with caution on untrusted networks)
- Locale warnings can be safely ignored on containerized environments
- FZF integration is automatically added to .zshrc by the installer
- Stow will fail if conflicts exist; remove conflicting files before running stow

## Validation Commands
After setup, verify installation with:
```bash
sshpass -p '<PASSWORD>' ssh -o StrictHostKeyChecking=no -p <PORT> <USER>@<HOST> << 'EOF'
zsh --version
eza --version
ls -la ~/.oh-my-zsh/custom/themes/
ls -la ~/.oh-my-zsh/custom/plugins/
cat ~/.zshrc | grep -E "^(ZSH_THEME|plugins=)"
EOF
```

## Reuse Template
To reuse this pipeline for a new environment, follow these steps:
1. Define all environment variables (PASSWORD, HOST, PORT, USER, DOTFILES_REPO_URL)
2. Execute steps 1-7 in sequence
3. Run validation commands to confirm setup
4. Connect to remote machine and verify zsh/Powerlevel10k functionality
