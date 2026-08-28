import { useEffect } from 'react';

const revealSelector = 'h1, h2, h3, p, .footer-label, .text-link, .red-action, .save-plan, .food-favorite';

export function useScrollReveal(rootSelector = 'main') {
  useEffect(() => {
    const root = document.querySelector(rootSelector);
    if (!root) return undefined;

    const elements = [...root.querySelectorAll(revealSelector)].filter((element) => !element.closest('header, [role="dialog"], .storage-strip'));
    elements.forEach((element, index) => {
      element.classList.add('scroll-reveal');
      element.style.setProperty('--reveal-delay', `${Math.min(index % 4, 3) * 70}ms`);
    });

    const revealAll = () => elements.forEach((element) => element.classList.add('is-visible'));
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches || !('IntersectionObserver' in window)) {
      revealAll();
      return undefined;
    }

    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12, rootMargin: '0px 0px -7% 0px' });

    elements.forEach((element) => observer.observe(element));
    return () => observer.disconnect();
  }, [rootSelector]);
}
