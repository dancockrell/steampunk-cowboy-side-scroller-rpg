# Michael: pose and timing brief v0.1

Status: provisional action design. Identity, costume details and final dimensions must be matched to recovered references. This brief describes motion without inventing Michael's face or clothing.

## Shared drawing contract

Side-view, one adult Michael per source image, orthographic character presentation, no camera movement. Start facing right. Provisional 64×96 export cell, logical foot origin at `(32,88)` in top-left-origin pixel coordinates. The foot origin is an alignment reference even when the character is airborne; do not re-center each frame around visible pixels. Sockets are authored per frame for muzzle and lasso hand, while collision dimensions are owned by code.

At 1× scale, Michael's hat, torso, hands/tool and leading boot must remain readable. Keep the approved equipment attached consistently. Treat the rope loop as a separate visual element when its full arc exceeds the cell; never shrink Michael to fit a wide loop. Preserve oversized source canvases until export so coat, rifle and rope motion are not clipped.

The right-facing study establishes motion, not permission to mirror asymmetric gear. Produce a left-facing key as an explicit continuity check before adopting any mirror rule. Mark unconfirmed handedness as unresolved; do not guess it from these action descriptions.

## Run: eight-frame proposal

| Frame | Drawing instruction | Contact and silhouette | Initial duration |
| --- | --- | --- | --- |
| 000 | Leading leg extends; trailing heel lifts | First contact; hat/torso establish forward lean | 80 ms |
| 001 | Weight settles over planted boot | Low/compressed; coat lags behind pelvis | 80 ms |
| 002 | Rear leg passes under body | Passing pose; separate knees and hands | 80 ms |
| 003 | Push-off lengthens body | Highest pose; coat catches up without floating | 80 ms |
| 004 | Opposite leg reaches contact | Second contact; preserve torso mass | 80 ms |
| 005 | Settle on opposite boot | Second compression, matching amplitude | 80 ms |
| 006 | First leg passes under torso | Clear negative space between limbs | 80 ms |
| 007 | Second push-off leads into 000 | Loop boundary maintains hat/hip continuity | 80 ms |

640 ms is a preview-loop proposal, not a controller speed requirement. Tune stride playback to measured motion, or adjust source stride after testing. Do not fix foot skating by making unrelated per-frame scale changes. First commission four keys (000/002/004/006); approve motion intent before filling the eight-frame loop.

## Lasso throw: six-frame proposal

| Frame | Pose and intent | Marker / implementation expectation | Initial duration |
| --- | --- | --- | --- |
| 000 | Set stance, glance/aim toward valid target | No attachment yet | 90 ms |
| 001 | Draw throwing arm back, weight over rear boot | Anticipation stays distinguishable from firearm aim | 90 ms |
| 002 | Loop crests above/behind shoulder | Rope loop may exceed character cell; separate overlay | 70 ms |
| 003 | Arm extends and loop leaves hand | `tool_commit` presentation alignment; simulation already owns throw | 60 ms |
| 004 | Follow through, body weight moves forward | Rope visual follows simulated projectile/endpoint | 80 ms |
| 005 | Settle into waiting/hold-ready pose | Branch to attached_hold or miss_recover from controller state | 100 ms |

Never bake a fixed destination or successful attachment into the throw frames. `rope_attach` belongs to an actual contact event; it is not emitted because frame 005 was reached. A miss must finish with an intelligible hand/rope recovery rather than snapping to an impossible held rope.

Attached hold uses two subtle tension poses, not two alternating attachment points. Pull uses planted boots, a backward hip shift and readable hand-over-hand or body-haul motion consistent with the approved costume. Swing uses four body-angle keys around the same grip socket; the controller sets position and orientation. Release opens the grip before settling into a fall/recovery pose.

## Jump, fall and landing

Jump rise uses compression-release/elongation keys, apex uses a compact balanced pose, fall shifts feet under the center of mass, landing uses contact → compression → recovery. Do not require a ground anticipation animation to complete before jump input takes effect. A short landing recovery must not prevent a buffered next jump unless explicitly specified by the movement design.

The logical foot origin remains stable across cells; real vertical movement belongs to the controller. Visual squash may change silhouette modestly but must not alter identity or hat scale. Inspect a run → jump → fall → land → run sequence, not only isolated loops.

## Firearm identity through posing

Pistol: compact arm extension, quick visible hand kick, short recovery. Shotgun: broader braced stance, shoulder/torso recoil and deliberate recovery. Rifle: sustained alignment, cheek/shoulder relationship consistent with the approved body, small precise shot response. Distinction must survive a silhouette-only review.

Aim direction policy is an implementation decision: do not commission eight directional aim sets before the controller establishes the permitted range and overlay method. Start with the side-view key for each firearm. Reload poses must communicate where ammunition enters the approved weapon; do not invent a mechanism independently in every frame.

## Review exit

Approve only after a native-size loop and both light/dark room backgrounds are inspected. Record identity drift, foot skating, socket discontinuity, clipped extremities and event-alignment concerns separately. Passing a sprite-sheet dimension check does not complete this review.
