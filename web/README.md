# Exam Pulse Pro Web App

Local-first countdown dashboard for exam schedules.

## Run

```bash
cd web
python3 -m http.server 4173
```

Open `http://localhost:4173`.

## Data format for bulk import

One line per exam:

```text
Title | YYYY-MM-DD | HH:MM
```

Time is optional; default is `09:00`.
