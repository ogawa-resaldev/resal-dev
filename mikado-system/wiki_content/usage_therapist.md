## 見出し
- [予約](#reservation)
  - [一覧表示](#reservation-index)
- [申請](#request)
  - [雑費申請](#miscellaneous-expenses-request)
  - [帝コイン入出庫申請](#mikado-coin-flow-request)
- [清算](#cash-flow)
  - [一覧表示](#cash-flow-index)
  - [振込一覧](#transfer-index)
- [ユーザー](#user)
  - [プロフィール](#user-edit)
  - [実績](#user-achievement)
- [HOME](#home)
  - [お知らせ](#notification)


## <a name="reservation"></a>予約
### <a name="reservation-index"></a>一覧表示
・予約一覧画面
<img src="/images/wiki/therapist/reservation/index.png" width="100%">
</img>

検索条件によって、予約の絞り込みが可能です。
詳細を押下することで、より詳しい予約の情報を表示します。
※予約自体が赤くなっているものは、予約日を過ぎたのに遂行済となっていないものなので、緊急対応必要であれば連絡用グループで確認してください。

・詳細画面
<img src="/images/wiki/therapist/reservation/details.png" width="100%">
</img>


## <a name="request"></a>申請
### <a name="miscellaneous-expenses-request"></a>雑費申請
・雑費申請画面
<img src="/images/wiki/therapist/miscellaneous-expenses-request/request.png" width="100%">
</img>

清算一覧に載っていない雑費(バー出勤時の料金等)があれば、こちらの画面から申請が可能です。
申請された雑費は清算一覧に掲載されますが、承認されるまでは計上及び振込作成はできません。
事務局にて承認されるのをお待ちください。

### <a name="mikado-coin-flow-request"></a>帝コイン入出庫申請
・帝コイン入出庫申請画面
<img src="/images/wiki/therapist/mikado-coin-flow-request/request.png" width="100%">
</img>

帝コインを使用して特典を受け取りたい場合や、入庫されるはずのコインが残高に計上されていない場合、こちらの画面から申請が可能です。
申請された帝コイン入出庫はユーザー編集画面に掲載されますが、承認されるまでは残高には反映されません。
事務局にて承認されるのをお待ちください。


## <a name="cash-flow"></a>清算
### <a name="cash-flow-index"></a>一覧表示
・一覧画面
<img src="/images/wiki/therapist/cash-flow/index.png" width="100%">
</img>

一覧から、計上したい清算を選択(複数選択可能)し、店とセラピスト間の振込を作成できます。
清算は、店舗グループごとに行なってください。
※赤くなっている清算は、遂行されてからじばらく時間の経ってしまった予約等です。早めの計上にご協力ください。

・振込の作成画面
<img src="/images/wiki/therapist/cash-flow/create-transfer.png" width="100%">
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
<img src="/images/wiki/therapist/transfer/index.png" width="100%">
</img>

詳細を押下で、振込対象の清算を一覧表示できます。
振込設定されたものについては、振込金額が清算合計金額の下に表示されるようになります。
向き先がセラピスト→店の場合、この画面で振込設定が可能です。
向き先が店→セラピストの場合、確認を押下可能です。
※赤くなっている振込は振込期限を過ぎたものになります。

・清算編集画面
<img src="/images/wiki/therapist/transfer/update-cash-flow.png" width="100%">
</img>

振込設定が行われていないものに関しては、
詳細→清算を編集
と進むことで清算編集画面を開き、清算を解除すること及び追加することが可能です。


## <a name="user"></a>ユーザー
### <a name="user-edit"></a>プロフィール
情報を更新できます。
メールアドレスと口座情報は、振込設定及び振込確認時に使用するので変更があった場合は随時更新するようにしてください。

### <a name="user-achievement"></a>実績
・セラピスト実績画面
<img src="/images/wiki/therapist/achievement/show.png" width="100%">
</img>

セラピストの実績を確認できます。

期間のデフォルトを先月の26日から今月25日としています。
(ランキング入りまで何ptなのか、確認しやすくしています。)


## <a name="home"></a>HOME
### <a name="notification"></a>お知らせ
<img src="/images/wiki/therapist/home/notification.png" width="100%">
</img>

緊急度の高さによって、赤や黄色で表示します。
各項目はクリックすることで、詳細を確認可能です。
