# SALOME 9.15.0 を Docker で使う（受講者向け）

配布された Docker イメージを使って、Windows / Mac で SALOME 9.15.0 のGUIを起動する手順。

イメージ名（配布用）:

```text
kamakiri734/salome915:2026-08-30
```

GUIはブラウザではなく、SALOME本来のGUIウィンドウを直接表示する方式。WindowsではWSLg、MacではXQuartzを使う。

---

## 0. 事前準備：Docker Desktop をインストールする

Windows / Mac どちらも、まず Docker Desktop をインストールする。

```text
https://www.docker.com/products/docker-desktop/
```

- Windows: インストール時に「Use WSL 2 based engine」を有効にする。インストール後、Docker Desktopの `Settings → Resources → WSL Integration` で使用するUbuntuディストリビューションを有効にしておく。
- Mac: 自分のMacがApple Silicon（M1/M2/M3等）かIntelかに合わせたインストーラーを選ぶ。

インストール後、Docker Desktopを起動したままにしておく（左下に `Engine running` と表示されていればOK）。

### Windows: WSL(Ubuntu)が入っていない場合

WindowsにまだUbuntu(WSL)が入っていない場合は、PowerShellを管理者として開き、

```powershell
wsl --install -d Ubuntu
```

を実行する（PC再起動を求められることがある）。初回起動時にUbuntu側のユーザー名・パスワードを設定する。

### Windows: どのターミナルを使うか

**この文書のWindows向けコマンド（`docker pull`, `docker run`, `echo $DISPLAY` など）は、すべて「Ubuntu(WSL)」のターミナルの中で実行する。** PowerShellやコマンドプロンプト（cmd）ではない。

Ubuntuターミナルの開き方:

```text
スタートメニュー → 「Ubuntu」と検索 → クリックして起動
```

または、Windows Terminal / PowerShell を開いてから、

```powershell
wsl
```

と入力するとUbuntu側に切り替わる。

黒い画面に、

```text
username@PC名:~$
```

のようなプロンプトが出ていれば、そこがUbuntu(WSL)のターミナル。以降の手順（1-1〜1-6）はすべてここで行う。

---

## 1. Windowsで使う

### 1-1. GUI表示の準備を確認する

WSLのUbuntuを起動し、

```bash
echo $DISPLAY
```

を実行して `:0` と表示されることを確認する。続けて、

```bash
ls /mnt/wslg/.X11-unix
```

を実行して `X0` が表示されることを確認する（WindowsのWSLgがGUI表示の受け口を用意している）。

### 1-2. イメージを取得する

```bash
docker pull --platform linux/amd64 kamakiri734/salome915:2026-08-30
```

### 1-3. 作業フォルダを用意する

```bash
mkdir -p ~/salome_work
```

SALOMEで保存したファイルはここに残る（コンテナを終了しても消えない）。

### 1-4. コンテナを起動する

```bash
docker run --rm -it --platform linux/amd64 -e DISPLAY=:0 -v /mnt/wslg/.X11-unix:/tmp/.X11-unix -v ~/salome_work:/work kamakiri734/salome915:2026-08-30
```

オプションの意味:

```text
--rm
→ コンテナ終了時に自動で削除する（イメージ本体は消えないので、また docker run すれば起動できる）

-it
→ 対話的にターミナル操作するためのオプション

--platform linux/amd64
→ Intel/AMD 64bit Linux向けのイメージとして起動する指定

-e DISPLAY=:0
→ GUIアプリ(SALOME)に「どの画面に描画すればよいか」を伝える環境変数。
  ":0" はWindows側のWSLgが用意している画面番号。

-v /mnt/wslg/.X11-unix:/tmp/.X11-unix
→ ホスト(WSL)側のX11用ソケットを、コンテナ内の同じ場所に重ねて見せる。
  これと DISPLAY=:0 が揃って初めて、コンテナ内のSALOMEのウィンドウが
  Windowsのデスクトップに直接表示される。

-v ~/salome_work:/work
→ ホスト側の ~/salome_work を、コンテナ内の /work に重ねて見せる。
  ここに保存すればホスト側にファイルが残る。
```

