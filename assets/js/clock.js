const hijriMonthsEn = [
  'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
  'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', "Sha'ban",
  'Ramadan', 'Shawwal', 'Dhu al-Qidah', 'Dhu al-Hijjah'
];

function getHijriDate() {
  const now = new Date();
  const year = now.getFullYear();
  const month = now.getMonth() + 1;
  const day = now.getDate();

  const m = month;
  const y = m < 3 ? year - 1 : year;
  const d = day;

  const c = Math.floor(y / 100);
  const a = Math.floor(c / 4);
  const b = 2 - c + a;
  const jd = Math.floor(365.25 * (y + 4716)) + Math.floor(30.6001 * (m + 1)) + d + b - 1524.5;

  const ijdl = Math.floor((30 * (jd - 1948439.5)) + 0.5);
  const i = Math.floor((ijdl - 1) / 10631);
  const l1 = ijdl - 10631 * i;
  const l = Math.floor((l1 - 1) / 3545);
  const k1 = l1 - 3545 * l + 30;
  const j = Math.floor((80 * k1) / 2447.6941);
  const d1 = k1 - Math.floor((2447.6941 * j) / 80);
  const m1 = Math.floor(j / 11);
  const month = j + 2 - 12 * m1;
  const year = 10631 * i + 354 * l + j + 1;
  const day = d1;

  return `${day} ${hijriMonthsEn[month - 1]} ${year} AH`;
}

function updateClock() {
  const now = new Date();
  const time = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });
  const day = now.toLocaleDateString([], { weekday: 'long' });
  const hijri = getHijriDate();
  const date = now.toLocaleDateString([], { day: 'numeric', month: 'long', year: 'numeric' }) + ' AD';
  document.getElementById('digital-clock').innerHTML = `${time} ${day}<br>${hijri}<br>${date}`;
}

setInterval(updateClock, 1000);
updateClock();
