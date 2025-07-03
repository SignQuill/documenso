import React, { useEffect, useState } from 'react';
import type { ImgHTMLAttributes } from 'react';

export type LogoProps = ImgHTMLAttributes<HTMLImageElement>;

export const BrandingLogo = ({ ...props }: LogoProps) => {
  const [isDarkMode, setIsDarkMode] = useState(false);

  useEffect(() => {
    const darkModeQuery = window.matchMedia('(prefers-color-scheme: dark)');
    const updateMode = (e: MediaQueryListEvent) => setIsDarkMode(e.matches);

    // Set initial mode
    setIsDarkMode(darkModeQuery.matches);

    // Listen for changes
    darkModeQuery.addEventListener('change', updateMode);

    return () => {
      darkModeQuery.removeEventListener('change', updateMode);
    };
  }, []);

  return (
    <img
      src={isDarkMode ? '/SignQuill_B1.png' : '/SignQuill_B2.png'}
      alt="SignQuill Logo"
      {...props}
    />
  );
};
