export function handlePageRender() {
  document.getElementById('loading-indicator').style.display = 'none';
  document.body.classList.remove('preload');
}

// Initialize page render handlers
window.addEventListener('load', handlePageRender);

// Handle Turbo navigation
document.addEventListener("turbo:before-render", function() {
  document.getElementById('loading-indicator').style.display = 'flex';
});

document.addEventListener("turbo:render", handlePageRender);
