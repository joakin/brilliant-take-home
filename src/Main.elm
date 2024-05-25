module Main exposing (..)

import Browser
import Browser.Events
import Canvas exposing (..)
import Canvas.Settings exposing (..)
import Canvas.Settings.Advanced exposing (..)
import Canvas.Settings.Text exposing (..)
import Color
import Extra.Vec2 as Vec2
import Html exposing (div)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Html.Events.Extra.Pointer as Pointer
import LightRay exposing (LightRay)
import Line
import Mirror exposing (Mirror)
import Object exposing (Object)
import Observer exposing (Observer)
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
    , delta : Float
    , testPointer : Maybe Vec2
    , observer : Observer
    , objects : List Object
    , mirrors : List Mirror
    , lightRays : List LightRay
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
    in
    ( { width = dimensions.width
      , height = dimensions.height
      , frame = 0
      , delta = 0
      , testPointer = Nothing
      , observer = Observer.make (centerPos |> Vec2.add { x = -space, y = space * 2 * 0.7 }) size
      , objects =
            [ Object.make
                (centerPos
                    |> Vec2.add (Vec2.vec2 -space (-space * 2 * 0.7))
                )
                size
            ]
      , mirrors =
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
      , lightRays =
            [ LightRay.make
                (centerPos
                    |> Vec2.add (Vec2.vec2 (-space * 2) -space)
                )
                (centerPos
                    |> Vec2.add (Vec2.vec2 (space * 2) -space)
                )
            , LightRay.makeFromSegments
                -- Object pos
                [ Line.make
                    (centerPos |> Vec2.add (Vec2.vec2 -space (-space * 2 * 0.7)))
                    (centerPos |> Vec2.add (Vec2.vec2 space 0))

                -- to Observer pos
                , Line.make
                    (centerPos |> Vec2.add (Vec2.vec2 space 0))
                    (centerPos |> Vec2.add { x = -space, y = space * 2 * 0.7 })
                ]
            ]
      }
    , Cmd.none
    )


subscriptions : Context -> Sub Msg
subscriptions ctx =
    Browser.Events.onAnimationFrameDelta Frame


update : Msg -> Context -> ( Context, Cmd Msg )
update msg ctx =
    case msg of
        Frame delta ->
            ( { ctx
                | frame = ctx.frame + 1
                , delta = delta
              }
            , Cmd.none
            )

        CanvasPointerDown event ->
            ( { ctx | testPointer = Just <| Vec2.fromTuple event.pointer.offsetPos }, Cmd.none )

        CanvasPointerMove event ->
            ( { ctx
                | testPointer =
                    ctx.testPointer
                        |> Maybe.map (\_ -> Vec2.fromTuple event.pointer.offsetPos)
              }
            , Cmd.none
            )

        CanvasPointerUp event ->
            ( { ctx | testPointer = Nothing }, Cmd.none )


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
render { frame, width, height, observer, objects, mirrors, lightRays } =
    group []
        (List.concat
            [ List.map Mirror.render mirrors
            , List.map Object.render objects
            , [ Observer.render observer ]
            , List.map LightRay.render lightRays
            ]
        )


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


center : { a | width : Float, height : Float } -> Vec2
center { width, height } =
    Vec2.vec2 (width / 2) (height / 2)
