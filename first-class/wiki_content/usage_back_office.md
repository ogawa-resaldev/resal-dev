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
- [店舗グループ](#store-group)
  - [一覧表示](#store-group-index)
  - [編集](#store-group-edit)
- [店舗](#store)
  - [一覧表示](#store-index)
  - [編集](#store-edit)


## <a name="home"></a>HOME
### <a name="notification"></a>お知らせ
緊急度の高さによって、赤や黄色で表示します。
各項目はクリックすることで、詳細を確認可能です。

## <a name="reservation"></a>予約
### <a name="reservation-new"></a>新規作成
矢印の順番にタブを開きながら情報を入力して、「予約作成」を押下することで新規に予約を作成することができます。
また、一括適用で「予約詳細」、「予約確定連絡」を貼り付けることで基本情報やコースを一括で適用できます。

<img src="/images/wiki/back_office/reservation/create.png" width="100%">
</img>

### <a name="reservation-index"></a>一覧表示
・予約一覧画面
<img src="/images/wiki/back_office/reservation/index.png" width="100%">
</img>

「表示」を押下することで、より詳しい予約の情報を表示します。
※詳細の横の「!」は、共有事項が存在する予約の場合に表示されます。表示を押下してその内容を確認してください。
※予約自体が赤くなっているものは、ただちに解消するべき事項があるので詳細を表示して問題を確認してください。

### <a name="reservation-edit"></a>編集
編集については、新規作成と基本的に操作は変わりません。
ステータスを遷移させることが可能です。


## <a name="cash-flow"></a>清算
### <a name="cash-flow-new"></a>新規作成(雑費)
予約以外のキャスト店舗間の清算を雑費として作成できます。
※ここで設定した支払い期限を過ぎた雑費は、一覧上で赤く表示されるようになります。

<img src="/images/wiki/back_office/cash-flow/create.png" width="100%">
</img>

### <a name="cash-flow-index"></a>一覧表示
一覧から、計上したい清算を選択(複数選択可能)し、店とキャスト間の振込を作成できます。
※赤くなっている清算は、遂行されてからじばらく時間の経ってしまった予約等なので早めに計上してください。
また、キャストが行った雑費の申請もここに表示されます。
申請された雑費が正しいものであれば承認することで振込計上可能となります。
もし正しくないものであれば却下を行い、キャストに再度作成を依頼するなどして対応してください。

・一覧画面
<img src="/images/wiki/back_office/cash-flow/index.png" width="100%">
</img>

・振込の作成画面
<img src="/images/wiki/back_office/cash-flow/create-transfer.png" width="100%">
</img>
振込の合計金額と方向は、清算を自動計算して決定されます。
画像の場合だと、「キャスト→店」を順方向として
-10,000円 + 12,000円 = 2,000円
となるので、2,000円の振込が作成されることとなります。

### <a name="transfer-index"></a>振込一覧
キャストと店舗で発生した清算をまとめ、振込が行われたかどうかを管理します。
振り込む側(キャストもしくは店舗)が振込設定(振り込んだ日付と振り込んだ金額を入力)を行い、
振り込まれる側(店舗もしくはキャスト)がその振込を確認することで、振込完了とします。

・一覧画面
<img src="/images/wiki/back_office/transfer/index.png" width="100%">
</img>

詳細を押下で、振込対象の清算を一覧表示できます。
振込設定されたものについては、振込金額が清算合計金額の下に表示されるようになります。
向き先に関わらず、振込設定も確認も押下可能です。(誤操作に注意してください。)
※赤くなっている振込は振込期限を過ぎたものになるので、キャストや店舗の経理責任者に確認を行なってください。

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
必要な情報を入力して、新規キャストもしくは内勤のユーザーを登録します。
※ログインIDは原則、後から変更できないので確定したものを入力するようにしてください。

### <a name="user-index"></a>一覧表示
・ユーザー一覧画面
<img src="/images/wiki/back_office/user/index.png" width="100%">
</img>

ルーキーキャストは、葉のマークが表示されます。

### <a name="user-achievement"></a>実績
・キャスト実績画面
<img src="/images/wiki/back_office/achievement/show.png" width="100%">
</img>

キャストの実績を確認できます。

### <a name="user-edit"></a>編集
・キャスト編集画面
<img src="/images/wiki/back_office/user/edit1.png" width="100%">
</img>
<img src="/images/wiki/back_office/user/edit2.png" width="100%">
</img>

キャストの基本情報を更新できます。

「word pressキャストを追加」について
システム上に作成したキャストユーザーと、ホームページ(word press)で公開されているキャストを紐付けすることで、予約などをキャストユーザーと紐付けます。

退店したキャストは、非アクティブにするを押下することでユーザーの一覧に表示されなくなります。

また、内勤の編集に関しては、上記に操作が内包されているため省略いたします。


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
