import unittest
import os

# Minimal implementation of parse_config function
def parse_config(file_path):
    config = {}
    with open(file_path, 'r') as f:
        for line in f:
            stripped = line.strip()
            if stripped and '=' in stripped:
                key, value = stripped.split('=', 1)
                config[key.strip()] = value.strip()
    return config

class TestBugTargetParser(unittest.TestCase):
    def setUp(self):
        self.test_file = "test_config.txt"
        with open(self.test_file, "w") as f:
            f.write("key1=value1\n\n\nkey2=value2\n   \nkey3=value3\ninvalid_line\n")

    def tearDown(self):
        if os.path.exists(self.test_file):
            os.remove(self.test_file)

    def test_skip_empty_lines(self):
        result = parse_config(self.test_file)
        self.assertEqual(len(result), 3)
        self.assertEqual(result["key1"], "value1")
        self.assertEqual(result["key2"], "value2")
        self.assertEqual(result["key3"], "value3")

    def test_skip_invalid_lines(self):
        result = parse_config(self.test_file)
        self.assertNotIn("invalid_line", result)

if __name__ == "__main__":
    unittest.main()