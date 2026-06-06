// Sprawdź czy użytkownik ma dostęp do panelu admina, jeśli nie, przekieruj go na stronę logowania
function getCookie(name) {
    const pairs = document.cookie.split(';').map(c => c.trim());

    for (const p of pairs) { // Ignoruj puste pary, które mogą powstać w wyniku nieprawidłowego formatowania ciasteczek
        if (!p) continue;
        const idx = p.indexOf('=');
        const key = idx > -1 ? p.substring(0, idx) : p; // Jeśli nie ma '=', to cała para jest kluczem, a wartość jest pusta
        const val = idx > -1 ? p.substring(idx + 1) : ''; // Jeśli nie ma '=', to wartość jest pusta
        if (key === name) { // Jeśli klucz pasuje do szukanego, zwróć jego wartość
            return decodeURIComponent(val); // Zwróć zdekodowaną wartość, aby obsłużyć ewentualne znaki specjalne
        }
    }

    return null;
}

function checkAdminAccess() {
    const isAdmin = getCookie('admin_access') === 'true'; // Sprawdź, czy ciasteczko 'admin_access' jest ustawione na 'true'

    if (!isAdmin) { // Jeśli użytkownik nie ma dostępu, ustaw ciasteczko na 'false' i przekieruj go na stronę logowania
        document.cookie = "admin_access=false; path=/"; // Ustaw ciasteczko 'admin_access' na 'false' dla całej domeny
        window.location.replace('admin.html'); // Przekieruj użytkownika na stronę admin.html
        // API obsługuje, czy admin.html zwraca plik admin.html czy login.html
        return false; // Zwróć false, aby zatrzymać dalsze wykonywanie skryptu, jeśli użytkownik nie ma dostępu
    }
// Jeśli użytkownik ma dostęp, zwróć true, aby pozwolić na dalsze wykonywanie skryptu
    return true;
}

// Funkcja do wylogowania użytkownika, która usuwa ciasteczko 'admin_access' i przekierowuje go na stronę admin.html
// Po usunięcia ciasteczka, API powinno zwrócić login.html zamiast admin.html mimo że link nadal kieruje do admin.html
function logout() {
    document.cookie = "admin_access=false; path=/; max-age=0";
    window.location.replace('admin.html');
}

// Sprawdź dostęp do panelu admina i załaduj dane z pliku zapisu przy ładowaniu strony
document.addEventListener('DOMContentLoaded', async () => {
// Sprawdź, czy użytkownik ma dostęp do panelu admina, jeśli nie, przekieruj go na stronę logowania
    if (!checkAdminAccess()) {
        return;
    }
    await loadSaveFile();

});

function redeemCode() { // Pobierz wartość z pola input i sprawdź, czy jest poprawnym kodem
    const codeInput = document.getElementById('codeInput').value.trim(); // zapisz kod z inputa i usuń ewentualne spacje na początku i końcu
    if(codeInput=="HasłoSzyfrowane"){ // Sprawdź, czy kod jest poprawny
        console.log("Code redeemed successfully!"); // Jeśli kod jest poprawny, odblokuj poziom 3-1, załaduj plik zapisu i przekieruj użytkownika do poziomu 3-1
        unlockLevel(3, 1); // Odblokuj poziom 3-1
        loadSaveFile(); // Załaduj plik zapisu, aby mieć pewność, że dane są aktualne przed przekierowaniem
        window.location.replace('levelH2.html'); // Przekieruj użytkownika do poziomu 3-1 (levelH2.html)
    }else if(codeInput=="V3Bpc3o6IEhhc8WCb1N6eWZyb3dhbmU="){ // Jeśli kod jest poprawny, wyświetl alert z informacją o podaniu hasła ukrytego za szyfrem
        alert("Podałeś szyfr. Podaj hasło ukryte za szyfrem."); // Wyświetl alert z informacją o podaniu hasła ukrytego za szyfrem, jeśli kod jest poprawny
    }
    else{ // Jeśli kod jest niepoprawny, wyświetl komunikat w konsoli
        console.log("Invalid code.");
    }
}