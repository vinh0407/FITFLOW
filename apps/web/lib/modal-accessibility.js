'use client';

import { useEffect } from 'react';

const focusableSelector = 'button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), a[href], [tabindex]:not([tabindex="-1"])';

/** Keeps every FITFLOW modal consistent without duplicating keyboard behavior. */
export function useModalAccessibility(isOpen, onRequestClose) {
  useEffect(() => {
    if (!isOpen) return undefined;

    // A confirmation can be layered above another modal (for example, profile →
    // logout). The topmost dialog is the only one that should receive focus.
    const dialogs = [...document.querySelectorAll('[role="dialog"][aria-modal="true"]')];
    const dialog = dialogs.at(-1);
    if (!dialog) return undefined;

    const restoreTarget = document.activeElement;
    const previousBodyOverflow = document.body.style.overflow;
    const previousDocumentOverflow = document.documentElement.style.overflow;
    const getFocusable = () => [...dialog.querySelectorAll(focusableSelector)].filter((element) => !element.hidden && element.getClientRects().length > 0);
    const focusable = getFocusable();
    if (!focusable.length && !dialog.hasAttribute('tabindex')) dialog.tabIndex = -1;
    (focusable[0] || dialog).focus();

    document.body.style.overflow = 'hidden';
    document.documentElement.style.overflow = 'hidden';

    const onKeyDown = (event) => {
      if (event.key === 'Escape') {
        event.preventDefault();
        onRequestClose();
        return;
      }
      if (event.key !== 'Tab') return;

      const items = getFocusable();
      if (!items.length) {
        event.preventDefault();
        dialog.focus();
        return;
      }

      const index = items.indexOf(document.activeElement);
      const nextIndex = event.shiftKey ? (index <= 0 ? items.length - 1 : index - 1) : (index === items.length - 1 ? 0 : index + 1);
      if (index === -1 || nextIndex !== index + (event.shiftKey ? -1 : 1)) {
        event.preventDefault();
        items[nextIndex].focus();
      }
    };

    document.addEventListener('keydown', onKeyDown);
    return () => {
      document.removeEventListener('keydown', onKeyDown);
      document.body.style.overflow = previousBodyOverflow;
      document.documentElement.style.overflow = previousDocumentOverflow;
      if (restoreTarget instanceof HTMLElement && document.contains(restoreTarget)) restoreTarget.focus();
    };
  }, [isOpen, onRequestClose]);
}
