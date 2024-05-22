module Extra.Vec2 exposing (..)

import Vec2 exposing (Vec2)


fromTuple : ( Float, Float ) -> Vec2
fromTuple ( x, y ) =
    Vec2.vec2 x y


toTuple : Vec2 -> ( Float, Float )
toTuple { x, y } =
    ( x, y )
