# 004. 完成した salome915 イメージを Windows / Mac の受講者に配布する

[002_install_salome915.md](002_install_salome915.md) で `salome915` イメージが完成し、`mesa_salome` の起動まで確認できている前提で、このイメージを Docker Hub へ公開し、Windows / Mac の受講者が `docker pull` するだけで使えるようにする手順を扱う。

```text
講師のPC
  └─ salome915 イメージ（完成済み）
        ↓ docker push
     Docker Hub（公開リポジトリ）
        ↓ docker pull
  ┌───────────────┬───────────────┐
  受講者(Windows)      受講者(Mac)
  WSLg でGUI表示        XQuartz でGUI表示
```

---

# 1. Docker Hub アカウントを作成する

以下にアクセスし、個人アカウントを作成する。

```text
https://hub.docker.com/
```

ここで決めたユーザー名が、そのままイメージ名の一部になる。

例えばユーザー名を `yourname` とした場合、公開するイメージ名は、

```text
yourname/salome915
```

のようになる（Docker Hubでは `ユーザー名/イメージ名` の形式で公開する）。

今回使用するユーザー名は `kamakiri734`。よって公開するイメージ名は、

```text
kamakiri734/salome915
```

になる。

---

# 2. WSL から Docker Hub にログインする

WSL Ubuntu 上で実行する。

```bash
docker login
```

Docker Hub のユーザー名とパスワード（またはアクセストークン）を入力する。

```text
Login Succeeded
```

と表示されればOK。

---

# 3. イメージにタグを付ける

## 3-0. 全体の流れと、結局どちらのタグを使うか

タグは2種類作るが、**用途が違う**。

```text
salome915（ローカル）
   │
   ├─ docker tag ─→ kamakiri734/salome915:latest       …①講師の管理用
   │
   └─ docker tag ─→ kamakiri734/salome915:2026-08-30    …②受講者に配る用
```

- ① `latest` は「常に最新」を指すエイリアス。今後Dockerfileを直して作り直したときに、このタグだけ上書きしていく。**講師が自分の作業を続けるための目印**であって、受講者に案内するものではない。
- ② `2026-08-30` は講義当日時点のイメージを固定したタグ。あとで①`latest`を更新しても、②の中身は変わらない。**受講者には必ずこちらを案内する。**

理由：受講者全員が講義中に`docker pull ... latest`していると、講師が裏で`latest`を更新した瞬間に「人によって中身が違うイメージを使っている」状態になりかねない。日付で固定したタグなら、講義中は絶対に中身が変わらないので事故が起きない。

流れとしては、

```text
1. salome915 イメージが完成している（002で確認済み）
        ↓
2. docker tag で ①latest と ②2026-08-30 の両方を作る（このセクション）
        ↓
3. docker push で両方を Docker Hub へアップロードする（4章）
        ↓
4. 受講者には ②2026-08-30 の pull コマンドだけを案内する（6章・7章）
```

①`latest`のタグ付け・pushは省略しても構わない（無くても受講者は困らない）。両方作るのは、講師側の運用を楽にするための保険。

現在ローカルにある `salome915` イメージに、Docker Hub 用の名前を付け直す。

```bash
docker tag salome915 kamakiri734/salome915:latest
```

さらに、講義当日に受講者が使うイメージが後から変わらないよう、日付などのバージョンタグも付けておく。

```bash
docker tag salome915 kamakiri734/salome915:2026-08-30
```

コマンドの意味：

```text
docker tag
→ 既存のイメージに新しい名前(タグ)を付ける。
  イメージの中身をコピーするわけではなく、同じイメージデータに
  複数の名前(エイリアス)を付けるだけなので、ディスク容量は増えない。

kamakiri734/salome915:latest
→ 「常に最新版」を指す名前。今後アップデートしたときはこのタグを更新する。

kamakiri734/salome915:2026-08-30
→ 講義当日時点のイメージを指す固定の名前。
  latest を後から更新しても、このタグのイメージ内容は変わらない。
  受講者にはこちらの日付タグを案内すると、当日「pullし直したら
  中身が変わっていた」という事故を防げる。
```

確認：

```bash
docker images
```

```text
REPOSITORY                TAG          IMAGE ID       SIZE
salome915                 latest       xxxxxxxxxxxx   ...
kamakiri734/salome915  latest       xxxxxxxxxxxx   ...
kamakiri734/salome915  2026-08-30   xxxxxxxxxxxx   ...
```

同じ `IMAGE ID` であれば、正しくタグ付けできている。

---

