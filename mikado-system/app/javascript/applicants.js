{
  // スピナー制御用関数
  function showSpinner(id) {
    const spinner = document.getElementById(id);
    if (spinner) spinner.style.display = 'block';
  }
  function hideSpinner(id) {
    const spinner = document.getElementById(id);
    if (spinner) spinner.style.display = 'none';
  }

  // 一括適用用のbodyをparamsに分解して返却。
  function getParamsFromBody(body) {
    return new Promise((resolve, reject) => {
      axios
      .post('/api/v1/applicants/get_params_from_body', {
        body: body
      })
      .then((res) => {
        resolve(res.data);
      })
      .catch((e) => {
        reject(e)
      })
    });
  }

  // mailAddressを検索条件にして、やりとりから画像を取得。
  function getLatestImages(applicantId) {
    return new Promise((resolve, reject) => {
      showSpinner('images-spinner');
      axios
      .post('/api/v1/applicants/get_latest_images_from_front', {
        applicantId:applicantId
      })
      .then((res) => {
        hideSpinner('images-spinner');
        resolve(res.data);
      })
      .catch((e) => {
        hideSpinner('images-spinner');
        reject(e)
      })
    });
  }

  // storeGroupIdとapplicantStatusIdから、mailとlineのテンプレートを取得。
  function getTemplates(storeGroupId, applicantStatusId) {
    return new Promise((resolve, reject) => {
      showSpinner('templates-spinner');
      axios
      .post('/api/v1/applicants/get_templates', {
        storeGroupId:storeGroupId,
        applicantStatusId:applicantStatusId
      })
      .then((res) => {
        hideSpinner('templates-spinner');
        resolve(res.data);
      })
      .catch((e) => {
        hideSpinner('templates-spinner');
        reject(e)
      })
    });
  }

  // フロントから画像を更新。
  function updateImage(applicantId, targetImage, filename, contentType, data) {
    return new Promise((resolve, reject) => {
      targetDiv = document.getElementById(targetImage)
      targetDiv.innerHTML = '';
      showSpinner(targetImage + '-spinner');
      axios
      .post('/api/v1/applicants/update_image_from_front', {
        applicantId:applicantId,
        targetImage:targetImage,
        filename:filename,
        contentType:contentType,
        data:data
      })
      .then((res) => {
        hideSpinner(targetImage + '-spinner');
        const img = document.createElement("img");
        img.src = res.data;
        img.className = "object-cover rounded-lg";
        targetDiv.appendChild(img);
        resolve(res.data);
      })
      .catch((e) => {
        hideSpinner(targetImage + '-spinner');
        reject(e)
      })
    });
  }

  // mailAddressを検索条件にして、やりとりを取得。
  function getThreads(storeGroupId, mailAddress, start, max) {
    return new Promise((resolve, reject) => {
      showSpinner('threads-spinner');
      axios
      .post('/api/v1/applicants/get_threads', {
        storeGroupId:storeGroupId,
        mailAddress:mailAddress,
        start:start,
        max:max
      })
      .then((res) => {
        hideSpinner('threads-spinner');
        resolve(res.data);
      })
      .catch((e) => {
        hideSpinner('threads-spinner');
        reject(e)
      })
    });
  }

  // thread_idを元に、そのメッセージを取得。
  function getMessages(storeGroupId, threadId) {
    return new Promise((resolve, reject) => {
      showSpinner('messages-spinner');
      axios
      .post('/api/v1/applicants/get_messages', {
        storeGroupId:storeGroupId,
        threadId:threadId
      })
      .then((res) => {
        hideSpinner('messages-spinner');
        resolve(res.data);
      })
      .catch((e) => {
        hideSpinner('messages-spinner');
        reject(e)
      })
    });
  }

  // やりとりの一覧をラジオボタンで表示
  function renderThreadsRadio(storeGroupId, threads, offset = 0, number = 10) {
    offset = parseInt(offset);
    number = parseInt(number);
    const threadsDiv = document.getElementById('threads-radio-list');
    threadsDiv.innerHTML = '';
    if (!threads || threads.length === 0) {
      threadsDiv.innerHTML = '<div class="text-gray-400">やりとりがありません</div>';
      return;
    }
    var checkFlag = true;
    for(let i = offset; i < (offset + number); i++) {
      if (i in threads) {
        const label = document.createElement('label');
        label.style.display = 'block';
        label.style.cursor = 'pointer';
        const radio = document.createElement('input');
        radio.type = 'radio';
        radio.name = 'thread-radio';
        radio.value = threads[i].id;
        radio.dataset.subject = threads[i].subject || threads[i].id;
        if (checkFlag) {
          radio.checked = true;
          checkFlag = false;
        }
        radio.addEventListener('change', async function() {
          const messages = await getMessages(storeGroupId, threads[i].id);
          renderChatMessages(messages);
        });
        label.appendChild(radio);
        label.appendChild(document.createTextNode(` ${threads[i].subject || threads[i].id}`));
        threadsDiv.appendChild(label);
      }
    };
  }

  // チャットUIにメッセージを追加する関数
  function renderChatMessages(messages) {
    const chatContainer = document.getElementById('chat-container');
    chatContainer.innerHTML = ''; // 既存をクリア

    messages.forEach(msg => {
      // 改行を<br>に変換
      const bodyWithBr = msg.body.replace(/\r?\n/g, "<br>");
      const msgDiv = document.createElement('div');
      msgDiv.className = 'chat-message';
      msgDiv.style.marginBottom = '10px';
      msgDiv.innerHTML = `
        <div style="font-size: 0.8em; color: #888;">${msg.from} - ${msg.date}</div>
        <div style="background: #f1f1f1; border-radius: 8px; padding: 8px 12px; display: inline-block;">${bodyWithBr}</div>
      `;
      chatContainer.appendChild(msgDiv);
    });

    // 最新メッセージまでスクロール
    chatContainer.scrollTop = chatContainer.scrollHeight;
    chatContainer.scrollLeft = 0;
  }

  // 応募者の情報を元にメールテンプレートからsubjectとbodyを返却する。
  function createApplicantMail(subject, body, mailParams) {
    return new Promise((resolve, reject) => {
      axios
      .post('/api/v1/mail_templates/create_applicant_mail', {
        subject: subject,
        body: body,
        mailParams: mailParams
      })
      .then((res) => {
        resolve(res.data);
      })
      .catch((e) => {
        reject(e)
      })
    });
  }

  // 応募者の情報を元にLINEテンプレートからbodyを返却する。
  function createApplicantLine(body, lineParams) {
    return new Promise((resolve, reject) => {
      axios
      .post('/api/v1/line_templates/create_applicant_line', {
        body: body,
        lineParams: lineParams
      })
      .then((res) => {
        resolve(res.data);
      })
      .catch((e) => {
        reject(e)
      })
    });
  }
}
