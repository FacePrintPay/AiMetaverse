json_escape() {
  # Read all stdin into a variable, escape \, " and newlines
  local input
  input="$(cat)"

  # Escape backslashes
  input=${input//\\/\\\\}
  # Escape double quotes
  input=${input//\"/\\\"}
  # Turn newlines into \n so JSON stays on one line
  input=${input//$'\n'/\\n}

  printf '%s' "$input"
}
