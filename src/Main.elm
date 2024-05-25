module Main exposing (..)

import Browser
import Browser.Events
import Canvas exposing (..)
import Canvas.Settings exposing (..)
import Canvas.Settings.Advanced exposing (..)
import Canvas.Settings.Line exposing (..)
import Canvas.Settings.Text exposing (..)
import Color
import Extra.Vec2 as Vec2
import Html exposing (div)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Html.Events.Extra.Pointer as Pointer
import Line
import Mirror exposing (Mirror)
import Object exposing (Object)
import Observer exposing (Observer)
import Ray exposing (Ray)
import Reflection exposing (Reflection)
import Vec2 exposing (Vec2)


main : Program () Context Msg
main =
    Browser.document
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type alias Flags =
    ()


type alias Context =
    { width : Float
    , height : Float
    , frame : Float
    , time : Float
    , delta : Float
    , testPointer : Maybe Vec2
    , observer : Observer
    , objects : List Object
    , mirrors : List Mirror
    , lightRays : List Ray
    , eyeSightRays : List Ray
    , reflections :
        { cache :
            { observer : Observer
            , objects : List Object
            , mirrors : List Mirror
            }
        , observers : List (Reflection Observer)
        , objects : List (Reflection Object)
        , mirrors : List (Reflection Mirror)
        }
    }


type Msg
    = Frame Float
    | CanvasPointerDown Pointer.Event
    | CanvasPointerMove Pointer.Event
    | CanvasPointerUp Pointer.Event


init : Flags -> ( Context, Cmd Msg )
init _ =
    let
        dimensions =
            { width = 500
            , height = 500
            }

        size =
            30

        centerPos =
            center dimensions

        space =
            50

        observer =
            Observer.make (centerPos |> Vec2.add { x = -space, y = space * 2 * 0.7 }) size

        objects =
            [ Object.make
                (centerPos
                    |> Vec2.add (Vec2.vec2 -space (-space * 2 * 0.7))
                )
                size
            ]

        mirrors =
            [ let
                p1 =
                    centerPos
                        |> Vec2.add (Vec2.vec2 space (-space * 2))

                p2 =
                    centerPos
                        |> Vec2.add (Vec2.vec2 space (space * 2))
              in
              Mirror.make p1 p2
            , let
                p1 =
                    centerPos
                        |> Vec2.add (Vec2.vec2 (-space * 2) (-space * 2))

                p2 =
                    centerPos
                        |> Vec2.add (Vec2.vec2 (-space * 2) (space * 2))
              in
              Mirror.make p1 p2
            , let
                p1 =
                    centerPos
                        |> Vec2.add (Vec2.vec2 space (-space * 2))

                p2 =
                    centerPos
                        |> Vec2.add (Vec2.vec2 (-space * 2) (-space * 2))
              in
              Mirror.make p1 p2
            , let
                p1 =
                    centerPos
                        |> Vec2.add (Vec2.vec2 space (space * 2))

                p2 =
                    centerPos
                        |> Vec2.add (Vec2.vec2 (-space * 2) (space * 2))
              in
              Mirror.make p1 p2
            ]
    in
    ( { width = dimensions.width
      , height = dimensions.height
      , frame = 0
      , time = 0
      , delta = 0
      , testPointer = Nothing
      , observer = observer
      , objects = objects
      , mirrors = mirrors
      , lightRays = []
      , eyeSightRays = []
      , reflections =
            { cache =
                { observer = observer
                , objects = objects
                , mirrors = mirrors
                }
            , observers = []
            , objects = []
            , mirrors = []
            }
      }
        |> updateReflections
    , Cmd.none
    )


subscriptions : Context -> Sub Msg
subscriptions ctx =
    Browser.Events.onAnimationFrameDelta Frame



-- UPDATE


update : Msg -> Context -> ( Context, Cmd Msg )
update msg ({ observer } as ctx) =
    case msg of
        Frame delta ->
            ( { ctx
                | frame = ctx.frame + 1
                , time = ctx.time + delta
                , delta = delta
              }
                |> updateSimulation
            , Cmd.none
            )

        CanvasPointerDown event ->
            ( { ctx
                | testPointer = Just <| Vec2.fromTuple event.pointer.offsetPos
                , observer = { observer | pos = Vec2.fromTuple event.pointer.offsetPos }
              }
            , Cmd.none
            )

        CanvasPointerMove event ->
            ( ctx.testPointer
                |> Maybe.map
                    (\_ ->
                        { ctx
                            | testPointer = Just <| Vec2.fromTuple event.pointer.offsetPos
                            , observer = { observer | pos = Vec2.fromTuple event.pointer.offsetPos }
                        }
                    )
                |> Maybe.withDefault ctx
            , Cmd.none
            )

        CanvasPointerUp event ->
            ( { ctx | testPointer = Nothing }, Cmd.none )


