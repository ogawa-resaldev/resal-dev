管理者権限で行えることは、基本的に内勤と変わりません。
<a href="/wiki/usage/back_office">内勤権限の説明書</a>

このページでは、管理者権限のみが行える機能を記載します。

## 見出し
- [予約](#reservation)
  - [一覧表示](#reservation-index)
- [清算](#cash-flow)
  - [一覧表示](#cash-flow-index)
  - [振込一覧](#transfer-index)
- [売上](#sale)
  - [売上一覧](#sale-index)
- [ユーザー](#user)
  - [編集](#user-edit)
- [店舗グループ](#store-group)
  - [新規作成](#store-group-new)
- [店舗](#store)
  - [新規登録](#store-new)


## <a name="reservation"></a>予約
### <a name="reservation-index"></a>一覧表示
・予約一覧画面
<img src="/images/wiki/admin/reservation/index.png" width="100%">
</img>

以下の要領で、ステータスを戻すことが可能です。
キャンセル→未確定に戻す。
遂行済み→確定(未遂行)に戻す。
戻す際、予約に紐づいた清算も削除されます。
※紐づいた清算がすでに振込に計上されている場合、エラーを出してステータスを戻すことに失敗します。


## <a name="cash-flow"></a>清算
### <a name="cash-flow-index"></a>一覧表示
全ての店舗グループの清算が表示可能。

### <a name="transfer-index"></a>振込一覧
全ての店舗グループの清算が表示可能。
振込の向き先に関わらず、振込設定及び確認が可能。


## <a name="sale"></a>売上
### <a name="sale-index"></a>売上一覧
全ての店舗グループの清算が表示可能。


## <a name="user"></a>ユーザー
### <a name="user-edit"></a>編集
内勤ユーザーの店舗グループを編集可能。


## <a name="store-group"></a>店舗グループ
### <a name="store-group-new"></a>新規作成
・店舗グループ作成画面
<img src="/images/wiki/admin/store-group/create.png" width="100%">
</img>

必要な情報を入力して、新規の店舗グループを作成します。
クレジット手数料...お客様がクレジット支払いをする際に、自動計算される手数料。
メール関連...お客様向けのメールに記載する各種パラメータ。
LINE関連...セラピスト向けのLINEを送信する公式LINEのパラメータ。


## <a name="store"></a>店舗
### <a name="store-new"></a>登録
・店舗登録画面
<img src="/images/wiki/admin/store/create.png" width="100%">
</img>
