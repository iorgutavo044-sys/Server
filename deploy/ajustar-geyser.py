#!/usr/bin/env python3
"""Ajusta o config.yml do Geyser para Floodgate e Bedrock via NetherNet."""
import re
import shutil
import sys
from pathlib import Path

def configure(path):
    if not path.is_file():
        raise FileNotFoundError(str(path))
    original=path.read_text(encoding="utf-8")
    lines=original.splitlines(keepends=True)
    def set_key(blocks,key,value):
        start=None
        for i,line in enumerate(lines):
            m=re.match(r"^([A-Za-z0-9_-]+):\s*(?:#.*)?$",line.strip("\r\n"))
            if m and m.group(1) in blocks:
                start=i
                break
        if start is None:
            return False
        end=len(lines)
        for i in range(start+1,len(lines)):
            if re.match(r"^[A-Za-z0-9_-]+:\s*(?:#.*)?$",lines[i].strip("\r\n")):
                end=i
                break
        matcher=re.compile(r"^(\s+)(?:#\s*)?"+re.escape(key)+r":\s*.*$")
        for i in range(start+1,end):
            m=matcher.match(lines[i].rstrip("\r\n"))
            if m:
                lines[i]=f"{m.group(1)}{key}: {value}\n"
                return True
        lines.insert(start+1,f"  {key}: {value}\n")
        return True
    success=[
        set_key(("bedrock",),"port","19132"),
        set_key(("bedrock",),"transport","nethernet"),
        set_key(("bedrock",),"clone-remote-port","false"),
        set_key(("java","remote"),"auth-type","floodgate"),
    ]
    if not all(success):
        raise ValueError("Config do Geyser mudou; veja https://geysermc.org/wiki/geyser/setup/")
    result="".join(lines)
    if result!=original:
        backup=path.with_suffix(".yml.antes-rafael.bak")
        if not backup.exists():
            shutil.copy2(path,backup)
        path.write_text(result,encoding="utf-8")
    print("Geyser configurado. Reinicie Minecraft.")

if __name__=="__main__":
    try:
        configure(Path(sys.argv[1]))
    except (IndexError,FileNotFoundError,ValueError) as e:
        sys.exit(f"ERRO: {e}")
