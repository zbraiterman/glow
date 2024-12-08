#!/usr/bin/env gxi
;; This is the main build file for Glow. Invoke it using
;;     ./build.ss [cmd]
;; where [cmd] is typically left empty (same as "compile")
;; Note that may you need to first:
;;     gxpkg install github.com/fare/gerbil-ethereum
;; See HACKING.md for details.

(import :std/cli/multicall :std/misc/process :clan/base :clan/building)

(def (files)
  (!> (all-gerbil-modules)
      (cut filter (lambda (module-name) (not (string-prefix? "dep" module-name))) <>)
      (cut cons "t/common.ss" <>)
      ;; TODO reenable when gerbil libp2p is fixed:
      (cut remove-build-file <> "runtime/pb/private-key.ss")
      (cut remove-build-file <> "runtime/pb/private-key.ss")
      ;; TODO enable the below after we get our package story updated to deal with it:
      ;;(cut cons [exe: "main.ss" bin: "glowrun" "-ld-options" "-lleveldb -lsecp256k1"] <>)
      (cut add-build-options <> "compiler/parse/expressions" "-cc-options" "-U___SINGLE_HOST")))

(init-build-environment!
 name: "Glow"
 ;; NB: missing versions for drewc/smug-gerbil and vyzo/libp2p
 deps: '("clan" "clan/crypto" "clan/poo" "clan/persist" "clan/ethereum")
 spec: files)

;; TODO: create version files for all overridden dependencies, too
(define-entry-point (nix)
  (help: "Build using nix-build" getopt: [])
  (create-version-file)
  (run-process ["nix-build"] stdin-redirection: #f stdout-redirection: #f)
  (void))

(def glow-packages
  [(map (cut string-append <> "-unstable") '("gambit" "gerbil")) ...
   (map (cut string-append "gerbilPackages-unstable." <>)
        '("gerbil-utils" "gerbil-poo" "gerbil-crypto" "gerbil-persist" "gerbil-ethereum"
          "gerbil-libp2p" "smug-gerbil" "ftw")) ...
   "glow-lang"])
