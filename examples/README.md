## Quickstart

In one terminal, run the transactor:

```sh
docker run -it --rm \
  -p 127.0.0.1:4334-4336:4334-4336 \
  gordonstratton/datomic-free-transactor:latest
```

Wherever you use `datomic.api/connect`, you can now connect to your running
transactor:

```clojure
(require '[datomic.api :as d])

(def conn
  (d/connect "datomic:free://localhost:4334/my-database"))

;; Or, if you have the Datomic Pro client library, you can use the `dev`
;; protocol:
;(def conn
;  (d/connect "datomic:dev://localhost:4334/my-database"))
```
