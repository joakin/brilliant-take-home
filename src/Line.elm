module Line exposing (Line, make, render)

import Canvas exposing (..)
import Canvas.Settings exposing (..)
import Canvas.Settings.Advanced exposing (..)
import Canvas.Settings.Line exposing (..)
import Canvas.Settings.Text exposing (..)
import Extra.Vec2 as Vec2
import Vec2 exposing (Vec2)


type alias Line =
    { p1 : Vec2
    , p2 : Vec2
    }


make : Vec2 -> Vec2 -> Line
make p1 p2 =
    { p1 = p1
    , p2 = p2
    }


render : List Setting -> Line -> Renderable
render settings { p1, p2 } =
    shapes
        (lineJoin RoundJoin
            :: lineCap RoundCap
            :: settings
        )
        [ path ( p1.x, p1.y ) [ lineTo ( p2.x, p2.y ) ] ]
