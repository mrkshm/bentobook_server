import { Loader } from "@googlemaps/js-api-loader";

// Store the promise so that we only try to load the API once.
let promise = null;

const getLoader = () => {
  if (promise) {
    return promise;
  }

  // This promise will be shared among all calls to getLoader()
  promise = new Promise((resolve, reject) => {
    const loader = new Loader({
      apiKey: window.googleMapsApiKey, // Make sure window.googleMapsApiKey is set
      version: "weekly",
      libraries: ["places", "marker"], // Added 'marker' for the new advanced markers
    });

    loader.load().then(resolve).catch(reject);
  });

  return promise;
};

export default getLoader;
