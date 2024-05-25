module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import List.Extra
import Simulation


simulationsAndContent =
    let
        space =
            50
    in
    [ ( [ h1 [] [ text "You and the mirror" ]
        , p [] [ text "Light bounces off you to the mirror, and back to your eyes. " ]
        , br [] []
        , p [] [ b [] [ text "ℹ️  Drag the observer circle to move it." ] ]
        , p [] [ b [] [ text "🐞 For the demo, stay within the confines of the mirrors!" ] ]
        ]
      , Simulation.init
            { zoom = 1
            , maxRecursion = 1
            , showLightRays = True
            , showEyeSightRays = True
            , observer = { pos = { x = -space, y = space * 2 * 0.7 }, size = 30 }
            , objectSize = 30
            , objects = []
            , mirrors =
                [ ( { x = space, y = -space * 2 }
                  , { x = space, y = space * 2 }
                  )
                ]
            }
      )
    , ( [ h1 [] [ text "You and one object" ]
        , p [] [ text "Light bounces off the object to the mirror, and back to your eyes. " ]
        , p [] [ text "Angles are the same in the light rays on the mirror." ]
        , p [] [ text "If the object is further away, notice how the intersection point is not the center." ]
        , p [] [ text "Move further down or up away from the mirror and notice how you still see the virtual object." ]
        , br [] []
        , p [] [ b [] [ text "ℹ️  Drag the observer circle to move it." ] ]
        , p [] [ b [] [ text "🐞 For the demo, stay within the confines of the mirrors!" ] ]
        ]
      , Simulation.init
            { zoom = 1
            , maxRecursion = 1
            , showLightRays = True
            , showEyeSightRays = True
            , observer = { pos = { x = -space, y = space * 2 * 0.7 }, size = 30 }
            , objectSize = 30
            , objects =
                [ { x = -space, y = -space * 2 * 0.7 }
                ]
            , mirrors =
                [ ( { x = space, y = -space * 2 }
                  , { x = space, y = space * 2 }
                  )
                ]
            }
      )
    , ( [ h1 [] [ text "Two mirrors!" ]
        , p [] [ text "With two mirrors in parallel, you can see the reflections on both mirrors." ]
        , p [] [ text "Notice how the angles are the same in the light rays on both mirrors." ]
        , p [] [ text "Move the observer and see how the reflections change in different direction in the different virtual rooms." ]
        , br [] []
        , p [] [ b [] [ text "ℹ️  Drag the observer circle to move it" ] ]
        , p [] [ b [] [ text "🐞 For the demo, stay within the confines of the mirrors!" ] ]
        ]
      , Simulation.init
            { zoom = 1
            , maxRecursion = 0
            , showLightRays = True
            , showEyeSightRays = True
            , observer = { pos = { x = -space, y = space * 2 * 0.7 }, size = 30 }
            , objectSize = 30
            , objects =
                [ { x = -space, y = -space * 2 * 0.7 }
                ]
            , mirrors =
                [ ( { x = space, y = -space * 2 }
                  , { x = space, y = space * 2 }
                  )
                , ( { x = -space * 2, y = -space * 2 }
                  , { x = -space * 2, y = space * 2 }
                  )
                ]
            }
      )
    , ( [ h1 [] [ text "Infinite reflections" ]
        , p [] [ text "If we zoom out, you can see two mirrors in parallel make infinite reflections." ]
        , p [] [ text "At least, as long as you are in the right place to see them." ]
        , p [] [ text "Try moving around to limit the number of reflections you see." ]
        , br [] []
        , p [] [ b [] [ text "ℹ️  Drag the observer circle to move it" ] ]
        , p [] [ b [] [ text "🐞 For the demo, stay within the confines of the mirrors!" ] ]
        ]
      , Simulation.init
            { zoom = 0.6
            , maxRecursion = 4
            , showLightRays = False
            , showEyeSightRays = True
            , observer = { pos = { x = -space, y = space * 2 * 0.7 }, size = 30 }
            , objectSize = 30
            , objects =
                [ { x = -space, y = -space * 2 * 0.7 }
                ]
            , mirrors =
                [ ( { x = space, y = -space * 2 }
                  , { x = space, y = space * 2 }
                  )
                , ( { x = -space * 2, y = -space * 2 }
                  , { x = -space * 2, y = space * 2 }
                  )
                ]
            }
      )
    , ( [ h1 [] [ text "3 mirrors" ]
        , p [] [ text "If we add one more mirror, you can see new virtual rooms appearing on another dimension as well." ]
        , p [] [ text "Try moving around and see how the virtual objects react." ]
        , br [] []
        , p [] [ b [] [ text "ℹ️  Drag the observer circle to move it" ] ]
        , p [] [ b [] [ text "🐞 For the demo, stay within the confines of the mirrors!" ] ]
        ]
      , Simulation.init
            { zoom = 0.5
            , maxRecursion = 4
            , showLightRays = False
            , showEyeSightRays = False
            , observer = { pos = { x = -space, y = space * 2 * 0.7 }, size = 30 }
            , objectSize = 30
            , objects =
                [ { x = -space, y = -space * 2 * 0.7 }
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
                ]
            }
      )
    , ( [ h1 [] [ text "Surrounded by mirrors" ]
        , p [] [ text "♾️. Infinite reflections!" ]
        , br [] []
        , p [] [ b [] [ text "ℹ️  Drag the observer circle to move it" ] ]
        , p [] [ b [] [ text "🐞 For the demo, stay within the confines of the mirrors!" ] ]
        ]
      , Simulation.init
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
      )
    ]


content =
    List.unzip simulationsAndContent |> Tuple.first


simulations =
    List.unzip simulationsAndContent |> Tuple.second



-- MAIN PROGRAM SETUP


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
    List Simulation.Context


type Msg
    = SimulationMsg Int Simulation.Msg


init : Flags -> ( Model, Cmd Msg )
init _ =
    simulations
        |> List.unzip
        |> (\( contexts, cmds ) ->
                ( contexts
                , cmds
                    |> List.indexedMap
                        (\i cmd ->
                            Cmd.map (SimulationMsg i) cmd
                        )
                    |> Cmd.batch
                )
           )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        (model
            |> List.indexedMap
                (\i sim ->
                    Simulation.subscriptions sim
                        |> Sub.map (SimulationMsg i)
                )
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SimulationMsg i simMsg ->
            model
                |> List.indexedMap
                    (\j sim ->
                        if i == j then
                            Simulation.update simMsg sim
                                |> Tuple.mapSecond (Cmd.map (SimulationMsg i))

                        else
                            ( sim, Cmd.none )
                    )
                |> List.unzip
                |> Tuple.mapSecond Cmd.batch


view : Model -> Browser.Document Msg
view model =
    { title = "Sketch"
    , body =
        [ div [ class "simulations" ]
            (List.Extra.zip content model
                |> List.indexedMap
                    (\i ( info, sim ) ->
                        div [ class "simulation" ]
                            [ div [] info
                            , Simulation.view sim
                                |> Html.map (SimulationMsg i)
                            ]
                    )
            )
        ]
    }
