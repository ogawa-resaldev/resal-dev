{
  /*
    セラピストのautocompleteフォームを作成。
    使い方：
      入れたい場所にid=therapist-autocompleteのdivを設定。
      例)
        <div id="therapist-autocomplete"></div>
      引数にform送信時のidを指定可能。(デフォルトはtherapist_id)
   */
  function createTherapistAutocomplete(form_id = "therapist_id") {
    const therapistAutocompleteDiv = document.getElementById('therapist-autocomplete')
    let therapistAutocompleteInput = document.createElement('input')
    therapistAutocompleteInput.id = "therapist-id-text-input"
    therapistAutocompleteInput.type = "text"
    therapistAutocompleteInput.placeholder = "セラピスト名を入力"
    therapistAutocompleteInput.autocomplete = "off"
    therapistAutocompleteInput.classList.add("py-3", "px-4", "pe-9", "block", "w-full", "border-gray-200", "rounded-lg", "text-sm", "focus:border-blue-500", "focus:ring-blue-500", "disabled:opacity-50", "disabled:pointer-events-none", "dark:bg-neutral-900", "dark:border-neutral-700", "dark:text-neutral-400", "dark:placeholder-neutral-500", "dark:focus:ring-neutral-600")
    therapistAutocompleteDiv.appendChild(therapistAutocompleteInput)
    let therapistAutocompleteHiddenField = document.createElement("input")
    therapistAutocompleteHiddenField.id = form_id
    therapistAutocompleteHiddenField.type = "hidden"
    therapistAutocompleteHiddenField.name = form_id
    therapistAutocompleteDiv.appendChild(therapistAutocompleteHiddenField)
    let therapistSuggestions = document.createElement("div")
    therapistSuggestions.id = "therapist-suggestions"
    therapistSuggestions.classList.add("absolute", "z-10", "mt-1", "w-full", "bg-white", "border", "border-gray-200", "rounded-lg", "shadow-lg", "hidden", "dark:bg-neutral-800", "dark:border-neutral-700")
    therapistAutocompleteDiv.appendChild(therapistSuggestions)
  }

  /*
    セラピストのautocompleteのリストを更新。
    引数に@therapist_select=[[therapist_id, therapist__name, therapist_autocomplete]...]を入れる。
    また、第2引数でform送信時のidを指定可能。(デフォルトはtherapist_id)
  */
  function updateTherapistAutocompleteList(therapist_select, form_id = "therapist_id") {
    const therapistAutocompleteInput = document.getElementById("therapist-id-text-input")
    const therapistAutocompleteHiddenField = document.getElementById(form_id)
    const therapistSuggestions = document.getElementById("therapist-suggestions")
    const therapistSelect = JSON.parse((therapist_select).replace(/(&quot;)/g, '"'))

    // セラピストデータを準備
    const therapists = []
    therapistSelect.forEach(function(therapist){
      therapists.push({
        id:therapist[0],
        name:therapist[1],
        autocomplete:therapist[2]
      })
    })

    // 初期値の設定（既に選択されている場合）
    const initialTherapistId = therapistAutocompleteHiddenField.value;
    if (initialTherapistId) {
      const selectedTherapist = therapists.find(t => t.id == initialTherapistId);
      if (selectedTherapist) {
        therapistAutocompleteInput.value = selectedTherapist.name;
      } else {
        therapistAutocompleteInput.value = '';
        therapistAutocompleteHiddenField.value = '';
      }
    }

    // 入力時の処理
    therapistAutocompleteInput.addEventListener('input', function() {
      const query = this.value.toLowerCase();

      // 入力が空の場合は候補を非表示
      if (!query) {
        therapistSuggestions.innerHTML = '';
        therapistSuggestions.classList.add('hidden');
        therapistAutocompleteHiddenField.value = '';
        return;
      }

      // 検索クエリにマッチするセラピストをフィルタリング
      const filteredTherapists = therapists.filter(
        therapist => therapist.autocomplete.toLowerCase().includes(query)
      );

      // 候補リストを生成
      therapistSuggestions.innerHTML = '';

      if (filteredTherapists.length > 0) {
        filteredTherapists.forEach(therapist => {
          const item = document.createElement('div');
          item.className = 'px-4 py-2 hover:bg-gray-100 cursor-pointer dark:hover:bg-neutral-700';
          item.textContent = therapist.name;
          item.dataset.id = therapist.id;

          item.addEventListener('click', function() {
            therapistAutocompleteInput.value = therapist.name;
            therapistAutocompleteHiddenField.value = therapist.id;
            therapistSuggestions.classList.add('hidden');
          });

          therapistSuggestions.appendChild(item);
        });

        therapistSuggestions.classList.remove('hidden');
      } else {
        // マッチする候補がない場合
        const noResults = document.createElement('div');
        noResults.className = 'px-4 py-2 text-gray-500 dark:text-gray-400';
        noResults.textContent = '該当するセラピストがいません';
        therapistSuggestions.appendChild(noResults);
        therapistSuggestions.classList.remove('hidden');
      }
    });

    // 候補リスト以外をクリックしたら候補を非表示
    document.addEventListener('click', function(e) {
      if (!therapistAutocompleteInput.contains(e.target) && !therapistSuggestions.contains(e.target)) {
        therapistSuggestions.classList.add('hidden');
      }
    });

    // フォーカス時に候補を表示
    therapistAutocompleteInput.addEventListener('focus', function() {
      if (this.value) {
        const event = new Event('input');
        this.dispatchEvent(event);
      }
    });

    // キーボード操作のサポート
    therapistAutocompleteInput.addEventListener('keydown', function(e) {
      const items = therapistSuggestions.querySelectorAll('.cursor-pointer');
      const currentIndex = Array.from(items).findIndex(item => item.classList.contains('bg-gray-100') || item.classList.contains('dark:bg-neutral-700'));

      // 下キー
      if (e.key === 'ArrowDown') {
        e.preventDefault();
        if (currentIndex < items.length - 1) {
          if (currentIndex >= 0) {
            items[currentIndex].classList.remove('bg-gray-100', 'dark:bg-neutral-700');
          }
          items[currentIndex + 1].classList.add('bg-gray-100', 'dark:bg-neutral-700');
        }
      }

      // 上キー
      else if (e.key === 'ArrowUp') {
        e.preventDefault();
        if (currentIndex > 0) {
          items[currentIndex].classList.remove('bg-gray-100', 'dark:bg-neutral-700');
          items[currentIndex - 1].classList.add('bg-gray-100', 'dark:bg-neutral-700');
        }
      }

      // Enterキー
      else if (e.key === 'Enter') {
        e.preventDefault();
        const selectedItem = therapistSuggestions.querySelector('.bg-gray-100', '.dark:bg-neutral-700');
        if (selectedItem) {
          selectedItem.click();
        }
      }

      // Escキー
      else if (e.key === 'Escape') {
        therapistSuggestions.classList.add('hidden');
      }
    });
  }
}
