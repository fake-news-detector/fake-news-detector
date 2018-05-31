module TwitterGraph exposing (..)

{-| This demonstrates laying out the characters in Les Miserables
based on their co-occurence in a scene. Try dragging the nodes!
-}

import AnimationFrame
import Data.Tweets exposing (..)
import Element exposing (..)
import Element.Attributes exposing (px)
import Graph exposing (Edge, Graph, Node, NodeContext, NodeId)
import Html exposing (button, div)
import Html.Attributes exposing (attribute)
import Html.Events exposing (on, onClick, onMouseEnter, onMouseLeave)
import Html.Lazy
import Http
import RemoteData exposing (..)
import Stylesheet exposing (..)
import Svg exposing (..)
import Svg.Attributes as Attr exposing (..)
import Time exposing (Time)
import Visualization.Force as Force exposing (State)


screenWidth : Float
screenWidth =
    600


screenHeight : Float
screenHeight =
    504


type Msg
    = Tick Time
    | LoadTweets String
    | TweetsResponse (WebData (List Tweet))
    | MouseOver NodeId
    | MouseLeave NodeId


type alias Model =
    { tweetsData : WebData ()
    , graph : Graph Entity ()
    , simulation : Force.State NodeId
    , highlightedNode : Maybe NodeId
    }


generateForces : Graph n e -> State Int
generateForces graph =
    let
        links =
            graph
                |> Graph.edges
                |> List.map (\{ from, to } -> { source = from, target = to, distance = 20, strength = Just 1.5 })
    in
    [ Force.customLinks 1 links
    , Force.manyBodyStrength -45 <| List.map .id <| Graph.nodes graph
    , Force.center (screenWidth / 2) (screenHeight / 2)
    ]
        |> Force.simulation
        |> Force.iterations 12


init : Model
init =
    { tweetsData = NotAsked
    , graph = initialGraph
    , simulation = generateForces initialGraph
    , highlightedNode = Nothing
    }


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
update msg ({ graph, simulation } as model) =
    case msg of
        Tick t ->
            let
                ( newState, list ) =
                    Force.tick simulation <| List.map .label <| Graph.nodes graph
            in
            ( { model | graph = updateGraphWithList graph list, simulation = newState }, Cmd.none )

        LoadTweets query ->
            ( { model | tweetsData = Loading }
            , getTweetData query
                |> RemoteData.sendRequest
                |> Cmd.map TweetsResponse
            )

        TweetsResponse response ->
            let
                graph =
                    case response of
                        Success tweets ->
                            buildTweetsGraph tweets
                                |> mapContexts

                        _ ->
                            model.graph
            in
            ( { model
                | tweetsData = RemoteData.map (always ()) response
                , graph = graph
                , simulation = generateForces graph
              }
            , Cmd.none
            )

        MouseOver nodeId ->
            ( { model | highlightedNode = Just nodeId }, Cmd.none )

        MouseLeave nodeId ->
            ( { model | highlightedNode = Nothing }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    if Force.isCompleted model.simulation then
        Sub.none
    else
        AnimationFrame.times Tick


linkElement : Graph Entity () -> { b | from : NodeId, to : NodeId } -> Svg msg
linkElement graph edge =
    let
        getEntity id =
            Graph.get id graph
                |> Maybe.map (.node >> .label)
                |> Maybe.withDefault (Force.entity 0 { id = "", screenName = "" })

        source =
            getEntity edge.from

        target =
            getEntity edge.to
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


nodeElement : Maybe NodeId -> Graph Entity () -> { c | label : { b | x : Float, y : number, value : IdAndScreenName }, id : NodeId } -> Svg Msg
nodeElement highlightedNode graph node =
    let
        connectionsCount =
            Graph.edges graph
                |> List.filter (\{ to } -> to == node.id)
                |> List.length

        nodeSize =
            (3 + toFloat connectionsCount * 0.2)
                |> Basics.min 10

        nodeText =
            Svg.text_
                [ x (toString <| node.label.x + nodeSize + 5)
                , y (toString <| node.label.y + 5)
                , Attr.style "font-family: sans-serif; font-size: 14px"
                ]
                [ Svg.text node.label.value.screenName ]

        nodeRect =
            rect
                [ x (toString <| node.label.x - 11)
                , y (toString <| node.label.y - 11)
                , width (toString <| 25 + String.length node.label.value.screenName * 9)
                , height (toString <| 22)
                , rx (toString 10)
                , ry (toString 10)
                , fill "#FFF"
                , stroke "#333"
                ]
                []

        nodeCircle =
            Svg.circle
                [ r (toString nodeSize)
                , fill "#FFF"
                , stroke "#000"
                , strokeWidth "1px"
                , cx (toString node.label.x)
                , cy (toString node.label.y)
                ]
                [ Svg.title [] [ Svg.text node.label.value.screenName ]
                ]
    in
    a
        [ onMouseEnter (MouseOver node.id)
        , onMouseLeave (MouseLeave node.id)
        , attribute "href" ("https://twitter.com/" ++ node.label.value.screenName ++ "/status/" ++ node.label.value.id)
        , target "_blank"
        ]
        (case ( highlightedNode == Just node.id, connectionsCount > 4 ) of
            ( True, _ ) ->
                [ nodeRect, nodeText, nodeCircle ]

            ( False, True ) ->
                [ nodeText, nodeCircle ]

            ( False, False ) ->
                [ nodeCircle ]
        )


view : String -> Model -> Element Classes variation Msg
view locationHref model =
    column NoStyle
        [ Element.Attributes.spacing 10 ]
        [ bold "Disseminação no Twitter"
        , tweetsDataResults locationHref model
        ]


tweetsDataResults : String -> Model -> Element Classes variation Msg
tweetsDataResults locationHref model =
    case model.tweetsData of
        NotAsked ->
            empty

        Success _ ->
            if Graph.isEmpty model.graph then
                Element.text "Nenhum tweet encontrado"
            else
                column NoStyle
                    []
                    [ Element.text "Veja como isso está se espalhando pelo twitter"
                    , Element.html <|
                        Html.Lazy.lazy2 drawGraph model.highlightedNode model.graph
                    ]

        Loading ->
            Element.text "Carregando tweets..."

        Failure _ ->
            column NoStyle
                [ Element.Attributes.spacing 8 ]
                [ Element.text "Para buscar a disseminação deste link precisamos que você faça login com a sua conta do Twitter"
                , twitterSignInButton locationHref
                ]


drawGraph : Maybe NodeId -> Graph Entity () -> Html.Html Msg
drawGraph highlightedNode graph =
    div []
        [ svg
            [ width (toString screenWidth ++ "px"), height (toString screenHeight ++ "px") ]
            [ g [ class "links" ] <| List.map (linkElement graph) <| Graph.edges graph
            , g [ class "nodes" ] <| List.map (nodeElement highlightedNode graph) <| Graph.nodes graph
            ]
        ]


twitterSignInButton : String -> Element Classes variation msg
twitterSignInButton locationHref =
    link (apiUrl ++ "/twitter/auth?return_to=" ++ Http.encodeUri locationHref)
        (Element.button TwitterButton
            [ Element.Attributes.padding 6 ]
            (row NoStyle
                [ Element.Attributes.verticalCenter ]
                [ el TwitterIcon
                    [ Element.Attributes.width (px 20)
                    , Element.Attributes.height (px 20)
                    ]
                    empty
                , el NoStyle
                    [ Element.Attributes.paddingLeft 5 ]
                    (bold "Entrar com Twitter")
                ]
            )
        )
