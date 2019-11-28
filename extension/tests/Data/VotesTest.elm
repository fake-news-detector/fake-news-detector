module Data.VotesTest exposing (..)

import Data.Category exposing (..)
import Data.Votes exposing (..)
import Expect exposing (Expectation)
import Locale.Words as Words
import Test exposing (..)


suite : Test
suite =
    describe "Votes"
        [ describe "chanceToText"
            [ test "slightly conclusive prediction" <|
                \_ -> chanceToText 0.65 |> Expect.equal Words.LooksLike
            , test "medium conclusive prediction" <|
                \_ -> chanceToText 0.8 |> Expect.equal Words.LooksALotLike
            , test "highly conclusive prediction" <|
                \_ -> chanceToText 0.9 |> Expect.equal Words.AlmostCertain
            ]
        , describe "predictionsToText"
            [ test "medium, highly and slightly positive predictions, to be shown in the right order" <|
                \_ ->
                    predictionsToText
                        { fake_news = 0.65
                        , extremely_biased = 0.9
                        , clickbait = 0.8
                        }
                        |> Expect.equal
                            [ ( Words.AlmostCertain, ExtremelyBiased )
                            , ( Words.LooksALotLike, Clickbait )
                            , ( Words.LooksLike, FakeNews )
                            ]
            , test "one positive and two negative predictions" <|
                \_ ->
                    predictionsToText
                        { fake_news = 0.3
                        , extremely_biased = 0.65
                        , clickbait = 0.3
                        }
                        |> Expect.equal
                            [ ( Words.LooksLike, ExtremelyBiased )
                            ]
            ]
        , describe "join people votes content with clickbait"
            [ test "is click bait" <|
                \_ ->
                    joinClickbaitCategory { content = [ { category = FakeNews, count = 5 } ], title = { clickbait = True, count = 10 } }
                        |> Expect.equal
                            [ { category = Clickbait, count = 10 }
                            , { category = FakeNews, count = 5 }
                            ]
            , test "is not click bait" <|
                \_ ->
                    joinClickbaitCategory { content = [ { category = FakeNews, count = 5 } ], title = { clickbait = False, count = 10 } }
                        |> Expect.equal
                            [ { category = FakeNews, count = 5 }
                            ]
            ]
        ]
