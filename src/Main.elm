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
import Simulation
import Vec2 exposing (Vec2)


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type alias Flags =
    ()


type alias Model =
    Simulation.Context


type alias Msg =
    Simulation.Msg


init : Flags -> ( Model, Cmd Msg )
init _ =
    let
        space =
            50
    in
    Simulation.init
        { zoom = 0.5
        , maxRecursion = 4
        , showLightRays = False
        , showEyeSightRays = False
        , observer = { pos = { x = -space, y = space * 2 * 0.7 }, size = 30 }
        , objectSize = 30
        , objects =
            [ { x = -space, y = -space * 2 * 0.7 }
            , { x = 0, y = 0 }
            ]
        , mirrors =
            [ ( { x = space, y = -space * 2 }
              , { x = space, y = space * 2 }
              )
            , ( { x = -space * 2, y = -space * 2 }
              , { x = -space * 2, y = space * 2 }
              )
            , ( { x = space, y = -space * 2 }
              , { x = -space * 2, y = -space * 2 }
              )
            , ( { x = space, y = space * 2 }
              , { x = -space * 2, y = space * 2 }
              )
            ]
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Simulation.subscriptions model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    Simulation.update msg model


view : Model -> Browser.Document Msg
view model =
    { title = "Sketch"
    , body =
        [ Simulation.view model
        ]
    }
