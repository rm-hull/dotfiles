{:user
  {:plugins [
    [lein-pprint "1.1.1"]
    [lein-assoc "0.1.0"]
    [jonase/eastwood "0.0.2"]
    [lein-expectations "0.0.7"]
    [lein-autoexpect "0.2.5"]
    [lein-ancient "0.5.4"]]
  :aliases {"slamhound" ["run" "-m" "slam.hound"]}
  :dependencies [[slamhound "RELEASE"]
                 ;[clj-stacktrace "0.2.5"]
                 ]
;  :injections [(let [orig (ns-resolve (doto 'clojure.stacktrace require)
;                                       'print-cause-trace)
;                      new (ns-resolve (doto 'clj-stacktrace.repl require)
;                                      'pst)]
;                 (alter-var-root orig (constantly @new)))]
   }
 }
