import type { Metadata } from "next";
import localFont from "next/font/local";
import { Montserrat, Space_Grotesk } from "next/font/google";
import "@clawe/ui/globals.css";
import "./globals.css";
import { AuthProvider } from "@/providers/auth-provider";
import { ConvexClientProvider } from "@/providers/convex-provider";
import { QueryProvider } from "@/providers/query-provider";
import { ThemeProvider } from "@/providers/theme-provider";
import { ApiClientProvider } from "@/providers/api-client-provider";
import { Toaster } from "@clawe/ui/components/sonner";

const geistSans = localFont({
  src: "./fonts/GeistVF.woff",
  variable: "--font-geist-sans",
});
const geistMono = localFont({
  src: "./fonts/GeistMonoVF.woff",
  variable: "--font-geist-mono",
});
const montserrat = Montserrat({
  subsets: ["latin"],
  variable: "--font-montserrat",
});
const spaceGrotesk = Space_Grotesk({
  subsets: ["latin"],
  variable: "--font-space-grotesk",
});

export const metadata: Metadata = {
  title: "Clawe",
  description: "AI-powered multi-agent coordination system.",
};

type RootLayoutProps = Readonly<{
  children: React.ReactNode;
  params?: Promise<Record<string, string | string[]>>;
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
}>;

export default async function RootLayout({
  children,
  params,
  searchParams,
}: RootLayoutProps) {
  // Next.js 15+: params/searchParams are Promises; await to avoid sync access warnings
  if (params) await params;
  if (searchParams) await searchParams;
  return (
    <html lang="en" suppressHydrationWarning>
      <body
        className={`${geistSans.variable} ${geistMono.variable} ${montserrat.variable} ${spaceGrotesk.variable}`}
      >
        <QueryProvider>
          <AuthProvider>
            <ApiClientProvider>
              <ConvexClientProvider>
                <ThemeProvider
                  attribute="class"
                  defaultTheme="system"
                  enableSystem
                  disableTransitionOnChange
                >
                  {children}
                  <Toaster />
                </ThemeProvider>
              </ConvexClientProvider>
            </ApiClientProvider>
          </AuthProvider>
        </QueryProvider>
      </body>
    </html>
  );
}
