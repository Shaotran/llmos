import figlet from "figlet";

console.log("Hello via Bun!");

const server = Bun.serve({
    port: 3000,
    fetch(req) {
        const body = figlet.textSync("Bun!");
        return new Response(body);
        return new Response("Bun!");
    },
  });
  

console.log(`Listening on http://localhost:${server.port} ...`);