module TwitterGraph exposing (main)

{-| This demonstrates laying out the characters in Les Miserables
based on their co-occurence in a scene. Try dragging the nodes!
-}

import AnimationFrame
import Data.TweetsGraph exposing (..)
import Graph exposing (Edge, Graph, Node, NodeContext, NodeId)
import Html exposing (button, div)
import Html.Events exposing (on, onClick)
import Json.Decode as Decode
import Mouse exposing (Position)
import RemoteData exposing (..)
import Svg exposing (..)
import Svg.Attributes as Attr exposing (..)
import Time exposing (Time)
import Visualization.Force as Force exposing (State)


screenWidth : Float
screenWidth =
    990


screenHeight : Float
screenHeight =
    504


type Msg
    = DragStart NodeId Position
    | DragAt Position
    | DragEnd Position
    | Tick Time
    | LoadTweets
    | TweetsResponse (WebData String)


type alias Model =
    { drag : Maybe Drag
    , tweetsData : WebData String
    , graph : Graph Entity ()
    , simulation : Force.State NodeId
    }


type alias Drag =
    { start : Position
    , current : Position
    , index : NodeId
    }


generateForces : Graph n e -> State Int
generateForces graph =
    let
        link { from, to } =
            ( from, to )
    in
    [ Force.links <| List.map link <| Graph.edges graph
    , Force.manyBody <| List.map .id <| Graph.nodes graph
    , Force.center (screenWidth / 2) (screenHeight / 2)
    ]
        |> Force.simulation


init : ( Model, Cmd Msg )
init =
    ( { drag = Nothing
      , tweetsData = NotAsked
      , graph = initialGraph
      , simulation = generateForces initialGraph
      }
    , Cmd.none
    )


updateNode : Position -> NodeContext Entity () -> NodeContext Entity ()
updateNode pos nodeCtx =
    let
        nodeValue =
            nodeCtx.node.label
    in
    updateContextWithValue nodeCtx { nodeValue | x = toFloat pos.x, y = toFloat pos.y }


updateContextWithValue : NodeContext Entity () -> Entity -> NodeContext Entity ()
updateContextWithValue nodeCtx value =
    let
        node =
            nodeCtx.node
    in
    { nodeCtx | node = { node | label = value } }


updateGraphWithList : Graph Entity () -> List Entity -> Graph Entity ()
updateGraphWithList =
    let
        graphUpdater value =
            Maybe.map (\ctx -> updateContextWithValue ctx value)
    in
    List.foldr (\node graph -> Graph.update node.id (graphUpdater node) graph)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ drag, graph, simulation } as model) =
    case msg of
        Tick t ->
            let
                ( newState, list ) =
                    Force.tick simulation <| List.map .label <| Graph.nodes graph
            in
            case drag of
                Nothing ->
                    ( { model | graph = updateGraphWithList graph list, simulation = newState }, Cmd.none )

                Just { current, index } ->
                    ( { model
                        | graph =
                            Graph.update index (Maybe.map (updateNode current)) (updateGraphWithList graph list)
                        , simulation = newState
                      }
                    , Cmd.none
                    )

        DragStart index xy ->
            ( { model | drag = Just (Drag xy xy index) }, Cmd.none )

        DragAt xy ->
            case drag of
                Just { start, index } ->
                    ( { model
                        | drag = Just (Drag start xy index)
                        , graph = Graph.update index (Maybe.map (updateNode xy)) graph
                        , simulation = Force.reheat simulation
                      }
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none )

        DragEnd xy ->
            case drag of
                Just { start, index } ->
                    ( { model | drag = Nothing, graph = Graph.update index (Maybe.map (updateNode xy)) graph }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        LoadTweets ->
            ( { model | tweetsData = Loading }
            , getTweetData
                |> RemoteData.sendRequest
                |> Cmd.map TweetsResponse
            )

        TweetsResponse response ->
            ( { model
                | tweetsData = response
                , graph = graphFromTweets
                , simulation = generateForces graphFromTweets
              }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.drag of
        Nothing ->
            -- This allows us to save resources, as if the simulation is done, there is no point in subscribing
            -- to the rAF.
            if Force.isCompleted model.simulation then
                Sub.none
            else
                AnimationFrame.times Tick

        Just _ ->
            Sub.batch [ Mouse.moves DragAt, Mouse.ups DragEnd, AnimationFrame.times Tick ]


onMouseDown : NodeId -> Attribute Msg
onMouseDown index =
    on "mousedown" (Decode.map (DragStart index) Mouse.position)


linkElement graph edge =
    let
        source =
            Maybe.withDefault (Force.entity 0 "") <| Maybe.map (.node >> .label) <| Graph.get edge.from graph

        target =
            Maybe.withDefault (Force.entity 0 "") <| Maybe.map (.node >> .label) <| Graph.get edge.to graph
    in
    line
        [ strokeWidth "1"
        , stroke "#aaa"
        , x1 (toString source.x)
        , y1 (toString source.y)
        , x2 (toString target.x)
        , y2 (toString target.y)
        ]
        []


nodeElement node =
    circle
        [ r "5.0"
        , fill "#000"
        , stroke "transparent"
        , strokeWidth "7px"
        , onMouseDown node.id
        , cx (toString node.label.x)
        , cy (toString node.label.y)
        ]
        [ Svg.title [] [ text node.label.value ] ]


view : Model -> Svg Msg
view model =
    div []
        [ svg
            [ width (toString screenWidth ++ "px"), height (toString screenHeight ++ "px") ]
            [ g [ class "links" ] <| List.map (linkElement model.graph) <| Graph.edges model.graph
            , g [ class "nodes" ] <| List.map nodeElement <| Graph.nodes model.graph
            ]
        , button [ onClick LoadTweets ] [ Html.text "Load data" ]
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



{- {"delay": 5001} -}
