function getHijriDate() {
  const now = new Date();
  const formatter = new Intl.DateTimeFormat('en-u-ca-islamic-umalqma', {
    day: 'numeric',
    month: 'long',
    year: 'numeric'
  });
  const parts = formatter.formatToParts(now);
  const day = parts.find(p => p.type === 'day').value;
  const month = parts.find(p => p.type === 'month').value;
  const year = parts.find(p => p.type === 'year').value;
  return `${day} ${month} ${year} AH`;
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
updateClock(); // Initial call