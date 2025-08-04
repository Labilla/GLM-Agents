import unittest

def get_introduction():
    """Returns a brief introduction of who I am and what I can do."""
    return ("Ich bin ein KI-Coding-Assistent, der bei Programmieraufgaben hilft. "
            "Ich kann Code in verschiedenen Programmiersprachen (insb. Python) erstellen, "
            "analysieren, debuggen und verbessern. Ich arbeite iterativ mit Plan-Code-Run-Inspect "
            "und kann Unit-Tests erstellen und ausführen.")

class TestIntroduction(unittest.TestCase):
    def test_introduction(self):
        intro = get_introduction()
        self.assertIn("KI-Coding-Assistent", intro)
        self.assertIn("Python", intro)
        self.assertIn("debuggen", intro)
        self.assertTrue(len(intro) > 20)

if __name__ == "__main__":
    unittest.main(argv=['first-arg-is-ignored'], exit=False)
    print("\n" + "="*50)
    print(get_introduction())
    print("="*50)