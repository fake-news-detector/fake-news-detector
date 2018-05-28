module Data.TweetsGraphTest exposing (..)

import Data.TweetsGraph exposing (..)
import Expect exposing (Expectation)
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
