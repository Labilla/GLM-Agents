<#
.SYNOPSIS
    Erstellt die ADDS-Struktur (adds/, tests/, .gitignore, requirements.txt) und pusht sie ins Git.

.PARAMETER ProjectPath
    Pfad zum Wurzelverzeichnis Deines Klons (z.B. C:\Users\labil\Downloads\GLM-Agents-main\GLM-Agents-main).

.PARAMETER Branch
    Git-Branch, auf den gepusht wird (Standard: main).

.EXAMPLE
    .\setup_adds.ps1 -ProjectPath "C:\Users\labil\Downloads\GLM-Agents-main\GLM-Agents-main" -Branch feature/adds
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath  = "C:\Users\labil\Downloads\GLM-Agents-main\GLM-Agents-main",
    [Parameter(Mandatory=$false)]
    [string]$Branch       = "main"
)

# 1) Wechsle ins Projektverzeichnis
Set-Location -Path $ProjectPath

# 2) .gitignore anlegen
@"
# Byte-compiled
__pycache__/
*.py[cod]
*.pyo

# Virtualenv / venv
venv/
.env
.glm-agent/

# Backup- & Log-Dateien
*.bak
*.log

# Artefakte
artifacts/
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8

# 3) requirements.txt anlegen
@"
httpx>=0.24
textual>=0.43
pytest>=8.0
rich>=13.0
"@ | Out-File -FilePath "requirements.txt" -Encoding UTF8

# 4) adds-Paketstruktur anlegen
$addsPath = Join-Path $ProjectPath "adds"
if (-Not (Test-Path $addsPath)) {
    New-Item -ItemType Directory -Path $addsPath | Out-Null
}

# Hilfsfunktion zum Schreiben von Dateien
function Write-ModuleFile($relativePath, $content) {
    $full = Join-Path $ProjectPath $relativePath
    $folder = Split-Path $full
    if (-Not (Test-Path $folder)) { New-Item -ItemType Directory -Path $folder | Out-Null }
    $content | Out-File -FilePath $full -Encoding UTF8
}

# __init__.py
Write-ModuleFile "adds\__init__.py" @"
\"\"\"
adds
====

Paket-Basis für das Autonome Digital Brain Assistant Entwicklungssystem (ADDS).
\"\"\"
"@

# task_graph.py
Write-ModuleFile "adds\task_graph.py" @"
\"\"\"
task_graph
===========

Definiert Task und TaskGraph mit Zyklus-Erkennung.
\"\"\"

from typing import Dict, List

class Task:
    def __init__(self, task_id: str, goal: str, assigned_to: str, depends_on: List[str] = None):
        self.task_id = task_id
        self.goal = goal
        self.assigned_to = assigned_to
        self.depends_on = depends_on or []

class TaskGraph:
    def __init__(self):
        self.tasks: Dict[str, Task] = {}

    def add_task(self, task: Task):
        self.tasks[task.task_id] = task

    def has_cycle(self) -> bool:
        visited = {}
        def visit(n):
            if visited.get(n) == 'temp': return True
            if visited.get(n) == 'perm': return False
            visited[n] = 'temp'
            for m in self.tasks[n].depends_on:
                if visit(m): return True
            visited[n] = 'perm'
            return False
        return any(visit(n) for n in self.tasks)
"@

# orchestrator.py
Write-ModuleFile "adds\orchestrator.py" @"
\"\"\"
orchestrator
============

MetaAgent: Analyse, Ressourcen-Schätzung, Makro-HTDAG-Generierung.
\"\"\"

from typing import Dict, Any
from adds.task_graph import Task, TaskGraph

class MetaAgent:
    def handle_request(self, goal: str) -> Dict[str, Any]:
        # Dummy-Ressourcenschätzung
        resources = {
            'gpu_vram_gb_peak':'low',
            'system_ram_gb_peak':'low',
            'estimated_compute_minutes':'low'
        }
        # Beispiel-Makro-HTDAG
        tg = TaskGraph()
        tg.add_task(Task('ARCH-001', f'Analysiere und implementiere: {goal}', 'ArchitectAgent'))
        tg.add_task(Task('VAL-001',
                         'Validiere das Ergebnis von ARCH-001 in Bezug auf die Anforderungen',
                         'ValidatorAgent', ['ARCH-001']))
        return {
            'resource_prediction': resources,
            'htdag': {'tasks': {tid: vars(t) for tid,t in tg.tasks.items()}}
        }
