# UserMind Homebrew-Tap

| Formula | Was |
|---|---|
| `wpsync` | WordPress Live → Lokal ([UserMind2018/wpsync](https://github.com/UserMind2018/wpsync)) |

## Installation

```sh
brew tap usermind2018/tap
brew install wpsync
```

Update: `brew update && brew upgrade wpsync`

Homebrew baut `wpsync` aus dem Quellcode des Releases (Go wird dafür automatisch
installiert). Die Xcode Command Line Tools müssen zur macOS-Version passen – sonst meldet
Homebrew „Your Command Line Tools (CLT) does not support macOS …“ und nennt die
Update-Befehle. Die Agent-Plugin-ZIP liegt danach unter
`$(brew --prefix)/share/wpsync/wpsync-agent.zip`.

## Neue Version eintragen

1. In `Formula/wpsync.rb` `url` auf den neuen Tag setzen und `sha256` anpassen:
   ```sh
   curl -sL https://github.com/UserMind2018/wpsync/archive/refs/tags/vX.Y.Z.tar.gz | shasum -a 256
   ```
2. Prüfen:
   ```sh
   brew reinstall --build-from-source usermind2018/tap/wpsync && brew test wpsync
   ```
3. Committen und pushen.
