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
       <think></think>