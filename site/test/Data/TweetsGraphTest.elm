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
                                [ { id = 1000933688572555300
                                  , user =
                                        { id = 708092973716807700
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
                                [ { id = 1000933688572555300
                                  , user =
                                        { id = 708092973716807700
                                        , screenName = "tuliovsky"
                                        }
                                  , retweet =
                                        Just
                                            { id = 1000857125235642400
                                            , user =
                                                { id = 758519817578086400
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
                                [ Node 0 "Ricardo_Obadiah"
                                , Node 1 "tuliovsky"
                                , Node 2 "Desesquerdizada"
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
                                [ Node 0 "Ricardo_Obadiah"
                                , Node 1 "tuliovsky"
                                , Node 2 "Desesquerdizada"
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
                        |> Expect.equal [ Node 2 "Desesquerdizada" ]
            ]
        ]


sampleJsonWithoutRetweet : String
sampleJsonWithoutRetweet =
    """
{
    "statuses": [
        {
            "id": 1000933688572555300,
            "user": {
                "id": 708092973716807700,
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
            "id": 1000933688572555300,
            "user": {
                "id": 708092973716807700,
                "screen_name": "tuliovsky"
            },
            "retweeted_status": {
                "id": 1000857125235642400,
                "user": {
                    "id": 758519817578086400,
                    "screen_name": "Desesquerdizada"
                }
            }
        }
    ]
}
"""


tweetsSample : List Tweet
tweetsSample =
    [ { id = 1000857125235642400
      , user =
            { id = 758519817578086400
            , screenName = "Desesquerdizada"
            }
      , retweet = Nothing
      }
    , { id = 1000933688572555300
      , user =
            { id = 708092973716807700
            , screenName = "tuliovsky"
            }
      , retweet =
            Just
                { id = 1000857125235642400
                , user =
                    { id = 758519817578086400
                    , screenName = "Desesquerdizada"
                    }
                }
      }
    , { id = 1000928922870132700
      , user =
            { id = 169545469
            , screenName = "Ricardo_Obadiah"
            }
      , retweet =
            Just
                { id = 1000857125235642400
                , user =
                    { id = 758519817578086400
                    , screenName = "Desesquerdizada"
                    }
                }
      }
    ]


tweetsSampleWithoutRetweetRoot : List Tweet
tweetsSampleWithoutRetweetRoot =
    [ { id = 1000933688572555300
      , user =
            { id = 708092973716807700
            , screenName = "tuliovsky"
            }
      , retweet =
            Just
                { id = 1000857125235642400
                , user =
                    { id = 758519817578086400
                    , screenName = "Desesquerdizada"
                    }
                }
      }
    , { id = 1000928922870132700
      , user =
            { id = 169545469
            , screenName = "Ricardo_Obadiah"
            }
      , retweet =
            Just
                { id = 1000857125235642400
                , user =
                    { id = 758519817578086400
                    , screenName = "Desesquerdizada"
                    }
                }
      }
    ]
