<!-->
# GitHub Pages の有効化

* Settings
* Build and deployment
  * Source : 'Deploy from a branch'
  * Branch : 'main'
  * Folder : '/ (root)'

-->

## Sileoへの追加

次のURLをSileoへ追加します。

```text
https://<GitHubユーザー名>.github.io/theosat/
```

## 更新

新しい`.deb`を`debs/`へ追加または差し替えた後、リポジトリのルートで実行します。

```sh
bash update-repo.sh
git <operation> ...
```
