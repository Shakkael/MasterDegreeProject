let saveData = null;

const levelNames = [
    'Tutorial',
    'Łatwy',
    'Średni',
    'Trudny',
    'Sekretny'
];

async function loadSaveFile() {

    try {
        const response = await fetch('savefile.txt');
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }

        const text = await response.text();
        saveData = JSON.parse(text);
        refreshDisplayedData();

    } catch (err) {
        console.error(
            'Błąd podczas wczytywania savefile.txt:',
            err
        );

        const levelsUnlockedDiv =
            document.getElementById('levelsUnlocked');

        const levelsCompletedDiv =
            document.getElementById('levelsCompleted');

        if (levelsUnlockedDiv) {
            levelsUnlockedDiv.innerHTML =
                '<p>Nie udało się wczytać savefile.txt</p>';
        }

        if (levelsCompletedDiv) {
            levelsCompletedDiv.innerHTML =
                '<p>Nie udało się wczytać savefile.txt</p>';
        }
    }
}

function refreshDisplayedData() {

    const levelsUnlockedDiv = document.getElementById('levelsUnlocked');
    const levelsCompletedDiv = document.getElementById('levelsCompleted');

    if (!levelsUnlockedDiv || !levelsCompletedDiv) {
        return;
    }

    levelsUnlockedDiv.innerHTML = '';
    levelsCompletedDiv.innerHTML = '';

    if (saveData?.unlocked) {

        Object.entries(saveData.unlocked)
            .forEach(([key, values]) => {

                if ( Array.isArray(values) && values.length === 0 ) {
                    return;
                }
                const levelName = levelNames[parseInt(key)] || key;
                const para = document.createElement('p');
                para.textContent = `${levelName}: [${values.join(', ')}]`;
                levelsUnlockedDiv.appendChild(para);
            });

    } else {

        const para = document.createElement('p');
        para.textContent = 'Brak danych o odblokowanych poziomach.';
        levelsUnlockedDiv.appendChild(para);
    }

    if (saveData?.completed) {

        Object.entries(saveData.completed)
            .forEach(([key, values]) => {

                if (
                    Array.isArray(values) &&
                    values.length === 0
                ) {
                    return;
                }
                const levelName = levelNames[parseInt(key)] || key;
                const para = document.createElement('p');
                para.textContent = `${levelName}: [${values.join(', ')}]`;
                levelsCompletedDiv.appendChild(para);
            });

    } else {

        const para = document.createElement('p');
        para.textContent = 'Brak danych o ukończonych poziomach.';
        levelsCompletedDiv.appendChild(para);
    }
}
async function saveToFile() {

    try {

        const response = await fetch(
            'http://127.0.0.1:8080/save',
            {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(saveData)
            }
        );

        const result = await response.text();
        console.log("Zapisano:", result);
        refreshDisplayedData();

    } catch (err) {
        console.error("Błąd zapisu:", err);
    }
}

async function unlockLevel(group, level) {

    if(group > 3 || group < 0) {
        console.error(`Niepoprawna grupa: ${group}`);
        return;
    }
    if(level < 0 || level > 4) {
        console.error(`Niepoprawny poziom: ${level}`);
        return;
    }

    group = String(group);

    if (!saveData) {
        await loadSaveFile();
    }

    if (!saveData.unlocked[group]) {
        saveData.unlocked[group] = [];
    }

    if (!saveData.unlocked[group].includes(level)) {
        saveData.unlocked[group].push(level);
        saveData.unlocked[group]
            .sort((a, b) => a - b);

        await saveToFile();

        console.log(
            `Odblokowano poziom ${level} w grupie ${group}`
        );
    }
}

async function completeLevel(group, level) {

    if(group > 3 || group < 0) {
        console.error(`Niepoprawna grupa: ${group}`);
        return;
    }
    if(level < 0 || level > 4) {
        console.error(`Niepoprawny poziom: ${level}`);
        return;
    }

    group = String(group);

    if (!saveData) {
        await loadSaveFile();
    }

    if (!saveData.completed[group]) {
        saveData.completed[group] = [];
    }
    if (!saveData.time_finished[group]) {
        saveData.time_finished[group] = [];
    }

    if (!saveData.completed[group].includes(level)) {
        saveData.completed[group].push(level);
        saveData.time_finished[group].push(new Date().toLocaleString())
        await saveToFile();
        console.log(
            `Ukończono poziom ${level} w grupie ${group}`
        );
    }
}

function isLevelUnlocked(group, level) {

    if(group >= 5 || group < 0) {
        console.error(`Niepoprawna grupa: ${group}`);
        return false;
    }
    if(level < 0 || level >= 5) {
        console.error(`Niepoprawny poziom: ${level}`);
        return false;
    }
    if (!saveData || !saveData.unlocked[group]) {
        return false;
    }
    return saveData.unlocked[group].includes(level);
}

function isLevelCompleted(group, level) {

    if(group >= 5 || group < 0) {
        console.error(`Niepoprawna grupa: ${group}`);
        return false;
    }
    if(level < 0 || level >= 5) {
        console.error(`Niepoprawny poziom: ${level}`);
        return false;
    }
    if (!saveData || !saveData.completed[group]) {
        return false;
    }
    return saveData.completed[group].includes(level);
}