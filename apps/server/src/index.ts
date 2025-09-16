import "dotenv/config";
import cors from "cors";
import express from "express";
import { auth } from "./lib/auth";
import { toNodeHandler } from "better-auth/node";

const app = express();

app.use(
	cors({
		origin: process.env.CORS_ORIGIN || "",
		methods: ["GET", "POST", "OPTIONS"],
		allowedHeaders: ["Content-Type", "Authorization"],
		credentials: true,
	}),
);

// Debug middleware to see what origin is being sent
app.use("/auth", (req, res, next) => {
	console.log("🔍 Auth request debug:");
	console.log("Origin header:", req.headers.origin);
	console.log("Referer header:", req.headers.referer);
	console.log("Host header:", req.headers.host);
	console.log("CORS_ORIGIN env:", process.env.CORS_ORIGIN);
	console.log("BETTER_AUTH_URL env:", process.env.BETTER_AUTH_URL);
	next();
});

app.all("/auth{/*path}", toNodeHandler(auth));

app.use(express.json());

app.get("/", (_req, res) => {
	res.status(200).send("OK");
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
	console.log(`Server is running on port ${port}`);
});
