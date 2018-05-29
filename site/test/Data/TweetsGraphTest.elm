module Data.TweetsGraphTest exposing (..)

import Data.TweetsGraph exposing (..)
import Expect exposing (Expectation)
import Graph exposing (Edge, Node)
import Json.Decode exposing (decodeString)
import Test exposing (..)


suite : Test
suite =
    describe "TweetsGraph"
        [ describe "decode tweet"
            [ test "decode without retweet" <|
                \_ ->
                    decodeString decodeTweets sampleJsonWithoutRetweet
                        |> Expect.equal
                            (Ok
                                [ { id = "1000933688572555264"
                                  , user =
                                        { id = "708092973716807682"
                                        , screenName = "tuliovsky"
                                        }
                                  , retweet = Nothing
                                  }
                                ]
                            )
            , test "decode with retweet" <|
                \_ ->
                    decodeString decodeTweets sampleJsonWithRetweet
                        |> Expect.equal
                            (Ok
                                [ { id = "1000933688572555264"
                                  , user =
                                        { id = "708092973716807682"
                                        , screenName = "tuliovsky"
                                        }
                                  , retweet =
                                        Just
                                            { id = "1000857125235642368"
                                            , user =
                                                { id = "758519817578086400"
                                                , screenName = "Desesquerdizada"
                                                }
                                            }
                                  }
                                ]
                            )
            ]
        , describe "build graphs"
            [ test "build simple graph" <|
                \_ ->
                    buildTweetsGraph tweetsSample
                        |> Expect.equal
                            (Graph.fromNodesAndEdges
                                [ Node 0 { id = "1000928922870132736", screenName = "Ricardo_Obadiah" }
                                , Node 1 { id = "1000933688572555264", screenName = "tuliovsky" }
                                , Node 2 { id = "1000857125235642368", screenName = "Desesquerdizada" }
                                ]
                                [ Edge 0 2 ()
                                , Edge 1 2 ()
                                ]
                            )
            , test "add retweeted user to graph even when not present" <|
                \_ ->
                    buildTweetsGraph tweetsSampleWithoutRetweetRoot
                        |> Expect.equal
                            (Graph.fromNodesAndEdges
                                [ Node 0 { id = "1000928922870132736", screenName = "Ricardo_Obadiah" }
                                , Node 1 { id = "1000933688572555264", screenName = "tuliovsky" }
                                , Node 2 { id = "1000857125235642368", screenName = "Desesquerdizada" }
                                ]
                                [ Edge 0 2 ()
                                , Edge 1 2 ()
                                ]
                            )
            , test "put the most connected nodes at the end" <|
                \_ ->
                    buildTweetsGraph tweetsSampleWithoutRetweetRoot
                        |> Graph.nodes
                        |> List.drop 2
                        |> Expect.equal [ Node 2 { id = "1000857125235642368", screenName = "Desesquerdizada" } ]
            ]
        ]


sampleJsonWithoutRetweet : String
sampleJsonWithoutRetweet =
    """
{
    "statuses": [
        {
            "id_str": "1000933688572555264",
            "user": {
                "id_str": "708092973716807682",
                "screen_name": "tuliovsky"
            }
        }
    ]
}
"""


sampleJsonWithRetweet : String
sampleJsonWithRetweet =
    """
{
    "statuses": [
        {
            "id_str": "1000933688572555264",
            "user": {
                "id_str": "708092973716807682",
                "screen_name": "tuliovsky"
            },
            "retweeted_status": {
                "id_str": "1000857125235642368",
                "user": {
                    "id_str": "758519817578086400",
                    "screen_name": "Desesquerdizada"
                }
            }
        }
    ]
}
"""


tweetsSample : List Tweet
tweetsSample =
    [ { id = "1000857125235642368"
      , user =
            { id = "758519817578086400"
            , screenName = "Desesquerdizada"
            }
      , retweet = Nothing
      }
    , { id = "1000933688572555264"
      , user =
            { id = "708092973716807682"
            , screenName = "tuliovsky"
            }
      , retweet =
            Just
                { id = "1000857125235642368"
                , user =
                    { id = "758519817578086400"
                    , screenName = "Desesquerdizada"
                    }
                }
      }
    , { id = "1000928922870132736"
      , user =
            { id = "169545469"
            , screenName = "Ricardo_Obadiah"
            }
      , retweet =
            Just
                { id = "1000857125235642368"
                , user =
                    { id = "758519817578086400"
                    , screenName = "Desesquerdizada"
                    }
                }
      }
    ]


tweetsSampleWithoutRetweetRoot : List Tweet
tweetsSampleWithoutRetweetRoot =
    [ { id = "1000933688572555264"
      , user =
            { id = "708092973716807682"
            , screenName = "tuliovsky"
            }
      , retweet =
            Just
                { id = "1000857125235642368"
                , user =
                    { id = "758519817578086400"
                    , screenName = "Desesquerdizada"
                    }
                }
      }
    , { id = "1000928922870132736"
      , user =
            { id = "169545469"
            , screenName = "Ricardo_Obadiah"
            }
      , retweet =
            Just
                { id = "1000857125235642368"
                , user =
                    { id = "758519817578086400"
                    , screenName = "Desesquerdizada"
                    }
                }
      }
    ]
