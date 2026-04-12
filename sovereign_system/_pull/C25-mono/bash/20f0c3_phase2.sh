find ~/repos -name "*.sh" -exec bash -n {} \; 2>&1 | tee ~/logs/validation.log
find ~/repos -name "*.log" -mtime +7 -delete
