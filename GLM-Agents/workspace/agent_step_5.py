import re
import unittest

def is_palindrome(s):
    normalized = re.sub(r'[^a-z0-9]', '', s.lower())
    return normalized == normalized[::-1]

class TestIsPalindrome(unittest.TestCase):
    def test_simple_palindrome(self):
        self.assertTrue(is_palindrome("radar"))
        
    def test_non_palindrome(self):
        self.assertFalse(is_palindrome("hello"))
        
    def test_empty_string(self):
        self.assertTrue(is_palindrome(""))
        
    def test_case_insensitive(self):
        self.assertTrue(is_palindrome("RaceCar"))
        
    def test_with_spaces(self):
        self.assertTrue(is_palindrome("a man a plan a canal panama"))
        
    def test_with_punctuation(self):
        self.assertTrue(is_palindrome("A man, a plan, a canal: Panama"))

if __name__ == '__main__':
    unittest.main(verbosity=2)