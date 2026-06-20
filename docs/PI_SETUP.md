# Raspberry Pi display setup

Run these steps after Supabase is configured and your HTML files have your project URL and anon key.

## 1) Flash Raspberry Pi OS

Use [Raspberry Pi Imager](https://www.raspberrypi.com/software/). In **Advanced options**:

- Set hostname (e.g. `desk-pet-display`)
- Configure Wi‑Fi
- Enable SSH
- Set username and password

## 2) Clone this repo on the Pi

```bash
git clone https://github.com/YOUR_USERNAME/rpi-desk-pet-starter.git
cd rpi-desk-pet-starter
```

## 3) Install kiosk dependencies

```bash
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y chromium unclutter xdotool
```

## 4) Autostart Chromium in kiosk mode

```bash
mkdir -p ~/.config/lxsession/LXDE-pi
nano ~/.config/lxsession/LXDE-pi/autostart
```

Paste (replace `YOUR_USERNAME`):

```ini
@xset s off
@xset -dpms
@xset s noblank
@unclutter -idle 0.1 -root
@chromium --kiosk --incognito --noerrdialogs --disable-session-crashed-bubble --disable-infobars file:///home/YOUR_USERNAME/rpi-desk-pet-starter/display/index.html
```

If that does not launch on boot, also add:

```bash
mkdir -p ~/.config/autostart
nano ~/.config/autostart/deskpet-kiosk.desktop
```

```ini
[Desktop Entry]
Type=Application
Name=DeskPet Kiosk
Exec=chromium --kiosk --incognito --noerrdialogs --disable-session-crashed-bubble --disable-infobars file:///home/YOUR_USERNAME/rpi-desk-pet-starter/display/index.html
X-GNOME-Autostart-enabled=true
```

Reboot:

```bash
sudo reboot
```

## 5) Optional: nightly dimming

```bash
sudo cp scripts/deskpet-dim.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/deskpet-dim.sh
crontab -e
```

Add:

```cron
0 * * * * /usr/local/bin/deskpet-dim.sh
@reboot sleep 90 && /usr/local/bin/deskpet-dim.sh
```

Edit dim hours inside `scripts/deskpet-dim.sh` if needed.

## 6) Optional: auto-update from GitHub

Create `/usr/local/bin/deskpet-update.sh`:

```bash
#!/bin/bash
set -e
cd /home/YOUR_USERNAME/rpi-desk-pet-starter
git fetch origin main
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)
if [ "$LOCAL" != "$REMOTE" ]; then
  git reset --hard origin/main
  DISPLAY=:0 xdotool key ctrl+r 2>/dev/null || true
fi
```

```bash
sudo chmod +x /usr/local/bin/deskpet-update.sh
crontab -e
```

Add weekly pull (example: Sundays at 3am):

```cron
0 3 * * 0 /usr/local/bin/deskpet-update.sh >> /home/YOUR_USERNAME/deskpet-update.log 2>&1
```
