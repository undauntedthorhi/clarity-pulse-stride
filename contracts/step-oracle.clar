;; Step Oracle Contract

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-steps (err u101))

;; Data Maps
(define-map verified-steps
  principal
  {
    steps: uint,
    timestamp: uint,
    last-verified: uint
  }
)

;; Public Functions
(define-public (verify-steps (user principal) (steps uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> steps u0) err-invalid-steps)
    
    (map-set verified-steps user
      {
        steps: steps,
        timestamp: block-height,
        last-verified: block-height
      }
    )
    (ok true)
  )
)

(define-read-only (get-verified-steps (user principal))
  (map-get? verified-steps user)
)
