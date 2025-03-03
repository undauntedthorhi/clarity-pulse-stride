;; Step Oracle Contract

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-steps (err u101))
(define-constant err-verification-cooldown (err u102))

(define-constant verification-cooldown u144) ;; ~24 hours in blocks

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
  (let (
    (last-verification (default-to { steps: u0, timestamp: u0, last-verified: u0 } 
      (map-get? verified-steps user)))
  )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> steps u0) err-invalid-steps)
    (asserts! (>= (- block-height (get last-verified last-verification)) verification-cooldown) 
      err-verification-cooldown)
    
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
