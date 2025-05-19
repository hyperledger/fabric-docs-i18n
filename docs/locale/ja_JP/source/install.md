# Install Fabric and Fabric Samples

以下のインストール手順を実行する前に [Prerequisites](./prereqs.html) のインストールを行ってください。

私たちは、何かを理解する最良の方法は、実際に自分で使ってみることだと考えています。
我々はFabricの利用を支援するために、Docker composeを使用したシンプルなFabricテストネットワークと、そのコア機能をデモするサンプルアプリケーションのセットを作成しました。

また、 `Fabric CLI tool binaries` および `Fabric Docker Images` を事前にコンパイルしたものを用意しており、これらを自身の環境へダウンロードすることですぐに開始できます。

以下の手順にあるcURLコマンドは、Fabricテストネットワークを実行できる環境を設定します。具体的には、以下の手順を実行します:

* [hyperledger/fabric-samples](https://github.com/hyperledger/fabric-samples) リポジトリをクローンする。
* 最新のHyperledger Fabric Dockerイメージをダウンロードし、 `latest` というタグを付与する。
* 以下に示す、プラットフォーム固有のHyperledger Fabric CLIツールのバイナリと設定ファイルを、 `fabric-samples` ディレクトリの `/bin` と `/config` ディレクトリにダウンロードする。これらのバイナリは、テストネットワークとのやり取りに役立ちます。
  * `configtxgen`,
  * `configtxlator`,
  * `cryptogen`,
  * `discover`,
  * `idemixgen`,
  * `orderer`,
  * `osnadmin`,
  * `peer`,
  * `fabric-ca-client`,
  * `fabric-ca-server`

## Download Fabric samples, Docker images, and binaries

作業ディレクトリの作成が必要です - 例えば、Goの開発者は `$HOME/go/src/github.com/<your_github_userid>` ディレクトリを利用します。これはGolangのコミュニティがGoプロジェクト向けに推奨しているものです。

```shell
mkdir -p $HOME/go/src/github.com/<your_github_userid>
cd $HOME/go/src/github.com/<your_github_userid>
```

インストールスクリプトを入手します:

```bash
curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh && chmod +x install-fabric.sh
```

オプション一覧を見るには、 `-h` オプションをつけてスクリプトを実行します:

```bash
./install-fabric.sh -h
Usage: ./install-fabric.sh [-f|--fabric-version <arg>] [-c|--ca-version <arg>] <comp-1> [<comp-2>] ... [<comp-n>] ...
        <comp>: Component to install one or more of  d[ocker]|b[inary]|s[amples]. If none specified, all will be installed
        -f, --fabric-version: FabricVersion (default: '2.5.4')
        -c, --ca-version: Fabric CA Version (default: '1.5.6')
```

## Choosing which components

ダウンロードするコンポーネントを指定するには、次の引数の1つまたは複数を追加します。各引数は最初の文字のみに短縮できます。

* Dockerを使用してFabricコンテナイメージをダウンロードするには `docker` を指定します
* podmanを使用してFabricコンテナイメージをダウンロードするには `podman` を指定します
* Fabricのバイナリをダウンロードするには `binary` を指定します
* fabric-samples gitHub リポジトリを現在のディレクトリにクローンするには `samples` を指定します

Dockerコンテナをpullし、サンプルリポジトリをクローンするには、次のコマンドのいずれかを実行してください。

```bash
./install-fabric.sh docker samples binary
or
./install-fabric.sh d s b
```

引数が指定されていない場合、引数 `docker binary samples` が使用されます。

## Choosing which version

デフォルトでは、コンポーネントの最新版が使用されます。これらは、オプション `--fabric-version` と `-ca-version` を使用して変更できます。`-f` と `-c` はそれぞれ対応する短縮形です。

例えば、v2.5.4のバイナリをダウンロードするには、次のコマンドを実行すると

```bash
./install-fabric.sh --fabric-version 2.5.4 binary
```

Fabricサンプル、Dockerイメージ、およびバイナリをシステムにインストールできます。

* Fabric へのコントリビューションを開始するために環境を設定したい場合は、 [Setting up the contributor development environment](./dev-setup/devenv.html) に示す手順を参照してください。

> Note: これは、既存のスクリプトと同じ結果を得るための更新されたインストールスクリプトです。ただし、構文が改善されています。このスクリプトでは、インストールするコンポーネントを選択する際、積極的なオプトイン方式を採用しています。元のスクリプトは、同じ場所 `curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/bootstrap.sh| bash -s` に引き続き存在しています。

* ヘルプが必要な場合、 [Hyperledger Discord Chat](https://discord.com/invite/hyperledger) の **fabric-questions** チャネルもしくは [StackOverflow](https://stackoverflow.com/questions/tagged/hyperledger-fabric) に質問を投稿しログを共有してください。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
