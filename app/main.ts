import {
  Application,
  Context,
  Router,
} from "https://deno.land/x/oak@v9.0.1/mod.ts";
import {
  Client,
  Pool,
  Transaction,
} from "https://deno.land/x/postgres@v0.13.0/mod.ts";

const app = new Application();
const router = new Router();
const pool = new Pool(
  {
    hostname: "localhost",
    port: 5432,
    database: "nile",
    user: "nile",
    password: "nile",
  },
  8,
  true,
);

async function useClient<T>(fn: (client: Client) => Promise<T>): Promise<T> {
  const client = await pool.connect();
  try {
    return fn(client);
  } finally {
    client.release();
  }
}

function useTransaction<T>(
  fn: (transaction: Transaction) => Promise<T>,
): Promise<T> {
  return useClient<T>(async (client) => {
    const transaction = client.createTransaction("TRANSACTIONAL QUERY");
    await transaction.begin();
    try {
      const result = await fn(transaction);
      await transaction.commit();
      return result;
    } catch (e) {
      try {
        await transaction.rollback();
        // deno-lint-ignore no-empty
      } catch {}
      throw e;
    }
  });
}

router.get("/", async (context) => {
  context.response.headers.set("content-type", "text/html");
  context.response.body = await Deno.readTextFile("./index.html");
});

router.get("/v1/systems/ping", (context) => {
  context.response.body = JSON.stringify({ ok: "ok" });
});

router.get("/v1/products", async (context) => {
  // 1 対 多のリクエストの場合は、1の方を SELECT * FROMにしたほうがいい
  // なぜ、出力するときに p.id とかすると怒られるのか
  const results = await useClient((client) => {
    return client.queryObject`
      SELECT id, name, count, price FROM nile.product p
        JOIN nile.product_history ph ON p.id = ph.product_id
        JOIN (SELECT product_id, MAX(version_number) as max_version_number FROM nile.product_history GROUP BY product_id) max
          ON max.product_id = p.id AND max.max_version_number = ph.version_number;`;
  });

  context.response.body = JSON.stringify(results.rows);
});

router.get("/v1/products/:id", async (context) => {
  const id = context.params.id;
  const results = await useClient((client) => {
    return client.queryObject`
      SELECT id, name, count, price FROM nile.product p
        JOIN nile.product_history ph ON p.id = ph.product_id
        JOIN (SELECT product_id, MAX(version_number) as max_version_number FROM nile.product_history GROUP BY product_id) max
          ON max.product_id = p.id AND max.max_version_number = ph.version_number
        WHERE p.id = ${id};`;
  });
  if ((results.rowCount ?? 0) > 0) {
    const result = results.rows[0];
    context.response.body = JSON.stringify(result);
  } else {
    context.response.status = 404;
    context.response.body = JSON.stringify({});
  }
});

router.post("/v1/products", async (context) => {
  const id = crypto.randomUUID();
  const { name, price, count } = await context.request.body({ type: "json" })
    .value;
  if (name == null || price == null || count == null) {
    context.response.status = 400;
    context.response.body = JSON.stringify({
      errors: ["Parameter 'name' or 'price' or 'count' not found."],
    });
    return;
  }
  await useTransaction(async (transaction) => {
    await transaction.queryObject`
        INSERT INTO nile.product (id, count) VALUES(${id}, ${count});`,
      await transaction.queryObject`
        INSERT INTO nile.product_history (product_id, name, version_number, price) VALUES(${id}, ${name}, 0, ${price});`;
  });
  context.response.body = JSON.stringify({ id, name, price });
});

router.put("/v1/products/:id", async (context) => {
  const id = context.params.id;
  const { name, price, count } = await context.request.body({ type: "json" })
    .value;
  if (name == null && price == null && count == null) {
    context.response.status = 400;
    context.response.body = JSON.stringify({
      errors: ["Parameter 'name' or 'price' not found."],
    });
    return;
  }

  await useTransaction(async (transaction) => {
    if (count != null) {
      await transaction.queryObject`
        UPDATE nile.product SET count = ${count} WHERE id = ${id};
      `;
    }
    if (name != null || price != null) {
      const latestData = await transaction.queryObject<Record<string, string>>`
        SELECT p1.product_id as id, p1.name, p1.price, p1.count FROM nile.product_history p1
          JOIN (SELECT product_id, MAX(version_number) max_version FROM nile.product_history GROUP BY product_id) p2
            ON p1.product_id = p2.product_id AND p1.version_number = p2.max_version
          WHERE p1.product_id = ${id};
      `;
      if ((latestData.rowCount ?? 0) === 0) {
        context.response.status = 404;
        context.response.body = JSON.stringify({
          errors: [`Product id(${id}) is not found.`],
        });
        return;
      }
      // deno-lint-ignore camelcase
      const { name: latestName, price: latestPrice, version_number } =
        latestData.rows[0];
      await transaction.queryObject`
        INSERT INTO nile.product_history (product_id, name, version_number, price)
          VALUES(${id}, ${name ?? latestName}, ${version_number + 1}, ${price ??
        latestPrice});
      `;
    }
  });

  context.response.body = JSON.stringify({});
});

router.delete("/v1/products/:id", async (context) => {
  const id = context.params.id;
  await useTransaction(async (transaction) => {
    await transaction.queryObject`
      DELETE FROM nile.product_history WHERE product_id = ${id};`;
    await transaction.queryObject`
      DELETE FROM nile.product WHERE id = ${id};`;
  });
  context.response.body = JSON.stringify({});
});

