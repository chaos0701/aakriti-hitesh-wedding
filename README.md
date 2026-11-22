# Aakriti & Hitesh — wedding website

Static site for GitHub Pages on **thehiteshaakritiwedding.in**: `index.html`, full-quality scroll frames in `hd/` (1920×1080 WebP, every frame of the 24 fps film), low-res preview frames in `pv/`, the portrait cut for phones in `hd-m/` (720×1280) and `pv-m/`, `logo.png` as the favicon, and a `CNAME` file holding the domain.

## 1. Publish to GitHub Pages

**With the GitHub CLI**

```bash
gh auth login          # once
./deploy.sh
```

This creates a public repo, pushes the site, turns on Pages from `main` and sets the custom domain.

**Or on github.com**

1. Create a new **public** repository (for example `aakriti-hitesh-wedding`).
2. Choose **uploading an existing file** and drag in everything from this folder, including `hd`, `pv`, `hd-m`, `pv-m` and `CNAME`. Commit.
3. **Settings → Pages**: Source *Deploy from a branch*, branch `main`, folder `/ (root)`. Save.
4. On the same page, under **Custom domain**, enter `thehiteshaakritiwedding.in` and save.

## 2. Point the domain at GitHub (at your registrar's DNS settings)

Remove any existing A / AAAA records on the root domain (`@`) first, for example parking-page records, then add:

| Type  | Host / Name | Value                     |
|-------|-------------|---------------------------|
| A     | @           | 185.199.108.153           |
| A     | @           | 185.199.109.153           |
| A     | @           | 185.199.110.153           |
| A     | @           | 185.199.111.153           |
| AAAA  | @           | 2606:50c0:8000::153       |
| AAAA  | @           | 2606:50c0:8001::153       |
| AAAA  | @           | 2606:50c0:8002::153       |
| AAAA  | @           | 2606:50c0:8003::153       |
| CNAME | www         | `<your-github-username>.github.io` |

The AAAA records are optional but recommended. With the `www` record, www.thehiteshaakritiwedding.in redirects to the main address.

## 3. Turn on HTTPS

DNS can take from a few minutes to a few hours to update. When **Settings → Pages** shows the DNS check as successful, tick **Enforce HTTPS** (GitHub issues the certificate automatically; this can take up to about an hour after DNS works).

Optional but recommended: verify the domain under your GitHub account **Settings → Pages → Add a domain**, so no one else's repository can claim it.

## Notes

- Keep `hd/`, `pv/`, `hd-m/` and `pv-m/` next to `index.html`; the page streams the frames from there, nearest the viewer's scroll position first.
- To preview locally, run `python3 -m http.server` in this folder and open http://localhost:8000. Double-clicking `index.html` won't load the full-quality frames.
