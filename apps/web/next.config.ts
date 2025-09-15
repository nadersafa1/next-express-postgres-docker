import type { NextConfig } from "next";
import path from "path";

const nextConfig: NextConfig = {
	typedRoutes: true,
	output: "standalone",
	// Include files from the monorepo root for proper tracing
	outputFileTracingRoot: path.join(__dirname, "../../"),
};

export default nextConfig;
