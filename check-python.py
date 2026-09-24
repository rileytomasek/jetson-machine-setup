"""Verify the configured Python version and a usable standard library."""

import ssl
import sqlite3
import sys
import venv


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("Usage: check-python.py MAJOR.MINOR")

    expected = sys.argv[1]
    actual = f"{sys.version_info.major}.{sys.version_info.minor}"
    if actual != expected:
        raise SystemExit(f"Expected Python {expected}; found {sys.version} at {sys.executable}")

    print(f"Python {actual} standard library checks passed")


if __name__ == "__main__":
    main()
