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
    applyGravity: otherMoon axis: axis [
        | newVel |
        newVel := vel perform: axis.
        ((pos perform: axis) < ((otherMoon pos) perform: axis)) ifTrue: [ newVel := newVel + 1. ].
        ((pos perform: axis) > ((otherMoon pos) perform: axis)) ifTrue: [ newVel := newVel - 1. ].
        vel perform: ((axis, #:) asSymbol) with: newVel.
    ]
    moveAxis: axis [
        | newPos |
        newPos := (pos perform: axis) + (vel perform: axis).
        pos perform: ((axis, #:) asSymbol) with: newPos.
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
    stepAxis: axis [
        moons do: [ :moon |
            moons do: [ :otherMoon |
                moon applyGravity: otherMoon axis: axis.
            ].
        ].
        moons do: [ :moon |
            moon moveAxis: axis.
        ].
    ]
    snapshot: axis [
        | snapshot |
        snapshot := OrderedCollection new.
        moons do: [ :moon |
            snapshot
                add: ((moon pos) perform: axis);
                add: ((moon vel) perform: axis).
        ].
        ^ snapshot asArray.
    ]
    cycleLengthAxis: axis [
        | length snapshot snapshots |
        length := 0.
        snapshot := self snapshot: axis.
        snapshots := Set new.
        [ snapshots includes: snapshot ] whileFalse: [
            snapshots add: snapshot.
            self stepAxis: axis.
            snapshot := self snapshot: axis.
            length := length + 1.
        ].
        ^ length.
    ]
    cycleLength [
        | x y z |
        x := self cycleLengthAxis: #x.
        y := self cycleLengthAxis: #y.
        z := self cycleLengthAxis: #z.
        ^ (x lcm: y) lcm: z.
    ]
]

system := System new.
[ stdin atEnd ] whileFalse: [
    pos := Vec3 parse: stdin nextLine.
    moon := Moon pos: pos.
    system add: moon.
].
system cycleLength displayNl.
