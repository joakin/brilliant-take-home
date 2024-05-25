module Observer exposing (Observer, make, render)

import Canvas exposing (..)
import Canvas.Settings exposing (..)
import Canvas.Settings.Advanced exposing (..)
import Canvas.Settings.Text exposing (..)
import Color
import Extra.Vec2 as Vec2
import Vec2 exposing (Vec2)


type alias Observer =
    { pos : Vec2
    , size : Float
    }


make : Vec2 -> Float -> Observer
make pos size =
    { pos = pos
    , size = size
    }


render : Observer -> Renderable
render { pos, size } =
    shapes
        [ fill Color.lightBlue
        ]
        [ circle (Vec2.toTuple pos) size ]
