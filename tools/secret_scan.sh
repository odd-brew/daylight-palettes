#!/bin/bash
# Fail when a committed file contains a credential-shaped token.
# Print the path only. Never print the match.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

fail=0
while IFS= read -r -d '' file; do
    if grep -I -E -q \
        -e 'ghp_[A-Za-z0-9]{20,}' \
        -e 'github_pat_[A-Za-z0-9_]{20,}' \
        -e 'AKIA[0-9A-Z]{16}' \
        -e '-----BEGIN [A-Z ]*PRIVATE KEY-----' \
        -e 'xox[baprs]-[0-9A-Za-z-]{10,}' \
        -e 'sk_live_[0-9A-Za-z]{16,}' \
        "$file"
    then
        echo "secret-scan: credential pattern in ${file#./}"
        fail=1
    fi
done < <(find . -type f -not -path './.git/*' -print0)

if [ "$fail" -ne 0 ]; then
    exit 1
fi

echo "secret-scan: no credential patterns"
