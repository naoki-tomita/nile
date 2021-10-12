nile=# SELECT * FROM product_history;
 99a8e0c2-0ed3-426d-911d-eca5e67918f8 |              0 | iPhone 13 128GB | 100000
 6e9bf5c3-3da3-4e00-b912-68b9fe6d24a1 |              0 | iPhone 13 256GB | 120000
 699140cc-bd30-412f-a574-dc1272a48ba7 |              0 | iPhone 13 1TB   | 170000
 99a8e0c2-0ed3-426d-911d-eca5e67918f8 |              1 | iPhone 13 128GB |  98000

SELECT * FROM product_history;
 99a8e0c2-0ed3-426d-911d-eca5e67918f8 |              0,1 | iPhone 13 128GB,iPhone 13 128GB | 100000,98000
 6e9bf5c3-3da3-4e00-b912-68b9fe6d24a1 |              0 | iPhone 13 256GB | 120000
 699140cc-bd30-412f-a574-dc1272a48ba7 |              0 | iPhone 13 1TB   | 170000


-- 商品一覧を出すクエリ
SELECT ph.* FROM product_history ph
JOIN (
  SELECT product_id, MAX(version_number) as max_version_number FROM product_history group by product_id
) pv ON ph.product_id = pv.product_id AND ph.version_number = pv.max_version_number;

INSERT INTO "order" VALUES(gen_random_uuid(), '7a1c925f-dfcb-49c1-a56b-2c677fa96a96', now());
INSERT INTO "order" VALUES(gen_random_uuid(), '7a1c925f-dfcb-49c1-a56b-2c677fa96a96', now());
INSERT INTO "order" VALUES(gen_random_uuid(), '7a1c925f-dfcb-49c1-a56b-2c677fa96a96', now());
INSERT INTO nile.order_product VALUES(
  'b80a9761-4e27-4565-b09c-12410a00df04',
  '99a8e0c2-0ed3-426d-911d-eca5e67918f8',
  (SELECT MAX(version_number) FROM product_history WHERE product_id = '99a8e0c2-0ed3-426d-911d-eca5e67918f8'),
  1);

INSERT INTO nile.order_product VALUES(
  'f0759461-f690-4530-b35d-8246933539d5',
  '6e9bf5c3-3da3-4e00-b912-68b9fe6d24a1',
  (SELECT MAX(version_number) FROM product_history WHERE product_id = '6e9bf5c3-3da3-4e00-b912-68b9fe6d24a1'),
  2);

INSERT INTO nile.order_product VALUES(
  '0327fe25-6eca-4d40-9bfd-8071d1c19ea7',
  '99a8e0c2-0ed3-426d-911d-eca5e67918f8',
  (SELECT MAX(version_number) FROM product_history WHERE product_id = '99a8e0c2-0ed3-426d-911d-eca5e67918f8'),
  1);

INSERT INTO nile.order_product VALUES(
  '0327fe25-6eca-4d40-9bfd-8071d1c19ea7',
  '699140cc-bd30-412f-a574-dc1272a48ba7',
  (SELECT MAX(version_number) FROM product_history WHERE product_id = '699140cc-bd30-412f-a574-dc1272a48ba7'),
  1);

SELECT o.id, u.name, ph.name, ph.price, op.count FROM nile.order_product op
JOIN nile.order o ON o.id = op.order_id
JOIN nile.user u ON o.user_id = u.id
JOIN nile.product_history ph ON op.product_id = ph.product_id AND op.product_version = ph.version_number;


SELECT * FROM nile.order o
JOIN (SELECT ARRAY_CONCAT(product_id) FROM nile.order_product GROUP BY order_id) op;

-- array_to_string(ARRAY(SELECT unnest(array_agg(name))), ',')
SELECT order_id
FROM nile.order_product GROUP BY order_id HAVING
  ARRAY_AGG(product_id) IN ('699140cc-bd30-412f-a574-dc1272a48ba7');


select a.order_id
from
(select order_id
from nile.order_product where product_id = '699140cc-bd30-412f-a574-dc1272a48ba7') a
join
(select order_id
from nile.order_product where product_id = '99a8e0c2-0ed3-426d-911d-eca5e67918f8') b
on a.order_id = b.order_id
