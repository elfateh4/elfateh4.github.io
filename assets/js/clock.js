const hijriMonthsEn = [
  'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
  'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', "Sha'ban",
  'Ramadan', 'Shawwal', 'Dhu al-Qidah', 'Dhu al-Hijjah'
];

function getHijriDate() {
  const now = new Date();
  const year = now.getFullYear();
  const month = now.getMonth();
  const day = now.getDate();

  const gregorianDate = new Date(Date.UTC(year, month, day));
  const julianDay = Math.floor((gregorianDate.getTime() / 86400000) + 2440587.5);

  const islamicEpoch = 1948439.5;
  const daysSinceEpoch = julianDay - islamicEpoch;
  const hijriYear = Math.ceil(daysSinceEpoch / 354.367067);
  const daysInYear = (hijriYear - 1) * 354 + Math.floor((3 + 11 * hijriYear) / 30);
  let hijriDay = Math.floor(daysSinceEpoch - daysInYear) + 1;
  let hijriMonth = Math.floor((hijriDay - 1) / 29.5) + 1;

  if (hijriMonth > 12) hijriMonth = 12;
  const daysInMonth = hijriMonth === 12 && ((hijriYear * 11 + 3) % 30 > 18) ? 30 : 29;
  hijriDay = Math.min(hijriDay, daysInMonth);

  return `${hijriDay} ${hijriMonthsEn[hijriMonth - 1]} ${hijriYear} AH`;
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