updateSimulation : Context -> Context
updateSimulation ({ reflections } as ctx) =
    if
        (ctx.observer == reflections.cache.observer)
            && (ctx.objects == reflections.cache.objects)
            && (ctx.mirrors == reflections.cache.mirrors)
    then
        ctx

    else
        { ctx
            | reflections =
                { reflections
                    | cache =
                        { observer = ctx.observer
                        , objects = ctx.objects
                        , mirrors = ctx.mirrors
                        }
                }
        }
            |> updateReflections


updateReflections : Context -> Context
updateReflections ({ reflections } as ctx) =
    let
        maxDepth =
            4

        mirrorReflections =
            generateMirrorReflections ctx.observer ctx.mirrors

        allMirrorReflections =
            generateReflectedMirrorReflections
                0
                maxDepth
                ctx.observer
                mirrorReflections
                ctx.mirrors
                mirrorReflections

        allMirrors =
            ctx.mirrors ++ List.map .reflected allMirrorReflections

        observerReflections =
            generateObserverReflections ctx.observer ctx.mirrors

        allObserverReflections =
            generateReflectedObserverReflections
                0
                maxDepth
                ctx.observer
                observerReflections
                ctx.mirrors
                observerReflections

        objectReflections =
            generateObjectReflections ctx.observer ctx.objects ctx.mirrors

        allObjectReflections =
            generateReflectedObjectReflections
                0
                maxDepth
                ctx.observer
                objectReflections
                ctx.mirrors
                objectReflections
    in
    { ctx
        | reflections =
            { reflections
                | observers = allObserverReflections
                , objects = allObjectReflections
                , mirrors = allMirrorReflections
            }
        , lightRays =
            []

        -- List.concat
        --     [ allObserverReflections
        --         |> List.map
        --             (\reflection ->
        --                 makeRay
        --                     [ ( reflection.original.pos, reflection.original.size / 2 )
        --                     , ( reflection.intersection, Mirror.width / 2 )
        --                     , ( reflection.original.pos, reflection.original.size / 2 )
        --                     ]
        --             )
        --     , allObjectReflections
        --         |> List.map
        --             (\reflection ->
        --                 let
        --                     directLine =
        --                         Line.make ctx.observer.pos reflection.reflected.pos
        --                     pointsByObserverDistance : List Vec2
        --                     pointsByObserverDistance =
        --                         allMirrors
        --                             |> List.filterMap (\mirror -> Line.intersection mirror.line directLine)
        --                             |> List.sortBy (Vec2.distanceSquared ctx.observer.pos)
        --                     segments : List ( Vec2, Float )
        --                     segments =
        --                         pointsByObserverDistance
        --                             |> List.reverse
        --                             |> List.map (\pos -> ( pos, Mirror.width / 2 ))
        --                     ray =
        --                         makeRay
        --                             ((( reflection.original.pos, reflection.original.size / 2 ) :: segments)
        --                                 ++ [ ( ctx.observer.pos, ctx.observer.size / 2 ) ]
        --                             )
        --                 in
        --                 ray
        --             )
        --     ]
        , eyeSightRays =
            List.concat
                [ allObserverReflections
                    |> List.map
                        (\reflection ->
                            makeRay
                                [ ( ctx.observer.pos, ctx.observer.size / 2 )
                                , ( reflection.intersection, 0 )
                                , ( reflection.reflected.pos, reflection.reflected.size / 2 )
                                ]
                        )
                , allObjectReflections
                    |> List.map
                        (\reflection ->
                            makeRay
                                [ ( ctx.observer.pos, ctx.observer.size / 2 )
                                , ( reflection.intersection, 0 )
                                , ( reflection.reflected.pos, reflection.reflected.size / 2 )
                                ]
                        )
                ]
    }


makeRay : List ( Vec2, Float ) -> Ray
makeRay segments =
    let
        loop acc list =
            case list of
                ( p1, s1 ) :: (( p2, s2 ) as segment) :: rest ->
                    loop
                        ((Line.make p1 p2
                            |> Line.adjustSize { start = s1, end = s2 }
                         )
                            :: acc
                        )
                        (segment :: rest)

                _ ->
                    acc
    in
    Ray.makeFromSegments (loop [] segments |> List.reverse)


generateObserverReflections : Observer -> List Mirror -> List (Reflection Observer)
generateObserverReflections observer mirrors =
    List.filterMap
        (\mirror ->
            let
                reflectedObserver =
                    { observer | pos = Line.mirroredPosition observer.pos mirror.line }
            in
            Line.intersection (Line.make reflectedObserver.pos observer.pos) mirror.line
                |> Maybe.map
                    (\intersectionPoint ->
                        Reflection.make
                            { reflected = reflectedObserver
                            , original = observer
                            }
                            intersectionPoint
                            mirror
                    )
        )
        mirrors


