import Link from "next/link";
import { Button } from "@clawe/ui/components/button";

export default function NotFound() {
  return (
    <div className="flex min-h-svh flex-col items-center justify-center gap-4 p-6">
      <h1 className="text-2xl font-semibold">Page not found</h1>
      <p className="text-muted-foreground text-sm">
        This page could not be found. Go back to the app to continue.
      </p>
      <Button asChild>
        <Link href="/">Go to Clawe</Link>
      </Button>
    </div>
  );
}
