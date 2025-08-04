import unittest
import os

class TestBugTarget(unittest.TestCase):
    def setUp(self):
        self.test_file = "test_config.txt"
        with open(self.test_file, "w") as f:
            f.write("key1=value1\n\n\nkey2=value2\n   \nkey3=value3\n")

    def tearDown(self):
        if os.path.exists(self.test_file):
            os.remove(self.test_file)

    def test_skip_empty_lines(self):
        from agent_bootstrap.bug_target import parse_config
        result = parse_config(self.test_file)
        expected = {"key1": "value1", "key2": "value2", "key3": "value3"}
        self.assertEqual(result, expected)

if __name__ == "__main__":
    unittest.main()