--
-- PostgreSQL database dump
--

-- Dumped from database version 13.4 (Debian 13.4-1.pgdg110+1)
-- Dumped by pg_dump version 13.4 (Debian 13.4-1.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: nile; Type: SCHEMA; Schema: -; Owner: nile
--

CREATE SCHEMA nile;


ALTER SCHEMA nile OWNER TO nile;

--
-- Name: pharaoh; Type: SCHEMA; Schema: -; Owner: nile
--

CREATE SCHEMA pharaoh;


ALTER SCHEMA pharaoh OWNER TO nile;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cart; Type: TABLE; Schema: nile; Owner: nile
--

CREATE TABLE nile.cart (
    id uuid NOT NULL,
    user_id uuid NOT NULL
);


ALTER TABLE nile.cart OWNER TO nile;

--
-- Name: cart_product; Type: TABLE; Schema: nile; Owner: nile
--

CREATE TABLE nile.cart_product (
    cart_id uuid NOT NULL,
    product_id uuid NOT NULL,
    count integer NOT NULL
);


ALTER TABLE nile.cart_product OWNER TO nile;

--
-- Name: delivery; Type: TABLE; Schema: nile; Owner: nile
--

CREATE TABLE nile.delivery (
    id uuid NOT NULL,
    status character varying(36) NOT NULL
);


ALTER TABLE nile.delivery OWNER TO nile;

--
-- Name: order; Type: TABLE; Schema: nile; Owner: nile
--

CREATE TABLE nile."order" (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    ordered_at timestamp without time zone NOT NULL
);


ALTER TABLE nile."order" OWNER TO nile;

--
-- Name: order_product; Type: TABLE; Schema: nile; Owner: nile
--

CREATE TABLE nile.order_product (
    order_id uuid NOT NULL,
    product_id uuid NOT NULL,
    product_version integer NOT NULL,
    count integer NOT NULL
);


ALTER TABLE nile.order_product OWNER TO nile;

--
-- Name: product; Type: TABLE; Schema: nile; Owner: nile
--

CREATE TABLE nile.product (
    id uuid NOT NULL
);


ALTER TABLE nile.product OWNER TO nile;

--
-- Name: product_history; Type: TABLE; Schema: nile; Owner: nile
--

CREATE TABLE nile.product_history (
    product_id uuid NOT NULL,
    version_number integer NOT NULL,
    name character varying(100) NOT NULL,
    price integer NOT NULL
);


ALTER TABLE nile.product_history OWNER TO nile;

--
-- Name: user; Type: TABLE; Schema: nile; Owner: nile
--

CREATE TABLE nile."user" (
    id uuid NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE nile."user" OWNER TO nile;

--
-- Name: user; Type: TABLE; Schema: pharaoh; Owner: nile
--

CREATE TABLE pharaoh."user" (
    id uuid NOT NULL,
    password character varying(64) NOT NULL
);


ALTER TABLE pharaoh."user" OWNER TO nile;

--
-- Data for Name: cart; Type: TABLE DATA; Schema: nile; Owner: nile
--

COPY nile.cart (id, user_id) FROM stdin;
\.


--
-- Data for Name: cart_product; Type: TABLE DATA; Schema: nile; Owner: nile
--

COPY nile.cart_product (cart_id, product_id, count) FROM stdin;
\.


--
-- Data for Name: delivery; Type: TABLE DATA; Schema: nile; Owner: nile
--

COPY nile.delivery (id, status) FROM stdin;
\.


--
-- Data for Name: order; Type: TABLE DATA; Schema: nile; Owner: nile
--

COPY nile."order" (id, user_id, ordered_at) FROM stdin;
b80a9761-4e27-4565-b09c-12410a00df04    7a1c925f-dfcb-49c1-a56b-2c677fa96a96    2021-09-30 05:40:53.32727
f0759461-f690-4530-b35d-8246933539d5    7a1c925f-dfcb-49c1-a56b-2c677fa96a96    2021-09-30 05:44:29.940515
0327fe25-6eca-4d40-9bfd-8071d1c19ea7    7a1c925f-dfcb-49c1-a56b-2c677fa96a96    2021-09-30 05:44:29.963153
\.


--
-- Data for Name: order_product; Type: TABLE DATA; Schema: nile; Owner: nile
--

COPY nile.order_product (order_id, product_id, product_version, count) FROM stdin;
b80a9761-4e27-4565-b09c-12410a00df04    99a8e0c2-0ed3-426d-911d-eca5e67918f8    1       1
0327fe25-6eca-4d40-9bfd-8071d1c19ea7    99a8e0c2-0ed3-426d-911d-eca5e67918f8    1       1
0327fe25-6eca-4d40-9bfd-8071d1c19ea7    699140cc-bd30-412f-a574-dc1272a48ba7    0       1
f0759461-f690-4530-b35d-8246933539d5    6e9bf5c3-3da3-4e00-b912-68b9fe6d24a1    0       2
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: nile; Owner: nile
--

INSERT INTO nile.product VALUES
('99a8e0c2-0ed3-426d-911d-eca5e67918f8'),
('6e9bf5c3-3da3-4e00-b912-68b9fe6d24a1'),
('699140cc-bd30-412f-a574-dc1272a48ba7');


--
-- Data for Name: product_history; Type: TABLE DATA; Schema: nile; Owner: nile
--

INSERT INTO nile.product_history (product_id, version_number, name, price) VALUES
('99a8e0c2-0ed3-426d-911d-eca5e67918f8', 0, 'iPhone 13 128GB', 100000),
('6e9bf5c3-3da3-4e00-b912-68b9fe6d24a1', 0, 'iPhone 13 256GB', 120000),
('699140cc-bd30-412f-a574-dc1272a48ba7', 0, 'iPhone 13 1TB', 170000),
('99a8e0c2-0ed3-426d-911d-eca5e67918f8', 1, 'iPhone 13 128GB', 98000);


--
-- Data for Name: user; Type: TABLE DATA; Schema: nile; Owner: nile
--

COPY nile."user" (id, name) FROM stdin;
7a1c925f-dfcb-49c1-a56b-2c677fa96a96    test1
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: pharaoh; Owner: nile
--

COPY pharaoh."user" (id, password) FROM stdin;
\.


--
-- Name: cart cart_pkey; Type: CONSTRAINT; Schema: nile; Owner: nile
--

ALTER TABLE ONLY nile.cart
    ADD CONSTRAINT cart_pkey PRIMARY KEY (id);


--
-- Name: cart_product cart_product_pkey; Type: CONSTRAINT; Schema: nile; Owner: nile
--

ALTER TABLE ONLY nile.cart_product
    ADD CONSTRAINT cart_product_pkey PRIMARY KEY (cart_id, product_id);


--
-- Name: cart cart_user_id_key; Type: CONSTRAINT; Schema: nile; Owner: nile
--

ALTER TABLE ONLY nile.cart
    ADD CONSTRAINT cart_user_id_key UNIQUE (user_id);


--
-- Name: delivery delivery_pkey; Type: CONSTRAINT; Schema: nile; Owner: nile
--

ALTER TABLE ONLY nile.delivery
    ADD CONSTRAINT delivery_pkey PRIMARY KEY (id);


--
-- Name: order order_pkey; Type: CONSTRAINT; Schema: nile; Owner: nile
--

ALTER TABLE ONLY nile."order"
    ADD CONSTRAINT order_pkey PRIMARY KEY (id);


--
-- Name: order_product order_product_pkey; Type: CONSTRAINT; Schema: nile; Owner: nile
--

ALTER TABLE ONLY nile.order_product
    ADD CONSTRAINT order_product_pkey PRIMARY KEY (order_id, product_id);


--
-- Name: product_history product_history_pkey; Type: CONSTRAINT; Schema: nile; Owner: nile
--

ALTER TABLE ONLY nile.product_history
    ADD CONSTRAINT product_history_pkey PRIMARY KEY (product_id, version_number);


--
-- Name: product product_pkey; Type: CONSTRAINT; Schema: nile; Owner: nile
--

ALTER TABLE ONLY nile.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: nile; Owner: nile
--

ALTER TABLE ONLY nile."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: pharaoh; Owner: nile
--

ALTER TABLE ONLY pharaoh."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: cart_product cart_product_cart_id_fkey; Type: FK CONSTRAINT; Schema: nile; Owner: nile
--

ALTER TABLE ONLY nile.cart_product
    ADD CONSTRAINT cart_product_cart_id_fkey FOREIGN KEY (cart_id) REFERENCES nile.cart(id);


--
-- Name: cart_product cart_product_product_id_fkey; Type: FK CONSTRAINT; Schema: nile; Owner: nile
--

ALTER TABLE ONLY nile.cart_product
    ADD CONSTRAINT cart_product_product_id_fkey FOREIGN KEY (product_id) REFERENCES nile.product(id);


--
-- Name: cart cart_user_id_fkey; Type: FK CONSTRAINT; Schema: nile; Owner: nile
--

ALTER TABLE ONLY nile.cart
    ADD CONSTRAINT cart_user_id_fkey FOREIGN KEY (user_id) REFERENCES nile."user"(id);


--
-- Name: order_product order_product_order_id_fkey; Type: FK CONSTRAINT; Schema: nile; Owner: nile
--

ALTER TABLE ONLY nile.order_product
    ADD CONSTRAINT order_product_order_id_fkey FOREIGN KEY (order_id) REFERENCES nile."order"(id);


--
-- Name: order_product order_product_product_id_product_version_fkey; Type: FK CONSTRAINT; Schema: nile; Owner: nile
--

ALTER TABLE ONLY nile.order_product
    ADD CONSTRAINT order_product_product_id_product_version_fkey FOREIGN KEY (product_id, product_version) REFERENCES nile.product_history(product_id, version_number);


--
-- Name: order order_user_id_fkey; Type: FK CONSTRAINT; Schema: nile; Owner: nile
--

ALTER TABLE ONLY nile."order"
    ADD CONSTRAINT order_user_id_fkey FOREIGN KEY (user_id) REFERENCES nile."user"(id);


--
-- Name: product_history product_history_product_id_fkey; Type: FK CONSTRAINT; Schema: nile; Owner: nile
--

ALTER TABLE ONLY nile.product_history
    ADD CONSTRAINT product_history_product_id_fkey FOREIGN KEY (product_id) REFERENCES nile.product(id);


--
-- PostgreSQL database dump complete
--
