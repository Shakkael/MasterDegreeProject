var cur_level_cat = -1;
var cur_level_id = -1;
var cur_level_tip = -1;

// Co sekundę pobieraj dane z API i aktualizuj stronę, jeśli kategoria lub poziom się zmieniły
var intervalId = setInterval(() => {
  // Pobierz dane z API
  fetch('http://127.0.0.1:8080/api').catch(err => {
    console.error('Błąd połączenia:', err); // Obsłuż błąd połączenia, np. wyświetl komunikat użytkownikowi
  } // Zapisz wynik fetch() jako response
  ).then(response => response.json()).then(data => { // Zapisz wynik response.json() jako data

    // Nie aktualizuj, jeśli kategoria i poziom się nie zmieniły
    if (data.category !== cur_level_cat || data.current !== cur_level_id || data.puzzle_tip !== cur_level_tip || 
      (data.puzzle_output !== document.getElementById('puzzleOutput').textContent)) {

      // Aktualizuj bieżące dane
      cur_level_cat = data.category; // Zapisz kategorię z API do zmiennej globalnej
      cur_level_id = data.current; // Zapisz poziom z API do zmiennej globalnej
      cur_level_tip = data.puzzle_tip; // Zapisz wskazówkę z API do zmiennej globalnej

      var tipButton = document.getElementById('tipButton'); // Pobierz przycisk wskazówki
      var puzzleTip = document.getElementById('puzzleTip'); // Pobierz element wskazówki
      if (data.puzzle_tip != puzzleTip.textContent) { // Jeśli wskazówka z API różni się od tej na stronie, zaktualizuj ją
        if (data.puzzle_tip == null || cur_level_id == -1) { // Jeśli wskazówka jest pusta lub jesteśmy w menu, pokaż odpowiedni komunikat i dezaktywuj przycisk
          reveal(); // Wywołaj funkcję reveal() do ustawienia komunikatu o braku wskazówki
          tipButton.disabled = true; // Dezaktywuj przycisk, ponieważ nie ma wskazówki do pokazania
        }else{ // W przeciwnym razie, jeśli jest nowa wskazówka, wyczyść pole wskazówki i aktywuj przycisk
      puzzleTip.textContent = ""; // Wyczyść pole wskazówki, aby użytkownik nie widział starej wskazówki przed kliknięciem przycisku
      tipButton.disabled = false; // Aktywuj przycisk, ponieważ jest nowa wskazówka do pokazania
      }}
      // Aktualizuj wyświetlanie kategorii i poziomu
      document.getElementById('currentLevel').innerHTML = `Kategoria: ${cur_level_cat}<br>Poziom: ${cur_level_id+1}`;

      // Aktualizuj zawartość zagadki jeśli istnieje
      var puzzleOutput = document.getElementById('puzzleOutput');
      if(data.puzzle_output && data.puzzle_output !== puzzleOutput.textContent) {
        puzzleOutput.textContent = data.puzzle_output ? data.puzzle_output : '';

        puzzleOutput.classList.remove('empty_output');
      // I jeśli nie istnieje, pokaż komunikat o braku danych, zmień styl
      }else{
        puzzleOutput.textContent = 'Brak danych do poziomu.';
        puzzleOutput.classList.add('empty_output');
      }
      
      var puzzleInputs = document.getElementsByClassName('user_inputs_list');
      if(data.puzzle_input) {
        for(let i=0; i<puzzleInputs.length; i++) {
          puzzleInputs[i].disabled = false;
          if(puzzleInputs[i] instanceof HTMLInputElement) {
            puzzleInputs[i].placeholder = 'Wpisz dane';
          }
        }
      }else{
        for(let i=0; i<puzzleInputs.length; i++) {
          puzzleInputs[i].disabled = true;
          if(puzzleInputs[i] instanceof HTMLInputElement) {
            puzzleInputs[i].value = '';
            puzzleInputs[i].placeholder = 'Niedostępne';
          }
        }
      }

      if(data.download_available) {
        document.getElementById('downloadBtn').disabled = false;
      }else{
        document.getElementById('downloadBtn').disabled = true;
      }

  }
})
}, 1000);

function reveal() {
  var puzzleTip = document.getElementById('puzzleTip');
  if (cur_level_tip) {
    puzzleTip.textContent = cur_level_tip;
  } else if (cur_level_id == -1) {
    puzzleTip.textContent = 'Witamy w menu. Tutaj nie ma wskazówek.';
  }
   else {
    puzzleTip.textContent = 'Błąd. Brak wskazówki dla tego poziomu. Skontaktuj się z organizatorem badania.';
  }
  var tipButton = document.getElementById('tipButton');
  tipButton.disabled = true;
}

function checkAnswer() {
  const answer = document.getElementById('userInput').value;
  fetch('http://127.0.0.1:8080/submit', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ answer: answer })
  })
  .then(response => response.json())
  .then(data => {
    const feedback = document.getElementById('answerFeedback');
    if (data.correct) {
      feedback.textContent = 'Odpowiedź poprawna!';
      feedback.style.color = 'green';
    } else {
      feedback.textContent = 'Odpowiedź niepoprawna. Spróbuj ponownie!';
      feedback.style.color = 'red';
    }
    setTimeout(hideFeedback, 6000);
  })
  .catch(err => {
    console.error('Error checking answer:', err);
  });
}
function hideFeedback() {
  const feedback = document.getElementById('answerFeedback');
  if (feedback.textContent !== '') {
    feedback.textContent = '';
  }
}