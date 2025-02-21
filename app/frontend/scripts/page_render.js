export function handlePageRender() {
  const loadingIndicator = document.getElementById('loading-indicator');
  if (loadingIndicator) {
    loadingIndicator.style.display = 'none';
  }
  document.body.classList.remove('preload');
}

// Initialize page render handlers
window.addEventListener('load', handlePageRender);

// Handle Turbo navigation
document.addEventListener("turbo:before-render", function() {
  const loadingIndicator = document.getElementById('loading-indicator');
  if (loadingIndicator) {
    loadingIndicator.style.display = 'flex';
  }
});

document.addEventListener("turbo:render", handlePageRender);
