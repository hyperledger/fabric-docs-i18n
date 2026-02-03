# Introduction

بصورة عامة، يمكن اعتبار البلوكتشين سجلًا للمعاملات لا يمكن التلاعب به، ويتم الاحتفاظ به ومشاركته بين مجموعة من العُقد (Peers) داخل شبكة موزعة. كل عقدة تحتفظ بنسخة من هذا السجل، ويتم تحديثها عن طريق تنفيذ معاملات تم التحقق منها باستخدام آلية إجماع (Consensus Protocol). تُجمع هذه المعاملات في كتل (Blocks)، وكل كتلة تحتوي على قيمة تجزئة (Hash) تربطها بالكتلة السابقة، مما يضمن ترابط السجل وعدم إمكانية تغييره.

أول وأشهر تطبيق لتقنية البلوكتشين كان عملة [Bitcoin](https://en.wikipedia.org/wiki/Bitcoin) الرقمية، ثم تبعتها تقنيات أخرى. من بينها Ethereum، الذي اتخذ مسارًا مختلفًا بعض الشيء؛ فبالإضافة إلى الخصائص الأساسية الموجودة في بيتكوين، قدّم مفهوم العقود الذكية (Smart Contracts)، مما جعله منصة لبناء تطبيقات موزعة.
كل من بيتكوين و Ethereum يندرجان تحت فئة ما يُعرف بالبلوكتشين العام وغير المقيَّد بالصلاحيات (Public Permissionless)، أي شبكات مفتوحة للجميع، يمكن لأي شخص الانضمام إليها والتفاعل داخلها دون الحاجة إلى هوية معروفة.

ومع الانتشار الواسع Bitcoin و Ethereum وبعض التقنيات المشتقة منهما، بدأ الاهتمام يتزايد باستخدام نفس المفاهيم الأساسية للبلوكتشين مثل السجل الموزع ومنصات التطبيقات اللامركزية في حالات استخدام خاصة بالمؤسسات (Enterprise Use Cases).
لكن الواقع أن كثيرًا من هذه الحالات يتطلب خصائص أداء لا تستطيع شبكات البلوكتشين العامة وغير المقيَّدة توفيرها حاليًا. بالإضافة إلى ذلك، هناك سيناريوهات يكون فيها التعرف على هوية المشاركين أمرًا ضروريًا، مثل المعاملات المالية التي تخضع لقوانين اعرف عميلك (KYC) ومكافحة غسل الأموال (AML).

لذلك، عند استخدام البلوكتشين في بيئات المؤسسات، تظهر مجموعة من المتطلبات الأساسية، من أهمها:

- ضرورة أن تكون هويات المشاركين معروفة ويمكن التحقق منها
- أن تكون الشبكة مقيَّدة بالصلاحيات (Permissioned)
- القدرة على معالجة عدد كبير من المعاملات في وقت قصير
- زمن تأكيد منخفض للمعاملات
- توفير الخصوصية وسرية البيانات المرتبطة بالمعاملات التجارية

في حين أن العديد من منصات البلوكتشين الأولى يتم تكييفها لاحقًا لتناسب احتياجات المؤسسات، فإن Hyperledger Fabric تم تصميمه من الأساس ليخدم هذا النوع من الاستخدامات.
وفي الأقسام التالية، سيتم توضيح كيف يختلف Fabric عن غيره من منصات البلوكتشين، وما هي الدوافع المعمارية التي أثرت على تصميمه.


## Hyperledger Fabric

Hyperledger Fabric هو open source منصة enterprise-grade permissioned Distributed Ledger Technology (DLT)، معمولة أساسًا للاستخدام في بيئات الشركات والمؤسسات. المنصة بتقدّم مجموعة من الخصائص اللي بتميّزها بشكل واضح عن باقي منصات الـ blockchain أو الـ distributed ledger المشهورة.

واحدة من أهم نقاط التميّز إن Hyperledger اتأسست تحت مظلة Linux Foundation، واللي عندها تاريخ طويل وناجح جدًا في رعاية مشاريع open source باستخدام نموذج open governance. النموذج ده بيساعد على بناء مجتمعات قوية ومستدامة حوالين المشاريع، وبيخلق ecosystems صحية وفعّالة.
إدارة Hyperledger بتتم عن طريق Technical Steering Committee متنوع، ومشروع Hyperledger Fabric نفسه بيتم الحفاظ عليه بواسطة مجموعة maintainers من منظمات مختلفة. مجتمع التطوير كمان كبر بسرعة، ووصل لأكتر من 35 منظمة وحوالي 200 مطوّر من وقت أول commits في المشروع.

من الناحية المعمارية، Fabric مبني على تصميم modular وconfigurable بدرجة عالية، وده بيسمح بمرونة كبيرة في التخصيص والـ optimization حسب كل use case. علشان كده بيتم استخدامه في مجالات كتير جدًا زي: banking، finance، insurance، healthcare، human resources، supply chain وحتى digital music delivery.

Fabric كانت أول منصة distributed ledger تدعم كتابة smart contracts باستخدام general-purpose programming languages زي Go، Java، وNode.js، بدل الاعتماد على domain-specific languages (DSLs). الميزة هنا إن أغلب الشركات عندها بالفعل المطوّرين والـ skill set اللازمة، ومش محتاجة تستثمر وقت أو تكلفة إضافية في تعلّم لغة جديدة مخصوصة للـ blockchain.

كمان Fabric منصة permissioned، يعني المشاركين في الشبكة معروفين لبعضهم، بعكس الشبكات العامة permissionless اللي بيكون فيها المشاركين anonymous وغير موثوق فيهم بشكل كامل. ده لا يعني إن كل الأطراف لازم تثق في بعضها ثقة مطلقة — ممكن يكونوا منافسين في نفس السوق — لكن الشبكة بتشتغل تحت governance model مبني على مستوى الثقة الموجود فعلًا، زي اتفاقيات قانونية أو أطر واضحة للتعامل مع النزاعات.

من أقوى نقاط التميّز في Fabric دعمها لـ pluggable consensus protocols، واللي بيسمح بتغيير أو اختيار آلية الـ consensus المناسبة حسب طبيعة الـ use case ودرجة الثقة بين المشاركين.
على سبيل المثال، لو الشبكة شغالة داخل مؤسسة واحدة أو تحت إدارة جهة موثوقة، استخدام Byzantine Fault Tolerant (BFT) consensus ممكن يكون مبالغ فيه ويأثر سلبًا على الأداء. في الحالة دي، بروتوكول Crash Fault Tolerant (CFT) غالبًا بيكون كافي تمامًا.
أما في سيناريوهات multi-party وdecentralized، فهنا بيبقى استخدام BFT consensus أكثر منطقية وضروري.

Fabric كمان بتدعم استخدام consensus protocols من غير الحاجة إلى native cryptocurrency، يعني مفيش mining مكلف ولا عملة رقمية لازمة لتشغيل smart contracts أو تحفيز المشاركين. غياب العملة الرقمية بيقلل مخاطر وهجمات كتير محتملة، وكمان عدم وجود عمليات mining معناه إن تكلفة التشغيل بتكون قريبة جدًا من أي distributed system تقليدي.

كل الخصائص التصميمية دي مع بعض بتخلّي Fabric واحدة من أفضل المنصات أداءً حاليًا، سواء من ناحية transaction throughput أو transaction confirmation latency، وفي نفس الوقت بتوفّر مستوى عالي من privacy وconfidentiality للـ transactions والـ smart contracts (اللي Fabric بتسميها chaincode).

خلّينا نبدأ نستكشف الخصائص المميّزة دي بشكل أعمق في الأقسام الجاية.



## Modularity

تم تصميم Hyperledger Fabric من الأساس بمعمارية modular بشكل مقصود. سواء كنا بنتكلم عن pluggable consensus، أو pluggable identity management protocols زي LDAP أو OpenID Connect، أو حتى key management protocols وcryptographic libraries، فـ Fabric معمولة من قلبها بحيث تكون configurable وتقدر تتكيّف مع التنوع الكبير في enterprise use cases.

بشكل عام وعلى مستوى high-level architecture، Fabric بتتكوّن من مجموعة مكونات مستقلة وقابلة للتبديل (modular components)، أهمها:

- Pluggable Ordering Service
  مسؤولة عن تحقيق consensus على ترتيب الـ transactions، وبعد كده بتعمل broadcast للـ blocks إلى الـ peers في الشبكة.

- Pluggable Membership Service Provider (MSP)
  دورها ربط الكيانات (entities) الموجودة في الشبكة بهويات cryptographic identities، وده الأساس في نظام الـ identity وaccess control داخل Fabric.

- Optional Peer-to-Peer Gossip Service
  خدمة اختيارية بتستخدم آلية gossip protocol لنشر الـ blocks اللي طالعة من الـ ordering service لباقي الـ peers بشكل فعّال.

- Smart Contracts (Chaincode)
  الـ chaincode بيشتغل داخل containerized environment زي Docker علشان يوفّر isolation. ممكن كتابته باستخدام standard programming languages، لكن من غير وصول مباشر لحالة الـ ledger state.

- Configurable Ledger Storage
  الـ ledger نفسه ممكن يتظبط بحيث يشتغل مع أنواع مختلفة من DBMSs، وده بيدي مرونة كبيرة في اختيار نظام التخزين المناسب لكل use case.

- Pluggable Endorsement and Validation Policies
  آليات endorsement وvalidation قابلة للتبديل والتخصيص، وممكن تتظبط بشكل مستقل لكل application حسب متطلبات الثقة وقواعد العمل.

في الصناعة بشكل عام، فيه اتفاق واسع إن مفيش حاجة اسمها *“one blockchain to rule them all”*.
قوة Hyperledger Fabric الحقيقية إنها قابلة للتهيئة بأكتر من شكل، وده بيسمح لها تلبّي متطلبات حلول مختلفة جدًا عبر صناعات وuse cases متعددة، بدل ما تفرض نموذج واحد ثابت على الجميع.

## Permissioned vs Permissionless Blockchains

في شبكات permissionless blockchain، تقريبًا أي شخص يقدر يشارك، وكل المشاركين بيكونوا anonymous. في السياق ده، مفيش ثقة حقيقية بين الأطراف، باستثناء الثقة إن حالة الـ blockchain state قبل عمق معين (depth) تعتبر immutable ومش ممكن تغييرها.

علشان يتم التعامل مع غياب الثقة ده، الشبكات الـ permissionless غالبًا بتستخدم native cryptocurrency معمولة عن طريق mining أو بتفرض transaction fees. الهدف من ده هو خلق economic incentive يعوّض التكلفة العالية جدًا للمشاركة في نوع من Byzantine Fault Tolerant (BFT) consensus مبني على Proof of Work (PoW)، واللي بيكون مكلف جدًا من حيث الطاقة والأداء.

على العكس تمامًا، شبكات permissioned blockchain بتشتغل بين مجموعة مشاركين معروفين، محددين الهوية، وغالبًا تم التحقق منهم مسبقًا (vetted participants)، وده كله بيكون تحت governance model بيوفّر درجة معيّنة من الثقة.
الـ permissioned blockchain بتوفّر طريقة آمنة لتنظيم التفاعل بين مجموعة كيانات عندهم هدف مشترك، حتى لو مش واثقين في بعضهم ثقة كاملة.

بما إن هويات المشاركين معروفة، الشبكات الـ permissioned تقدر تستخدم consensus protocols أكثر تقليدية زي Crash Fault Tolerant (CFT) أو Byzantine Fault Tolerant (BFT)، من غير الحاجة إلى costly mining أو استهلاك موارد مبالغ فيه.

كمان، في السياق الـ permissioned ده، خطر إن أحد المشاركين يحاول إدخال malicious code عن عمد من خلال smart contract بيكون أقل بكتير.
السبب الأول إن كل المشاركين معروفين لبعضهم، وكل الأفعال — سواء submitting application transactions، أو modifying network configuration، أو deploying a smart contract — بتتسجل على الـ blockchain وفقًا لـ endorsement policy محددة مسبقًا للشبكة ونوع الـ transaction المعني.

وبدل ما يكون الفاعل completely anonymous، زي ما هو الحال في الشبكات العامة، الطرف المسؤول عن المخالفة بيكون سهل تحديده، والتعامل مع الحادثة بيتم وفقًا لشروط وقواعد الـ governance model المعتمدة في الشبكة.


## Smart Contracts

الـ smart contract — أو اللي Fabric بتسميه chaincode — هو في الأساس trusted distributed application بتستمد الأمان والثقة بتاعتها من الـ blockchain نفسها ومن الـ consensus القائم بين الـ peers.
الـ chaincode هو business logic الخاصة بأي blockchain application.

فيه تلات نقاط أساسية لازم ناخدهم في الاعتبار عند التعامل مع smart contracts، خصوصًا على مستوى المنصات:

* عدد كبير من الـ smart contracts بيشتغلوا concurrently في نفس الشبكة،
* ممكن يتم deploy للـ smart contracts بشكل dynamic (وفي حالات كتير بواسطة أي طرف في الشبكة)،
* كود التطبيق نفسه لازم يتعامل معاه على إنه untrusted، وممكن يكون malicious في أسوأ الحالات.

أغلب منصات الـ blockchain اللي بتدعم smart contracts حاليًا بتشتغل وفق معمارية اسمها order-execute، واللي فيها بروتوكول الـ consensus بيقوم بالآتي:

* يعمل validation وordering للـ transactions، وبعد كده ينشرها لكل الـ peer nodes،
* كل peer بعد كده بينفّذ الـ transactions sequentially وبنفس الترتيب.

معمارية order-execute موجودة تقريبًا في كل أنظمة الـ blockchain الحالية، سواء كانت منصات عامة public / permissionless زي
[Ethereum](https://ethereum.org/) (بـ PoW-based consensus)
أو منصات permissioned زي
[Tendermint](http://tendermint.com/)،
[Chain](http://chain.com/)،
و [Quorum](http://www.jpmorgan.com/global/Quorum).

في أي blockchain شغالة بمعمارية order-execute، لازم يكون تنفيذ الـ smart contracts deterministic؛ لأن غير كده الـ consensus ممكن ما يوصلش أبدًا لنتيجة موحّدة.
ولحل مشكلة non-determinism، منصات كتير بتفرض إن كتابة الـ smart contracts تكون باستخدام non-standard أو domain-specific languages (DSLs) زي
[Solidity](https://solidity.readthedocs.io/en/v0.4.23/)
وده بيسمح بالتحكم في العمليات غير الحتمية ومنعها.

لكن النهج ده بيعيق wide-spread adoption، لأنه بيجبر المطوّرين يتعلّموا لغة جديدة مخصوصة للـ smart contracts، وده ممكن يزوّد احتمالية programming errors.

بالإضافة لكده، وبسبب إن كل الـ transactions بتتنفّذ sequentially على كل الـ nodes، فالأداء (performance) وقابلية التوسع (scalability) بيبقوا محدودين.
كون إن كود الـ smart contract بيتنفّذ على every node في النظام بيخلّي المنصة محتاجة إجراءات معقدة جدًا لحماية الشبكة من potentially malicious contracts، وده علشان نضمن resiliency واستقرار النظام ككل.


## A New Approach

بتقدّم Hyperledger Fabric معمارية جديدة للتعامل مع الـ transactions اسمها
execute-order-validate.
المعمارية دي اتصممت علشان تعالج مشاكل resiliency، flexibility، scalability، performance وconfidentiality اللي بيعاني منها نموذج order-execute التقليدي، وده عن طريق فصل مسار الـ transaction لثلاث مراحل واضحة:

* execute
  تنفيذ الـ transaction والتحقق من صحتها، وبالتالي عمل endorsement ليها.
* order
  ترتيب الـ transactions باستخدام pluggable consensus protocol.
* validate
  التحقق من الـ transactions بناءً على application-specific endorsement policy قبل ما يتم commit على الـ ledger.

التصميم ده مختلف جذريًا عن نموذج order-execute، لأن Fabric بتنفّذ الـ transactions قبل ما يتم الوصول لاتفاق نهائي على ترتيبها.

في Fabric، الـ endorsement policy الخاصة بكل application بتحدد مين من الـ peer nodes — أو كام واحد منهم — مطلوب منهم يثبتوا صحة تنفيذ smart contract معيّن.
وبالتالي، كل transaction بتتنفّذ (ويتم عمل endorsement ليها) فقط على subset من الـ peers اللي يكفوا لتحقيق شروط الـ endorsement policy، مش على كل الشبكة.

النهج ده بيسمح بـ parallel execution للـ transactions، وده بيرفع بشكل كبير performance وscalability على مستوى النظام كله.
المرحلة الأولى دي كمان بتقوم بدور مهم جدًا، وهو إنها تقضي على non-determinism، لأن أي نتائج تنفيذ غير متطابقة بتتفلتر قبل مرحلة الـ ordering.

وبما إن مشكلة non-determinism اتحلّت من الأساس، أصبحت Fabric أول تقنية blockchain
بتسمح باستخدام standard programming languages في كتابة الـ smart contracts، من غير قيود معمارية أو لغات خاصة.


## Privacy and Confidentiality

زي ما اتكلمنا قبل كده، في شبكات public permissionless blockchain اللي بتستخدم Proof of Work (PoW) كنموذج consensus، كل transaction بتتنفّذ على every node في الشبكة.
النتيجة الطبيعية لكده إن مفيش confidentiality لا على مستوى الـ smart contracts نفسها، ولا على مستوى transaction data اللي بتتعامل معاها. كل transaction، والكود اللي بينفّذها، بيبقوا visible لكل node في الشبكة.
بمعنى آخر، إحنا هنا بنضحّي بـ privacy وconfidentiality مقابل الحصول على Byzantine Fault Tolerant consensus معتمد على PoW.

غياب الخصوصية ده بيشكّل مشكلة حقيقية في كتير من enterprise use cases.
على سبيل المثال، في شبكة supply chain فيها شركاء كتير، ممكن بعض العملاء يحصلوا على preferred rates كجزء من بناء علاقة تجارية قوية أو لتشجيع مبيعات إضافية.
لو كل المشاركين شايفين كل الـ contracts وكل الـ transactions، الحفاظ على النوع ده من العلاقات التجارية هيبقى مستحيل — لأن ببساطة كل الأطراف هتطالب بنفس الأسعار التفضيلية.

مثال تاني من securities industry:
التاجر (trader) اللي بيبني مركز مالي (position) أو بيخرج منه، بالتأكيد مش حابب منافسيه يعرفوا ده. لو المعلومة دي كانت مكشوفة، المنافسين هيحاولوا يدخلوا السوق في نفس الاتجاه، وده يضعف الاستراتيجية (gambit) بتاعته.

علشان يتم التعامل مع مشكلة نقص privacy وconfidentiality وتلبية متطلبات الشركات، منصات الـ blockchain جرّبت أكتر من نهج مختلف، وكل نهج ليه trade-offs خاصة بيه.

واحد من الحلول هو encrypting data.
لكن في شبكة permissionless شغالة بـ PoW، البيانات المشفّرة نفسها بتكون موجودة على كل الـ nodes. ومع الوقت، ومع توفر موارد حسابية كافية، ممكن التشفير يتم كسره.
بالنسبة لكتير من enterprise use cases، مجرد احتمالية إن البيانات الحساسة تتعرّض للاختراق تعتبر مخاطرة غير مقبولة.

نهج تاني قيد البحث هو Zero Knowledge Proofs (ZKP).
الميزة هنا إنها بتوفّر درجة عالية من الخصوصية، لكن المقابل إن حساب ZKP حاليًا بيحتاج وقت طويل وموارد حسابية كبيرة.
يعني في الحالة دي، المقايضة بتكون performance مقابل confidentiality.

في سياق permissioned blockchain اللي تقدر تستخدم أشكال بديلة من الـ consensus، ممكن تطبيق حلول بتقيّد توزيع المعلومات الحساسة بحيث توصل فقط إلى authorized nodes.

وبما إن Hyperledger Fabric منصة permissioned، فهي بتوفّر الخصوصية والسرية من خلال channel architecture وميزة
[private data](./private-data/private-data.html).

في channels، المشاركين في شبكة Fabric بيكوّنوا sub-network، بحيث كل عضو في القناة يكون ليه صلاحية رؤية مجموعة معيّنة من الـ transactions.
وبالتالي، فقط الـ nodes اللي مشتركة في القناة هي اللي تقدر تشوف الـ smart contract (chaincode) والبيانات اللي بيتم التداول عليها، وده بيحافظ على privacy وconfidentiality للطرفين.

ميزة private data بتسمح بإنشاء data collections بين أعضاء داخل نفس القناة، وبتقدّم حماية قريبة جدًا من فكرة القنوات، لكن من غير العبء الإداري (maintenance overhead) الخاص بإنشاء وإدارة قناة منفصلة.

## Pluggable Consensus

مسؤولية ordering transactions في Hyperledger Fabric متفوضة لمكوّن modular خاص بالـ consensus، ومكوّن ده منفصل منطقيًا (logically decoupled) عن الـ peers اللي دورهم تنفيذ الـ transactions والحفاظ على الـ ledger.
المكوّن ده هو تحديدًا ordering service.

وبما إن الـ consensus نفسه modular، فتنفيذه ممكن يتخصّص حسب trust assumptions الخاصة بكل deployment أو solution.
المعمارية المرنة دي بتسمح لـ Fabric إنها تعتمد على well-established toolkits لتنفيذ آليات ترتيب CFT (crash fault-tolerant) أو BFT (byzantine fault-tolerant).

حاليًا، Fabric بتوفّر CFT ordering service مبني على مكتبة
[`etcd`](https://coreos.com/etcd/)
واللي بتستخدم Raft protocol
([Raft paper](https://raft.github.io/raft.pdf)).

للاطلاع على تفاصيل أكتر عن خدمات الـ ordering المتاحة حاليًا، راجع
[conceptual documentation about ordering](./orderer/ordering_service.html).

ومن المهم نلاحظ إن الاختيارات دي مش mutually exclusive.
شبكة Fabric واحدة ممكن يكون فيها multiple ordering services في نفس الوقت، بحيث كل ordering service تخدم application مختلف أو تلبّي application requirements متباينة.

## Performance and Scalability

أداء أي blockchain platform بيتأثر بعدد كبير من العوامل، زي transaction size، block size، حجم الشبكة (network size)، بالإضافة لقيود وإمكانات hardware نفسها، وغيرها من المتغيرات.

في Hyperledger Fabric، مجموعة العمل الخاصة بالأداء وقابلية التوسع
[Performance and Scale Working Group](https://wiki.hyperledger.org/display/PSWG/Performance+and+Scale+Working+Group)
شغّالة حاليًا على إطار عمل للـ benchmarking اسمه
[Hyperledger Caliper](https://wiki.hyperledger.org/display/caliper).
Caliper بيُستخدم لقياس ومقارنة أداء منصات الـ blockchain بشكل منهجي ومحايد.

كمان، اتنشرت عدة research papers قامت بدراسة واختبار قدرات الأداء في Hyperledger Fabric.
أحدث الدراسات دي قدرت توصل بـ Fabric لحد
[20,000 transactions per second](https://arxiv.org/abs/1901.00910)،
وده بيبرز مستوى performance وscalability العالي اللي ممكن تحققه المنصة في سيناريوهات معينة.


## Conclusion

أي تقييم جاد لأي blockchain platform لازم يحط Hyperledger Fabric ضمن
short list الخاصة بالمنصات المرشحة.

مجتمعة، الخصائص المميّزة لـ Fabric بتخليها منصة highly scalable للـ permissioned blockchains، وبتدعم flexible trust assumptions تسمح بتكييف الشبكة حسب طبيعة الثقة بين المشاركين. المرونة دي بتمكّن المنصة من دعم نطاق واسع جدًا من industry use cases، بداية من government وfinance، مرورًا بـ supply-chain logistics، ووصولًا إلى healthcare، وغيرهم كتير.

Hyperledger Fabric هي حاليًا أكثر مشاريع Hyperledger نشاطًا.
المجتمع المحيط بالمنصة بيكبر بشكل مستمر، ومستوى innovation اللي بيتم تقديمه مع كل release جديد بيتفوّق بفارق واضح على باقي منصات enterprise blockchain الموجودة في السوق.


## Acknowledgement

يستند هذا المحتوي الي الورقة البحثية التالية
["Hyperledger Fabric: A Distributed Operating System for Permissioned Blockchains"](https://dl.acm.org/doi/10.1145/3190508.3190538) - Elli Androulaki, Artem
Barger, Vita Bortnikov, Christian Cachin, Konstantinos Christidis, Angelo De
Caro, David Enyeart, Christopher Ferris, Gennady Laventman, Yacov Manevich,
Srinivasan Muralidharan, Chet Murthy, Binh Nguyen, Manish Sethi, Gari Singh,
Keith Smith, Alessandro Sorniotti, Chrysoula Stathakopoulou, Marko Vukolic,
Sharon Weed Cocco, Jason Yellick
