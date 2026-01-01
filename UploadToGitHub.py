from datetime import datetime
import os, pytz

os.chdir(os.path.dirname(os.path.abspath(__file__)))

project = "Pos"
branch = "main"

try:
  if input("Did you have a git repo installed? (y/n): ").lower()[0] == "n":
    os.system(f'''
    git init && \
    git remote add origin https://github.com/mido-ghanam/{project}.git
    ''')
except: pass

q = input("Adding a commit message? (Skip available): ")

os.system(f'''
git add . && \
git commit -m "| {datetime.now(pytz.timezone("Africa/Cairo")).strftime("%d-%m-%Y | %H:%M:%S")} | {f"{q} |" if q else ''}" && \
git branch -M {branch} && \
git push https://github.com/mido-ghanam/{project}.git {branch} --force
''')
