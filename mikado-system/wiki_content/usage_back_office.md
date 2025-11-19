## 見出し
- [HOME](#home)
  - [お知らせ](#notification)
- [予約](#reservation)
  - [新規作成](#reservation-new)
  - [一覧表示](#reservation-index)
  - [編集](#reservation-edit)
- [清算](#cash-flow)
  - [新規作成(雑費)](#cash-flow-new)
  - [一覧表示](#cash-flow-index)
  - [振込一覧](#transfer-index)
- [売上](#sale)
  - [売上一覧](#sale-index)
- [ユーザー](#user)
  - [新規作成](#user-new)
  - [一覧表示](#user-index)
  - [実績](#user-achievement)
  - [編集](#user-edit)
- [未連携セラピスト一覧](#word-press-therapist)
  - [紐づける](#word-press-therapist-link)
- [ランキング](#rank)
  - [変更 (本部のみ)](#rank-edit)
- [レビュー](#review)
  - [作成](#review-new)
  - [一覧表示](#review-index)
  - [編集](#review-edit)
- [求人](#applicant)
  - [応募者登録](#applicant-new)
  - [一覧表示](#applicant-index)
  - [編集](#applicant-edit)
  - [自動通知](#applicant-auto-notification)
- [マスター](#master)
  - [通過区分](#master-pass-classification)
  - [求人メールテンプレート](#master-applicant-mail-template)
  - [求人LINEテンプレート](#master-applicant-line-template)
- [店舗グループ](#store-group)
  - [一覧表示](#store-group-index)
  - [編集](#store-group-edit)
- [店舗](#store)
  - [一覧表示](#store-index)
  - [編集](#store-edit)
- [ポイント](#point)
  - [ボーナスポイント発行](#point-new)
  - [一覧表示](#point-index)
- [帝コイン (本部のみ)](#mikado-coin)
  - [入出庫作成](#mikado-coin-flow-new)
  - [入出庫一覧](#mikado-coin-flow-index)


## <a name="home"></a>HOME
### <a name="notification"></a>お知らせ
<img src="/images/wiki/back_office/home/notification.png" width="100%">
</img>

緊急度の高さによって、赤や黄色で表示します。
各項目はクリックすることで、詳細を確認可能です。

## <a name="reservation"></a>予約
### <a name="reservation-new"></a>新規作成
矢印の順番にタブを開きながら情報を入力して、「予約作成」を押下することで新規に予約を作成することができます。

<img src="/images/wiki/back_office/reservation/create.png" width="100%">
</img>

### <a name="reservation-index"></a>一覧表示
・予約一覧画面
<img src="/images/wiki/back_office/reservation/index.png" width="100%">
</img>

<span style="color: red; ">①</span>は詳細の表示ボタンです。これを押下することで、より詳しい予約の情報を表示します。
<span style="color: red; ">②</span>はそれぞれの予約のステータス(状態)と状態を移行させるボタンです。ボタンを押下することで、ステータスの移行確認画面が表示されます。
※詳細の横の「!」は、共有事項が存在する予約の場合に表示されます。表示を押下してその内容を確認してください。
※予約自体が赤くなっているものは、ただちに解消するべき事項があるので詳細を表示して問題を確認してください。

・ステータスの移行確認画面
<img src="/images/wiki/back_office/reservation/status_change.png" width="100%">
</img>

<span style="color: red; ">①</span>で、メール(お客様に送信)とLINE(セラピストに送信)のどちらの内容を表示するかを切り替えます。
<span style="color: red; ">②</span>のチェックを外すことで、お客様及びセラピストにメッセージを送信しないことも可能です。
<span style="color: red; ">③</span>で、送信内容を修正可能です。(修正されるのは、一時的。)
<span style="color: red; ">④</span>を押下することでメッセージを送信しつつ、予約のステータスを変更します。

・詳細画面
<img src="/images/wiki/back_office/reservation/details.png" width="100%">
</img>

### <a name="reservation-edit"></a>編集
編集については、新規作成と基本的に操作は変わりません。
ステータスについては、下に記載した画像に注意事項を載せています。
・編集画面
<img src="/images/wiki/back_office/reservation/edit.png" width="100%">
</img>


## <a name="cash-flow"></a>清算
### <a name="cash-flow-new"></a>新規作成(雑費)
セラピストが作成したバーでの売上など、予約以外で発生した清算を雑費として作成します。
※ここで設定した支払い期限を過ぎた雑費は、一覧上で赤く表示されるようになります。

<img src="/images/wiki/back_office/cash-flow/create.png" width="100%">
</img>

### <a name="cash-flow-index"></a>一覧表示
一覧から、計上したい清算を選択(複数選択可能)し、店とセラピスト間の振込を作成できます。
※赤くなっている清算は、遂行されてからじばらく時間の経ってしまった予約等なので早めに計上してください。
また、セラピストが行った雑費の申請もここに表示されます。
申請された雑費が正しいものであれば承認することで振込計上可能となります。
もし正しくないものであれば却下を行い、セラピストに再度作成を依頼するなどして対応してください。

・一覧画面
<img src="/images/wiki/back_office/cash-flow/index.png" width="100%">
</img>

・振込の作成画面
<img src="/images/wiki/back_office/cash-flow/create-transfer.png" width="100%">
</img>
振込の合計金額と方向は、清算を自動計算して決定されます。
画像の場合だと、「セラピスト→店」を順方向として
-8,000円 + 3,000円 = -5,000円
となるので、方向を逆(店→セラピスト)にした5,000円の振込が作成されることとなります。

### <a name="transfer-index"></a>振込一覧
予約やバーの売上など、セラピストと店舗で発生した清算をまとめ、振込が行われたかどうかを管理します。
振り込む側(セラピストもしくは店舗)が振込設定(振り込んだ日付と振り込んだ金額を入力)を行い、
振り込まれる側(店舗もしくはセラピスト)がその振込を確認することで、振込完了とします。

・一覧画面
<img src="/images/wiki/back_office/transfer/index.png" width="100%">
</img>

詳細を押下で、振込対象の清算を一覧表示できます。
振込設定されたものについては、振込金額が清算合計金額の下に表示されるようになります。
向き先に関わらず、振込設定も確認も押下可能です。(誤操作に注意してください。)
※赤くなっている振込は振込期限を過ぎたものになるので、セラピストや店舗の経理責任者に確認を行なってください。

・清算編集画面
<img src="/images/wiki/back_office/transfer/update-cash-flow.png" width="100%">
</img>

振込設定が行われていないものに関しては、
詳細→清算を編集
と進むことで清算編集画面を開き、清算を解除すること及び追加することが可能です。


## <a name="sale"></a>売上
### <a name="sale-index"></a>売上一覧
売上の一覧を確認できます。
期間や束ね方で表の出力を変更できます。


## <a name="user"></a>ユーザー
### <a name="user-new"></a>新規作成
必要な情報を入力して、新規セラピストもしくは内勤のユーザーを登録します。
※ログインIDは原則、後から変更できないので確定したものを入力するようにしてください。

### <a name="user-index"></a>一覧表示
・ユーザー一覧画面
<img src="/images/wiki/back_office/user/index.png" width="100%">
</img>

ランカーの場合は、この画面でランクが確認可能です。
新人のセラピストは、葉のマークが表示されます。
修正を押下することで、セラピストの情報を修正できます。

### <a name="user-achievement"></a>実績
・セラピスト実績画面
<img src="/images/wiki/back_office/achievement/show.png" width="100%">
</img>

セラピストの実績を確認できます。

期間のデフォルトを先月の26日から今月25日としています。

### <a name="user-edit"></a>編集
・セラピスト編集画面
<img src="/images/wiki/back_office/user/edit1.png" width="100%">
</img>
<img src="/images/wiki/back_office/user/edit2.png" width="100%">
</img>

セラピストの基本情報を更新できます。(帝コインは入出庫で増減させるため、ここでは編集不可能としています。)

「ログイン案内」について

システム上に作成したセラピストユーザーと、ホームページ(word press)で公開されているセラピストを紐付けすることで、予約フォームからの予約などをセラピストユーザーと紐付けます。
店舗とセラピストを選択した後、セラピストとやりとりを行うLINEのIDを取得して通知グループIDとして入力し、word pressセラピストを追加を押下することで追加されます。

「word pressセラピストの紐付け」について
システム上に作成したセラピストユーザーと、ホームページ(word press)で公開されているセラピストを紐付けすることで、予約フォームからの予約などをセラピストユーザーと紐付けます。
店舗とセラピストを選択した後、セラピストとやりとりを行うLINEのIDを取得して通知グループIDとして入力し、word pressセラピストを追加を押下することで追加されます。

退店したセラピストは、非アクティブにするを押下することでユーザーの一覧に表示されなくなります。

また、内勤の編集に関しては、上記に操作が内包されているため省略いたします。


## <a name="word-press-therapist"></a>未連携セラピスト一覧
### <a name="word-press-therapist-link"></a>紐づける
<img src="/images/wiki/back_office/word-press-therapist/link.png" width="100%">
</img>
一覧には、word pressで公開されているもののリザルのセラピストに紐づけられていないセラピストが表示されます。
紐づけたいセラピストがいたら、このページから紐づけることも可能です。


## <a name="rank"></a>ランキング
### <a name="rank-edit"></a>変更 (本部のみ)
<img src="/images/wiki/back_office/rank/edit.png" width="100%">
</img>

反映日と変更後のランキングを登録しておくことで、反映日にランキングが一括で変更されます。
(反映日設定をせず、即時反映させることも可能です。)
現在のランキングを反映予定のランキングで置き換えるので、ランキングに変更のないセラピストも、
再度反映予定のランキングとして設定してください。
また、ランカーの画像を差し替えた際には、「ランカー画像情報更新」を押下して枠を自動付与する画像の情報を最新のものにしてください。


## <a name="point"></a>ポイント
### <a name="point-new"></a>ボーナスポイント発行
<img src="/images/wiki/back_office/point/create.png" width="100%">
</img>

予約以外で発生した、バー売上や応援シャンパン、特別賞などのボーナスポイントを発行します。
一度に最大で10件まで作成可能です。(削除を行うと、ページ更新を行うまで最大作成数が減ります。)
ボーナスは特別賞など決まったものを選択できる他、直接説明を入力することも可能です。
作成後は、ボーナスポイントの一覧画面に飛びます。

### <a name="point-index"></a>一覧表示
<img src="/images/wiki/back_office/point/index.png" width="100%">
</img>

各セラピストの、指定期間内のポイントを表示します。
(デフォルトは、ランキングポイントの集計用に先月26日〜今月25日まで)
また、括弧内に通常ポイント(ランキング入りした際のキャッシュバック対象のポイント)も表示しています。
確認ボタンを押下することで、ポイント対象の予約の一覧やボーナスポイントの一覧を表示するようになっています。


## <a name="review"></a>レビュー
### <a name="review-new"></a>新規作成
必要な情報を入力して、レビューを新規登録します。

<img src="/images/wiki/back_office/review/create.png" width="100%">
</img>

### <a name="review-index"></a>一覧表示
セラピスト、期間による絞り込みや、ニックネームおよび内容による検索が可能です。
非表示に設定されているレビューについては、「非表示」と赤く表示されます。

<img src="/images/wiki/back_office/review/index.png" width="100%">
</img>

### <a name="review-edit"></a>編集
編集については、新規作成と違って表示/非表示の切り替えができます。

<img src="/images/wiki/back_office/review/edit.png" width="100%">
</img>


## <a name="applicant"></a>求人
### <a name="applicant-new"></a>応募者登録
必要な情報を入力して、応募者を登録します。
写真は、一度登録した後に編集から追加できます。

<img src="/images/wiki/back_office/applicant/create.png" width="100%">
</img>

### <a name="applicant-index"></a>一覧表示
ステータスによる検索が可能です。
「進行中」は、選考中～デビュー待ちまでを表しています。

<img src="/images/wiki/back_office/applicant/index.png" width="100%">
</img>

### <a name="applicant-edit"></a>編集
「ステータス/選考情報」から求人の進行状況に応じてステータスを更新してください。
※あらかじめ、「通過区分」を登録しておいてください。
また、更新の際に「メール/LINE送信」から応募者にメールやLINEを送信できます。
この際、あらかじめ「求人メールテンプレート」「求人LINEテンプレート」を作成しておくことでテンプレートを使用できます。

<img src="/images/wiki/back_office/applicant/edit.png" width="100%">
</img>

### <a name="applicant-auto-notification"></a>自動通知
あらかじめ作成した「求人メールテンプレート」「求人LINEテンプレート」を対象にして、面接日/研修日の前日/当日/翌日に時間指定してテンプレートメッセージを応募者に送信できます。

<img src="/images/wiki/back_office/applicant/auto_notification.png" width="100%">
</img>


## <a name="master"></a>マスター
### <a name="master-pass-classification"></a>通過区分
求人で選考を進める際に、応募者を振り分ける通過区分を設定します。
また、デビューに必要な費用、通過時のメールテンプレートを設定できます。
メールテンプレートの中で「{{applicant_name}}」などの変数を挿入することで、その部分が該当のものに自動変換されます。(メールプレビューで確認可能)

<img src="/images/wiki/back_office/master/pass_classification.png" width="100%">
</img>

### <a name="master-applicant-mail-template"></a>求人メールテンプレート
求人で選考を進めている最中や、面接日や研修日付近での応募者への自動通知に使用できるメールのテンプレートを登録/編集できます。

<img src="/images/wiki/back_office/master/applicant_mail_template.png" width="100%">
</img>

### <a name="master-applicant-line-template"></a>求人LINEテンプレート
求人で選考を進めている最中や、面接日や研修日付近での応募者への自動通知に使用できるLINEのテンプレートを登録/編集できます。

<img src="/images/wiki/back_office/master/applicant_line_template.png" width="100%">
</img>


## <a name="store-group"></a>店舗グループ
### <a name="store-group-index"></a>一覧表示
・店舗グループ一覧画面
<img src="/images/wiki/back_office/store-group/index.png" width="100%">
</img>

### <a name="store-group-edit"></a>編集
・店舗グループ編集画面
<img src="/images/wiki/back_office/store-group/edit.png" width="100%">
</img>


## <a name="store"></a>店舗
### <a name="store-index"></a>一覧表示
・店舗一覧画面
<img src="/images/wiki/back_office/store/index.png" width="100%">
</img>

### <a name="store-edit"></a>編集
・店舗編集画面
<img src="/images/wiki/back_office/store/edit.png" width="100%">
</img>


## <a name="mikado-coin"></a>帝コイン (本部のみ)
残高はセラピストページに表示される。
以下記載するのは、入出庫の管理による残高操作の方法。

### <a name="mikado-coin-flow-new"></a>入出庫作成
<img src="/images/wiki/back_office/mikado-coin/create-flow.png" width="100%">
</img>

ランキングボーナスによる帝コインの入庫や帝コインによる商品の購入時に発生する出庫を、
入出庫の増減コイン数を入力することで作成します。
※作成しただけでは反映されず、一覧画面にて計上する必要があります。

### <a name="mikado-coin-flow-index"></a>入出庫一覧
<img src="/images/wiki/back_office/mikado-coin/index-flow.png" width="100%">
</img>

作成されている帝コインの入出庫を一覧表示します。
計上して残高に反映させること、入出庫自体を削除することが可能です。
また、セラピストが行った帝コイン入出庫の申請もここに表示されます。
申請された帝コインの入出庫が正しいものであれば承認することで残高に反映されます。
もし正しくないものであれば却下を行い、セラピストに再度作成を依頼するなどして対応してください。
