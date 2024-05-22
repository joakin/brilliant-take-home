module Main exposing (..)

import Browser
import Browser.Events
import Canvas exposing (..)
import Canvas.Settings exposing (..)
import Canvas.Settings.Advanced exposing (..)
import Color
import Extra.Vec2 as Vec2
import Html exposing (div)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Html.Events.Extra.Pointer as Pointer
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
    }


type Msg
    = Frame Float
    | CanvasPointerDown Pointer.Event
    | CanvasPointerMove Pointer.Event
    | CanvasPointerUp Pointer.Event


init : Flags -> ( Context, Cmd Msg )
init _ =
    ( { width = 500
      , height = 500
      , frame = 0
      , delta = 0
      , testPointer = Nothing
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
render { frame, width, height } =
    let
        centerX =
            width / 2

        centerY =
            height / 2

        size =
            width / 3

        x =
            -(size / 2)

        y =
            -(size / 2)
    in
    shapes
        [ transform
            [ translate centerX centerY
            , rotate (degrees (frame / 3))
            ]
        , fill (Color.hsl (sin <| frame / 1000) 0.7 0.7)
        ]
        [ rect ( x, y ) size size ]


renderTestPointer : Context -> Renderable
renderTestPointer { testPointer } =
    testPointer
        |> Maybe.map (\pos -> shapes [ fill Color.red ] [ circle (Vec2.toTuple pos) 10 ])
        |> Maybe.withDefault (shapes [] [])
