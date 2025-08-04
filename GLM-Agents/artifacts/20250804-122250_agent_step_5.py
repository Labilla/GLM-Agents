import unittest
import os

def parse_config(file_path):
    config = {}
    with open(file_path, 'r') as f:
        for line in f:
            stripped = line.strip()
            if stripped and '=' in stripped:
                key, value = stripped.split('=', 1)
                config[key.strip()] = value.strip()
    return config

class TestBugTarget(unittest.TestCase):
    def setUp(self):
        self.test_file = "test_config.txt"
        with open(self.test_file, "w") as f:
            f.write("key1=value1\n\n\nkey2=value2\n   \nkey3=value3\n")

    def tearDown(self):
        if os.path.exists(self.test_file):
            os.remove(self.test_file)

    def test_skip_empty_lines(self):
        result = parse_config(self.test_file)
        expected = {"key1": "value1", "key2": "value2", "key3": "value3"}
        self.assertEqual(result, expected)

    def test_only_empty_lines(self):
        with open("empty_test.txt", "w") as f:
            f.write("\n\n   \n\n")
        result = parse_config("empty_test.txt")
        self.assertEqual(result, {})
        os.remove("empty_test.txt")

if __name__ == "__main__":
    unittest.main()