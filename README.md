# らぁめんさぁち
　このアプリは、現在地から近いラーメン屋を探すアプリです。  
　現在地からの距離を指定すると、ヒットしたラーメン屋をキャッチコピー付きで一覧表示します。また、口コミからキーワードを抽出することも可能です。  

## デモ
![Animated GIF-downsized_large (1)](https://user-images.githubusercontent.com/21253696/128353056-9b315357-e782-49e3-ae06-183d04657a05.gif)

## goodな点
### １、UXにこだわった操作感
　このアプリでは、食事処を探す時にありがちな「いったりきたり」を極力排除して、UXの向上を目指しています。  
　たとえば、距離を指定して検索する場合、検索ボタンを押して画面遷移をしないと、全部で何件該当するのかわからない、ということがありがちです。  
　そこで、このアプリでは、先に件数を表示することで、件数が少ないからやり直そう、という「いったりきたり」を解消しています。  
　また、せっかく検索結果が出ても、そこがどういったお店かひと目でわからなければ、店舗詳細を１つ１つ見なければなりません。これは特にラーメン屋を探す時には致命的です。そのお店が昔ながらの醤油ラーメン屋か二郎系かわからないのですから！  
　そこで、キャッチコピーを同時に表示することによって、詳細を１つ１つ確認しなくても、そのお店がどういうラーメン屋さんかわかるようにしました。これによって、店舗の詳細を確認する際の「いったりきたり」を削減できました。  

### ２、AI技術を用いた口コミ解析
　Googleの自然言語解析APIと連携することで、トップ５のクチコミに含まれる単語を解析し、頻度が高いものをキーワードとして表示しています。これによって、そのお店の特徴を簡単に把握できます。  
　店舗一覧画面のキャッチコピーはお店側の視点でしたが、口コミは利用者の視点であるので、お店選びの際に総合的な判断がしやすくなります。  

## 使用している技術
### 言語
Swift  

### モデル
MVC  

### コンポーネント
UITableView, UITextField, UIPickerView, UIImageViewなど  

### 使用しているAPI
HotPepperグルメサーチAPI  
Google Places API  
Google Cloud Natural Language API  
