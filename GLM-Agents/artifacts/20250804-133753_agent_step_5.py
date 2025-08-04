import unittest
import os

class TestBugTargetParser(unittest.TestCase):
    def setUp(self):
        self.test_file = "test_config.txt"
        with open(self.test_file, "w") as f:
            f.write("key1=value1\n\n\nkey2=value2\n   \nkey3=value3\ninvalid_line\n")

    def tearDown(self):
        if os.path.exists(self.test_file):
            os.remove(self.test_file)

    def test_skip_empty_lines(self):
        from agent_bootstrap.bug_target import parse_config
        result = parse_config(self.test_file)
        self.assertEqual(len(result), 3)
        self.assertEqual(result["key1"], "value1")
        self.assertEqual(result["key2"], "value2")
        self.assertEqual(result["key3"], "value3")

    def test_skip_invalid_lines(self):
        from agent_bootstrap.bug_target import parse_config
        result = parse_config(self.test_file)
        self.assertNotIn("invalid_line", result)

if __name__ == "__main__":
    unittest.main()