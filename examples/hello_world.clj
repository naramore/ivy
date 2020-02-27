(require '[datomic.api :as d])
(require '[datomic.client.api :as c])
(require '[clojure.pprint :refer [pprint]])
(require '[hara.object :as h])

(def txes
  [[{:db/ident :item/id
      :db/valueType :db.type/string
      :db/cardinality :db.cardinality/one
      :db/unique :db.unique/identity}
    {:db/ident :item/description
      :db/valueType :db.type/string
      :db/cardinality :db.cardinality/one
      :db/fulltext true}
    {:db/ident :item/count
      :db/valueType :db.type/long
      :db/cardinality :db.cardinality/one
      :db/index true}
    {:db/ident :tx/error
      :db/valueType :db.type/boolean
      :db/index true
      :db/cardinality :db.cardinality/one}
    {:db/id "datomic.tx"
      :db/txInstant #inst "2012"}]
    [{:item/id "DLC-042"
      :item/description "Dilitihium Crystals"
      :item/count 100}
    {:db/id "datomic.tx"
      :db/txInstant #inst "2013-01"}]
    [{:db/id [:item/id "DLC-042"]
      :item/count 250}
    {:db/id "datomic.tx"
      :db/txInstant #inst "2013-02"}]
    [{:db/id [:item/id "DLC-042"]
      :item/count 50}
    {:db/id "datomic.tx"
      :db/txInstant #inst "2014-02-28"}]
    [{:db/id [:item/id "DLC-042"]
      :item/count 9999}
    {:db/id "datomic.tx"
      :db/txInstant #inst "2014-04-01"
      :tx/error true}]
    [{:db/id [:item/id "DLC-042"]
      :item/count 100}
    {:db/id "datomic.tx"
      :db/txInstant #inst "2014-05-15"}]])

(def add-schema
  [{:db/ident :vm/cpu_count
    :db/valueType :db.type/long
    :db/cardinality :db.cardinality/one
    :db/index true}
   {:db/ident :vm/ram
    :db/valueType :db.type/long
    :db/cardinality :db.cardinality/one
    :db/index true}
   {:db/ident :vm/opaque_ref
    :db/valueType :db.type/string
    :db/cardinality :db.cardinality/one
    :db/unique :db.unique/identity}
   {:db/ident :host/vms
    :db/valueType :db.type/ref
    :db/cardinality :db.cardinality/many
    :db/isComponent true
    :db/index true}
   {:db/ident :host/cpu_count
    :db/valueType :db.type/long
    :db/cardinality :db.cardinality/one
    :db/index true}
   {:db/ident :host/ram
    :db/valueType :db.type/long
    :db/cardinality :db.cardinality/one
    :db/index true}
   {:db/ident :host/uri
    :db/valueType :db.type/uri
    :db/cardinality :db.cardinality/one
    :db/index true}
   {:db/ident :vm/disks
    :db/valueType :db.type/ref
    :db/cardinality :db.cardinality/many
    :db/isComponent true
    :db/index true}
   {:db/ident :disk/image
    :db/valueType :db.type/string
    :db/cardinality :db.cardinality/one
    :db/index true}])

(defn uuid [] (.toString (java.util.UUID/randomUUID)))

(defn add-disk [n] {:disk/image (uuid)})
(defn add-disks [d] (map add-disk (range d)))

(defn add-vm [n d]
  {:vm/cpu_count (+ (rand-int 4) 1)
   :vm/ram (+ (rand-int (* 8 1024)) 1024)
   :vm/opaque_ref (uuid)
   :vm/disks (add-disks d)})
(defn add-vms [v d] (map #(add-vm % d) (range v)))

(defn add-host [n v d]
  {:host/cpu_count (+ (rand-int 64) 1)
   :host/ram (+ (rand-int (* 128 1024)) 1024)
   :host/uri (new java.net.URI "http://clojuredocs.org/")
   :host/vms (add-vms v d)})
(defn add-hosts [h v d] (map #(add-host % v d) (range h)))

(defn db->map [db]
  (map (juxt identity #(% db))
        (keys (h/delegate db))))

(defn schema-info [db]
  (d/q '{:find [[(pull ?id [* {:db/valueType [:db/ident]}
                              {:db/cardinality [:db/ident]}
                              {:db/unique [:db/ident]}]) ...]]
          :where [[?e :db/ident ?id]
                  [_ :db.install/attribute ?e]]}
        db))

(def database-uri
  (str "datomic:free://localhost:4334/" (d/squuid)))

(def conn
  (do
    (d/create-database database-uri)
    (d/connect database-uri)))

(def empty-db (d/db conn))
(def empty-db-map (db->map empty-db))
(pprint empty-db-map)
(def empty-history (d/history empty-db))
(def empty-history-map (db->map empty-history))
(pprint empty-history-map)

(def results (map #(d/transact conn %) txes))
(map pprint results)
(def schema-results (d/transact conn add-schema))
(pprint schema-results)
(def host-results (d/transact conn (add-hosts 10 3 2)))
(pprint host-results)

; (d/shutdown true)
