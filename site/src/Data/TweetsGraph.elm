module Data.TweetsGraph exposing (..)

import Graph exposing (NodeId)
import Http
import Json.Decode exposing (Decoder, field, int, list, string, succeed)
import Json.Decode.Pipeline exposing (decode, optional, required)
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


graphFromTweets : Graph.Graph Entity ()
graphFromTweets =
    Graph.fromNodeLabelsAndEdgePairs
        [ "Foo"
        , "Bar"
        , "Baz"
        ]
        [ ( 1, 0 )
        ]
        |> mapContexts


mapContexts : Graph.Graph a b -> Graph.Graph (Force.Entity Int { value : a }) b
mapContexts =
    Graph.mapContexts
        (\({ node } as ctx) ->
            { ctx | node = { label = Force.entity node.id node.label, id = node.id } }
        )


getTweetData : Http.Request String
getTweetData =
    Http.get "/src/sample.json" (succeed "foo")


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
