# Connection Profile

**対象読者**: アーキテクト、アプリケーションおよびスマートコントラクト開発者

コネクションプロファイル (Connection Profile) は、Hyperledger Fabricブロックチェーンネットワーク内のピア、
Orderer、認証局などのコンポーネントのセットを記述します。
また、これらのコンポーネントに関連するチャネルおよび組織の情報も含まれています。
コネクションプロファイルは、主にアプリケーションがネットワークとのあらゆるやりとりを処理する
[ゲートウェイ (Gateway)](./gateway.html) を設定するために使用され、ビジネスロジックに集中できるようにします。
コネクションプロファイルは通常、ネットワークトポロジを理解している管理者によって作成されます。

このトピックでは、以下について説明します:

* [コネクションプロファイルが重要な理由](#scenario)
* [アプリケーションがコネクションプロファイルを使用する方法](#usage)
* [コネクションプロファイルを定義する方法](#structure)

## Scenario

コネクションプロファイルは、ゲートウェイを設定するために使用されます。
ゲートウェイは[多くの理由](./gateway.html) で重要であり、主な目的はアプリケーションとネットワークチャネルとのやりとりを単純化することです。

![profile.scenario](./develop.diagram.30.png) *2つのアプリケーションである「発行」と「購入」は、コネクションプロファイル1および2を用いて設定されたゲートウェイ1および2を使用します。
各プロファイルは、MagnetoCorp および DigiBank ネットワークコンポーネントの異なるサブセットを記述します。
各コネクションプロファイルには、ゲートウェイが「発行」および「購入」アプリケーションに代わってネットワークとやりとりするための十分な情報が含まれている必要があります。
詳細な説明については、テキストを参照してください。*

コネクションプロファイルには、JSONまたはYAMLのどちらかの構文で表現されたネットワークビューの説明が含まれています。
このトピックでは、読みやすいようにYAMLでの表現を使用します。
静的ゲートウェイは動的ゲートウェイよりも多くの情報を必要とします。
なぜなら、動的ゲートウェイはコネクションプロファイルの情報を動的に拡張するために[サービスディスカバリ (Service Discovery)](../discovery-overview.html) を使用できるからです。

コネクションプロファイルは、ネットワークチャネルの網羅的な記述であるべきではなく、
それを使用しているゲートウェイにとって十分な情報を含む必要があるだけです。
上記のネットワークでは、コネクションプロファイル1は、少なくとも `発行 (issue)` トランザクションのためのエンドーシング組織とピアを含む必要があります。
また、トランザクションが台帳にコミットされたときにゲートウェイに通知するピアを特定する必要があります。

コネクションプロファイルは、ネットワークの *ビュー* を表すものと考えるのが最も簡単です。
それは包括的なビューとすることもできますが、それはいくつかの理由で非現実的です:

* ピア、Orderer、認証局、チャネル、組織は、要求に応じて追加・削除されます。

* コンポーネントは、起動および停止したり、予期せず障害が発生したりする可能性があります (停電など)。

* ゲートウェイはネットワーク全体のビューを必要とせず、たとえばトランザクションの送信やイベント通知を正常に処理するために必要なものだけを必要とします。

* サービスディスカバリは、コネクションプロファイルの情報を拡張することができます。
  具体的には、動的ゲートウェイは最小限のFabricトポロジ情報で設定でき、残りはサービスディスカバリで検出することができます。

静的コネクションプロファイルは通常、ネットワークトポロジを詳細に理解している管理者によって作成されます。
これは、静的プロファイルには非常に多くの情報が含まれている可能性があり、
管理者は対応するコネクションプロファイルにこの情報を取り込む必要があるためです。
対照的に、動的プロファイルは必要な定義の量を最小限に抑えるため、
早く作業を始めたい開発者や、より応答性の高いゲートウェイを作成したい管理者にとってより良い選択となります。
コネクションプロファイルは、選択したエディタを使用してYAMLまたはJSON形式で作成されます。

## Usage

コネクションプロファイルを定義する方法をすぐに見てみましょう。
まず、サンプルのMagnetoCorpの `issue` アプリケーションでどのように使用されるかを見てみましょう:

```javascript
const yaml = require('js-yaml');
const { Gateway } = require('fabric-network');

const connectionProfile = yaml.safeLoad(fs.readFileSync('../gateway/paperNet.yaml', 'utf8'));

const gateway = new Gateway();

await gateway.connect(connectionProfile, connectionOptions);
```

いくつかの必要なクラスをロードした後で
`yaml.safeLoad()` メソッドを使用して `paperNet.yaml` ゲートウェイファイルをファイルシステムからロード、JSONオブジェクトに変換し、
`connect()` メソッドを使用してゲートウェイを設定する方法を確認します。

このコネクションプロファイルを使用してゲートウェイを設定することにより、
発行アプリケーションは、トランザクションの処理に使用する必要のある関連するネットワークトポロジをゲートウェイに提供します。
これは、コネクションプロファイルにPaperNetチャネル、組織、ピア、Orderer、およびCAに関する十分な情報が含まれており、
トランザクションを正常に処理できるようにするためです。

コネクションプロファイルでは、特定の組織に対して複数のピアを定義することは良い方法です。
これにより、単一障害点が防止されます。
この方法は、サービスディスカバリのための複数の開始点を提供するために動的ゲートウェイにも適用されます。

DigiBankの `購入 (buy)` アプリケーションは通常、同様のコネクションプロファイルでゲートウェイを設定しますが、
いくつかの重要な違いがあります。
チャネルなど、一部の要素は同じになります。エンドーシングピアなど、一部の要素は重複します。
イベント通知に使用するピアや認証局など、他の要素は完全に異なります。

ゲートウェイに渡される `connectionOptions` は、コネクションプロファイルを補完します。
これにより、アプリケーションは、ゲートウェイがコネクションプロファイルを使用する方法を宣言できます。
これらはネットワークコンポーネントとのやりとりのパターンを制御するためにSDKによって解釈されます。
たとえば、接続するアイデンティティや、イベント通知に使用するピアを選択します。
使用可能なコネクションオプションのリストとそれらをいつ使用するについては [こちら](./connectionoptions.html) をお読みください。

## Structure

コネクションプロファイルの構造を理解しやすくするために、[上記](#scenario) に示されているネットワークの例を順を追って説明します。
そのコネクションプロファイルは、PaperNetコマーシャルペーパーサンプルに基づいており、GitHubリポジトリ内に[保存](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/gateway/networkConnection.yaml)
されています。便宜上、[以下](#sample) に転載しました。サンプル自体も別のブラウザウィンドウに表示しながら以下を読み進めるとわかりやすいです:

* 9行目: `name: "papernet.magnetocorp.profile.sample"`

  これはコネクションプロファイルの名前です。DNS形式の名前を使用してみてください。これは意味を伝えるための非常に簡単な方法です。


* 16行目: `x-type: "hlfv1"`

  ユーザーは、HTTPヘッダーの場合と同様に、「アプリケーション固有」の独自の `x-` プロパティを追加できます。これは主に将来的な使用のために提供されています。


* 20行目: `description: "Sample connection profile for documentation topic"`

  このコネクションプロファイルの簡単な説明です。初めてこれを見るかもしれない読者のために役立つように設定してください！


* 25行目: `version: "1.0"`

  このコネクションプロファイルのスキーマのバージョンです。現在はバージョン1.0のみがサポートされており、このスキーマが頻繁に変更されることは想定されていません。


* 32行目: `channels:`

  これは本当に重要な最初の行です。 `channels:` は、このコネクションプロファイルが記述する *すべて* のチャネルが続くことを示します。
  ただし、特に互いに独立して使用される場合には、異なるチャネルを異なるコネクションプロファイルに入れておくことは良い方法です。


* 36行目: `papernet:`

  このコネクションプロファイルの最初のチャネルである `papernet` の詳細です。


* 41行目: `orderers:`

  `papernet` のすべてのOrdererの詳細です。45行目で、このチャネルのOrdererが `orderer1.magnetocorp.example.com` であることがわかります。
  これは単なる論理名です。コネクションプロファイルの後半 (134行目から147行目) に、このOrdererへの接続方法の詳細が記載されています。
  `orderer2.digibank.example.com` がこのリストには含まれていないことに注意してください。
  アプリケーションが別の組織のOrdererではなく、自組織のOrdererを使用することは理にかなっています。


* 49行目: `peers:`

  `papernet` のすべてのピアの詳細です。

  MagnetoCorpからリストされている3つのピア `peer1.magnetocorp.example.com`, `peer2.magnetocorp.example.com`, `peer3.magnetocorp.example.com` を確認できます。
  ここで行われているようにMagnetoCorpのすべてのピアをリストする必要はありません。DigiBankからリストされているピア `peer9.digibank.example.com` は1つだけです。
  このDigiBankのピアを含めることは、これから確認するように、エンドースメントポリシーが、MagnetoCorpとDigiBankがトランザクションをエンドースすることを要求していることを暗示し始めます。
  単一障害点を回避するために、複数のピアを用意することは良い方法です。

  各ピアの下には、**endorsingPeer**、**chaincodeQuery**、**ledgerQuery**、および**eventSource**という4つの非排他的な役割が表示されています。
  スマートコントラクト `papercontract` をホストするときに、 `peer1` と `peer2` が どのようにすべての役割を実行できるかをご覧ください。
  対照的に、 `peer3` は通知、あるいはワールドステートではなく台帳のブロックチェーンコンポーネントにアクセスする台帳クエリ (ledger query) にのみ使用でき、
  スマートコントラクトをインストールする必要はありません。
  `peer9` は、MagnetoCorpのピアによってより適切に提供されるため、エンドースメント以外の目的で使用することはできません。

  繰り返しになりますが、ピアが論理名と役割に従ってどのように記述されているかを確認してください。プロファイルの後半で、これらのピアの物理情報を確認します。


* 97行目: `organizations:`

  すべてのチャネルのための、すべての組織の詳細です。
  現在リストされているチャネルは `papernet` だけですが、ここで記載されている組織はすべてのチャネルを対象としていることに注意してください。
  これは、組織が複数のチャネルに存在する可能性があり、チャネルが複数の組織を持つ可能性があるためです。
  さらに、一部のアプリケーション操作は、チャネルではなく組織に関連しています。
  たとえば、アプリケーションは、[コネクションオプション](./connectoptions.html) を使用して、
  1組織内またはネットワーク内のすべての組織の、1つまたはすべてのピアからの通知を要求できます。
  このためには、組織とピアのマッピングが必要であり、このセクションでそれを提供します。

* 101行目: `MagnetoCorp:`

  MagneticCorpの一部と見なされるすべてのピア (`peer1`、`peer2`、および `peer3`) がリストされています。
  認証局についても同様です。ここでも `channels:` セクションと同じように論理名を使用していることに注意してください。
  物理情報は、プロファイルの後半へ続きます。


* 121行目: `DigiBank:`

  DigiBankの一部としてリストされているのは `peer9` のみであり、認証局はリストされていません。
  これは、DigiBankの他のピアとCAが、このコネクションプロファイルのユーザーに関連していないためです。


* 134行目: `orderers:`

  Ordererの物理情報がリストされてます。
  このコネクションプロファイルでは `papernet` 用のOrdererは1つしか記載されていないため、(ここでは) `orderer1.magnetocorp.example.com` の詳細がリストされています。
  これには、そのIPアドレスとポート、必要に応じてOrdererと通信する際に使用されるデフォルト値を上書きできるgRPCオプションが含まれます。
  `peers:` と同様に、高可用性を実現するには、複数のOrdererを指定することは良い考えです。


* 152行目: `peers:`

  前述したすべてのピアの物理情報がリストされています。このコネクションプロファイルには、MagnetoCorpに関しては3つのピア (`peer1`、 `peer2`、および `peer3`)
  DigiBankに関しては、単一のピア `peer9` があり、それらの情報がリストされています。
  Ordererと同様に、ピアごとに、そのIPアドレスとポートが、必要に応じて特定のピアと通信する際に使用されるデフォルト値を上書きできるgRPCオプションとともに表示されています。

* 194行目: `certificateAuthorities:`

  認証局の物理情報がリストされています。コネクションプロファイルには、MagnetoCorp用にリストされた単一のCA `ca1-magnetocorp` があり、その物理情報が続きます。
  IPの詳細だけでなく、登録者 (Registrar) 情報により、このCAを証明書署名要求（CSR）に使用できます。
  これらは、ローカルで生成された公開鍵と秘密鍵のペアの新しい証明書を要求するために使用されます。

これでMagnetoCorpのコネクションプロファイルを理解したところで、DigiBankの[対応するプロファイル](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/gateway/networkConnection.yaml) を見てみてください。
MagnetoCorpのプロファイルと同じところ、似ているところ、そして最後に違うところを確認してください。
これらの違いがDigiBankアプリケーションにとって意味がある理由を考えてみてください。


コネクションプロファイルについて知っておく必要があるのはこれだけです。
要約すると、コネクションプロファイルは、アプリケーションがゲートウェイを構成するのに十分なチャネル、
組織、ピア、Orderer、および認証局を定義します。
ゲートウェイを使用することで、アプリケーションはネットワークトポロジの詳細ではなく、ビジネスロジックに集中することができます。

## Sample

このファイルはGitHub上のコマーシャルペーパーの[サンプル](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/gateway/networkConnection.yaml) をインラインで転載したものです。

```
1: ---
2: #
3: # [必須]. コネクションプロファイルには、一連のネットワークコンポーネントに関する情報
4: # が含まれています。これは通常、ゲートウェイを設定するために使用され、
5: # アプリケーションが基礎となるトポロジを気にすることなくネットワークチャネルとやりとり
6: # できるようにします。コネクションプロファイルは通常、このトポロジを理解している管理者
7: # によって作成されます。
8: #
9: name: "papernet.magnetocorp.profile.sample"
10: #
11: # [任意]. HTTPと同様に、プレフィックスが「x-」のプロパティは「アプリケーション固有」
12: # と見なされ、ゲートウェイによって無視されます。
13: # たとえば、値が「hlfv1」のプロパティ「x-type」は、元々、Fabric 0.xではなく
14: # Fabric 1.xのコネクションプロファイルであることを識別するために使用されていました。
15: #
16: x-type: "hlfv1"
17: #
18: # [必須]. コネクションプロファイルの簡単な説明
19: #
20: description: "Sample connection profile for documentation topic"
21: #
22: # [必須]. コネクションプロファイルのスキーマのバージョン。
23: # ゲートウェイがこれらのデータを解釈するために使用します。
24: #
25: version: "1.0"
26: #
27: # [任意]. 各ネットワークチャネルの論理的な説明 (そのピア名とOrderer名、
28: # およびチャネル内でのそれらの役割)。これらのコンポーネントの物理的な詳細
29: # (ピアのIPアドレスなど) は、プロファイルの後半で指定されます。
30: # 最初に論理情報に焦点を合わせ、その後に物理情報に焦点を合わせます。
31: #
32: channels:
33:   #
34:   # [任意]. papernet はこのコネクションプロファイルに含まれる唯一のチャネルとなります
35:   #
36:   papernet:
37:     #
38:     # [任意]. PaperNet のチャネルOrderer。それらに接続する方法の詳細は
39:     # 後述の物理情報を示す「orderers:」セクションで指定されます。
40:     #
41:     orderers:
42:     #
43:     # [必須]. Ordererの論理名
44:     #
45:       - orderer1.magnetocorp.example.com
46:     #
47:     # [任意]. ピアとその役割
48:     #
49:     peers:
50:     #
51:     # [必須]. ピアの論理名
52:     #
53:       peer1.magnetocorp.example.com:
54:         #
55:         # [任意]. このピアがエンドーシングピアかどうか (チェーンコードがインストール
56:         # されている必要あり)。デフォルト値: true
57:         #
58:         endorsingPeer: true
59:         #
60:         # [任意]. このピアがクエリするために使われるかどうか (チェーンコードがインストール
61:         # されている必要あり)。デフォルト値: true
62:         #
63:         chaincodeQuery: true
64:         #
65:         # [任意]. このピアがチェーンコード以外のクエリに使われるかどうか。
66:         # すべてのピアは、 queryBlock()、queryTransaction() 等を含むこれらのタイプの
67:         # クエリをサポートします。デフォルト値: true
68:         #
69:         ledgerQuery: true
70:         #
71:         # [任意]. このピアがイベントハブ (Event Hub) として使われるかどうか。
72:         # すべてのピアはイベントを生成できます。デフォルト値: true
73:         #
74:         eventSource: true
75:       #
76:       peer2.magnetocorp.example.com:
77:         endorsingPeer: true
78:         chaincodeQuery: true
79:         ledgerQuery: true
80:         eventSource: true
81:       #
82:       peer3.magnetocorp.example.com:
83:         endorsingPeer: false
84:         chaincodeQuery: false
85:         ledgerQuery: true
86:         eventSource: true
87:       #
88:       peer9.digibank.example.com:
89:         endorsingPeer: true
90:         chaincodeQuery: false
91:         ledgerQuery: false
92:         eventSource: false
93: #
94: # [必須]. すべてのチャネルのための組織のリスト。
95: # 少なくとも1つ以上の組織が必要となります。
96: #
97: organizations:
98:    #
99:    # [必須]. MagnetoCorp用の組織情報
100:   #
101:   MagnetoCorp:
102:     #
103:     # [必須]. TMagnetoCorpの識別に使用されるMSP ID
104:     #
105:     mspid: MagnetoCorpMSP
106:     #
107:     # [必須]. MagnetoCorpのピア
108:     #
109:     peers:
110:       - peer1.magnetocorp.example.com
111:       - peer2.magnetocorp.example.com
112:       - peer3.magnetocorp.example.com
113:     #
114:     # [任意]. 認証局 (Fabric CA)
115:     #
116:     certificateAuthorities:
117:       - ca-magnetocorp
118:   #
119:   # [任意]. DigiBank用の組織情報
120:   #
121:   DigiBank:
122:     #
123:     # [必須]. DigiBankの識別に使用されるMSP ID
124:     #
125:     mspid: DigiBankMSP
126:     #
127:     # [必須]. DigiBankのピア
128:     #
129:     peers:
130:       - peer9.digibank.example.com
131: #
132: # [任意]. Ordererの物理情報 (Orderer名ごと)
133: #
134: orderers:
135:   #
136:   # [必須]. MagnetoCorpのOrdererの名前
137:   #
138:   orderer1.magnetocorp.example.com:
139:     #
140:     # [必須]. このOrdererのIPアドレス
141:     #
142:     url: grpc://localhost:7050
143:     #
144:     # [任意]. 通信に使用するgRPCコネクションプロパティ
145:     #
146:     grpcOptions:
147:       ssl-target-name-override: orderer1.magnetocorp.example.com
148: #
149: # [必須]. ピアの物理情報 (ピア名ごと)
150: # 少なくとも1つ以上のピアが必要となります。
151: #
152: peers:
153:   #
154:   # [必須]. MagetoCorpの1つ目のピアの物理プロパティ
155:   #
156:   peer1.magnetocorp.example.com:
157:     #
158:     # [必須]. Peer's IP address
159:     #
160:     url: grpc://localhost:7151
161:     #
162:     # [任意]. 通信に使用するgRPCコネクションプロパティ
163:     #
164:     grpcOptions:
165:       ssl-target-name-override: peer1.magnetocorp.example.com
166:       request-timeout: 120001
167:   #
168:   # [任意]. MagnetoCorpのその他のピア
169:   #
170:   peer2.magnetocorp.example.com:
171:     url: grpc://localhost:7251
172:     grpcOptions:
173:       ssl-target-name-override: peer2.magnetocorp.example.com
174:       request-timeout: 120001
175:   #
176:   peer3.magnetocorp.example.com:
177:     url: grpc://localhost:7351
178:     grpcOptions:
179:       ssl-target-name-override: peer3.magnetocorp.example.com
180:       request-timeout: 120001
181:   #
182:   # [必須]. Digibankのピアの物理プロパティ
183:   #
184:   peer9.digibank.example.com:
185:     url: grpc://localhost:7951
186:     grpcOptions:
187:       ssl-target-name-override: peer9.digibank.example.com
188:       request-timeout: 120001
189: #
190: # [任意]. 認証局 (Fabric CA) の物理情報 (名前ごと)
191: # この情報は (たとえば) 新しいユーザーを登録するために使用できます。
192: # 通信はRESTを介して行われるため、オプションはgRPCではなくHTTPに関連します。
193: #
194: certificateAuthorities:
195:   #
196:   # [必須]. MagnetoCorp用のCA
197:   #
198:   ca1-magnetocorp:
199:     #
200:     # [必須]. CAのIPアドレス
201:     #
202:     url: http://localhost:7054
203:     #
204:     # [任意]. 通信に使うHTTPコネクションプロパティ
205:     #
206:     httpOptions:
207:       verify: false
208:     #
209:     # [任意]. Fabric CA は証明書署名要求 (Certificate Signing Request, CSR) をサポートします。
210:     # 登録者情報 (registrar) は新しいユーザを登録するために必要です。
211:     #
212:     registrar:
213:       - enrollId: admin
214:         enrollSecret: adminpw
215:     #
216:     # [任意]. CAの名前
217:     #
218:     caName: ca-magnetocorp
```

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
