import unittest

def parse_cfg(file):
    config = {}
    current_section = None
    
    with open(file, 'r') as f:
        for line in f:
            stripped = line.strip()
            
            if not stripped:  # Skip empty lines
                continue
                
            if stripped.startswith('[') and stripped.endswith(']'):
                current_section = stripped[1:-1]
                if current_section not in config:
                    config[current_section] = {}
                    
            elif '=' in stripped and current_section is not None:
                key, value = stripped.split('=', 1)
                config[current_section][key.strip()] = value.strip()
                
    return config

class TestParseCfg(unittest.TestCase):
    def test_empty_file(self):
        with open('empty.cfg', 'w') as f:
            pass
        self.assertEqual(parse_cfg('empty.cfg'), {})
        
    def test_empty_lines_only(self):
        with open('empty_lines.cfg', 'w') as f:
            f.write("\n\n\n")
        self.assertEqual(parse_cfg('empty_lines.cfg'), {})
        
    def test_single_section(self):
        with open('single.cfg', 'w') as f:
            f.write("[section]\nkey1 = value1\n")
        result = parse_cfg('single.cfg')
        self.assertEqual(result, {'section': {'key1': 'value1'}})
        
    def test_multiple_sections(self):
        with open('multi.cfg', 'w') as f:
            f.write("[sec1]\nk1=v1\n\n[sec2]\nk2=v2\n")
        result = parse_cfg('multi.cfg')
        self.assertEqual(result, {'sec1': {'k1': 'v1'}, 'sec2': {'k2': 'v2'}})
        
    def test_key_value_with_spaces(self):
        with open('spaces.cfg', 'w') as f:
            f.write("[s]\n  key  =  value  \n")
        result = parse_cfg('spaces.cfg')
        self.assertEqual(result, {'s': {'key': 'value'}})

if __name__ == '__main__':
    unittest.main(argv=['first-arg-is-ignored'], exit=False)