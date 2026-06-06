// Podpięcie handlera do przesyłania formularza logowania
document.getElementById("loginForm").addEventListener("submit", checkPassword);

// Funkcja obsługująca próbę logowania
function checkPassword(event) {
  // Zapobiegamy domyślnej akcji formularza (przeładowanie strony)
  event.preventDefault();

  // Pobranie referencji do formularza i sprawdzenie poprawności pola przez HTML5
  const form = document.getElementById('loginForm');
  var check = form.reportValidity;
  // Jeśli walidacja nie przeszła, wyświetlamy komunikat i wracamy na stronę główną
  if(!check){
    alert("Check zły");
    window.location.replace('index.html');
    return;
  }

  // Pobranie wartości pól username i password
  const password = document.getElementById('password').value;
  const username = document.getElementById('username').value;

  // Wysłanie żądania POST do backendu z danymi logowania
  fetch('http://127.0.0.1:8080/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ password: password, username: username })
  })
  .then(response => response.json())
  .then(data => {
    // Miejsce na ewentualne wyświetlenie informacji zwrotnej dla użytkownika
    const feedback = document.getElementById('passwordFeedback');
    // Tymczasowe okno alert z flagą admina (można usunąć w produkcji)
    alert(data.admin);
    // Jeśli hasło jest poprawne, ustawiamy cookie i przekierowujemy do panelu admina
    if (data.password_correct == true) {
      console.log("Login successful");
      document.cookie = "admin_access=true; path=/; max-age=" + (24 * 60 * 60);
      window.location.replace('admin.html');
    }
  })
  .catch(err => {
    // Logowanie błędów w konsoli
    console.error('Error checking password:', err);
  });
}