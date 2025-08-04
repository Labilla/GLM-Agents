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
