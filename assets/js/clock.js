function getHijriDate() {
  const now = new Date();
  const hijri = new Intl.DateTimeFormat('en-u-ca-islamic-umalqma', {
    day: 'numeric',
    month: 'long',
    year: 'numeric'
  }).format(now);
  return hijri + ' AH';
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