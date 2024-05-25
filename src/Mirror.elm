module Mirror exposing (Mirror, make, render, width)

import Canvas exposing (..)
import Canvas.Settings exposing (..)
import Canvas.Settings.Advanced exposing (..)
import Canvas.Settings.Line exposing (..)
import Canvas.Settings.Text exposing (..)
import Color
import Extra.Vec2 as Vec2
import Line exposing (Line)
import Vec2 exposing (Vec2)


type alias Mirror =
    { line : Line
    }


make : Vec2 -> Vec2 -> Mirror
make point1 point2 =
    { line = Line.make point1 point2
    }


width =
    5


render : Mirror -> Renderable
render { line } =
    group []
        [ Line.render
            [ stroke Color.lightBlue
            , lineWidth width
            ]
            line
        ]
