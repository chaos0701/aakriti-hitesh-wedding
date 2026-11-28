#!/usr/bin/env bash
# Publishes the current commit to the extra GitHub Pages repos that serve the
# site's subdomains (invite. and card.thehiteshaakritiwedding.in). GitHub Pages
# allows one custom domain per repo, so each copy lives in its own repo and
# differs only in its CNAME file.
# Run it after every push to the main site. Needs git and the GitHub CLI (gh).
#   ./deploy-mirrors.sh          # all subdomains
#   ./deploy-mirrors.sh card     # just one
set -euo pipefail
APEX="thehiteshaakritiwedding.in"
BASE="aakriti-hitesh-wedding"
SUBS=(invite card)
[ "$#" -gt 0 ] && SUBS=("$@")
cd "$(dirname "$0")"
OWNER="$(gh api user -q .login)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mirror() {
  local SUB="$1" REPO="$BASE-$1" DOMAIN="$1.$APEX" NEW=0
  local URL="https://github.com/$OWNER/$REPO.git" BLOB TREE PARENT="" MSG COMMIT

  if ! gh repo view "$OWNER/$REPO" >/dev/null 2>&1; then
    gh repo create "$OWNER/$REPO" --public \
      --description "Mirror of the wedding site, served on $DOMAIN" >/dev/null
    NEW=1
  fi
  if git remote get-url "$SUB" >/dev/null 2>&1; then
    git remote set-url "$SUB" "$URL"
  else
    git remote add "$SUB" "$URL"
  fi

  # Build the tree of HEAD with only the CNAME swapped, without touching the
  # working folder or the real index.
  BLOB="$(printf '%s\n' "$DOMAIN" | git hash-object -w --stdin)"
  TREE="$(
    export GIT_INDEX_FILE="$TMP/index-$SUB"
    git read-tree HEAD
    git update-index --add --cacheinfo "100644,$BLOB,CNAME"
    git write-tree
  )"

  # Stack on the mirror's last commit so only changed files are uploaded.
  if git fetch -q "$SUB" main 2>/dev/null; then
    PARENT="$(git rev-parse FETCH_HEAD)"
  fi
  if [ -n "$PARENT" ] && [ "$(git rev-parse "$PARENT^{tree}")" = "$TREE" ]; then
    echo "https://$DOMAIN is already up to date."
  else
    MSG="Mirror $(git rev-parse --short HEAD): $(git log -1 --format=%s HEAD)"
    COMMIT="$(git commit-tree "$TREE" ${PARENT:+-p "$PARENT"} -m "$MSG")"
    git push -q "$SUB" "$COMMIT:refs/heads/main"
    echo "Pushed $(git rev-parse --short HEAD) to $OWNER/$REPO."
  fi

  if [ "$NEW" = 1 ] || ! gh api "repos/$OWNER/$REPO/pages" >/dev/null 2>&1; then
    gh api -X POST "repos/$OWNER/$REPO/pages" -f "source[branch]=main" -f "source[path]=/" >/dev/null
    gh api -X PUT "repos/$OWNER/$REPO/pages" -f "cname=$DOMAIN" >/dev/null
    echo "Pages is on. Add this DNS record at your registrar:"
    echo "  CNAME   $SUB   $OWNER.github.io"
    echo "After GitHub issues the certificate, turn on HTTPS with:"
    echo "  gh api -X PUT repos/$OWNER/$REPO/pages -F https_enforced=true"
  fi
}

for SUB in "${SUBS[@]}"; do mirror "$SUB"; done