成功すると、

```text
salome@xxxxxxxx:/work$
```

のようなプロンプトになる。

### 1-5. GUI表示を確認する

いきなりSALOMEを起動せず、まず

```bash
xclock
```

を実行する。Windowsデスクトップ上に時計のウィンドウが表示されればGUI表示は成功。`xclock`を終了して次へ進む。

### 1-6. SALOMEを起動する

```bash
/opt/salome/mesa_salome
```

Windows上にSALOME 9.15.0のGUIウィンドウが表示されれば完了。

---

## 2. Macで使う

### 2-1. XQuartzをインストールする

```text
https://www.xquartz.org/
```

からダウンロードしてインストールする。インストール後、一度ログアウト/再ログイン（またはMac再起動）が必要な場合がある。

### 2-2. XQuartzを設定する

XQuartzを起動し、メニューから、

```text
XQuartz → 設定（Preferences） → セキュリティ（Security）
```

を開き、

```text
Allow connections from network clients
```

にチェックを入れる。設定後、XQuartzを再起動する。

### 2-3. X11接続を許可する

Macのターミナルで実行する。

```bash
xhost +localhost
```

### 2-4. イメージを取得する

```bash
docker pull --platform linux/amd64 kamakiri734/salome915:2026-08-30
```

Apple Silicon Macでも `--platform linux/amd64` を明示して取得する（エミュレーションで動作する）。

### 2-5. 作業フォルダを用意する

```bash
mkdir -p ~/salome_work
```

### 2-6. コンテナを起動する

```bash
docker run --rm -it --platform linux/amd64 -e DISPLAY=host.docker.internal:0 -v ~/salome_work:/work kamakiri734/salome915:2026-08-30
```

Windows版との違い:

```text
-e DISPLAY=host.docker.internal:0
→ MacにはWSLgのようなLinux用X11ソケットが存在しないため、コンテナから
  Macホスト上のXQuartzへネットワーク経由(TCP)で接続する。
  host.docker.internal は「コンテナから見たホストMac」を指す特別な
  ホスト名で、Docker Desktopが自動的に用意する。

/mnt/wslg/.X11-unix のマウントが無い
→ WSLg特有のソケット共有はMacには存在しないため不要。代わりに
  DISPLAY=host.docker.internal:0 と 2-3 の xhost +localhost の
  組み合わせでGUIを表示する。
```

### 2-7. GUI表示を確認する

```bash
xclock
```

を実行し、Macのデスクトップに時計が表示されれば成功。

### 2-8. SALOMEを起動する

```bash
/opt/salome/mesa_salome
```

MacにSALOME 9.15.0のGUIウィンドウが表示されれば完了。

---

## 3. 動作確認の目安

一通り操作して問題ないか確認する。

```text
SALOME 起動
↓
Geometry で Box 作成
↓
Mesh でメッシュ生成（NETGEN等）
↓
MED形式で保存・再読込
↓
ParaVis で結果表示
```

---

## 4. うまくいかないとき

- `docker: image not found` 等が出る → `docker pull` からやり直す。タグ（`2026-08-30`）を打ち間違えていないか確認する。
- GUIが表示されない（Windows） → `1-1` の `$DISPLAY` と `/mnt/wslg/.X11-unix` の確認からやり直す。
- GUIが表示されない（Mac） → `2-2` の XQuartz 設定と `2-3` の `xhost +localhost` を再確認する。
- 動作が重い → ソフトウェアレンダリング(mesa_salome)で動かしているため、GPUを使う場合より3D表示は遅い。Apple Siliconの場合はエミュレーションも重なるため、シンプルなモデルで一度事前に試しておくとよい。
