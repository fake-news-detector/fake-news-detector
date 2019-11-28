module Data.Category exposing (..)

import Locale.Words as Words


type Category
    = Legitimate
    | FakeNews
    | Clickbait
    | ExtremelyBiased
    | Satire
    | NotNews


fromId : Int -> Category
fromId id =
    case id of
        1 ->
            Legitimate

        2 ->
            FakeNews

        3 ->
            Clickbait

        4 ->
            ExtremelyBiased

        5 ->
            Satire

        6 ->
            NotNews

        _ ->
            Legitimate


toId : Category -> Int
toId category =
    case category of
        Legitimate ->
            1

        FakeNews ->
            2

        Clickbait ->
            3

        ExtremelyBiased ->
            4

        Satire ->
            5

        NotNews ->
            6


toEmoji : Category -> String
toEmoji category =
    case category of
        Legitimate ->
            "✅"

        FakeNews ->
            "💀"

        Clickbait ->
            "🐟"

        ExtremelyBiased ->
            "🙉"

        Satire ->
            "\u{1F921}"

        NotNews ->
            "🏳️"


toName : Category -> Words.LocaleKey
toName category =
    case category of
        Legitimate ->
            Words.Legitimate

        FakeNews ->
            Words.FakeNews

        Clickbait ->
            Words.Clickbait

        ExtremelyBiased ->
            Words.Biased

        Satire ->
            Words.Satire

        NotNews ->
            Words.NotNews
