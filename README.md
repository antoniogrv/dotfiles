# dotfiles

The following script allows for a quick installation of a bunch of software that I typically use. Fill in the `<username` variable at the end.

```bash
curl -s https://raw.githubusercontent.com/antoniogrv/dotfiles/master/boot.sh | bash -s <username>
```

#### Notes
- 
- Everything should already be set up appropriately. If not, figure it out.
- `python3`, as well as `pip`, are both in *PATH*. The setup includes `go` and `rustup` too.

#### Cheatsheets

- [nvim cheatsheet](https://github.com/antoniogrv/nvim-config/blob/master/CHEATSHEET.md)
- [i3 cheatsheet](https://github.com/antoniogrv/i3-config/blob/master/CHEATSHEET.md)

### Core

- **Terminal**: gnome-terminal
- **Shell**: bash
- **Desktop**: i3 + gnome
- **Editor**: nvim
- **Filesystem**: nautilus + ranger

### Additional

- **Containers**: docker, podman
- **Kubernetes**: kubectl, krew, k9s, helm, minikube, kind
- **IaC**: terraform, ansible
- **Cloud**: awscli
- **Programming**: golang, rust, python
- **IDEs**: vscode
- **Networking**: wireshark, nmap
- **Utils**: htop, tree, qdirstat ... + *nerd fonts*

### To-do

- add gns3, virtualbox, pipx
