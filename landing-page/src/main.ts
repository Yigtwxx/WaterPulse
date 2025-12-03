import './style.css'

// Simple interaction logic
document.addEventListener('DOMContentLoaded', () => {
  console.log('WaterPulse Landing Page Loaded');

  const downloadBtn = document.getElementById('download-btn');
  if (downloadBtn) {
    downloadBtn.addEventListener('click', (e) => {
      e.preventDefault();
      alert('Download started! (This is a demo)');
    });
  }

  // Smooth scroll for anchor links
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', (e) => {
      e.preventDefault();
      const href = anchor.getAttribute('href');
      if (href) {
        const target = document.querySelector(href);
        if (target) {
          target.scrollIntoView({
            behavior: 'smooth'
          });
        }
      }
    });
  });
});
