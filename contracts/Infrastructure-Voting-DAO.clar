
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_NOT_MEMBER (err u101))
(define-constant ERR_ALREADY_MEMBER (err u102))
(define-constant ERR_PROPOSAL_NOT_FOUND (err u103))
(define-constant ERR_PROPOSAL_EXPIRED (err u104))
(define-constant ERR_ALREADY_VOTED (err u105))
(define-constant ERR_INSUFFICIENT_FUNDS (err u106))
(define-constant ERR_PROPOSAL_NOT_ACTIVE (err u107))
(define-constant ERR_MILESTONE_NOT_FOUND (err u108))
(define-constant ERR_INVALID_AMOUNT (err u109))
(define-constant ERR_PROPOSAL_NOT_APPROVED (err u110))
(define-constant ERR_PROPOSAL_NOT_EXPIRED (err u111))
(define-constant ERR_MILESTONE_COMPLETED (err u112))
(define-constant ERR_INSUFFICIENT_VOTES (err u113))

(define-data-var next-proposal-id uint u1)
(define-data-var next-milestone-id uint u1)
(define-data-var total-members uint u0)
(define-data-var dao-treasury uint u0)
(define-data-var voting-period uint u1440)
(define-data-var quorum-threshold uint u51)

(define-map members principal bool)
(define-map member-contributions principal uint)
(define-map proposals
  uint
  {
    id: uint,
    title: (string-ascii 100),
    description: (string-ascii 500),
    budget: uint,
    proposer: principal,
    start-height: uint,
    end-height: uint,
    yes-votes: uint,
    no-votes: uint,
    total-voters: uint,
    status: (string-ascii 20),
    funds-released: uint
  }
)

(define-map votes { proposal-id: uint, voter: principal } bool)
(define-map milestones
  uint
  {
    id: uint,
    proposal-id: uint,
    description: (string-ascii 300),
    amount: uint,
    completed: bool,
    approved-votes: uint,
    rejected-votes: uint
  }
)

(define-public (join-dao)
  (let ((sender tx-sender))
    (asserts! (not (is-member sender)) ERR_ALREADY_MEMBER)
    (map-set members sender true)
    (var-set total-members (+ (var-get total-members) u1))
    (ok true)
  )
)

(define-public (contribute-funds (amount uint))
  (let ((sender tx-sender))
    (asserts! (is-member sender) ERR_NOT_MEMBER)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (try! (stx-transfer? amount sender (as-contract tx-sender)))
    (map-set member-contributions sender (+ (get-member-contribution sender) amount))
    (var-set dao-treasury (+ (var-get dao-treasury) amount))
    (ok true)
  )
)

(define-public (create-proposal (title (string-ascii 100)) (description (string-ascii 500)) (budget uint))
  (let (
    (proposal-id (var-get next-proposal-id))
    (sender tx-sender)
    (current-height stacks-block-height)
  )
    (asserts! (is-member sender) ERR_NOT_MEMBER)
    (asserts! (> budget u0) ERR_INVALID_AMOUNT)
    (asserts! (<= budget (var-get dao-treasury)) ERR_INSUFFICIENT_FUNDS)
    (map-set proposals proposal-id {
      id: proposal-id,
      title: title,
      description: description,
      budget: budget,
      proposer: sender,
      start-height: current-height,
      end-height: (+ current-height (var-get voting-period)),
      yes-votes: u0,
      no-votes: u0,
      total-voters: u0,
      status: "active",
      funds-released: u0
    })
    (var-set next-proposal-id (+ proposal-id u1))
    (ok proposal-id)
  )
)

(define-public (vote-on-proposal (proposal-id uint) (support bool))
  (let (
    (voter tx-sender)
    (proposal (unwrap! (map-get? proposals proposal-id) ERR_PROPOSAL_NOT_FOUND))
    (current-height stacks-block-height)
    (vote-key { proposal-id: proposal-id, voter: voter })
  )
    (asserts! (is-member voter) ERR_NOT_MEMBER)
    (asserts! (is-none (map-get? votes vote-key)) ERR_ALREADY_VOTED)
    (asserts! (<= current-height (get end-height proposal)) ERR_PROPOSAL_EXPIRED)
    (asserts! (is-eq (get status proposal) "active") ERR_PROPOSAL_NOT_ACTIVE)
    
    (map-set votes vote-key support)
    (map-set proposals proposal-id
      (merge proposal {
        yes-votes: (if support (+ (get yes-votes proposal) u1) (get yes-votes proposal)),
        no-votes: (if support (get no-votes proposal) (+ (get no-votes proposal) u1)),
        total-voters: (+ (get total-voters proposal) u1)
      })
    )
    (ok true)
  )
)

