# Tenter Installer 🥀

A colorful, menu-driven Bash installer for setting up common applications on Linux.

## Features

- Colorful terminal menu
- Numbered options for individual applications
- An **Install All** option
- Detects several package managers automatically
- Uses non-interactive flags where supported

## Applications

1. Brave
2. Telegram
3. Discord
4. Proton VPN
5. Firefox
6. btop
7. htop
8. Alacritty
9. LibreWolf
10. LibreOffice
11. Steam
12. Fastfetch
13. Cava

## Install

First, make sure Git and Bash are installed. Clone this repository:

```bash
git clone https://github.com/juantenter/tenter-installer.git
cd tenter-installer
chmod +x tenter-install.sh
./tenter-install.sh
```

Choose an application number from the menu, or choose **14** to attempt installing all applications.

## Supported distributions

The script detects package managers used by:

- Arch Linux and Arch-based distributions such as CachyOS
- Debian, Ubuntu, and Linux Mint
- Fedora
- openSUSE
- Alpine Linux
- Void Linux
- Solus

**Important:** detecting a package manager does not guarantee that every application is available in that distribution's enabled repositories. Package names, third-party repositories, architecture support, and VPN setup differ by distribution. Some apps use Flatpak, which may need to be installed and configured.

## Requirements

- Bash
- Git to clone the repository
- `sudo` access for system package installation (unless running as root)
- Internet connection
- A supported package manager
- Flatpak for applications installed through Flathub; the script attempts to install it if missing

## Security note

Review scripts before running them, especially when they install software or use administrator privileges. Tenter Installer may add the Flathub remote and uses package-manager commands to install applications. Only run it if you trust the source.

## Troubleshooting

- **`git: command not found`**: install Git using your distribution's package manager.
- **Package not found**: check whether the package is available in your distribution's enabled repositories.
- **Steam installation fails**: some distributions require additional repositories or 32-bit library support.
- **Proton VPN**: setup is distribution-specific. Follow the official instructions at [Proton VPN Support](https://protonvpn.com/support/).
- **Colors do not show**: use a terminal that supports ANSI colors. You can disable colors with `NO_COLOR=1`.

## Contributing

Issues and pull requests are welcome. Test changes on the relevant distributions and clearly document any limitations.

## License

No license has been specified yet. Until a license is added to this repository, do not assume that others have permission to redistribute or modify the project.
