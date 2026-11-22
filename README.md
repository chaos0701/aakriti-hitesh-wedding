# Aakriti & Hitesh — wedding website

Static site for GitHub Pages on **thehiteshaakritiwedding.in**: `index.html`, full-quality scroll frames in `hd/` (1920×1080 WebP, every frame of the 24 fps film), low-res preview frames in `pv/`, the portrait cut for phones as one small video `film-m.mp4` (540×960, 20 fps, keyframe every 5 frames, no audio; scrubbed by scroll) with `film-m.webp` as its poster, `logo.png` as the favicon, and a `CNAME` file holding the domain.

## 1. Publish to GitHub Pages

**With the GitHub CLI**

```bash
gh auth login          # once
./deploy.sh
```

This creates a public repo, pushes the site, turns on Pages from `main` and sets the custom domain.

**Or on github.com**

1. Create a new **public** repository (for example `aakriti-hitesh-wedding`).
2. Choose **uploading an existing file** and drag in everything from this folder, including `hd`, `pv`, `film-m.mp4`, `film-m.webp` and `CNAME`. Commit.
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

- Keep `hd/`, `pv/`, `film-m.mp4` and `film-m.webp` next to `index.html`. Landscape screens stream the frames from `hd/` and `pv/`, nearest the viewer's scroll position first; portrait screens download only `film-m.mp4` and seek it.
- To rebuild the phone video from the portrait source:
  `ffmpeg -i portrait.mp4 -an -vf "scale=540:-2,fps=20" -c:v libx264 -profile:v main -crf 33 -preset slow -pix_fmt yuv420p -g 5 -movflags +faststart film-m.mp4`
- To preview locally, run `python3 -m http.server` in this folder and open http://localhost:8000. Double-clicking `index.html` won't load the full-quality frames.
