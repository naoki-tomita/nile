-- 商品の個数を保存しておくのを忘れていた
ALTER TABLE nile.product ADD COLUMN count INTEGER NOT NULL DEFAULT 0;
ALTER TABLE nile.product ALTER COLUMN count DROP DEFAULT;
