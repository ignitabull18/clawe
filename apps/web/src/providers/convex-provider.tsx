"use client";

import { ConvexProviderWithAuth, ConvexReactClient } from "convex/react";
import type { ReactNode } from "react";
import { useConvexAuth } from "@/providers/auth-provider";

// Fallback for local dev when env isn't inlined (e.g. missing .env or wrong cwd)
const convexUrl =
  typeof process.env.NEXT_PUBLIC_CONVEX_URL === "string" &&
  process.env.NEXT_PUBLIC_CONVEX_URL.length > 0
    ? process.env.NEXT_PUBLIC_CONVEX_URL
    : "http://127.0.0.1:3210";
const convex = new ConvexReactClient(convexUrl);

export const ConvexClientProvider = ({ children }: { children: ReactNode }) => (
  <ConvexProviderWithAuth client={convex} useAuth={useConvexAuth}>
    {children}
  </ConvexProviderWithAuth>
);
