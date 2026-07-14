# dotfiles

## 前提条件
```bash
apt update && apt install curl
```

## proxmox
### host
Proxmoxホスト環境用のセットアップスクリプト（Docker、OpenSSH、リポジトリ設定）
```bash
curl -fsSL https://raw.githubusercontent.com/r-namiki/proxmox-scripts/main/proxmox/host/install.sh | bash
```

### vm
仮想マシン用のセットアップスクリプト（Docker、OpenSSH、自動アップデート）
```bash
curl -fsSL https://raw.githubusercontent.com/r-namiki/proxmox-scripts/main/proxmox/vm/install.sh | bash
```

### container
LXCコンテナ用のセットアップスクリプト（OpenSSH、自動アップデート）
```bash
curl -fsSL https://raw.githubusercontent.com/r-namiki/proxmox-scripts/main/proxmox/container/install.sh | bash
```

## SSH公開鍵の設定

ローカルマシンで公開鍵を確認:
```bash
cat ~/.ssh/id_ed25519.pub
```

サーバー側で公開鍵を設定:
```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cat > ~/.ssh/authorized_keys << 'EOF'
pubkey-here
EOF
chmod 600 ~/.ssh/authorized_keys
```
