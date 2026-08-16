# 000. Dockerのセットアップ

## 目的

オープンCAE学会サマースクールで SALOME 9.15 を使用するために、Windows上で Docker 環境を作成し、最終的には Mac ユーザーにも同じ環境を配布できるようにする。

想定構成：

```text
Windows
  ↓
Docker Desktop
  ↓
WSL2
  ↓
linux/amd64 の Ubuntu 24.04
  ↓
SALOME 9.15
  ↓
Dockerイメージとして配布
  ↓
Windows / Mac で共通利用
```

---

## 方針

- ベースOS：Ubuntu 24.04 LTS
- Dockerプラットフォーム：`linux/amd64`
- SALOME：9.15
- Windowsでは Docker Desktop + WSL2 を使用
- Apple Silicon Mac では `linux/amd64` をエミュレーションして利用
- 最終的には noVNC 等を使い、ブラウザから SALOME のGUIを開ける構成を目指す

このドキュメントでは、SALOME本体を入れる前段階の「Dockerが正しく動く土台を作る」ところまでを扱う。SALOME 9.15をコンテナへ実際にインストールする手順は [002_install_salome915.md](002_install_salome915.md) を参照。

---

# 1. Docker Desktop のインストール

Docker公式サイトから Windows 用 Docker Desktop をダウンロードする。

選択したもの：

```text
Docker Desktop for Windows - x86_64
```

ARM版ではなく x86_64 版を使用する。

インストール時の設定：

```text
Per-user installation (Recommended)    ON
Use WSL 2 instead of Hyper-V           ON
Allow Windows Containers               OFF
Add shortcut to desktop                任意
```

今回使うのは Linux コンテナなので、Windows Containers は不要。

---

# 2. Docker Desktop の WSL Integration を有効化

Docker Desktopを起動し、

```text
Settings
  ↓
Resources
  ↓
WSL Integration
```

を開く。

使用している Ubuntu のスイッチを ON にする。

例：

```text
Enable integration with additional distros:

Ubuntu    ON
```

`Enable integration with my default WSL distro` は必須ではない。

Ubuntu を個別に ON にしていれば利用可能。

設定後、

```text
Apply & restart
```

を押す。

---

# 3. Docker Desktop は起動したままにする

Docker Desktop左下に、

```text
Engine running
```

と表示されていれば Docker Engine が動作している。

Docker Desktopの設定画面は閉じてよい。

Docker Desktop本体は基本的に起動したままにする。

最小化は問題ない。

---

# 4. WSLからDockerが見えるか確認

WSL Ubuntu で実行：

```bash
docker --version
```

今回の確認結果：

```text
Docker version 29.7.2, build a7dcaa6
```

これで Docker CLI が WSL から利用可能になった。

---

# 5. Docker Engine への接続確認

次に、

```bash
docker version
```

を実行。

今回の結果：

```text
Client:
 Version:           29.7.2
 API version:       1.55
 OS/Arch:           linux/amd64
 Context:           default

Server: Docker Desktop 4.86.0
 Engine:
  Version:          29.7.2
  OS/Arch:          linux/amd64
```

重要なのは、

```text
Client OS/Arch: linux/amd64
Server OS/Arch: linux/amd64
```

となっていること。

これで、

```text
Windows
  ↓
WSL2
  ↓
Docker Desktop
  ↓
linux/amd64
```

まで正常に動作している。

---

# 6. Dockerソケットの確認

途中で以下のエラーが出た。

```text
permission denied while trying to connect to the docker API at unix:///var/run/docker.sock
```

確認した内容：

```bash
groups
```

結果：

```text
kamakiri adm cdrom sudo dip plugdev users ollama docker
```

ユーザーはすでに `docker` グループに所属していた。

Dockerソケット確認：

```bash
ls -l /var/run/docker.sock
```

結果：

```text
srw-rw---- 1 root docker 0 ... /var/run/docker.sock
```

Docker context確認：

```bash
docker context ls
```

結果：

```text
NAME            DESCRIPTION                               DOCKER ENDPOINT
default *       Current DOCKER_HOST based configuration   unix:///var/run/docker.sock
desktop-linux   Docker Desktop                            npipe:////./pipe/dockerDesktopLinuxEngine
```

その後 Docker Desktop / WSL の再起動を行い、`docker version` で Client / Server の両方が表示されることを確認した。

---

# 7. WSLを完全に再起動する方法

必要な場合は Windows PowerShell で、

```powershell
wsl --shutdown
```

を実行する。

その後、

1. Docker Desktopを起動
2. `Engine running` を確認
3. WSL Ubuntuを起動

という順番で戻す。

---

# 8. Ubuntu 24.04 amd64 コンテナを起動する

次のステップとして、WSL上で以下を実行する。

```bash
docker run --rm -it --platform linux/amd64 ubuntu:24.04 bash
```

意味：

```text
docker run
→ コンテナを起動

--rm
→ 終了時にコンテナを削除

-it
→ 対話型ターミナルとして起動

--platform linux/amd64
→ Intel/AMD 64bit Linux 環境として起動

ubuntu:24.04
→ Ubuntu 24.04 イメージを使用

bash
→ bashを起動
```

成功すると、

```text
root@xxxxxxxx:/#
```

のようなプロンプトになる。

---

# 9. コンテナ内のCPUアーキテクチャ確認

Ubuntuコンテナ内で、

```bash
uname -m
```

を実行。

期待する結果：

```text
x86_64
```

これが `linux/amd64` に相当する。

---

# 10. Ubuntuバージョン確認

コンテナ内で、

```bash
cat /etc/os-release
```

を実行。

期待する内容：

```text
NAME="Ubuntu"
VERSION="24.04 LTS (Noble Numbat)"
```

ここまで確認できれば、

```text
Ubuntu 24.04
+
linux/amd64
```

のDocker環境が完成。

終了するときは、

```bash
exit
```

を実行する。

---

# 11. linux/amd64 とは

`linux/amd64` は、

```text
OS：Linux
CPU：Intel / AMD 64bit
```

という意味。

一般的な Windows PC は Intel / AMD 系なので、通常は amd64。

一方、最近の Mac は Apple Silicon を使用している。

```text
Intel / AMD PC
→ amd64

Apple Silicon Mac
→ arm64
```

SALOME 9.15 の Linux 環境は amd64 を基準にするため、今回は最初から、

```text
linux/amd64
```

で統一する。

Apple Silicon Mac では Docker Desktop が amd64 をエミュレーションして実行する。

イメージ：

```text
Apple Silicon Mac
  ↓
arm64 CPU
  ↓
Docker Desktop
  ↓
linux/amd64 エミュレーション
  ↓
Ubuntu 24.04
  ↓
SALOME 9.15
```

---

ここまででDockerの土台が整った。次は [002_install_salome915.md](002_install_salome915.md) でSALOME 9.15本体をコンテナへ組み込む。
