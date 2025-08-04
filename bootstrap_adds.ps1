<#
.SYNOPSIS
  One-Click Bootstrap für das ADDS-Gerüst in Deinem GLM-Agents-Repo.

.PARAMETER ProjectPath
  Absoluter Pfad zu Deinem lokalen Klon.

.PARAMETER Branch
  Gewünschter Branch (Standard: main).

.PARAMETER RepoUrl
  Dein GitHub-HTTPS-URL (Standard: https://github.com/Labilla/GLM-Agents.git).
#>
param(
  [string]$ProjectPath = "C:\Users\labil\Downloads\GLM-Agents-main\GLM-Agents-main",
  [string]$Branch      = "main",
  [string]$RepoUrl     = "https://github.com/Labilla/GLM-Agents.git"
)

# 1) Ins Projekt-Verzeichnis wechseln
Set-Location -LiteralPath $ProjectPath

# 2) Remote origin setzen/aktualisieren
if ((git remote) -match "origin") {
  git remote set-url origin $RepoUrl
  Write-Host "✔ origin → $RepoUrl"
} else {
  git remote add origin $RepoUrl
  Write-Host "✔ origin hinzugefügt → $RepoUrl"
}

# 3) Pull/Rebase mit Autostash
Write-Host "⏳ Pull/Rebase mit Autostash von origin/$Branch..."
git fetch origin $Branch
git pull --rebase --autostash origin $Branch

# 4) .gitignore und requirements.txt anlegen
@'
# Byte-compiled
__pycache__/
*.py[cod]
*.pyo

# virtualenv / venv
venv/
.env
.glm-agent/

# backup/logs
*.bak
*.log

# artifacts
artifacts/
'@ | Set-Content -Encoding UTF8 ".gitignore"

@'
httpx>=0.24
textual>=0.43
pytest>=8.0
rich>=13.0
'@ | Set-Content -Encoding UTF8 "requirements.txt"

# 5) Hilfsfunktion zum Erzeugen von Dateien im adds-Ordner
function Write-AddsFile {
  param(
    [Parameter(Mandatory=$true)][string]$RelPath,
    [Parameter(Mandatory=$true)][string]$Txt
  )
  $full = Join-Path $ProjectPath $RelPath
  $dir  = Split-Path $full
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  $Txt | Set-Content -Encoding UTF8 -Path $full
}

# 6) Dateien für das adds-Paket erzeugen
$init = @'
"""
adds
====

Paket-Basis für das Autonome Digital Brain Assistant System (ADDS).
"""
'@
Write-AddsFile -RelPath "adds\__init__.py"       -Txt $init

$tg = @'
"""
task_graph
==========

Definiert Task und TaskGraph mit Zyklus-Erkennung.
"""

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
'@
Write-AddsFile -RelPath "adds\task_graph.py"       -Txt $tg

$orc = @'
"""
orchestrator
============

MetaAgent: Anfrage → Ressourcen-Schätzung + Makro-HTDAG.
"""

from typing import Dict, Any
from adds.task_graph import Task, TaskGraph

class MetaAgent:
    def handle_request(self, goal: str) -> Dict[str, Any]:
        resources = {
            "gpu_vram_gb_peak":"low",
            "system_ram_gb_peak":"low",
            "estimated_compute_minutes":"low"
        }
        tg = TaskGraph()
        tg.add_task(Task("ARCH-001", f"Analysiere und implementiere: {goal}", "ArchitectAgent"))
        tg.add_task(Task("VAL-001",
                         "Validiere das Ergebnis von ARCH-001",
                         "ValidatorAgent", ["ARCH-001"]))
        return {
            "resource_prediction": resources,
            "htdag": {"tasks": {tid: vars(t) for tid,t in tg.tasks.items()}}
        }
'@
Write-AddsFile -RelPath "adds\orchestrator.py"      -Txt $orc

$arch = @'
"""
architect_agent
===============

Stub für den Architekt-Agenten.
"""
class ArchitectAgent:
    def plan(self, spec: str):
        raise NotImplementedError
'@
Write-AddsFile -RelPath "adds\architect_agent.py"   -Txt $arch

$val = @'
"""
validator_agent
===============

Stub für den Validator-Agenten.
"""
class ValidatorAgent:
    def validate(self, data):
        raise NotImplementedError
'@
Write-AddsFile -RelPath "adds\validator_agent.py"   -Txt $val

$eth = @'
"""
ethics_agent
============

Stub für den Ethiker-Agenten.
"""
class EthicsAgent:
    def audit(self, artifact):
        raise NotImplementedError
'@
Write-AddsFile -RelPath "adds\ethics_agent.py"     -Txt $eth

$ux = @'
"""
ux_agent
========

Stub für den UX-Agenten.
"""
class UXAgent:
    def evaluate(self, component):
        raise NotImplementedError
'@
Write-AddsFile -RelPath "adds\ux_agent.py"         -Txt $ux

$cli = @'
#!/usr/bin/env python3
"""
adds_cli
========

Kommandozeilen-Frontend für den MetaAgent.
"""

import os, sys, json
try:
    from adds.orchestrator import MetaAgent
except ImportError:
    root = os.path.dirname(os.path.dirname(__file__))
    sys.path.insert(0, root)
    from adds.orchestrator import MetaAgent

def main():
    args = sys.argv[1:]
    if not args:
        print("Usage: adds_cli.py \"<goal>\"", file=sys.stderr)
        return 1
    goal = " ".join(args)
    resp = MetaAgent().handle_request(goal)
    print(json.dumps(resp, indent=2, ensure_ascii=False))
    return 0

if __name__=="__main__":
    sys.exit(main())
'@
Write-AddsFile -RelPath "adds\cli.py"             -Txt $cli

# 7) Tests anlegen
if (-not (Test-Path "tests")) { New-Item -ItemType Directory -Path "tests" | Out-Null }
$test = @'
"""
Tests für das adds-Paket.
"""

from adds.task_graph import Task, TaskGraph
from adds.orchestrator import MetaAgent

def test_taskgraph_cycle():
    tg = TaskGraph()
    tg.add_task(Task("A","a","X"))
    tg.add_task(Task("B","b","Y",["A"]))
    assert not tg.has_cycle()

def test_taskgraph_cycle_detected():
    tg = TaskGraph()
    tg.add_task(Task("A","a","X",["B"]))
    tg.add_task(Task("B","b","Y",["A"]))
    assert tg.has_cycle()

def test_metaagent_cli():
    resp = MetaAgent().handle_request("Testgoal")
    assert "resource_prediction" in resp
    assert "htdag" in resp
'@
$test | Set-Content -Encoding UTF8 "tests\test_adds.py"

# 8) Commit & Push
git add .gitignore requirements.txt adds tests
git commit -m "Bootstrap ADDS foundation"
git push -u origin $Branch

Write-Host "`n✅ Fertig: ADDS-Gerüst erstellt, committed & gepusht!`n"
