# Option C: Homebrew Tap

## Setup

1. Create a new repo: `davidteren/homebrew-tap`
2. Add the formula file below as `Formula/lpx-links.rb`
3. Users install with:

```bash
brew tap davidteren/tap
brew install lpx-links
```

Then run:

```bash
lpx-links                  # Logic Pro (default)
lpx-links -n GarageBand    # GarageBand
lpx-links -n Mainstage     # MainStage
```

## Notes

- Homebrew automatically handles aria2 as a dependency
- `brew upgrade lpx-links` picks up new versions
- Only useful for users who already have Homebrew
