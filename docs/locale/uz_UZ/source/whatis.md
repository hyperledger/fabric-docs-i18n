# Kirish

Umumiy ma'noda blokcheyn — bu *peer tugunlar*dan iborat taqsimlangan tarmoqda
yuritiladigan, tranzaksiyalarning o'zgarmas reestri. Har bir tugun
reestrning o'z nusxasini saqlaydi va unga _konsensus protokoli_ orqali
validatsiyadan o'tgan tranzaksiyalarni qo'llaydi. Tranzaksiyalar bloklarga
guruhlanadi, har bir blokda esa uni oldingi blok bilan bog'laydigan xesh
bo'ladi.

Blokcheynning birinchi va eng mashhur qo'llanilishi —
[Bitcoin](https://en.wikipedia.org/wiki/Bitcoin) kriptovalyutasi, garchi
undan keyin boshqalar ham shu yo'ldan borgan bo'lsa-da. Muqobil kriptovalyuta
bo'lgan Ethereum boshqacha yondashuvni tanladi: u Bitcoin'ning ko'plab
xususiyatlarini o'zida jamladi, lekin taqsimlangan ilovalar uchun platforma
yaratish maqsadida *smart-kontraktlar*ni qo'shdi. Bitcoin va Ethereum biz
_ommaviy, ruxsat talab qilmaydigan_ (public permissionless) blokcheyn texnologiyasi deb tasniflaydigan blokcheynlar
sinfiga kiradi. Oddiy qilib aytganda, bular hamma uchun ochiq bo'lgan ommaviy
tarmoqlar bo'lib, ularda ishtirokchilar anonim tarzda o'zaro ishlaydi.

Bitcoin, Ethereum va ulardan kelib chiqqan boshqa bir nechta texnologiyalar
ommalashgani sari blokcheyn, taqsimlangan reestr va taqsimlangan ilovalar
platformasi negizida yotgan texnologiyani yanada innovatsion _korporativ_
vazifalarda qo'llashga qiziqish ham ortdi. Biroq ko'plab korporativ vazifalar
ruxsat talab qilmaydigan blokcheyn texnologiyalari (hozircha) ta'minlay olmaydigan unumdorlik
ko'rsatkichlarini talab qiladi. Bundan tashqari, ko'p hollarda
ishtirokchilarning shaxsi aniq bo'lishi qat'iy talab hisoblanadi. Masalan,
moliyaviy tranzaksiyalarda "Mijozingni bil" (KYC) va jinoiy daromadlarni
legallashtirishga qarshi kurash (AML) qoidalariga rioya qilish shart.

Korporativ foydalanish uchun quyidagi talablarni hisobga olishimiz kerak:

- Ishtirokchilar aniqlangan yoki aniqlanadigan bo'lishi kerak
- Tarmoqlar _ruxsatli_ bo'lishi kerak
- Tranzaksiyalarni qayta ishlashning yuqori o'tkazish qobiliyati
- Tranzaksiya yakunlanishigacha bo'lgan past kechikish
- Biznes tranzaksiyalariga oid tranzaksiyalar va ma'lumotlarning maxfiyligi
  va konfidensialligi

Ko'plab ilk blokcheyn platformalari hozirda korporativ foydalanishga
_moslashtirilayotgan_ bo'lsa, Hyperledger Fabric boshidanoq korporativ
foydalanish uchun _loyihalangan_. Keyingi bo'limlarda Hyperledger Fabric
(Fabric) boshqa blokcheyn platformalaridan qanday farq qilishi va uning
arxitekturaviy qarorlari ortidagi ba'zi sabablar tasvirlanadi.

## Hyperledger Fabric

Hyperledger Fabric — korporativ muhitda foydalanish uchun loyihalangan, ochiq
kodli, korporativ darajadagi ruxsatli taqsimlangan reestr texnologiyasi (DLT)
platformasi. U boshqa mashhur taqsimlangan reestr yoki blokcheyn
platformalariga nisbatan bir qator muhim o'ziga xos imkoniyatlarni taqdim etadi.

Asosiy farqlardan biri shundaki, Hyperledger Linux Foundation tarkibida tashkil
etilgan. Linux Foundation esa **ochiq boshqaruv** asosida ochiq kodli
loyihalarni rivojlantirish bo'yicha ko'p yillik va juda muvaffaqiyatli tajribaga ega:
bunday loyihalar atrofida kuchli va barqaror hamjamiyatlar hamda gullab-yashnayotgan
ekotizimlar shakllanadi. Hyperledger turli a'zolardan iborat texnik boshqaruv
qo'mitasi tomonidan, Hyperledger Fabric loyihasi esa bir nechta tashkilotlardan
kelgan turli maintainer'lar tomonidan boshqariladi. Loyihaning ilk commit'laridan
beri uning ishlab chiquvchilar hamjamiyati 35 dan ortiq tashkilot va qariyb
200 nafar dasturchiga yetdi.

Fabric yuqori darajada **modulli** va **sozlanadigan** arxitekturaga ega. Bu
bank ishi, moliya, sug'urta, sog'liqni saqlash, kadrlar boshqaruvi, ta'minot
zanjiri va hatto raqamli musiqa yetkazib berish kabi keng ko'lamli sohaviy
vazifalar uchun innovatsiya, moslashuvchanlik va optimallashtirish imkonini
beradi.

Fabric — cheklangan sohaviy tillar (DSL) emas, balki Java, Go va Node.js kabi
**umumiy maqsadli dasturlash tillarida yozilgan smart-kontraktlarni**
qo'llab-quvvatlaydigan birinchi taqsimlangan reestr platformasi. Bu shuni
anglatadiki, ko'pchilik korxonalarda smart-kontraktlarni ishlab chiqish uchun
zarur ko'nikmalar allaqachon mavjud va yangi til yoki DSL'ni o'rganish uchun
qo'shimcha o'qish talab qilinmaydi.

Fabric platformasi, shuningdek, **ruxsatli** hisoblanadi. Ya'ni ommaviy, ruxsat
talab qilmaydigan tarmoqdan farqli o'laroq, ishtirokchilar bir-biriga ma'lum:
ular anonim emas, demak, mutlaqo ishonib bo'lmaydigan taraflar ham emas. Bu shuni anglatadiki,
ishtirokchilar bir-birlariga _to'liq_ ishonmasalar ham (masalan, ular bir
sohadagi raqobatchilar bo'lishi mumkin), tarmoqni ishtirokchilar o'rtasida
_mavjud bo'lgan_ ishonch asosida qurilgan boshqaruv modeli bo'yicha
yuritish mumkin. Bunday ishonchga, masalan, yuridik shartnoma yoki nizolarni
hal qilish tartibi asos bo'lishi mumkin.

Platformaning eng muhim o'ziga xos jihatlaridan biri — **almashtiriladigan (pluggable)
konsensus protokollarini** qo'llab-quvvatlashi. Bu platformani muayyan vazifalar va
ishonch modellariga yanada samarali moslashtirish imkonini beradi. Masalan,
platforma bitta korxona ichida joylashtirilganda yoki ishonchli organ
tomonidan boshqarilganda, Vizantiya nosozliklariga to'liq bardoshli konsensus
ortiqcha bo'lib, unumdorlik va o'tkazish qobiliyatini keraksiz pasaytirishi
mumkin. Bunday vaziyatlarda
[avariyaviy nosozliklarga bardoshli](https://en.wikipedia.org/wiki/Fault_tolerance) (CFT)
konsensus protokoli yetarli bo'lishi mumkin. Ko'p tomonli, markazlashmagan
vazifalarda esa an'anaviyroq
[Vizantiya nosozliklariga bardoshli](https://en.wikipedia.org/wiki/Byzantine_fault_tolerance)
(BFT) konsensus protokoli talab qilinishi mumkin.

Fabric qimmatga tushadigan mayningni rag'batlantirish yoki smart-kontraktlarni
bajarishni ta'minlash uchun **o'z kriptovalyutasini talab qilmaydigan**
konsensus protokollaridan foydalana oladi. Kriptovalyutadan voz kechish ba'zi
jiddiy xavf va hujum yo'nalishlarini kamaytiradi, kriptografik mayning
operatsiyalarining yo'qligi esa platformani boshqa har qanday taqsimlangan
tizim bilan taxminan bir xil operatsion xarajatlar bilan joylashtirish mumkinligini
anglatadi.

Ushbu o'ziga xos arxitekturaviy xususiyatlarning uyg'unligi Fabric'ni
tranzaksiyalarni qayta ishlash tezligi jihatidan ham, tranzaksiya
yakunlanishigacha bo'lgan kechikish jihatidan ham bugungi kundagi
**unumdorligi yuqori platformalardan** biriga aylantiradi. U
tranzaksiyalar va ularni amalga oshiradigan smart-kontraktlarning (Fabric ularni
"chaincode" deb ataydi) **maxfiyligi va konfidensialligini** ham ta'minlaydi.

Keling, ushbu o'ziga xos xususiyatlarni batafsilroq ko'rib chiqamiz.

## Modullilik

Hyperledger Fabric ataylab modulli arxitektura asosida loyihalangan.
Almashtiriladigan konsensus bo'ladimi, LDAP yoki OpenID Connect kabi
raqamli shaxslarni boshqarishning almashtiriladigan protokollari bo'ladimi, kalitlarni
boshqarish protokollari yoki kriptografik kutubxonalar bo'ladimi — platforma
negizidanoq turli-tuman korporativ talablarga moslab sozlanadigan qilib
yaratilgan.

Umumiy ko'rinishda Fabric quyidagi modulli komponentlardan iborat:

- Almashtiriladigan _tartiblash xizmati_ tranzaksiyalar tartibi bo'yicha
konsensusga erishadi va so'ngra bloklarni peer'larga tarqatadi.
- Almashtiriladigan _a'zolik xizmati provayderi_ tarmoqdagi subyektlarni
kriptografik raqamli shaxslar (identity) bilan bog'lash vazifasini bajaradi.
- Ixtiyoriy _peer-to-peer gossip xizmati_ tartiblash xizmati chiqargan bloklarni
boshqa peer'larga tarqatadi.
- Smart-kontraktlar ("chaincode") izolyatsiya uchun konteyner muhitida (masalan,
Docker) ishlaydi. Ular standart dasturlash tillarida yozilishi mumkin, lekin
reestr holatiga to'g'ridan-to'g'ri kirish huquqiga ega emas.
- Reestrni turli MBBT'larni (ma'lumotlar bazasini boshqarish tizimlarini)
qo'llab-quvvatlaydigan qilib sozlash mumkin.
- Har bir ilova uchun alohida sozlanadigan, almashtiriladigan tasdiqlash va
validatsiya siyosatlarini qo'llash mexanizmi.

Sohada "hammasi uchun yagona blokcheyn" yo'q degan fikrga deyarli hamma qo'shiladi.
Hyperledger Fabric turli sohalardagi vazifalarning xilma-xil talablarini
qondirish uchun ko'p usullarda sozlanishi mumkin.

## Ruxsatli va ruxsat talab qilmaydigan blokcheynlar

Ruxsat talab qilmaydigan blokcheynda deyarli har kim ishtirok etishi mumkin va har bir
ishtirokchi anonim bo'ladi. Bunday sharoitda blokcheynning ma'lum chuqurlikdan
oldingi holati o'zgarmas ekanidan boshqa hech narsaga ishonib bo'lmaydi. Ushbu ishonch yo'qligini yumshatish uchun ruxsat talab qilmaydigan blokcheynlar odatda
"mayning" qilinadigan o'z kriptovalyutasidan yoki tranzaksiya to'lovlaridan
foydalanadi. Bu "ish isboti" (proof of work, PoW) asosidagi Vizantiya
nosozliklariga bardoshli konsensusda ishtirok etishning favqulodda katta
xarajatlarini qoplash uchun iqtisodiy rag'bat beradi.

**Ruxsatli** blokcheynlar esa ma'lum, aniqlangan va ko'pincha tekshiruvdan
o'tgan ishtirokchilar to'plami o'rtasida ishlaydi. Bu ishtirokchilar ma'lum
darajada ishonch hosil qiladigan boshqaruv modeli asosida faoliyat yuritadi.
Ruxsatli blokcheyn umumiy maqsadga ega, lekin bir-biriga to'liq ishonmasligi
mumkin bo'lgan subyektlar guruhi o'rtasidagi o'zaro aloqalarni himoyalash
usulini taqdim etadi. Ishtirokchilarning raqamli shaxslariga tayangan holda
ruxsatli blokcheyn qimmat mayningni talab qilmaydigan an'anaviyroq avariyaviy
nosozliklarga bardoshli (CFT) yoki Vizantiya nosozliklariga bardoshli
(BFT) konsensus protokollaridan foydalana oladi.

Bundan tashqari, bunday ruxsatli muhitda ishtirokchining smart-kontrakt orqali
ataylab zararli kod kiritish xavfi kamayadi. Birinchidan, ishtirokchilar
bir-birlariga ma'lum va barcha harakatlar — ilova tranzaksiyalarini yuborish,
tarmoq konfiguratsiyasini o'zgartirish yoki smart-kontraktni joylashtirish
bo'ladimi — tarmoq va tegishli tranzaksiya turi uchun belgilangan tasdiqlash
siyosatiga muvofiq blokcheynda qayd etiladi. Aybdor tomon to'liq anonim
bo'lmagani uchun uni osongina aniqlash va hodisani boshqaruv modeli shartlariga
muvofiq hal qilish mumkin.

## Smart-kontraktlar

Smart-kontrakt (Fabric'da u "chaincode" deb ataladi) ishonchli
taqsimlangan ilova sifatida ishlaydi. U o'z xavfsizligi va ishonchliligini
blokcheyndan hamda peer'lar o'rtasidagi konsensusdan oladi. Smart-kontrakt —
blokcheyn ilovasining biznes mantiqidir.

Smart-kontraktlarga, ayniqsa ular platformada qo'llanilganda, uchta asosiy
jihat tegishli:

- tarmoqda bir vaqtning o'zida ko'plab smart-kontraktlar ishlaydi,
- ular dinamik ravishda joylashtirilishi mumkin (ko'p hollarda har kim
tomonidan) va
- ilova kodiga ishonchsiz, hatto zararli bo'lishi mumkin bo'lgan kod sifatida
qaralishi kerak.

Smart-kontraktlarni qo'llab-quvvatlaydigan mavjud blokcheyn platformalarining
aksariyati **tartiblash-bajarish** (order-execute) arxitekturasiga amal qiladi.
Unda konsensus protokoli:

- tranzaksiyalarni validatsiyadan o'tkazadi va tartiblaydi, so'ngra ularni
barcha peer tugunlarga tarqatadi,
- shundan keyin har bir peer tranzaksiyalarni ketma-ket bajaradi.

Tartiblash-bajarish arxitekturasini deyarli barcha mavjud blokcheyn
tizimlarida uchratish mumkin: [Ethereum](https://ethereum.org/) (PoW asosidagi
konsensus bilan) kabi ommaviy/ruxsat talab qilmaydigan platformalardan tortib
[Tendermint](http://tendermint.com/), [Chain](http://chain.com/) va
[Quorum](http://www.jpmorgan.com/global/Quorum) kabi ruxsatli platformalargacha.

Tartiblash-bajarish arxitekturasida ishlaydigan blokcheynda bajariladigan
smart-kontraktlar deterministik bo'lishi shart, aks holda konsensusga hech
qachon erishilmasligi mumkin. Nodeterminizm muammosini hal qilish uchun ko'plab
platformalar smart-kontraktlarning nostandart yoki sohaviy tilda (masalan,
[Solidity](https://solidity.readthedocs.io/en/v0.4.23/)) yozilishini talab
qiladi, shunda nodeterministik operatsiyalarni istisno qilish mumkin bo'ladi.
Bu keng tarqalishga to'sqinlik qiladi, chunki smart-kontrakt yozadigan
dasturchilardan yangi tilni o'rganishni talab qiladi va dasturlash xatolariga
olib kelishi mumkin.

Bundan tashqari, barcha tranzaksiyalar barcha tugunlar tomonidan ketma-ket
bajarilgani sababli unumdorlik va kengayuvchanlik cheklanadi.
Smart-kontrakt kodining tizimdagi har bir tugunda bajarilishi butun tizimning
barqarorligini ta'minlash uchun uni zararli bo'lishi mumkin bo'lgan
kontraktlardan himoya qilishning murakkab choralarini ko'rishni talab qiladi.

## Yangi yondashuv

Fabric tranzaksiyalar uchun biz **bajarish-tartiblash-validatsiya**
(execute-order-validate) deb ataydigan yangi arxitekturani taqdim etadi. U
tranzaksiya oqimini uch bosqichga ajratish orqali tartiblash-bajarish modeli
duch keladigan barqarorlik, moslashuvchanlik, kengayuvchanlik, unumdorlik va
konfidensiallik muammolarini hal qiladi:

- tranzaksiyani _bajarish_ va uning to'g'riligini tekshirish, shu orqali uni
tasdiqlash (endorsement),
- tranzaksiyalarni (almashtiriladigan) konsensus protokoli orqali _tartiblash_
va
- tranzaksiyalarni reestrga qayd etishdan oldin ilovaga xos tasdiqlash
siyosatiga muvofiq _validatsiyadan o'tkazish_

Bu yondashuv tartiblash-bajarish paradigmasidan tubdan farq qiladi, chunki
Fabric tranzaksiyalarni ularning tartibi bo'yicha yakuniy kelishuvga
erishilishidan oldin bajaradi.

Fabric'da ilovaga xos tasdiqlash siyosati qaysi peer tugunlar yoki ulardan
nechtasi ma'lum bir smart-kontraktning to'g'ri bajarilganini kafolatlashi
kerakligini belgilaydi. Shunday qilib, har bir tranzaksiyani faqat uning
tasdiqlash siyosatini qondirish uchun zarur bo'lgan peer tugunlar qismi
bajarishi (tasdiqlashi) kifoya. Bu parallel bajarish imkonini beradi va
tizimning umumiy unumdorligi hamda kengayuvchanligini oshiradi. Ushbu
birinchi bosqich **har qanday nodeterminizmni ham bartaraf etadi**, chunki
bir-biriga mos kelmaydigan natijalarni tartiblashdan oldin saralab tashlash
mumkin.

Nodeterminizmni bartaraf etganimiz uchun Fabric **standart dasturlash
tillaridan foydalanish imkonini beradigan** birinchi blokcheyn texnologiyasi
hisoblanadi.

## Maxfiylik va konfidensiallik

Yuqorida muhokama qilganimizdek, konsensus modeli uchun PoW'dan foydalanadigan
ommaviy, ruxsat talab qilmaydigan blokcheyn tarmog'ida tranzaksiyalar har bir tugunda bajariladi.
Bu kontraktlarning o'zi ham, ular qayta ishlaydigan tranzaksiya ma'lumotlari
ham konfidensial bo'la olmasligini anglatadi. Har bir tranzaksiya va uni amalga
oshiradigan kod tarmoqdagi har bir tugunga ko'rinadi. Bunda biz PoW
ta'minlaydigan Vizantiya nosozliklariga bardoshli konsensus evaziga kontrakt
va ma'lumotlar konfidensialligini qurbon qilgan bo'lamiz.

Konfidensiallikning bunday yo'qligi ko'plab biznes va korporativ vazifalar
uchun muammo bo'lishi mumkin. Masalan, ta'minot zanjiri hamkorlari tarmog'ida
ba'zi iste'molchilarga munosabatlarni mustahkamlash yoki qo'shimcha savdoni
rag'batlantirish maqsadida imtiyozli narxlar berilishi mumkin. Agar har bir
ishtirokchi har bir kontrakt va tranzaksiyani ko'ra olsa, to'liq shaffof
tarmoqda bunday biznes munosabatlarini saqlab qolish imkonsiz bo'lib qoladi —
hamma imtiyozli narxlarni xohlaydi!

Ikkinchi misol sifatida qimmatli qog'ozlar sohasini ko'rib chiqing: pozitsiya
ochayotgan (yoki uni yopayotgan) treyder o'z raqobatchilari bundan xabar topishini
istamaydi, aks holda ular ham bu o'yinga qo'shilishga harakat qiladi va
treyderning rejasini zaiflashtiradi.

Korporativ talablarni bajarish maqsadida maxfiylik va konfidensiallik
yetishmasligi muammosini hal qilish uchun blokcheyn platformalari turli yondashuvlarni
qo'llagan. Ularning barchasi o'z kamchiliklariga ega.

Ma'lumotlarni shifrlash konfidensiallikni ta'minlashning bir usuli. Biroq
konsensus uchun PoW'dan foydalanadigan ruxsat talab qilmaydigan tarmoqda shifrlangan
ma'lumotlar har bir tugunda saqlanadi. Yetarli vaqt va hisoblash resurslari
bo'lsa, shifrni buzish mumkin. Ko'plab korporativ vazifalar uchun o'z
ma'lumotlari oshkor bo'lib qolishi xavfi qabul qilib bo'lmaydigan holatdir.

Nol bilimli isbotlar (zero knowledge proofs, ZKP) bu muammoni hal qilish uchun
o'rganilayotgan yana bir tadqiqot yo'nalishi. Bunda kamchilik shundaki, hozirda
ZKP'ni hisoblash ko'p vaqt va hisoblash resurslarini talab qiladi. Demak, bu
holda konfidensiallik uchun unumdorlikdan voz kechiladi.

Konsensusning muqobil shakllaridan foydalana oladigan ruxsatli muhitda
konfidensial ma'lumotlarning tarqatilishini faqat vakolatli tugunlar bilan
cheklaydigan yondashuvlarni ko'rib chiqish mumkin.

Ruxsatli platforma bo'lgan Hyperledger Fabric konfidensiallikni o'zining kanal
arxitekturasi va [maxfiy ma'lumotlar](./private-data/private-data.html)
imkoniyati orqali ta'minlaydi. Kanallarda Fabric tarmog'i ishtirokchilari
quyi tarmoq tashkil qiladi, unda har bir a'zo ma'lum bir tranzaksiyalar
to'plamini ko'ra oladi. Shunday qilib, smart-kontraktga (chaincode) va
tranzaksiya ma'lumotlariga faqat kanalda ishtirok etadigan tugunlargina kira
oladi, bu esa ikkalasining ham maxfiyligi va konfidensialligini saqlaydi.
Maxfiy ma'lumotlar kanal a'zolari o'rtasida to'plamlar (collection) yaratish
imkonini beradi. Bu alohida kanal yaratish va uni yuritish xarajatlarisiz
kanallar beradigan himoyaning katta qismini ta'minlaydi.

## Almashtiriladigan konsensus

Tranzaksiyalarni tartiblash vazifasi konsensus uchun mo'ljallangan modulli
komponentga topshiriladi. Bu komponent tranzaksiyalarni bajaradigan va reestrni
yuritadigan peer'lardan mantiqiy jihatdan ajratilgan. Aniqrog'i, bu tartiblash
xizmatidir. Konsensus modulli bo'lgani uchun uning implementatsiyasini muayyan
joylashtirish varianti yoki yechimning ishonch farazlariga moslashtirish mumkin. Ushbu
modulli arxitektura platformaga CFT (avariyaviy nosozliklarga bardoshli)
yoki BFT (Vizantiya nosozliklariga bardoshli) tartiblash uchun yaxshi sinalgan
vositalarga tayanish imkonini beradi.

Hozirda Fabric [`etcd` kutubxonasi](https://coreos.com/etcd/)dagi
[Raft protokoli](https://raft.github.io/raft.pdf) implementatsiyasiga asoslangan
CFT tartiblash xizmatini taklif etadi. Hozirda mavjud tartiblash xizmatlari haqida
ma'lumot olish uchun [tartiblash haqidagi konseptual hujjatlarimizni](./orderer/ordering_service.html)
ko'rib chiqing.

Shuni ham yodda tutingki, bular bir-birini istisno qilmaydi. Fabric tarmog'ida
turli ilovalar yoki ilova talablarini qo'llab-quvvatlaydigan bir nechta
tartiblash xizmati bo'lishi mumkin.

## Unumdorlik va kengayuvchanlik

Blokcheyn platformasining unumdorligiga ko'plab omillar ta'sir qilishi mumkin:
tranzaksiya hajmi, blok hajmi, tarmoq hajmi, shuningdek protsessor, xotira,
disk hajmi, disk va tarmoq kiritish-chiqarish (I/O) tezligi kabi mavjud
apparat resurslari.

## Xulosa

Blokcheyn platformalarini jiddiy baholashda Hyperledger Fabric albatta qisqa
ro'yxatga kiritilishi kerak.

Fabric'ning o'ziga xos imkoniyatlari birgalikda uni moslashuvchan ishonch
farazlarini qo'llab-quvvatlaydigan, yuqori darajada kengayuvchan ruxsatli
blokcheyn tizimiga aylantiradi. Bu platformaga davlat boshqaruvidan tortib
moliya, ta'minot zanjiri logistikasi, sog'liqni saqlash va boshqa ko'plab
sohalargacha bo'lgan keng ko'lamli vazifalarni qo'llab-quvvatlash imkonini
beradi.

Hyperledger Fabric — Hyperledger loyihalari ichida eng faoli. Platforma
atrofidagi hamjamiyat barqaror o'sib bormoqda va har bir yangi reliz bilan
taqdim etilayotgan innovatsiyalar boshqa korporativ blokcheyn platformalaridan
ancha ilgarilab ketmoqda.

## Minnatdorchilik

Yuqoridagi matn ekspertlar tomonidan taqrizdan o'tgan
["Hyperledger Fabric: A Distributed Operating System for Permissioned Blockchains"](https://dl.acm.org/doi/10.1145/3190508.3190538)
maqolasi asosida tayyorlangan. Mualliflar: Elli Androulaki, Artem
Barger, Vita Bortnikov, Christian Cachin, Konstantinos Christidis, Angelo De
Caro, David Enyeart, Christopher Ferris, Gennady Laventman, Yacov Manevich,
Srinivasan Muralidharan, Chet Murthy, Binh Nguyen, Manish Sethi, Gari Singh,
Keith Smith, Alessandro Sorniotti, Chrysoula Stathakopoulou, Marko Vukolic,
Sharon Weed Cocco, Jason Yellick
