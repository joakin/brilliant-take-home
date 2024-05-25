module Object exposing (Object, make, render)

import Canvas exposing (..)
import Canvas.Settings exposing (..)
import Canvas.Settings.Advanced exposing (..)
import Canvas.Settings.Text exposing (..)
import Color
import Extra.Vec2 as Vec2
import Vec2 exposing (Vec2)


type alias Object =
    { pos : Vec2
    , size : Float
    }


make : Vec2 -> Float -> Object
make pos size =
    { pos = pos
    , size = size
    }


render : Object -> Renderable
render { pos, size } =
    let
        halfSize =
            size / 2

        trianglePath =
            path ( pos.x, pos.y )
                [ lineTo ( pos.x, pos.y - halfSize )
                , lineTo ( pos.x + size * 0.8, pos.y )
                , lineTo ( pos.x, pos.y + halfSize )
                ]
    in
    shapes
        [ fill Color.lightRed
        , transform [ translate -(halfSize * 0.7) 0 ]
        ]
        [ trianglePath ]
