#!/usr/bin/env bash
# Publishes the current commit to a second GitHub Pages repo that serves
# invite.thehiteshaakritiwedding.in. GitHub Pages allows one custom domain per
# repo, so the copy lives in its own repo and differs only in its CNAME file.
# Run it after every push to the main site. Needs git and the GitHub CLI (gh).
set -euo pipefail
REPO="${1:-aakriti-hitesh-wedding-invite}"
DOMAIN="invite.thehiteshaakritiwedding.in"
cd "$(dirname "$0")"
OWNER="$(gh api user -q .login)"
URL="https://github.com/$OWNER/$REPO.git"

NEW=0
if ! gh repo view "$OWNER/$REPO" >/dev/null 2>&1; then
  gh repo create "$OWNER/$REPO" --public \
    --description "Mirror of the wedding site, served on $DOMAIN" >/dev/null
  NEW=1
fi
if git remote get-url invite >/dev/null 2>&1; then
  git remote set-url invite "$URL"
else
  git remote add invite "$URL"
fi

# Build the tree of HEAD with only the CNAME swapped, without touching the
# working folder or the real index.
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
BLOB="$(printf '%s\n' "$DOMAIN" | git hash-object -w --stdin)"
TREE="$(
  export GIT_INDEX_FILE="$TMP/index"
  git read-tree HEAD
  git update-index --add --cacheinfo "100644,$BLOB,CNAME"
  git write-tree
)"

# Stack on the mirror's last commit so only changed files are uploaded.
PARENT=""
if git fetch -q invite main 2>/dev/null; then
  PARENT="$(git rev-parse FETCH_HEAD)"
fi
if [ -n "$PARENT" ] && [ "$(git rev-parse "$PARENT^{tree}")" = "$TREE" ]; then
  echo "https://$DOMAIN is already up to date."
else
  MSG="Mirror $(git rev-parse --short HEAD): $(git log -1 --format=%s HEAD)"
  COMMIT="$(git commit-tree "$TREE" ${PARENT:+-p "$PARENT"} -m "$MSG")"
  git push -q invite "$COMMIT:refs/heads/main"
  echo "Pushed $(git rev-parse --short HEAD) to $OWNER/$REPO."
fi

if [ "$NEW" = 1 ] || ! gh api "repos/$OWNER/$REPO/pages" >/dev/null 2>&1; then
  gh api -X POST "repos/$OWNER/$REPO/pages" -f "source[branch]=main" -f "source[path]=/" >/dev/null
  gh api -X PUT "repos/$OWNER/$REPO/pages" -f "cname=$DOMAIN" >/dev/null
  echo "Pages is on. Add this DNS record at your registrar:"
  echo "  CNAME   invite   $OWNER.github.io"
  echo "After GitHub issues the certificate, turn on HTTPS with:"
  echo "  gh api -X PUT repos/$OWNER/$REPO/pages -F https_enforced=true"
fi
