CREATE TABLE nile.product(
  id UUID,
  count INTEGER NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE nile.product_history(
  product_id UUID,
  version_number INT,
  -- 検索はESなどで行うため、インデックスをはるひつようはない
  name VARCHAR(100) NOT NULL,
  price INTEGER NOT NULL,
  PRIMARY KEY (product_id, version_number),
  FOREIGN KEY (product_id) REFERENCES nile.product(id)
);

CREATE TABLE nile.user(
  id UUID,
  name VARCHAR(100) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE nile.cart(
  id UUID,
  user_id UUID NOT NULL,
  PRIMARY KEY (id),
  UNIQUE (user_id),
  FOREIGN KEY (user_id) REFERENCES nile.user(id)
);

CREATE TABLE nile.cart_product(
  cart_id UUID NOT NULL,
  product_id UUID NOT NULL,
  count INTEGER NOT NULL,
  PRIMARY KEY (cart_id, product_id),
  -- PRIMARY KEY === UNIQUE + NOT NULL
  -- PRIMARY KEY インデックスが張られる
  -- UNIQUE インデックスが張られる
  -- インデックスはどちらも B-TREE
  -- インデックスが貼ってあれば、検索・ソートが早くなる
  FOREIGN KEY (product_id) REFERENCES nile.product(id),
  FOREIGN KEY (cart_id) REFERENCES nile.cart(id)
);

CREATE TABLE nile.order(
  id UUID,
  user_id UUID NOT NULL,
  ordered_at TIMESTAMP NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (user_id) REFERENCES nile.user(id)
);

CREATE TABLE nile.order_product(
  order_id UUID NOT NULL,
  product_id UUID NOT NULL,
  product_version INT NOT NULL,
  count INTEGER NOT NULL,
  PRIMARY KEY (order_id, product_id),
  FOREIGN KEY (product_id, product_version) REFERENCES nile.product_history(product_id, version_number),
  FOREIGN KEY (order_id) REFERENCES nile.order(id)
);

-- 在庫テーブルで、並列で購入しようとしたときに、足りなくならないように設計する


-- データを用意してみる
-- 商品を買っている人の注文の平均額などを出すなど








CREATE TABLE nile.delivery(
  id UUID,
  status VARCHAR(36) NOT NULL
  PRIMARY KEY (id)
);

CREATE TABLE pharaoh.user(
  id UUID,
  password VARCHAR(64) NOT NULL,
  PRIMARY KEY (id)
);
