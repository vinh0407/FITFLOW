import './globals.css';

export const metadata = {
  title: 'FITFLOW / Training Operating System',
  description: 'Train with intent.',
  icons: { icon: '/favicon-f.png' }
};

export default function RootLayout({ children }) {
  const contract = `<!--
    THESIS: FITFLOW is a training operating system, not a soft wellness dashboard.
    OWN-WORLD: charcoal substrate, off-white type, hazard red, square geometry, blueprint rules, and telemetry.
    STORY: the user sees the next useful session, understands its readiness, and starts without friction.
    FIRST VIEWPORT: asymmetric training command deck with session status left-to-right and START SESSION as the focal action.
    FORM: industrial control deck; code-led first surface.
    FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance
  -->`;
  return <html lang="en"><body><div hidden dangerouslySetInnerHTML={{ __html: contract }} />{children}</body></html>;
}
