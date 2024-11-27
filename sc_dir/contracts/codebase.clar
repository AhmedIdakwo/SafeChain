;; SafeChain Escrow Contract
;; Provides a secure, trustless escrow service with built-in dispute resolution

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u1))
(define-constant ERR-INVALID-STATE (err u2))
(define-constant ERR-INSUFFICIENT-FUNDS (err u3))
(define-constant ERR-DISPUTE-NOT-FOUND (err u4))

;; Escrow States
(define-constant STATE-INITIATED u0)
(define-constant STATE-FUNDED u1)
(define-constant STATE-COMPLETED u2)
(define-constant STATE-DISPUTED u3)
(define-constant STATE-REFUNDED u4)

;; Escrow Structure
(define-map escrows {
    id: uint,
    seller: principal,
    buyer: principal,
    amount: uint,
    state: uint,
    dispute-resolver: (optional principal),
    dispute-reason: (optional (string-utf8 200))
})

;; Tracking next escrow ID
(define-data-var next-escrow-id uint u0)

;; Create a new escrow
(define-public (create-escrow (seller principal) (amount uint))
    (begin
        ;; Validate seller is not contract owner
        (asserts! (not (is-eq seller CONTRACT-OWNER)) ERR-UNAUTHORIZED)
        
        ;; Increment escrow ID
        (let ((escrow-id (var-get next-escrow-id)))
            (var-set next-escrow-id (+ escrow-id u1))
            
            ;; Create escrow map entry
            (map-set escrows 
                {
                    id: escrow-id, 
                    seller: seller, 
                    buyer: tx-sender, 
                    amount: amount, 
                    state: STATE-INITIATED,
                    dispute-resolver: none,
                    dispute-reason: none
                }
            )
            
            (ok escrow-id)
        )
    )
)

;; Fund the escrow
(define-public (fund-escrow (escrow-id uint))
    (let ((escrow (unwrap! (map-get? escrows {id: escrow-id}) ERR-DISPUTE-NOT-FOUND)))
        (asserts! (is-eq (get state escrow) STATE-INITIATED) ERR-INVALID-STATE)
        (asserts! (is-eq (get buyer escrow) tx-sender) ERR-UNAUTHORIZED)
        
        ;; Update escrow state to funded
        (map-set escrows 
            {id: escrow-id} 
            (merge escrow {state: STATE-FUNDED})
        )
        
        (ok true)
    )
)

;; Complete escrow and release funds to seller
(define-public (complete-escrow (escrow-id uint))
    (let ((escrow (unwrap! (map-get? escrows {id: escrow-id}) ERR-DISPUTE-NOT-FOUND)))
        (asserts! (is-eq (get state escrow) STATE-FUNDED) ERR-INVALID-STATE)
        (asserts! (is-eq (get buyer escrow) tx-sender) ERR-UNAUTHORIZED)
        
        ;; Update escrow state to completed
        (map-set escrows 
            {id: escrow-id} 
            (merge escrow {state: STATE-COMPLETED})
        )
        
        (ok true)
    )
)

;; Initiate a dispute
(define-public (initiate-dispute 
    (escrow-id uint) 
    (dispute-reason (string-utf8 200))
    (dispute-resolver principal)
)
    (let ((escrow (unwrap! (map-get? escrows {id: escrow-id}) ERR-DISPUTE-NOT-FOUND)))
        (asserts! (is-eq (get state escrow) STATE-FUNDED) ERR-INVALID-STATE)
        (asserts! (is-eq (get buyer escrow) tx-sender) ERR-UNAUTHORIZED)
        
        ;; Update escrow state to disputed
        (map-set escrows 
            {id: escrow-id} 
            (merge escrow {
                state: STATE-DISPUTED,
                dispute-resolver: (some dispute-resolver),
                dispute-reason: (some dispute-reason)
            })
        )
        
        (ok true)
    )
)

;; Resolve dispute
(define-public (resolve-dispute 
    (escrow-id uint) 
    (refund-to-buyer bool)
)
    (let ((escrow (unwrap! (map-get? escrows {id: escrow-id}) ERR-DISPUTE-NOT-FOUND)))
        (asserts! (is-eq (get state escrow) STATE-DISPUTED) ERR-INVALID-STATE)
        (asserts! (is-eq (get dispute-resolver escrow) (some tx-sender)) ERR-UNAUTHORIZED)
        
        ;; Determine final state based on resolution
        (let ((new-state (if refund-to-buyer STATE-REFUNDED STATE-COMPLETED)))
            (map-set escrows 
                {id: escrow-id} 
                (merge escrow {state: new-state})
            )
            
            (ok true)
        )
    )
)

;; Read-only function to check escrow status
(define-read-only (get-escrow-status (escrow-id uint))
    (map-get? escrows {id: escrow-id})
)