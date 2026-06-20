# rpi-desk-pet-starter ♡

**Clone me and make your own remote desk pet!**

A small, cozy long-distance display for two people: one **sender** (you) page on your laptop/phone updates a **display** (for your partner/bestie/fam) running fullscreen on a Raspberry Pi. No custom backend — just HTML, JavaScript, and [Supabase](https://supabase.com) for realtime sync and photo storage.

This is a starter template. Fork it, swap in your names and photos, connect your own Supabase project, and ship a physical desk pet to someone you miss.

---

## What you get

| Part | What it does |
|------|----------------|
| **`sender/`** | Web UI to set status, draw on photos, and send messages |
| **`display/`** | 800×480 kiosk UI for a small LCD (Waveshare / Pi touchscreen) |
| **`images/`** | Pixel-art status scenes (working, sleeping, gone fishing) |
| **`scripts/deskpet-dim.sh`** | Optional nightly screen dimming on the Pi |
| **`docs/PI_SETUP.md`** | Raspberry Pi kiosk setup steps |

---

## How it works

```
You (sender page)  ──►  Supabase  ◄──  Raspberry Pi (display, kiosk mode)
         │                    │
         │                    ├── status table (realtime)
         │                    ├── message table (realtime)
         │                    └── photos storage bucket
```

1. You open `sender/index.html` locally (or host it somewhere private).
2. Status and message updates write to Supabase.
3. The Pi display subscribes to Supabase realtime and updates instantly.
4. Tap the Pi screen to cycle slides: **clocks → status → latest photo/message**.

---

## Parts I used (yours may vary)

- **Raspberry Pi** (any model that runs Raspberry Pi OS desktop) — I used a Rasberry Pi Zero 2W
- **Small HDMI/DSI display** — I used a Waveshare LCD in 800×480-ish kiosk mode
- **Supabase free tier** — Postgres + realtime + storage
- **Chromium kiosk** — autostart fullscreen on boot
- **Plain HTML/CSS/JS** — no build step, no framework

---

## Quick start

### 1) Clone this repo

```bash
git clone https://github.com/YOUR_USERNAME/rpi-desk-pet-starter.git
cd rpi-desk-pet-starter
```

### 2) Create a Supabase project

1. Go to [supabase.com](https://supabase.com) → **New project**
2. Pick a name and database password (save the password somewhere safe)

### 3) Run the database schema

In Supabase: **SQL Editor → New query**, paste and run:

```sql
create table status (
  id integer primary key default 1,
  value text not null default 'working',
  updated_at timestamp with time zone default now()
);

create table message (
  id integer primary key default 1,
  text text default '',
  photo_url text default '',
  sent_at timestamp with time zone default now(),
  viewed boolean default true
);

insert into status (id, value) values (1, 'working')
  on conflict (id) do nothing;

insert into message (id) values (1)
  on conflict (id) do nothing;
```

### 4) Create the photos storage bucket

1. Supabase → **Storage → New bucket**
2. Name: `photos`
3. **Public bucket**: ON (simplest for this project)

### 5) Enable Row Level Security (recommended)

In **SQL Editor**, run:

```sql
alter table public.status enable row level security;
alter table public.message enable row level security;

create policy "anon read status"
  on public.status for select to anon using (true);

create policy "anon update status"
  on public.status for update to anon using (true) with check (true);

create policy "anon read message"
  on public.message for select to anon using (true);

create policy "anon update message"
  on public.message for update to anon using (true) with check (true);

create policy "anon upload photos"
  on storage.objects for insert to anon
  with check (bucket_id = 'photos');

create policy "anon read photos"
  on storage.objects for select to anon
  using (bucket_id = 'photos');
```

### 6) Get your API keys

Supabase → **Project Settings → API**

Copy:

- **Project URL** (e.g. `https://abcdefgh.supabase.co`)
- **anon public** key (the `eyJ...` string)

Never commit the **service_role** key. Only the **anon** key goes in the HTML files.

### 7) Paste keys into both HTML files

Edit **`sender/index.html`** and **`display/index.html`**. Find:

```js
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

Replace with your values from step 6.

### 8) Customize the display

In **`display/index.html`**, also update:

| Setting | What to change |
|---------|----------------|
| Clock labels | HTML: `.clock-name` text ("you" / "partner" → your names) |
| Timezones | `TZ_YOU` and `TZ_PARTNER` (IANA names like `America/New_York`) |
| Permanent photo | `YOUR_PERMANENT_PHOTO_URL_HERE` — upload to Supabase Storage, paste public URL |
| Countdown | `COUNTDOWN_START` / `COUNTDOWN_TARGET` dates, or remove the bar |
| Message labels | "from sender", popup text, etc. |

In **`sender/index.html`**, update button copy (`send to display ♡`) if you want.

### 9) Test locally

Open in a browser (serve from repo root so image paths work):

```bash
python3 -m http.server 8765
```

- Sender: `http://localhost:8765/sender/index.html`
- Display: `http://localhost:8765/display/index.html`

Change status on sender — display should update within a second.

### 10) Set up the Raspberry Pi

Follow **[docs/PI_SETUP.md](docs/PI_SETUP.md)** to flash the Pi, clone this repo, and autostart Chromium in kiosk mode.

---

## Project structure

```
rpi-desk-pet-starter/
├── sender/index.html       ← control panel (run locally or host privately)
├── display/index.html      ← Pi kiosk display
├── images/                 ← status pixel art
├── scripts/deskpet-dim.sh  ← optional night dimming
├── docs/PI_SETUP.md        ← Pi hardware + kiosk guide
└── README.md
```

---

## Customization ideas

- Rename clocks and message labels to match your relationship
- Swap pixel art in `images/` for your own characters
- Change countdown target date (or delete the countdown block)
- Add a fourth status with a new image + button in sender
- Deploy sender to Vercel/Netlify **with password protection** if you want remote access

---

## Security notes

- The **anon key is embedded in client-side HTML** — anyone with the key can read/write your Supabase tables if RLS is off. Enable RLS (step 5).
- Keep the **sender private** if you only use it locally (`file://` or localhost).
- Use a **separate Supabase project** for experiments vs. your live desk pet.
- If a key ever leaks, regenerate it in Supabase → Settings → API.

---

## Credits

The pixel-art status characters in `images/` are based on [Sumikko Gurashi](https://sumikkogurashi.com/).

---

## License

MIT — use freely, customize and personalize, make someone smile <3
