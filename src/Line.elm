module Line exposing (Line, displace, intersection, make, mirroredPosition, render)

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


mirroredPosition : Vec2 -> Line -> Vec2
mirroredPosition point { p1, p2 } =
    let
        lineVec =
            Vec2.sub p2 p1

        pointVec =
            Vec2.sub point p1

        lineDir =
            Vec2.normalize lineVec

        projectionLength =
            Vec2.dot pointVec lineDir

        projection =
            Vec2.scale projectionLength lineDir

        perpendicular =
            Vec2.sub pointVec projection

        mirroredVec =
            Vec2.sub projection perpendicular
    in
    -- Mirrored point is p1 + projection - perpendicular
    Vec2.add p1 mirroredVec


intersection : Line -> Line -> Maybe Vec2
intersection l1 l2 =
    let
        ( l1p1, l1p2 ) =
            ( l1.p1, l1.p2 )

        ( l2p1, l2p2 ) =
            ( l2.p1, l2.p2 )

        -- Direction vectors of the lines
        d1 =
            Vec2.sub l1p2 l1p1

        d2 =
            Vec2.sub l2p2 l2p1

        -- Determinant of the system
        det =
            (d1.x * d2.y) - (d1.y * d2.x)

        eps =
            1.0e-10
    in
    -- Check if lines are parallel (det == 0)
    if abs det < eps then
        Nothing

    else
        let
            -- Difference between the points
            diff =
                Vec2.sub l2p1 l1p1

            -- Parameters for the intersection point
            t1 =
                ((diff.x * d2.y) - (diff.y * d2.x)) / det

            t2 =
                ((diff.x * d1.y) - (diff.y * d1.x)) / det
        in
        -- Check if the intersection point lies on both line segments
        if (0 <= t1 && t1 <= 1) && (0 <= t2 && t2 <= 1) then
            Just (Vec2.add l1p1 (Vec2.scale t1 d1))

        else
            Nothing


displace : Float -> Line -> Line
displace displacement { p1, p2 } =
    let
        direction =
            Vec2.sub p2 p1

        perpendicular =
            Vec2.vec2 -direction.y direction.x

        normalizedPerpendicular =
            Vec2.normalize perpendicular

        displacementVector =
            Vec2.scale displacement normalizedPerpendicular
    in
    -- Displace both points by the displacement vector
    { p1 = Vec2.add p1 displacementVector
    , p2 = Vec2.add p2 displacementVector
    }


render : List Setting -> Line -> Renderable
render settings { p1, p2 } =
    shapes
        (lineJoin RoundJoin
            :: lineCap RoundCap
            :: settings
        )
        [ path ( p1.x, p1.y ) [ lineTo ( p2.x, p2.y ) ] ]
