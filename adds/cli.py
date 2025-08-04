#!/usr/bin/env python3
\"\"\"  
adds_cli  
========  

CLI-Frontend fÃ¼r den MetaAgent.  
\"\"\"  

import os, sys, json  
try:  
    from adds.orchestrator import MetaAgent  
except ModuleNotFoundError:  
    # FÃ¼ge Projekt-Root zum Pfad hinzu, wenn nicht installiert  
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
