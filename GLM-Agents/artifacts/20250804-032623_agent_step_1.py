import unittest

def is_palindrome(s):
    """Überprüft, ob ein String ein Palindrom ist."""
    if not isinstance(s, str):
        raise TypeError("Eingabe muss ein String sein")
    s = s.lower().replace(" ", "")
    return s == s[::-1]

class TestPalindrome(unittest.TestCase):
    def test_palindromes(self):
        self.assertTrue(is_palindrome("Anna"))
        self.assertTrue(is_palindrome("Lagerregal"))
        self.assertTrue(is_palindrome("Ein Neger mit Gazelle zagt im Regen nie"))
    
    def test_non_palindromes(self):
        self.assertFalse(is_palindrome("Hallo"))
        self.assertFalse(is_palindrome("Python"))
        self.assertFalse(is_palindrome("Test"))
    
    def test_empty_string(self):
        self.assertTrue(is_palindrome(""))
    
    def test_case_insensitive(self):
        self.assertTrue(is_palindrome("Anna"))
        self.assertTrue(is_palindrome("ANNA"))
    
    def test_with_spaces(self):
        self.assertTrue(is_palindrome("A man a plan a canal Panama"))
    
    def test_non_string_input(self):
        with self.assertRaises(TypeError):
            is_palindrome(123)
        with self.assertRaises(TypeError):
            is_palindrome(None)

if __name__ == "__main__":
    unittest.main()