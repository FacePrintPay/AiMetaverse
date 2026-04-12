find ~/repos -name ".git" | while read git; do
  cd ${git%/.git}
  git add -A && git commit -m "C25 auto-build" && git push
done
