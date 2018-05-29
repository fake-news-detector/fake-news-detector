module Data.TweetsGraph exposing (..)

import Dict
import Graph exposing (Edge, Node, NodeId)
import Http
import Json.Decode exposing (Decoder, field, int, list, string, succeed)
import Json.Decode.Pipeline exposing (decode, optional, required)
import List.Extra
import Visualization.Force as Force


type alias TwitterUser =
    { id : Int
    , screenName : String
    }


type alias IdAndUser =
    { id : Int, user : TwitterUser }


type alias Tweet =
    { id : Int
    , user : TwitterUser
    , retweet : Maybe IdAndUser
    }


type alias Entity =
    Force.Entity NodeId { value : String }


initialGraph : Graph.Graph Entity ()
initialGraph =
    Graph.fromNodeLabelsAndEdgePairs [] []
        |> mapContexts


sampleGraph : Graph.Graph Entity ()
sampleGraph =
    Graph.fromNodesAndEdges
        [ Node 1 "Foo", Node 2 "Bar", Node 3 "Baz" ]
        [ Edge 1 2 () ]
        |> mapContexts


mapContexts : Graph.Graph a b -> Graph.Graph (Force.Entity Int { value : a }) b
mapContexts =
    Graph.mapContexts
        (\({ node } as ctx) ->
            { ctx | node = { label = Force.entity node.id node.label, id = node.id } }
        )


getTweetData : Http.Request (List Tweet)
getTweetData =
    Http.get "/src/sample.json" decodeTweets


decodeTweets : Decoder (List Tweet)
decodeTweets =
    let
        tweetDecoder : Decoder Tweet
        tweetDecoder =
            decode Tweet
                |> required "id" int
                |> required "user" twitterUserDecoder
                |> optional "retweeted_status" idAndUserDecoder Nothing

        twitterUserDecoder : Decoder TwitterUser
        twitterUserDecoder =
            decode TwitterUser
                |> required "id" int
                |> required "screen_name" string

        idAndUserDecoder : Decoder (Maybe IdAndUser)
        idAndUserDecoder =
            decode IdAndUser
                |> required "id" int
                |> required "user" twitterUserDecoder
                |> Json.Decode.map Just
    in
    field "statuses" (list tweetDecoder)


buildTweetsGraph : List Tweet -> Graph.Graph String ()
buildTweetsGraph tweets =
    let
        indexedTweets =
            tweets
                |> List.concatMap
                    (\tweet ->
                        tweet.retweet
                            |> Maybe.map (\rt -> [ { id = rt.id, screenName = rt.user.screenName } ])
                            |> Maybe.withDefault []
                            |> flip (++) [ { id = tweet.id, screenName = tweet.user.screenName } ]
                    )
                |> List.Extra.uniqueBy .id
                |> List.reverse
                |> List.Extra.indexedFoldl
                    (\index tweet indexedTweets ->
                        Dict.insert tweet.id { index = index, screenName = tweet.screenName } indexedTweets
                    )
                    Dict.empty

        nodes =
            Dict.values indexedTweets
                |> List.map (\{ index, screenName } -> Node index screenName)

        getTweetIndex { id } =
            Dict.get id indexedTweets
                |> Maybe.map .index
                |> Maybe.withDefault 0

        edges =
            tweets
                |> List.concatMap
                    (\tweet ->
                        case tweet.retweet of
                            Just retweet ->
                                [ Edge (getTweetIndex tweet) (getTweetIndex retweet) () ]

                            Nothing ->
                                []
                    )
    in
    Graph.fromNodesAndEdges nodes edges
