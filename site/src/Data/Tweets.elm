module Data.Tweets exposing (..)

import Data.Votes
import Dict
import FlagLink exposing (Query(..), decodeQuery)
import Graph exposing (Edge, Node, NodeId)
import Http
import Json.Decode exposing (Decoder, field, int, list, string, succeed)
import Json.Decode.Pipeline exposing (decode, optional, required)
import List.Extra
import Regex
import Visualization.Force as Force


apiUrl : String
apiUrl =
    "http://localhost:8000"



-- Data.Votes.apiUrl


type alias TwitterUser =
    { id : String
    , screenName : String
    }


type alias IdAndUser =
    { id : String, user : TwitterUser }


type alias IdAndScreenName =
    { id : String, screenName : String }


type alias Tweet =
    { id : String
    , user : TwitterUser
    , retweet : Maybe IdAndUser
    }


type alias Entity =
    Force.Entity NodeId { value : IdAndScreenName }


initialGraph : Graph.Graph Entity ()
initialGraph =
    Graph.fromNodeLabelsAndEdgePairs [] []
        |> mapContexts


mapContexts : Graph.Graph a b -> Graph.Graph (Force.Entity Int { value : a }) b
mapContexts =
    Graph.mapContexts
        (\({ node } as ctx) ->
            { ctx | node = { label = Force.entity node.id node.label, id = node.id } }
        )


getTweetData : String -> Http.Request (List Tweet)
getTweetData query =
    let
        cleanQuery =
            case decodeQuery query of
                Url url ->
                    Regex.replace Regex.All (Regex.regex "https?://") (\_ -> "") url
                        |> Regex.replace Regex.All (Regex.regex "\\?.*") (\_ -> "")

                _ ->
                    query
    in
    Http.request
        { method = "GET"
        , headers = []
        , url = apiUrl ++ "/twitter/search?q=" ++ Http.encodeUri cleanQuery
        , body = Http.emptyBody
        , expect = Http.expectJson decodeTweets
        , timeout = Nothing
        , withCredentials = True
        }


decodeTweets : Decoder (List Tweet)
decodeTweets =
    let
        tweetDecoder : Decoder Tweet
        tweetDecoder =
            decode Tweet
                |> required "id_str" string
                |> required "user" twitterUserDecoder
                |> optional "retweeted_status" idAndUserDecoder Nothing

        twitterUserDecoder : Decoder TwitterUser
        twitterUserDecoder =
            decode TwitterUser
                |> required "id_str" string
                |> required "screen_name" string

        idAndUserDecoder : Decoder (Maybe IdAndUser)
        idAndUserDecoder =
            decode IdAndUser
                |> required "id_str" string
                |> required "user" twitterUserDecoder
                |> Json.Decode.map Just
    in
    field "statuses" (list tweetDecoder)


buildTweetsGraph : List Tweet -> Graph.Graph IdAndScreenName ()
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
                        Dict.insert tweet.id { id = tweet.id, index = index, screenName = tweet.screenName } indexedTweets
                    )
                    Dict.empty

        nodes =
            Dict.values indexedTweets
                |> List.map (\{ index, id, screenName } -> Node index { id = id, screenName = screenName })

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