(define-public (finalize-proposal (proposal-id uint))
  (let (
    (proposal (unwrap! (map-get? proposals proposal-id) ERR_PROPOSAL_NOT_FOUND))
    (current-height stacks-block-height)
    (total-votes (get total-voters proposal))
    (yes-votes (get yes-votes proposal))
    (vote-percentage (if (> total-votes u0) (* (/ yes-votes total-votes) u100) u0))
    (quorum-met (>= (* total-votes u100) (* (var-get total-members) u30)))
    (proposal-passed (and quorum-met (>= vote-percentage (var-get quorum-threshold))))
  )
    (asserts! (> current-height (get end-height proposal)) ERR_PROPOSAL_NOT_EXPIRED)
    (asserts! (is-eq (get status proposal) "active") ERR_PROPOSAL_NOT_ACTIVE)
    
    (map-set proposals proposal-id
      (merge proposal {
        status: (if proposal-passed "approved" "rejected")
      })
    )
    (ok proposal-passed)
  )
)

(define-public (create-milestone (proposal-id uint) (description (string-ascii 300)) (amount uint))
  (let (
    (milestone-id (var-get next-milestone-id))
    (proposal (unwrap! (map-get? proposals proposal-id) ERR_PROPOSAL_NOT_FOUND))
  )
    (asserts! (is-eq tx-sender (get proposer proposal)) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status proposal) "approved") ERR_PROPOSAL_NOT_APPROVED)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (<= (+ (get funds-released proposal) amount) (get budget proposal)) ERR_INSUFFICIENT_FUNDS)
    
    (map-set milestones milestone-id {
      id: milestone-id,
      proposal-id: proposal-id,
      description: description,
      amount: amount,
      completed: false,
      approved-votes: u0,
      rejected-votes: u0
    })
    (var-set next-milestone-id (+ milestone-id u1))
    (ok milestone-id)
  )
)

(define-public (vote-milestone (milestone-id uint) (approve bool))
  (let (
    (voter tx-sender)
    (milestone (unwrap! (map-get? milestones milestone-id) ERR_MILESTONE_NOT_FOUND))
  )
    (asserts! (is-member voter) ERR_NOT_MEMBER)
    (asserts! (not (get completed milestone)) ERR_MILESTONE_COMPLETED)
    
    (map-set milestones milestone-id
      (merge milestone {
        approved-votes: (if approve (+ (get approved-votes milestone) u1) (get approved-votes milestone)),
        rejected-votes: (if approve (get rejected-votes milestone) (+ (get rejected-votes milestone) u1))
      })
    )
    (ok true)
  )
)

(define-public (release-milestone-funds (milestone-id uint))
  (let (
    (milestone (unwrap! (map-get? milestones milestone-id) ERR_MILESTONE_NOT_FOUND))
    (proposal (unwrap! (map-get? proposals (get proposal-id milestone)) ERR_PROPOSAL_NOT_FOUND))
    (approved-votes (get approved-votes milestone))
    (total-votes (+ approved-votes (get rejected-votes milestone)))
    (approval-rate (if (> total-votes u0) (* (/ approved-votes total-votes) u100) u0))
    (funds-approved (>= approval-rate (var-get quorum-threshold)))
  )
    (asserts! funds-approved ERR_INSUFFICIENT_VOTES)
    (asserts! (not (get completed milestone)) ERR_MILESTONE_COMPLETED)
    (asserts! (<= (get amount milestone) (var-get dao-treasury)) ERR_INSUFFICIENT_FUNDS)
    
    (try! (as-contract (stx-transfer? (get amount milestone) tx-sender (get proposer proposal))))
    (map-set milestones milestone-id (merge milestone { completed: true }))
    (map-set proposals (get proposal-id milestone)
      (merge proposal { funds-released: (+ (get funds-released proposal) (get amount milestone)) })
    )
    (var-set dao-treasury (- (var-get dao-treasury) (get amount milestone)))
    (ok true)
  )
)

(define-public (withdraw-contribution (amount uint))
  (let (
    (sender tx-sender)
    (contribution (get-member-contribution sender))
  )
    (asserts! (is-member sender) ERR_NOT_MEMBER)
    (asserts! (<= amount contribution) ERR_INSUFFICIENT_FUNDS)
    (asserts! (<= amount (var-get dao-treasury)) ERR_INSUFFICIENT_FUNDS)
    
    (try! (as-contract (stx-transfer? amount tx-sender sender)))
    (map-set member-contributions sender (- contribution amount))
    (var-set dao-treasury (- (var-get dao-treasury) amount))
    (ok true)
  )
)

(define-read-only (is-member (user principal))
  (default-to false (map-get? members user))
)

(define-read-only (get-member-contribution (user principal))
  (default-to u0 (map-get? member-contributions user))
)

(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals proposal-id)
)

(define-read-only (get-milestone (milestone-id uint))
  (map-get? milestones milestone-id)
)

(define-read-only (get-vote (proposal-id uint) (voter principal))
  (map-get? votes { proposal-id: proposal-id, voter: voter })
)

(define-read-only (get-dao-stats)
  {
    total-members: (var-get total-members),
    dao-treasury: (var-get dao-treasury),
    voting-period: (var-get voting-period),
    quorum-threshold: (var-get quorum-threshold),
    next-proposal-id: (var-get next-proposal-id),
    next-milestone-id: (var-get next-milestone-id)
  }
)

(define-read-only (get-proposal-status (proposal-id uint))
  (let ((proposal (map-get? proposals proposal-id)))
    (match proposal
      prop (get status prop)
      "not-found"
    )
  )
)
