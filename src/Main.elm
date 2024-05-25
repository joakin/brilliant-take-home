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
        observerReflections =
            generateObserverReflections ctx.observer ctx.mirrors

        objectReflections =
            generateObjectReflections ctx.observer ctx.objects ctx.mirrors
    in
    { ctx
        | reflections =
            { reflections
                | observers = observerReflections
                , objects = objectReflections
                , mirrors = []
            }
        , lightRays =
            observerReflections
                |> List.map
                    (\reflection ->
                        Ray.makeFromSegments
                            [ Line.make
                                reflection.original.pos
                                reflection.intersection
                                |> Line.displace -5
                            , Line.make
                                reflection.intersection
                                reflection.original.pos
                                |> Line.displace 0
                            ]
                    )
        , eyeSightRays =
            observerReflections
                |> List.map
                    (\reflection ->
                        Ray.makeFromSegments
                            [ Line.make
                                ctx.observer.pos
                                reflection.intersection
                                |> Line.displace 5
                            , Line.make
                                reflection.intersection
                                reflection.reflected.pos
                                |> Line.displace 5
                            ]
                    )
    }


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
render { frame, width, height, observer, objects, mirrors, lightRays, eyeSightRays, reflections } =
    group []
        [ group [ alpha 0.3 ] <| List.map (Reflection.render Observer.render) reflections.observers
        , group [ alpha 0.3 ] <| List.map (Reflection.render Object.render) reflections.objects
        , group [ alpha 0.3 ] <| List.map (Reflection.render Mirror.render) reflections.mirrors
        , group [] <| List.map Mirror.render mirrors
        , group [] <| List.map Object.render objects
        , group [] [ Observer.render observer ]
        , group [] <| List.map (Ray.render Color.lightGreen) eyeSightRays
        , group [] <| List.map (Ray.render Color.lightYellow) lightRays
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
