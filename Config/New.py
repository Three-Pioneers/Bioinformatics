import os
import sys
import configparser
from pathlib import Path
import pandas as pd

if len(sys.argv) == 1:
    print("Usage: python Transcriptome.py <config_file>")
    sys.exit(0)

conf = Path(sys.argv[1]).resolve()
project_dir = conf.parent

