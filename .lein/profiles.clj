{
 :user {
  :plugins [
    [cider/cider-nrepl "0.23.0"]
    [lein-cljfmt "0.6.6"]
    [lein-pprint "1.3.2"]
    [lein-assoc "0.1.0"]
    [lein-cloverage "1.1.2"]
    [jonase/eastwood "0.2.5" :exclusions [org.clojure/clojure]]
    [lein-expectations "0.0.8"]
    [lein-autoexpect "1.9.0"]
    [com.jakemccrary/lein-test-refresh "0.14.0"]
    [lein-ancient "0.6.15"]
    [lein-nvd "0.6.0"]]
  :repl-options {
    :timeout 300000}
  :aliases {
    "slamhound" ["run" "-m" "slam.hound"]}
  :dependencies [
    [slamhound "1.5.5"]] } }
