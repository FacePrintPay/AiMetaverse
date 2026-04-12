find ~/repos -maxdepth 1 -type d | sed -n '61,70p' | while read repo; do
  cd $repo
  npm run build 2>/dev/null || python setup.py build 2>/dev/null
done
