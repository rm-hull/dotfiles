{
 :user {
  :plugins [
    [cider/cider-nrepl "0.15.1"]
    [lein-cljfmt "0.5.7"]
    [lein-pprint "1.1.2"]
    [lein-assoc "0.1.0"]
    [lein-cloverage "1.0.9"]
    [venantius/ultra "0.5.1"]
    [jonase/eastwood "0.2.5" :exclusions [org.clojure/clojure]]
    [lein-expectations "0.0.8"]
    [lein-autoexpect "1.9.0"]
    [com.jakemccrary/lein-test-refresh "0.14.0"]
    [lein-ancient "0.6.14"]
    [lein-nvd "0.4.0"]]
  :repl-options {
    :timeout 300000}
  :aliases {
    "slamhound" ["run" "-m" "slam.hound"]}
  :dependencies [
    [slamhound "1.5.5"]] } }
