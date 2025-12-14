import pytest
import sys

if __name__ == "__main__":
    with open("test_output_utf8.txt", "w", encoding="utf-8") as f:
        sys.stdout = f
        sys.stderr = f
        sys.exit(pytest.main(["tests/test_streak_achievements.py", "-s", "-vv"]))
