"use client";

import { useEffect } from "react";
import { STORAGE_KEYS, readStorage } from "../../lib/storage";

const faqs = [
  [
    "What is FITFLOW and how does it work?",
    "FITFLOW is a training companion for people who train independently. Use the exercise library to understand a movement, build a BMI-based 7-day plan, start a guided session, and keep a local record of completed work.",
  ],
  [
    "Does FITFLOW create a plan for me?",
    "Yes. The plan builder uses height and weight to calculate BMI, then creates a gradual 7-day starting plan. Your saved profile can also record your training goal, level, and available training days.",
  ],
  [
    "Can I see how to perform an exercise?",
    "Yes. Select a movement from the Exercise Library or Training Guide to open its demonstration and written guidance. The guide links to the matching movement in the library whenever one is available.",
  ],
  [
    "Does FITFLOW work offline?",
    "The current web experience is local-first: profile details, saved plans, food favourites, and workout history are stored on this device. Cross-device cloud sync is planned; until then, data does not automatically move between devices.",
  ],
  [
    "Does FITFLOW use an AI food scanner?",
    "Not in the current version. FITFLOW includes a practical food library, nutrition values, a random daily menu, and calculators. Food recognition or barcode scanning should only be presented when those features are actually available.",
  ],
  [
    "Is there a FITFLOW mobile app?",
    "FITFLOW has an Android companion built with Flutter. It follows the same training language—plans, exercise guidance, nutrition, profile, and progress—with mobile-first controls. Availability depends on the Android build you install.",
  ],
  [
    "Is FITFLOW free to use?",
    "The FITFLOW web app is free to use. It does not sell training courses or require a subscription to use the core exercise, plan, nutrition, calculator, and local workout-log features.",
  ],
  [
    "Is FITFLOW medical advice?",
    "No. BMI, calorie, body-fat, heart-rate, and macro calculations are estimates. Adjust training around injury, health conditions, medication, or uncertainty with a qualified health professional.",
  ],
];

export default function AboutPage() {
  useEffect(() => {
    document.documentElement.dataset.theme =
      readStorage(STORAGE_KEYS.theme, "light") === "dark" ? "dark" : "light";
  }, []);

  return (
    <main className="about-page">
      <a className="skip-link" href="#about-content">
        SKIP TO CONTENT
      </a>
      <header className="subpage-header about-header">
        <a className="wordmark" href="/" aria-label="FITFLOW home">
          <span className="mark">F</span> FITFLOW
        </a>
        <a className="back-link" href="/">
          ← BACK TO TRAINING
        </a>
      </header>
      <section className="about-hero" id="about-content">
        <div>
          <span>HOME / ABOUT FITFLOW</span>
          <h1>
            TRAIN
            <br />
            <em>ON YOUR TERMS.</em>
          </h1>
        </div>
        <p>
          FITFLOW is for the solo rep: the day you want a clear next action, a
          reliable reference, and a pace you can sustain.
        </p>
      </section>
      <section className="about-statement">
        <div>
          <span>THE PROMISE</span>
          <h2>
            START WITH
            <br />
            <em>WHAT YOU HAVE.</em>
          </h2>
        </div>
        <div>
          <p>
            There is no perfect starting point. There is only the next useful
            decision: move, learn the form, record the work, recover, and
            return.
          </p>
          <p>
            FITFLOW keeps that decision practical with an exercise library,
            guided sessions, a 7-day plan builder, nutrition references,
            calculators, and a history that stays on your device.
          </p>
        </div>
      </section>
      <section
        className="mobile-companion"
        aria-labelledby="mobile-companion-title"
      >
        <div className="mobile-companion-copy">
          <span>FITFLOW / ANDROID COMPANION</span>
          <h2 id="mobile-companion-title">
            THE PLAN
            <br />
            <em>IN YOUR HAND.</em>
          </h2>
          <p>
            The Android companion brings FITFLOW&apos;s training flow to a
            phone: profile, plan, workout session, nutrition reference, and
            progress—built in Flutter with the same black, white, grey, and red
            command-deck language.
          </p>
          <p className="about-availability">
            ANDROID BUILD / INSTALL WHEN AVAILABLE
          </p>
        </div>
        <div
          className="mobile-screen"
          aria-label="FITFLOW mobile app feature summary"
        >
          <b>FITFLOW</b>
          <strong>
            START
            <br />
            DAY 01
          </strong>
          <span>7-DAY PLAN</span>
          <i>WORKOUT · NUTRITION · LOG</i>
        </div>
      </section>
      <section className="faq-section" aria-labelledby="faq-heading">
        <header>
          <span>FREQUENTLY ASKED QUESTIONS</span>
          <h2 id="faq-heading">
            CLEAR
            <br />
            <em>BEFORE YOU START.</em>
          </h2>
          <p>
            If you have something else to ask, use FITFLOW&apos;s on-page
            guidance first—then seek qualified support for medical or personal
            training decisions.
          </p>
        </header>
        <div className="faq-list">
          {faqs.map(([question, answer], index) => (
            <details key={question}>
              <summary>
                <span>{String(index + 1).padStart(2, "0")}</span>
                {question}
                <b aria-hidden="true">+</b>
              </summary>
              <p>{answer}</p>
            </details>
          ))}
        </div>
      </section>
      <section className="about-close">
        <h2>
          THE NEXT
          <br />
          <em>REP IS YOURS.</em>
        </h2>
        <a className="red-action" href="/#workouts">
          START TODAY&apos;S WORKOUT <span>→</span>
        </a>
      </section>
      <nav className="mobile-dock" aria-label="Mobile primary navigation">
        <a href="/">HOME</a>
        <a href="/#workouts">TRAIN</a>
        <a href="/#library">LIBRARY</a>
        <a href="/#plans">PLAN</a>
        <a href="/nutrition">FOOD</a>
      </nav>
    </main>
  );
}
