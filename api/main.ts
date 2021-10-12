import { Application, Router } from "https://deno.land/x/oak@v9.0.1/mod.ts";
import { Client } from "https://deno.land/x/postgres@v0.13.0/mod.ts";

const app = new Application();
const router = new Router();
const client = new Client({
  hostname: "localhost",
  port: 5432,
  database: "nile",
  user: "nile",
  password: "nile",
});
await client.connect();

interface ProductHistory {
  // deno-lint-ignore camelcase
  product_id: string;
  name: string;
  // deno-lint-ignore camelcase
  version_number: number;
  price: number;
}

function toProductJson(productHistory: ProductHistory) {
  return {
    id: productHistory.product_id,
    name: productHistory.name,
    price: productHistory.price,
  }
}

router.get("/", async (context) => {
  context.response.headers.append("content-type", "text/html");
  context.response.body = await Deno.readTextFile("./index.html")
});

router.get("/v1/systems/ping", (context) => {
  context.response.headers.append("content-type", "application/json");
  context.response.body = JSON.stringify({ ok: "ok" });
});
router.get("/v1/products", async (context) => {
  context.response.headers.append("content-type", "application/json");

  const results = await client.queryObject<ProductHistory>`
    SELECT ph.product_id, ph.name, ph.version_number, ph.price FROM nile.product_history ph
      JOIN (SELECT product_id, MAX(version_number) as max_version_number FROM nile.product_history GROUP BY product_id) max
        ON max.product_id = ph.product_id AND max.max_version_number = ph.version_number;
  `;
  context.response.body = JSON.stringify(results.rows.map(toProductJson));
});
router.get("/v1/products/:id", async (context) => {
  context.response.headers.append("content-type", "application/json");

  const id = context.params.id;
  const results = await client.queryObject<ProductHistory>`
    SELECT * FROM nile.product_history ph
      JOIN (SELECT product_id, MAX(version_number) as max_version_number FROM nile.product_history GROUP BY product_id) max
        ON max.product_id = ph.product_id AND max.max_version_number = ph.version_number
      WHERE ph.product_id = ${id};
  `;
  if ((results.rowCount ?? 0) > 0) {
    const result = results.rows[0];
    context.response.body = JSON.stringify(toProductJson(result));
  } else {
    context.response.status = 404;
    context.response.body = JSON.stringify({});
  }
});
router.post("/v1/products", async (context) => {
  context.response.headers.append("content-type", "application/json");

  const id = crypto.randomUUID();
  const { name, price } = await context.request.body({ type: "json" }).value;
  if (name == null || price == null) {
    context.response.status = 400;
    context.response.body = JSON.stringify({ errors: ["Parameter 'name' or 'price' not found."] });
    return;
  }
  await client.queryObject`
    INSERT INTO nile.product (id) VALUES(${id});
  `;
  await client.queryObject`
    INSERT INTO nile.product_history (product_id, name, version_number, price) VALUES(${id}, ${name}, 0, ${price});
  `;
  context.response.body = JSON.stringify({ id, name, price });
});
router.put("/v1/products/:id", async (context) => {
  context.response.headers.append("content-type", "application/json");

  const id = context.params.id;
  const { name, price } = await context.request.body({ type: "json" }).value;
  if (name == null && price == null) {
    context.response.status = 400;
    context.response.body = JSON.stringify({ errors: ["Parameter 'name' or 'price' not found."] });
    return;
  }
  const latestData = await client.queryObject<ProductHistory>`
    SELECT * FROM nile.product_history p1
      JOIN (SELECT product_id, MAX(version_number) max_version FROM nile.product_history GROUP BY product_id) p2
        ON p1.product_id = p2.product_id AND p1.version_number = p2.max_version
      WHERE p1.product_id = ${id};
  `;
  if ((latestData.rowCount ?? 0) === 0) {
    context.response.status = 400;
    context.response.body = JSON.stringify({ errors: ["Parameter 'name' or 'price' not found."] });
    return;
  }
  // deno-lint-ignore camelcase
  const { name: latestName, price: latestPrice, version_number } = latestData.rows[0];
  await client.queryObject`
    INSERT INTO nile.product_history (product_id, name, version_number, price)
      VALUES(${id}, ${name ?? latestName}, ${version_number + 1}, ${price ?? latestPrice});
  `;

  context.response.body = JSON.stringify({});
});

app.use(router.routes());

app.addEventListener("listen", () => console.log("Server started on 8080"));
app.listen({ port: 8080 });
