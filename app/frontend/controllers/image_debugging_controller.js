import { Controller } from "@hotwired/stimulus";

// This controller is for debugging image loading issues
export default class extends Controller {
  connect() {
    console.log("Image debugging controller connected");
    this.runImageTests();
  }

  runImageTests() {
    console.log("Running image compatibility tests...");

    // Test 1: Basic image creation
    const img1 = new Image();
    img1.onload = () => console.log("Test 1: Basic image loaded successfully");
    img1.onerror = () => console.error("Test 1: Basic image failed to load");
    img1.src = "data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==";

    // Test 2: Data URL with transparent PNG
    const img2 = new Image();
    img2.onload = () => console.log("Test 2: PNG loaded successfully");
    img2.onerror = () => console.error("Test 2: PNG failed to load");
    // 1x1 transparent PNG
    img2.src = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=";

    // Test 3: Create element and set properties
    const container = document.createElement('div');
    container.style.width = '100px';
    container.style.height = '100px';
    container.style.position = 'absolute';
    container.style.left = '-9999px';
    container.style.backgroundImage = `url(${img1.src})`;
    container.style.backgroundSize = 'cover';
    document.body.appendChild(container);
    
    setTimeout(() => {
      console.log("Test 3: Container computed style:", 
        window.getComputedStyle(container).backgroundImage,
        window.getComputedStyle(container).backgroundSize);
      document.body.removeChild(container);
    }, 100);

    // Test browser and platform information
    console.log("Browser:", navigator.userAgent);
    console.log("Platform:", navigator.platform);
  }
}
