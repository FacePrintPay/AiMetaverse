// lib/storage.ts
// SSR-safe localStorage wrapper for Next.js App Router

export const getItem = (key: string): string | null => {
  if (typeof window === 'undefined') return null;
  try {
    return localStorage.getItem(key);
  } catch {
    return null;
  }
};

export const setItem = (key: string, value: string): void => {
  if (typeof window === 'undefined') return;
  try {
    localStorage.setItem(key, value);
  } catch {}
};

export const removeItem = (key: string): void => {
  if (typeof window === 'undefined') return;
  try {
    localStorage.removeItem(key);
  } catch {}
};

export const getJSON = <T>(key: string, fallback: T): T => {
  const str = getItem(key);
  if (!str) return fallback;
  try {
    return JSON.parse(str) as T;
  } catch {
    return fallback;
  }
};

export const setJSON = <T>(key: string, value: T): void => {
  try {
    setItem(key, JSON.stringify(value));
  } catch {}
};
