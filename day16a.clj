(defn abs [n]
  (if (neg? n)
    (- n)
    n))

(def base-pattern [0 1 0 -1])

(defn pattern [n]
  (drop 1 (cycle (mapcat #(repeat n %) base-pattern))))

(defn phase [lst]
  (map #(mod (abs (reduce + (map * lst (pattern (inc %))))) 10)
       (range (count lst))))

(let [lst (map #(Integer/parseInt (str %)) (read-line))
      result (nth (iterate phase lst) 100)]
  (println (clojure.string/join (take 8 result))))
