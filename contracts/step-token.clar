;; Step Token Contract - SIP010
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token step-token)

(define-constant contract-owner tx-sender)

;; SIP010 Implementation
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  ;; Implementation
)

(define-public (mint (amount uint) (recipient principal))
  ;; Implementation
)

;; Read Only Functions
(define-read-only (get-name))
(define-read-only (get-symbol))
(define-read-only (get-decimals))
(define-read-only (get-balance (owner principal)))
(define-read-only (get-total-supply))
(define-read-only (get-token-uri))
