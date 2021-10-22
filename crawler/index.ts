import puppeteer from "https://deno.land/x/puppeteer@9.0.1/mod.ts";
import { Client } from "https://deno.land/x/postgres@v0.13.0/mod.ts";

const browser = await puppeteer.launch();
const page = await browser.newPage();

const pages = ["computers", "toys", "videogames", "shoes", "jewelry", "sports", "hpc", "beauty"];

const results = [];
for (const link of pages) {
  await page.goto(`https://www.amazon.co.jp/gp/new-releases/${link}`);
  const titleEls = await page.$$(".zg-item-immersion");
  const list = await Promise.all(
    titleEls.map(it => it.evaluate(el => {
      const title = el.querySelector(".p13n-sc-truncated")
      const price = el.querySelector(".p13n-sc-price");
      return {
        name: title.getAttribute("title") ?? title.innerText,
        price: price?.innerText ?? "-1",
      };
    }))
  );
  results.push(list);
}

await browser.close();

const client = new Client({
  hostname: "localhost",
  port: 5432,
  database: "nile",
  user: "nile",
  password: "nile",
});

await client.connect();
for (const item of results.flat()) {
  const id = crypto.randomUUID();
  const transaction = client.createTransaction("");
  await transaction.begin();
  try {
    await client.queryObject`
      INSERT INTO nile.product (id, count) VALUES(${id}, 10)`;
    await client.queryObject`
      INSERT INTO nile.product_history (product_id, name, price, version_number) VALUES(${id}, ${item.name.slice(0, 100)}, ${item.price.replace(/,/g, "").replace(/￥/g, "")}, 0)`;
    await transaction.commit();
  } catch {
    await transaction.rollback();
  }
}

await client.end();
