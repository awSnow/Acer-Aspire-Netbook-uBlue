# Acer Minimal OS

Custom UBlue Fedora Atomic image for Acer Aspire 722 netbook (AMD C-50, 2GB RAM).

## Quick Start

### Default Credentials
| Field | Value |
|-------|-------|
| Username | `dj` |
| Password | `changeme` |

**⚠️ Change your password immediately after first login:**
```bash
passwd
```

## Features

- Minimal Openbox desktop (~150MB RAM usage)
- LightDM with auto-login (5 second timeout)
- Essential utilities: pcmanfm, xterm, mousepad, htop
- NetworkManager for connectivity
- Low-RAM sysctl tweaks (swappiness=10)
- Passwordless sudo for wheel group

## Building

### Automatic (GitHub Actions)

Images build automatically on push to `main` and are published to:
```
ghcr.io/YOUR_USERNAME/acer-minimal-os:42
```

### Manual Local Build

```bash
# Install BlueBuild CLI
podman run --rm -it -v .:/repo:Z ghcr.io/blue-build/cli build /repo/recipes/recipe.yml

# Or use the GitHub Action locally with act
act -j build
```

## Creating Bootable Media

After the image is built and pushed to GHCR:

### Generate ISO

```bash
# Pull your image first
podman pull ghcr.io/YOUR_USERNAME/acer-minimal-os:42

# Create ISO with bootc-image-builder
sudo podman run --rm -it --privileged \
  --pull=newer \
  -v ./config.toml:/config.toml \
  -v ./output:/output \
  -v /var/lib/containers/storage:/var/lib/containers/storage \
  quay.io/centos-bootc/bootc-image-builder:latest \
  --type iso \
  --config /config.toml \
  --local \
  ghcr.io/YOUR_USERNAME/acer-minimal-os:42

# ISO will be at ./output/bootiso/install.iso
```

### Flash to USB

```bash
# Find your USB device (be careful!)
lsblk

# Flash (replace /dev/sdX with your USB device)
sudo dd if=./output/bootiso/install.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

## GitHub Setup

### 1. Create Signing Keys

```bash
# Install cosign
# Fedora: sudo dnf install cosign
# macOS: brew install cosign

# Generate keypair
cosign generate-key-pair

# This creates:
# - cosign.key (private - add to GitHub secrets)
# - cosign.pub (public - keep in repo)
```

### 2. Add Secret to GitHub

1. Go to your repo → **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Name: `SIGNING_SECRET`
4. Value: Paste entire contents of `cosign.key`

### 3. Enable Packages Permission

1. **Settings** → **Actions** → **General**
2. Under "Workflow permissions", select **Read and write permissions**
3. Check **Allow GitHub Actions to create and approve pull requests**

## Project Structure

```
my-acer-os/
├── .github/
│   └── workflows/
│       └── build.yml          # GitHub Actions CI/CD
├── files/
│   ├── scripts/
│   │   ├── setup-user.sh      # Creates 'dj' user at build time
│   │   └── configure-desktop.sh # LightDM, Openbox, sysctl tweaks
│   └── system/                # Files copied to / in image
│       └── etc/
│           └── sudoers.d/
├── recipes/
│   └── recipe.yml             # BlueBuild recipe
├── config.toml                # bootc-image-builder config
├── cosign.pub                 # Public signing key
└── README.md
```

## Hardware Status

| Component | Status | Notes |
|-----------|--------|-------|
| Display | ✅ Working | AMD Radeon HD 6250 via mesa |
| CPU | ✅ Working | AMD C-50 dual-core @ 1.0 GHz |
| Storage | ✅ Working | 500GB HDD |
| WiFi | ⏳ Planned | Broadcom BCM4313 needs firmware |
| Audio | ❓ Untested | |

## Roadmap

- [x] Minimal bootable image
- [x] Baked-in user account
- [x] Auto-login desktop
- [ ] Broadcom WiFi driver integration
- [ ] 8GB RAM upgrade → Sway desktop
- [ ] Audio configuration

## Troubleshooting

### No login prompt / black screen

If LightDM fails, switch to TTY:
```
Ctrl+Alt+F2
```
Login as `dj` / `changeme`, then debug:
```bash
journalctl -u lightdm --no-pager
```

### Forgot password / locked out

Boot with `rd.break` appended to kernel:
1. At GRUB, press `e` to edit
2. Find line starting with `linux`
3. Append: `rd.break`
4. Press `Ctrl+X` to boot
5. At emergency shell:
```bash
chroot /sysroot
passwd dj
exit
reboot
```

### Check system resources

```bash
htop          # Interactive process viewer
free -h       # Memory usage
df -h         # Disk usage
```

## User Creation Approaches

This image uses **two complementary methods**:

1. **Build-time** (`files/scripts/setup-user.sh`): User `dj` is baked into the OCI image. Every deployment has this user.

2. **Install-time** (`config.toml`): bootc-image-builder can inject/override users when creating ISO. Useful for customization without rebuilding.

For production deployments, consider:
- Remove auto-login in `/etc/lightdm/lightdm.conf.d/50-acer-minimal.conf`
- Use SSH keys instead of passwords
- Remove `NOPASSWD` from sudoers

## License

MIT

## Credits

Built with [BlueBuild](https://blue-build.org/) on [Universal Blue](https://universal-blue.org/).