router.get("/v1/carts", (context) => {
  const userId = context.request.headers.get("x-user-id");
  return useClient(async (client) => {
    const cartResult = await client.queryObject<{ id: string }>`
      SELECT * FROM nile.cart WHERE user_id = ${userId}`;

    if (cartResult.rowCount === 0) {
      context.response.status = 500;
      context.response.body = JSON.stringify({ errors: ["Cart not found"] });
    }

    const cartItems = await client.queryObject`
      SELECT p.id, cp.count, ph.name, ph.price FROM nile.cart_product cp
        JOIN nile.product p ON cp.product_id = p.id
        JOIN nile.product_history ph ON p.id = ph.product_id
        JOIN (SELECT product_id, MAX(version_number) as max_version_number FROM nile.product_history GROUP BY product_id) x
          ON x.product_id = p.id AND x.max_version_number = ph.version_number
        WHERE cart_id = ${cartResult.rows[0].id};`;

    context.response.body = JSON.stringify(cartItems.rows);
  });
});

router.post("/v1/carts", async (context) => {
  const userId = context.request.headers.get("x-user-id");
  const { id, count } = await context.request.body({ type: "json" }).value;
  await useClient(async (client) => {
    await client.queryObject`
      INSERT INTO nile.cart_product (cart_id, product_id, count)
        SELECT id as cart_id, ${id} as product_id, ${count} as count
          FROM nile.cart WHERE user_id = ${userId};`;
  });

  context.response.body = JSON.stringify({});
});

router.delete("/v1/carts/:id", async (context) => {
  const id = context.params.id;
  const userId = context.request.headers.get("x-user-id");
  await useClient(async (client) => {
    await client.queryObject`
      DELETE FROM nile.cart_product
        WHERE product_id = ${id}
          AND cart_id in (SELECT id FROM nile.cart WHERE user_id = ${userId});`;
  });
  context.response.body = JSON.stringify({});
});

router.post("/v1/users", async (context) => {
  const id = crypto.randomUUID();
  const { name } = await context.request.body({ type: "json" }).value;

  if (name == null) {
    context.response.status = 400;
    context.response.body = JSON.stringify({
      errors: ["Parameter 'name' not found."],
    });
    return;
  }

  await useTransaction(async (transaction) => {
    await transaction.queryObject`
      INSERT INTO nile.user (id, name) VALUES(${id}, ${name});`;
    await transaction.queryObject`
      INSERT INTO nile.cart (id, user_id) VALUES(${id}, ${id});`;
  });

  context.response.body = JSON.stringify({ id, name });
});

router.post("/v1/orders", async (context) => {
  const id = crypto.randomUUID();
  const userId = context.request.headers.get("x-user-id");
  await useTransaction(async (transaction) => {
    // order テーブルに列を作る
    await transaction.queryObject`
      INSERT INTO nile.order (id, user_id, ordered_at) VALUES(${id}, ${userId}, NOW());`;
    // order_product テーブルにカートの商品をコピーする
    // その際に、商品の
    await transaction.queryObject`
      INSERT INTO nile.order_product(order_id, product_id, product_version, count)
        SELECT ${id} as order_id, ph.product_id, ph.version_number, count FROM nile.cart c
          JOIN nile.cart_product cp
            ON c.id = cp.cart_id
          JOIN nile.product_history ph
            ON cp.product_id = ph.product_id
          JOIN (SELECT product_id, MAX(version_number) as max_version_number FROM nile.product_history GROUP BY product_id) as max
            ON max.product_id = ph.product_id AND max.max_version_number = ph.version_number
          WHERE c.user_id = ${userId};`;
    await transaction.queryObject`
      DELETE FROM nile.cart_product
        WHERE cart_id in (SELECT id FROM nile.cart WHERE user_id = ${userId});`;
  });
  context.response.body = JSON.stringify({ id });
});

router.get("/v1/orders", async (context) => {
  const userId = context.request.headers.get("x-user-id");
  const results = await useClient((client) => {
    return client.queryObject<{
      id: string;
      productId: string;
      name: string;
      price: number;
    }>`
      SELECT id, op.product_id as productId, ph.name, ph.price FROM nile.order o
        JOIN nile.order_product op
          ON o.id = op.order_id
        JOIN nile.product_history ph
          ON op.product_id = ph.product_id
        WHERE o.user_id = ${userId};`;
  });
  const map = results.rows.reduce((prev, curr) => ({
    ...prev,
    [curr.id]: [...(prev[curr.id] ?? []), curr],
  }), {} as { [key: string]: typeof results.rows });
  context.response.body = JSON.stringify(
    Object.entries(map).map(([id, values]) => ({ id, values })),
  );
});

function log(context: Context, text: string) {
  console.log(`[${Date.now()}] [${context.state.id}]`, text);
}

function error(context: Context, text: string) {
  console.error(`[${Date.now()}] [${context.state.id}]`, text);
}

const Chars = "abcdefghijklmnopqrstuvwxyz1234567890";
function random(size: number) {
  return Array(size).fill(null).map(() =>
    Chars[Math.floor(Math.random() * Chars.length)]
  ).join("");
}

app.use(async (context, next) => {
  context.state.id = random(5);
  log(context, `${context.request.method.toUpperCase()} ${context.request.url}`);
  const start = Date.now();
  context.response.headers.set("content-type", "application/json");
  try {
    await next();
  } catch (e) {
    error(context, e);
    context.response.status = 500;
    context.response.headers.set("content-type", "text/plane");
    context.response.body = e;
  } finally {
    log(context, `Respond in ${Date.now() - start}ms.`);
  }
});

app.use(router.routes());

app.addEventListener("listen", () => console.log("Server started on 8080"));
app.listen({ port: 8080 });
