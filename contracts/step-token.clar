;; Step Token Contract - SIP010
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(define-fungible-token step-token)

(define-constant contract-owner tx-sender)
(define-constant token-name "StepToken")
(define-constant token-symbol "STEP")
(define-constant token-decimals u6)

;; SIP010 Implementation
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) (err u1))
    (asserts! (> amount u0) (err u2))
    (match (ft-transfer? step-token amount sender recipient)
      success (ok success)
      error (err u3))
  )
)

(define-read-only (get-name)
  (ok token-name))

(define-read-only (get-symbol)
  (ok token-symbol))

(define-read-only (get-decimals)
  (ok token-decimals))

(define-read-only (get-balance (owner principal))
  (ok (ft-get-balance step-token owner)))

(define-read-only (get-total-supply)
  (ok (ft-get-supply step-token)))

(define-read-only (get-token-uri)
  (ok none))
