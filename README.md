# dotfiles
前提として`apt install curl`を行う必要があります
## proxmox
### host
`curl -fsSL https://raw.githubusercontent.com/r-namiki/dotfiles/main/proxmox/host/install.sh | bash`
### container
`curl -fsSL https://raw.githubusercontent.com/r-namiki/dotfiles/main/proxmox/container/install.sh | bash`

SSH公開鍵の設定:
```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "ローカルの公開鍵をここに貼り付け" > ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

ローカルマシンで公開鍵を確認:
```bash
cat ~/.ssh/id_ed25519.pub
```
