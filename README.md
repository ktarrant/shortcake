# shortcake
2D platform fighting game with floaty physics

## Player State Management

![PlayerState](https://github.com/user-attachments/assets/235aa1c1-db26-41cb-9e7f-d1dabc456f5b)<svg width="610pt" height="361pt" viewBox="0.00 0.00 609.67 361.36" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
<g id="graph0" class="graph" transform="scale(1 1) rotate(0) translate(4 357.36)">
<title>PlayerStateMachine</title>
<polygon fill="white" stroke="none" points="-4,4 -4,-357.36 605.67,-357.36 605.67,4 -4,4"/>
<g id="clust1" class="cluster">
<title>cluster_air</title>
<polygon fill="none" stroke="black" stroke-dasharray="5,2" points="210.34,-8 210.34,-164 593.67,-164 593.67,-8 210.34,-8"/>
<text text-anchor="middle" x="402" y="-147.4" font-family="Times,serif" font-size="14.00">Air Phase</text>
</g>
<!-- IdleState -->
<g id="node1" class="node">
<title>IdleState</title>
<ellipse fill="lightgray" stroke="black" cx="45.36" cy="-200" rx="45.36" ry="18"/>
<text text-anchor="middle" x="45.36" y="-195.8" font-family="Times,serif" font-size="14.00">IdleState</text>
</g>
<!-- RunState -->
<g id="node2" class="node">
<title>RunState</title>
<ellipse fill="lightgray" stroke="black" cx="269.61" cy="-216" rx="46.44" ry="18"/>
<text text-anchor="middle" x="269.61" y="-211.8" font-family="Times,serif" font-size="14.00">RunState</text>
</g>
<!-- IdleState&#45;&gt;RunState -->
<g id="edge1" class="edge">
<title>IdleState-&gt;RunState</title>
<path fill="none" stroke="black" d="M80.62,-211.76C89.65,-214.34 99.46,-216.69 108.72,-218 142.96,-222.84 181.75,-222.5 212.54,-220.87"/>
<polygon fill="black" stroke="black" points="212.64,-224.37 222.41,-220.28 212.22,-217.38 212.64,-224.37"/>
<text text-anchor="middle" x="154.53" y="-226.16" font-family="Times,serif" font-size="14.00">input_dir.x ≠ 0</text>
</g>
<!-- JumpState -->
<g id="node3" class="node">
<title>JumpState</title>
<ellipse fill="lightgray" stroke="black" cx="269.61" cy="-92" rx="51.27" ry="18"/>
<text text-anchor="middle" x="269.61" y="-87.8" font-family="Times,serif" font-size="14.00">JumpState</text>
</g>
<!-- IdleState&#45;&gt;JumpState -->
<g id="edge2" class="edge">
<title>IdleState-&gt;JumpState</title>
<path fill="none" stroke="black" d="M54.24,-182.07C63.99,-162.2 82.55,-130.9 108.72,-115.2 138.07,-97.59 175.76,-91.5 207.18,-89.94"/>
<polygon fill="black" stroke="black" points="207.06,-93.45 216.93,-89.61 206.82,-86.45 207.06,-93.45"/>
<text text-anchor="middle" x="154.53" y="-119.4" font-family="Times,serif" font-size="14.00">jump</text>
</g>
<!-- AttackState -->
<g id="node4" class="node">
<title>AttackState</title>
<ellipse fill="lightgray" stroke="black" cx="542.45" cy="-299" rx="56.09" ry="18"/>
<text text-anchor="middle" x="542.45" y="-294.8" font-family="Times,serif" font-size="14.00">AttackState</text>
</g>
<!-- IdleState&#45;&gt;AttackState -->
<g id="edge3" class="edge">
<title>IdleState-&gt;AttackState</title>
<path fill="none" stroke="black" d="M66.48,-216.16C78.25,-225.01 93.72,-235.65 108.72,-243 205.1,-290.2 232.83,-299.58 338.88,-316 395.75,-324.8 411.19,-322.56 468.36,-316 474.75,-315.27 481.39,-314.19 487.94,-312.92"/>
<polygon fill="black" stroke="black" points="488.29,-316.42 497.36,-310.94 486.85,-309.57 488.29,-316.42"/>
<text text-anchor="middle" x="269.61" y="-317" font-family="Times,serif" font-size="14.00">attack</text>
</g>
<!-- AirState -->
<g id="node5" class="node">
<title>AirState</title>
<ellipse fill="lightgray" stroke="black" cx="542.45" cy="-113" rx="43.22" ry="18"/>
<text text-anchor="middle" x="542.45" y="-108.8" font-family="Times,serif" font-size="14.00">AirState</text>
</g>
<!-- IdleState&#45;&gt;AirState -->
<g id="edge4" class="edge">
<title>IdleState-&gt;AirState</title>
<path fill="none" stroke="black" d="M51.74,-182.02C60.06,-157.12 78.35,-112.27 108.72,-86 189.68,-15.96 232.69,-28.49 338.88,-15 395.97,-7.75 416.93,10.81 468.36,-15 497.32,-29.53 517.73,-61.57 529.49,-85.07"/>
<polygon fill="black" stroke="black" points="526.18,-86.28 533.63,-93.81 532.51,-83.28 526.18,-86.28"/>
<text text-anchor="middle" x="269.61" y="-33.99" font-family="Times,serif" font-size="14.00">!is_on_floor</text>
</g>
<!-- RunState&#45;&gt;IdleState -->
<g id="edge5" class="edge">
<title>RunState-&gt;IdleState</title>
<path fill="none" stroke="black" d="M233.55,-204.41C223,-201.45 211.31,-198.68 200.34,-197.2 167.59,-192.77 130.57,-193.27 101.04,-194.98"/>
<polygon fill="black" stroke="black" points="100.97,-191.47 91.22,-195.61 101.42,-198.46 100.97,-191.47"/>
<text text-anchor="middle" x="154.53" y="-201.4" font-family="Times,serif" font-size="14.00">input_dir.x == 0</text>
</g>
<!-- RunState&#45;&gt;JumpState -->
<g id="edge6" class="edge">
<title>RunState-&gt;JumpState</title>
<path fill="none" stroke="black" d="M224.03,-212.01C201.03,-207.41 175.01,-197.72 160.65,-177.4 139.54,-147.53 182.04,-122.99 219.98,-108"/>
<polygon fill="black" stroke="black" points="220.97,-111.37 229.09,-104.57 218.5,-104.82 220.97,-111.37"/>
<text text-anchor="middle" x="154.53" y="-164.8" font-family="Times,serif" font-size="14.00">jump</text>
</g>
<!-- RunState&#45;&gt;AttackState -->
<g id="edge7" class="edge">
<title>RunState-&gt;AttackState</title>
<path fill="none" stroke="black" d="M305.82,-227.72C316.38,-230.99 328.04,-234.37 338.88,-237 395.7,-250.77 413.11,-241.11 468.36,-260.2 481.07,-264.59 494.26,-270.96 505.87,-277.27"/>
<polygon fill="black" stroke="black" points="503.87,-280.16 514.3,-282 507.3,-274.05 503.87,-280.16"/>
<text text-anchor="middle" x="403.62" y="-264.4" font-family="Times,serif" font-size="14.00">attack</text>
</g>
<!-- RunState&#45;&gt;AirState -->
<g id="edge8" class="edge">
<title>RunState-&gt;AirState</title>
<path fill="none" stroke="black" d="M316.41,-215.49C366.41,-214.25 442.76,-210.18 468.36,-197 492.95,-184.35 512.89,-159.6 525.69,-140.23"/>
<polygon fill="black" stroke="black" points="528.53,-142.29 530.91,-131.97 522.61,-138.55 528.53,-142.29"/>
<text text-anchor="middle" x="403.62" y="-218.97" font-family="Times,serif" font-size="14.00">!is_on_floor</text>
</g>
<!-- JumpState&#45;&gt;AirState -->
<g id="edge13" class="edge">
<title>JumpState-&gt;AirState</title>
<path fill="none" stroke="black" d="M285.1,-74.62C297.7,-60.97 317.28,-43.01 338.88,-35.2 393,-15.63 415.55,-12.35 468.36,-35.2 492.19,-45.51 511.82,-67.82 524.72,-85.92"/>
<polygon fill="black" stroke="black" points="521.81,-87.88 530.32,-94.19 527.61,-83.95 521.81,-87.88"/>
<text text-anchor="middle" x="403.62" y="-39.4" font-family="Times,serif" font-size="14.00">!jump or timeout</text>
</g>
<!-- JumpState&#45;&gt;AirState -->
<g id="edge14" class="edge">
<title>JumpState-&gt;AirState</title>
<path fill="none" stroke="black" d="M312.45,-81.68C352.86,-73.38 415.54,-64.96 468.36,-77.2 481.88,-80.33 495.79,-86.33 507.79,-92.54"/>
<polygon fill="black" stroke="black" points="506.01,-95.55 516.47,-97.25 509.35,-89.4 506.01,-95.55"/>
<text text-anchor="middle" x="403.62" y="-81.4" font-family="Times,serif" font-size="14.00">jump_extend_time ≤ 0</text>
</g>
<!-- AttackState&#45;&gt;IdleState -->
<g id="edge15" class="edge">
<title>AttackState-&gt;IdleState</title>
<path fill="none" stroke="black" d="M514.34,-315.01C500.98,-322 484.34,-329.41 468.36,-333 451.19,-336.86 226.19,-338.14 210.34,-334 160.24,-320.91 148.3,-310.39 108.72,-277 91.51,-262.49 75.6,-242.7 64.16,-226.81"/>
<polygon fill="black" stroke="black" points="67.12,-224.93 58.51,-218.75 61.38,-228.95 67.12,-224.93"/>
<text text-anchor="middle" x="269.61" y="-340.76" font-family="Times,serif" font-size="14.00">land + no input</text>
</g>
<!-- AttackState&#45;&gt;RunState -->
<g id="edge16" class="edge">
<title>AttackState-&gt;RunState</title>
<path fill="none" stroke="black" d="M486.35,-296.79C435.59,-294.08 364.42,-288.36 338.88,-277 320.9,-269 304.33,-254.46 292.03,-241.58"/>
<polygon fill="black" stroke="black" points="294.94,-239.57 285.6,-234.56 289.77,-244.3 294.94,-239.57"/>
<text text-anchor="middle" x="403.62" y="-299.83" font-family="Times,serif" font-size="14.00">land + input_dir.x ≠ 0</text>
</g>
<!-- AttackState&#45;&gt;AirState -->
<g id="edge17" class="edge">
<title>AttackState-&gt;AirState</title>
<path fill="none" stroke="black" d="M542.45,-280.75C542.45,-248.54 542.45,-181.35 542.45,-142.48"/>
<polygon fill="black" stroke="black" points="545.95,-142.69 542.45,-132.69 538.95,-142.69 545.95,-142.69"/>
<text text-anchor="middle" x="531.05" y="-201.8" font-family="Times,serif" font-size="14.00">!is_on_floor</text>
</g>
<!-- AirState&#45;&gt;IdleState -->
<g id="edge11" class="edge">
<title>AirState-&gt;IdleState</title>
<path fill="none" stroke="black" d="M504.04,-121.53C492.63,-123.9 480.03,-126.29 468.36,-128 309.59,-151.28 260.56,-108.07 108.72,-160 97.22,-163.93 85.71,-170.41 75.77,-177.02"/>
<polygon fill="black" stroke="black" points="73.82,-174.11 67.65,-182.72 77.84,-179.84 73.82,-174.11"/>
<text text-anchor="middle" x="269.61" y="-139.89" font-family="Times,serif" font-size="14.00">land + no input</text>
</g>
<!-- AirState&#45;&gt;RunState -->
<g id="edge12" class="edge">
<title>AirState-&gt;RunState</title>
<path fill="none" stroke="black" d="M520.2,-128.89C506.19,-138.56 487.04,-150.3 468.36,-157 413.61,-176.65 393.78,-156.94 338.88,-176.2 326.4,-180.58 313.63,-187.31 302.56,-194"/>
<polygon fill="black" stroke="black" points="300.81,-190.97 294.21,-199.26 304.54,-196.89 300.81,-190.97"/>
<text text-anchor="middle" x="403.62" y="-180.4" font-family="Times,serif" font-size="14.00">land + input_dir.x ≠ 0</text>
</g>
<!-- AirState&#45;&gt;JumpState -->
<g id="edge9" class="edge">
<title>AirState-&gt;JumpState</title>
<path fill="none" stroke="black" d="M499.54,-109.75C454.48,-106.26 382.44,-100.67 331.22,-96.7"/>
<polygon fill="black" stroke="black" points="331.72,-93.23 321.48,-95.94 331.18,-100.21 331.72,-93.23"/>
<text text-anchor="middle" x="403.62" y="-110.99" font-family="Times,serif" font-size="14.00">jump (double)</text>
</g>
<!-- AirState&#45;&gt;AttackState -->
<g id="edge10" class="edge">
<title>AirState-&gt;AttackState</title>
<path fill="none" stroke="black" d="M542.45,-131.17C542.45,-163.33 542.45,-230.52 542.45,-269.43"/>
<polygon fill="black" stroke="black" points="538.95,-269.24 542.45,-279.24 545.95,-269.24 538.95,-269.24"/>
<text text-anchor="middle" x="531.05" y="-201.8" font-family="Times,serif" font-size="14.00">attack</text>
</g>
</g>
</svg>

## Collision Masking

🧱 Collision Layers and Masks
| Layer | Name             | Used By               | Purpose / Notes                                   |
| ----- | ---------------- | --------------------- | ------------------------------------------------- |
| 1     | `Player`         | Player bodies         | Characters’ physical bodies (no mutual collision) |
| 2     | `SolidPlatform`  | Main platform         | Solid ground — cannot fall through                |
| 3     | `OneWayPlatform` | Top platforms         | One-way pass-through platforms                    |
| 4     | `OverlapArea`    | Area2D inside players | Soft collision detection between players          |

✅ Collision Mask Configuration
| Node Type              | Layer(s) | Mask(s) | Description                                     |
| ---------------------- | -------- | ------- | ----------------------------------------------- |
| `Player`               | 1        | 2, 3    | Collides with ground and one-way platforms only |
| `OverlapArea` (Area2D) | 4        | 1       | Detects overlap with other players              |
| `SolidPlatform`        | 2        | —       | Standard ground — blocks movement               |
| `OneWayPlatform`       | 3        | —       | One-way platform — supports drop-through        |

🔄 Special Logic
- When player falls through:
	set_collision_mask_value(3, false) (disable one-way platform collision)

- On landing:
	set_collision_mask_value(3, true) (restore platform collision)

# TODO

Attacks:
- Front kick
- Down spike
- Add cooldown for attacks to avoid spam

Game state:
- Lives/stock counting
- Respawn delay + animation
- Temporary invincibility after respawn
- Add state enum for idle, attacking, hitstun, etc.
- Tie percent into a floating UI element

Jumping:
- Wall jumping
