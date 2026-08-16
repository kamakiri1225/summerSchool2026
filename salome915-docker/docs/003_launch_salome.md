# 003. Dockerで作ったSALOME 9.15を起動する

[002_install_salome915.md](002_install_salome915.md) で `salome915` イメージが完成した前提で、実際にコンテナを起動してSALOMEのGUIをWindows/Mac側の画面に表示するところまでを扱う。

GUIはブラウザ(noVNC)ではなく、SALOME本来のGUIウィンドウをX11経由で直接表示する方式。WindowsではWSLg、MacではXQuartzを使う。

---

# 1. WindowsでGUIを直接表示する準備

WindowsではWSLgを使う。

WSL側で、

```bash
echo $DISPLAY
```

を確認する。

通常、

```text
:0
```

である。

続いて、

```bash
ls /mnt/wslg/.X11-unix
```

を確認する。

通常、

```text
X0
```

が表示される。

---

# 2. Windowsでコンテナ起動

```bash
mkdir -p ~/salome_work
```

起動:

```bash
docker run --rm -it --platform linux/amd64 -e DISPLAY=:0 -v /mnt/wslg/.X11-unix:/tmp/.X11-unix -v ~/salome_work:/work salome915
```

コマンドの意味：

```text
docker run
→ イメージからコンテナを起動する

--rm
→ コンテナを終了したときに、そのコンテナ（実行中の入れ物）を自動的に削除する。
  イメージ本体(salome915)は消えないので、次回また docker run すれば起動できる。

-it
→ 対話的にターミナル操作するためのオプション（-i: 標準入力を受け付ける、
  -t: 見やすいターミナル画面にする）。これがないとコンテナ内でコマンドを打てない。

--platform linux/amd64
→ ビルド時と同じくamd64として起動する指定。ビルドしたイメージがamd64なので合わせる。

-e DISPLAY=:0
→ コンテナの中に環境変数 DISPLAY=:0 を渡す。GUIアプリ(SALOMEなど)は、
  この DISPLAY 変数を見て「どの画面に描画すればよいか」を判断する。
  ":0" はWindows側のWSLgが用意している画面番号。

-v /mnt/wslg/.X11-unix:/tmp/.X11-unix
→ ホスト(WSL)側の /mnt/wslg/.X11-unix フォルダを、コンテナ内の /tmp/.X11-unix に
  そのまま重ねて見せる(ボリュームマウント)。
  ここにはWSLgが用意するX11の通信用ソケット(ファイルのように見える通信口)が入っている。
  Linuxのアプリは通常 /tmp/.X11-unix の中のソケットを通じて画面表示のやり取りをするため、
  この場所を共有することで、コンテナの中のSALOMEが「あたかも自分の外にある画面」に
  ウィンドウを直接描画できるようになる（＝-e DISPLAY=:0 とこのマウントが揃って初めて
  GUIがWindowsのデスクトップに表示される）。

-v ~/salome_work:/work
→ ホスト側の ~/salome_work フォルダを、コンテナ内の /work に重ねて見せる。
  SALOMEでStudyファイルなどを保存するとき、コンテナ内の /work に保存しておけば、
  実体はホスト側の ~/salome_work に残るので、コンテナを --rm で削除しても消えない。

salome915
→ 起動するイメージの名前。docker build -t salome915 で付けた名前と一致させる。
```

成功すると、

```text
salome@xxxxxxxx:/work$
```

のようになる。

---

# 3. まずxclockでGUI表示確認

いきなりSALOMEを起動せず、

```bash
xclock
```

を実行する。

Windowsデスクトップ上に小さい時計のウィンドウが表示されれば、

```text
Docker
↓
X11
↓
WSLg
↓
Windows GUI
```

の接続は成功。

`xclock`を終了して次へ進む。

---

# 4. SALOME本体を起動する

コンテナ内で、

```bash
ls -lah /opt/salome
```

を実行する。

SALOMEの起動用ファイルを探す。

```bash
find /opt/salome -maxdepth 2 -type f \( -name "salome" -o -name "mesa_salome" -o -name "run_salome.sh" \)
```

例えば、

```text
/opt/salome/mesa_salome
```

がある場合、

```bash
/opt/salome/mesa_salome
```

を実行する。

正常ならWindows上にSALOME 9.15のGUIウィンドウが直接表示される。

ブラウザは使用しない。

---

# 5. Macで使う場合

同じ `salome915` DockerイメージをMacでも使用する。

Apple Silicon Macの場合も、

```text
linux/amd64
```

として起動する。

Mac側ではX11 GUI表示のためにXQuartzを使用する。

構成:

```text
Mac
↓
Docker Desktop
↓
linux/amd64
↓
Ubuntu 24.04
↓
SALOME 9.15
↓
XQuartz
↓
SALOME GUI
```

Dockerイメージ自体はWindows版と同じものを使用する。

違うのはGUIの表示先だけ。

---

# 6. 今回使わないもの

以前検討した以下は使用しない。

```text
Xvfb
x11vnc
noVNC
websockify
```

これらはDocker内の画面をブラウザへ表示するための仕組み。

今回は、

```text
SALOME本来のGUIウィンドウを直接表示する
```

ことが目的なので不要。

---

# 7. 現在地

現在、以下まで完了している。

- [ ] Windowsでxclock表示確認
- [ ] WindowsでSALOME GUI起動確認
- [ ] Mac + XQuartzでGUI起動確認
- [ ] 配布用Dockerイメージ作成
- [ ] Docker Hub等への配布
