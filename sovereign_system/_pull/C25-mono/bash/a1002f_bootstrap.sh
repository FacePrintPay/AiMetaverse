#!/data/data/com.termux/files/usr/bin/bash
cd ~
tar -xzf c25-agents.tar.gz
bash agents/*/startup.sh &
