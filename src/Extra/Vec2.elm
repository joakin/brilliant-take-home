module Extra.Vec2 exposing (..)

import Vec2 exposing (Vec2)


subBy : Vec2 -> Vec2 -> Vec2
subBy v1 v2 =
    { x = v2.x - v1.x, y = v2.y - v1.y }


fromTuple : ( Float, Float ) -> Vec2
fromTuple ( x, y ) =
    Vec2.vec2 x y


toTuple : Vec2 -> ( Float, Float )
toTuple { x, y } =
    ( x, y )