"@

# architect_agent.py
Write-ModuleFile "adds\architect_agent.py" @"
\"\"\"
architect_agent
================

Stub für den Architekt-Agenten (Feature-Design & Codegenerierung).
\"\"\"
class ArchitectAgent:
    def plan(self, spec: str):
        raise NotImplementedError
"@

# validator_agent.py
Write-ModuleFile "adds\validator_agent.py" @"
\"\"\"
validator_agent
===============

Stub für den Validator-Agenten (Leistungs- und Qualitätschecks).
\"\"\"
class ValidatorAgent:
    def validate(self, data):
        raise NotImplementedError
"@

# ethics_agent.py
Write-ModuleFile "adds\ethics_agent.py" @"
\"\"\"
ethics_agent
============

Stub für den Ethiker-Agenten (Compliance & Audits).
\"\"\"
class EthicsAgent:
    def audit(self, artifact):
        raise NotImplementedError
"@

# ux_agent.py
Write-ModuleFile "adds\ux_agent.py" @"
\"\"\"
ux_agent
========

Stub für den UX-Agenten (Accessibility & Trust).
\"\"\"
class UXAgent:
    def evaluate(self, component):
        raise NotImplementedError
"@

# cli.py
Write-ModuleFile "adds\cli.py" @"
#!/usr/bin/env python3
\"\"\"
adds_cli
========

CLI-Frontend für den MetaAgent.
\"\"\"

import os, sys, json
try:
    from adds.orchestrator import MetaAgent
except ModuleNotFoundError:
    # Füge Projekt-Root zum Pfad hinzu, wenn nicht installiert
    root = os.path.dirname(os.path.dirname(__file__))
    sys.path.insert(0, root)
    from adds.orchestrator import MetaAgent

def main(argv=None):
    args = sys.argv[1:] if argv is None else argv
    if not args:
        print('Usage: adds_cli.py \"<goal>\"', file=sys.stderr)
        return 1
    goal = ' '.join(args)
    agent = MetaAgent()
    resp = agent.handle_request(goal)
    print(json.dumps(resp, indent=2, ensure_ascii=False))
    return 0

if __name__=='__main__':
    sys.exit(main())
"@

# 5) tests/test_adds.py
$testsPath = Join-Path $ProjectPath "tests"
if (-Not (Test-Path $testsPath)) {
    New-Item -ItemType Directory -Path $testsPath | Out-Null
}

@"
\"\"\"
Tests für das adds-Paket.
\"\"\"

from adds.task_graph import Task, TaskGraph
from adds.orchestrator import MetaAgent

def test_taskgraph_cycle():
    tg = TaskGraph()
    tg.add_task(Task('A','a','X'))
    tg.add_task(Task('B','b','Y',['A']))
    assert not tg.has_cycle()

def test_taskgraph_cycle_detected():
    tg = TaskGraph()
    tg.add_task(Task('A','a','X',['B']))
    tg.add_task(Task('B','b','Y',['A']))
    assert tg.has_cycle()

def test_metaagent_cli():
    ma = MetaAgent()
    resp = ma.handle_request('Testgoal')
    assert 'resource_prediction' in resp
    assert 'htdag' in resp
"@ | Out-File -FilePath "tests\test_adds.ps1" -Encoding UTF8

# 6) Git-Commit & Push
git add .gitignore requirements.txt adds tests

# Prüfe, ob origin existiert und pushe
$remotes = git remote
if ($remotes -contains 'origin') {
    git push origin $Branch
    Write-Host "✅ Änderungen nach origin/$Branch gepusht."
} else {
    Write-Warning "⚠ Kein Remote 'origin' gefunden. Änderungen wurden committed, aber nicht gepusht."
}

Write-Host "✅ Fertig! Datei-/Commit-Schritte abgeschlossen."
