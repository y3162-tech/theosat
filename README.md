# (開発者向け) GitHub Pages の有効化

* Settings
* Build and deployment
  * Source : 'Deploy from a branch'
  * Branch : 'main'
  * Folder : '/ (root)'

## Sileoへの追加

次のURLをSileoへ追加する。

```text
https://<GitHubユーザー名>.github.io/theosat/
```

## インストール

```sh
sh install-theosat.sh [iPhone-IP] [repository-url] [package-id]
```

引数を省略すると、既定のURLとパッケージIDを使う。
IPアドレスを省略した場合は `IPHONE_IP_ADDRESS` を使う。

## アンインストール

```sh
sh uninstall-theosat.sh [iPhone-IP]
```

アンインストーラーは `com.yourcompany.theosat` とTheosAT専用のAPTソースを削除する。

## 更新

新しい`.deb`を`debs/`へ追加または差し替えた後、リポジトリのルートで実行する。

```sh
bash update-repo.sh
git <operation> ...
```