generateReflectedObserverReflections :
    Int
    -> Int
    -> Observer
    -> List (Reflection Observer)
    -> List Mirror
    -> List (Reflection Observer)
    -> List (Reflection Observer)
generateReflectedObserverReflections depth maxDepth observer reflectedObservers mirrors allObserverReflections =
    if depth >= maxDepth then
        allObserverReflections

    else
        let
            newReflectedObservers : List (Reflection Observer)
            newReflectedObservers =
                List.concatMap
                    (\mirror ->
                        List.filterMap
                            (\reflectedObserver ->
                                if mirror /= reflectedObserver.mirror then
                                    let
                                        reReflectedObserver : Observer
                                        reReflectedObserver =
                                            Observer.make
                                                (Line.mirroredPosition reflectedObserver.reflected.pos mirror.line)
                                                reflectedObserver.reflected.size
                                    in
                                    Line.intersection (Line.make reReflectedObserver.pos observer.pos) mirror.line
                                        |> Maybe.map
                                            (\intersectionPoint ->
                                                Reflection.make
                                                    { reflected = reReflectedObserver
                                                    , original = reflectedObserver.original
                                                    }
                                                    intersectionPoint
                                                    mirror
                                            )

                                else
                                    Nothing
                            )
                            reflectedObservers
                    )
                    mirrors
        in
        generateReflectedObserverReflections
            (depth + 1)
            maxDepth
            observer
            newReflectedObservers
            mirrors
            (allObserverReflections ++ newReflectedObservers)


generateObjectReflections : Observer -> List Object -> List Mirror -> List (Reflection Object)
generateObjectReflections observer objects mirrors =
    List.concatMap
        (\mirror ->
            List.filterMap
                (\object ->
                    let
                        reflectedObject =
                            { object | pos = Line.mirroredPosition object.pos mirror.line }
                    in
                    Line.intersection (Line.make reflectedObject.pos observer.pos) mirror.line
                        |> Maybe.map
                            (\intersectionPoint ->
                                Reflection.make
                                    { reflected = reflectedObject
                                    , original = object
                                    }
                                    intersectionPoint
                                    mirror
                            )
                )
                objects
        )
        mirrors


generateReflectedObjectReflections :
    Int
    -> Int
    -> Observer
    -> List (Reflection Object)
    -> List Mirror
    -> List (Reflection Object)
    -> List (Reflection Object)
generateReflectedObjectReflections depth maxDepth observer reflectedObjects mirrors allObjectReflections =
    if depth >= maxDepth then
        allObjectReflections

    else
        let
            newReflectedObjects : List (Reflection Object)
            newReflectedObjects =
                List.concatMap
                    (\mirror ->
                        List.filterMap
                            (\reflectedObject ->
                                if mirror /= reflectedObject.mirror then
                                    let
                                        reReflectedObject : Object
                                        reReflectedObject =
                                            Object.make
                                                (Line.mirroredPosition reflectedObject.reflected.pos mirror.line)
                                                reflectedObject.reflected.size
                                    in
                                    Line.intersection (Line.make reReflectedObject.pos observer.pos) mirror.line
                                        |> Maybe.map
                                            (\intersectionPoint ->
                                                Reflection.make
                                                    { reflected = reReflectedObject
                                                    , original = reflectedObject.original
                                                    }
                                                    intersectionPoint
                                                    mirror
                                            )

                                else
                                    Nothing
                            )
                            reflectedObjects
                    )
                    mirrors
        in
        generateReflectedObjectReflections
            (depth + 1)
            maxDepth
            observer
            newReflectedObjects
            mirrors
            (allObjectReflections ++ newReflectedObjects)


generateMirrorReflections : Observer -> List Mirror -> List (Reflection Mirror)
generateMirrorReflections observer mirrors =
    List.concatMap
        (\mirror ->
            List.filterMap
                (\mirror2 ->
                    if mirror /= mirror2 then
                        let
                            reflectedMirror =
                                Mirror.make
                                    (Line.mirroredPosition mirror2.line.p1 mirror.line)
                                    (Line.mirroredPosition mirror2.line.p2 mirror.line)

                            reflection intersectionPoint =
                                Reflection.make
                                    { reflected = reflectedMirror
                                    , original = mirror2
                                    }
                                    intersectionPoint
                                    mirror
                        in
                        case
                            ( Line.intersection (Line.make observer.pos reflectedMirror.line.p1) mirror.line
                            , Line.intersection (Line.make observer.pos reflectedMirror.line.p2) mirror.line
                            )
                        of
                            ( Just intersectionPoint, _ ) ->
                                Just <| reflection intersectionPoint

                            ( _, Just intersectionPoint ) ->
                                Just <| reflection intersectionPoint

                            _ ->
                                Nothing

                    else
                        Nothing
                )
                mirrors
        )
        mirrors


