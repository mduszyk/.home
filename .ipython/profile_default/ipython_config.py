import os
import sys

c = get_config()

c.TerminalInteractiveShell.term_title = True

def generate_title():
    version = sys.version.split()[0]
    current_dir = os.getcwd()
    return f"ipython{version} {current_dir}"

c.TerminalInteractiveShell.term_title_format = generate_title()

