import unittest

class RobustLineParser:
    def __init__(self):
        self.errors = []
    
    def parse_line(self, line):
        line = line.strip()
        if not line:
            self.errors.append("Empty line")
            return None
            
        parts = line.split(',')
        if len(parts) < 2:
            self.errors.append(f"Insufficient fields: {line}")
            return None
            
        try:
            value = float(parts[1])
        except ValueError:
            self.errors.append(f"Invalid numeric value: {parts[1]}")
            return None
            
        return {
            'key': parts[0].strip(),
            'value': value,
            'extra': parts[2].strip() if len(parts) > 2 else None
        }
    
    def get_errors(self):
        return self.errors

class TestRobustLineParser(unittest.TestCase):
    def setUp(self):
        self.parser = RobustLineParser()
    
    def test_valid_line(self):
        result = self.parser.parse_line("item1,12.5,extra")
        self.assertEqual(result, {'key': 'item1', 'value': 12.5, 'extra': 'extra'})
        self.assertEqual(len(self.parser.get_errors()), 0)
    
    def test_empty_line(self):
        result = self.parser.parse_line("")
        self.assertIsNone(result)
        self.assertEqual(len(self.parser.get_errors()), 1)
        self.assertEqual(self.parser.get_errors()[0], "Empty line")
    
    def test_insufficient_fields(self):
        result = self.parser.parse_line("single")
        self.assertIsNone(result)
        self.assertEqual(len(self.parser.get_errors()), 1)
        self.assertEqual(self.parser.get_errors()[0], "Insufficient fields: single")
    
    def test_invalid_numeric(self):
        result = self.parser.parse_line("item,abc,extra")
        self.assertIsNone(result)
        self.assertEqual(len(self.parser.get_errors()), 1)
        self.assertEqual(self.parser.get_errors()[0], "Invalid numeric value: abc")
    
    def test_whitespace_handling(self):
        result = self.parser.parse_line("  item  ,  42.0  ,  extra  ")
        self.assertEqual(result, {'key': 'item', 'value': 42.0, 'extra': 'extra'})
        self.assertEqual(len(self.parser.get_errors()), 0)

if __name__ == '__main__':
    unittest.main()