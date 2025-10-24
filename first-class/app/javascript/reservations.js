{
  // 予約の情報を元に追加する必要のあるポイントのリストを計算して返却する。
  function calcPoints(reservationCourses, reservationFees, reservationTel, reservationMailAddress, reservationStoreId, reservationTherapistId) {
    // 予約パラメータを元に予約ポイントを追加。
    return new Promise((resolve, reject) => {
      axios
      .post('/api/v1/reservations/calc_points', {
        reservationCourses:reservationCourses,
        reservationFees:reservationFees,
        reservationTel:reservationTel,
        reservationMailAddress:reservationMailAddress,
        reservationStoreId:reservationStoreId,
        reservationTherapistId:reservationTherapistId
      })
      .then((res) => {
        resolve(res.data);
      })
      .catch((e) => {
        reject(e)
      })
    });
  }

  // 予約の情報を元に追加する必要のある費用のリストを計算して返却する。
  function calcFees(reservationDateYear, reservationDateMonth, reservationDateDay, reservationTimeHour, reservationTimeMinute, reservationCourses, reservationTypeId, reservationStoreId, reservationTherapistId) {
    // 予約パラメータを元に予約費用を追加。
    return new Promise((resolve, reject) => {
      axios
      .post('/api/v1/reservations/calc_fees', {
        reservationDateYear:reservationDateYear,
        reservationDateMonth:reservationDateMonth,
        reservationDateDay:reservationDateDay,
        reservationTimeHour:reservationTimeHour,
        reservationTimeMinute:reservationTimeMinute,
        reservationCourses: reservationCourses,
        reservationTypeId: reservationTypeId,
        reservationStoreId: reservationStoreId,
        reservationTherapistId: reservationTherapistId
      })
      .then((res) => {
        resolve(res.data);
      })
      .catch((e) => {
        reject(e)
      })
    });
  }

  // 料金合計、店舗IDを元にクレジット手数料を計算して返却する。
  function calcCreditFee(sumAmount, reservationStoreId) {
    // 予約パラメータを元にクレジット手数料を出力。
    return new Promise((resolve, reject) => {
      axios
      .post('/api/v1/reservations/calc_credit_fee', {
        sumAmount:sumAmount,
        reservationStoreId: reservationStoreId
      })
      .then((res) => {
        resolve(res.data);
      })
      .catch((e) => {
        reject(e)
      })
    });
  }

  // 店舗ID、セラピストIDを元にセラピストバック率を返却する。
  function getTherapistBackRatio(reservationStoreId, reservationTherapistId) {
    // 予約パラメータを元にバック率を出力。
    return new Promise((resolve, reject) => {
      axios
      .post('/api/v1/reservations/get_therapist_back_ratio', {
        reservationStoreId: reservationStoreId,
        reservationTherapistId: reservationTherapistId
      })
      .then((res) => {
        resolve(res.data);
      })
      .catch((e) => {
        reject(e)
      })
    });
  }

  // 予約の情報を元にメールの件名を返却する。
  function updateEmailSubject(reservationStatusId, reservationCancelReason) {
    let emailSubject = ""
    switch (reservationStatusId) {
      case "2":
        // 確定となるケース。確定の連絡をする。
        emailSubject = "予約確定のお知らせ"
        break
      case "3":
        // キャンセルとなるケース。キャンセルの連絡をする。(予約間違い・変更の場合は何もしない)
        if (reservationCancelReason != "予約間違い・変更") {
          emailSubject = "キャンセル受付のご連絡"
        }
        break
      case "4":
        // 遂行済みとなるケース。口コミの投稿をお願いする。
        emailSubject = "口コミ投稿ご協力のお願い"
        break
    }
    return emailSubject
  }

  // 店舗IDを元に店舗グループごとのメールパラメータを取得。
  function getMailParams(reservationStoreId){
    return new Promise((resolve, reject) => {
      axios
      .post('/api/v1/reservations/get_mail_params', {
        reservationStoreId: reservationStoreId
      })
      .then((res) => {
        resolve(res.data);
      })
      .catch((e) => {
        reject(e)
      })
    })
  }

  // 予約の情報を元にメールの本文を返却する。
  function updateEmailBody(
    reservationStatusId,
    reservationName,
    reservationDatetime,
    reservationMailAddress,
    reservationPlace,
    reservationAddress,
    reservationTypeId,
    reservationCourses,
    reservationFees,
    reservationPaymentMethod,
    reservationCancelReason,
    therapistId,
    therapistName,
    userRoleId,
    userName,
    mailParams
  ) {
    let emailBody = ""

    switch (reservationStatusId) {
      case "2":
        // 確定となるケース。確定の連絡をする。
        emailBody += reservationName + "様\n\n"
        emailBody += "お世話になっております。\n"
        if (userRoleId != 1) {
          emailBody += mailParams.name + "の" + userName + "です。\n"
        } else {
          emailBody += mailParams.name + "です。\n"
        }
        emailBody += "ご予約誠にありがとうございます。\n"
        emailBody += "下記内容にて確定させていただきました。\n"
        emailBody += "お手数ですがご確認の上空メールでも大丈夫ですので返信をよろしくお願いします。\n\n"
        emailBody += "ご利用日時: " + reservationDatetime + "\n"
        emailBody += "ご指名: " + (reservationTypeId == 3 ? "フリー → " : "") + therapistName + "\n"
        emailBody += "待ち合わせ場所: " + reservationPlace + "\n"
        if (reservationAddress != "") {
          emailBody += "利用場所: " + reservationAddress + "\n"
        }

        let total = 0
        let courseDetail = ""
        reservationCourses.forEach((reservationCourse) => {
          if (courseDetail != "") {
            courseDetail += "、"
          }
          courseDetail += reservationCourse.course_detail
          total += Number(reservationCourse.amount)
        })
        emailBody += "コース料金: " + total.toLocaleString() + "円（" + courseDetail + "）\n"

        reservationFees.forEach((reservationFee) => {
          emailBody += reservationFee.fee_type
          if (reservationFee.fee_detail != "") {
          emailBody += "（" + reservationFee.fee_detail+ "）"
          }
          emailBody += ": " + Number(reservationFee.amount).toLocaleString() + "円\n"
          total += Number(reservationFee.amount)
        })
        emailBody += "合計: " + total.toLocaleString() + "円（" + reservationPaymentMethod + "）\n"
        switch (reservationPaymentMethod) {
          case "クレジット(事前決済)":
            emailBody += "\n"
            emailBody += mailParams.credit1
            emailBody += total.toLocaleString()
            emailBody += mailParams.credit2
            emailBody += "\n\n\n"
            break
          case "事前振り込み":
            emailBody += "※振込については、お手数ですが下記の振り込み先までお振込みいただくようお願いします。\n\n"
            emailBody += "=======================\n"
            emailBody += mailParams.transferBank
            emailBody += "\n=======================\n\n\n"
            break
        }
        dayDiff = (new Date(new Date(reservationDatetime.replace("時",":").replace("分","")).toDateString()) - new Date((new Date()).toDateString())) / (1000 * 60 * 60 * 24)
        if (2 <= dayDiff) {
          emailBody += "当日"
        } else if (1 <= dayDiff) {
          emailBody += "明日"
        } else if (0 <= dayDiff) {
          emailBody += "本日"
        } else {
          emailBody += "当日"
        }
        emailBody += "はよろしくお願いします。\n\n"
        if (userRoleId != 1) {
          emailBody += mailParams.name + " " + userName
        } else {
          emailBody += mailParams.name
        }
        emailBody += "\n\n"
        emailBody += mailParams.signature
        break
      case "3":
        // キャンセルとなるケース。キャンセルを受け付けた連絡をする。(予約間違い・変更の場合は何もしない)
        if (reservationCancelReason != "予約間違い・変更") {
          emailBody += reservationName + "様\n\n"
          emailBody += "お世話になっております。\n\n"
          if (userRoleId != 1) {
            emailBody += mailParams.name + "の" + userName + "です。\n\n"
          } else {
            emailBody += mailParams.name + "です。\n\n"
          }
          if (reservationCancelReason == "お客様都合") {
            emailBody += "下記のご予約につきましてキャンセルを承らせていただきました。\n\n"
          } else {
            // セラピスト都合もしくは無断キャンセルの場合、キャンセルにした。という言い方にする。
            emailBody += "下記のご予約につきましてキャンセルいたしました。\n\n"
          }
          emailBody += "キャンセル理由 :" + reservationCancelReason + "\n\n"
          emailBody += "【 予約日時 】" + reservationDatetime + "\n"
          let totalAmount = 0
          // 事前予約だった場合、キャンセル料を請求するようにする。
          let isAdvancedReservation = false
          let cancelFeeForAdvancedReservation = 5000
          reservationCourses.forEach((reservationCourse, index) => {
            if (index == 0) {
              emailBody += "【 コース 】" + reservationCourse.course + "（" + reservationCourse.course_detail + "）\n"
            } else {
              emailBody += "【 コース " + String(index + 1) + "】" + reservationCourse.course + "（" + reservationCourse.course_detail + "）\n"
            }
            totalAmount += Number(reservationCourse.amount)
          })
          reservationFees.forEach((reservationFee) => {
            if (reservationFee.fee_type == "事前指名料金") {
              isAdvancedReservation = true
            }
            totalAmount += Number(reservationFee.amount)
          })
          emailBody += "【 指名 】" + therapistName + "\n"
          emailBody += "【 ご利用場所 】" + reservationPlace + "\n\n"

          if (reservationCancelReason != "セラピスト都合") {
            // セラピスト都合ではない場合は、キャンセル料の計算を行う。
            if ((new Date(reservationDatetime.replace("時",":").replace("分",""))) - new Date() < 1000 * 60 * 60 * 24) {
              let cancelFee = "0"
              let cancelFeeExplanation = ""
              if (reservationCancelReason == "無断キャンセル") {
                // 無断キャンセルの場合、全額負担
                cancelFee = totalAmount.toLocaleString()
                cancelFeeExplanation = "料金全額の"
              } else if (reservationCancelReason == "お客様都合") {
                // お客様都合の場合、半額負担
                cancelFee = (totalAmount / 2).toLocaleString()
                cancelFeeExplanation = "料金全額の半額"
              }
              // 24時間以内のキャンセルなら、キャンセル料を要求する。
              switch (reservationPaymentMethod) {
                case "現金手渡し":
                  emailBody += "また、予約日時の24時間前よりも後のキャンセルのため、キャンセル料として" + cancelFeeExplanation + cancelFee + "円を３日以内にクレジット払い、もしくは銀行振込にてお支払いいただくようお願いします。\n\n"
                  emailBody += mailParams.credit1
                  emailBody += cancelFee
                  emailBody += mailParams.credit2
                  emailBody += "\n\n振込についてはお手数ですが下記の振り込み先までお振込みいただくようお願いします。\n\n"
                  emailBody += mailParams.transferBank
                  emailBody += "\n\n"
                  emailBody += "ただ、予約時刻の2時間前までの予約変更であればキャンセル料はいただきません。その場合支払い方法はクレジットカード払い、もしくは銀行振込に変更となりますので必ず予約時刻までに事前決済をお済ませください。\n"
                  break
                case "クレジット(事前決済)":
                  emailBody += "また、予約日時の24時間前よりも後のキャンセルのため、キャンセル料として" + cancelFeeExplanation + cancelFee + "円をお支払いいただくようお願いします。\n\n"
                  emailBody += mailParams.credit1
                  emailBody += cancelFee
                  emailBody += mailParams.credit2
                  emailBody += "\n\n振込についてはお手数ですが下記の振り込み先までお振込みいただくようお願いします。\n\n"
                  emailBody += mailParams.transferBank
                  emailBody += "\n\n"
                  emailBody += "ただ、予約時刻の2時間前までの予約変更であればキャンセル料はいただきません。その場合支払い方法はクレジットカード払い、もしくは銀行振込に変更となりますので必ず予約時刻までに事前決済をお済ませください。\n\n"
                  emailBody += "※既にクレジットカード料金を支払いいただいている場合はこちらのキャンセル料金" + cancelFee + "円の決済が確認出来次第クレジット会社を通して決済キャンセルもしくは料金組み戻しの手続きをさせて頂きますのでその旨をご連絡お願いします。\n"
                  break
                case "事前振り込み":
                  emailBody += "また、予約日時の24時間前よりも後のキャンセルのため、キャンセル料として" + cancelFeeExplanation + cancelFee + "円を３日以内にクレジット払い、もしくは銀行振込にてお支払いいただくようお願いします。\n\n"
                  emailBody += mailParams.credit1
                  emailBody += cancelFee
                  emailBody += mailParams.credit2
                  emailBody += "\n\n振込についてはお手数ですが下記の振り込み先までお振込みいただくようお願いします。\n\n"
                  emailBody += mailParams.transferBank
                  emailBody += "\n\n"
                  emailBody += "ただ、予約時刻の2時間前までの予約変更であればキャンセル料はいただきません。その場合支払い方法はクレジットカード払い、もしくは銀行振込に変更となりますので必ず予約時刻までに事前決済をお済ませください。\n\n"
                  emailBody += "※既にサービス料金を銀行振込みにてお支払いいただいている場合はその金額からこちらのキャンセル料金" + cancelFee + "円を差し引いた金額をお振込みさせていただきますので振込み先口座をご記載の上その旨をご連絡いただければと思います。\n"
                  break
              }
            } else if (isAdvancedReservation) {
              // 事前予約したものなら、キャンセル料を要求する。
              emailBody += "また、事前指名での予約のキャンセルのため、キャンセル料として" + cancelFeeForAdvancedReservation.toLocaleString() + "円を３日以内にクレジット払い、もしくは銀行振込にてお支払いいただくようお願いします。\n\n"
              emailBody += mailParams.credit1
              emailBody += cancelFeeForAdvancedReservation.toLocaleString()
              emailBody += mailParams.credit2
              emailBody += "\n\n振込についてはお手数ですが下記の振り込み先までお振込みいただくようお願いします。\n\n"
              emailBody += mailParams.transferBank
              emailBody += "\n\n"
              emailBody += "ただ、予約時刻の2時間前までの予約変更であればキャンセル料はいただきません。その場合支払い方法はクレジットカード払い、もしくは銀行振込に変更となりますので必ず予約時刻までに事前決済をお済ませください。\n"
            } else {
              // クレジット決済の場合、キャンセル手数料を要求する。
              if (reservationPaymentMethod == "クレジット(事前決済)") {
                // クレジットのキャンセル手数料
                let creditCancelFee = 2000
                emailBody += "※クレジット払いにてサービス料金を決済完了していただいてるご予約に関してはキャンセル手数料" + creditCancelFee.toLocaleString() + "円をいただいた後にキャンセルが可能となっております。\n"
                emailBody += "予約日時の変更でしたら手数料無しで変更も可能ですので併せてご検討頂けますと幸いです。\n"
                emailBody += "\n"
                emailBody += "https://pay2.star-pay.jp/site/pc/shop.php?payc=A70054\n"
                emailBody += "キャンセル手数料の支払いについては上記のURLよりクレジット決済ページへお進み頂き、ご料金をご確認いただきお申込金額の欄に" + creditCancelFee.toLocaleString() + "円と入力して決済をお願い致します。\n"
                emailBody += "決済が確認出来次第クレジット会社を通して決済キャンセルもしくは料金組み戻しの手続きをさせて頂きます。\n"
              } else {
                emailBody += "またのご利用をお待ちしております。\n"
              }
            }
          } else {
            // セラピスト都合の場合、キャンセル料を要求しない。
            emailBody += "せっかくご予約いただいたのにも関わらず、キャンセルとなり大変申し訳ありません。\n"
            emailBody += "またのご利用をお待ちしております。\n"
          }
          emailBody += "\n\n"
          if (userRoleId != 1) {
            emailBody += mailParams.name + " " + userName
          } else {
            emailBody += mailParams.name
          }
          emailBody += "\n\n"
          emailBody += mailParams.signature
        }
        break
      case "4":
        // 遂行済みとなるケース。口コミの投稿をお願いする。
        emailBody += reservationName + "様\n\n"
        emailBody += "お世話になっております。\n"
        if (userRoleId != 1) {
          emailBody += mailParams.name + "の" + userName + "です。\n"
        } else {
          emailBody += mailParams.name + "です。\n"
        }
        emailBody += "当店をご利用いただき誠にありがとうございました。\n"
        emailBody += "ご満足いただけたようでしたら幸いです。\n\n"
        emailBody += "入れ違いの連絡であれば申し訳ありません。\n"
        emailBody += "当店は少しでも多くの女性にサービスをイメージしていただけるように口コミを募集しております。\n"
        emailBody += "もしよろしければ、" + reservationName + "様より以下の口コミ投稿フォームより口コミ投稿をいただけますとセラピストの励みにもなりますのでお願いできないかと思います。\n\n"
        emailBody += mailParams.reviewUrl + "?reservation_name=" + reservationName + "&therapist_id=" + therapistId + "&reservation_mail_address=" + reservationMailAddress + "\n\n"
        emailBody += "また、口コミを投稿していただけますと次回ご利用時に-1,000円の口コミ割も適用可能です。\n"
        emailBody += "お手数ですがどうぞよろしくお願いいたします。\n\n"
        if (userRoleId != 1) {
          emailBody += mailParams.name + " " + userName
        } else {
          emailBody += mailParams.name
        }
        emailBody += "\n\n"
        emailBody += mailParams.signature
        break
    }

    return emailBody
  }

  function updateLine(
    reservationStatusId,
    reservationName,
    reservationTel,
    reservationSms,
    reservationDatetime,
    reservationPlace,
    reservationAddress,
    reservationCourses,
    reservationFees,
    reservationPaymentMethod,
    reservationCancelReason,
    userRoleId,
    userName
  ) {
    let line = ""

    switch (reservationStatusId) {
      case "2":
        // 確定となるケース。確定の連絡をする。
        line += reservationName + "様\n\n"
        line += "電話番号: " + reservationTel + "\n\n"
        line += "sms: " + reservationSms + "\n\n"
        line += "ご利用日時: " + reservationDatetime.replace(/-/g,"/") + "\n\n"
        line += "待ち合わせ場所: " + reservationPlace + "\n\n"
        if (reservationAddress != "") {
          line += "利用場所: " + reservationAddress + "\n\n"
        }
        var sumAmount = 0
        var sumBackTherapistAmount = 0
        line += "コース料金: "
        var courses = ""
        reservationCourses.forEach((reservationCourse) => {
          if (courses != "") {
            courses += "+"
          }
          courses += Number(reservationCourse.amount).toLocaleString() + "円（" + reservationCourse.course_detail + "）"
          sumAmount += Number(reservationCourse.amount)
          sumBackTherapistAmount += Number(reservationCourse.back_therapist_amount)
        })
        line += courses + "\n\n"

        reservationFees.forEach((reservationFee) => {
          line += reservationFee.fee_type
          if (reservationFee.fee_detail != "") {
            line += "（" + reservationFee.fee_detail + "）"
          }
          line += ": " + Number(reservationFee.amount).toLocaleString() + "円\n\n"
          sumAmount += Number(reservationFee.amount)
          sumBackTherapistAmount += Number(reservationFee.back_therapist_amount)
        })

        if (reservationPaymentMethod != "現金手渡し") {
          line += "受け取り: 事前決済のため当日の受け取りはありません。\n"
          line += "セラピスト報酬: " + sumBackTherapistAmount.toLocaleString() + "円\n"
          line += "店舗分: " + (sumAmount - sumBackTherapistAmount).toLocaleString() + "円\n\n"
          line += "セラピスト報酬" + sumBackTherapistAmount.toLocaleString() + "円につきましては、リザルにて他の報酬分から相殺した上で清算一覧にて振込作成をお願いいたします。\n"
          line += "また、仕事日から10日～14日以内で相殺できない場合は事務局から振り込みますので振込依頼の作成をお願いいたします。\n\n"
        } else {
          line += "受け取り: " + sumAmount.toLocaleString() + "円\n"
          line += "セラピスト報酬: " + sumBackTherapistAmount.toLocaleString() + "円\n"
          line += "店舗振込: " + (sumAmount - sumBackTherapistAmount).toLocaleString() + "円\n\n"
        }

        line += "上記のご予約を確定しました！\n"
        line += "よろしくお願いいたします。\n\n"

        if (reservationPaymentMethod != "現金手渡し") {
          line += "リザルの利用方法↓\n"
          line += "https://docs.google.com/document/d/1yNPcc1MqD9X53JE4F_9BpB7drhcxvgywSlwjCOcYYQ8/\n\n"
        }

        if (userRoleId != 1) {
          line += mailParams.name + " " + userName
        } else {
          line += mailParams.name
        }
        break
      case "3":
        // キャンセルとなるケース。キャンセルの連絡をする。(予約間違い・変更の場合は何もしない)
        if (reservationCancelReason != "予約間違い・変更") {
          line += reservationName + "様\n\n"
          line += "電話番号: " + reservationTel + "\n\n"
          line += "sms: " + reservationSms + "\n\n"
          line += "ご利用日時: " + reservationDatetime.replace(/-/g,"/") + "\n\n"
          line += "待ち合わせ場所: " + reservationPlace + "\n\n"
          if (reservationAddress != "") {
            line += "利用場所: " + reservationAddress + "\n\n"
          }
          var sumAmount = 0
          var sumBackTherapistAmount = 0
          line += "コース料金: "
          var courses = ""
          reservationCourses.forEach((reservationCourse) => {
            if (courses != "") {
              courses += "+"
            }
            courses += Number(reservationCourse.amount).toLocaleString() + "円（" + reservationCourse.course_detail + "）"
            sumAmount += Number(reservationCourse.amount)
            sumBackTherapistAmount += Number(reservationCourse.back_therapist_amount)
          })
          line += courses + "\n\n"

          reservationFees.forEach((reservationFee) => {
            line += reservationFee.fee_type
            if (reservationFee.fee_detail != "") {
              line += "（" + reservationFee.fee_detail + "）"
            }
            line += ": " + Number(reservationFee.amount).toLocaleString() + "円\n\n"
            sumAmount += Number(reservationFee.amount)
            sumBackTherapistAmount += Number(reservationFee.back_therapist_amount)
          })

          if (reservationPaymentMethod != "現金手渡し") {
            line += "受け取り: 事前決済のため当日の受け取りはありません。\n"
            line += "セラピスト報酬: " + sumBackTherapistAmount.toLocaleString() + "円\n"
            line += "店舗分: " + (sumAmount - sumBackTherapistAmount).toLocaleString() + "円\n\n"
            line += "セラピスト報酬" + sumBackTherapistAmount.toLocaleString() + "円につきましては、他の報酬分から相殺して振り込み必ず詳細メールを送信下さい。\n"
            line += "また、仕事日から10日～14日以内で相殺できない場合は事務局から振り込みますのでご連絡下さい。\n\n"
          } else {
            line += "受け取り: " + sumAmount.toLocaleString() + "円\n"
            line += "セラピスト報酬: " + sumBackTherapistAmount.toLocaleString() + "円\n"
            line += "店舗振込: " + (sumAmount - sumBackTherapistAmount).toLocaleString() + "円\n\n"
          }

          line = "==========\n" + line
          line = "キャンセル理由 :" + reservationCancelReason + "\n\n" + line
          line = "下記のご予約がキャンセルされました。\n\n" + line
          line += "==========\n\n"
          if (userRoleId != 1) {
            line += mailParams.name + " " + userName
          } else {
            line += mailParams.name
          }
        }
        break
    }

    return line
  }
}
