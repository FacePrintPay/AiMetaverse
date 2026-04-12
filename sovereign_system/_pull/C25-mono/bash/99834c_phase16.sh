find ~/repos -type f -exec sha256sum {} \; | sort | \
  awk '{if($1==p){system("rm "$2)}; p=$1}' # dedupe
