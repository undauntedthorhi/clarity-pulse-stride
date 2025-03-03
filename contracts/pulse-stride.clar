;; PulseStride Main Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-challenge (err u101))
(define-constant err-already-joined (err u102))
(define-constant err-invalid-stake (err u103))
(define-constant err-challenge-expired (err u104))
(define-constant err-challenge-incomplete (err u105))
(define-constant err-already-completed (err u106))

;; Data Variables
(define-data-var challenge-counter uint u0)

;; Data Maps
(define-map challenges
  uint 
  {
    creator: principal,
    start-time: uint,
    end-time: uint,
    target-steps: uint,
    stake-amount: uint,
    status: (string-ascii 10)
  }
)

(define-map challenge-participants 
  { challenge-id: uint, participant: principal }
  {
    steps: uint,
    completed: bool,
    staked: uint,
    stake-returned: bool
  }
)

;; Public Functions
(define-public (create-challenge (duration uint) (target-steps uint) (stake-amount uint))
  (let
    (
      (challenge-id (var-get challenge-counter))
      (current-time block-height)
    )
    (asserts! (> duration u0) err-invalid-challenge)
    (asserts! (> target-steps u0) err-invalid-challenge)
    (asserts! (>= stake-amount u0) err-invalid-stake)
    
    (map-set challenges challenge-id
      {
        creator: tx-sender,
        start-time: current-time,
        end-time: (+ current-time duration),
        target-steps: target-steps,
        stake-amount: stake-amount,
        status: "active"
      }
    )
    (var-set challenge-counter (+ challenge-id u1))
    (ok challenge-id)
  )
)

(define-public (join-challenge (challenge-id uint))
  (let (
    (challenge (unwrap! (map-get? challenges challenge-id) err-invalid-challenge))
    (current-time block-height)
  )
    (asserts! (<= current-time (get end-time challenge)) err-challenge-expired)
    (asserts! (is-none (map-get? challenge-participants { challenge-id: challenge-id, participant: tx-sender })) err-already-joined)
    
    (try! (stx-transfer? (get stake-amount challenge) tx-sender (as-contract tx-sender)))
    
    (map-set challenge-participants
      { challenge-id: challenge-id, participant: tx-sender }
      {
        steps: u0,
        completed: false,
        staked: (get stake-amount challenge),
        stake-returned: false
      }
    )
    (ok true)
  )
)

(define-public (complete-challenge (challenge-id uint))
  (let (
    (challenge (unwrap! (map-get? challenges challenge-id) err-invalid-challenge))
    (participant-data (unwrap! (map-get? challenge-participants { challenge-id: challenge-id, participant: tx-sender }) err-invalid-challenge))
    (current-time block-height)
  )
    (asserts! (>= (get steps participant-data) (get target-steps challenge)) err-challenge-incomplete)
    (asserts! (not (get completed participant-data)) err-already-completed)
    
    ;; Return stake to participant
    (try! (as-contract (stx-transfer? (get staked participant-data) tx-sender tx-sender)))
    
    (map-set challenge-participants
      { challenge-id: challenge-id, participant: tx-sender }
      (merge participant-data { completed: true, stake-returned: true })
    )
    (ok true)
  )
)
