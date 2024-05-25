module Reflection exposing (Reflection, make)

import Mirror exposing (Mirror)
import Vec2 exposing (Vec2)


type alias Reflection a =
    { reflected : a
    , original : a
    , mirror : Mirror
    , intersection : Vec2
    }


make : { original : a, reflected : a } -> Vec2 -> Mirror -> Reflection a
make { original, reflected } intersection mirror =
    { reflected = reflected
    , original = original
    , mirror = mirror
    , intersection = intersection
    }
