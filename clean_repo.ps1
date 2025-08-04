# PowerShell-Skript zum Bereinigen eines Git-Repositorys (Version 2 - Korrigiert)
# =========================================================================

# --- Konfiguration ---
# Inhalt für die .gitignore-Datei.
$gitignoreContent = @"
# Python Bytecode und Caches
__pycache__/
*.pyc
*.pyo
*.pyd

# Virtuelle Umgebungen
venv/
.venv/
env/
.env
ENV/

# Build- und Distributionsartefakte
build/
dist/
*.egg-info/
sdist/
develop-eggs/
eggs/
lib/
lib64/
parts/
var/
wheels/
*.egg
pip-wheel-metadata/

# Installations- und Konfigurationsdateien
pip-selfcheck.json
.installed.cfg

# Log-Dateien
*.log

# Lokale Konfigurationsdateien für Editoren
.vscode/
.idea/
.project
.pydevproject
.settings/

# Betriebssystem-spezifische Dateien
.DS_Store
Thumbs.db

# Sensible Daten (z.B. API-Keys)
.env
.env.*
secrets.yml
*.credential*
"@

# --- Skript-Logik ---

# Überprüfen, ob wir uns in einem Git-Repository befinden
if (-not (Test-Path ".git")) {
    Write-Host "Fehler: Kein Git-Repository im aktuellen Verzeichnis gefunden." -ForegroundColor Red
    exit
}

Write-Host "Git-Repository gefunden. Starte die Bereinigung..." -ForegroundColor Cyan

# Schritt 1: .gitignore erstellen oder aktualisieren
if (-not (Test-Path ".gitignore")) {
    Write-Host "Keine .gitignore gefunden. Erstelle eine neue für Python-Projekte." -ForegroundColor Yellow
    Set-Content -Path ".gitignore" -Value $gitignoreContent
} else {
    Write-Host ".gitignore existiert bereits. Stelle sicher, dass sie vollständig ist." -ForegroundColor Green
}

# Schritt 2: Aufräum-Befehle ausführen
Write-Host "Führe Git-Bereinigung aus..." -ForegroundColor Cyan
Write-Host "1. Füge .gitignore zum Index hinzu"
git add .gitignore

Write-Host "2. Entferne alle Dateien aus dem Git-Index (lokale Dateien bleiben erhalten)"
git rm -r --cached .

Write-Host "3. Füge saubere Dateien erneut zum Index hinzu"
git add .

Write-Host ""
Write-Host "--------------------------------------------------------" -ForegroundColor Green
Write-Host "BEREINIGUNG ABGESCHLOSSEN!" -ForegroundColor Green
Write-Host "--------------------------------------------------------"
Write-Host ""
Write-Host "Die 'Überbleibsel' wurden aus der Git-Verfolgung entfernt."
Write-Host "Bitte überprüfe die Änderungen mit 'git status'."
Write-Host "Wenn alles korrekt ist, führe den Commit manuell durch:"
# --- KORRIGIERTE ZEILE UNTEN ---
Write-Host 'git commit -m "Feat: Clean up repository with script"' -ForegroundColor Yellow
Write-Host ""

# Zeige den finalen Status an
git status