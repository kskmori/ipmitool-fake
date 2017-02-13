(Japanese)

# ipmitool-fake

このツールは、ipmitool コマンドを置き換えて、仮想マシンの電源断を ipmitool コマンドインタフェースで実行するものです。

Pacemakerの試験において、物理環境用のSTONITHプラグイン(external/ipmi)設定をそのまま仮想環境上で使用して設定・動作確認を行うことが可能になります。

あくまでPacemakerクラスタの試験用のツールですので、実商用環境での利用には向いていません。

## パッケージのビルド

* (1) リポジトリをチェックアウトする。

```
$ git clone https://github.com/kskmori/ipmitool-fake
$ cd ipmitool-fake
```

* (2) ipmitool-fake.conf 設定ファイルを作成する。
  + ※ vi コマンドが起動するので適宜修正する。その他の手段で作成・修正しても可。
  + 設定内容の詳細はファイルの内容参照。

```
$ make conf
```

* (3) 以下のコマンドで RPM パッケージを作成する。

```
$ make rpm
```

以下のディレクトリにRPMパッケージが作成される。

```
$ ls ~/rpmbuild/RPMS/noarch/ipmitool-fake-0.1-1.noarch.rpm
/home/ksk/rpmbuild/RPMS/noarch/ipmitool-fake-0.1-1.noarch.rpm
```


## インストール

* (0) 前提条件
  + KVM仮想マシン上に Pacemaker クラスタを構築する。
  + Pacemaker の設定として、物理環境を想定した external/ipmi プラグインのSTONITHリソース設定を行う。

* (1) ssh 設定を行う (両ゲスト上で実施)
  + 仮想マシンからホストへ root ユーザのパスワード無しでの ssh ログインを許可する設定を行う。
  + 設定後、以下のコマンドでパスワード無しでログインできることを確認する
  + ※ $(HOST) はパッケージのビルド(2)で設定したホスト名(もしくはIPアドレス)

```
# ssh -l root $(HOST)
```

* (2) RPM のインストールを行う (両ゲスト上で実施)

```
# rpm -ivh ipmitool-fake-0.1-1.noarch.rpm
```

* (3) 置き換えた ipmitool コマンドが動作することを確認する。
  + オプションはそれぞれパッケージのビルド(2)で設定したゲストのIPMI用IPアドレス、ユーザ、パスワード

```
# ipmitool -H 192.168.99.27 -U pacemaker -P pacemakerpass power status
# echo $?
0
#
```


## アンインストール

* 1. 以下のコマンドでアンインストールする。

```
# rpm -e ipmitool-fake
```

* 2. ipmitool が本来のバイナリに戻っていることを確認する。

```
# file /usr/bin/ipmitool
/usr/bin/ipmitool: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV),
dynamically linked (uses shared libs), for GNU/Linux 2.6.32,
BuildID[sha1]=2dbae2ce2dd77cabff47d677157dba142906d239, stripped
```

## ipmitool-fake.conf 設定項目

* HOST
  * 仮想環境ホストの管理LANのIPアドレス。ゲストからアクセスするIPアドレス(もしくはホスト名)を指定する。
* VMCONFIG
  * ゲストのIPMI用IPアドレスとゲストのドメイン名のマッピングを設定する。それぞれを':'文字で連結し、一行一ゲストで記載する。
  * ゲストのIPMI用IPアドレスへは実際にはアクセスしないため、到達しないアドレスで良い。
  * ゲストのドメイン名はホストから見えるドメイン名であることに注意。(ゲスト内OSのホスト名ではない)
* USER
  * IPMI用ユーザ名
* PASSWORD
  * IPMI用パスワード

* 補足:
  * RPMパッケージインストール後に個別に設定変更したい場合は、/etc/ipmitool-fake.conf ファイルを作成することで変更可能。

以上。


