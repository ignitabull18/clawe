import { describe, it, expect, vi, afterEach } from "vitest";
import { deriveStatus, ONLINE_THRESHOLD_MS } from "./index";

describe("deriveStatus", () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("returns offline when lastHeartbeat is undefined", () => {
    expect(deriveStatus({ status: "active" })).toBe("offline");
  });

  it("returns online when heartbeat is fresh", () => {
    const now = Date.now();
    vi.spyOn(Date, "now").mockReturnValue(now);

    expect(deriveStatus({ status: "active", lastHeartbeat: now - 1000 })).toBe(
      "online",
    );
  });

  it("returns offline when heartbeat is stale", () => {
    const now = Date.now();
    vi.spyOn(Date, "now").mockReturnValue(now);

    expect(
      deriveStatus({
        status: "active",
        lastHeartbeat: now - ONLINE_THRESHOLD_MS - 1,
      }),
    ).toBe("offline");
  });

  it("returns online at exact threshold boundary", () => {
    const now = Date.now();
    vi.spyOn(Date, "now").mockReturnValue(now);

    expect(
      deriveStatus({
        status: "active",
        lastHeartbeat: now - ONLINE_THRESHOLD_MS,
      }),
    ).toBe("online");
  });

  it("ignores the DB status field", () => {
    const now = Date.now();
    vi.spyOn(Date, "now").mockReturnValue(now);

    // Even with status "active", no heartbeat means offline
    expect(deriveStatus({ status: "active" })).toBe("offline");

    // Even with status "offline", fresh heartbeat means online
    expect(deriveStatus({ status: "offline", lastHeartbeat: now - 1000 })).toBe(
      "online",
    );
  });
});
