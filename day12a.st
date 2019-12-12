Object subclass: Vec3 [
    | x y z |
    Vec3 class >> x: xInt y: yInt z: zInt [
        | v |
        v := super new.
        v
            x: xInt;
            y: yInt;
            z: zInt.
        ^ v.
    ]
    Vec3 class >> parse: str [
        (str =~ '<x=(-?\d+), y=(.*), z=(.*)>')
            ifMatched: [ :match |
                ^ Vec3
                    x: (match at: 1) asNumber
                    y: (match at: 2) asNumber
                    z: (match at: 3) asNumber.
            ].
        ^ Exception signal: 'Unparsable'.
    ]
    x: xInt [
        x := xInt.
    ]
    y: yInt [
        y := yInt.
    ]
    z: zInt [
        z := zInt.
    ]
    x [ ^ x. ]
    y [ ^ y. ]
    z [ ^ z. ]
    += u [
        x := x + u x.
        y := y + u y.
        z := z + u z.
    ]
    displayOn: stream [
        '<x=' displayOn: stream.
        x displayOn: stream.
        ', y=' displayOn: stream.
        y displayOn: stream.
        ', z=' displayOn: stream.
        z displayOn: stream.
        '>' displayOn: stream.
    ]
]

Object subclass: Moon [
    | pos vel |
    Moon class >> pos: posVec [
        | m |
        m := super new.
        m pos: posVec.
        m vel: (Vec3 x: 0 y: 0 z: 0).
        ^ m.
    ]
    pos: posVec [
        pos := posVec.
    ]
    vel: velVec [
        vel := velVec.
    ]
    pos [ ^ pos. ]
    vel [ ^ vel. ]
    applyGravity: otherMoon [
        (pos x < otherMoon pos x) ifTrue: [ vel x: (vel x + 1). ].
        (pos x > otherMoon pos x) ifTrue: [ vel x: (vel x - 1). ].
        (pos y < otherMoon pos y) ifTrue: [ vel y: (vel y + 1). ].
        (pos y > otherMoon pos y) ifTrue: [ vel y: (vel y - 1). ].
        (pos z < otherMoon pos z) ifTrue: [ vel z: (vel z + 1). ].
        (pos z > otherMoon pos z) ifTrue: [ vel z: (vel z - 1). ].
    ]
    move [
        pos += vel.
    ]
    potentialEnergy [
        ^ pos x abs + pos y abs + pos z abs.
    ]
    kineticEnergy [
        ^ vel x abs + vel y abs + vel z abs.
    ]
    energy [
        ^ self potentialEnergy * self kineticEnergy.
    ]
    displayOn: stream [
        'pos=' displayOn: stream.
        pos displayOn: stream.
        ', vel=' displayOn: stream.
        vel displayOn: stream.
    ]
]

Object subclass: System [
    | moons |
    System class >> new [
        | s |
        s := super new.
        s init.
        ^ s.
    ]
    init [
        moons := OrderedCollection new.
    ]
    add: moon [
        moons add: moon.
    ]
    energy [
        ^ moons inject: 0 into: [ :e :moon | e + moon energy. ].
    ]
    step [
        moons do: [ :moon |
            moons do: [ :otherMoon |
                moon applyGravity: otherMoon.
            ].
        ].
        moons do: [ :moon |
            moon move.
        ].
    ]
    step: n [
        1 to: n do: [ :i |
            self step.
        ].
    ]
    displayOn: stream [
        moons do: [ :moon |
            moon displayOn: stream.
            stream nl.
        ].
    ]
]

system := System new.
[ stdin atEnd ] whileFalse: [
    pos := Vec3 parse: stdin nextLine.
    moon := Moon pos: pos.
    system add: moon.
].
system step: 1000.
system energy displayNl.
