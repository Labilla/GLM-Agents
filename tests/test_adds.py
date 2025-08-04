\"\"\"  
Tests fÃ¼r das adds-Paket.  
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
