module LightRay exposing (LightRay, make, makeFromSegments, render)

import Canvas exposing (..)
import Canvas.Settings exposing (..)
import Canvas.Settings.Advanced exposing (..)
import Canvas.Settings.Line exposing (..)
import Canvas.Settings.Text exposing (..)
import Color
import Line exposing (Line)
import List.Extra as List
import Vec2 exposing (Vec2)


type alias LightRay =
    { segments : List Line
    }


make : Vec2 -> Vec2 -> LightRay
make start end =
    { segments = [ Line.make start end ] }


makeFromSegments : List Line -> LightRay
makeFromSegments segments =
    { segments = segments }


render : LightRay -> Renderable
render { segments } =
    let
        width =
            3
    in
    List.last segments
        |> Maybe.map
            (\lastSegment ->
                group []
                    [ group []
                        (List.map
                            (Line.render [ stroke Color.lightYellow, lineWidth width ])
                            segments
                        )
                    , let
                        arrowHeadSize =
                            10

                        directionVec =
                            Vec2.direction { from = lastSegment.p1, to = lastSegment.p2 }

                        angle =
                            Vec2.angle directionVec

                        arrowTip =
                            -- Displace the arrow tip a bit to cover the end of the line
                            lastSegment.p2
                                |> Vec2.add (Vec2.scale width directionVec)

                        arrowTransform =
                            [ translate arrowTip.x arrowTip.y
                            , rotate angle
                            ]
                      in
                      shapes [ fill Color.lightYellow, transform arrowTransform ]
                        [ path ( 0, 0 )
                            [ lineTo ( -arrowHeadSize, -arrowHeadSize * 0.6 )
                            , lineTo ( -arrowHeadSize, arrowHeadSize * 0.6 )
                            ]
                        ]
                    ]
            )
        |> Maybe.withDefault (group [] [])
