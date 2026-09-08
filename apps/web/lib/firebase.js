import { initializeApp, getApps, getApp } from "firebase/app";
import { getAnalytics, isSupported } from "firebase/analytics";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyBNwXhXjhcK7ptmN79rjNKgxu4A95J5bhY",
  authDomain: "fitflow-ungvinh.firebaseapp.com",
  projectId: "fitflow-ungvinh",
  storageBucket: "fitflow-ungvinh.firebasestorage.app",
  messagingSenderId: "478201681453",
  appId: "1:478201681453:web:548382a87ae04688e48aa4",
  measurementId: "G-7P5BQ18ESP",
};

// Initialize Firebase safely for both Next.js SSR and client
const app = !getApps().length ? initializeApp(firebaseConfig) : getApp();

// Analytics is only initialized on client-side where supported
let analytics = null;
if (typeof window !== "undefined") {
  isSupported()
    .then((supported) => {
      if (supported) {
        analytics = getAnalytics(app);
      }
    })
    .catch(() => {});
}

const auth = getAuth(app);
const db = getFirestore(app);

export { app, analytics, auth, db, firebaseConfig };
export default app;