# 4. Docker Hub へ push する

```bash
docker push kamakiri734/salome915:latest
docker push kamakiri734/salome915:2026-08-30
```

`salome915` イメージには SALOME 本体（展開後 約6.8GB）と各種ライブラリが含まれているため、イメージサイズは数GB〜10GB程度になる。アップロードには時間がかかるので、講義前日までに済ませておく。

進捗は、

```bash
docker push kamakiri734/salome915:latest
```

実行中のターミナルに各レイヤーの `Pushing` / `Pushed` 表示で確認できる。

---

# 5. Docker Hub 側で公開設定を確認する

ブラウザで Docker Hub にログインし、該当リポジトリのページを開く。

```text
https://hub.docker.com/r/kamakiri734/salome915
```

リポジトリの設定（Settings）で、

```text
Visibility: Public
```

になっていることを確認する。Private のままだと、受講者が `docker pull` してもアクセス拒否になる。

---

# 6. 受講者側（Windows）の利用手順

前提として、受講者は [000_docker_setup.md](000_docker_setup.md) の手順で Docker Desktop（WSL2 + WSLg）を準備しておく。

WSL Ubuntu 上で、イメージを取得する。

```bash
docker pull --platform linux/amd64 kamakiri734/salome915:2026-08-30
```

作業フォルダを用意する。

```bash
mkdir -p ~/salome_work
```

コンテナを起動する。

```bash
docker run --rm -it --platform linux/amd64 -e DISPLAY=:0 -v /mnt/wslg/.X11-unix:/tmp/.X11-unix -v ~/salome_work:/work kamakiri734/salome915:2026-08-30
```

各オプションの意味は [003_launch_salome.md](003_launch_salome.md) の「1-2. コンテナを起動する」と同じ（イメージ名だけが `salome915` から `kamakiri734/salome915:2026-08-30` に変わっている。`/mnt/f` の受講者用マウントは不要なので付けていない）。

以降の `xclock` での確認、`/opt/salome/mesa_salome` の起動も [003_launch_salome.md](003_launch_salome.md) の「1-3」「1-4」と同じ。

---

# 7. 受講者側（Mac）の利用手順

XQuartzのインストール・設定（`Allow connections from network clients`の有効化）、`xhost +localhost`によるX11接続許可の手順は [003_launch_salome.md](003_launch_salome.md) の「2-1」「2-2」を参照。受講者にも同じ手順を案内する。

イメージを取得する。

```bash
docker pull --platform linux/amd64 kamakiri734/salome915:2026-08-30
```

Apple Silicon Mac でも `--platform linux/amd64` を明示して取得する（Rosetta相当のエミュレーションで動作する）。

作業フォルダを用意する。

```bash
mkdir -p ~/salome_work
```

コンテナを起動する。

```bash
docker run --rm -it --platform linux/amd64 -e DISPLAY=host.docker.internal:0 -v ~/salome_work:/work kamakiri734/salome915:2026-08-30
```

各オプションの意味（`DISPLAY=host.docker.internal:0` を使う理由など）は [003_launch_salome.md](003_launch_salome.md) の「2-3」と同じ（イメージ名だけが `salome915` から `kamakiri734/salome915:2026-08-30` に変わっている）。

以降の `xclock` での確認、`/opt/salome/mesa_salome` の起動も [003_launch_salome.md](003_launch_salome.md) の「2-4」と同じ。

---

# 8. 配布時の注意点

```text
イメージサイズ
→ 数GB〜10GB程度あるため、受講者の回線が遅い/会場Wi-Fiが混雑する
  場合は pull に時間がかかる。可能なら講義前に各自ダウンロードを
  済ませておくよう案内する。

バージョンタグ
→ 受講者には latest ではなく 2026-08-30 のような固定タグを案内する。
  講師側が後から latest を更新しても、受講者の環境が意図せず
  変わらないようにするため。

Apple Silicon Mac
→ linux/amd64 イメージをエミュレーションで動かすため、Intel Macより
  動作が遅くなる場合がある。事前に軽い動作確認をしておくとよい。
```

---

# 9. 現在地

現在、以下まで完了している。

- [ ] Docker Hubアカウント作成
- [ ] `docker login`
- [ ] `docker tag` でイメージ名を付け替え
- [ ] `docker push` でDocker Hubへ公開
- [ ] リポジトリのVisibilityがPublicであることを確認
- [ ] Windows受講者側での動作確認（別PCまたはクリーンな環境で）
- [ ] Mac受講者側での動作確認（XQuartz）