generateReflectedMirrorReflections :
    Int
    -> Int
    -> Observer
    -> List (Reflection Mirror)
    -> List Mirror
    -> List (Reflection Mirror)
    -> List (Reflection Mirror)
generateReflectedMirrorReflections depth maxDepth observer reflectedMirrors mirrors allMirrorReflections =
    if depth >= maxDepth then
        allMirrorReflections

    else
        let
            newReflectedMirrors =
                List.concatMap
                    (\mirror ->
                        List.filterMap
                            (\reflectedMirror ->
                                if mirror /= reflectedMirror.mirror then
                                    let
                                        reReflectedMirror =
                                            Mirror.make
                                                (Line.mirroredPosition reflectedMirror.reflected.line.p1 mirror.line)
                                                (Line.mirroredPosition reflectedMirror.reflected.line.p2 mirror.line)

                                        reflection intersectionPoint =
                                            Reflection.make
                                                { reflected = reReflectedMirror
                                                , original = reflectedMirror.original
                                                }
                                                intersectionPoint
                                                mirror
                                    in
                                    case
                                        ( Line.intersection (Line.make observer.pos reReflectedMirror.line.p1) mirror.line
                                        , Line.intersection (Line.make observer.pos reReflectedMirror.line.p2) mirror.line
                                        )
                                    of
                                        ( Just intersectionPoint, _ ) ->
                                            Just <| reflection intersectionPoint

                                        ( _, Just intersectionPoint ) ->
                                            Just <| reflection intersectionPoint

                                        _ ->
                                            Nothing

                                else
                                    Nothing
                            )
                            reflectedMirrors
                    )
                    mirrors
        in
        generateReflectedMirrorReflections
            (depth + 1)
            maxDepth
            observer
            newReflectedMirrors
            mirrors
            (allMirrorReflections ++ newReflectedMirrors)



-- RENDER


view : Context -> Browser.Document Msg
view ({ width, height } as ctx) =
    { title = "Sketch"
    , body =
        [ Canvas.toHtml
            ( round width, round height )
            [ style "display" "block"
            , style "border" "25px solid rgba(0, 0, 0, 0.05)"
            , Pointer.onDown (\event -> CanvasPointerDown event)
            , Pointer.onMove (\event -> CanvasPointerMove event)
            , Pointer.onUp (\event -> CanvasPointerUp event)
            ]
            [ clearScreen ctx
            , render ctx
            , renderTestPointer ctx
            ]
        ]
    }


clearScreen { width, height } =
    shapes [ fill Color.white ] [ rect ( 0, 0 ) width height ]


render : Context -> Renderable
render ({ frame, width, height, observer, objects, mirrors, lightRays, eyeSightRays, reflections } as ctx) =
    let
        centerPos =
            center ctx

        zoom =
            0.5
    in
    group [ transform [ translate centerPos.x centerPos.y, scale zoom zoom, translate -centerPos.x -centerPos.y ] ]
        [ group [ alpha 0.3 ] <| List.map (Reflection.render Mirror.render) reflections.mirrors
        , group [ alpha 0.3 ] <| List.map (Reflection.render Observer.render) reflections.observers
        , group [ alpha 0.3 ] <| List.map (Reflection.render Object.render) reflections.objects
        , group [ alpha 0.3 ] <| List.map (Reflection.render Mirror.render) reflections.mirrors
        , group [] <| List.map Mirror.render mirrors
        , group [] <| List.map Object.render objects
        , group [] [ Observer.render observer ]
        , group [] <| List.map (Ray.render Color.lightGreen 2) eyeSightRays
        , group [] <| List.map (Ray.render Color.lightYellow 3) lightRays
        ]


renderTestPointer : Context -> Renderable
renderTestPointer { testPointer } =
    testPointer
        |> Maybe.map
            (\pos ->
                group [ transform [ translate pos.x pos.y ] ]
                    [ shapes [ fill <| Color.hsla 0.15 1.0 0.5 0.3 ] [ circle ( 0, 0 ) 20 ]
                    , text
                        [ font { size = 12, family = "sans-serif" }
                        , align Center
                        , fill Color.black
                        ]
                        ( 0, -30 )
                        ("x: " ++ String.fromFloat pos.x ++ ", y: " ++ String.fromFloat pos.y)
                    ]
            )
        |> Maybe.withDefault (shapes [] [])



-- UTILITIES


center : { a | width : Float, height : Float } -> Vec2
center { width, height } =
    Vec2.vec2 (width / 2) (height / 2)


lerp : (Float -> Float) -> Float -> Float -> Float -> Float
lerp easing a b t =
    a + (b - a) * easing t
