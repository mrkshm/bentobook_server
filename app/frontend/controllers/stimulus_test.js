// Simple test to verify Stimulus is working
document.addEventListener('DOMContentLoaded', () => {
  console.log('Stimulus test: DOM content loaded');
  
  // Check if Stimulus is defined
  if (window.Stimulus) {
    console.log('Stimulus is available globally:', window.Stimulus);
    
    // List all registered controllers
    const controllers = Object.keys(window.Stimulus.controllers);
    console.log('Registered controllers:', controllers);
    
    // Check for specific controllers
    console.log('Hello controller registered:', controllers.includes('hello'));
    console.log('Dropdown menu controller registered:', controllers.includes('dropdown-menu'));
  } else {
    console.error('Stimulus is not available globally!');
  }
  
  // Check for elements with controllers
  const helloElements = document.querySelectorAll('[data-controller="hello"]');
  console.log('Hello controller elements:', helloElements.length);
  
  const dropdownElements = document.querySelectorAll('[data-controller="dropdown-menu"]');
  console.log('Dropdown menu controller elements:', dropdownElements.length);
});
