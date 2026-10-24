#!/usr/bin/env bash
# Publishes this folder to GitHub Pages on thehiteshaakritiwedding.in.
# Needs git and the GitHub CLI (gh), signed in with `gh auth login`.
set -euo pipefail
REPO="${1:-aakriti-hitesh-wedding}"
DOMAIN="thehiteshaakritiwedding.in"
cd "$(dirname "$0")"
[ -d .git ] || git init -q -b main
git add -A
git commit -q -m "Wedding website" || true
gh repo create "$REPO" --public --source=. --remote=origin --push
OWNER="$(gh api user -q .login)"
gh api -X POST "repos/$OWNER/$REPO/pages" -f "source[branch]=main" -f "source[path]=/" >/dev/null
gh api -X PUT "repos/$OWNER/$REPO/pages" -f "cname=$DOMAIN" >/dev/null
echo "Pages is on. Now add the DNS records from README.md at your domain registrar."
echo "Once DNS is working the site is at https://$DOMAIN (until then: https://$OWNER.github.io/$REPO/)"
echo "After GitHub issues the certificate, turn on HTTPS with:"
echo "  gh api -X PUT repos/$OWNER/$REPO/pages -F https_enforced=true"
