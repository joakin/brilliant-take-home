module Reflection exposing (Reflection, make, render)

import Canvas exposing (..)
import Canvas.Settings exposing (..)
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


render : (a -> Renderable) -> Reflection a -> Renderable
render renderReflected reflection =
    renderReflected reflection.reflected
