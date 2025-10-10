# dotfiles

## 前提条件
```bash
apt update && apt install curl
```

## proxmox
### host
```bash
curl -fsSL https://raw.githubusercontent.com/r-namiki/dotfiles/main/proxmox/host/install.sh | bash
```

### container
```bash
curl -fsSL https://raw.githubusercontent.com/r-namiki/dotfiles/main/proxmox/container/install.sh | bash
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
