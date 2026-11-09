#!/bin/sh
set -eu

fixture=$(mktemp)
trap 'rm -f "$fixture"' EXIT
cat >"$fixture" <<'EOF'
Plain *paragraph*.

[source,python]
print('source')

.Title
[source,bash]
echo hi
EOF

output=$(tree-sitter query queries/injections.scm "$fixture" --captures 2>/dev/null)
content_count=$(printf '%s\n' "$output" | awk '/capture: [0-9]+ - injection.content/{count++} END{print count+0}')
python_count=$(printf '%s\n' "$output" | awk '/injection.language.*text: `python`/{count++} END{print count+0}')
bash_count=$(printf '%s\n' "$output" | awk '/injection.language.*text: `bash`/{count++} END{print count+0}')

if [ "$content_count" -ne 4 ] || [ "$python_count" -ne 1 ] || [ "$bash_count" -ne 1 ]; then
  printf '%s\n' "$output"
  exit 1
fi
